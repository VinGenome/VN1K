# Vietnamese Pangenome Graph Pipeline

A comprehensive Snakemake pipeline for constructing population-specific pangenome graphs, performing read alignment, and calling variants using both traditional linear and graph-based approaches.

## Overview

This pipeline builds a Vietnamese population-specific pangenome graph by integrating:
- **4 Vietnamese hybrid assemblies** (VN1K_920_ragtag, VN1K_007_ragtag, HG01596, HG02018)
- **2 reference genomes** (GRCh38, T2T-CHM13)
- **Population variants** from ~1,000 Vietnamese whole-genome sequencing samples (SNPs, indels, SVs)

The pipeline enables comprehensive comparison between:
- **Linear alignment** (BWA-MEM for short reads, minimap2/pbmm2 for long reads)
- **Graph-based alignment** (vg giraffe) to three graph types:
  - Baseline GRCh38-only graph
  - Backbone graph (assemblies + references)
  - Full pangenome graph (backbone + population variants)

## Features

### Graph Construction
- Per-chromosome processing for parallelization
- Minigraph-cactus for backbone graph construction
- VG tools for variant integration and indexing
- Giraffe indexes for both short-read and long-read alignment

### Alignment Modes
| Mode | Short Reads | Long Reads |
|------|-------------|------------|
| Linear | BWA-MEM | minimap2, pbmm2 |
| Graph (Baseline) | vg giraffe | vg giraffe |
| Graph (Backbone) | vg giraffe | vg giraffe |
| Graph (Pangenome) | vg giraffe | vg giraffe |

### Variant Calling
- **DeepVariant**: From linear BAMs and surjected graph BAMs
- **vg call**: Native graph-based calling from GAM alignments
- **vg augment**: Novel variant discovery
- **SV Callers**:
  - Manta (short reads)
  - Sniffles (long reads)
  - pbsv (PacBio long reads)
  - cuteSV (long reads)

## Directory Structure

```
genome_graph_mc_pipeline/
├── Snakefile                 # Main workflow file
├── config/
│   ├── config.yaml           # Pipeline configuration
│   └── samples.tsv           # Sample sheet
├── rules/                    # Modular Snakemake rules
│   ├── backbone.smk          # Graph construction with minigraph-cactus
│   ├── sv_merge.smk          # SV merging with SURVIVOR
│   ├── novel_variants.smk    # Novel variant detection
│   ├── graph_augment.smk     # Graph augmentation with variants
│   ├── indexing.smk          # Giraffe index building
│   ├── baseline_grch38.smk   # GRCh38-only baseline graph
│   ├── alignment_linear.smk  # BWA/minimap2 alignment
│   ├── alignment_graph.smk   # VG giraffe alignment
│   ├── baseline_alignment.smk
│   ├── backbone_alignment.smk
│   ├── variant_calling_deepvariant.smk
│   ├── vg_call_baseline.smk
│   ├── vg_novel_calling.smk
│   ├── sv_calling_*.smk      # SV callers (Manta, Sniffles, pbsv, cuteSV)
│   ├── graph_comparison.smk  # Comparison analysis
│   ├── stats.smk             # Statistics generation
│   └── targets.smk           # Target rule definitions
├── envs/
│   └── pangenome.yaml        # Conda environment
├── profiles/
│   └── slurm/                # SLURM cluster profile
├── scripts/                  # Helper scripts
├── results/                  # Output directory
├── logs/                     # Log files
└── benchmarks/               # Benchmark files
```

## Installation

### Prerequisites
- Conda/Mamba
- Snakemake >= 7.0
- Docker (for DeepVariant, Manta)

### Setup

```bash
# Clone repository
git clone 
cd genome_graph_mc_pipeline

# Create conda environment
conda env create -f envs/pangenome.yaml
conda activate pangenome

# Pull Docker images for variant calling
./scripts/pull_docker_images.sh
```

### Additional Tools (may require separate installation)
- **Cactus** (minigraph-cactus): `pip install cactus`
- **vg**: Version >= 1.50

## Configuration

### config/config.yaml

Key configuration sections:

```yaml
# Project settings
project_name: "vn_pangenome"
output_dir: "results"

# Chromosomes to process
chromosomes:
  - chr22  # Start with one chromosome for testing

# Input data paths
per_chrom_fastas:
  directory: "/path/to/per_chromosome_fastas"
  pattern: "{chrom}.fa.gz"

# Variant inputs
variants:
  snps_indels_dir: "/path/to/snp_vcfs"
  manta_dir: "/path/to/manta_vcfs"
  pbsv_vcfs: [...]

# Tool parameters
cactus:
  max_cores: 64
  max_memory: "256G"
```

### config/samples.tsv

Tab-separated sample sheet:

```tsv
sample_id	platform	r1	r2	long_reads	read_type
VN005	ILLUMINA	/path/to/R1.fastq.gz	/path/to/R2.fastq.gz		
HG02080	PACBIO			/path/to/hifi.fastq.gz	hifi
```

**Columns:**
- `sample_id`: Unique sample identifier
- `platform`: `ILLUMINA`, `PACBIO`, or `ONT`
- `r1`, `r2`: Paired-end FASTQ paths (for Illumina)
- `long_reads`: Long read FASTQ path
- `read_type`: `hifi`, `clr`, or `ont` (for long reads)

## Usage

### Basic Usage

```bash
# Activate environment
conda activate pangenome

# Dry run to see what will be executed
snakemake -n <target>

# Run with local cores
snakemake --cores 64 <target>

# Run with SLURM cluster
snakemake --profile profiles/slurm <target>
```

### Main Target Rules

