pwd="$(pwd)"

RUN_ID="$1"
sample="$2"
TYPE="$3"

Result=$(pwd)"/Result"
RUN_folder="/dragennfs/area4/analysis/""${RUN_ID}/"


if [[ $TYPE = "raw" ]]
then
    echo "Calulate fastq size of "$TYPE" "$sample
    total_size=0
    for i in {1..4}
    do
        fastq1="$RUN_folder"fastq_raw/"$sample"_S*_L00"$i"_R1_001.fastq.gz  #input 1
        fastq2="$RUN_folder"fastq_raw/"$sample"_S*_L00"$i"_R2_001.fastq.gz  #input 2
        s1=$(du -s $fastq1 | cut -d$'\t' -f 1)
        s2=$(du -s $fastq2 | cut -d$'\t' -f 1)
        total_size=$((total_size+s1+s2))
    done
    echo $total_size >> $Result"/"$RUN_ID"_raw_size.txt"
    
elif [[ $TYPE = "clean" ]]
then 
    echo "Calulate fastq size of "$TYPE" "$sample
    fastq1="$RUN_folder"fastq_clean/clean_combines/"$sample"/"$sample"_R1.filtered.trimmed.fastq.gz  #input 1
    fastq2="$RUN_folder"fastq_clean/clean_combines/"$sample"/"$sample"_R2.filtered.trimmed.fastq.gz  #input echo "File 1: "$fastq1
    s1=$(du -s $fastq1 | cut -d$'\t' -f 1)
    s2=$(du -s $fastq2 | cut -d$'\t' -f 1)
    let total_size=(s1+s2)
    
    #total_size=$(bc -l <<< $total_size/1000000)
    #echo ${total_size:0:8}
    echo $total_size >> $Result"/"$RUN_ID"_clean_size.txt"
else
    echo "TYPE wrong. clean or raw only."
fi