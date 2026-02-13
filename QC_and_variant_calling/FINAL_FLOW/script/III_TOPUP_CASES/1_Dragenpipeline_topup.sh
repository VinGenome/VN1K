Picard_root="/dragennfs/area1/analysis/picard/"
GATK_root="/home/shared/tools/gatk-4.1.2.0/"

sample="$1"
first="$2"
first_run="$3"
second="$4"
second_run="$5"

echo "$sample"
echo "$second_run"

# first_root="${first_run}""/pipelines/Dragen_v07.011.350.3.3.11/"
# second_root="${second_run}""/pipelines/Dragen_v07.011.350.3.3.11/"
first_root="${first_run}""/pipelines/Dragen_v3.6.3/"
second_root="${second_run}""/pipelines/Dragen_v3.6.3/"

Result_root="${second_root}""topup_samples/""${sample}/"

[[ ! -f "${second_root}""topup_samples/" ]] && mkdir "${second_root}""topup_samples/"
mkdir "${Result_root}"

java -jar "${Picard_root}"picard.jar MergeSamFiles I="${first_root}""${sample}"_"${first}"_01/"${sample}"_"${first}"_01.bam I="${second_root}""${sample}"_"${second}"_01/"${sample}"_"${second}"_01.bam O="${Result_root}""${sample}".merged.bam

dragen -r /staging/Refs/ --output-directory "${Result_root}" --output-file-prefix "${sample}" -b "${Result_root}""${sample}".merged.bam --enable-variant-caller true --vc-sample-name "${sample}" --enable-duplicate-marking true --vc-emit-ref-confidence GVCF --enable-cnv true --cnv-enable-self-normalization true --enable-map-align true --ht-alt-aware-validate true

dragen -r /staging/Refs/ --enable-joint-genotyping true --output-file-prefix "${sample}" --output-directory "${Result_root}" --variant "${Result_root}""${sample}".hard-filtered.gvcf.gz
