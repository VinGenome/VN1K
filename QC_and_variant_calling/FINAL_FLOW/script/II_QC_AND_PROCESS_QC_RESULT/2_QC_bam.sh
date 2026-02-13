RUN_folder="$1"
sample="$2"

Sample_root=$RUN_folder"pipelines/Dragen_v3.6.3/""${sample}/"
Picard_folder="/dragennfs/area1/analysis/picard/"

Ref_folder="/home/shared/references/Homo_sapiens_assembly38.fasta"
#Ref_folder="/staging/Refs/Homo_sapiens_assembly38.fasta"

java -jar "$Picard_folder"picard.jar CollectRawWgsMetrics \
	I="${Sample_root}""${sample}".bam \
	O="${Sample_root}""${sample}"_wgs_metrics.txt \
	R="${Ref_folder}" INCLUDE_BQ_HISTOGRAM=true

java -jar "$Picard_folder"picard.jar \
	CollectGcBiasMetrics I="${Sample_root}""${sample}".bam \
	O="${Sample_root}""${sample}"_gc_bias_metrics.txt \
	CHART="${Sample_root}""${sample}"_gc_bias_metrics.pdf \
	S="${Sample_root}""${sample}"_summary_metrics.txt \
	R="${Ref_folder}"

java -jar "$Picard_folder"picard.jar \
	CollectAlignmentSummaryMetrics I="${Sample_root}""${sample}".bam \
	O="${Sample_root}""${sample}"_alignment_metrics.txt \
	R="${Ref_folder}"

java -jar "$Picard_folder"picard.jar \
	CollectInsertSizeMetrics I="${Sample_root}""${sample}".bam \
	O="${Sample_root}""${sample}"_insert_size_metrics.txt \
	H="${Sample_root}""${sample}"_insert_size_histogram.pdf M=0.5
