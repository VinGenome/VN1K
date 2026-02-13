while read sample Run_folder
do
	Sample_root="$Run_folder""fastq_clean/clean_combines/";
	Result_root="$Run_folder""pipelines/Dragen_v3.6.3/";
	RUN_ID="$(echo $Run_folder | cut -d'/' -f5)"

	mkdir -p "${Result_root}""${sample}"/

	echo $(dragen --version)
	echo "Sample "$sample
	echo "RG" $RUN_ID

	dragen -f -r /staging/references --output-directory "${Result_root}""${sample}"/ --output-file-prefix "${sample}" -1 "${Sample_root}""${sample}"/"${sample}"_R1.filtered.trimmed.fastq.gz -2 "${Sample_root}""${sample}"/"${sample}"_R2.filtered.trimmed.fastq.gz --enable-map-align-output true --enable-bam-indexing true --enable-variant-caller true --RGID $RUN_ID  --RGSM "${sample}" --enable-duplicate-marking true --vc-emit-ref-confidence GVCF --enable-cnv true --cnv-enable-self-normalization true --enable-map-align true --ht-alt-aware-validate true

done<"$1"
#dragen -r /staging/Refs/ --enable-joint-genotyping true --output-file-prefix "${sample}" --output-directory "${Result_root}""${sample}"/ --variant "${Result_root}""${sample}"/"${sample}".hard-filtered.gvcf.gz
