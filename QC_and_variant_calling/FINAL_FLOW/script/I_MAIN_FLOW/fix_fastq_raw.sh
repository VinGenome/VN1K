Run_ID="$1"
Run_folder="/dragennfs/area4/analysis/""${Run_ID}/"
SampleSheet=$(find "${Run_folder}" -type f -name "DGV4VN*")

awk -F',' '{ if ($1 ~ /^VN/) print $1"\t"$2 }' "$SampleSheet">"$Run_folder"fastq_raw/rename_SN.list

while read new_name old_name
do
	find "$Run_folder"fastq_raw/DGV4VN/$new_name -type f -name "$old_name*" | while read FILE ; do
    		newfile="$(echo ${FILE} |sed -e "s/$old_name/$new_name/2")" ;
    		mv "${FILE}" "${newfile}" ;
	done
	
#	echo "$old_name"*.gz
#	rename -v 's/$old_name/$new_name' "$old_name"*.gz
done<"$Run_folder"fastq_raw/rename_SN.list

mv "$Run_folder"fastq_raw/DGV4VN/*/*.gz "$Run_folder"fastq_raw/
