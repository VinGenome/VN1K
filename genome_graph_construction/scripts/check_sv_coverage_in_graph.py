#!/usr/bin/env python3
"""
Check if SVs called by linear alignment but not by graph alignment
are due to missing SV sites in the pangenome graph.

This script:
1. Compares SVs from linear vs graph-based calling
2. Identifies SVs unique to linear alignment
3. Checks if these SVs overlap with the SV catalog used to build the graph
4. Reports statistics on coverage gaps

Usage:
    python check_sv_coverage_in_graph.py \
        --linear-sv <linear_sv.vcf.gz> \
        --graph-sv <graph_sv.vcf.gz> \
        --graph-sv-catalog <merged_sv_catalog.vcf.gz> \
        --output <output_report.txt> \
        [--max-distance 500] \
        [--chrom chr22]
"""

import argparse
import gzip
import sys
from collections import defaultdict
from dataclasses import dataclass
from typing import List, Dict, Tuple, Optional


@dataclass
class SVRecord:
    """Simple SV record"""
    chrom: str
    pos: int
    end: int
    svtype: str
    svlen: int
    id: str
    line: str

    def __repr__(self):
        return f"{self.chrom}:{self.pos}-{self.end} {self.svtype} len={self.svlen}"


def parse_vcf_sv(vcf_path: str, chrom_filter: Optional[str] = None) -> List[SVRecord]:
    """Parse SV records from VCF file"""
    records = []

    opener = gzip.open if vcf_path.endswith('.gz') else open

    with opener(vcf_path, 'rt') as f:
        for line in f:
            if line.startswith('#'):
                continue

            fields = line.strip().split('\t')
            if len(fields) < 8:
                continue

            chrom = fields[0]
            if chrom_filter and chrom != chrom_filter:
                continue

            pos = int(fields[1])
            sv_id = fields[2]
            ref = fields[3]
            alt = fields[4]
            info = fields[7]

            # Parse INFO field
            info_dict = {}
            for item in info.split(';'):
                if '=' in item:
                    key, value = item.split('=', 1)
                    info_dict[key] = value
                else:
                    info_dict[item] = True

            # Get SV type
            svtype = info_dict.get('SVTYPE', '')
            if not svtype:
                # Try to infer from ALT
                if alt.startswith('<'):
                    svtype = alt.strip('<>').split(':')[0]
                elif len(alt) > len(ref):
                    svtype = 'INS'
                elif len(ref) > len(alt):
                    svtype = 'DEL'
                else:
                    continue

            # Get SV length
            svlen = 0
            if 'SVLEN' in info_dict:
                try:
                    svlen = abs(int(info_dict['SVLEN'].split(',')[0]))
                except:
                    pass

            # Get END position
            end = pos
            if 'END' in info_dict:
                try:
                    end = int(info_dict['END'])
                except:
                    pass

            if end == pos and svlen > 0:
                end = pos + svlen

            # Skip very small variants (not really SVs)
            if svlen < 50 and svtype in ['DEL', 'INS', 'DUP']:
                continue

            records.append(SVRecord(
                chrom=chrom,
                pos=pos,
                end=end,
                svtype=svtype,
                svlen=svlen,
                id=sv_id,
                line=line.strip()
            ))

    return records


def svs_overlap(sv1: SVRecord, sv2: SVRecord, max_distance: int = 500) -> bool:
    """Check if two SVs overlap within max_distance"""
    if sv1.chrom != sv2.chrom:
        return False

    # Check if same type (or compatible types)
    type_compatible = (
        sv1.svtype == sv2.svtype or
        {sv1.svtype, sv2.svtype} <= {'DEL', 'DEL:ME', 'DEL:ME:ALU'} or
        {sv1.svtype, sv2.svtype} <= {'INS', 'INS:ME', 'INS:ME:ALU'} or
        {sv1.svtype, sv2.svtype} <= {'DUP', 'DUP:TANDEM'}
    )

    if not type_compatible:
        return False

    # Check position overlap with tolerance
    pos_close = abs(sv1.pos - sv2.pos) <= max_distance
    end_close = abs(sv1.end - sv2.end) <= max_distance

    # Check size similarity (within 50% or 500bp)
    if sv1.svlen > 0 and sv2.svlen > 0:
        size_ratio = min(sv1.svlen, sv2.svlen) / max(sv1.svlen, sv2.svlen)
        size_diff = abs(sv1.svlen - sv2.svlen)
        size_similar = size_ratio > 0.5 or size_diff < 500
    else:
        size_similar = True

    return pos_close and (end_close or size_similar)


def find_matching_sv(sv: SVRecord, sv_list: List[SVRecord], max_distance: int = 500) -> Optional[SVRecord]:
    """Find a matching SV in the list"""
    for candidate in sv_list:
        if svs_overlap(sv, candidate, max_distance):
            return candidate
    return None


