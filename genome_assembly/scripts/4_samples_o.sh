#!/bin/bash
#SBATCH -N 1                          # Number of nodes
#SBATCH -n 1                          # Number of tasks (each task for one sample)
#SBATCH -c 32                         # Number of CPU cores per task
#SBATCH --mem=800GB                   # Total memory for the entire job
#SBATCH -o out_%x_%A_%a.txt           # File for stdout, %A is job ID, %a is array task ID
#SBATCH -e error_%x_%A_%a.txt         # File for stderr
#SBATCH --job-name=4_ONTs             # Job name
#SBATCH --time=32:00:00               # Maximum time for each task
#SBATCH --partition=general           # Partition to run the job
#SBATCH --account=<account_name>      # Account to use
#SBATCH --array=0-3                   # Array range

# Load necessary modules
module load matplotlib/3.5.2-foss-2022a
module load flye/2.9-gcc-10.3.0
module load samtools/1.16.1-gcc-11.3.0 
module load minimap2/2.24-gcccore-11.3.0 
module load bcftools/1.15.1-gcc-11.3.0
module load tabixpp/1.1.0-gcc-10.3.0
source ~/.bashrc

# HG01596:
# HI-FI: https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220831_JAX_HiFi/HG01596/
# Nanopore ONT: https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20211013_ONT_Rebasecalled/HG01596/

# HG02018: 
# HI-FI: https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20220418_UW_HiFi/HG02018/
# Nanopore ONT: https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02018/

# HG02059: 
# HI-FI: https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20210509_UW_HiFi/HG02059/
# Nanopore ONT: https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/20230501_HGSVC_UL_ONT-UW/HG02059/

# HG02080: https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=working/HPRC_PLUS/HG02080/raw_data/

# Configuration: Use environment variables or default to relative paths
DATA_DIR=${VN1K_DATA:-"./data"}
THREADS=32

samples=('HG01596' 'HG02018' 'HG02059' 'HG02080')

# Function to process a sample
process_sample() {
    local sample_id=$1
    local sample_dir="${DATA_DIR}/${sample_id}"
    local combined_reads="${sample_dir}/${sample_id}_combined.fastq.gz"
    local flye_output_dir="${sample_dir}/flye_${sample_id}"
    local quast_dir="${sample_dir}/quast_${sample_id}"
    
    mkdir -p "$flye_output_dir" "$quast_dir"

    echo "Processing sample: ${sample_id}"
    cd "${sample_dir}"

    # Concatenate FASTQ files
    if [ "${sample_id}" == "HG01596" ]; then
        zcat 2022*_21-lee-006*.fastq.gz > "${combined_reads}"
    elif [ "${sample_id}" == "HG02018" ]; then
        zcat 2022*_${sample_id}_*.fastq.gz 2023*_${sample_id}_*.fastq.gz > "${combined_reads}"
    else
        zcat ${sample_id}_*.fastq.gz > "${combined_reads}"
    fi

    if [ $? -ne 0 ]; then
        echo "Error during concatenation for ${sample_id}."
        return 1
    fi

    # Step 1: De novo assembly with Flye
    echo "Running Flye assembly for ${sample_id}..."
    flye --nano-hq "${combined_reads}" --out-dir "${flye_output_dir}" --threads "${THREADS}"

    if [ $? -ne 0 ]; then
        echo "Error during Flye assembly for ${sample_id}."
        return 1
    fi

    # Step 3: Quality assessment with Quast
    python quast.py \
        "${flye_output_dir}/assembly.fasta" \
        -o "${quast_dir}"

    echo "Assembly process completed for ${sample_id}."
}

# Execute
sample=${samples[$SLURM_ARRAY_TASK_ID]}
process_sample "$sample"