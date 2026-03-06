# VN1K: a genome graph-based and function-driven multi-omics and phenomics resource for the Vietnamese population

## Project Overview

This project implements a population-scale genomic resource and analysis framework for the 1000 Vietnamese Genomes (VN1K) initiative. It provides end-to-end pipelines from raw data quality control and variant calling through genome-graph construction, genotype imputation, structural-variant detection, mobile element insertion (MEI) detection, and GWAS/clinical applications. The workflows integrate multiple variant callers (GATK, Illumina Dragen, Google DeepVariant) to generate consensus variant callset, build population-aware pangenome graphs, and support downstream analyses including SNP/HLA imputation, deep learning–based SV merging, and multi-trait GWAS on Vietnamese genomic data.

## Analysis Components

The repository includes the following six components:

- **Quality Control and Variant Calling** — Multiple pipelines for QC and variant calling from WGS and array data, with consensus calling across GATK, Dragen, and DeepVariant.
- **Genome Graph Construction** — Population-aware pangenome graphs (minigraph-cactus, vg), linear and graph-based alignment (BWA-MEM, vg giraffe), and variant calling (DeepVariant, vg call, Manta, Sniffles, pbsv, cuteSV).
- **Genotype Imputation** — SNP and HLA imputation workflows and reference panels integrating VN1K with Asian population data (e.g. 1KGP, HGDP, GenomeAsia).
- **Structural Variation (SV)** — Deep learning–based SV merge and QC pipeline (e.g. cnnLSV) with precision/recall evaluation.
- **GWAS and Clinical Applications** — Multi-trait GWAS (~34 clinical/non-clinical traits), LD clumping, and clinical interpretation workflows.
- **Mobile Element Insertions (MEIs)** — xTea-based MEI detection in the VN1K dataset.