def analyze_sv_coverage(
    linear_svs: List[SVRecord],
    graph_svs: List[SVRecord],
    catalog_svs: List[SVRecord],
    max_distance: int = 500
) -> Dict:
    """Analyze SV coverage between linear, graph, and catalog"""

    results = {
        'total_linear': len(linear_svs),
        'total_graph': len(graph_svs),
        'total_catalog': len(catalog_svs),
        'linear_only': [],           # SVs in linear but not in graph
        'graph_only': [],            # SVs in graph but not in linear
        'both': [],                  # SVs in both
        'linear_only_in_catalog': [],    # Linear-only SVs that ARE in catalog
        'linear_only_not_in_catalog': [], # Linear-only SVs NOT in catalog
        'by_type': defaultdict(lambda: {
            'linear_only': 0,
            'in_catalog': 0,
            'not_in_catalog': 0
        })
    }

    # Find SVs unique to linear (not in graph)
    for sv in linear_svs:
        match = find_matching_sv(sv, graph_svs, max_distance)
        if match:
            results['both'].append((sv, match))
        else:
            results['linear_only'].append(sv)

    # Find SVs unique to graph (not in linear)
    for sv in graph_svs:
        match = find_matching_sv(sv, linear_svs, max_distance)
        if not match:
            results['graph_only'].append(sv)

    # Check if linear-only SVs are in the catalog
    for sv in results['linear_only']:
        catalog_match = find_matching_sv(sv, catalog_svs, max_distance)
        if catalog_match:
            results['linear_only_in_catalog'].append((sv, catalog_match))
            results['by_type'][sv.svtype]['in_catalog'] += 1
        else:
            results['linear_only_not_in_catalog'].append(sv)
            results['by_type'][sv.svtype]['not_in_catalog'] += 1
        results['by_type'][sv.svtype]['linear_only'] += 1

    return results


