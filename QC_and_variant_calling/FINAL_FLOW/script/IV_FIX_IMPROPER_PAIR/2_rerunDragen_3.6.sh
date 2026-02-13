Run_folder="$1"
sample="$2"

Result_root="$Run_folder""pipelines/Dragen_v3.6.3/";
RUN_ID="$(echo $Run_folder | cut -d'/' -f5)"

echo $(dragen --version)
echo "Sample "$sample
echo "RG" $RUN_ID

dragen -r /staging/references/ --output-directory "${Result_root}""${sample}" --output-file-prefix "${sample}".mergeImproperSameChr_ProperPair -b "${Result_root}""${sample}"/"${sample}".mergeImproperSameChr_ProperPair.bam --enable-variant-caller true --enable-sort true  --enable-duplicate-marking true  --enable-cnv true --cnv-enable-self-normalization true --enable-map-align true --ht-alt-aware-validate true --vc-emit-ref-confidence GVCF 

dragen -r /staging/references/ --enable-joint-genotyping true --output-file-prefix "${sample}" --output-directory "${Result_root}""${sample}"/ --variant "${Result_root}""${sample}"/"${sample}".mergeImproperSameChr_ProperPair.hard-filtered.gvcf.gz