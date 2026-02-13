current_folder="$(pwd)"
Run_ID="$2"
Run_folder="/dragennfs/area4/analysis/""${Run_ID}/"

list_topup=""
if [ $# -eq 2 ]; then
        list_topup="$Run_folder"list_topup.csv
        echo "Use default list_topup.csv"
else
        list_topup="$3"
        echo "Use list "$3
fi

while read sample first first_run second second_run; do
        echo "Run $1 on Sample "${sample}
        bash "$current_folder"/"$1" "${sample}" "$first" "$first_run" "$second" "$second_run" >"${Run_folder}""Log/""${sample}"_"$1".log 2>"${Run_folder}""Log/""${sample}"_"$1"_error.log &
done <"$list_topup"
