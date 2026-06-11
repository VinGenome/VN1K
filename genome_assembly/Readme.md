# Genome Assembly Pipeline

This repository contains a comprehensive suite of bioinformatics scripts and environment configurations dedicated to high-quality genome assembly and quality control on HPC systems. It is structured to support reproducible workflows across different sequencing technologies (ONT, PacBio HiFi).

## Directory Structure

.
├── environments/      # Conda environment definitions (.yaml)
└── scripts/           # SLURM submission scripts (.sh)

## Workflow Overview

The pipeline is designed to handle modular tasks:

1. Assembly: Leveraging state-of-the-art tools like Flye for ONT long reads, Hifiasm for HiFi reads, and Wengan for hybrid assemblies.
2. Polishing: Using Medaka to refine assembly consensus.
3. Scaffolding: Utilizing Ragtag to arrange contigs against a reference genome.
4. Quality Control (QC): Integrated Quast and FastQC modules to assess assembly metrics (N50, completeness, error rates).

## Setup and Prerequisites

### 1. Environment Management

Before executing the scripts, ensure your Conda environments are prepared. You can recreate the necessary environments using:

conda env create -f environments/<env_name>.yaml

### 2. Configuration

The scripts utilize environment variables for flexibility across different HPC nodes. Ensure the following variables are set or defined in your shell session:

* VN1K_DATA: The root directory where your raw data resides.
* WENGAN_PROJECT_ROOT: The directory containing the Singularity containers and binary tools.

## Execution Instructions

These scripts are optimized for the SLURM workload manager. To submit a job, use:

sbatch scripts/<script_name>.sh

## Key Components

| Tool | Purpose |
| :--- | :--- |
| Wengan | Hybrid assembly (ONT + HiFi) managed via Singularity containers. |
| Hifiasm | De novo assembly specifically for PacBio HiFi data. |
| Flye | Long-read assembly for Nanopore ONT data. |
| Quast | Standardized assembly quality metrics and report generation. |
| Ragtag | Reference-based scaffolding and patching. |

## Notes for Users

* Data Paths: The pipeline uses a dynamic path mapping strategy (mapping /QRISdata to /mnt inside containers) to ensure compatibility between host and containerized environments.
* Resources: Resource requests (--mem, -c) are tuned for high-depth human genome assemblies. Please verify your project's resource quota before scaling up.
