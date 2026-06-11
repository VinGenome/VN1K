#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --mem=800GB
#SBATCH -o out_%x_%j.txt
#SBATCH -e error_%x_%j.txt
#SBATCH --job-name=assembly_hifi
#SBATCH --time=42:00:00
#SBATCH --partition=general
#SBATCH --account=<account_name>

# Load necessary modules and environments
source activate ragtag
module load matplotlib/3.5.2-foss-2022a
module load samtools/1.16.1-gcc-11.3.0

# Configuration: Use environment variables or default to relative paths
SAMPLE="HG01596"
DATA_DIR=${VN1K_DATA:-"./data/${SAMPLE}"}
ASM_DIR="${DATA_DIR}/asm_new"
QUAST_DIR="${DATA_DIR}/qc_hifi_${SAMPLE}_new"
THREADS=16

# Create directories if they don't exist
mkdir -p "$ASM_DIR" "$QUAST_DIR"

# Convert BAM files to FASTQ format
cd "$DATA_DIR"
for file in *.bam; do
    echo "Converting $(basename "$file") to FASTQ..."
    samtools bam2fq "$file" > "${file%.bam}.new.fastq"
done

# Step 1: Run Hifiasm for de novo assembly
echo "Running Hifiasm for ${SAMPLE}..."
hifiasm -o "${ASM_DIR}/${SAMPLE}_asm" -t "$THREADS" \
    "JAX_HiFi_${SAMPLE}_m64039_220216_202046.new.fastq" \
    "JAX_HiFi_${SAMPLE}_m64119_220209_052029.new.fastq" \
    "JAX_HiFi_${SAMPLE}_m64119_220214_210708.new.fastq"

# Check if hifiasm completed successfully
if [ $? -eq 0 ]; then
    echo "Hifiasm completed successfully for ${SAMPLE}"
else
    echo "Error during Hifiasm assembly for ${SAMPLE}. Check the logs for details."
    exit 1
fi

echo "Assembly process completed for ${SAMPLE}"

# Step 2: Convert GFA to FASTA
echo "Converting GFA to FASTA..."
gfatools gfa2fa "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.gfa" > "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.fa"

# Step 3: Run Quast for QC
echo "Running Quast..."
python quast.py \
    "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.fa" \
    -o "$QUAST_DIR"

echo "QC process completed for ${SAMPLE}"

# Deactivate the Conda environment
conda deactivate