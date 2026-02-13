Run_folder="$1"

Clean_root="$Run_folder""fastq_clean/clean_lanes/"
Bwa_mem_root="$Run_folder""pipelines/Bwa_mem/"
Result_root="$Run_folder""pipelines/Parabricks/GATK_v4.0/"

sample="$2"
RUN_ID="$(echo $Run_folder | cut -d'/' -f5)"

a=${RUN_ID:14:4}
Run_number=$(($a - 10))
SampleName=${sample:1:13}

echo "$sample"" - RG""$Run_number"
mkdir "${Result_root}""${sample}"
mkdir "${Bwa_mem_root}""${sample}"

rg1="@RG\tID:RG"${Run_number}"_"${sample}_1"\tLB:lib1\tPL:ILLUMINA\tSM:"${SampleName}"\tPU:"${sample}"_rg1"
rg2="@RG\tID:RG"${Run_number}"_"${sample}_2"\tLB:lib1\tPL:ILLUMINA\tSM:"${SampleName}"\tPU:"${sample}"_rg2"
rg3="@RG\tID:RG"${Run_number}"_"${sample}_3"\tLB:lib1\tPL:ILLUMINA\tSM:"${SampleName}"\tPU:"${sample}"_rg3"
rg4="@RG\tID:RG"${Run_number}"_"${sample}_4"\tLB:lib1\tPL:ILLUMINA\tSM:"${SampleName}"\tPU:"${sample}"_rg4"


if [[ ! -f "${Result_root}""${sample}"/"${sample}".gvcf.gz ]] 
then
    pbrun germline --ref /home/shared/references/Homo_sapiens_assembly38.fasta \
    --in-fq "${Clean_root}""${sample}"/"${sample}"_L001_R1.filtered.trimmed.fastq.gz \
    "${Clean_root}""${sample}"/"${sample}"_L001_R2.filtered.trimmed.fastq.gz "${rg1}" \
    --in-fq "${Clean_root}""${sample}"/"${sample}"_L002_R1.filtered.trimmed.fastq.gz \
    "${Clean_root}""${sample}"/"${sample}"_L002_R2.filtered.trimmed.fastq.gz "${rg2}" \
    --in-fq "${Clean_root}""${sample}"/"${sample}"_L003_R1.filtered.trimmed.fastq.gz \
    "${Clean_root}""${sample}"/"${sample}"_L003_R2.filtered.trimmed.fastq.gz "${rg3}" \
    --in-fq "${Clean_root}""${sample}"/"${sample}"_L004_R1.filtered.trimmed.fastq.gz \
    "${Clean_root}""${sample}"/"${sample}"_L004_R2.filtered.trimmed.fastq.gz "${rg4}" \
    --knownSites /home/shared/standards/dbsnp151.with_chr.vcf.gz \
    --out-bam "${Bwa_mem_root}""${sample}"/"${sample}".bam \
    --out-variants "${Result_root}""${sample}"/"${sample}".gvcf \
    --out-recal-file "${Result_root}""${sample}"/"${sample}"_report.txt --gvcf
else
    echo "File ""${Result_root}""${sample}"/"${sample}"".gvcf.gz existed"
fi

if [[ ! -f "${Result_root}""${sample}"/"${sample}".vcf  ]]
then 
    echo "Decompress file ""${Result_root}""${sample}"/"${sample}"".gvcf.gz"
    bgzip -d "${Result_root}""${sample}"/"${sample}".gvcf.gz
    pbrun genotypegvcf --ref /home/shared/references/Homo_sapiens_assembly38.fasta --in-gvcf "${Result_root}""${sample}"/"${sample}".gvcf --out-vcf "${Result_root}""${sample}"/"${sample}".vcf
else
    echo "File ""${Result_root}""${sample}"/"${sample}"".vcf existed" 
fi

[[ ! -f "${Result_root}""${sample}"/"${sample}".gvcf.gz  ]] && bgzip "${Result_root}""${sample}"/"${sample}".gvcf
[[ ! -f "${Result_root}""${sample}"/"${sample}".gvcf.gz.tbi  ]] && tabix -p vcf "${Result_root}""${sample}"/"${sample}".gvcf.gz
