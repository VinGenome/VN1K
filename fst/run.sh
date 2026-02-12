HGDP_path=/mnt/nas_share/vinhdc/1KVG_imputation_panel/HGDP/hgdp_wgs.chr20.vcf.gz
GSA_path=/mnt/nas_share/vinhdc/1KVG_imputation_panel/Reference_Tmp/VN_95.HaplotypeData.chr20.vcf.gz

bcftools isec -c none -p isec_VN95_HGDP $HGDP_path $GSA_path
bgzip isec/0002.vcf
bcftools index -t isec/0002.vcf.gz
bgzip isec/0003.vcf
bcftools index -t isec/0003.vcf.gz

bcftools merge isec/0002.vcf.gz isec/0003.vcf.gz -Oz -o merge_VN95_HGDP.vcf.gz

### vcftools
mkdir -p output_vcftools
for file in $(ls /mnt/nas_share/vinhdc/1KVG_imputation_panel/hgdp_list/)
do
    vcftools --gzvcf merge_VN95_HGDP.vcf.gz --weir-fst-pop /mnt/nas_share/vinhdc/1KVG_imputation_panel/Sample/GSAv3.sample_list.txt \
        --weir-fst-pop /mnt/nas_share/vinhdc/1KVG_imputation_panel/hgdp_list/$file \
        --out output_vcftools/GSA_${file/_sample.list/}
done

for log_path in $(ls output_vcftools/*.log)
do
    log_file=$(basename $log_path)
    set_name=${log_file/.log/}
    tail -n 4 $log_path | head -n 2 > ${log_path/.log/.fst_mean}
done



################# Additional part: check GSA vs KHV fst ################
KHV_path=/mnt/nas_share/vinhdc/1KVG_imputation_panel/Reference_Tmp/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.KHV.vcf.gz

bcftools isec -c none -p isec_VN95_KHV $KHV_path $GSA_path
bgzip isec_VN95_KHV/0002.vcf
bcftools index -t isec_VN95_KHV/0002.vcf.gz
bgzip isec_VN95_KHV/0003.vcf
bcftools index -t isec_VN95_KHV/0003.vcf.gz

bcftools merge isec_VN95_KHV/0002.vcf.gz isec_VN95_KHV/0003.vcf.gz -Oz -o merge_VN95_KHV.vcf.gz
vcftools --gzvcf merge_VN95_KHV.vcf.gz \
        --weir-fst-pop /mnt/nas_share/vinhdc/1KVG_imputation_panel/Sample/GSAv3.sample_list.txt \
        --weir-fst-pop /mnt/nas_share/vinhdc/1KVG_imputation_panel/Sample/Kinh_samples.txt \
        --out output_vcftools/GSA_KHV