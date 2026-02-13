RUN_ID="$1"
listcsv="$2"

Result=$(pwd)"/Result"
RUN_folder="/dragennfs/area4/analysis/""${RUN_ID}/"
vars=($(awk -F= '{print $listcsv}' "$listcsv"))

i=1
for sample in "${vars[@]}"; do
	echo "Process sample: "$sample
	q20=0
	q30=0
	total=0
	echo $sample >>$Result"/$RUN_ID"_qc_after.txt
	q20=$(head -n $((i * 11)) $Result"/$RUN_ID"_after.txt | tail -n11 | awk '$1 == "Q20" {sum += $2} END {print sum}')
	q30=$(head -n $((i * 11)) $Result"/$RUN_ID"_after.txt | tail -n11 | awk '$1 == "Q30" {sum += $2} END {print sum}')
	total=$(head -n $((i * 11)) $Result"/$RUN_ID"_after.txt | tail -n6 | awk '$1 == "Total" {print 2*$3}')

	gc=$(head -n $((i * 11)) $Result"/$RUN_ID"_after.txt | tail -n11 | awk '$1 == "GC" {print $3}')
	# gc2=$(head -n $((i*11+6)) $Result"/$RUN_ID"_cafter.txt|head -n5 |awk '$1 == "GC" {print $3}')

	p20=$(bc -l <<<$q20/$total)
	p30=$(bc -l <<<$q30/$total)

	echo "q20 0"${p20:0:8} >>$Result"/$RUN_ID"_qc_after.txt
	echo "q30 0"${p30:0:8} >>$Result"/$RUN_ID"_qc_after.txt
	echo "total sequence "$total >>$Result"/$RUN_ID"_qc_after.txt
	echo "gc content "$gc >>$Result"/$RUN_ID"_qc_after.txt
	echo "" >>$Result"/$RUN_ID"_qc_after.txt
	i=$((i + 1))

	echo "0"${p20:0:8} >>$Result"/$RUN_ID"_q20_after.txt
	echo "0"${p30:0:8} >>$Result"/$RUN_ID"_q30_after.txt
	echo $total >>$Result"/$RUN_ID"_reads_after.txt
	echo $gc >>$Result"/$RUN_ID"_gc_after.txt

	echo "q20 0"${p20:0:8} >>$Result"/$RUN_ID"_qc_after.txt
	echo "q30 0"${p30:0:8} >>$Result"/$RUN_ID"_qc_after.txt
	echo "total sequence "$total >>$Result"/$RUN_ID"_qc_after.txt
	echo "gc content "$gc >>$Result"/$RUN_ID"_qc_after.txt
	echo "" >>$Result"/$RUN_ID"_qc_after.txt
done
