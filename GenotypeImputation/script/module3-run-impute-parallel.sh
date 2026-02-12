bash script/module3-impute.sh Input/APMRA96.chr20.vcf.gz \
    Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.vcf.gz \
    Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.m3vcf.gz &
# bash script/module3-impute.sh Input/APMRA96.chr20.vcf.gz \
#     Reference_Final/VN_916.HaplotypeData.chr20.QC.vcf.gz \
#     Reference_Final/VN_916.HaplotypeData.chr20.QC.m3vcf.gz &
# bash script/module3-impute.sh Input/APMRA96.chr20.vcf.gz \
#     Reference_Final/SG10K.chr20.hg38_QC2.QC.vcf.gz \
#     Reference_Final/SG10K.chr20.hg38_QC2.QC.m3vcf.gz &
# bash script/module3-impute.sh Input/APMRA96.chr20.vcf.gz \
#     Reference_Final/merge-SG10K-vn916.chr20_forprephase.vcf.gz \
#     Reference_Final/merge-SG10K-vn916.chr20_forimpute.m3vcf.gz &
bash script/module3-impute.sh Input/APMRA96.chr20.vcf.gz \
    Reference_Final/merge-1KGP3-vn916.chr20_forprephase.vcf.gz \
    Reference_Final/merge-1KGP3-vn916.chr20_forimpute.m3vcf.gz