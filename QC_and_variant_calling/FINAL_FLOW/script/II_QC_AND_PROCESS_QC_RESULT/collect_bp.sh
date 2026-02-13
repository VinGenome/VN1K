Run_folder="$1"

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

	echo "sample: $sample"

	[ ! -f "$Run_folder"Log/bp.txt ] && touch "$Run_folder"Log/bp.txt
	tail -n 3 "$Run_folder"Log/"$sample"_count_bp.sh.log | awk '$2 == "bp:" {print $3}' >> "$Run_folder"Log/bp.txt
done

cat "$Run_folder"Log/bp.txt
