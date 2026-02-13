# Axiom Genotyping Array Processing (processAxiom\ 1.sh)

## Overview

This script processes Axiom genotyping array data using the Axiom Best Practice workflow. It performs quality control on raw CEL files from Illumina Axiom microarray assays, generates genotype calls, and filters samples and variants based on quality metrics.

## Methodology

As an alternative genotyping platform to whole-genome sequencing, the VN1K project utilized Illumina Axiom microarrays processed using the official Axiom Best Practice pipeline:

1. **Quality Control - Dish QC (DQC)**:
   - Uses APT (Axiom Genotyping Console) for initial QC
   - Generates DQC values from raw CEL files
   - DQC metric indicates overall quality of genotyping reactions
   - Removes samples with DQC < 0.82 (default threshold)

2. **Sample Grouping and Organization**:
   - Organizes CEL files by batch and plate identifiers
   - Generates manifest files listing samples for processing
   - Processes samples in batch mode for efficiency
   - Supports multiple batch and plate configurations

3. **Sample Filtering**:
   - Removes low-DQC samples from downstream analysis
   - Maintains list of failed samples for quality reporting
   - Continues processing with passing samples only

4. **Axiom Genotyping Steps**:
   - Step 1: Group samples into batches
   - Step 2: Generate DQC quality metrics
   - Step 3: Filter by DQC threshold
   - Step 4-6: Genotype calling (SNP polishing, sex determination, copy number analysis)

5. **Output Generation**:
   - Genotype calls (best guess genotypes)
   - Confidences scores for each call
   - Sex predictions from X chromosome markers
   - Copy number estimates

## Input Requirements

- **CEL files**: Raw intensity files from Axiom microarray scanner
  - Binary format output from GeneTitan or GeneTitan Instrument
  - One per sample, organized by batch and plate
- **Axiom analysis files**: APT library files
  - XML configuration file (e.g., Axiom_PMDA.r7.apt-geno-qc.AxiomQC1.xml)
  - PMDA library files for annotation
- **APT binaries**: Affymetrix Power Tools
  - apt-geno-qc: QC generation tool
  - apt-genotype: Genotype calling tool

## Processing Steps

1. **Directory setup**: Create output directories for:
   - QC results
   - Genotype calls
   - Summary statistics
   - Intermediate analysis results
   - Specialized analysis (SNPolisher, copy number)

2. **Manifest generation**: List all CEL files by batch and plate

3. **Dish QC calculation**:
   - apt-geno-qc generates QC metrics for each sample
   - Outputs DQC values and quality reports
   - Identifies problematic samples

4. **Sample filtering**:
   - Filters samples with DQC < 0.82
   - Creates inclusion/exclusion lists
   - Continues with passing samples

5. **Genotype calling** (multiple steps):
   - SNP genotyping
   - Sex determination
   - Copy number variation analysis
   - Confidence score assignment

## Output Files

- **QC report**: `apt-geno-qc.txt`
  - DQC values for all samples
  - Quality metrics and statistics
  - Annotations and sample identifiers

- **QC log**: `apt-geno-qc.log`
  - Detailed processing log
  - Error messages and warnings
  - Processing timestamps

- **Genotype calls**: Multiple files in Output directory:
  - `summary/`: Genotype summary statistics
  - `step2/`: Post-polishing genotypes
  - `cn/`: Copy number analysis results
  - `SNPolisher/`: SNP quality information
  - `analysis_step1/`: Intermediate analysis data

- **Sample lists**:
  - `list_fail_DQC.txt`: Samples failing DQC threshold
  - `list_celB[N].filterDQC.txt`: Passing samples for downstream processing

## Key Parameters

- **DQC threshold**: 0.82 (default Axiom recommendation)
- **Configuration**: Axiom Best Practice XML files
- **Analysis files path**: PMDA library directory
- **Batch processing**: Organized by batch number and plate number

## Batch Processing

The script supports processing multiple batches and plates:

```bash
# Single batch processing
bash "processAxiom 1.sh" 1

# Multiple batches with multiple plates
# Batch 2, plate 1
bash "processAxiom 1.sh" 2 1

# Batch 2, plate 2
bash "processAxiom 1.sh" 2 2
```

## Usage

```bash
bash "processAxiom 1.sh" <batch_number> [plate_number]
```

Configure paths in script:
```bash
APT_app="/path/to/apt/bin/"
Axiom_analysisDir="/path/to/axiom/analysis/libraries/"
CEL_dir="/path/to/raw/cel/files/Batch[N]/"
Output_QC_BP="/path/to/output/QC/"
Output_BP="/path/to/output/calls/"
```

## Output Usage

- **Passing samples**: Used in subsequent array analysis pipelines
- **Genotype calls**: Can be converted to VCF format
- **QC metrics**: Used to assess microarray platform performance
- **Cross-validation**: Can be compared against WGS genotypes

## Integration with VN1K Pipeline

- **Complementary platform**: Provides microarray genotyping data alongside WGS
- **Comparison opportunity**: Can validate/compare array calls against sequencing calls
- **QC refinement**: Combined data improves overall sample quality assessment

## Tool Requirements

- APT (Axiom Genotyping Console): https://www.affymetrix.com/
- Axiom analysis libraries: PMDA v7.0 (or relevant version)
- Perl or scripting language for list processing

## Quality Control Metrics

- **DQC (Dish QC)**: Overall dish quality
  - DQC < 0.82: Sample fails QC
  - DQC ≥ 0.82: Sample passes QC
- **Sample call rate**: Percentage of markers successfully called
- **Gender concordance**: Sex determination accuracy
- **Clustering metrics**: SNP allele clustering quality

## References

- Affymetrix Axiom: https://www.affymetrix.com/
- Axiom Best Practice: Affymetrix documentation
- APT (Axiom Genotyping Console): Affymetrix Power Tools
- QC metrics: Affymetrix technical notes

## Notes

- File names contain spaces in directory paths; adjust for proper handling in production
- Consider batch effects when comparing across multiple processing batches
- DQC threshold may be adjusted based on project-specific requirements
- High-throughput processing can utilize parallelization with batch submissions
