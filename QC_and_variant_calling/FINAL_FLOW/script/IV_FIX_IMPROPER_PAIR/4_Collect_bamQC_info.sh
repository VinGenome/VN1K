while read Run_folder sample
do
	Result_root="$Run_folder""pipelines/Dragen_v3.6.3/""$sample/"

	metrics="${Result_root}""${sample}".mergeImproperSameChr_ProperPair_wgs_metrics.txt
	first=$(head -8 $metrics | tail -1 | sed -e 's/\t/ /g' | cut -d" " -f1-14)
	second=$(head -8 $metrics | tail -1 | sed -e 's/\t/ /g' | cut -d" " -f15-29)
	cal4x=$(head -n15 $metrics | tail -n4 |awk '$1 < 4 {sum += $2} END {print (1-(sum/3043453562))}')

	mapping="${Result_root}""${sample}".mergeImproperSameChr_ProperPair.mapping_metrics.csv
	sex=$(head -n49 $mapping | tail -1 | awk -F',' '{print $4}')
	echo $first" "$cal4x" "$second" "$sex | sed -e 's/ /\t/g'
 
    awk -v sampleName=$sample '{ if ($1 ~ /^PAIR/) { print sampleName,"\t",$0 } }' "${Result_root}""${sample}"_mergeImproperSameChr_ProperPair_alignment_metrics.txt>>alignment_"$Run_folder".txt
done<<"$1"
