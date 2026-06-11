#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem=600GB
#SBATCH -o out_%x_%A_%a.txt
#SBATCH -e error_%x_%A_%a.txt
#SBATCH --job-name=assembly_ont
#SBATCH --time=200:00:00
#SBATCH --partition=general
#SBATCH --account=<account_name>

# Load modules
module load flye/2.9-gcc-10.3.0
module load samtools/1.16.1-gcc-11.3.0 
module load minimap2/2.24-gcccore-11.3.0 
module load bcftools/1.15.1-gcc-11.3.0
module load tabixpp/1.1.0-gcc-10.3.0
source ~/.bashrc

start_time=$(date +%s)

# Configuration: Use environment variables or default to relative paths
SAMPLE_ID="HG02018"
DATA_DIR=${VN1K_DATA:-"./data/${SAMPLE_ID}"}
FLYE_OUTPUT_DIR="${DATA_DIR}/flye_${SAMPLE_ID}"
QUAST_DIR="${DATA_DIR}/quast_ONT_${SAMPLE_ID}"
THREADS=32

mkdir -p "$FLYE_OUTPUT_DIR" "$QUAST_DIR"

echo "Running Flye assembly for ${SAMPLE_ID}..."
flye --nano-hq \
    "${DATA_DIR}/20221025_HG02018_UL_eee-prom1-1D-PAM78083_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz" \
    "${DATA_DIR}/20221101_HG02018_UL_eee-prom1-1G-PAM79302_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz" \
    "${DATA_DIR}/20221102_HG02018_UL_eee-prom1-3H-PAM78744_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz" \
    "${DATA_DIR}/20221108_HG02018_UL_eee-prom1-3B-PAM64235_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz" \
    "${DATA_DIR}/20221130_HG02018_UL_eee-prom1-2C-PAM77931_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz" \
    "${DATA_DIR}/20221206_HG02018_UL_eee-prom1-2C-PAG68624_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz" \
    "${DATA_DIR}/20221207_HG02018_UL_eee-prom1-2C-PAG68624_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz" \
    "${DATA_DIR}/20230210_HG02018_UL_eee-prom1-3B-PAG76493_guppy-5.0.11-sup-prom_fastq_pass.fastq.gz" \
    --genome-size 3g \
    --threads "$THREADS" \
    --out-dir "$FLYE_OUTPUT_DIR"

if [ $? -eq 0 ]; then
    echo "Flye assembly completed successfully for ${SAMPLE_ID}."
else
    echo "Error during Flye assembly for ${SAMPLE_ID}. Check the logs for details."
    exit 1
fi

echo "Running Quast for ${SAMPLE_ID}..."
python quast.py \
    "${FLYE_OUTPUT_DIR}/assembly.fasta" \
    -o "$QUAST_DIR"

echo "[$(date)] Assembly process completed for ${SAMPLE_ID}."
end_time=$(date +%s)
echo "Total runtime: $((end_time - start_time)) seconds"
echo "Memory usage: $(free -h)"
echo "Disk usage: $(df -h .)"