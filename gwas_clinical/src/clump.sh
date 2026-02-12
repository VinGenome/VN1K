RUNDIR=/dragennfs/area15/nam/KVG_gwas_clinical/run_0131
mkdir -p $RUNDIR

### clump file
clump_list="$RUNDIR/clinical_prune.ALT.assoc.linear.corrected.add_head $RUNDIR/clinical_prune.AST.assoc.linear.corrected.add_head $RUNDIR/clinical_prune.Glucose.assoc.linear.corrected.add_head $RUNDIR/clinical_prune.HbA1c.assoc.linear.corrected.add_head $RUNDIR/clinical_prune.LDL-C.assoc.linear.corrected.add_head $RUNDIR/clinical_prune.Triglyceride.assoc.linear.corrected.add_head"

plink --allow-extra-chr \
  --allow-no-sex \
  --double-id \
  --vcf-half-call haploid \
  --vcf data/KVG.811clinical.qc_var.vcf.gz \
  --output-chr chrM \
  --clump $clump_list \
  --clump-p1 0.0000001 --clump-kb 1000 --clump-r2 0.1 \
  --out $RUNDIR/clinical_prune.all

### clump big files
clump_big_list="$RUNDIR/clinical_prune.Acid_Uric.assoc.linear $RUNDIR/clinical_prune.ALT.assoc.linear $RUNDIR/clinical_prune.AST.assoc.linear $RUNDIR/clinical_prune.BC.assoc.linear $RUNDIR/clinical_prune.Creatinine.assoc.linear $RUNDIR/clinical_prune.Glucose.assoc.linear $RUNDIR/clinical_prune.HbA1c.assoc.linear $RUNDIR/clinical_prune.HDL-C.assoc.linear $RUNDIR/clinical_prune.LDL-C.assoc.linear $RUNDIR/clinical_prune.Total_Cholesterol.assoc.linear $RUNDIR/clinical_prune.Triglyceride.assoc.linear $RUNDIR/clinical_prune.Ure.assoc.linear"

plink --allow-extra-chr \
  --update-sex data/clinical_pheno.0131.txt 1 \
  --double-id \
  --vcf-half-call haploid \
  --vcf data/KVG.811clinical.qc_var.vcf.gz \
  --output-chr chrM \
  --clump $RUNDIR/clinical_prune.*.glm.linear.plink19 \
  --clump-p1 0.0000001 --clump-kb 1000 --clump-r2 0.1 \
  --out $RUNDIR/clinical_prune.all_big

### clump each file separate
traits="Acid_Uric HbA1c ALT HDL-C AST LDL-C BC Total_Cholesterol Creatinine Triglyceride Glucose Ure"
for trait in $traits
do
plink --allow-extra-chr \
  --allow-no-sex \
  --double-id \
  --vcf-half-call haploid \
  --vcf data/KVG.811clinical.qc_var.vcf.gz \
  --output-chr chrM \
  --clump $RUNDIR/clinical_prune.$trait.assoc.linear \
  --clump-p1 0.0000001 --clump-kb 1000 --clump-r2 0.1 \
  --out $RUNDIR/clinical.clump.$trait
done