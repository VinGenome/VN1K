RUN_folder="$1"
sample="$2"

RawFastq_folder="${RUN_folder}""fastq_raw/"
CleanCombine_folder="${RUN_folder}""fastq_clean/clean_combines/"
QC_folder="${RUN_folder}""qc/"

mkdir -p "${QC_folder}""${sample}"/after
mkdir -p "${QC_folder}""${sample}"/before

# QC before
fastqc  "${RawFastq_folder}""${sample}"*"_L001_R1"*.fastq.gz \
        "${RawFastq_folder}""${sample}"*"_L001_R2"*.fastq.gz \
        "${RawFastq_folder}""${sample}"*"_L002_R1"*.fastq.gz \
        "${RawFastq_folder}""${sample}"*"_L002_R2"*.fastq.gz \
        "${RawFastq_folder}""${sample}"*"_L003_R1"*.fastq.gz \
        "${RawFastq_folder}""${sample}"*"_L003_R2"*.fastq.gz \
        "${RawFastq_folder}""${sample}"*"_L004_R1"*.fastq.gz \
        "${RawFastq_folder}""${sample}"*"_L004_R2"*.fastq.gz \
        --outdir "${QC_folder}""${sample}"/before -t 8

# QC after
fastqc "${CleanCombine_folder}""${sample}"/"${sample}"_R1.filtered.trimmed.fastq.gz \
        "${CleanCombine_folder}""${sample}"/"${sample}"_R2.filtered.trimmed.fastq.gz \
        --outdir "${QC_folder}""${sample}"/after -t 8
