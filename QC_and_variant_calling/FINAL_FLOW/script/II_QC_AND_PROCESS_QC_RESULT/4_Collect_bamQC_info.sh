Run_folder="/dragennfs/area4/analysis/""$1"/

if [ $# -eq 1 ]; then
	readarray -t myarr <"$Run_folder"list.csv
	echo "Use default list.csv"
else
	readarray -t myarr <"$3"
	echo "Use list "$3
fi

for sample in "${myarr[@]}"; do
	# Sample_root=$Run_folder"pipelines/Dragen_v07.011.350.3.3.11/""$sample/"
	Sample_root=$Run_folder"pipelines/Dragen_v3.6.3/""$sample/"

	metrics="$Sample_root""$sample"_wgs_metrics.txt
	first=$(head -8 $metrics | tail -1 | tr -s " " " " | sed -e 's/\t/ /g' | sed -e 's/\n/ /g' | cut -d" " -f1-14)
	second=$(head -8 $metrics | tail -1 | tr -s " " " " | sed -e 's/\t/ /g' | sed -e 's/\n/ /g' | cut -d" " -f15-29)
	cal4x=$(head -n15 $metrics | tail -n4 | awk '$1 < 4 {sum += $2} END {print (1-(sum/3043453562))}')

	# mapping="$Sample_root""$sample".mapping_metrics.csv
	# sex=$(head -n1 $mapping | tail -1 | awk -F',' '{print $4}')
	cnv_metric="$Sample_root""$sample".cnv_metrics.csv
	sex=$(head -n1 $cnv_metric | cut -d ',' -f 4)
	echo $first" "$cal4x" "$second" "$sex | sed -e 's/ /\t/g'
done
