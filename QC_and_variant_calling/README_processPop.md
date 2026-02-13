# GATK Variant Calling and VQSR Filtering (processPop.sh)

## Overview

This script processes GVCF files from the GATK Human_par pipeline (or GATK GenomicsDBImport combined calls), applies variant quality score recalibration (VQSR) to SNPs and INDELs separately, and generates final high-confidence cohort VCF files.

## Methodology

Following SNP and INDEL calling with the GATK Human_par pipeline on the reference genome GRCh38 p7, the VN1K project applies VQSR filtering:

1. **Quality Score Recalibration (VQSR)**: Two-pass filtering for improved sensitivity and specificity:
   - **INDEL recalibration**: First pass applies VQSR to INDELs
     - Uses Mills and 1000G gold standard INDEL training set
     - Trains on variants with high confidence scores
     - Applies quality metrics: QD, SOR, DP, FS, MQRankSum, ReadPosRankSum
     - Maximum 4 Gaussian components
     - 99.0% truth sensitivity level

   - **SNP recalibration**: Second pass applies VQSR to SNPs
     - Uses multiple training sets: HapMap, Omni, 1000G phase 1, dbSNP
     - Combines INDEL-recalibrated variants with SNP training data
     - Applies quality metrics: QD, SOR, DP, FS, MQRankSum, ReadPosRankSum
     - Maximum 6 Gaussian components (richer model for SNPs)
     - 99.0% truth sensitivity level

2. **Filtering and Selection**: Retains only passing variants:
   - Filters for PASS status and missing data handling
   - Generates final PASS-only cohort VCF

3. **Variant Normalization**: Standardizes variant representation:
   - Decomposes complex variants into primitives (vt decompose)
   - Normalizes using reference genome (vt normalize)
   - Removes duplicate variants (vt uniq)
   - Generates final normalized VCF

4. **QC Metrics**: Compares pre- and post-filtering statistics:
   - BCFtools stats on raw joint genotyped VCF
   - BCFtools stats on VQSR-recalibrated VCF
   - BCFtools stats on normalized VCF

## Input Requirements

- **Joint genotyped VCF**: Output from GATK GenomicsDBImport combining all sample GVCFs
  - File format: `*.gatk.joint_genotype.vcf.gz`
  - Must be gzipped and indexed
- **Reference genome**: GRCh38 p7 (FASTA format with index)
- **Resource/training files**:
  - Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
  - Homo_sapiens_assembly38.dbsnp138.vcf.gz
  - hapmap_3.3.hg38.vcf.gz
  - 1000G_omni2.5.hg38.vcf.gz
  - 1000G_phase1.snps.high_confidence.hg38.vcf.gz

## Processing Steps

1. **INDEL VQSR First Pass**:
   - Input: Raw joint genotyped VCF
   - Training: Mills and 1000G gold standard + dbSNP
   - Output: INDEL-recalibrated VCF + recalibration files
   - Artifacts: Recalibration plots and tranches

2. **SNP VQSR Second Pass**:
   - Input: INDEL-recalibrated VCF
   - Training: HapMap + Omni + 1000G phase 1 + dbSNP
   - Output: SNP+INDEL-recalibrated VCF + recalibration files
   - Artifacts: SNP recalibration plots and tranches

3. **Filtering**:
   - Applies VQSR passing filter (tranche 99.0)
   - Selects PASS and missing data sites
   - Output: High-confidence PASS-only VCF

4. **Normalization**:
   - Decomposes and normalizes variants
   - Removes duplicates
   - Final output: `*.norm.vqsr.vcf.gz`

## Output Files

- **INDEL recalibrated**: `testPop_1016.gatk.recalibrated_INDEL.vcf.gz`
  - Intermediate: After first VQSR pass

- **SNP+INDEL recalibrated**: `testPop_1016.gatk.recalibrated_variants.vcf.gz`
  - Intermediate: After second VQSR pass (all variants)

- **VQSR filtered**: `testPop_1016.gatk.vqsr.vcf.gz`
  - Filtered: PASS-only variants

- **Normalized final**: `testPop_1016.gatk.norm.vqsr.vcf.gz`
  - Final: Normalized, deduplicated, high-confidence variants

- **Recalibration files**:
  - `*.recalibrate_INDEL_rawSNP.recal` - INDEL recalibration model
  - `*.recalibrate_INDEL.tranches` - INDEL filter tranches
  - `*.recalibrate_SNP.recal` - SNP recalibration model
  - `*.recalibrate_SNP.tranches` - SNP filter tranches

- **QC statistics**:
  - `*.joint_genotype.bcftools_stats.txt` - Pre-filtering stats
  - `*.vqsr.bcftools_stats.txt` - Post-VQSR stats
  - `*.norm.vqsr.bcftools_stats.txt` - Post-normalization stats

## VQSR Parameters

### INDEL Filtering
- **Training set sensitivity**: 99.0%
- **Gaussian components**: 4 (max)
- **Annotations used**: QD, SOR, DP, FS, MQRankSum, ReadPosRankSum
- **Training data**: Mills (prior=12.0), dbSNP (prior=2.0)

### SNP Filtering
- **Training set sensitivity**: 99.0%
- **Gaussian components**: 6 (max)
- **Annotations used**: QD, SOR, DP, FS, MQRankSum, ReadPosRankSum
- **Training data**: HapMap (prior=15.0), Omni (prior=12.0), 1000G (prior=10.0), dbSNP (prior=2.0)

## Usage

```bash
bash processPop.sh
```

Configure paths in script:
```bash
GATK_folder="/path/to/gatk/output/"
VQSR_folder="/path/to/vqsr/output/"
Ref_folder="/path/to/GRCh38/p7/reference.fasta"
Resource_root="/path/to/resource/databases/"
GATK_root="/path/to/gatk/4.1.8.1/"
```

## Related Files

- **Input**: Output from GATK GenomicsDBImport (in FINAL_FLOW/script/I_MAIN_FLOW)
- **Uses resources**: Tool requires GATK installation and reference databases
- **Output used by**: consensus_pop.sh for multi-pipeline consensus calling
- **Final integration**: postProcessConsensus.sh for population-level refinement

## QC Interpretation

Compare statistics across three output stages:
1. **Raw joint genotyped**: Total variants called
2. **VQSR filtered**: Variants passing recalibration model
3. **Normalized**: Final variants after deduplication and normalization

Track:
- Total variant count (should decrease through filtering)
- Transition/transversion (Ts/Tv) ratio (should be ~2.0 for high quality)
- SNP vs INDEL count
- Missing data rate

## Best Practices

1. **VQSR sensitivity**: 99.0% allows small number of true variants to be filtered
2. **Training data**: Use high-confidence, well-characterized reference datasets
3. **Multiple passes**: Separate INDEL and SNP filtering improves accuracy
4. **Normalization**: Ensures consistent representation across pipelines
5. **QC tracking**: Monitor statistics at each stage for quality assurance

## References

- GATK VQSR: https://gatk.broadinstitute.org/hc/en-us/articles/360037499012-VariantRecalibrator
- GATK Best Practices: https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-
- Mills and 1000G gold standard: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3671529/
- HapMap: https://www.ncbi.nlm.nih.gov/snp/
- 1000 Genomes Project: http://www.1000genomes.org/
- Variant annotations: https://gatk.broadinstitute.org/hc/en-us/articles/360035891011-Allele-specific-annotation
