#!/usr/bin/env python3
"""
Create synthetic contigs containing structural variants for minigraph integration.

This script reads a VCF file containing SVs and generates FASTA sequences
with the variant alleles embedded in flanking reference sequence.

Usage (standalone):
    python create_sv_contigs.py input.vcf.gz reference.fa output.fa --flank 2000

Usage (Snakemake):
    Called automatically via script directive
"""

import sys
import gzip
import argparse
import logging
from pathlib import Path

# Try to import pysam and pyfaidx, fall back to manual parsing if unavailable
try:
    import pysam
    HAS_PYSAM = True
except ImportError:
    HAS_PYSAM = False

try:
    from pyfaidx import Fasta
    HAS_PYFAIDX = True
except ImportError:
    HAS_PYFAIDX = False


def setup_logging(log_file=None):
    """Configure logging"""
    handlers = [logging.StreamHandler(sys.stderr)]
    if log_file:
        handlers.append(logging.FileHandler(log_file))

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=handlers
    )
    return logging.getLogger(__name__)


class SimpleFasta:
    """Simple FASTA reader when pyfaidx is not available"""

    def __init__(self, fasta_path):
        self.sequences = {}
        self._load_fasta(fasta_path)

    def _load_fasta(self, path):
        """Load FASTA file into memory"""
        current_name = None
        current_seq = []

        opener = gzip.open if str(path).endswith('.gz') else open
        with opener(path, 'rt') as f:
            for line in f:
                line = line.strip()
                if line.startswith('>'):
                    if current_name:
                        self.sequences[current_name] = ''.join(current_seq)
                    current_name = line[1:].split()[0]
                    current_seq = []
                else:
                    current_seq.append(line.upper())

            if current_name:
                self.sequences[current_name] = ''.join(current_seq)

    def __getitem__(self, chrom):
        return FastaChrom(self.sequences.get(chrom, ''))


class FastaChrom:
    """Chromosome sequence wrapper"""

    def __init__(self, seq):
        self.seq = seq

    def __getitem__(self, key):
        if isinstance(key, slice):
            start = max(0, key.start) if key.start else 0
            stop = min(len(self.seq), key.stop) if key.stop else len(self.seq)
            return FastaChrom(self.seq[start:stop])
        return self.seq[key]

    def __str__(self):
        return self.seq

    def __len__(self):
        return len(self.seq)


def parse_vcf_line(line):
    """Parse a VCF line and extract SV information"""
    fields = line.strip().split('\t')
    if len(fields) < 8:
        return None

    chrom = fields[0]
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

    svtype = info_dict.get('SVTYPE', 'UNK')
    svlen = info_dict.get('SVLEN', '0')
    end = info_dict.get('END', str(pos + len(ref)))

    # Handle SVLEN which can be negative or a list
    try:
        if ',' in str(svlen):
            svlen = int(svlen.split(',')[0])
        else:
            svlen = int(svlen)
    except ValueError:
        svlen = 0

    try:
        end = int(end)
    except ValueError:
        end = pos + len(ref)

    return {
        'chrom': chrom,
        'pos': pos,
        'id': sv_id,
        'ref': ref,
        'alt': alt,
        'svtype': svtype,
        'svlen': abs(svlen),
        'end': end,
        'info': info_dict
    }


