#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 64
#SBATCH --mem=1500GB
#SBATCH -o out_%x_%j.txt
#SBATCH -e error_%x_%j.txt
#SBATCH --job-name=weg_0920
#SBATCH --time=300:00:00
#SBATCH --partition=general
#SBATCH --account=<your_account_name>

# Set environment
export LANGUAGE=C; export LC_ALL=C; export LANG=C; export LC_CTYPE=C

# Container and wengan download from here https://github.com/adigenova/wengan
# to get help; run: singularity exec "/<PROJECT>/<ROOT>"/WG/wengan_v0.2.sif perl "/<PROJECT>/<ROOT>"/WG/wengan-v0.2-bin-Linux/wengan.pl -h
# Define Project Root and Tools
PROJECT_ROOT=${WENGAN_PROJECT_ROOT:-"/<PROJECT>/<ROOT>"}
CONTAINER="${PROJECT_ROOT}/WG/wengan_v0.2.sif"
WENGAN_BIN="${PROJECT_ROOT}/WG/wengan-v0.2-bin-Linux/wengan.pl"
QUAST_BIN="${PROJECT_ROOT}/quast/quast.py"

# Data and Output configuration
DATA_ROOT=${VN1K_DATA:-"./data"}
SAMPLE="VN0920"
THREADS=64

# Host paths
HOST_NANOPORE="${DATA_ROOT}/ont/Human0920_SUP.fastq.gz"
HOST_PACBIO="${DATA_ROOT}/pacbio/VN0920.hifi_reads.fq.gz"
HOST_OUTPUT="./wengan_${SAMPLE}/tmp"
HOST_QUAST="./q_wengan_${SAMPLE}"

# Create directories
mkdir -p "$HOST_OUTPUT" "$HOST_QUAST"

# Container paths (Mounting /QRISdata to /mnt)
MOUNT_POINT="/mnt"
CONT_NANOPORE="${HOST_NANOPORE/\/QRISdata/$MOUNT_POINT}"
CONT_PACBIO="${HOST_PACBIO/\/QRISdata/$MOUNT_POINT}"
CONT_OUTPUT="${HOST_OUTPUT/\/QRISdata/$MOUNT_POINT}"

echo "Starting WENGAN assembly for ${SAMPLE} at $(date)"

# Run Wengan via Singularity
# Bind the data source to the container mount point
singularity exec --bind "/QRISdata:${MOUNT_POINT}" "$CONTAINER" perl "$WENGAN_BIN" \
 -x ccsont \
 -a M \
 -l "$CONT_NANOPORE" \
 -b "$CONT_PACBIO" \
 -p "$CONT_OUTPUT" \
 -t "$THREADS" \
 -g 3000

if [ $? -eq 0 ]; then
    echo "WENGAN assembly completed successfully at $(date)"
    
    echo "Running Quast..."
    python "$QUAST_BIN" \
         "${HOST_OUTPUT}/asm_wengan.contigs.fa" \
         -o "$HOST_QUAST"
    echo "Quast assessment completed."
else
    echo "WENGAN assembly failed."
    exit 1
fi