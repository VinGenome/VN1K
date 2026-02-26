#!/bin/bash
# validate_inputs.sh
# Validate input files before running the pipeline
# Usage: bash scripts/validate_inputs.sh

set -euo pipefail

CONFIG="config/config.yaml"

echo "======================================="
echo "Input Validation for VN Pangenome"
echo "======================================="
echo ""

ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_file() {
    local file=$1
    local desc=$2

    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $desc: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $desc: $file NOT FOUND"
        ((ERRORS++))
        return 1
    fi
}

check_dir() {
    local dir=$1
    local desc=$2

    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $desc: $dir"
        return 0
    else
        echo -e "${RED}✗${NC} $desc: $dir NOT FOUND"
        ((ERRORS++))
        return 1
    fi
}

# Extract paths from config
echo "Parsing config..."
GRCH38=$(grep -A2 "^references:" $CONFIG | grep "GRCh38:" | awk '{print $2}' | tr -d '"')
CHM13=$(grep -A2 "^references:" $CONFIG | grep "CHM13:" | awk '{print $2}' | tr -d '"')

echo ""
echo "=== Reference Genomes ==="
check_file "$GRCH38" "GRCh38"
check_file "$CHM13" "CHM13"

echo ""
echo "=== Hybrid Assemblies ==="
for i in 1 2 3 4; do
    ASM=$(grep "VN_sample${i}:" $CONFIG | awk '{print $2}' | tr -d '"')
    check_file "$ASM" "VN_sample${i}"
done

echo ""
echo "=== SNP/Indel VCFs (Per Chromosome) ==="
SNPS_DIR=$(grep "snps_indels_dir:" $CONFIG | awk '{print $2}' | tr -d '"')

if check_dir "$SNPS_DIR" "SNPs/indels directory"; then
    FOUND_CHROMS=0
    MISSING_CHROMS=""

    for chr in chr{1..22} chrX chrY; do
        if [ -f "${SNPS_DIR}/${chr}.vcf.gz" ]; then
            ((FOUND_CHROMS++))
        else
            MISSING_CHROMS="${MISSING_CHROMS}${chr} "
        fi
    done

    echo -e "  Found ${GREEN}${FOUND_CHROMS}/24${NC} chromosome VCFs"

    if [ $FOUND_CHROMS -eq 0 ]; then
        echo -e "  ${RED}ERROR: No chromosome VCFs found!${NC}"
        ((ERRORS++))
    elif [ $FOUND_CHROMS -lt 24 ]; then
        echo -e "  ${YELLOW}WARNING: Missing: ${MISSING_CHROMS}${NC}"
        ((WARNINGS++))
    fi
fi

echo ""
echo "=== Manta SV VCFs ==="
MANTA_DIR=$(grep "manta_dir:" $CONFIG | awk '{print $2}' | tr -d '"')

if check_dir "$MANTA_DIR" "Manta directory"; then
    MANTA_COUNT=$(ls "$MANTA_DIR"/*.vcf* 2>/dev/null | wc -l)
    echo -e "  Found ${GREEN}${MANTA_COUNT}${NC} Manta VCF files"

    if [ $MANTA_COUNT -eq 0 ]; then
        echo -e "  ${RED}ERROR: No Manta VCFs found!${NC}"
        ((ERRORS++))
    elif [ $MANTA_COUNT -lt 1000 ]; then
        echo -e "  ${YELLOW}WARNING: Expected ~1000 files${NC}"
        ((WARNINGS++))
    fi
fi

echo ""
echo "=== pbsv Long-read SV VCFs ==="
for i in 1 2 3 4; do
    PBSV=$(grep -A5 "pbsv_vcfs:" $CONFIG | grep "Pool${i}" | awk '{print $2}' | tr -d '"')
    check_file "$PBSV" "Pool${i}"
done

echo ""
echo "=== Index Files ==="
# Check if FASTAs are indexed
for ref in "$GRCH38" "$CHM13"; do
    if [ -f "$ref" ]; then
        if [ -f "${ref}.fai" ]; then
            echo -e "${GREEN}✓${NC} Index exists: ${ref}.fai"
        else
            echo -e "${YELLOW}!${NC} Index missing: ${ref}.fai (will be created)"
            ((WARNINGS++))
        fi
    fi
done

echo ""
echo "======================================="
echo "Summary"
echo "======================================="
echo -e "Errors: ${RED}${ERRORS}${NC}"
echo -e "Warnings: ${YELLOW}${WARNINGS}${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}VALIDATION FAILED${NC}"
    echo "Please fix the errors above before running the pipeline."
    exit 1
else
    echo -e "${GREEN}VALIDATION PASSED${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo "Pipeline can run, but check warnings above."
    else
        echo "All inputs are ready!"
    fi
    echo ""
    echo "Next steps:"
    echo "  1. Dry run: snakemake -n --cores 1"
    echo "  2. Run pipeline: snakemake --profile profiles/slurm --use-conda"
    exit 0
fi
