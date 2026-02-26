#!/bin/bash
# Quick script to check SV coverage in graph catalog
#
# Usage:
#   ./run_sv_coverage_check.sh <sample> <chrom> <caller>
#
# Example:
#   ./run_sv_coverage_check.sh HG02059 chr22 sniffles
#   ./run_sv_coverage_check.sh HG02080 chr22 manta

set -e

SAMPLE=${1:-"HG02059"}
CHROM=${2:-"chr22"}
CALLER=${3:-"sniffles"}  # sniffles, manta, or cutesv

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="${BASE_DIR}/results"
VARIANTS_DIR="${RESULTS_DIR}/called_variants"
SV_MERGE_DIR="${RESULTS_DIR}/sv_merge"

echo "=============================================="
echo "SV Coverage Analysis"
echo "=============================================="
echo "Sample: ${SAMPLE}"
echo "Chromosome: ${CHROM}"
echo "Caller: ${CALLER}"
echo ""

# Set paths based on caller
case $CALLER in
    "manta")
        LINEAR_SV="${VARIANTS_DIR}/manta/linear_sr/${SAMPLE}/${CHROM}.sv.pass.vcf.gz"
        GRAPH_SV="${VARIANTS_DIR}/manta/graph_sr/${SAMPLE}/${CHROM}.sv.pass.vcf.gz"
        ;;
    "sniffles")
        LINEAR_SV="${VARIANTS_DIR}/sniffles/linear_lr/${SAMPLE}/${CHROM}.sv.pass.vcf.gz"
        GRAPH_SV="${VARIANTS_DIR}/sniffles/graph_lr/${SAMPLE}/${CHROM}.sv.pass.vcf.gz"
        ;;
    "cutesv")
        LINEAR_SV="${VARIANTS_DIR}/cutesv/linear_lr/${SAMPLE}/${CHROM}.sv.pass.vcf.gz"
        GRAPH_SV="${VARIANTS_DIR}/cutesv/pbmm2_lr/${SAMPLE}/${CHROM}.sv.pass.vcf.gz"
        ;;
    *)
        echo "Unknown caller: ${CALLER}"
        echo "Supported: manta, sniffles, cutesv"
        exit 1
        ;;
esac

CATALOG="${SV_MERGE_DIR}/${CHROM}/final_sv_merged.vcf.gz"
OUTPUT_DIR="${VARIANTS_DIR}/sv_coverage_analysis/${CALLER}/${SAMPLE}"
OUTPUT_REPORT="${OUTPUT_DIR}/${CHROM}.coverage_report.txt"

# Check input files exist
echo "Checking input files..."
for f in "$LINEAR_SV" "$GRAPH_SV" "$CATALOG"; do
    if [[ ! -f "$f" ]]; then
        echo "ERROR: File not found: $f"
        exit 1
    fi
done
echo "All input files found."
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run analysis
echo "Running analysis..."
python "${SCRIPT_DIR}/check_sv_coverage_in_graph.py" \
    --linear-sv "$LINEAR_SV" \
    --graph-sv "$GRAPH_SV" \
    --graph-sv-catalog "$CATALOG" \
    --output "$OUTPUT_REPORT" \
    --max-distance 500 \
    --chrom "$CHROM" \
    --output-linear-only-vcf "${OUTPUT_DIR}/${CHROM}.linear_only_not_in_catalog.vcf"

echo ""
echo "=============================================="
echo "Results written to: ${OUTPUT_REPORT}"
echo "=============================================="
echo ""

# Print summary
echo "Quick Summary:"
echo "--------------"
grep -A 20 "^SUMMARY" "$OUTPUT_REPORT" | head -25
