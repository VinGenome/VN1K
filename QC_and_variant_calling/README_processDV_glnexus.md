# DeepVariant Variant Calling with GLNexus (processDV_glnexus.sh)

## Overview

This script processes Google DeepVariant GVCF files using GLNexus for variant consolidation and generates chromosome-specific cohort VCF files. It includes variant annotation, normalization, filtering, and comprehensive quality control metrics across the genome.

## Methodology

Following SNP and INDEL calling with Google DeepVariant on clean fastq data, the VN1K project consolidates population-level calls using GLNexus:

1. **GVCF Consolidation**: Uses GLNexus to merge individual sample GVCF files:
   - Processes per-chromosome GVCF files from all samples
   - Applies DeepVariant-specific configuration (default hard filters)
   - Handles non-diploid sites and complex variants appropriately
   - Generates BCF output for efficient storage and processing

2. **Variant Normalization**: Normalizes variant representation:
   - Fills population statistics tags (MAF, AC, AN, DP)
   - Decomposes complex variants into simpler forms
   - Normalizes using reference genome (GRCh38 p7)
   - Removes redundant variants (vt uniq)

3. **Sample Filtering**: Applies population-level sample QC:
   - Removes samples listed in exclusion file (list_exclude1.csv)
   - Removes samples with problematic quality indicators

4. **Variant Site Filtering**: Applies stringent site-level filters:
   - Keeps only biallelic sites (-m 2 -M 2)
   - Removes multiallelic variants for final output
   - Maintains annotation field information

5. **Quality Control**: Generates comprehensive QC metrics:
   - Missing site rates (--missing-site)
   - Missing individual genotype rates (--missing-indv)
   - Individual variant burden (--indv-freq-burden)
   - Singleton variant detection (--singletons)
   - Site quality score distributions (--site-quality)

## Input Requirements

- **Individual GVCF files**: Output from DeepVariant variant calling on sample BAM files
  - Location: `/dragennfs/area4/Population/DV_gvcf/*.dv.gvcf.gz`
  - One GVCF file per sample
- **Bed files**: Chromosome-specific interval definitions
- **Reference genome**: GRCh38 p7 FASTA file
- **Sample metadata**: Exclusion list for samples failing QC

## Processing Steps (per chromosome)

1. **GLNexus consolidation**: 
   - Combines all sample GVCFs for chromosome region
   - Applies DeepVariant default filter configuration
   - Output: Chromosome-specific BCF file

2. **Tag filling**: 
   - Adds population-level statistics (bcftools +fill-tags)
   - Computes AC, AN, MAF from genotypes

3. **Variant normalization**:
   - Decomposes complex variants into primitives (vt decompose)
   - Normalizes against reference genome (vt normalize)
   - Removes duplicate/redundant variants (vt uniq)

4. **Sample filtering**: 
   - Excludes specified low-quality samples
   - Retains all passing samples

5. **Site-level filtering**: 
   - Keeps only biallelic SNPs/INDELs
   - Removes multiallelic sites

6. **QC metric generation**:
   - vcftools missing site statistics
   - vcftools individual missing rate
   - vcftools allele burden per individual
   - vcftools singleton detection
   - vcftools site quality scores

## Output Files

- **Chromosome VCF files**: `testPop_1011.dv_glnexus.chr[N].norm.filltags.vcf.gz`
  - Processed DeepVariant calls for each chromosome (1-22, X, Y)
  - Normalized, filtered, biallelic variants only
  - Indexed with tabix

- **QC metrics**: `QC/testPop_1011.dv_glnexus.chr[N].*.out`
  - Missing site rates
  - Missing individual genotype rates
  - Individual allele frequency burden
  - Singleton variants
  - Site quality distributions

## Key Parameters

- **GLNexus config**: DeepVariant (default hard filtering applied)
- **Biallelic filtering**: `-m 2 -M 2` (exactly 2 alleles)
- **Sample exclusion**: Reads from list_exclude1.csv
- **Reference genome**: GRCh38 p7
- **Tag filling**: All population-level statistics

## Chromosome Processing

```bash
# Standard chromosomes (1-22)
for i in {1..22}; do
  # GLNexus consolidation
  # Variant normalization
  # Sample/site filtering
  # QC generation
done

# Special chromosomes (X, Y, others)
for i in 'X' 'Y' '_others'; do
  # Same processing as standard chromosomes
done
```

## Usage

```bash
bash processDV_glnexus.sh
```

Configure paths in script:
```bash
DV_folder="/path/to/glnexus/output/"
DV_file="cohort_name"  # Output prefix
Reference_root="/path/to/GRCh38/p7/reference.fasta"
```

Ensure GVCF files are pre-indexed:
```bash
tabix -p gvcf sample.dv.gvcf.gz
```

## Output Usage

- **Final VCFs**: Used in consensus_pop.sh for multi-pipeline consensus calling
- **QC metrics**: Used to assess variant and sample quality
- **Final output**: Included in postProcessConsensus.sh for final cohort curation

## Related Files

- **Input**: Individual sample GVCF files from FINAL_FLOW/script/I_MAIN_FLOW (Google DeepVariant calling)
- **Uses**: Processing with consensus_pop.sh
- **Final integration**: postProcessConsensus.sh for population-level refinement

## Tool Requirements

- GLNexus: https://github.com/dnanexus/GLnexus
- bcftools: https://samtools.github.io/bcftools/
- vt toolkit: https://github.com/atks/vt
- vcftools: http://vcftools.sourceforge.net/
- tabix/bgzip: https://github.com/samtools/htslib

## Quality Metrics Interpretation

- **Missing rate**: Percentage of genotypes not called (should be < 1-5%)
- **Individual burden**: Number of variants per individual (helps identify outliers)
- **Singletons**: Variants observed in only one individual (potential technical artifacts)
- **Site quality**: QUAL field distribution (higher values = more confident calls)

## References

- Google DeepVariant: https://github.com/google/deepvariant
- GLNexus: https://github.com/dnanexus/GLnexus
- GRCh38 p7: https://www.ncbi.nlm.nih.gov/grc/human/data
- vt toolkit: Tan A, et al. BMC Bioinformatics. 2015;16:180
