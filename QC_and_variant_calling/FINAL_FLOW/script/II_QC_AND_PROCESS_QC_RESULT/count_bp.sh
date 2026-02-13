sample="$2"

Run_folder="$1"
echo "sample: $sample"

cd "$Run_folder"fastq_raw

totalbp=0
totalread=0
read=0
bp=0

for i in {1..4}
do
        fastq1="$sample"_S*_L00"$i"_R1_001.fastq.gz  #input 1
        fastq2="$sample"_S*_L00"$i"_R2_001.fastq.gz  #input 2

        echo "File 1: "$fastq1
        echo "File 2: "$fastq2

        \cp -f $fastq1 "$sample"_L"$i"_R1.fastq.gz
        \cp -f $fastq2 "$sample"_L"$i"_R2.fastq.gz

        dunzip "$sample"_L"$i"_R1.fastq.gz
        dunzip "$sample"_L"$i"_R2.fastq.gz

        bp1=$(cat "$sample"_L"$i"_R1.fastq | paste - - - - | cut -f 2 | wc -c)
        bp2=$(cat "$sample"_L"$i"_R2.fastq | paste - - - - | cut -f 2 | wc -c)

        r1=$(wc -l "$sample"_L"$i"_R1.fastq | awk '{print $1}')
        r2=$(wc -l "$sample"_L"$i"_R2.fastq | awk '{print $1}')

        read=$(((r1+r2)))
        read=$((read/4))
        bp=$((bp1+bp2-read))

        totalread=$((totalread+read))
        totalbp=$((totalbp+bp))

        rm "$sample"_L"$i"_R1.fastq
        rm "$sample"_L"$i"_R2.fastq
        rm "$sample"_L"$i"_R1.fastq.gz
        rm "$sample"_L"$i"_R2.fastq.gz
done

echo "total bp: "$totalbp
echo "total read:"$totalread
