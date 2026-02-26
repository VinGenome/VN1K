#!/usr/bin/env python3
"""
Annotate VG Giraffe SV calls with SVTYPE and SVLEN fields

VG Giraffe represents structural variants as alternative paths through the pangenome graph,
but doesn't include standard SVTYPE/SVLEN annotations used by other callers like Manta.
This script adds these annotations by comparing REF and ALT allele lengths.
Filters out SVs with |SVLEN| < 50.

Usage:
    python annotate_vg_sv.py input.vcf.gz output.vcf.gz
"""

import sys
import gzip
import argparse
from pathlib import Path

def annotate_vg_sv(input_vcf, output_vcf):
    """
    Annotate VG VCF with SVTYPE and SVLEN fields
    Filter out SVs with |SVLEN| < 50
    """
    filtered_count = 0
    kept_count = 0
    
    with gzip.open(input_vcf, 'rt') as infile, gzip.open(output_vcf, 'wt') as outfile:

        for line in infile:
            if line.startswith('##'):
                # Copy header lines
                outfile.write(line)
                continue

            if line.startswith('#CHROM'):
                # Add INFO headers right before the column header line
                outfile.write('##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">\n')
                outfile.write('##INFO=<ID=SVLEN,Number=1,Type=Integer,Description="Difference in length between REF and ALT alleles">\n')
                # Copy column header
                outfile.write(line)
                continue

            # Parse variant line
            fields = line.strip().split('\t')
            if len(fields) < 8:
                continue  # Skip malformed lines
                
            chrom, pos, id_, ref, alt = fields[0], fields[1], fields[2], fields[3], fields[4]
            qual, filter_, info = fields[5], fields[6], fields[7]

            # Calculate SVLEN
            svlen = len(alt) - len(ref)

            # Filter out SVs with |SVLEN| < 50
            if abs(svlen) < 50:
                filtered_count += 1
                continue

            # Determine SVTYPE
            if svlen < 0:
                svtype = 'DEL'
            elif svlen > 0:
                svtype = 'INS'
            else:
                svtype = 'SUB'  # Substitution or other

            # Add annotations to INFO field
            info_parts = info.split(';') if info != '.' else []

            # Remove existing SVTYPE/SVLEN if present
            info_parts = [part for part in info_parts if not part.startswith('SVTYPE=') and not part.startswith('SVLEN=')]

            # Add new annotations
            info_parts.extend([f'SVTYPE={svtype}', f'SVLEN={svlen}'])

            # Update INFO field
            new_info = ';'.join(info_parts)

            # Write updated line
            new_fields = [chrom, pos, id_, ref, alt, qual, filter_, new_info] + fields[8:]
            outfile.write('\t'.join(new_fields) + '\n')
            kept_count += 1
    
    print(f"Filtered out {filtered_count} variants with |SVLEN| < 50")
    print(f"Kept {kept_count} variants")

def main():
    parser = argparse.ArgumentParser(description='Annotate VG SV calls with SVTYPE and SVLEN')
    parser.add_argument('input_vcf', help='Input VG VCF file (gzipped)')
    parser.add_argument('output_vcf', help='Output annotated VCF file (gzipped)')

    args = parser.parse_args()

    # Check input file exists
    if not Path(args.input_vcf).exists():
        print(f"Error: Input file {args.input_vcf} does not exist")
        sys.exit(1)

    print(f"Annotating {args.input_vcf} -> {args.output_vcf}")
    annotate_vg_sv(args.input_vcf, args.output_vcf)
    print("Done!")

if __name__ == '__main__':
    main()