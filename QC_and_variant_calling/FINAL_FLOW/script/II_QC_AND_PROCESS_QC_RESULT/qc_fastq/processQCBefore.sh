RUN_ID="$1"
listcsv="$2"

Result=$(pwd)"/Result"
RUN_folder="/dragennfs/area4/analysis/""${RUN_ID}/"
QC_folder="${RUN_folder}""qc/"

vars=($(awk -F= '{print $listcsv}' "$listcsv"))

i=1
for sample in "${vars[@]}"; do
	q20=0
	q30=0
	total=0
	echo $sample >>$Result"/$RUN_ID"_qc_before.txt
	q20=$(head -n $((i * 44)) $Result"/$RUN_ID"_before.txt | tail -n44 | awk '$1 == "Q20" {sum += $2} END {print sum}')
	q30=$(head -n $((i * 44)) $Result"/$RUN_ID"_before.txt | tail -n44 | awk '$1 == "Q30" {sum += $2} END {print sum}')
	total=$(head -n $((i * 44)) $Result"/$RUN_ID"_before.txt | tail -n44 | awk '$1 == "Total" {sum += $3} END {print sum}')

	gc=$(head -n $((i * 44)) $Result"/$RUN_ID"_before.txt | tail -n44 | awk '$1 == "GC" {print $3}')
	gc1=$(head -n $((i * 44)) $Result"/$RUN_ID"_before.txt | tail -n6 | awk '$1 == "GC" {print $3}')

	p20=$(bc -l <<<$q20/$total)
	p30=$(bc -l <<<$q30/$total)

	echo "0"${p20:0:8} >>$Result"/$RUN_ID"_q20_before.txt
	echo "0"${p30:0:8} >>$Result"/$RUN_ID"_q30_before.txt
	echo $total >>$Result"/$RUN_ID"_reads_before.txt
	echo $gc1 >>$Result"/$RUN_ID"_gc_before.txt

	echo "q20 0"${p20:0:8} >>$Result"/$RUN_ID"_qc_before.txt
	echo "q30 0"${p30:0:8} >>$Result"/$RUN_ID"_qc_before.txt
	echo "total sequence "$total >>$Result"/$RUN_ID"_qc_before.txt
	echo "gc content "$gc >>$Result"/$RUN_ID"_qc_before.txt
	echo "" >>$Result"/$RUN_ID"_qc_before.txt
	i=$((i + 1))
done
