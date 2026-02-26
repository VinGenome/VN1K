#!/usr/bin/env python3
"""
Verify if SVs are actually present in the pangenome graph structure.

This script checks if SVs that were not called by graph-based methods
are actually missing from the graph structure by:
1. Checking if the SV region has alternative paths in the graph
2. Examining graph complexity at the SV location
3. Comparing with the SV catalog used to build the graph

Usage:
    python verify_sv_in_graph.py \
        --linear-only-vcf <linear_only_svs.vcf> \
        --graph-dir <path/to/graph/dir> \
        --catalog <sv_catalog.vcf.gz> \
        --reference <reference.fa> \
        --output <verification_report.txt>
"""

import argparse
import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Tuple
import gzip


def parse_vcf_positions(vcf_path: str, limit: int = None) -> List[Dict]:
    """Parse VCF to get SV positions"""
    svs = []
    opener = gzip.open if vcf_path.endswith('.gz') else open

    with opener(vcf_path, 'rt') as f:
        for line in f:
            if line.startswith('#'):
                continue

            fields = line.strip().split('\t')
            chrom = fields[0]
            pos = int(fields[1])
            sv_id = fields[2]
            info = fields[7]

            # Parse END and SVTYPE
            info_dict = {}
            for item in info.split(';'):
                if '=' in item:
                    key, value = item.split('=', 1)
                    info_dict[key] = value

            end = int(info_dict.get('END', pos))
            svtype = info_dict.get('SVTYPE', 'UNK')
            svlen = info_dict.get('SVLEN', '0')

            svs.append({
                'chrom': chrom,
                'pos': pos,
                'end': end,
                'id': sv_id,
                'svtype': svtype,
                'svlen': svlen,
                'line': line.strip()
            })

            if limit and len(svs) >= limit:
                break

    return svs


def check_graph_region_complexity(graph_xg: str, chrom: str, start: int, end: int) -> Dict:
    """
    Check graph complexity at a specific region using vg stats.
    Returns metrics about nodes, edges, and paths in the region.
    """
    result = {
        'has_variation': False,
        'num_nodes': 0,
        'num_edges': 0,
        'num_paths': 0,
        'error': None
    }

    try:
        # Extract subgraph for this region
        cmd = [
            'vg', 'find',
            '-x', graph_xg,
            '-p', f"{chrom}:{start}-{end}",
            '-c', '100'  # context
        ]

        extract_result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=60
        )

        if extract_result.returncode != 0:
            result['error'] = f"vg find failed: {extract_result.stderr[:200]}"
            return result

        subgraph_vg = extract_result.stdout

        if not subgraph_vg.strip():
            result['error'] = "Empty subgraph - region not found in graph"
            return result

        # Get stats on the subgraph
        stats_cmd = ['vg', 'stats', '-lz', '-']
        stats_result = subprocess.run(
            stats_cmd,
            input=subgraph_vg,
            capture_output=True,
            text=True,
            timeout=30
        )

        if stats_result.returncode == 0:
            # Parse stats output
            stats_lines = stats_result.stdout.strip().split('\n')
            for line in stats_lines:
                if 'nodes' in line.lower():
                    try:
                        result['num_nodes'] = int(line.split()[0])
                    except:
                        pass
                elif 'edges' in line.lower():
                    try:
                        result['num_edges'] = int(line.split()[0])
                    except:
                        pass
                elif 'paths' in line.lower():
                    try:
                        result['num_paths'] = int(line.split()[0])
                    except:
                        pass

            # If we have edges and multiple nodes, there's variation
            if result['num_nodes'] > 1 and result['num_edges'] > result['num_nodes']:
                result['has_variation'] = True

    except subprocess.TimeoutExpired:
        result['error'] = "Timeout checking graph region"
    except Exception as e:
        result['error'] = f"Error: {str(e)}"

    return result


def check_sv_in_catalog(sv: Dict, catalog_vcf: str, max_distance: int = 500) -> Tuple[bool, str]:
    """Check if SV exists in catalog"""
    # Simple grep-based search for quick check
    chrom = sv['chrom']
    pos = sv['pos']
    svtype = sv['svtype']

    # Search in catalog
    try:
        if catalog_vcf.endswith('.gz'):
            cmd = ['zgrep', '-v', '^#', catalog_vcf]
        else:
            cmd = ['grep', '-v', '^#', catalog_vcf]

        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)

        # Look for nearby SVs of same type
        for line in result.stdout.split('\n'):
            if not line:
                continue
            fields = line.split('\t')
            if fields[0] != chrom:
                continue

            cat_pos = int(fields[1])
            if abs(cat_pos - pos) <= max_distance:
                info = fields[7]
                if svtype in info or f"SVTYPE={svtype}" in info:
                    return True, f"Found in catalog at {chrom}:{cat_pos}"

        return False, "Not found in catalog"

    except Exception as e:
        return False, f"Error checking catalog: {str(e)}"


