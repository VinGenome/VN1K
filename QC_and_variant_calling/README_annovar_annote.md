# Variant Annotation (annovar_annote.sh)

## Overview

This script performs comprehensive variant annotation on VCF files using ANNOVAR, adding functional information and clinical significance data to variants identified during SNP and INDEL calling. Annotation includes gene information, population frequencies, protein impact predictions, and clinical database associations.

## Methodology

Following the VN1K data processing pipeline, variant annotation is the final step after variant calling and initial quality filtering:

1. **Variant Caller Integration**: Converts VCF files (output from SNP and INDEL calling pipelines - GATK, Illumina Dragen, or Google DeepVariant) to ANNOVAR input format
2. **Functional Annotation**: Annotates variants with:
   - Gene and transcript information (refGene)
   - Chromosomal band locations (cytoBand)
   - Population frequencies from ExAC v0.3
   - Known SNP identifiers (dbSNP v150)
   - Protein consequence predictions (dbnsfp v4.2c)
   - Clinical significance (ClinVar - regularly updated)

3. **Annotation Database Processing**: Integrates data from multiple reference databases:
   - RefGene: Gene coordinate annotations
   - CytoBand: Chromosomal cytogenetic band assignments
   - ExAC03: Exome Aggregation Consortium frequencies
   - dbSNP150: Known variant database
   - dbnsfp42c: Functional consequence and deleteriousness scores
   - ClinVar: Clinical interpretation and assertions

## Input Requirements

- **VCF files**: Output from SNP and INDEL calling pipelines (should be gzipped and indexed)
- **ANNOVAR installation**: Must have ANNOVAR binaries and humandb database configured
- **Reference databases**: Pre-downloaded ANNOVAR humandb directory with annotation databases

## Output Files

- **Annotated VCF**: VCF files with added annotation fields in INFO column
- **ANNOVAR input format**: Intermediate conversion files (.avinput)
- **Variant classification files**: Variants filtered by:
  - HGMD category (DP, DFP, FP, DM, DM?, R)
  - Allele count (AC=1, AC=2, AC=3, AC>3)
  - ClinVar significance (BENIGN, NOT_BENIGN)

## Key Parameters

- **Protocols used**: refGene, cytoBand, exac03, avsnp150, dbnsfp42c, clinvar_20220320
- **Operations**: 'g,r,f,f,f,f' (gene prediction, region, filter for each database)
- **NA string**: '.' for missing annotations
- **Polish option**: Enabled for improved variant representation

## Usage

```bash
bash annovar_annote.sh
```

Edit the script to specify:
- Input VCF file path and name
- Output directory path
- ANNOVAR installation path
- Path to humandb annotation databases

## Related Files

- **Input**: Output from SNP/INDEL calling (processPop.sh, processDV_glnexus.sh)
- **Next step**: Variant filtering and clinical interpretation based on annotations

## References

- ANNOVAR: http://annovar.openbioinformatics.org/
- RefGene: NCBI Reference Sequence Database
- ExAC: Exome Aggregation Consortium
- dbSNP: NCBI Single Nucleotide Polymorphism Database
- dbnsfp: Database for non-synonymous functional predictions
- ClinVar: NCBI Clinical Variation Database