def create_sv_contigs(vcf_path, ref_path, output_path, flank_size=2000, logger=None):
    """
    Create synthetic contigs containing SVs for minigraph integration.

    Args:
        vcf_path: Path to input VCF file (can be gzipped)
        ref_path: Path to reference FASTA file
        output_path: Path to output FASTA file
        flank_size: Size of flanking sequence on each side
        logger: Logger instance
    """
    if logger is None:
        logger = logging.getLogger(__name__)

    # Load reference
    logger.info(f"Loading reference from {ref_path}")
    if HAS_PYFAIDX:
        ref = Fasta(str(ref_path))
    else:
        logger.warning("pyfaidx not available, using simple FASTA parser (slower)")
        ref = SimpleFasta(ref_path)

    # Open VCF
    vcf_path = str(vcf_path)
    if vcf_path.endswith('.gz'):
        vcf_opener = lambda: gzip.open(vcf_path, 'rt')
    else:
        vcf_opener = lambda: open(vcf_path, 'r')

    # Process SVs
    contigs_written = 0
    skipped = {'no_alt': 0, 'symbolic': 0, 'error': 0, 'no_ref_chrom': 0}

    with vcf_opener() as vcf, open(output_path, 'w') as out:
        for line_num, line in enumerate(vcf, 1):
            if line.startswith('#'):
                continue

            try:
                sv = parse_vcf_line(line)
                if sv is None:
                    continue

                chrom = sv['chrom']
                pos = sv['pos'] - 1  # Convert to 0-based
                svtype = sv['svtype']
                alt = sv['alt']
                ref_allele = sv['ref']
                end = sv['end']

                # Skip if chromosome not in reference
                if HAS_PYFAIDX:
                    if chrom not in ref.keys():
                        skipped['no_ref_chrom'] += 1
                        continue
                    chrom_seq = ref[chrom]
                else:
                    if chrom not in ref.sequences:
                        skipped['no_ref_chrom'] += 1
                        continue
                    chrom_seq = ref[chrom]

                # Get flanking sequences
                left_start = max(0, pos - flank_size)
                left_flank = str(chrom_seq[left_start:pos])

                # Handle different SV types
                if alt in ['<DEL>', '<DEL:ME>', '<DEL:ME:ALU>', '<DEL:ME:LINE1>']:
                    # Deletion: skip the deleted region
                    right_start = end
                    right_end = end + flank_size
                    right_flank = str(chrom_seq[right_start:right_end])
                    contig_seq = left_flank + right_flank
                    skipped['symbolic'] += 1  # Count but still process

                elif alt in ['<INS>', '<INS:ME>', '<INS:ME:ALU>', '<INS:ME:LINE1>',
                            '<DUP>', '<DUP:TANDEM>', '<INV>', '<CNV>']:
                    # Symbolic alleles without sequence - skip
                    skipped['symbolic'] += 1
                    continue

                elif alt.startswith('<') or alt == '.':
                    # Other symbolic alleles or missing - skip
                    skipped['symbolic'] += 1
                    continue

                elif alt is None or alt == '':
                    skipped['no_alt'] += 1
                    continue

                else:
                    # Sequence-resolved SV
                    # Position after REF allele
                    ref_end = pos + len(ref_allele)
                    right_end = ref_end + flank_size
                    right_flank = str(chrom_seq[ref_end:right_end])
                    contig_seq = left_flank + alt + right_flank

                # Skip very short contigs
                if len(contig_seq) < flank_size:
                    continue

                # Generate contig name
                sv_id = sv['id'] if sv['id'] != '.' else f"sv_{line_num}"
                contig_name = f"VN_{chrom}_{pos}_{svtype}_{sv_id}"

                # Write contig
                out.write(f">{contig_name}\n")
                # Write sequence in 80-character lines
                for i in range(0, len(contig_seq), 80):
                    out.write(contig_seq[i:i+80] + "\n")

                contigs_written += 1

            except Exception as e:
                logger.warning(f"Error processing line {line_num}: {e}")
                skipped['error'] += 1
                continue

    # Report statistics
    logger.info(f"Contigs written: {contigs_written}")
    logger.info(f"Skipped - no alt: {skipped['no_alt']}")
    logger.info(f"Skipped - symbolic: {skipped['symbolic']}")
    logger.info(f"Skipped - no ref chrom: {skipped['no_ref_chrom']}")
    logger.info(f"Skipped - errors: {skipped['error']}")

    return contigs_written


def main():
    """Main function for standalone usage"""
    parser = argparse.ArgumentParser(
        description='Create synthetic contigs containing SVs for pangenome graph integration'
    )
    parser.add_argument('vcf', help='Input VCF file (can be gzipped)')
    parser.add_argument('ref', help='Reference FASTA file')
    parser.add_argument('output', help='Output FASTA file')
    parser.add_argument('--flank', type=int, default=2000,
                       help='Flanking sequence size (default: 2000)')
    parser.add_argument('--log', help='Log file path')

    args = parser.parse_args()

    logger = setup_logging(args.log)
    logger.info("Starting SV contig generation")
    logger.info(f"Input VCF: {args.vcf}")
    logger.info(f"Reference: {args.ref}")
    logger.info(f"Output: {args.output}")
    logger.info(f"Flank size: {args.flank}")

    create_sv_contigs(args.vcf, args.ref, args.output, args.flank, logger)

    logger.info("Done!")


# Snakemake entry point
if __name__ == "__main__":
    # Check if running under Snakemake
    try:
        snakemake
    except NameError:
        # Running standalone
        main()
    else:
        # Running under Snakemake
        logger = setup_logging(snakemake.log[0] if snakemake.log else None)

        create_sv_contigs(
            vcf_path=snakemake.input.vcf,
            ref_path=snakemake.input.ref,
            output_path=snakemake.output.fasta,
            flank_size=snakemake.params.flank,
            logger=logger
        )