def main():
    parser = argparse.ArgumentParser(
        description="Verify if SVs are present in pangenome graph structure"
    )
    parser.add_argument('--linear-only-vcf', required=True,
                        help='VCF with SVs only found in linear alignment')
    parser.add_argument('--graph-xg', required=True,
                        help='Path to graph XG index (e.g., graph.xg)')
    parser.add_argument('--catalog', required=True,
                        help='SV catalog VCF used to build graph')
    parser.add_argument('--output', required=True,
                        help='Output verification report')
    parser.add_argument('--sample-size', type=int, default=20,
                        help='Number of SVs to sample for detailed verification (default: 20)')

    args = parser.parse_args()

    # Check if vg is available
    try:
        subprocess.run(['vg', 'version'], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("ERROR: 'vg' command not found. Please ensure vg toolkit is installed.")
        sys.exit(1)

    # Parse linear-only SVs
    print(f"Loading SVs from {args.linear_only_vcf}...")
    linear_only_svs = parse_vcf_positions(args.linear_only_vcf, limit=args.sample_size)
    print(f"Loaded {len(linear_only_svs)} SVs for verification")

    # Verify each SV
    results = []
    print(f"\nVerifying SVs in graph structure...")

    for i, sv in enumerate(linear_only_svs, 1):
        print(f"  [{i}/{len(linear_only_svs)}] Checking {sv['id']} at {sv['chrom']}:{sv['pos']}-{sv['end']}...")

        # Check if in catalog
        in_catalog, catalog_msg = check_sv_in_catalog(sv, args.catalog)

        # Check graph region complexity
        graph_info = check_graph_region_complexity(
            args.graph_xg,
            sv['chrom'],
            sv['pos'],
            sv['end']
        )

        results.append({
            'sv': sv,
            'in_catalog': in_catalog,
            'catalog_msg': catalog_msg,
            'graph_info': graph_info
        })

    # Write report
    print(f"\nWriting report to {args.output}...")
    with open(args.output, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("SV VERIFICATION REPORT: Checking if SVs exist in Graph Structure\n")
        f.write("=" * 80 + "\n\n")

        f.write(f"Total SVs verified: {len(results)}\n\n")

        # Summary statistics
        in_catalog_count = sum(1 for r in results if r['in_catalog'])
        has_variation_count = sum(1 for r in results if r['graph_info']['has_variation'])

        f.write("-" * 80 + "\n")
        f.write("SUMMARY\n")
        f.write("-" * 80 + "\n\n")
        f.write(f"SVs found in catalog:              {in_catalog_count} / {len(results)} ({100*in_catalog_count/len(results):.1f}%)\n")
        f.write(f"SVs with graph variation present:  {has_variation_count} / {len(results)} ({100*has_variation_count/len(results):.1f}%)\n\n")

        f.write("Interpretation:\n")
        f.write("  - 'In catalog' = SV location is in the catalog used to build graph\n")
        f.write("  - 'Graph variation' = Graph has alternative paths/bubbles at this location\n")
        f.write("  - If 'In catalog' but no 'Graph variation' = SV may not have been properly integrated\n")
        f.write("  - If not 'In catalog' and no 'Graph variation' = SV is completely missing from graph\n\n")

        # Detailed results
        f.write("-" * 80 + "\n")
        f.write("DETAILED VERIFICATION RESULTS\n")
        f.write("-" * 80 + "\n\n")

        for i, result in enumerate(results, 1):
            sv = result['sv']
            f.write(f"{i}. {sv['id']} - {sv['chrom']}:{sv['pos']}-{sv['end']} ({sv['svtype']}, len={sv['svlen']})\n")
            f.write(f"   In catalog: {'YES' if result['in_catalog'] else 'NO'} - {result['catalog_msg']}\n")

            graph_info = result['graph_info']
            if graph_info['error']:
                f.write(f"   Graph check: ERROR - {graph_info['error']}\n")
            else:
                f.write(f"   Graph region: {graph_info['num_nodes']} nodes, {graph_info['num_edges']} edges, {graph_info['num_paths']} paths\n")
                f.write(f"   Has variation: {'YES' if graph_info['has_variation'] else 'NO'}\n")

            f.write("\n")

    print(f"Report written to {args.output}")
    print("\n" + "=" * 60)
    print("VERIFICATION COMPLETE")
    print("=" * 60)
    print(f"SVs in catalog: {in_catalog_count}/{len(results)}")
    print(f"SVs with graph variation: {has_variation_count}/{len(results)}")


if __name__ == '__main__':
    main()
