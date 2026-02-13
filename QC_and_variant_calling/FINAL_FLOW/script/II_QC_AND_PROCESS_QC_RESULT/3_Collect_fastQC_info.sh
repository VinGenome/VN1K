pwd=$(pwd)
Result=$pwd"/Result"
mkdir $Result

RUN_ID="$1"
Run_folder="/dragennfs/area4/analysis/"$RUN_ID/

echo $RUN_ID
echo $Run_folder

if [ $# -eq 1 ]; then
        readarray -t myarr <"$Run_folder"list.csv
        echo "Use default list.csv"
        # Collect Q20, Q30, GC, Reads
        bash qc_fastq/Collect_fastqc.sh $RUN_ID "$Run_folder"list.csv

else
        readarray -t myarr <"$2"
        echo "Use list "$2

        # Collect Q20, Q30, GC, Reads
        bash qc_fastq/Collect_fastqc.sh $RUN_ID "$3"

fi

for sample in "${myarr[@]}"; do
        # Collect raw fastq size

        echo $sample
        bash qc_fastq/size.sh $RUN_ID $sample raw

        # Collect clean fastq size
        bash qc_fastq/size.sh $RUN_ID $sample clean

        # Collect base pairs
        bash qc_fastq/collect_bp.sh $RUN_ID $sample
done
