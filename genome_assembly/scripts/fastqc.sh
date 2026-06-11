#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 2
#SBATCH --mem=600GB
#SBATCH -o out_%A_%a.txt
#SBATCH -e error_%A_%a.txt
#SBATCH --job-name=fastqc
#SBATCH --time=20:00:00
#SBATCH --partition=general
#SBATCH --account=<account_name>
#SBATCH --array=0-0

module load fastqc/0.11.9-java-11 
source ~/.bashrc

# Increase Java heap size
export _JAVA_OPTIONS="-Xmx64G"

# Configuration: Use environment variables or default to relative paths
DATA_DIR=${VN1K_DATA:-"./data"}
FASTQC_DIR=${VN1K_FASTQC:-"./FastQC"}

# names=("VN0007" "VN0920" "HG01596_ONT" "HG02018_ONT" "HG02059_ONT" "HG02080_ONT")

# for the PacBio data
# fastqcs=(
#     '${DATA_DIR}/pacbio/VN0007.hifi_reads.fq.gz'
#     '${DATA_DIR}/pacbio/VN0920.hifi_reads.fq.gz'
#     '${DATA_DIR}/hg01596/HG01596_ONT_combined.fastq.gz' 
#     '${DATA_DIR}/hg02018/HG02018_ONT_combined.fastq.gz' 
#     '${DATA_DIR}/hg02059/HG02059_ONT_combined.fastq.gz' 
#     '${DATA_DIR}/hg02080/HG02080_ONT_combined.fastq.gz'
# )

# names=("VN0007" "VN0920" "HG01596_HIFI" "HG02018_HIFI" "HG02059_HIFI" "HG02080_HIFI")

# fastqcs=(
#     "${DATA_DIR}/ont/Human0007_SUP_recall.fastq"
#     "${DATA_DIR}/ont/Human0920_SUP.fastq"
#     "${DATA_DIR}/hg01596/JAX_HiFi_HG01596_m64039_220216_202046.fastq.gz"
#     "${DATA_DIR}/hg02018/m54329U_220129_124757.hifi_reads.fastq"
#     "${DATA_DIR}/hg02059/asm/HG02059_hifi.fastq.gz"
#     "${DATA_DIR}/hg02080/asm/HG02080_hifi.fastq.gz"
# )

# for the PacBio data () 
# # VN0007
# ${DATA_DIR}/ont/Human0007_SUP_recall.fastq 
# # VN0920
# ${DATA_DIR}/ont/Human0920_SUP.fastq
# # HG01596
# ${DATA_DIR}/hg01596/JAX_HiFi_HG01596_m64039_220216_202046.fastq.gz
# ${DATA_DIR}/hg01596/JAX_HiFi_HG01596_m64119_220214_210708.fastq.gz
# ${DATA_DIR}/hg01596/JAX_HiFi_HG01596_m64119_220209_052029.fastq.gz
# #HG02018
# ${DATA_DIR}/hg02018/m54329U_220129_124757.hifi_reads.fastq
# ${DATA_DIR}/hg02018/m54329U_220128_015221.hifi_reads.fastq
# ${DATA_DIR}/hg02018/m54329U_220125_004416.hifi_reads.fastq
# #HG02059
# ${DATA_DIR}/hg02059/asm/HG02059_hifi.fastq.gz
# #HG02080
# ${DATA_DIR}/hg02080/asm/HG02080_hifi.fastq.gz

names=("HG01596_HIFI")
fastqcs=("${DATA_DIR}/hg01596/JAX_HiFi_HG01596_m64039_220216_202046.fastq.gz")

process_sample() {
    local fname=$1
    local fq=$2

    mkdir -p "${FASTQC_DIR}/${fname}"

    if [ "$fname" == "HG01596_HIFI" ]; then
        fq="${DATA_DIR}/hg01596/HG01596_hifi_combined_new.fastq.gz"
        cat "${DATA_DIR}/hg01596/JAX_HiFi_HG01596_m64039_220216_202046.new.fastq" \
            "${DATA_DIR}/hg01596/JAX_HiFi_HG01596_m64119_220214_210708.new.fastq" \
            "${DATA_DIR}/hg01596/JAX_HiFi_HG01596_m64119_220209_052029.new.fastq" \
            | gzip > "${fq}"
    fi

    fastqc -Xmx64G -o "${FASTQC_DIR}/${fname}" "${fq}"

    if [[ $? -ne 0 ]]; then
        echo "FastQC failed for sample ${fname}" >&2
        exit 1
    fi
}

fname=${names[$SLURM_ARRAY_TASK_ID]}
fq=${fastqcs[$SLURM_ARRAY_TASK_ID]}

if [[ -z "$fname" || -z "$fq" ]]; then
    echo "Error: Sample name or fastq file is empty. Check the SLURM_ARRAY_TASK_ID." >&2
    exit 1
fi

process_sample "$fname" "$fq"