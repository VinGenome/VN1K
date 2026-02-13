Run_folder="$1"
sample="$2"

Sample_root="$Run_folder""fastq_clean/clean_combines/"
Result_root="$Run_folder""pipelines/Dragen_v07.011.350.3.3.11/"

mkdir "${Result_root}""${sample}"/

echo $(dragen --version)
echo "Sample "$sample

dragen -f -r /staging/Refs/ --output-directory "${Result_root}""${sample}"/ --output-file-prefix "${sample}" -1 "${Sample_root}""${sample}"/"${sample}"_R1.filtered.trimmed.fastq.gz -2 "${Sample_root}""${sample}"/"${sample}"_R2.filtered.trimmed.fastq.gz --enable-map-align-output true --enable-variant-caller true --vc-sample-name "${sample}" --enable-duplicate-marking true --vc-emit-ref-confidence GVCF --enable-cnv true --cnv-enable-self-normalization true --enable-map-align true --ht-alt-aware-validate true

dragen -r /staging/Refs/ --enable-joint-genotyping true --output-file-prefix "${sample}" --output-directory "${Result_root}""${sample}"/ --variant "${Result_root}""${sample}"/"${sample}".hard-filtered.gvcf.gz
