#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH --mem=600GB
#SBATCH -o out_%x_%j.txt
#SBATCH -e error_%x_%j.txt
#SBATCH --job-name=assembly_hifi
#SBATCH --time=48:00:00
#SBATCH --partition=general
#SBATCH --account=<account_name>

# Load necessary modules and environments
source activate ragtag
module load matplotlib/3.5.2-foss-2022a
module load samtools/1.16.1-gcc-11.3.0 
module load fastqc/0.11.9-java-11  

# Configuration: Use environment variables or default to relative paths
SAMPLE="HG02018"
DATA_DIR=${VN1K_DATA:-"./data/${SAMPLE}"}
ASM_DIR="${DATA_DIR}/asm"
QUAST_DIR="${DATA_DIR}/qc_hifi_${SAMPLE}"
THREADS=16

mkdir -p "$ASM_DIR" "$QUAST_DIR"

# Step 0: Convert BAM to FASTQ and run FastQC
cd "$DATA_DIR"
for file in *.bam; do
    echo "Converting $(basename "$file") to FASTQ..."
    samtools bam2fq "$file" > "${file%.bam}.fastq"
done

echo "Running FastQC..."
fastqc *.fastq

# Step 1: De-novo assembly by hifiasm
echo "Running hifiasm for ${SAMPLE}..."
hifiasm \
    -o "${ASM_DIR}/${SAMPLE}_asm" \
    -t "$THREADS" \
    m54329U_220125_004416.hifi_reads.fastq \
    m54329U_220128_015221.hifi_reads.fastq \
    m54329U_220129_124757.hifi_reads.fastq

# Step 2: gfa -> fasta
echo "Converting GFA to FASTA..."
gfatools gfa2fa "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.gfa" > "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.fa"

# Step 3: Quast QC
echo "Running Quast..."
python quast.py \
    "${ASM_DIR}/${SAMPLE}_asm.bp.p_ctg.fa" \
    -o "$QUAST_DIR"

conda deactivate