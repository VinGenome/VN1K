#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem=800GB
#SBATCH -o out_%A_%a.txt
#SBATCH -e error_%A_%a.txt
#SBATCH --time=24:00:00
#SBATCH --partition=general
#SBATCH --account=<account_name>
#SBATCH --array=0-3

set -e  # Exit immediately if a command exits with a non-zero status.

# Samples
samples=('HG01596' 'HG02018' 'HG02059' 'HG02080')

process_sample() {
    local SAMPLE=$1
    local THREADS=$2

    echo "Processing sample ${SAMPLE} at $(date)"

    # Configuration: Use environment variables or default to relative paths
    local DATA_DIR=${VN1K_DATA:-"./data/${SAMPLE}"}
    local ASM_DIR="${DATA_DIR}/asm"
    local QUAST_DIR="${DATA_DIR}/qc_hifi_${SAMPLE}"
    
    mkdir -p "$ASM_DIR" "$QUAST_DIR"

    cd "$DATA_DIR"
    echo "Converting BAM to FASTQ for ${SAMPLE}..."
    
    case $SAMPLE in
        HG01596|HG02018)
            # Process BAMs directly
            for file in *.bam; do
                [ -e "$file" ] || continue
                samtools bam2fq -@ "$THREADS" "$file" > "${file%.bam}.hifi_reads.fastq"
            done
            ;;
        HG02059|HG02080)
            # Process BAMs and combine
            local pattern="m54329U_*.hifi_reads.bam"
            [[ "$SAMPLE" == "HG02080" ]] && pattern="m64043_*.ccs.bam"
            
            for file in $pattern; do
                [ -e "$file" ] || continue
                echo "Processing $file"
                samtools bam2fq -@ "$THREADS" "$file" | gzip > "$ASM_DIR/${file%.bam}.fastq.gz"
            done
            echo "Combining FASTQ files for ${SAMPLE}..."
            zcat "$ASM_DIR"/*.fastq.gz | gzip > "$ASM_DIR/${SAMPLE}_hifi_reads.fastq.gz"
            rm "$ASM_DIR"/*.fastq.gz
            ;;
    esac

    # Run hifiasm
    echo "Running hifiasm for ${SAMPLE} at $(date)"
    local INPUT_FASTQ="$ASM_DIR/${SAMPLE}_hifi_reads.fastq.gz"
    [[ ! -f "$INPUT_FASTQ" ]] && INPUT_FASTQ="*.hifi_reads.fastq"
    
    hifiasm -o "$ASM_DIR/${SAMPLE}_asm" -t "$THREADS" $INPUT_FASTQ

    echo "Converting GFA to FASTA for ${SAMPLE} at $(date)"
    gfatools gfa2fa "$ASM_DIR/${SAMPLE}_asm.bp.p_ctg.gfa" | gzip > "$ASM_DIR/${SAMPLE}_asm.bp.p_ctg.fa.gz"

    echo "Running Quast for ${SAMPLE} at $(date)"
    python quast.py \
        "$ASM_DIR/${SAMPLE}_asm.bp.p_ctg.fa.gz" \
        -o "$QUAST_DIR"

    echo "Processing completed for sample ${SAMPLE} at $(date)"
}

# Main execution
source activate ragtag
module load matplotlib/3.5.2-foss-2022a
module load samtools/1.16.1-gcc-11.3.0 
module load fastqc/0.11.9-java-11  

sample=${samples[$SLURM_ARRAY_TASK_ID]}
process_sample "$sample" 32

conda deactivate