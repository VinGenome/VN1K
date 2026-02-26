#!/usr/bin/env python3
"""
Merge novel SVs from multiple callers and samples.
Group SVs by location and type, filter by support level.
"""

import sys
import gzip
from collections import defaultdict
from dataclasses import dataclass
from typing import List, Dict, Tuple


@dataclass
class SV:
    chrom: str
    pos: int
    end: int
    svtype: str
    svlen: int
    caller: str
    sample: str
    line: str

    def location_key(self, tolerance=500):
        """Return a key for grouping similar SVs"""
        # Group by chromosome, approximate position, and type
        return (self.chrom, self.pos // tolerance, self.svtype)


def parse_vcf(vcf_path: str, caller: str, sample: str) -> List[SV]:
    """Parse SV records from VCF"""
    svs = []

    opener = gzip.open if vcf_path.endswith('.gz') else open

    with opener(vcf_path, 'rt') as f:
        for line in f:
            if line.startswith('#'):
                continue

            fields = line.strip().split('\t')
            if len(fields) < 8:
                continue

            chrom = fields[0]
            pos = int(fields[1])
            info = fields[7]

            # Parse INFO
            info_dict = {}
            for item in info.split(';'):
                if '=' in item:
                    key, value = item.split('=', 1)
                    info_dict[key] = value

            svtype = info_dict.get('SVTYPE', 'UNK')
            end = int(info_dict.get('END', pos))

            try:
                svlen = abs(int(info_dict.get('SVLEN', '0').split(',')[0]))
            except:
                svlen = end - pos

            svs.append(SV(
                chrom=chrom,
                pos=pos,
                end=end,
                svtype=svtype,
                svlen=svlen,
                caller=caller,
                sample=sample,
                line=line.strip()
            ))

    return svs


def merge_svs(all_svs: List[SV], min_support: int = 2) -> Dict:
    """
    Merge SVs by location and filter by support.

    Returns dict with:
    - 'all': all SVs grouped by location
    - 'high_confidence': SVs with >= min_support
    - 'stats': statistics
    """

    # Group SVs by location
    sv_groups = defaultdict(list)

    for sv in all_svs:
        key = sv.location_key(tolerance=500)
        sv_groups[key].append(sv)

    # Categorize by support
    high_conf = []
    medium_conf = []
    low_conf = []

    for key, svs in sv_groups.items():
        # Count unique callers and samples
        callers = set(sv.caller for sv in svs)
        samples = set(sv.sample for sv in svs)

        support = len(svs)

        if support >= min_support or len(callers) >= 2 or len(samples) >= 2:
            high_conf.append({
                'representative': svs[0],  # Use first as representative
                'support': support,
                'callers': callers,
                'samples': samples,
                'all_svs': svs
            })
        elif support > 1:
            medium_conf.append({
                'representative': svs[0],
                'support': support,
                'callers': callers,
                'samples': samples,
                'all_svs': svs
            })
        else:
            low_conf.append({
                'representative': svs[0],
                'support': 1,
                'callers': callers,
                'samples': samples,
                'all_svs': svs
            })

    return {
        'high_confidence': high_conf,
        'medium_confidence': medium_conf,
        'low_confidence': low_conf,
        'total_groups': len(sv_groups),
        'stats': {
            'high': len(high_conf),
            'medium': len(medium_conf),
            'low': len(low_conf)
        }
    }


def write_vcf(sv_groups: List[Dict], output_path: str, header_source: str):
    """Write merged SVs to VCF"""

    # Get header from source
    opener = gzip.open if header_source.endswith('.gz') else open
    header_lines = []

    with opener(header_source, 'rt') as f:
        for line in f:
            if line.startswith('#'):
                header_lines.append(line)
            else:
                break

    # Add our own INFO fields
    extra_header = [
        '##INFO=<ID=SUPPORT,Number=1,Type=Integer,Description="Number of supporting calls">\n',
        '##INFO=<ID=CALLERS,Number=.,Type=String,Description="List of callers supporting this SV">\n',
        '##INFO=<ID=SAMPLES,Number=.,Type=String,Description="List of samples with this SV">\n'
    ]

    with open(output_path, 'w') as out:
        # Write header
        for line in header_lines[:-1]:  # All except last #CHROM line
            out.write(line)

        # Add extra header
        for line in extra_header:
            out.write(line)

        # Write last header line
        out.write(header_lines[-1])

        # Write SVs
        for group in sv_groups:
            sv = group['representative']

            # Modify INFO field to add support info
            fields = sv.line.split('\t')
            info = fields[7]

            # Add support annotations
            info += f";SUPPORT={group['support']}"
            info += f";CALLERS={','.join(sorted(group['callers']))}"
            info += f";SAMPLES={','.join(sorted(group['samples']))}"

            fields[7] = info

            out.write('\t'.join(fields) + '\n')


def main():
    if len(sys.argv) < 3:
        print("Usage: python merge_novel_svs.py <vcf_list_file> <output_prefix>")
        sys.exit(1)

    vcf_list_file = sys.argv[1]
    output_prefix = sys.argv[2]

    print("="*70)
    print("MERGING NOVEL SVs FROM MULTIPLE CALLERS")
    print("="*70)

    # Read VCF list
    with open(vcf_list_file) as f:
        vcf_paths = [line.strip() for line in f if line.strip()]

    print(f"\nFound {len(vcf_paths)} VCF files to merge\n")

    # Parse all SVs
    all_svs = []

    for vcf_path in vcf_paths:
        # Extract caller and sample from path
        # Path format: .../caller/sample/chr22.linear_only_not_in_catalog.vcf
        parts = vcf_path.split('/')
        caller = parts[-3]
        sample = parts[-2]

        print(f"Loading {caller}/{sample}...")
        svs = parse_vcf(vcf_path, caller, sample)
        print(f"  Loaded {len(svs)} SVs")
        all_svs.extend(svs)

    print(f"\nTotal SVs loaded: {len(all_svs)}")

    # Merge SVs
    print("\nMerging SVs by location and type...")
    merged = merge_svs(all_svs, min_support=2)

    print("\n" + "="*70)
    print("MERGE RESULTS")
    print("="*70)
    print(f"\nTotal SV groups: {merged['total_groups']}")
    print(f"\nBy confidence level:")
    print(f"  High confidence (≥2 support):   {merged['stats']['high']}")
    print(f"  Medium confidence (2 support):  {merged['stats']['medium']}")
    print(f"  Low confidence (1 support):     {merged['stats']['low']}")

    # Analyze by SV type
    print("\nHigh-confidence SVs by type:")
    type_counts = defaultdict(int)
    type_samples = defaultdict(set)

    for group in merged['high_confidence']:
        svtype = group['representative'].svtype
        type_counts[svtype] += 1
        type_samples[svtype].update(group['samples'])

    for svtype in sorted(type_counts.keys()):
        print(f"  {svtype}: {type_counts[svtype]} (in {len(type_samples[svtype])} samples)")

    # Write output files
    print("\nWriting output files...")

    # High confidence
    high_conf_vcf = f"{output_prefix}.high_confidence.vcf"
    write_vcf(merged['high_confidence'], high_conf_vcf, vcf_paths[0])
    print(f"  High confidence: {high_conf_vcf}")

    # All novel SVs
    all_groups = merged['high_confidence'] + merged['medium_confidence'] + merged['low_confidence']
    all_vcf = f"{output_prefix}.all_merged.vcf"
    write_vcf(all_groups, all_vcf, vcf_paths[0])
    print(f"  All merged: {all_vcf}")

    # Write statistics
    stats_file = f"{output_prefix}.merge_stats.txt"
    with open(stats_file, 'w') as f:
        f.write("="*70 + "\n")
        f.write("NOVEL SV MERGE STATISTICS\n")
        f.write("="*70 + "\n\n")

        f.write(f"Input files: {len(vcf_paths)}\n")
        f.write(f"Total SVs: {len(all_svs)}\n")
        f.write(f"Total SV groups: {merged['total_groups']}\n\n")

        f.write("By confidence:\n")
        f.write(f"  High:   {merged['stats']['high']}\n")
        f.write(f"  Medium: {merged['stats']['medium']}\n")
        f.write(f"  Low:    {merged['stats']['low']}\n\n")

        f.write("High-confidence SVs by type:\n")
        for svtype in sorted(type_counts.keys()):
            f.write(f"  {svtype}: {type_counts[svtype]}\n")

        f.write("\n" + "="*70 + "\n")
        f.write("INTERPRETATION\n")
        f.write("="*70 + "\n\n")
        f.write("High confidence SVs:\n")
        f.write("  - Found by ≥2 callers OR in ≥2 samples\n")
        f.write("  - Recommended for adding to catalog\n\n")
        f.write("Medium/Low confidence SVs:\n")
        f.write("  - Found by only 1 caller in 1 sample\n")
        f.write("  - May be false positives or sample-specific\n")
        f.write("  - Recommend additional validation\n\n")

    print(f"  Statistics: {stats_file}")

    print("\n" + "="*70)
    print("MERGE COMPLETE")
    print("="*70)
    print(f"\nRecommended for catalog: {high_conf_vcf}")
    print(f"  ({merged['stats']['high']} high-confidence novel SVs)")


if __name__ == '__main__':
    main()
