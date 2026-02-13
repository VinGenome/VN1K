# Population Consensus Calling (consensus_pop.sh)

## Overview

This script identifies consensus variants across three independent variant calling pipelines (GATK Human_par, Illumina Dragen, and Google DeepVariant) on SNPs and INDELs separately. This multi-pipeline consensus approach reduces false positives and increases confidence in variant calls for population-level analysis.

## Methodology

To assure uniformity and reduce technical artifacts from any single calling pipeline, the VN1K project employed variant consensus calling as described:

1. **Pipeline Separation**: Separates SNPs and INDELs from each pipeline's output:
   - GATK GenomicsDBImport combined GVCF files
   - Illumina Dragen cohort VCF files
   - Google DeepVariant + GLNexus combined GVCF files

2. **Variant Type Splitting**: Uses `bcftools view` to separately process:
   - SNPs (single nucleotide polymorphisms)
   - INDELs (insertions and deletions)

3. **Intersection Analysis**: Identifies variants called by multiple pipelines using `bcftools isec`:
   - Variants present in 2+ pipelines (higher confidence)
   - Variants unique to each pipeline
   - Separates SNP and INDEL consensus calls

4. **Quality Filtering**: Only variants passing initial pipeline-specific filters are included:
   - GATK: VQSR-filtered variants
   - Dragen: Hard-filtered variants
   - DeepVariant: Default filter applied

## Input Requirements

- **GATK VCF**: Normalized, VQSR-filtered joint-genotyped VCF from GATK GenomicsDBImport
- **Dragen VCF**: Normalized, hard-filtered joint genotyped VCF from Dragen Genotyper
- **DeepVariant VCF**: Normalized, filtered VCF from GLNexus with tag filling

All input files should be:
- Gzip compressed (.vcf.gz)
- Indexed with tabix
- Normalized with consistent variant representation

## Output Files

- **SNP consensus**: Separated consensus SNP calls for each pipeline
  - Format: `[common_name].{gatk|dragen|dv}.SNP.norm.*.vcf.gz`
- **INDEL consensus**: Separated consensus INDEL calls for each pipeline
  - Format: `[common_name].{gatk|dragen|dv}.INDEL.norm.*.vcf.gz`
- **Intersection results**: Multi-way intersections in dedicated directories
  - SNP intersection: `SNP/cmp/`
  - INDEL intersection: `INDEL/cmp/`

## Key Parameters

- **isec option**: `-n +2` - variants present in 2 or more samples
- **isec option**: `-c none` - use variant coordinates for comparison
- **Separation**: Chromosomal coordinate-based variant splitting

## Usage

```bash
bash consensus_pop.sh
```

Configure the script paths:
```bash
Dragen_folder="/path/to/dragen/output/"
DV_folder="/path/to/deepvariant/glnexus/output/"
GATK_folder="/path/to/gatk/genotyper/output/"
Out_dir="/path/to/consensus/output/"
```

## Related Files

- **Input source 1**: GATK pipeline output (processPop.sh for GATK processing)
- **Input source 2**: Dragen pipeline output (module3-impute.sh in FINAL_FLOW)
- **Input source 3**: DeepVariant output (processDV_glnexus.sh)
- **Next step**: Variant merging and final post-processing (postProcessConsensus.sh)

## Benefits of Consensus Calling

1. **Increased confidence**: Variants called by multiple independent pipelines are more likely to be true positives
2. **Reduced false positives**: Technical artifacts that appear in only one pipeline are excluded
3. **Pipeline comparison**: Ability to assess performance and agreement across different calling methods
4. **Quality metrics**: Provides detailed intersection statistics for quality assessment

## References

- GATK GenomicsDBImport: https://gatk.broadinstitute.org/hc/en-us/articles/360035535652-GenomicsDBImport
- Illumina Dragen: https://www.illumina.com/products/by-type/informatics-products/dragen-bio-it-platform.html
- Google DeepVariant: https://github.com/google/deepvariant
- GLNexus: https://github.com/dnanexus/GLnexus
- bcftools: https://samtools.github.io/bcftools/bcftools.html
