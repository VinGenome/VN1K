RUNDIR=/dragennfs/area15/nam/KVG_gwas_clinical/run1

### plot mahattan
OUTDIR=$RUNDIR/mahattan
mkdir -p $OUTDIR
for trait in Acid_Uric ALT AST BC Creatinine Glucose HbA1c HDL-C LDL-C Total_Cholesterol Triglyceride Ure
do
Rscript src/plot_mahattan_server.R $RUNDIR $trait $OUTDIR
done