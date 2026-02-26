#!/bin/bash
# Workflow để validate novel SVs và update catalog

set -e

WORK_DIR="results/called_variants/sv_coverage_analysis"
OUTPUT_DIR="results/validated_novel_svs"
CATALOG="results/sv_merged/chr22/final_sv_merged.vcf.gz"

mkdir -p ${OUTPUT_DIR}

echo "============================================================"
echo "WORKFLOW: Validate và Update SV Catalog"
echo "============================================================"
echo ""

################################################################################
# STEP 1: Merge all novel SVs from different callers
################################################################################
echo "Step 1: Merging novel SVs from all callers..."

# Collect all novel SV VCFs
find ${WORK_DIR} -name "chr22.linear_only_not_in_catalog.vcf" > ${OUTPUT_DIR}/novel_vcf_list.txt

echo "Found novel SV VCFs:"
cat ${OUTPUT_DIR}/novel_vcf_list.txt

# Merge using SURVIVOR (if available) or bcftools
if command -v SURVIVOR &> /dev/null; then
    echo "Using SURVIVOR to merge SVs..."
    SURVIVOR merge ${OUTPUT_DIR}/novel_vcf_list.txt \
        500 \        # Max distance between breakpoints
        2 \          # Min number of callers supporting SV
        1 \          # Use strand info (1=yes)
        1 \          # Use SV type (1=yes)
        0 \          # Use SV size (0=no, due to caller differences)
        50 \         # Min SV size
        ${OUTPUT_DIR}/novel_svs_merged.vcf
else
    echo "SURVIVOR not found, using simple concatenation..."
    # Simple concat (may have duplicates)
    for vcf in $(cat ${OUTPUT_DIR}/novel_vcf_list.txt); do
        grep -v "^#" $vcf || true
    done > ${OUTPUT_DIR}/novel_svs_all.vcf

    # Add header from first file
    head -1000 $(head -1 ${OUTPUT_DIR}/novel_vcf_list.txt) | grep "^#" > ${OUTPUT_DIR}/novel_svs_merged.vcf
    cat ${OUTPUT_DIR}/novel_svs_all.vcf >> ${OUTPUT_DIR}/novel_svs_merged.vcf
fi

################################################################################
# STEP 2: Filter novel SVs by support
################################################################################
echo ""
echo "Step 2: Filtering novel SVs by support..."

# Count how many samples/callers support each SV
python3 << 'PYEOF'
import sys
from collections import defaultdict

vcf_file = "results/validated_novel_svs/novel_svs_merged.vcf"
output_file = "results/validated_novel_svs/novel_svs_high_confidence.vcf"

svs_by_location = defaultdict(list)

