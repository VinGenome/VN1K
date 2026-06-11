#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem=200GB
#SBATCH -o out_%x_%j.txt
#SBATCH -e error_%x_%j.txt
#SBATCH --job-name=assembly_hifi
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --account=<account_name>

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Job started at $(date)"

# Load modules and environments
source activate ragtag
module load matplotlib/3.5.2-foss-2022a
module load samtools/1.16.1-gcc-11.3.0 
module load fastqc/0.11.9-java-11  

# Configuration: Use environment variables or default to relative paths
SAMPLE="HG02059"
DATA_DIR=${VN1K_DATA:-"./data/${SAMPLE}"}
ASM_DIR="${DATA_DIR}/asm"
QUAST_DIR="${DATA_DIR}/qc_hifi_${SAMPLE}"
THREADS=32

mkdir -p "$ASM_DIR" "$QUAST_DIR"

echo "Converting BAM to FASTQ..."
for file in "${DATA_DIR}"/*.hifi_reads.bam; do
    echo "Processing $(basename "$file")"
    samtools bam2fq -@ "$THREADS" "$file" | gzip > "${ASM_DIR}/$(basename "${file%.hifi_reads.bam}.fastq.gz")"
done

echo "BAM to FASTQ conversion completed at $(date)"

echo "Combining FASTQ files..."
zcat "${ASM_DIR}"/*.fastq.gz | gzip > "${ASM_DIR}/${SAMPLE}_hifi.fastq.gz"

echo "Running hifiasm..."
hifiasm -o "${ASM_DIR}/${SAMPLE}_asm" -t "$THREADS" "${ASM_DIR}/${SAMPLE}_hifi.fastq.gz"

echo "Hifiasm completed at $(date)"

# Step 2: gfa -> fasta
echo "Converting GFA to FASTA..."
gfatools gfa2fa "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.gfa" > "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.fa"

# Step 3: Quast analysis
echo "Running Quast..."
python quast.py \
    "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.fa" \
    -o "$QUAST_DIR"

if [ $? -eq 0 ]; then
    echo "Quast analysis completed successfully at $(date)"
else
    echo "Error during Quast analysis. Check the logs for details."
    exit 1
fi

conda deactivate

echo "Job completed at $(date)"