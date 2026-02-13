current_folder="$(pwd)"
while read Run_folder sample
do
    echo "Run $1 on Sample "${sample}
    time bash "$current_folder"/"$1" "${Run_folder}" "${sample}" > "${Run_folder}""Log/""${sample}"_"$1".log 2>"${Run_folder}""Log/""${sample}"_"$1"_error.log &
done<<"$list_topup""
