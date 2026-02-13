Picard_root="/dragennfs/area1/analysis/picard/"
GATK_root="/home/shared/tools/gatk-4.1.2.0/"

sample="$1"
first="$2"
first_run="$3"
second="$4"
second_run="$5"

echo "$sample"

first_root="${first_run}""pipelines/Bwa_mem/"
second_root="${second_run}""pipelines/Bwa_mem/"

topupBam_root="${second_root}""topup_samples/""${sample}/"
Result_root="${second_run}""pipelines/Parabricks/GATK_v4.0/topup_samples/""${sample}/"

[[ ! -f "${second_root}""topup_samples/" ]] && mkdir "${second_root}""topup_samples/"
mkdir "${topupBam_root}"
[[ ! -f "${second_run}""pipelines/Parabricks/GATK_v4.0/topup_samples/" ]] && mkdir "${second_run}""pipelines/Parabricks/GATK_v4.0/topup_samples/"
mkdir "${Result_root}"

java -jar "${Picard_root}"picard.jar MergeSamFiles I="${first_root}""${sample}"_"${first}"_01/"${sample}"_"${first}"_01.bam I="${second_root}""${sample}"_"${second}"_01/"${sample}"_"${second}"_01.bam O="${topupBam_root}"/"${sample}".merged.bam

java -jar "${Picard_root}"picard.jar AddOrReplaceReadGroups I="${topupBam_root}"/"${sample}".merged.bam O="${topupBam_root}"/"${sample}".fixedSN.bam RGID="${sample}"_topup RGLB=lib1 RGPL=ILLUMINA RGPU=unit1 RGSM="${sample}"

pbrun haplotypecaller --ref /home/shared/references/Homo_sapiens_assembly38.fasta --in-bam "${topupBam_root}""${sample}".fixedSN.bam --out-variants "${Result_root}""${sample}".merged.gvcf --gvcf

pbrun genotypegvcf --ref /home/shared/references/Homo_sapiens_assembly38.fasta --in-gvcf "${Result_root}"/"${sample}".merged.gvcf --out-vcf "${Result_root}"/"${sample}".merged.vcf

bgzip "${Result_root}"/"${sample}".merged.gvcf
tabix -p vcf "${Result_root}"/"${sample}".merged.gvcf.gz
