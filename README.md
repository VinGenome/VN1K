# VN1K: a genome graph-based and function-driven multi-omics and phenomics resource for the Vietnamese population 

**VN1K** is a population-scale genomic resource and analysis framework for the 1000 Vietnamese Genomes initiative. In this repository, we provides detailed codes and implementations for end-to-end analysis, from raw data quality control and variant calling through genome-graph construction, imputation, structural-variant detection, mobile elements and GWAS/clinical applications.

---

## Overview

- **Quality Control and Variant Calling** — We provided multiple pipelines for quality control and variant calling using various tools to generate a consensus dataset from DNA Whole Genome Sequencing and related data.
- **Genome Graph Construction** — We built population-aware genome graphs using VN1K samples and evaluated their performance on 1KGP samples, including the Kinh population in Ho Chi Minh City, Vietnam (KHV) from 1000 Human Genomes (1KGP).
- **Genotype Imputation** — We implemented imputation workflows and developed reference panels that integrate the VN1K genetic structure with existing datasets from Asian populations for downstream human genome applications.
- **Structural Variation (SV)** — We developed a deep learning–based workflow for SV detection and performed comprehensive analysis using this pipeline.
- **GWAS and Clinical Applications** — We conducted multi-trait genome-wide association studies and implemented clinical interpretation workflows.
- **Mobile Element Insertions (MEIs)** — We applied xTea-based workflows to detect MEIs in the VN1K dataset.

Detailed methods are described in the manuscript in this preprint at https://www.biorxiv.org/content/10.1101/2025.04.15.648991v2.full.pdf.

## Citation and contact

If you use VN1K data or code, please cite the VN1K publication (Nature Communications, as appropriate) and the repository:
1. Tran, T. T., Hoang, T. H., Tran, M. H., Nguyen, N. T., Nguyen, D. T., Pham, T. M., ... & Vo, N. S. (2025). VN1K: a genome graph-based and function-driven multi-omics and phenomics resource for the Vietnamese population. bioRxiv, 2025-04.
2. Repository: [https://github.com/VinGenome/VN1K](https://github.com/VinGenome/VN1K)

