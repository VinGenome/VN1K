sample="$1"
first_run="$3"
second_run="$5"

echo "$sample"

# second_root="${second_run}""/pipelines/Dragen_v07.011.350.3.3.11/"
second_root="${second_run}""/pipelines/Dragen_v3.6.3/"

Result_root="${second_root}""topup_samples/""${sample}/"

Picard_folder="/dragennfs/area1/analysis/picard/"

Ref_folder="/home/shared/references/Homo_sapiens_assembly38.fasta"
#Ref_folder="/staging/Refs/Homo_sapiens_assembly38.fasta"

java -jar "$Picard_folder"picard.jar CollectRawWgsMetrics \
	I="${Result_root}""${sample}".merged.bam \
	O="${Result_root}""${sample}"_wgs_metrics.txt \
	R="${Ref_folder}" INCLUDE_BQ_HISTOGRAM=true

java -jar "$Picard_folder"picard.jar \
	CollectGcBiasMetrics I="${Result_root}""${sample}".merged.bam \
	O="${Result_root}""${sample}"_gc_bias_metrics.txt \
	CHART="${Result_root}""${sample}"_gc_bias_metrics.pdf \
	S="${Result_root}""${sample}"_summary_metrics.txt \
	R="${Ref_folder}"

java -jar "$Picard_folder"picard.jar \
	CollectAlignmentSummaryMetrics I="${Result_root}""${sample}".merged.bam \
	O="${Result_root}""${sample}"_alignment_metrics.txt \
	R="${Ref_folder}"

java -jar "$Picard_folder"picard.jar \
	CollectInsertSizeMetrics I="${Result_root}""${sample}".merged.bam \
	O="${Result_root}""${sample}"_insert_size_metrics.txt \
	H="${Result_root}""${sample}"_insert_size_histogram.pdf M=0.5
