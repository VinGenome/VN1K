#!/bin/bash
# Call novel SVs from graph alignment using vg augment

GRAPH_VG=$1
GAM_FILE=$2
OUTPUT_PREFIX=$3

echo "Method 1: vg augment - Discover new variants from alignments"
echo "=============================================================="

# Step 1: Augment graph with new variants from reads
echo "Step 1: Augmenting graph with aligned reads..."
vg augment ${GRAPH_VG} ${GAM_FILE} \
    -A augmented.gam \
    -a > ${OUTPUT_PREFIX}.augmented.vg

# Step 2: Extract new variants added by augment
echo "Step 2: Calling variants from augmented graph..."
vg call ${OUTPUT_PREFIX}.augmented.vg \
    -k ${OUTPUT_PREFIX}.augmented.pack \
    -s sample_name \
    -v > ${OUTPUT_PREFIX}.novel_variants.vcf

echo "Novel variants written to: ${OUTPUT_PREFIX}.novel_variants.vcf"
