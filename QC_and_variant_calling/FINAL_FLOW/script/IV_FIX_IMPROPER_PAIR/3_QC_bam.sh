sample="$2"
Run_folder="$1"

echo "$sample"

Picard_folder="/dragennfs/area1/analysis/picard/"

Ref_folder="/home/shared/references/Homo_sapiens_assembly38.fasta"
#Ref_folder="/staging/Refs/Homo_sapiens_assembly38.fasta"
Result_root="$Run_folder""pipelines/Dragen_v3.6.3/";

java -jar "$Picard_folder"picard.jar CollectRawWgsMetrics \
		I="${Result_root}""${sample}".mergeImproperSameChr_ProperPair.bam \
		O="${Result_root}""${sample}".mergeImproperSameChr_ProperPair_wgs_metrics.txt \
		R="${Ref_folder}" INCLUDE_BQ_HISTOGRAM=true

java -jar "$Picard_folder"picard.jar \
		CollectGcBiasMetrics I="${Sample_root}""${sample}".mergeImproperSameChr_ProperPair.bam \
		O="${Result_root}""${sample}"_mergeImproperSameChr_ProperPair_gc_bias_metrics.txt \
		CHART="${Result_root}""${sample}"_mergeImproperSameChr_ProperPair_gc_bias_metrics.pdf \
		S="${Result_root}""${sample}"_mergeImproperSameChr_ProperPair_summary_metrics.txt \
		R="${Ref_folder}"

java -jar "$Picard_folder"picard.jar \
		CollectAlignmentSummaryMetrics I="${Result_root}""${sample}".mergeImproperSameChr_ProperPair.bam \
		O="${Result_root}""${sample}"_mergeImproperSameChr_ProperPair_alignment_metrics.txt \
		R="${Ref_folder}"

java -jar "$Picard_folder"picard.jar  \
		CollectInsertSizeMetrics I="${Result_root}""${sample}".mergeImproperSameChr_ProperPair.bam \
		O="${Result_root}""${sample}"_mergeImproperSameChr_ProperPair_insert_size_metrics.txt \
		H="${Result_root}""${sample}"_mergeImproperSameChr_ProperPair_insert_size_histogram.pdf M=0.5