Detailed methods are described in the manuscript: [bioRxiv preprint](https://www.biorxiv.org/content/10.1101/2025.04.15.648991v2.full.pdf).

## Project Structure

```
VN1K/
├── QC_and_variant_calling/     # QC and variant calling pipelines
│   ├── FINAL_FLOW/             # Main WGS processing flow
│   ├── processDV_glnexus.sh     # DeepVariant + GLNexus consolidation
│   ├── processPop.sh            # GATK VQSR filtering
│   ├── consensus_pop.sh         # Multi-pipeline consensus calling
│   ├── postProcessConsensus.sh  # Post-processing and cohort QC
│   ├── makeImputationREF.sh     # Imputation reference panel preparation
│   ├── annovar_annote.sh        # ANNOVAR variant annotation
│   ├── processAxiom 1.sh        # Axiom array processing
│   └── README_*.md              # Per-script documentation
├── genome_graph_construction/   # Pangenome graph pipeline (Snakemake)
│   ├── config/                  # config.yaml, samples.tsv
│   ├── envs/                    # Conda environment (pangenome.yaml)
│   ├── rules/                   # Snakemake rules (backbone, alignment, variant calling, etc.)
│   ├── scripts/                 # Helper scripts
│   ├── profiles/                # SLURM cluster profile
│   └── benchmarks/
├── GenotypeImputation/          # Imputation workflows and evaluation
│   ├── script/                  # Module scripts (prep, merge, impute, error rate, FST)
│   └── fst/                     # FST analysis and plotting
├── sv_deeplearning/             # Deep learning SV merge and QC
│   ├── script/                  # cnnlsv.sh and pipeline scripts
│   ├── tools/                   # Tool binaries/code
│   ├── requirements.txt         # Python dependencies
│   ├── dockerfile               # Docker environment
│   └── quality_control.ipynb    # TP/FP/FN evaluation
├── gwas_clinical/               # GWAS and clinical analysis
│   └── src/                     # QC.sh, gwas.sh, clump.sh, Manhattan plots (R)
├── meis/                        # Mobile element insertion (xTea-based)
└── README.md                    # This file
```

## Overall Workflow

**1. Data preprocessing and variant calling**

- **WGS:** Align reads (e.g. via FINAL_FLOW), call variants with GATK, Dragen, and DeepVariant; consolidate DeepVariant GVCFs with GLNexus (`processDV_glnexus.sh`); apply GATK VQSR (`processPop.sh`).
- **Array:** Process Axiom CEL files with APT (`processAxiom 1.sh`) for QC and genotype calling.

**2. Consensus and cohort refinement**

- **Consensus calling:** Intersect SNP/INDEL calls across GATK, Dragen, and DeepVariant (`consensus_pop.sh`).
- **Post-processing:** HWE filtering, sample QC, rsID/gnomAD integration, final cohort VCF and sites-only panel (`postProcessConsensus.sh`).
- **Imputation reference:** Phasing with SHAPEIT and building reference panels (`makeImputationREF.sh`).
- **Annotation:** Functional and clinical annotation with ANNOVAR (`annovar_annote.sh`).

**3. Downstream analysis**

- **Genome graph:** Build pangenome graphs, run linear and graph alignment, call variants (DeepVariant, vg call, SV callers) — see `genome_graph_construction/` Snakemake targets.
- **Imputation:** Run SNP/HLA imputation using reference panels (see `GenotypeImputation/script/`).
- **SV deep learning:** Merge/refine SVs and run QC (`sv_deeplearning/script/cnnlsv.sh`, `quality_control.ipynb`).
- **GWAS:** QC target VCF, run GWAS (PLINK2 GLM), LD clumping, Manhattan plots (`gwas_clinical/src/`).
- **MEIs:** Run xTea-based MEI detection (see `meis/` and manuscript).

**4. Evaluation and visualization**

- Compare variant call sets (consensus stats, QC metrics).
- Evaluate imputation accuracy and error rates (R/Python in `GenotypeImputation/`).
- Assess SV precision/recall in `sv_deeplearning/quality_control.ipynb`.
- Visualize GWAS results (Manhattan plots, etc.) in `gwas_clinical/`.

## Setup and Requirements

### Dependencies

| Category | Tools / versions |
|----------|------------------|
| **Core (QC/variant calling)** | Bash, bcftools, SAMtools, tabix/bgzip (htslib), vt, vcftools |
| **Variant callers** | GATK 4.x (e.g. 4.1.8.1), Google DeepVariant, GLNexus; Illumina Dragen (optional) |
| **Phasing / imputation ref** | SHAPEIT (with extractPIRs) |
| **Annotation** | ANNOVAR (with humandb) |
| **Array** | Affymetrix Power Tools (APT), Axiom analysis libraries (e.g. PMDA v7.0) |
| **Genome graph** | Conda/Mamba, Snakemake ≥ 7.0, Docker; Cactus (minigraph-cactus), vg ≥ 1.50; BWA-MEM, minimap2, pbmm2; DeepVariant, Manta (Docker); Sniffles, pbsv, cuteSV, SURVIVOR |
| **Imputation** | Minimac4 / IMPUTE5 or similar (as in module scripts); bcftools, vcftools; Python 3, R |
| **SV deep learning** | Python 3; opencv-python, pysam, torch, cigar (see `sv_deeplearning/requirements.txt`) |
| **GWAS** | PLINK 1.9, PLINK2; bcftools; R ≥ 3.6 (tidyverse, qqman, ggplot2, ggrepel) |
| **MEIs** | xTea; BWA, SAMtools; reference genome GRCh38 |

### Data requirements

- **Reference genome:** GRCh38 p7 (FASTA + index) for variant calling, phasing, graph construction, and MEIs.
- **Variant calling:** Per-sample GVCFs (DeepVariant) or joint VCFs (GATK/Dragen); chromosome BEDs; sample lists.
- **VQSR resources (GATK):** Mills_and_1000G_gold_standard.indels.hg38, dbSNP138, hapmap_3.3, 1000G_omni2.5, 1000G_phase1.snps.high_confidence (hg38).
- **Consensus / post-processing:** IGSR HC, KHV HC, gnomAD reference files.
- **Imputation:** Consensus VCF, BAMs (for PIR extraction), 1KGP (and optionally HGDP) reference panels.
- **ANNOVAR:** refGene, cytoBand, exac03, avsnp150, dbnsfp42c, ClinVar (or equivalent).
- **Axiom:** Raw CEL files and Axiom XML/config.
- **GWAS:** QC’ed consensus VCF, phenotype file (e.g. `clinical_pheno.0131.txt`), sample list (e.g. 811 clinical samples).
- **Genome graph:** Per-chromosome FASTAs (references + assemblies), variant VCFs (SNPs/indels, SVs), sample sheet (`samples.tsv`).
- **SV deep learning:** VCF list (header removed), BAM path, input/output paths as in `cnnlsv.sh`.
- **MEIs:** Aligned BAMs (or FASTQs) and xTea reference/annotation files.

Module-specific details: see the README in each subfolder (`QC_and_variant_calling/README_*.md`, `genome_graph_construction/README.md`, `GenotypeImputation/README.md`, `sv_deeplearning/README.md`, `gwas_clinical/README.md`).

## Version History

- **v1.0** — Initial release with QC/variant calling, genome graph construction, imputation, SV deep learning, GWAS/clinical, and MEIs components (see manuscript and repository history).

## References

### GitHub repositories

- [Google DeepVariant](https://github.com/google/deepvariant)
- [GLNexus](https://github.com/dnanexus/GLnexus)
- [vt (variant tools)](https://github.com/atks/vt)
- [bcftools / htslib](https://github.com/samtools/htslib)
- [vg](https://github.com/vgteam/vg)
- [xTea (MEIs)](https://github.com/parklab/xTea)
- [ANNOVAR](http://annovar.openbioinformatics.org/)
- [SHAPEIT](http://shapeit.fr/)

### Documentation and tutorials

- [GATK Best Practices — Germline short variant discovery](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-)
- [GATK VariantRecalibrator](https://gatk.broadinstitute.org/hc/en-us/articles/360037499012-VariantRecalibrator)
- [Snakemake documentation](https://snakemake.readthedocs.io/)
- [PLINK](https://www.cog-genomics.org/plink/)

### Research papers and resources

- VN1K manuscript: [bioRxiv 2025.04.15.648991](https://www.biorxiv.org/content/10.1101/2025.04.15.648991v2.full.pdf)
- GRCh38: [NCBI GRC human data](https://www.ncbi.nlm.nih.gov/grc/human/data)
- 1000 Genomes Project: [www.internationalgenome.org](https://www.internationalgenome.org/)
- gnomAD: [gnomad.broadinstitute.org](https://gnomad.broadinstitute.org/)

## Citation and contact

If you use VN1K data or code, please cite:

1. Trang TH Tran, Tham H Hoang, Mai H Tran, Nguyen T Nguyen, Dat T Nguyen, Tien M Pham, Nam N Nguyen, Giang M Vu, Vinh C Duong, Quang T Vu, Thien K Nguyen, Sang V Nguyen, Hien Q Vu, Trang M Nguyen, Toan Dang, Hoang Nguyen, Tuan Do, Cuong Le, Hung TT Nguyen, Nam Q Le, Quang-Huy Nguyen, Linh T Le, Thang Pham, Minh Dao, Duc M Vu, Huong TT Le, Tho D Ngo, Liem T Nguyen, Yen Hoang, Dat X Dao, Giang H Phan, Loan Nguyen, Chi Trung Ha, Hung N Luu, Vinh Le, Thinh Tran, Ly Le, Nguyen Thuy Duong, Duc-Hau Le, Quan Nguyen, Van H Vu, Nam S Vo (2025). VN1K: a genome graph-based and function-driven multi-omics and phenomics resource for the Vietnamese population. bioRxiv, 2025-04.
2. Repository: [https://github.com/VinGenome/VN1K](https://github.com/VinGenome/VN1K)
