RUN_ID="$1"
sample=$2

RUN_folder="/dragennfs/area4/analysis/""${RUN_ID}/"
QC_folder="${RUN_folder}""qc/"
Result="$(pwd)""/Result"

echo "Sample "${sample}
bp1=$(head -n18 ${RUN_folder}Log/${sample}"_2_clean_fastq.sh_error.log" | tail -n 12 | awk '{
		if (match($1,"total")==1 && match($2, "reads:")==1){
			read += $3
		}
		if (match($1,"total")==1 && match($2, "bases:")==1){
			base += $3
		}
	}
	END {printf("%15.f\n", base)}
	')

bp2=$(head -n140 ${RUN_folder}Log/${sample}"_2_clean_fastq.sh_error.log" | tail -n 12 | awk '{
		if (match($1,"total")==1 && match($2, "reads:")==1){
			read += $3
		}
		if (match($1,"total")==1 && match($2, "bases:")==1){
			base += $3
		}
	}
	END {printf("%15.f\n", base)}
	')
bp3=$(head -n262 ${RUN_folder}Log/${sample}"_2_clean_fastq.sh_error.log" | tail -n 12 | awk '{
		if (match($1,"total")==1 && match($2, "reads:")==1){
			read += $3
		}
		if (match($1,"total")==1 && match($2, "bases:")==1){
			base += $3
		}
	}
	END {printf("%15.f\n", base)}
	')
bp4=$(head -n384 ${RUN_folder}Log/${sample}"_2_clean_fastq.sh_error.log" | tail -n 12 | awk '{
		if (match($1,"total")==1 && match($2, "reads:")==1){
			read += $3
		}
		if (match($1,"total")==1 && match($2, "bases:")==1){
			base += $3
		}
	}
	END {printf("%15.f\n", base)}
	')

# bp1=$(head -n12 ${RUN_folder}fastq_clean/clean_lanes/${sample}"_clean_lanes.sh_error.log" | tail -n 12 | awk '{
# 		if (match($1,"total")==1 && match($2, "reads:")==1){
# 			read += $3
# 		}
# 		if (match($1,"total")==1 && match($2, "bases:")==1){
# 			base += $3
# 		}
# 	}
# 	END {printf("%15.f\n", base)}
# 	')

# bp2=$(head -n128 ${RUN_folder}fastq_clean/clean_lanes/${sample}"_clean_lanes.sh_error.log" | tail -n 12 | awk '{
# 		if (match($1,"total")==1 && match($2, "reads:")==1){
# 			read += $3
# 		}
# 		if (match($1,"total")==1 && match($2, "bases:")==1){
# 			base += $3
# 		}
# 	}
# 	END {printf("%15.f\n", base)}
# 	')
# bp3=$(head -n244 ${RUN_folder}fastq_clean/clean_lanes/${sample}"_clean_lanes.sh_error.log" | tail -n 12 | awk '{
# 		if (match($1,"total")==1 && match($2, "reads:")==1){
# 			read += $3
# 		}
# 		if (match($1,"total")==1 && match($2, "bases:")==1){
# 			base += $3
# 		}
# 	}
# 	END {printf("%15.f\n", base)}
# 	')
# bp4=$(head -n360 ${RUN_folder}fastq_clean/clean_lanes/${sample}"_clean_lanes.sh_error.log" | tail -n 12 | awk '{
# 		if (match($1,"total")==1 && match($2, "reads:")==1){
# 			read += $3
# 		}
# 		if (match($1,"total")==1 && match($2, "bases:")==1){
# 			base += $3
# 		}
# 	}
# 	END {printf("%15.f\n", base)}
# 	')

# echo $bp1 $bp2 $bp3 $bp4
bp=$((bp1 + bp2 + bp3 + bp4))
echo $bp >>"${Result}"/"${RUN_ID}"_bp.txt
