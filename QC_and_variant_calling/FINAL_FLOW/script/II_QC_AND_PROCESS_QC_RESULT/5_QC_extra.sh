Run_folder="$1"
sample="$2"

Ref_folder="/home/shared/references/Homo_sapiens_assembly38.fasta"
#Ref_folder="/staging/Refs/Homo_sapiens_assembly38.fasta"
Picard_folder="/dragennfs/area1/analysis/picard/"

        Result_root="$Run_folder"clean_Q30/Human_Par/"${sample}"/
        Bwa_root="$Run_folder"clean_Q30/Bwa_mem/"${sample}"/
        
# Sample_root="$Run_folder"pipelines/Dragen_v07.011.350.3.3.11/"${sample}"
Sample_root="$Run_folder"pipelines/Dragen_v3.6.3/"${sample}"
echo ${sample}

mkdir "${Sample_root}"/qualimap_"${sample}"

qualimap bamqc -bam "${Sample_root}"/"${sample}".bam -outdir "${Sample_root}"/qualimap_"${sample}" --java-mem-size=100G -c -gd HUMAN -ip -nt 10 -sd -sdmode 2

rtg samstats -t /home/shared/references/hg38.sdf "${Sample_root}"/"${sample}".bam --consensus --distributions --per-file --validate >"${Sample_root}"/"${sample}"_samstats.txt

rtg coverage -t /home/shared/references/hg38.sdf -s 20 -o "${Sample_root}"/"${sample}"_cov "${Sample_root}"/"${sample}".bam

java -jar "$Picard_folder"picard.jar QualityScoreDistribution I="${Sample_root}"/"${sample}".bam O="${Sample_root}"/"${sample}"_qual_score_dist.txt CHART="${Sample_root}"/"${sample}"_qual_score_dist.pdf

java -jar "$Picard_folder"picard.jar CollectQualityYieldMetrics I="${Sample_root}"/"${sample}".bam O="${Sample_root}"/"${sample}"_quality_yield_metrics.txt R="${Ref_folder}"

java -jar "$Picard_folder"picard.jar CollectVariantCallingMetrics I="${Sample_root}"/"${sample}".hard-filtered.vcf.gz O="${Sample_root}"/"${sample}"_picard_vc_metrics.txt DBSNP="/home/shared/standards/dbsnp151.with_chr.vcf.gz"

java -jar "$Picard_folder"picard.jar CollectOxoGMetrics I="${Sample_root}"/"${sample}".bam O="${Sample_root}"/"${sample}"_oxoG_metrics.txt R="${Ref_folder}"

rtg vcfstats "${Sample_root}"/"${sample}".hard-filtered.vcf.gz >"${Sample_root}"/"${sample}".vcfstats.txt



#rtg vcfeval -b /dragennfs/area1/trangth18/NA12878/gold_standard/Illumina_Platinum/NA12878.vcf.gz -e /dragennfs/area1/trangth18/NA12878/gold_standard/Illumina_Platinum/ConfidentRegions.bed.gz -c "${Sample_root}""${sample}"/"${sample}".vcf.gz -t /home/shared/references/hg38.sdf -f AVR -o "${Sample_root}"/vcfstats

#java -jar /dragennfs/area1/analysis/picard/picard.jar CollectSequencingArtifactMetrics I="${Sample_root}""${sample}"/"${sample}".sort.md.grp.bqsr.bam O="${Sample_root}"/"${sample}"_artifact_metrics.txt R=/home/shared/references/Homo_sapiens_assembly38.fasta
