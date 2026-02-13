#Root directories
sample=$2
Run_folder=$1
Sample_root="${Run_folder}fastq_raw/"
Clean_lane_root="${Run_folder}fastq_clean/clean_lanes/${sample}/"
Clean_combines=${Run_folder}"fastq_clean/clean_combines/${sample}/"
un
mkdir "${Clean_lane_root}"

split_S=$(ls "${Sample_root}""${sample}"_S*_L001_R1_001.fastq.gz | awk -F "/" '{print $7}' | cut -d'_' -f 7)
s=${split_S:1}

for i in {1..4}; do
    # Clean data
            fastp -i "${Sample_root}""${sample}"_S"${s}"_L00"${i}"_R1_001.fastq.gz \
                -I "${Sample_root}""${sample}"_S"${s}"_L00"${i}"_R2_001.fastq.gz \
                -o "${Clean_lane_root}""${sample}"_L00"${i}"_R1_p.trimmed.fastq.gz \
                -O "${Clean_lane_root}""${sample}"_L00"${i}"_R2_p.trimmed.fastq.gz \
                --adapter_fasta /dragennfs/area7/testPolyG_atHead/adapter.fasta \
                --detect_adapter_for_pe -L -Q -w 20 -g -b 150 -B 150 \
                -h "${Clean_lane_root}""${sample}"_adaptertrimmed_cut151_polyG.fastp.html \
                -j "${Clean_lane_root}""${sample}"_adaptertrimmed_cut151_polyG.fastp.json \
                -R "${Clean_lane_root}${sample}_adaptertrimmed_cut151_polyG_fastp.report"

        #filter by fastp
        fastp --in1 "${Clean_lane_root}""${sample}"_L00"${i}"_R1_p.trimmed.fastq.gz \
                --in2 "${Clean_lane_root}""${sample}"_L00"${i}"_R2_p.trimmed.fastq.gz \
                --out1 "${Clean_lane_root}""${sample}"_L00"${i}"_R1.filtered1.trimmed.fastq.gz \
                --out2 "${Clean_lane_root}""${sample}"_L00"${i}"_R2.filtered1.trimmed.fastq.gz \
                -q 31 -u 49 -L -n 15 -A -w 10 -h "${Clean_lane_root}""${sample}"_L00"${i}"_filtered1.fastp.html -j "${Clean_lane_root}""${sample}"_L00"${i}"_filtered1.fastp.json

        # End clean data

        fastp --in1 "${Clean_lane_root}""${sample}"_L00"${i}"_R1.filtered1.trimmed.fastq.gz \
                --in2 "${Clean_lane_root}""${sample}"_L00"${i}"_R2.filtered1.trimmed.fastq.gz \
                --out1 "${Clean_lane_root}""${sample}"_L00"${i}"_R1.filtered2.trimmed.fastq.gz \
                --out2 "${Clean_lane_root}""${sample}"_L00"${i}"_R2.filtered2.trimmed.fastq.gz \
                -q 3 -u 9 -L -n 15 -A -w 10 \
                -h "${Clean_lane_root}""${sample}"_filtered2.fastp.html \
                -j "${Clean_lane_root}""${sample}"_filtered2.fastp.json \
                -R "${Clean_lane_root_root}${sample}_filtered2_fastp.report"

        fastp --in1 "${Clean_lane_root}""${sample}"_L00"${i}"_R1.filtered2.trimmed.fastq.gz \
                --in2 "${Clean_lane_root}""${sample}"_L00"${i}"_R2.filtered2.trimmed.fastq.gz \
                --out1 "${Clean_lane_root}""${sample}"_L00"${i}"_R1.filtered.trimmed.fastq.gz \
                --out2 "${Clean_lane_root}""${sample}"_L00"${i}"_R2.filtered.trimmed.fastq.gz \
                -e 31 -L -A -w 10 \
                -h "${Clean_lane_root}""${sample}"_filtered.fastp.html \
                -j "${Clean_lane_root}""${sample}"_filtered.fastp.json \
                -R "${Clean_lane_root_root}${sample}_filtered_fastp.report"
        done
done

ls "${Clean_lane_root}"$sample*"R1.filtered.trimmed.fastq.gz" >"$Clean_lane_root""${sample}"R1
ls "${Clean_lane_root}"$sample*"R2.filtered.trimmed.fastq.gz" >"$Clean_lane_root""${sample}"R2

mkdir $Clean_combines

echo $(grep -v '^#' ${Clean_lane_root}${sample}"R1")
cat $(grep -v '^#' ${Clean_lane_root}${sample}"R1") > ${Clean_combines}${sample}"_R1.filtered.trimmed.fastq.gz"

echo $(grep -v '^#' ${Clean_lane_root}${sample}"R2")
cat $(grep -v '^#' ${Clean_lane_root}${sample}"R2") > ${Clean_combines}${sample}"_R2.filtered.trimmed.fastq.gz"

rm "${Clean_lane_root}""$sample"R1
rm "${Clean_lane_root}""$sample"R2
