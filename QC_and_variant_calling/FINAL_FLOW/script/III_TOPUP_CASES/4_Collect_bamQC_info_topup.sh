RUN_ID="$1"

Run_folder="/dragennfs/area4/analysis/"$RUN_ID

list_topup=""
if [ $# -eq 1 ]; then
	list_topup="$Run_folder"/list_topup.csv
	echo "Use default list.csv"
else
	list_topup="$2"
	echo "Use list "$2
fi

while read sample first first_run second second_run; do
	# Sample_root=$second_run"/pipelines/Dragen_v07.011.350.3.3.11/topup_samples/""$sample/"
	Sample_root=$second_run"/pipelines/Dragen_v3.6.3/topup_samples/""$sample/"

	metrics="$Sample_root""$sample"_wgs_metrics.txt
	first=$(head -8 $metrics | tail -1 | sed -e 's/\t/ /g' | cut -d" " -f1-14)
	second=$(head -8 $metrics | tail -1 | sed -e 's/\t/ /g' | cut -d" " -f15-29)
	cal4x=$(head -n15 $metrics | tail -n4 | awk '$1 < 4 {sum += $2} END {print (1-(sum/3043453562))}')

	# mapping="$Sample_root""$sample".mapping_metrics.csv
	# sex=$(head -n49 $mapping | tail -1 | awk -F',' '{print $4}')
	cnv_metric="$Sample_root""$sample".cnv_metrics.csv
	sex=$(head -n1 $cnv_metric | cut -d ',' -f 4)
	echo $first" "$cal4x" "$second" "$sex | sed -e 's/ /\t/g'
done <"$list_topup"