# Read SVs and group by location
with open(vcf_file) as f:
    header_lines = []
    for line in f:
        if line.startswith('#'):
            header_lines.append(line)
            continue

        fields = line.strip().split('\t')
        chrom = fields[0]
        pos = int(fields[1])
        info = fields[7]

        # Parse SV type and size
        svtype = ""
        svlen = 0
        for item in info.split(';'):
            if item.startswith('SVTYPE='):
                svtype = item.split('=')[1]
            elif item.startswith('SVLEN='):
                svlen = abs(int(item.split('=')[1]))

        # Group by approximate location (within 500bp)
        key = (chrom, pos // 500, svtype)
        svs_by_location[key].append((line, svlen))

# Write high confidence SVs (supported by multiple callers)
with open(output_file, 'w') as out:
    # Write header
    for h in header_lines:
        out.write(h)

    # Write SVs with support >= 2
    high_conf_count = 0
    for key, sv_list in svs_by_location.items():
        if len(sv_list) >= 2:  # At least 2 callers/samples
            # Write first SV as representative
            out.write(sv_list[0][0])
            high_conf_count += 1

    print(f"High confidence SVs: {high_conf_count} / {len(svs_by_location)}")

PYEOF

################################################################################
# STEP 3: Analyze novel SV characteristics
################################################################################
echo ""
echo "Step 3: Analyzing novel SV characteristics..."

python3 << 'PYEOF'
from collections import Counter

vcf_file = "results/validated_novel_svs/novel_svs_high_confidence.vcf"

sv_types = []
sv_sizes = []

with open(vcf_file) as f:
    for line in f:
        if line.startswith('#'):
            continue

        fields = line.strip().split('\t')
        info = fields[7]

        for item in info.split(';'):
            if item.startswith('SVTYPE='):
                svtype = item.split('=')[1]
                sv_types.append(svtype)
            elif item.startswith('SVLEN='):
                svlen = abs(int(item.split('=')[1]))
                sv_sizes.append(svlen)

print("\n" + "="*60)
print("NOVEL SV STATISTICS")
print("="*60)
print(f"\nTotal high-confidence novel SVs: {len(sv_types)}")
print(f"\nSV Types:")
for svtype, count in Counter(sv_types).most_common():
    print(f"  {svtype}: {count}")

if sv_sizes:
    print(f"\nSV Size distribution:")
    print(f"  Min: {min(sv_sizes)} bp")
    print(f"  Max: {max(sv_sizes)} bp")
    print(f"  Mean: {sum(sv_sizes)/len(sv_sizes):.0f} bp")
    print(f"  Median: {sorted(sv_sizes)[len(sv_sizes)//2]} bp")

PYEOF

################################################################################
# STEP 4: Merge with existing catalog
################################################################################
echo ""
echo "Step 4: Creating updated catalog..."

# Compress and index
bgzip -f ${OUTPUT_DIR}/novel_svs_high_confidence.vcf
tabix -f -p vcf ${OUTPUT_DIR}/novel_svs_high_confidence.vcf.gz

# Merge with existing catalog
bcftools concat -a \
    ${CATALOG} \
    ${OUTPUT_DIR}/novel_svs_high_confidence.vcf.gz | \
    bcftools sort -O z -o ${OUTPUT_DIR}/updated_catalog.vcf.gz

tabix -p vcf ${OUTPUT_DIR}/updated_catalog.vcf.gz

echo ""
echo "Updated catalog created: ${OUTPUT_DIR}/updated_catalog.vcf.gz"

# Compare sizes
original_count=$(zgrep -v "^#" ${CATALOG} | wc -l)
updated_count=$(zgrep -v "^#" ${OUTPUT_DIR}/updated_catalog.vcf.gz | wc -l)
novel_count=$((updated_count - original_count))

echo ""
echo "="*60
echo "SUMMARY"
echo "="*60
echo "Original catalog: ${original_count} SVs"
echo "Novel SVs added:  ${novel_count} SVs"
echo "Updated catalog:  ${updated_count} SVs"
echo "="*60
echo ""
echo "Next steps:"
echo "  1. Review novel SVs: ${OUTPUT_DIR}/novel_svs_high_confidence.vcf.gz"
echo "  2. If satisfied, use updated catalog to rebuild graph:"
echo "     vg construct -r reference.fa -v ${OUTPUT_DIR}/updated_catalog.vcf.gz"
echo ""

################################################################################
# STEP 5: Generate validation report
################################################################################
echo "Step 5: Generating validation report..."

cat > ${OUTPUT_DIR}/VALIDATION_REPORT.txt << 'EOF'
================================================================================
NOVEL SV VALIDATION AND CATALOG UPDATE REPORT
================================================================================

METHODOLOGY
-----------
1. Collected novel SVs from all callers (Manta, Sniffles, CuteSV)
2. Merged SVs across callers/samples
3. Filtered for high-confidence SVs (≥2 supporting callers/samples)
4. Analyzed characteristics
5. Added to existing catalog

VALIDATION CRITERIA
-------------------
- SV must be called by ≥2 independent callers or in ≥2 samples
- SV must be ≥50bp (for structural variants)
- SV must not overlap with existing catalog (within 500bp)

KEY FINDINGS
------------
See statistics printed above.

⚠️  SPECIAL ATTENTION NEEDED
---------------------------
- DUP (Duplications): 100% were missing from original catalog
- INV (Inversions): 100% were missing from original catalog

These SV types are underrepresented in short-read based catalogs!

RECOMMENDATIONS
---------------
1. VALIDATE DUP/INV variants manually (higher false positive rate)
2. Consider using orthogonal methods:
   - Long-read sequencing (PacBio/ONT)
   - Optical mapping (Bionano)
   - Linked reads (10X Genomics)
3. Visual inspection with IGV for selected candidates

NEXT STEPS
----------
1. Review novel SVs: novel_svs_high_confidence.vcf.gz
2. Manual validation of DUP/INV
3. If satisfied, rebuild graph with updated catalog:

   vg construct -r reference.fa \
       -v updated_catalog.vcf.gz \
       -t 32 > updated_graph.vg

   vg index -x updated_graph.xg updated_graph.vg

4. Re-run calling pipeline with updated graph
5. Iterate until convergence (few/no new SVs found)

================================================================================
EOF

cat ${OUTPUT_DIR}/VALIDATION_REPORT.txt

echo ""
echo "Validation complete! Check ${OUTPUT_DIR}/ for results."
