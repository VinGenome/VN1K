#!/bin/bash
#SBATCH -N 1                          # Number of nodes
#SBATCH -n 1                          # Number of tasks (each task for one sample)
#SBATCH -c 32                         # Number of CPU cores per task
#SBATCH --mem=400GB                   # Total memory for the entire job
#SBATCH -o out_%x_%A_%a.txt           # File for stdout, %A is job ID, %a is array task ID
#SBATCH -e error_%x_%A_%a.txt         # File for stderr
#SBATCH --job-name=pacnano            # Job name
#SBATCH --time=50:00:00               # Maximum time for each task
#SBATCH --partition=general           # Partition to run the job
#SBATCH --account=<account_name>      # Account to use
#SBATCH --array=0-0                   # Array range

# Load necessary modules
module load minimap2/2.24-gcccore-11.3.0 
module load matplotlib/3.5.2-foss-2022a

source activate ragtag

# Configuration: Use environment variables or default to relative paths
DATA_DIR=${VN1K_DATA:-"./data"}
THREADS_PER_SAMPLE=32  

# Define the list of samples
samples=(
    'HG01596' #'HG02018' 'HG01596' 'HG02059' 'HG02080'
)

# Function to process a sample
process_sample() {
    local sample_id=$1
    local start_time=$(date +%s)

    echo "[$(date)] Starting processing for ${sample_id}"

    local nano_assembly="${DATA_DIR}/flye_${sample_id}/assembly.fasta"
    local pacbio_assembly="${DATA_DIR}/${sample_id}/asm_new/${sample_id}_asm.bp.p_ctg.fa"
    local output_dir="${DATA_DIR}/pac_nano_${sample_id}"
    local quast_dir="${DATA_DIR}/quast_pac_nano_${sample_id}"
    
    # Check if input files exist
    if [[ ! -f $nano_assembly || ! -f $pacbio_assembly ]]; then
        echo "Error: Input files not found for ${sample_id}" >&2
        return 1
    fi

    # Create output directories
    mkdir -p "$output_dir" "$quast_dir"

    # Step 1: Run RagTag
    echo "Running RagTag for ${sample_id}..."
    time ragtag.py patch "$pacbio_assembly" "$nano_assembly" -o "$output_dir" -f 5000 -d 50000 -s 100000 -w -u -t "$THREADS_PER_SAMPLE"

    if [ $? -ne 0 ]; then
        echo "Error during RagTag for ${sample_id}. Exit code: $?" >&2
        return 1
    fi

    # Rename the output file
    mv "${output_dir}/ragtag.patch.fasta" "${output_dir}/${sample_id}_pac_nano.fasta"
    
    if [ ! -f "${output_dir}/${sample_id}_pac_nano.fasta" ]; then
        echo "Error: Failed to rename output file for ${sample_id}" >&2
        return 1
    fi

    # Step 2: Quality assessment with Quast
    echo "Running Quast for ${sample_id}..."
    # Ensure the path to quast.py is updated if necessary
    python quast.py \
        "${output_dir}/${sample_id}_pac_nano.fasta" \
        -o "$quast_dir"

    if [ $? -ne 0 ]; then
        echo "Error during Quast analysis for ${sample_id}. Exit code: $?" >&2
        return 1
    fi

    # Check for expected output files
    if [ ! -f "${quast_dir}/report.txt" ]; then
        echo "Error: Quast output files not found for ${sample_id}" >&2
        return 1
    fi

    local end_time=$(date +%s)
    echo "[$(date)] Assembly process completed for ${sample_id}"
    echo "Total runtime: $((end_time - start_time)) seconds"
    echo "Memory usage: $(free -h)"
    echo "Disk usage: $(df -h .)"
}

# Set up error handling
trap 'echo "Job for ${samples[$SLURM_ARRAY_TASK_ID]} interrupted" >&2; exit 1' INT TERM

# Execute the process_sample function for the current array task
sample=${samples[$SLURM_ARRAY_TASK_ID]}
process_sample "$sample"

# Deactivate the conda environment
conda deactivate

echo "Job completed successfully"
