#!/bin/bash
RUN_ID="$1"
listcsv="$2"

RUN_folder="/dragennfs/area4/analysis/""${RUN_ID}/"
QC_folder="${RUN_folder}""qc/"
Result=$(pwd)"/Result"

vars=($(awk -F= '{print $listcsv}' "$listcsv"))

touch $Result"/$RUN_ID"_after.txt
for sample in "${vars[@]}"
do
	echo $sample >> $Result"/$RUN_ID"_after.txt

	fastqc1="$QC_folder""$sample""/after/""$sample"_R1.filtered.trimmed_fastqc  #input 1
	fastqc2="$QC_folder""$sample""/after/""$sample"_R2.filtered.trimmed_fastqc  #input 2

	echo "File 1: "$fastqc1.zip >> $Result"/$RUN_ID"_after.txt
	

	unzip -p $fastqc1.zip "$sample"_R1.filtered.trimmed_fastqc/fastqc_data.txt > "$Result""/$RUN_ID"_R1.txt
	unzip -p $fastqc2.zip "$sample"_R2.filtered.trimmed_fastqc/fastqc_data.txt > "$Result""/$RUN_ID"_R2.txt

	tail -n300 "$Result""/$RUN_ID"_R1.txt |awk '{
		if (match($1,">>Per base sequence content")==1){
			print "Summary of GC content: "$2
		}
		if (match($1,">>Per sequence GC content")==1){
			print "Total Sequences: "$2
		}
	}' >> $Result"/$RUN_ID"_after.txt

	head -n12 "$Result""/$RUN_ID"_R1.txt |awk '{
		if (match($1,"%GC")==1){
			print "GC content: "$2
		}
		if (match($1,"Total")==1){
			print "Total Sequences: "$3
		}
	}' >>$Result"/$RUN_ID"_after.txt

	tail -n 347 "$Result""/$RUN_ID"_R1.txt | head -n 27 | awk '{
		echo $1
		if ($1>=20){
			cal_Q20 += $2
			if ($1>=30){
				cal_Q30 += $2
			}	
		}
		if ($1==37){
			print "Q20 "cal_Q20
			print "Q30 "cal_Q30
		}
	}' >>$Result"/$RUN_ID"_after.txt

	echo "File 2: "$fastqc2.zip >> $Result"/$RUN_ID"_after.txt

	head -n12 "$Result""/$RUN_ID"_R2.txt |awk '{
		if (match($1,"%GC")==1){
			print "GC content "$2
		}
		if (match($1,"Total")==1){
			print "Total Sequences "$3
		}
	}' >>$Result"/$RUN_ID"_after.txt
	tail -n 347 "$Result""/$RUN_ID"_R2.txt | head -n 27 | awk '{
		if ($1>=20){
			cal_Q20 += $2
			if ($1>=30){
				cal_Q30 += $2
			}	
		}
		if ($1==37){
			print "Q20 "cal_Q20
			print "Q30 "cal_Q30
		}
	}' >>$Result"/$RUN_ID"_after.txt

done

rm "$Result""/$RUN_ID"_R1.txt
rm "$Result""/$RUN_ID"_R2.txt
