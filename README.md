# VN1K: a genome graph-based and function-driven multi-omics and phenomics resource for the Vietnamese population 

**VN1K** is a population-scale genomic resource and analysis framework for the Vietnamese 1000 Genomes initiative. This repository provides code for end-to-end analysis and implementation, from raw data quality control and variant calling through genome-graph construction, imputation, structural-variant detection, and GWAS/clinical applications.

---

## Overview

VN1K’s codebase supports:

- **Quality control and variant calling** — Processing pipelines for WGS and related data.
- **Genome graph construction** — Building and using population-aware genome graphs.
- **Genotype imputation** — Imputation methods and reference panels.
- **Structural variation (SV)** — Deep-learning–based SV detection and analysis.
- **GWAS and clinical use** — Association and clinical interpretation workflows.
- **MEIS** — Supporting tools and workflows for Mobile Element Insertions.

Detailed methods are described in the manuscript and in **Supplementary Methods** (see `Supplementary Methods.docx` in this preprint https://www.biorxiv.org/content/10.1101/2025.04.15.648991v2.full.pdf).

---

## Repository structure (GitHub)

Code is organized at **[github.com/VinGenome/VN1K](https://github.com/VinGenome/VN1K)** under the following modules:

| Module | Description |
|--------|-------------|
| **[QC_and_variant_calling](https://github.com/VinGenome/VN1K/tree/main/QC_and_variant_calling)** | Quality control and variant calling pipelines (e.g. short-read WGS). |
| **[genome_graph_construction](https://github.com/VinGenome/VN1K/tree/main/genome_graph_construction)** | Construction and use of genome graphs for the VN1K resource. |
| **[GenotypeImputation](https://github.com/VinGenome/VN1K/tree/main/GenotypeImputation)** | Imputation workflows and reference panels. |
| **[sv_deeplearning](https://github.com/VinGenome/VN1K/tree/main/sv_deeplearning)** | Deep-learning–based structural variant detection and analysis. |
| **[gwas_clinical](https://github.com/VinGenome/VN1K/tree/main/gwas_clinical)** | GWAS and clinical interpretation pipelines. |
| **[meis](https://github.com/VinGenome/VN1K/tree/main/meis)** | MEIS-related analysis and utilities. |

---

## Programing languages

The VN1K uses following programing languages:

- **C++** — Core tools and performance-critical components  
- **Shell** — Pipeline orchestration and automation  
- **Python** — Analysis scripts and utilities  
- **R** — Statistics and visualization  
- **Makefile** — Build and workflow automation  
- **Jupyter Notebook** — Interactive analysis  
- **Nextflow** — Workflow management where applicable  

---

## Citation and contact

If you use VN1K data or code, please cite the VN1K publication (Nature Communications, as appropriate) and the repository:
1. Tran, T. T., Hoang, T. H., Tran, M. H., Nguyen, N. T., Nguyen, D. T., Pham, T. M., ... & Vo, N. S. (2025). VN1K: a genome graph-based and function-driven multi-omics and phenomics resource for the Vietnamese population. bioRxiv, 2025-04.
2. **Repository:** [https://github.com/VinGenome/VN1K](https://github.com/VinGenome/VN1K)

