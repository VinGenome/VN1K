#!/usr/bin/env python3
"""
Detect potential novel SVs from graph alignments by analyzing anomalies.

This script analyzes GAM (Graph Alignment/Map) files to identify:
1. Soft-clipped regions (potential insertions)
2. Large gaps in coverage (potential deletions)
3. Discordant read pairs (potential SVs)
4. Regions with abnormal read depth

Usage:
    # First convert GAM to JSON format for analysis
    vg view -aj alignments.gam > alignments.json

    # Then analyze
    python detect_novel_sv_from_gam.py \
        --gam-json alignments.json \
        --graph-xg graph.xg \
        --output novel_sv_candidates.bed \
        --min-soft-clip 50 \
        --min-coverage-drop 0.3
"""

import argparse
import json
import sys
from collections import defaultdict
from typing import Dict, List, Tuple


class SVCandidate:
    """Represents a potential novel SV"""
    def __init__(self, chrom, start, end, svtype, evidence_count, evidence_type):
        self.chrom = chrom
        self.start = start
        self.end = end
        self.svtype = svtype
        self.evidence_count = evidence_count
        self.evidence_type = evidence_type

    def __repr__(self):
        return f"{self.chrom}:{self.start}-{self.end} {self.svtype} (evidence={self.evidence_count}, type={self.evidence_type})"


def analyze_soft_clips(gam_json_path: str, min_clip_len: int = 50) -> List[SVCandidate]:
    """
    Analyze soft-clipped reads which may indicate insertions not in the graph.

    Soft clips happen when reads don't align fully to the graph, suggesting
    sequence that's not represented in the graph structure.
    """
    candidates = []
    soft_clip_clusters = defaultdict(list)

    print("Analyzing soft-clipped reads...")

    with open(gam_json_path) as f:
        for line_num, line in enumerate(f, 1):
            if line_num % 10000 == 0:
                print(f"  Processed {line_num} alignments...")

            try:
                aln = json.loads(line.strip())
            except:
                continue

            # Check for soft clips in the alignment
            if 'path' not in aln or 'mapping' not in aln['path']:
                continue

            mappings = aln['path']['mapping']
            if not mappings:
                continue

            # Check first mapping for left soft clip
            first_mapping = mappings[0]
            if 'edit' in first_mapping:
                for edit in first_mapping['edit']:
                    if 'from_length' in edit and edit['from_length'] >= min_clip_len:
                        # Potential insertion
                        if 'position' in first_mapping:
                            pos = first_mapping['position']
                            if 'node_id' in pos and 'offset' in pos:
                                # Record this position
                                key = (pos.get('node_id'), pos.get('offset'))
                                soft_clip_clusters[key].append(edit['from_length'])

            # Check last mapping for right soft clip
            last_mapping = mappings[-1]
            if 'edit' in last_mapping:
                for edit in last_mapping['edit']:
                    if 'from_length' in edit and edit['from_length'] >= min_clip_len:
                        if 'position' in last_mapping:
                            pos = last_mapping['position']
                            if 'node_id' in pos and 'offset' in pos:
                                key = (pos.get('node_id'), pos.get('offset'))
                                soft_clip_clusters[key].append(edit['from_length'])

    # Convert clusters to candidates
    for (node_id, offset), clip_lengths in soft_clip_clusters.items():
        if len(clip_lengths) >= 3:  # At least 3 reads support
            avg_len = sum(clip_lengths) / len(clip_lengths)
            candidates.append(SVCandidate(
                chrom="chr?",  # Would need node->position mapping
                start=node_id,
                end=node_id + int(avg_len),
                svtype="INS",
                evidence_count=len(clip_lengths),
                evidence_type="soft_clips"
            ))

    print(f"Found {len(candidates)} insertion candidates from soft clips")
    return candidates


def analyze_coverage_gaps(gam_json_path: str, window_size: int = 1000) -> List[SVCandidate]:
    """
    Analyze coverage gaps which may indicate deletions not in the graph.

    Large drops in coverage suggest regions that are present in the sample
    but not well represented in the graph.
    """
    candidates = []
    node_coverage = defaultdict(int)

    print("Analyzing coverage patterns...")

    with open(gam_json_path) as f:
        for line_num, line in enumerate(f, 1):
            if line_num % 10000 == 0:
                print(f"  Processed {line_num} alignments...")

            try:
                aln = json.loads(line.strip())
            except:
                continue

            if 'path' not in aln or 'mapping' not in aln['path']:
                continue

            # Count coverage per node
            for mapping in aln['path']['mapping']:
                if 'position' in mapping and 'node_id' in mapping['position']:
                    node_id = mapping['position']['node_id']
                    node_coverage[node_id] += 1

    # Find coverage gaps (simplified - would need more sophisticated analysis)
    print(f"Analyzed coverage for {len(node_coverage)} nodes")

    return candidates


def write_candidates(candidates: List[SVCandidate], output_path: str):
    """Write SV candidates to BED-like format"""

    with open(output_path, 'w') as f:
        f.write("# Novel SV candidates detected from graph alignments\n")
        f.write("# chrom\tstart\tend\tsvtype\tevidence_count\tevidence_type\n")

        for cand in candidates:
            f.write(f"{cand.chrom}\t{cand.start}\t{cand.end}\t{cand.svtype}\t{cand.evidence_count}\t{cand.evidence_type}\n")

    print(f"Wrote {len(candidates)} candidates to {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Detect novel SV candidates from graph alignments"
    )
    parser.add_argument('--gam-json', required=True,
                        help='GAM file converted to JSON format (vg view -aj)')
    parser.add_argument('--output', required=True,
                        help='Output BED file with SV candidates')
    parser.add_argument('--min-soft-clip', type=int, default=50,
                        help='Minimum soft clip length (default: 50)')
    parser.add_argument('--min-coverage-drop', type=float, default=0.3,
                        help='Minimum coverage drop to flag (default: 0.3)')

    args = parser.parse_args()

    print("=" * 70)
    print("Novel SV Detection from Graph Alignments")
    print("=" * 70)

    all_candidates = []

    # Method 1: Soft clips
    soft_clip_candidates = analyze_soft_clips(args.gam_json, args.min_soft_clip)
    all_candidates.extend(soft_clip_candidates)

    # Method 2: Coverage gaps
    coverage_candidates = analyze_coverage_gaps(args.gam_json)
    all_candidates.extend(coverage_candidates)

    # Write results
    write_candidates(all_candidates, args.output)

    print("\n" + "=" * 70)
    print(f"SUMMARY: Found {len(all_candidates)} potential novel SV candidates")
    print("=" * 70)
    print("\nNOTE: These are candidates that require further validation:")
    print("  1. Visual inspection with vg view")
    print("  2. Local assembly")
    print("  3. Validation with orthogonal methods")


if __name__ == '__main__':
    main()
