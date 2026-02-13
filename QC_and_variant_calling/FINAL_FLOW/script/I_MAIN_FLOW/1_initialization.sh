Run_ID="$1"
Run_folder="/dragennfs/area4/analysis/""${Run_ID}/"

RawFastq_folder="${Run_folder}""fastq_raw/"
CleanLanes_folder="${Run_folder}""fastq_clean/clean_lanes/"
CleanCombine_folder="${Run_folder}""fastq_clean/clean_combines/"
QC_folder="${Run_folder}""qc/"

#pipeline folder
# Dragen_folder="${Run_folder}""pipelines/Dragen_v07.011.350.3.3.11/"
Dragen_folder="${Run_folder}""pipelines/Dragen_v3.6.3/"
Bwa_folder="${Run_folder}""pipelines/Bwa_mem/"
GATK_folder="${Run_folder}""pipelines/Parabricks/GATK_v4.0/"
DeepVariant_folder="${Run_folder}""pipelines/Parabricks/DeepVariant/"

[[ ! -f "${Run_folder}" ]] && mkdir "${Run_folder}"
[[ ! -f "${Run_folder}""Log" ]] && mkdir "${Run_folder}""Log"
[[ ! -f "${Run_folder}""fastq_clean/" ]] && mkdir "${Run_folder}""fastq_clean/"
[[ ! -f "${CleanLanes_folder}" ]] && mkdir "${CleanLanes_folder}"
[[ ! -f "${CleanCombine_folder}" ]] && mkdir "${CleanCombine_folder}"
[[ ! -f "${QC_folder}" ]] && mkdir "${QC_folder}"

[[ ! -f "${Run_folder}""pipelines/" ]] && mkdir "${Run_folder}""pipelines/"
[[ ! -f "${Run_folder}""pipelines/Parabricks/" ]] && mkdir "${Run_folder}""pipelines/Parabricks/"

[[ ! -f "${Bwa_folder}" ]] && mkdir "${Bwa_folder}"
[[ ! -f "${Dragen_folder}" ]] && mkdir "${Dragen_folder}"
[[ ! -f "${GATK_folder}" ]] && mkdir "${GATK_folder}"
[[ ! -f "${DeepVariant_folder}" ]] && mkdir "${DeepVariant_folder}"

cp /dragennfs/vinmecdata/"${Run_ID}"/DGV4VN* "${Run_folder}"
touch "${Run_folder}"a.txt
SampleSheet=$(find "${Run_folder}" -type f -name "DGV4VN*")

#echo "${SampleSheet}"
awk -F',' -v OFS=, '{ if ($1 ~ /^VN/) $2=$1 }1' "${SampleSheet}" >"${Run_folder}"temp.txt
mv "${Run_folder}"temp.txt "${SampleSheet}"
rm "${Run_folder}"temp.txt
sed -i 's/Adapter,/AdapterRead1,/' "${SampleSheet}"
sed -i '/AdapterRead2,GGGGGGG/d' "${SampleSheet}"

cat "$SampleSheet" | awk '{ if ($0 ~ /^VN/) print $0}' >"${Run_folder}"a.txt
cat "${Run_folder}"a.txt | awk -F',' '{ if ($11 ~ /Topup/) print substr($1,1,13)}' >"${Run_folder}"list_topup.csv
cat "${Run_folder}"a.txt | awk -F',' '{ if ($11 !~ /Topup/) print $1}' >"${Run_folder}"list_new.csv
cat "${Run_folder}"a.txt | awk -F',' '{ print $1 }' >"${Run_folder}"list.csv

[ ! -s "${Run_folder}"list_topup.csv ] && rm "${Run_folder}"list_topup.csv
[ ! -s "${Run_folder}"list_new.csv ] && rm "${Run_folder}"list_new.csv
rm "${Run_folder}"a.txt

#IF BCL2FASTQ on DRAGEN SERVER
# dragen --bcl-conversion-only true --bcl-input-directory /dragennfs/vinmecdata/"${Run_ID}/" --output-directory "${RawFastq_folder}" --sample-sheet "${SampleSheet}" --combine-samples-by-name true --force

#IF BCL2FASTQ on HPC

bcl2fastq -R /dragennfs/vinmecdata/"${Run_ID}/" -o "${RawFastq_folder}" --sample-sheet "${SampleSheet}"
mv "${RawFastq_folder}"DGV4VN/*.fastq.gz "${RawFastq_folder}"
