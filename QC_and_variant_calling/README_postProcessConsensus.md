# Post-processing of Consensus Calls (postProcessConsensus.sh)

## Overview

This script performs comprehensive post-processing and quality refinement on consensus variant calls across three independent variant calling pipelines. It applies population-level filters, integrates annotation data, performs sample-level QC, and generates final high-confidence cohort VCF files.

## Methodology

Following the consensus variant calling across GATK Human_par, Illumina Dragen, and Google DeepVariant pipelines, post-processing includes:

1. **Sample Filtering**: Removes samples failing quality thresholds:
   - Filters based on Hardy-Weinberg Equilibrium (HWE) test results
   - Removes samples with missing genotype rates exceeding thresholds
   - Excludes samples inconsistent with population genetics assumptions

2. **Variant-Level QC**: Applies rigorous variant quality filters:
   - HardyWeinberg Equilibrium filtering (p > 1e-6 typical threshold)
   - Missingness filtering (removes variants with >threshold% missing calls)
   - KHV (Kinh Vietnamese from 1000 Genomes) consistency checking
   - Hardy-Weinberg equilibrium assessment within subpopulations

3. **Annotation Integration**: Adds missing information:
   - Fills missing variant IDs using rsID mapping
   - Adds population allele frequency annotations
   - Integrates gnomAD reference data
   - Tags variants for downstream analysis

4. **Database Cross-reference**: Compares against external databases:
   - IGSR HC (International Genome Sample Resource high-confidence calls)
   - KHV HC (East Asian reference panel)
   - gnomAD (Genome Aggregation Database) for allele frequencies

5. **Final Filtering**: Creates analysis-ready VCF files:
   - Removes non-reference alleles or keeps multiallelic sites
   - Generates sites-only VCF for imputation reference panels
   - Applies final tag filling (MAF, AC, AN, etc.)

## Input Requirements

- **Consensus VCF files**: Output from consensus_pop.sh
  - GATK cohort VCF (normalized, VQSR-filtered)
  - Dragen cohort VCF (normalized, hard-filtered)
  - DeepVariant cohort VCF (normalized, GLNexus combined)
- **Reference databases**:
  - IGSR HC VCF files (population reference)
  - KHV HC VCF files (East Asian reference)
  - gnomAD database files
- **Sample metadata**: List of excluded/included samples

## Processing Steps

1. **Prepare input directories**: Organize VCF files from each pipeline
2. **Apply HWE filtering**: Remove variants violating Hardy-Weinberg equilibrium
3. **Sample-level filtering**: Remove problematic samples using provided lists
4. **Add missing IDs**: Integrate rsID assignments for known variants
5. **Normalize representation**: Ensure consistent variant representation across files
6. **Fill annotation tags**: Add population statistics and reference information
7. **Apply final filters**: Multi-allelic site handling, remove non-ref alleles
8. **Create output variants**: Generate final cohort VCF and sites-only reference VCF
9. **Index outputs**: Compress and index all final VCF files

## Output Files

- **Consensus VCF**: `consensus23.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz`
  - Final high-confidence population cohort VCF
  - All samples, multi-allelic sites with rsIDs added
- **Sites-only VCF**: `consensus23.sitesOnly.passKHV.passHWE.addMissingID.rsID.norm.filltags.multi.rmNonRef.vcf.gz`
  - Variant sites without genotypes (for reference panels)
- **QC summary**: Statistics on filtering steps applied
- **Removed samples list**: IDs of samples failing QC thresholds

## Key Parameters

- **HWE p-value threshold**: < 1e-6 (or adjustable)
- **Missing data threshold**: < 5% (or adjustable per variant)
- **KHV consistency**: Variants present in East Asian reference panel
- **MAF reporting**: Calculated across cohort
- **Fill tags**: MAF, AC, AN, F_MISSING

## Usage

```bash
bash postProcessConsensus.sh
```

Configure paths in script:
```bash
Dragen_folder="/path/to/dragen/vcf/"
GATK_folder="/path/to/gatk/vcf/"
DV_folder="/path/to/deepvariant/vcf/"
Out_dir="/path/to/output/vcf.gz"
Ref_folder="/path/to/reference/genome.fasta"
IGSR_HC="/path/to/igsr/reference.vcf.gz"
KHV_HC="/path/to/khv/reference/"
```

## Related Files

- **Input**: Output from consensus_pop.sh
- **Input database**: IGSR, KHV, gnomAD reference files
- **Output used by**: makeImputationREF.sh (for imputation panels)
- **Output used by**: GenotypeImputation/ workflows
- **Output used by**: gwas_clinical/ analyses

## Quality Assurance

The script ensures:
1. Population genetic consistency (HWE assumptions)
2. Reference panel concordance (KHV matching)
3. Annotation completeness (rsID assignment)
4. Sample identity verification (included sample verification)
5. Data integrity (compression, indexing)

## References

- Hardy-Weinberg Equilibrium: https://en.wikipedia.org/wiki/Hardy%E2%80%93Weinberg_principle
- IGSR: https://www.internationalgenome.org/
- KHV Population: 1000 Genomes Project East Asian population
- gnomAD: https://gnomad.broadinstitute.org/
- BCFtools: https://samtools.github.io/bcftools/bcftools.html