def write_report(results: Dict, output_path: str, args):
    """Write analysis report"""

    with open(output_path, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("SV Coverage Analysis: Linear vs Graph-based Calling\n")
        f.write("=" * 80 + "\n\n")

        f.write(f"Parameters:\n")
        f.write(f"  Linear SV VCF: {args.linear_sv}\n")
        f.write(f"  Graph SV VCF: {args.graph_sv}\n")
        f.write(f"  Graph SV Catalog: {args.graph_sv_catalog}\n")
        f.write(f"  Max distance: {args.max_distance} bp\n")
        if args.chrom:
            f.write(f"  Chromosome filter: {args.chrom}\n")
        f.write("\n")

        f.write("-" * 80 + "\n")
        f.write("SUMMARY\n")
        f.write("-" * 80 + "\n\n")

        f.write(f"Total SVs in linear alignment calls: {results['total_linear']}\n")
        f.write(f"Total SVs in graph alignment calls:  {results['total_graph']}\n")
        f.write(f"Total SVs in graph catalog:          {results['total_catalog']}\n\n")

        f.write(f"SVs found in BOTH linear and graph:  {len(results['both'])}\n")
        f.write(f"SVs found ONLY in linear:            {len(results['linear_only'])}\n")
        f.write(f"SVs found ONLY in graph:             {len(results['graph_only'])}\n\n")

        f.write("-" * 80 + "\n")
        f.write("ANALYSIS OF LINEAR-ONLY SVs\n")
        f.write("-" * 80 + "\n\n")

        in_catalog = len(results['linear_only_in_catalog'])
        not_in_catalog = len(results['linear_only_not_in_catalog'])
        total_linear_only = len(results['linear_only'])

        if total_linear_only > 0:
            pct_in = 100.0 * in_catalog / total_linear_only
            pct_not = 100.0 * not_in_catalog / total_linear_only
        else:
            pct_in = pct_not = 0

        f.write(f"Linear-only SVs that ARE in graph catalog:     {in_catalog:5d} ({pct_in:.1f}%)\n")
        f.write(f"Linear-only SVs that are NOT in graph catalog: {not_in_catalog:5d} ({pct_not:.1f}%)\n\n")

        f.write("Interpretation:\n")
        f.write("  - SVs IN catalog but not called by graph: May be alignment/calling sensitivity issue\n")
        f.write("  - SVs NOT in catalog: These SV sites were never added to the pangenome graph\n")
        f.write("    (not present in Manta merged or pbsv pool data)\n\n")

        f.write("-" * 80 + "\n")
        f.write("BREAKDOWN BY SV TYPE\n")
        f.write("-" * 80 + "\n\n")

        f.write(f"{'SV Type':<12} {'Linear-Only':>12} {'In Catalog':>12} {'Not in Cat':>12} {'% Missing':>12}\n")
        f.write("-" * 60 + "\n")

        for svtype in sorted(results['by_type'].keys()):
            stats = results['by_type'][svtype]
            total = stats['linear_only']
            in_cat = stats['in_catalog']
            not_cat = stats['not_in_catalog']
            pct = 100.0 * not_cat / total if total > 0 else 0
            f.write(f"{svtype:<12} {total:>12} {in_cat:>12} {not_cat:>12} {pct:>11.1f}%\n")

        f.write("\n")

        # Write detailed lists
        f.write("-" * 80 + "\n")
        f.write("LINEAR-ONLY SVs NOT IN GRAPH CATALOG (Novel SVs missed by graph)\n")
        f.write("-" * 80 + "\n\n")

        if results['linear_only_not_in_catalog']:
            f.write(f"Total: {len(results['linear_only_not_in_catalog'])} SVs\n\n")
            for i, sv in enumerate(results['linear_only_not_in_catalog'][:100]):
                f.write(f"{i+1}. {sv}\n")
            if len(results['linear_only_not_in_catalog']) > 100:
                f.write(f"\n... and {len(results['linear_only_not_in_catalog']) - 100} more\n")
        else:
            f.write("None - all linear-only SVs are present in the graph catalog\n")

        f.write("\n")
        f.write("-" * 80 + "\n")
        f.write("LINEAR-ONLY SVs THAT ARE IN GRAPH CATALOG (Graph calling sensitivity issue)\n")
        f.write("-" * 80 + "\n\n")

        if results['linear_only_in_catalog']:
            f.write(f"Total: {len(results['linear_only_in_catalog'])} SVs\n\n")
            for i, (sv, catalog_sv) in enumerate(results['linear_only_in_catalog'][:50]):
                f.write(f"{i+1}. Linear:  {sv}\n")
                f.write(f"   Catalog: {catalog_sv}\n\n")
            if len(results['linear_only_in_catalog']) > 50:
                f.write(f"\n... and {len(results['linear_only_in_catalog']) - 50} more\n")
        else:
            f.write("None\n")

        f.write("\n")

    print(f"Report written to: {output_path}")


def write_vcf_subset(svs: List[SVRecord], output_path: str, header_source: str):
    """Write SVs to a VCF file"""

    opener = gzip.open if header_source.endswith('.gz') else open

    # Get header from source
    header_lines = []
    with opener(header_source, 'rt') as f:
        for line in f:
            if line.startswith('#'):
                header_lines.append(line)
            else:
                break

    with open(output_path, 'w') as f:
        for line in header_lines:
            f.write(line)
        for sv in svs:
            f.write(sv.line + '\n')

    print(f"VCF written to: {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Check if SVs called by linear but not graph are due to missing SV sites in pangenome"
    )
    parser.add_argument('--linear-sv', required=True,
                        help='VCF from linear alignment SV calling (e.g., Manta, Sniffles)')
    parser.add_argument('--graph-sv', required=True,
                        help='VCF from graph-based SV calling or surjected alignment')
    parser.add_argument('--graph-sv-catalog', required=True,
                        help='Merged SV catalog used to build the pangenome graph')
    parser.add_argument('--output', required=True,
                        help='Output report file')
    parser.add_argument('--max-distance', type=int, default=500,
                        help='Max distance for SV matching (default: 500)')
    parser.add_argument('--chrom', default=None,
                        help='Filter to specific chromosome')
    parser.add_argument('--output-linear-only-vcf', default=None,
                        help='Output VCF with linear-only SVs not in catalog')

    args = parser.parse_args()

    print("Loading SVs from linear alignment...")
    linear_svs = parse_vcf_sv(args.linear_sv, args.chrom)
    print(f"  Loaded {len(linear_svs)} SVs")

    print("Loading SVs from graph alignment...")
    graph_svs = parse_vcf_sv(args.graph_sv, args.chrom)
    print(f"  Loaded {len(graph_svs)} SVs")

    print("Loading SVs from graph catalog...")
    catalog_svs = parse_vcf_sv(args.graph_sv_catalog, args.chrom)
    print(f"  Loaded {len(catalog_svs)} SVs")

    print("\nAnalyzing SV coverage...")
    results = analyze_sv_coverage(linear_svs, graph_svs, catalog_svs, args.max_distance)

    print("\nWriting report...")
    write_report(results, args.output, args)

    if args.output_linear_only_vcf and results['linear_only_not_in_catalog']:
        write_vcf_subset(
            results['linear_only_not_in_catalog'],
            args.output_linear_only_vcf,
            args.linear_sv
        )

    # Print summary to stdout
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Linear-only SVs: {len(results['linear_only'])}")
    print(f"  - In catalog (graph sensitivity issue): {len(results['linear_only_in_catalog'])}")
    print(f"  - NOT in catalog (missing from graph):  {len(results['linear_only_not_in_catalog'])}")


if __name__ == '__main__':
    main()
