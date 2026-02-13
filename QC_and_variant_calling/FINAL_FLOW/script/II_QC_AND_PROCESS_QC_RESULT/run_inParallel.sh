current_folder="$(pwd)"

Run_ID="$2"
Run_folder="/dragennfs/area4/analysis/""${Run_ID}/"

if [ $# -eq 2 ]
then
        readarray -t myarr <"$Run_folder"list.csv
        echo "Use default list.csv"
else
        readarray -t myarr <"$3"
        echo "Use list "$3
fi

for sample in "${myarr[@]}"
do
	echo "Run $1 on Sample "${sample}
	time bash "$current_folder"/"$1" "${Run_folder}" "${sample}" > "${Run_folder}""Log/""${sample}"_"$1".log 2>"${Run_folder}""Log/""${sample}"_"$1"_error.log &
done
