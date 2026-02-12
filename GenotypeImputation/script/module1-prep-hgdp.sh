bcftools view /dragennfs/area15/tien/PostProcess/0123/consensus23.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz -S list_sample_APMRA.txt -Oz -o consensus23.APMRA_sample.vcf.gz
bcftools index -t consensus23.APMRA_sample.vcf.gz
bcftools view -r chr20 consensus23.APMRA_sample.vcf.gz -Oz -o consensus23.APMRA_sample.chr20.vcf.gz
bcftools index -t consensus23.APMRA_sample.chr20.vcf.gz

# masked data
bcftools isec -c none consensus23.APMRA_sample.chr20.vcf.gz /dragennfs/area7/hung_dir/reference_data/HGDP/array-simulation/Japanese.chr20_QC2.vcf.gz -p isec_1KGV_HGDP_chr20_masked


# Genotyping simulate data
bcftools isec -c none consensus23.APMRA_sample.vcf.gz /dragennfs/area7/hung_dir/reference_data/HGDP/HGDP.b38_aligned.vcf.gz -p isec_1KGV_HGDP
bcftools view isec_1KGV_HGDP/0002.vcf -Oz -o isec_1KGV_HGDP/0002.vcf.gz
bcftools index -t isec_1KGV_HGDP/0002.vcf.gz
bcftools merge --missing-to-ref -m none -Oz -o HGDP-APMRA.genotype.vcf.gz isec_1KGV_HGDP/0002.vcf.gz /dragennfs/area7/hung_dir/reference_data/HGDP/HGDP.b38_aligned.vcf.gz
bcftools index -t HGDP-APMRA.genotype.vcf.gz
bcftools view -r chr20 HGDP-APMRA.genotype.vcf.gz -Oz -o HGDP-APMRA.chr20.genotype.vcf.gz
bcftools index -t HGDP-APMRA.chr20.genotype.vcf.gz