| Target | Description |
|--------|-------------|
| `all` | Build pangenome indexes + pipeline summary |
| `all_backbone` | Build backbone graphs (minigraph-cactus) |
| `all_graphs` | Build final augmented graphs |
| `all_alignments` | All alignments (linear + graph) |
| `all_variants` | DeepVariant calling (linear + graph) |
| `all_vg_call` | Native vg call from GAM |
| `all_sv_calling` | All SV callers (Manta + Sniffles + pbsv + cuteSV) |
| `all_grch38_baseline` | Build GRCh38-only baseline |
| `all_complete_pipeline` | **Run everything** |

### Example Workflows

```bash
# 1. Build pangenome graph only
snakemake --cores 64 all_graphs

# 2. Run alignments and DeepVariant
snakemake --cores 64 all_variants

# 3. Run vg call on all three graph types
snakemake --cores 64 all_vg_call_all_graphs

# 4. Run complete pipeline
snakemake --cores 64 all_complete_pipeline

# 5. Run for specific sample (modify samples.tsv first)
# Comment out other samples, then:
snakemake --cores 64 all_variants
```

### Per-Chromosome Processing

The pipeline processes each chromosome independently. To run specific chromosomes, edit `config/config.yaml`:

```yaml
chromosomes:
  - chr22  # Test with one chromosome
  # - chr1
  # - chr2
  # ... uncomment for full genome
```

## Output Structure

```
results/
├── backbone/                    # Backbone graphs (minigraph-cactus)
│   └── {chrom}/
│       ├── vn_pangenome.{chrom}.gfa.gz
│       ├── vn_pangenome.{chrom}.gbz
│       └── vn_pangenome.{chrom}.vcf.gz
├── sv_merged/                   # Merged SVs (SURVIVOR)
│   └── {chrom}/
│       └── final_sv_merged.vcf.gz
├── pangenome/                   # Final augmented graphs
│   └── {chrom}/
│       └── vn_pangenome_final.{chrom}.vg
├── indexes/                     # Giraffe indexes
│   └── {chrom}/
│       ├── vn_pangenome.{chrom}.giraffe.gbz
│       ├── vn_pangenome.{chrom}.dist
│       ├── vn_pangenome.{chrom}.shortread.withzip.min
│       └── vn_pangenome.{chrom}.longread.withzip.min
├── baseline_grch38/             # GRCh38-only baseline
│   ├── graphs/
│   └── indexes/
├── alignments/
│   ├── linear_sr/{sample}/      # BWA-MEM alignments
│   ├── linear_lr/{sample}/      # minimap2 alignments
│   ├── graph_sr/{sample}/       # Giraffe short-read GAM
│   ├── graph_lr/{sample}/       # Giraffe long-read GAM
│   ├── baseline_sr/{sample}/    # Baseline graph GAM
│   └── backbone_sr/{sample}/    # Backbone graph GAM
└── called_variants/
    ├── linear_sr/{sample}.vcf.gz      # DeepVariant (linear)
    ├── graph_sr/{sample}.vcf.gz       # DeepVariant (graph)
    ├── vg_call_sr/{sample}.vcf.gz     # vg call (pangenome)
    ├── vg_call_baseline_sr/           # vg call (baseline)
    ├── vg_call_backbone_sr/           # vg call (backbone)
    ├── manta/                         # Manta SVs
    ├── sniffles/                      # Sniffles SVs
    ├── pbsv/                          # pbsv SVs
    └── cutesv/                        # cuteSV SVs
```

## Workflow Phases

### Phase 1: Graph Construction
1. **Backbone construction** (minigraph-cactus)
   - Input: Per-chromosome FASTAs with references + assemblies
   - Output: GFA, GBZ, VCF

2. **SV merging** (SURVIVOR)
   - Merge Manta SVs (1011 samples, 1% support threshold)
   - Merge pbsv SVs (4 pools)
   - Combine both platforms

3. **Graph augmentation** (vg add)
   - Add merged SVs to backbone
   - Add filtered SNPs/indels (MAF > 5%)

4. **Index building** (vg autoindex)
   - Giraffe indexes for short-read and long-read alignment
   - XG index for surjection

### Phase 2: Baseline Construction
- Build GRCh38-only graph for comparison
- Same indexing workflow

### Phase 3: Alignment
- Linear alignment (BWA-MEM, minimap2)
- Graph alignment to all three graph types
- Surjection of GAM to BAM

### Phase 4: Variant Calling
- DeepVariant from BAMs (linear + surjected)
- vg call from GAMs
- SV calling (Manta, Sniffles, pbsv, cuteSV)

### Phase 5: Analysis
- Graph statistics comparison
- Alignment quality comparison
- Variant calling benchmarks

## Resource Requirements

| Rule | Threads | Memory | Time |
|------|---------|--------|------|
| cactus_pangenome | 64 | 256GB | 48h |
| build_giraffe_indexes | 32 | 64GB | 12h |
| align_graph | 16 | 64GB | 4h |
| deepvariant | 8 | 32GB | 4h |
| merge_manta_sv | 4 | 16GB | 12h |

## Troubleshooting

### Common Issues

1. **Double slash in paths**: Check `config.yaml` for trailing slashes in directory paths

2. **Sample not recognized**: Ensure `samples.tsv` uses tab separators (not spaces)

3. **Memory issues with cactus**: Reduce `max_memory` or process fewer chromosomes

4. **Docker permission errors**: Add user to docker group or use `sudo`

### Validation

```bash
# Validate input files
./scripts/validate_inputs.sh

# Check Snakemake DAG
snakemake --dag all | dot -Tpng > dag.png

# Check specific rule requirements
snakemake -n --reason <target>
```

