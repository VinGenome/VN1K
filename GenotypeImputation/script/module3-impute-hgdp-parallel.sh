############## APMRA96
bash script/module3-impute-hgdp.sh Input/APMRA96.chr20.vcf.gz \
    Reference_Final/merge-1KGP3-vn916.chr20_forprephase.vcf.gz \
    Reference_Final/merge-1KGP3-vn916.chr20_forimpute.m3vcf.gz
    
############## HGDP
# bash script/module3-impute-hgdp.sh Input/HGDP.b38_aligned.chr20.vcf.gz \
#     Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.vcf.gz \
#     Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.m3vcf.gz
# bash script/module3-impute-hgdp.sh Input/HGDP.b38_aligned.chr20.vcf.gz \
#     Reference_Final/VN_916.HaplotypeData.chr20.QC.vcf.gz \
#     Reference_Final/VN_916.HaplotypeData.chr20.QC.m3vcf.gz &
# bash script/module3-impute-hgdp.sh Input/HGDP.b38_aligned.chr20.vcf.gz \
#     Reference_Final/SG10K.chr20.hg38_QC2.QC.vcf.gz \
#     Reference_Final/SG10K.chr20.hg38_QC2.QC.m3vcf.gz &
# bash script/module3-impute-hgdp.sh Input/HGDP.b38_aligned.chr20.vcf.gz \
#     Reference_Final/merge-SG10K-vn916.chr20_forprephase.vcf.gz \
#     Reference_Final/merge-SG10K-vn916.chr20_forimpute.m3vcf.gz &
# bash script/module3-impute-hgdp.sh Input/HGDP.b38_aligned.chr20.vcf.gz \
#     Reference_Final/merge-1KGP3-vn916.chr20_forprephase.vcf.gz \
#     Reference_Final/merge-1KGP3-vn916.chr20_forimpute.m3vcf.gz

# ############# KHV
# bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
#     Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.RemoveKHV.vcf.gz \
#     Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.RemoveKHV.m3vcf.gz &
# bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
#     Reference_Final/VN_916.HaplotypeData.chr20.QC.vcf.gz \
#     Reference_Final/VN_916.HaplotypeData.chr20.QC.m3vcf.gz &
# bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
#     Reference_Final/SG10K.chr20.hg38_QC2.QC.vcf.gz \
#     Reference_Final/SG10K.chr20.hg38_QC2.QC.m3vcf.gz &
# bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
#     Reference_Final/merge-SG10K-vn916.chr20_forprephase.vcf.gz \
#     Reference_Final/merge-SG10K-vn916.chr20_forimpute.m3vcf.gz &
# bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
#     Reference_Final/merge-1KGP3-vn916.chr20_forprephase.removeKHV.vcf.gz \
#     Reference_Final/merge-1KGP3-vn916.chr20_forprephase.removeKHV.m3vcf.gz
bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
    Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.RemoveKHV.vcf.gz \
    Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.RemoveKHV.m3vcf.gz &
bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
    Reference_Final/merge-1KGP3-vn916.chr20_forprephase.removeKHV.vcf.gz \
    Reference_Final/merge-1KGP3-vn916.chr20_forprephase.removeKHV.m3vcf.gz
bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
    /mnt/nas_share/namnn12/impute_data/ref/Ref_VN1008_v1/VN_1008.chr20.all.vcf.gz \
    /mnt/nas_share/namnn12/impute_data/ref/Ref_VN1008_v1/VN_1008.chr20.all.m3vcf.gz
bash script/module3-impute-hgdp.sh Input/KHV.chip.omni_broad_sanger_combined.20140818.snps.genotypes.20.addchr.hg38.vcf.gz \
    /mnt/nas_share/namnn12/impute_data/ref/Ref_VN1008_v01/vn1008.chr20.vcf.gz \
    /mnt/nas_share/namnn12/impute_data/ref/Ref_VN1008_v01/vn1008.chr20.m3vcf.gz


############## GSA24
bash script/module3-impute-hgdp.sh Input/GSAv3_24.rename.normalized.QC.vcf.gz \
    Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.vcf.gz \
    Reference_Final/CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.Total.QC.m3vcf.gz
bash script/module3-impute-hgdp.sh Input/GSAv3_24.rename.normalized.QC.vcf.gz \
    Reference_Final/VN_916.HaplotypeData.chr20.QC.vcf.gz \
    Reference_Final/VN_916.HaplotypeData.chr20.QC.m3vcf.gz &
bash script/module3-impute-hgdp.sh Input/GSAv3_24.rename.normalized.QC.vcf.gz \
    Reference_Final/SG10K.chr20.hg38_QC2.QC.vcf.gz \
    Reference_Final/SG10K.chr20.hg38_QC2.QC.m3vcf.gz &
bash script/module3-impute-hgdp.sh Input/GSAv3_24.rename.normalized.QC.vcf.gz \
    Reference_Final/merge-SG10K-vn916.chr20_forprephase.vcf.gz \
    Reference_Final/merge-SG10K-vn916.chr20_forimpute.m3vcf.gz &
bash script/module3-impute-hgdp.sh Input/GSAv3_24.rename.normalized.QC.vcf.gz \
    Reference_Final/merge-1KGP3-vn916.chr20_forprephase.vcf.gz \
    Reference_Final/merge-1KGP3-vn916.chr20_forimpute.m3vcf.gz