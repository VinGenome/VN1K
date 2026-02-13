RUN_ID="$1"

Clean_root="/dragennfs/area4/analysis/""$RUN_ID""/fastq_clean/clean_lanes/";
Result_root="/dragennfs/area4/analysis/""$RUN_ID""/pipelines/GATK_v4.1/";
Picard_root="/home/shared/tools/picard/";
#Picard_root="/staging/picard/"
#GATK_root="/staging/gatk-4.1.2.0/"
Reference_root="/home/shared/references/";
GATK_root="/home/shared/tools/gatk-4.1.2.0/";
Standard_root="/home/shared/standards/"

sample="$2"
a=${RUN_ID:14:4}
Run_number=$(($a-10))

echo "$sample"" - RG""$Run_number"
mkdir "${Result_root}"
mkdir "${Result_root}""${sample}"

rm "${Result_root}""${sample}"/"${sample}"_input.list

for i in {1..4..1}
do
#	java -jar "${Picard_root}"picard.jar FastqToSam F1="${Clean_root}""${sample}"/"${sample}"_L00"${i}"_R1.filtered.trimmed.fastq.gz \
#	F2="${Clean_root}""${sample}"/"${sample}"_L00"${i}"_R2.filtered.trimmed.fastq.gz O="${Result_root}""${sample}"/"${sample}"_L00"${i}".unaligned.bam \
#	SM="${sample}" PL=ILLUMINA PU="$RUN_ID.${i}" LB=lib"$Run_number"

	#Align to reference genomes
#	bwa mem -M -Y -t 16 -K 10000000 "${Reference_root}"Homo_sapiens_assembly38.fasta "${Clean_root}""${sample}"/"${sample}"_L00"${i}"_R1.filtered.trimmed.fastq.gz "${Clean_root}""${sample}"/"${sample}"_L00"${i}"_R2.filtered.trimmed.fastq.gz > "${Result_root}""${sample}"/"${sample}"_L00"${i}".sam
#	samtools view "${Result_root}""${sample}"/"${sample}"_L00"${i}".sam -1 -o "${Result_root}""${sample}"/"${sample}"_L00"${i}".aligned.bam

	#Merge original uBam and aligned BAM
	java -jar "${Picard_root}"picard.jar MergeBamAlignment \
		EXPECTED_ORIENTATIONS=FR \
		ATTRIBUTES_TO_RETAIN=X0 \
                ALIGNED_BAM="${Result_root}""${sample}"/"${sample}"_L00"${i}".aligned.bam \
                UNMAPPED_BAM="${Result_root}""${sample}"/"${sample}"_L00"${i}".unaligned.bam \
                O="${Result_root}""${sample}"/"${sample}"_L00"${i}".bam \
                REFERENCE_SEQUENCE="${Reference_root}"Homo_sapiens_assembly38.fasta SORT_ORDER="unsorted" \
                IS_BISULFITE_SEQUENCE=false \
                ALIGNED_READS_ONLY=false \
                CLIP_ADAPTERS=false \
                ADD_MATE_CIGAR=true \
                MAX_INSERTIONS_OR_DELETIONS=-1 \
                PRIMARY_ALIGNMENT_STRATEGY=MostDistant \
                UNMAPPED_READ_STRATEGY=COPY_TO_TAG \
                ALIGNER_PROPER_PAIR_FLAGS=true \
                UNMAP_CONTAMINANT_READS=true

	echo "${Result_root}""${sample}"/"${sample}"_L00"${i}".bam >> "${Result_root}""${sample}"/"${sample}"_input.list	
done

params=$(cat "${Result_root}""${sample}"/"${sample}"_input.list | while read bam; do printf " I=$bam "; done);

cmd="java -Xmx10g -jar "${Picard_root}"picard.jar MarkDuplicates "$params" O="${Result_root}""${sample}"/"${sample}".md.bam \
      METRICS_FILE=${sample}.MD.metrics \
      VALIDATION_STRINGENCY=SILENT \
      OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 \
      ASSUME_SORT_ORDER="queryname" \
      CREATE_MD5_FILE=false"

$cmd


#Sort BAM file
java -jar "${Picard_root}"picard.jar SortSam I="${Result_root}""${sample}"/"${sample}".md.bam O="${Result_root}""${sample}"/"${sample}".sorted.md.bam SO=coordinate CREATE_INDEX=false CREATE_MD5_FILE=false 

java -jar "${Picard_root}"picard.jar SetNmMdAndUqTags \
      I="${Result_root}""${sample}"/"${sample}".sorted.md.bam \
      O="${Result_root}""${sample}"/"${sample}".tagged.sorted.md.bam \
      CREATE_INDEX=true \
      R="${Reference_root}"Homo_sapiens_assembly38.fasta


#Recalibrate base quality score (run BQSR)
#Analyze patterns of covariation
"${GATK_root}"gatk BaseRecalibrator -R "${Reference_root}"Homo_sapiens_assembly38.fasta --use-original-qualities -I "${Result_root}""${sample}"/"${sample}".tagged.sorted.md.bam \
--known-sites "${Standard_root}"Mills_and_1000G_gold_standard.indels.hg38.vcf.gz --known-sites "${Standard_root}"Homo_sapiens_assembly38.dbsnp138.vcf \
--known-sites "${Standard_root}"1000G_phase1.snps.high_confidence.hg38.vcf.gz -O "${Result_root}""${sample}"/"${sample}"_recal_data.table

#Apply recalibration
"${GATK_root}"gatk ApplyBQSR -R "${Reference_root}"Homo_sapiens_assembly38.fasta -I "${Result_root}""${sample}"/"${sample}".tagged.sorted.md.bam -bqsr "${Result_root}""${sample}"/"${sample}"_recal_data.table -O "${Result_root}""${sample}"/"${sample}".bqsr.sorted.md.bam \
  --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30 \
    --add-output-sam-program-record \
    --create-output-bam-md5 \
    --use-original-qualities

#[optional] - second recalibration table and analyze Covariates and plot
"${GATK_root}"gatk BaseRecalibrator -R "${Reference_root}"Homo_sapiens_assembly38.fasta -I "${Result_root}""${sample}"/"${sample}".bqsr.sorted.md.bam --known-sites "${Standard_root}"Homo_sapiens_assembly38.dbsnp138.vcf \
--known-sites "${Standard_root}"Mills_and_1000G_gold_standard.indels.hg38.vcf.gz -O "${Result_root}""${sample}"/"${sample}"_recal_data2.table --use-original-qualities \
--known-sites "${Standard_root}"Homo_sapiens_assembly38.dbsnp138.vcf --known-sites "${Standard_root}"1000G_phase1.snps.high_confidence.hg38.vcf.gz

"${GATK_root}"gatk AnalyzeCovariates -before "${Result_root}""${sample}"/"${sample}"_recal_data.table -after "${Result_root}""${sample}"/"${sample}"_recal_data2.table -csv  "${Result_root}""${sample}"/"${sample}"_BQSR.csv -plots "${Result_root}""${sample}"/"${sample}"_plots.pdf

#Convert BAM to GVCF 

"${GATK_root}"gatk HaplotypeCaller -ERC GVCF -R "${Reference_root}"Homo_sapiens_assembly38.fasta -I "${Result_root}""${sample}"/"${sample}".bqsr.sorted.md.bam -O "${Result_root}""${sample}"/"${sample}".gvcf.gz
"${GATK_root}"gatk GenotypeGVCFs -R "${Reference_root}"Homo_sapiens_assembly38.fasta -V "${Result_root}""${sample}"/"${sample}".gvcf.gz -O "${Result_root}""${sample}"/"${sample}".vcf.gz
