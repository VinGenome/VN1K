RUNDIR=/dragennfs/area15/nam/KVG_gwas_clinical/run_0131
mkdir -p $RUNDIR
# convert to plink
plink --allow-extra-chr \
  --allow-no-sex \
  --double-id \
  --make-bed \
  --all-pheno \
  --vcf-half-call haploid \
  --pheno data/clinical_pheno.0131.txt \
  --update-sex data/clinical_pheno.0131.txt 1 \
  --vcf data/KVG.811clinical.qc_var.vcf.gz \
  --out $RUNDIR/KVG.811clinical.qc_var \
  --output-chr chrM
  # --pheno-name ALT \

### calculate PCA and create cov file
#prune variants
plink --bfile $RUNDIR/KVG.811clinical.qc_var \
  --indep-pairwise 50 5 0.2 \
  --out $RUNDIR/KVG.811clinical.qc_var
#   --geno 0.01 \
#   --maf 0.01 \

#calculate pca
plink --bfile $RUNDIR/KVG.811clinical.qc_var \
  --extract $RUNDIR/KVG.811clinical.qc_var.prune.in \
  --pca 10 'header' 'tabs' \
  --out $RUNDIR/KVG.811clinical.qc_var

# create covariate file
cut -f3,5,6,7 data/clinical_pheno.0131.txt > $RUNDIR/covar.txt
paste $RUNDIR/KVG.811clinical.qc_var.eigenvec $RUNDIR/covar.txt > $RUNDIR/pca_covar.txt

# ### perform association
# plink --bfile $RUNDIR/KVG.811clinical.qc_var \
#   --covar $RUNDIR/pca_covar.txt \
#   --linear \
#   --ci 0.95 \
#   --out $RUNDIR/ALT
#   # --hide-covar \

### try to run all pheno
plink2 --allow-extra-chr \
  --double-id \
  --vcf-half-call haploid \
  --pheno data/clinical_pheno.0131.txt \
  --pheno-name ALT-Creatinin \
  --update-sex data/clinical_pheno.0131.txt \
  --vcf data/KVG.811clinical.qc_var.vcf.gz \
  --covar $RUNDIR/pca_covar.txt \
  --covar-variance-standardize \
  --glm hide-covar \
  --ci 0.95 \
  --out $RUNDIR/clinical_prune
  # --extract $RUNDIR/KVG.811clinical.qc_var.prune.in \

### statistic 
head -n 1 $RUNDIR/clinical_prune.ALT.glm.linear > $RUNDIR/clinical_prune.glm.linear.header
for file in $RUNDIR/clinical_prune*.glm.linear; do awk '($14<5.86e-9) {print}' $file > ${file/linear/linear.corrected}; done
for file in $RUNDIR/*linear.corrected; do wc -l $file; done
for file in $RUNDIR/*linear.corrected;
do
cat $RUNDIR/clinical_prune.assoc.linear.header $file > $file.add_head
done