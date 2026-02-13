sample="$1"
first_run="$3"
second_run="$5"

echo "$sample"

# first_root="${first_run}""/pipelines/Dragen_v07.011.350.3.3.11/"
# second_root="${second_run}""/pipelines/Dragen_v07.011.350.3.3.11/"
first_root="${first_run}""/pipelines/Dragen_v3.6.3/"
second_root="${second_run}""/pipelines/Dragen_v3.6.3/"

Result_root="${second_root}""topup_samples/""${sample}/"
Ref_folder="/home/shared/references/Homo_sapiens_assembly38.fasta"
#Ref_folder="/staging/Refs/Homo_sapiens_assembly38.fasta"
Picard_folder="/dragennfs/area1/analysis/picard/"

SampleNumber="${sample:9:4}"
#SampleNumber="$((S+=0))"

mkdir "${Result_root}"qualimap_"${SampleNumber}"

qualimap bamqc -bam "${Result_root}""${sample}".merged.bam -outdir "${Result_root}"qualimap_"${SampleNumber}" -c -gd HUMAN -ip -nt 10 -sd -sdmode 2 --java-mem-size=20G

rtg samstats -t /home/shared/references/hg38.sdf "${Result_root}""${sample}".merged.bam --consensus --distributions --per-file --validate >"${Result_root}""${sample}"_samstats.txt

rtg coverage -t /home/shared/references/hg38.sdf -s 20 -o "${Result_root}""${sample}"_cov "${Result_root}""${sample}".merged.bam

java -jar "$Picard_folder"picard.jar QualityScoreDistribution I="${Result_root}""${sample}".merged.bam O="${Result_root}""${sample}"_qual_score_dist.txt CHART="${Result_root}""${sample}"_qual_score_dist.pdf

java -jar "$Picard_folder"picard.jar CollectQualityYieldMetrics I="${Result_root}""${sample}".merged.bam O="${Result_root}""${sample}"_quality_yield_metrics.txt R="${Ref_folder}"

java -jar "$Picard_folder"picard.jar CollectVariantCallingMetrics I="${Result_root}""${sample}".vcf.gz O="${Result_root}""${sample}"_picard_vc_metrics.txt DBSNP="/home/shared/standards/dbsnp151.with_chr.vcf.gz"

rtg vcfstats "${Result_root}""${sample}".vcf.gz >"${Result_root}""${sample}".vcfstats.txt

#rtg vcfeval -b /dragennfs/area1/trangth18/NA12878/gold_standard/Illumina_Platinum/NA12878.vcf.gz -e /dragennfs/area1/trangth18/NA12878/gold_standard/Illumina_Platinum/ConfidentRegions.bed.gz -c "${Result_root}""${sample}"/"${sample}".vcf.gz -t /home/shared/references/hg38.sdf -f AVR -o "${Result_root}"/vcfstats

#java -jar /dragennfs/area1/analysis/picard/picard.jar CollectSequencingArtifactMetrics I="${Result_root}""${sample}"/"${sample}".sort.md.grp.bqsr.bam O="${Result_root}"/"${sample}"_artifact_metrics.txt R=/home/shared/references/Homo_sapiens_assembly38.fasta
