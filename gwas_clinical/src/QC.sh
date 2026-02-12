# simple QC
bcftools view -S list_811_clinical_samples.txt data/consensus23.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz -Oz -o data/KVG.811clinical.vcf.gz # get samples have clinical label
bcftools index -t data/KVG.811clinical.vcf.gz
bcftools view -i 'INFO/MAF>0.01&F_MISSING<0.01' data/KVG.811clinical.vcf.gz -Oz -o data/KVG.811clinical.qc_var.vcf.gz # filter bad variants
bcftools index -t data/KVG.811clinical.qc_var.vcf.gz