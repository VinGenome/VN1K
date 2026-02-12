# GWAS Clinical Analysis Pipeline

Genome-wide association study (GWAS) pipeline for analyzing clinical traits in the Vietnamese Genome Project (VGP).

## Overview

This pipeline performs association analysis between genetic variants and 12 clinical traits (liver enzymes, glucose metabolism, lipid profiles, kidney markers) in 811 Vietnamese samples.

**Analyzed traits:**
- Liver function: ALT, AST
- Glucose metabolism: Glucose, HbA1c
- Lipid profile: HDL-C, LDL-C, Total_Cholesterol, Triglyceride
- Kidney function: Creatinine, Ure, Acid_Uric
- Blood chemistry: BC

## Pipeline Workflow

```
Input VCF → Quality Control → GWAS Analysis → LD Clumping → Visualization
```

### 1. Quality Control (`src/QC.sh`)

Filters variants and samples for analysis quality:
- Extract 811 clinical samples from consensus VCF
- Filter variants: MAF > 0.01, missing rate < 0.01

```bash
bash src/QC.sh
```

**Output:** `data/KVG.811clinical.qc_var.vcf.gz`

### 2. GWAS Analysis (`src/gwas.sh`)

Complete association analysis workflow:

1. **Convert VCF to PLINK format** with phenotype data
2. **LD pruning** for PCA (50kb window, step 5, r² < 0.2)
3. **Calculate 10 principal components** from pruned variants
4. **Merge covariates**: 10 PCs + sex + year of birth + height + weight
5. **Run linear regression** (PLINK2 GLM) for all traits
6. **Extract genome-wide significant variants** (p < 5.86e-9, Bonferroni corrected)

```bash
bash src/gwas.sh
```

**Key parameters:**
- Genome-wide significance: p < 5.86e-9
- Covariates: 10 PCs + 4 demographic/anthropometric variables
- Model: Linear regression with covariate variance standardization

**Outputs:**
- `$RUNDIR/clinical_prune.*.glm.linear` - Full association results per trait
- `$RUNDIR/clinical_prune.*.glm.linear.corrected` - Genome-wide significant variants only

### 3. LD Clumping (`src/clump.sh`)

Identifies independent association signals by clumping correlated variants:

```bash
bash src/clump.sh
```

**Clumping parameters:**
- Index SNP p-value threshold: p₁ = 1e-7
- Clumping window: 1000kb
- LD threshold: r² = 0.1

**Outputs:** `$RUNDIR/clinical.clump.*.clumped` (one file per trait)

### 4. Visualization (`src/run_Rplot_mahattan.sh`)

Generates Manhattan plots for all traits:

```bash
bash src/run_Rplot_mahattan.sh
```

**Plot single trait:**
```bash
Rscript src/plot_mahattan_server.R <RUNDIR> <trait_name> <output_directory>
```

**Outputs:** `$RUNDIR/mahattan/*.pdf`

## Requirements

### Software
- **PLINK 1.9**: Basic operations and clumping
- **PLINK2**: GLM analysis with multiple phenotypes
- **bcftools**: VCF operations
- **R** (≥ 3.6) with packages:
  - tidyverse
  - qqman
  - ggplot2
  - ggrepel

### Input Data

1. **VCF file**: `data/consensus23.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz`
   - Quality-controlled Vietnamese genome variants

2. **Phenotype file**: `data/clinical_pheno.0131.txt`
   - Tab-separated format
   - 811 samples × 31 traits
   - Columns: FID, IID, Sex, YoB, Height, Weight, Age, [clinical measurements]

3. **Sample list**: `list_811_clinical_samples.txt`
   - Sample IDs for subsetting VCF

## Configuration

**Important:** Update `RUNDIR` variable in all scripts before running:

```bash
# In src/gwas.sh, src/clump.sh, src/run_Rplot_mahattan.sh
RUNDIR=/path/to/your/output/directory
```

This directory will store all intermediate files and results.

## Output Structure

```
$RUNDIR/
├── KVG.811clinical.qc_var.*          # PLINK binary files
├── KVG.811clinical.qc_var.eigenvec   # PCA results
├── pca_covar.txt                     # Merged covariates file
├── clinical_prune.*.glm.linear       # Full GWAS results per trait
├── clinical_prune.*.glm.linear.corrected  # Significant variants only
├── clinical.clump.*                  # Clumped results per trait
└── mahattan/*.pdf                    # Manhattan plots
```

## Usage Example

```bash
# 1. Quality control
bash src/QC.sh

# 2. Run GWAS (update RUNDIR first!)
bash src/gwas.sh

# 3. LD clumping
bash src/clump.sh

# 4. Generate Manhattan plots
bash src/run_Rplot_mahattan.sh
```

## Statistical Methods

- **Association test**: Linear regression
- **Covariate adjustment**: Population structure (10 PCs) + demographic/anthropometric variables
- **Multiple testing correction**: Bonferroni (α = 0.05 / 8.5M variants ≈ 5.86e-9)
- **LD clumping**: Index SNP approach to identify independent signals

## Notes

- Pipeline designed for Vietnamese population data with specific QC parameters
- Requires significant computational resources (RAM for handling VCF with millions of variants)
- Absolute paths in scripts may need adjustment for different computing environments
- Manhattan plot generation filters variants with -log10(P) > 1 for visualization performance

## License

Vietnamese Genome Project (VGP)

## Contact

For questions about the pipeline or data, contact the VGP team.
