# Imputation Reference Panel Preparation (makeImputationREF.sh)

## Overview

This script creates a chromosome-specific imputation reference panel from phased haplotype data by combining Vietnamese population (VN1K) consensus variants with 1000 Genomes Project (1KGP) reference data. The resulting panels serve as reference for genotype imputation in downstream analyses.

## Methodology

Following the VN1K variant calling and consensus calling procedures, imputation reference panels are constructed by:

1. **Variant Filtering**: Processes consensus VCF files containing high-confidence variants:
   - Retains only biallelic, common variants (MAF ≥ 0.001)
   - Filters variants with >1% missing data
   - Normalizes and decomposes complex variants
   - Fills population statistics tags (MAF, AC, AN)

2. **Haplotype Assembly**: Uses SHAPEIT for haplotype phasing:
   - Extracts paired-end read information (PIRs) using extractPIRs
   - Phases genotypes using SHAPEIT with phasing information
   - Converts phased data to VCF format for imputation tools

3. **Reference Panel Construction**: Combines population-specific variants with global reference:
   - VN1K variants: Vietnamese population consensus variants
   - 1KGP variants: Global reference variants filtered by MAF threshold
   - Chromosome-specific organization for efficient imputation

## Input Requirements

- **Consensus VCF**: Output from postProcessConsensus.sh (normalized, with variant tags)
- **BAM files**: Aligned whole genome sequencing data for PIR extraction
- **Reference genome**: GRCh38 p7 with FASTA index
- **1KGP reference VCF**: Pre-downloaded 1000 Genomes Project high-confidence VCF files

## Processing Steps

1. **Chromosome separation**: Split VCF by chromosome for parallel processing
2. **Missing data filtering**: Keep variants with <1% missing genotypes
3. **Variant normalization**: Decompose complex variants, normalize representation
4. **Allele frequency filtering**: Retain variants with MAF ≥ 0.001
5. **Biallelic filtering**: Keep only sites with exactly 2 alleles
6. **PIR extraction**: Extract paired-end read information for improved phasing
7. **SHAPEIT phasing**: Phase genotypes using read-level information
8. **VCF conversion**: Convert phased haplotype data to VCF format
9. **Indexing**: Compress and index all output files with tabix

## Output Files

- **Phased VCF files**: `VN_1008.HaplotypeData.chr[N].vcf.gz` - SHAPEIT phased haplotypes
- **Per-chromosome panels**: Organized by chromosome in `VN_1008/` directory
- **1KGP panels**: Filtered 1KGP variants by chromosome
- **Merged panels**: Combined reference panels ready for imputation

## Key Parameters

- **MAF threshold**: ≥ 0.001 (keeps common variants)
- **Missing data filter**: Maximum 1% missing calls
- **Variant types**: Biallelic SNPs and small INDELs only
- **Phasing threads**: 50 (adjustable based on available resources)
- **Reference genome**: GRCh38 p7

## Usage

```bash
bash makeImputationREF.sh <chromosome_number>
```

Configure paths in script:
```bash
VN_ref="/path/to/consensus/vcf.gz"
Ref_folder="/path/to/reference/output/"
Reference_root="/path/to/GRCh38/p7/reference.fasta"
extractPIR_folder="/path/to/extractPIRs/binary/"
```

## Parallel Execution

This script is designed for chromosome-level parallelization:

```bash
# Process all chromosomes in parallel
for i in {1..22} X; do
  bash makeImputationREF.sh $i &
done
wait
```

## Related Files

- **Input**: Output from postProcessConsensus.sh
- **Uses BAM files**: From FINAL_FLOW/script/I_MAIN_FLOW (aligned reads)
- **Outputs to**: Used in GenotypeImputation/ workflows

## Tool Requirements

- SHAPEIT: http://shapeit.fr/
- extractPIRs: Part of SHAPEIT package
- bcftools: For VCF manipulation
- vt toolkit: For variant normalization
- SAMtools: For BAM file handling

## References

- SHAPEIT: Delaneau O, et al. A linear complexity phasing algorithm. Bioinformatics. 2013
- 1000 Genomes Project: http://www.1000genomes.org/
- GRCh38 p7: https://www.ncbi.nlm.nih.gov/grc/human/data
- extractPIRs: Durbin R. Phasing. 2014
