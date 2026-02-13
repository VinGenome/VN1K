Run_folder="$1"
sample="$2"

Result_root="$Run_folder""pipelines/Dragen_v3.6.3/";
RUN_ID="$(echo $Run_folder | cut -d'/' -f5)"

echo $(dragen --version)
echo "Sample "$sample
echo "RG" $RUN_ID

mkdir "${Result_root}""${sample}"/

samtools view -b -h -f 0x2 "${Result_root}"pipelines/Dragen_v07.011.350.3.3.11/"${sample}"/"${sample}".bam -o "${Result_root}""${sample}"/"${sample}".ProperPair.bam -@ 10
samtools view -b -h -F 0x2 "${Result_root}"pipelines/Dragen_v07.011.350.3.3.11/"${sample}"/"${sample}".bam -o "${Result_root}""${sample}"/"${sample}".ImProperPair.bam -@ 10

samtools view "${Result_root}""${sample}"/"${sample}".ImProperPair.bam |  awk '{ if ( $3 ~ /^$7/ || $7 ~ /^=/  ) print $0; }' >"${Result_root}""${sample}"/"${sample}".SameChr.ImproperPair.sam

samtools merge -f -c "${Result_root}""${sample}"/"${sample}".mergeImproperSameChr_ProperPair.bam "${Result_root}""${sample}"/"${sample}".ProperPair.bam  "${Result_root}""${sample}"/"${sample}".SameChr.ImproperPair.bam	

samtools index "${Result_root}""${sample}"/"${sample}".mergeImproperSameChr_ProperPair.bam
