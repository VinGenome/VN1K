Run_folder="$1"
sample="$2"

Result_root="$Run_folder""pipelines/Dragen_v3.6.3/";
RUN_ID="$(echo $Run_folder | cut -d'/' -f5)"

echo $(dragen --version)
echo "Sample "$sample
echo "RG" $RUN_ID

Sample_root="$Run_folder""fastq_clean/clean_combines/"

mkdir -p "${Result_root}""${sample}"/

dragen -f -r /staging/references --output-directory "${Result_root}""${sample}"/ --output-file-prefix "${sample}" -1 "${Sample_root}""${sample}"/"${sample}"_R1.filtered.trimmed.fastq.gz -2 "${Sample_root}""${sample}"/"${sample}"_R2.filtered.trimmed.fastq.gz --enable-map-align-output true --enable-bam-indexing true --enable-variant-caller true --RGID $RUN_ID  --RGSM "${sample}" --enable-duplicate-marking true --vc-emit-ref-confidence GVCF --enable-cnv true --cnv-enable-self-normalization true --enable-map-align true --ht-alt-aware-validate true

dragen -r /staging/references/ --enable-joint-genotyping true --output-file-prefix "${sample}" --output-directory "${Result_root}""${sample}"/ --variant "${Result_root}""${sample}"/"${sample}".hard-filtered.gvcf.gz


while read sample Run_folder
do
        echo $sample
        Clean_lanes="$Run_folder"clean_Q30/fastq_clean/clean_lanes/"${sample}/"
        Result_root="$Run_folder"clean_Q30/Dragen_v3.6.3/"${sample}/"
        mkdir -p "$Result_root"

        RUN_ID="$(echo $Run_folder | cut -d'/' -f5)"

        a="$(echo $RUN_ID | cut -d'_' -f3)"

        Run_number=$((10#$a - 10))
        SampleName=${sample:0:13}

        rm fq_list.csv
        touch fq_list.csv

        echo "RGID,RGSM,RGLB,Lane,Read1File,Read2File">>fq_list.csv
        echo "${Run_number}"_"${sample}"_1,"${SampleName}",lib"$Run_number",1,"${Clean_lanes}""${sample}"_L001_R1.filtered.trimmed.fastq.gz,"${Clean_lanes}""${sample}"_L001_R2.filtered.trimmed.fastq.gz>>fq_list.csv
        echo "${Run_number}"_"${sample}"_2,"${SampleName}",lib"$Run_number",2,"${Clean_lanes}""${sample}"_L002_R1.filtered.trimmed.fastq.gz,"${Clean_lanes}""${sample}"_L002_R2.filtered.trimmed.fastq.gz>>fq_list.csv
        echo "${Run_number}"_"${sample}"_3,"${SampleName}",lib"$Run_number",3,"${Clean_lanes}""${sample}"_L003_R1.filtered.trimmed.fastq.gz,"${Clean_lanes}""${sample}"_L003_R2.filtered.trimmed.fastq.gz>>fq_list.csv
        echo "${Run_number}"_"${sample}"_4,"${SampleName}",lib"$Run_number",4,"${Clean_lanes}""${sample}"_L004_R1.filtered.trimmed.fastq.gz,"${Clean_lanes}""${sample}"_L004_R2.filtered.trimmed.fastq.gz>>fq_list.csv

#       if [ ! -f "${Result_root}""${sample}".hard-filtered.gvcf.gz ]; then
                dragen -f -r /staging/references --output-directory "${Result_root}" --output-file-prefix "${sample}" --fastq-list fq_list.csv --fastq-list-sample-id "${SampleName}" --enable-map-align-output true --enable-bam-indexing true --enable-variant-caller true --enable-duplicate-marking true --enable-cnv true --cnv-enable-self-normalization true --enable-map-align true --ht-alt-aware-validate true --enable-sort true --vc-emit-ref-confidence GVCF --vc-enable-joint-detection true

                dragen -r /staging/references/ --enable-joint-genotyping true --output-file-prefix "${sample}" --output-directory "${Result_root}" --variant "${Result_root}""${sample}".hard-filtered.gvcf.gz
#       fi
#       nohup bash /dragennfs/area1/analysis/newClean/QC_Q30.sh $sample $Run_folder > /dragennfs/area7/testPolyG_atHead/Log/"${sample}".qc_log.txt 2>/dragennfs/area7/testPolyG_atHead/Log/"${sample}".qc_error_log.txt &
done<"$1"