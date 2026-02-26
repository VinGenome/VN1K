#!/bin/bash
# prepare_inputs.sh
# Helper script to set up data directories and validate inputs
# Usage: bash scripts/prepare_inputs.sh

set -euo pipefail

echo "======================================="
echo "Vietnamese Pangenome Pipeline Setup"
echo "======================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create directory structure
echo "Creating directory structure..."
mkdir -p data/assemblies
mkdir -p data/variants/manta
mkdir -p data/variants/pbsv
mkdir -p results
mkdir -p logs
mkdir -p benchmarks

echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Check for required tools
echo "Checking required tools..."
TOOLS_OK=true

check_tool() {
    if command -v $1 &> /dev/null; then
        VERSION=$($1 --version 2>&1 | head -n1 || echo "version unknown")
        echo -e "${GREEN}✓ $1${NC}: $VERSION"
    else
        echo -e "${RED}✗ $1 not found${NC}"
        TOOLS_OK=false
    fi
}

check_tool snakemake
check_tool bcftools
check_tool tabix
check_tool minigraph
check_tool vg
check_tool SURVIVOR

# Check for cactus
if command -v cactus-pangenome &> /dev/null; then
    echo -e "${GREEN}✓ cactus-pangenome${NC}"
else
    echo -e "${YELLOW}! cactus-pangenome not found - install separately${NC}"
fi

echo ""

# Validate config
if [ -f "config/config.yaml" ]; then
    echo -e "${GREEN}✓ config/config.yaml exists${NC}"
else
    echo -e "${RED}✗ config/config.yaml not found${NC}"
fi

echo ""
echo "======================================="
echo "Data Preparation Checklist"
echo "======================================="
echo ""
echo "Please ensure the following files are in place:"
echo ""
echo "1. Reference Assemblies (in data/assemblies/):"
echo "   - GRCh38.fa"
echo "   - CHM13.fa"
echo "   - hybrid_asm1.fa, hybrid_asm2.fa, hybrid_asm3.fa, hybrid_asm4.fa"
echo ""
echo "2. Variants:"
echo "   - data/variants/snps_indels.vcf.gz (merged SNPs/indels)"
echo "   - data/variants/manta/*.manta.vcf.gz (1000 Manta files)"
echo "   - data/variants/pbsv/pool[1-4].pbsv.vcf.gz (4 pbsv files)"
echo ""

# Count Manta files if directory exists
if [ -d "data/variants/manta" ]; then
    MANTA_COUNT=$(ls data/variants/manta/*.manta.vcf.gz 2>/dev/null | wc -l)
    echo -e "Found ${GREEN}${MANTA_COUNT}${NC} Manta VCF files"
else
    echo -e "${YELLOW}Manta directory not found${NC}"
fi

# Count pbsv files
if [ -d "data/variants/pbsv" ]; then
    PBSV_COUNT=$(ls data/variants/pbsv/*.pbsv.vcf.gz 2>/dev/null | wc -l)
    echo -e "Found ${GREEN}${PBSV_COUNT}${NC} pbsv VCF files"
else
    echo -e "${YELLOW}pbsv directory not found${NC}"
fi

echo ""
echo "======================================="
echo "Quick Start Commands"
echo "======================================="
echo ""
echo "# Dry run (check workflow)"
echo "snakemake -n --cores 1"
echo ""
echo "# Run locally"
echo "snakemake --cores 64 --use-conda"
echo ""
echo "# Run on SLURM cluster"
echo "snakemake --profile profiles/slurm --use-conda"
echo ""
echo "# Run specific targets"
echo "snakemake --cores 64 backbone_only      # Build backbone only"
echo "snakemake --cores 64 sv_merge_only      # Merge SVs only"
echo ""
echo "# Generate DAG visualization"
echo "snakemake --dag | dot -Tpng > dag.png"
echo ""
