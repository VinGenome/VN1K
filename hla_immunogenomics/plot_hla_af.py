"""Plot allele frequency (AF) for all HLA classes, sorted top to bottom (highest first)."""
import csv
from collections import Counter
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

BASE = Path(__file__).resolve().parent
CSV_PATH = BASE / "VN1k_1015.HISAT_result.csv"
SAMPLE_IDS_PATH = BASE / "sample_ids.txt"
OUT_PATH = BASE / "HLA_AF_plot.png"
OUT_SOURCE_CSV = BASE / "source_data_hla_af_plot.csv"

def two_field(allele_str):
    if not allele_str or not str(allele_str).strip():
        return None
    s = str(allele_str).strip()
    parts = s.replace("G", "").split(":")
    if len(parts) >= 2:
        return ":".join(parts[:2])
    return s.split(":")[0] if parts else None

def main():
    # Load sample IDs to keep (skip header line)
    with open(SAMPLE_IDS_PATH, encoding="utf-8") as f:
        lines = [ln.strip() for ln in f if ln.strip()]
    sample_id_set = set(lines[1:]) if lines and lines[0].lower() == "sample_id" else set(lines)

    with open(CSV_PATH, newline="", encoding="utf-8") as f:
        all_rows = list(csv.DictReader(f))
    # First column is sample ID (key is '' when header is ",A_1,...")
    sample_id_key = next(iter(all_rows[0].keys())) if all_rows else ""
    rows = [r for r in all_rows if (r.get(sample_id_key) or "").strip() in sample_id_set]
    n_samples = len(rows)

    gene_cols = {
        "A": ("A_1", "A_2"),
        "B": ("B_1", "B_2"),
        "C": ("C_1", "C_2"),
        "DRB1": ("DRB1_1", "DRB1_2"),
        "DQB1": ("DQB1_1", "DQB1_2"),
        "DQA1": ("DQA1_1", "DQA1_2"),
        "DPB1": ("DPB1_1", "DPB1_2"),
        "DPA1": ("DPA1_1", "DPA1_2"),
    }

    # Collect AF per allele per gene (sorted descending)
    data = {}
    source_rows = []
    for gene, (c1, c2) in gene_cols.items():
        alleles = []
        for r in rows:
            for col in (c1, c2):
                a = two_field(r.get(col, ""))
                if a:
                    alleles.append(a)
        total = len(alleles)
        cnt = Counter(alleles)
        # sort by count descending (top = highest AF); keep only top 30 per class
        sorted_alleles_all = sorted(cnt.items(), key=lambda x: -x[1])
        sorted_alleles = sorted_alleles_all[:30]
        labels = [a for a, _ in sorted_alleles]
        af_pct = [100.0 * c / total for _, c in sorted_alleles]
        data[gene] = (labels, af_pct, total)
        for rank, (allele, count) in enumerate(sorted_alleles_all, start=1):
            source_rows.append(
                {
                    "gene": gene,
                    "rank": rank,
                    "allele": f"{gene}*{allele}",
                    "allele_count": count,
                    "total_alleles_for_gene": total,
                    "af_percent": 100.0 * count / total if total else 0.0,
                    "is_top30_plotted": rank <= 30,
                    "n_samples": n_samples,
                }
            )

    with open(OUT_SOURCE_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "gene",
                "rank",
                "allele",
                "allele_count",
                "total_alleles_for_gene",
                "af_percent",
                "is_top30_plotted",
                "n_samples",
            ]
        )
        for row in source_rows:
            w.writerow(
                [
                    row["gene"],
                    row["rank"],
                    row["allele"],
                    row["allele_count"],
                    row["total_alleles_for_gene"],
                    f"{row['af_percent']:.8g}",
                    int(row["is_top30_plotted"]),
                    row["n_samples"],
                ]
            )
    print(f"Saved: {OUT_SOURCE_CSV}")

    # Plot: 2 rows x 4 cols (A,B,C,DRB1 | DQB1,DQA1,DPB1,DPA1)
    fig, axes = plt.subplots(2, 4, figsize=(16, 10))
    axes = axes.flatten()
    genes = list(gene_cols.keys())

    for idx, gene in enumerate(genes):
        ax = axes[idx]
        labels, af_pct, total = data[gene]
        n_bars = len(labels)
        y_pos = np.arange(n_bars)[::-1]  # top = index 0 (highest AF)
        bars = ax.barh(y_pos, af_pct, height=0.7, color="steelblue", edgecolor="navy", alpha=0.85)
        ax.set_yticks(y_pos)
        ax.set_yticklabels(labels, fontsize=7)
        ax.set_xlabel("Allele frequency (%)", fontsize=9)
        ax.set_title(f"HLA-{gene} (n={n_samples}, 2N={total})", fontsize=10)
        # Class I (A, B, C): fixed x-axis 0-25%; others: auto
        if gene in ("A", "B", "C"):
            ax.set_xlim(0, 25)
        else:
            ax.set_xlim(0, max(af_pct) * 1.15 if af_pct else 1)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)

    plt.suptitle("VN1k HISAT HLA allele frequencies, sorted by AF (top = highest)", fontsize=12, y=1.02)
    plt.tight_layout()
    plt.savefig(OUT_PATH, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"Saved: {OUT_PATH}")

    # B*15:02 stats for this filtered cohort (for manuscript text)
    b_alleles = []
    n_carriers_b1502 = 0
    for r in rows:
        a1 = two_field(r.get("B_1", ""))
        a2 = two_field(r.get("B_2", ""))
        if a1:
            b_alleles.append(a1)
        if a2:
            b_alleles.append(a2)
        if a1 == "15:02" or a2 == "15:02":
            n_carriers_b1502 += 1
    total_b = len(b_alleles)
    count_b1502 = sum(1 for a in b_alleles if a == "15:02")
    af_b1502 = 100.0 * count_b1502 / total_b if total_b else 0
    carrier_freq_b1502 = 100.0 * n_carriers_b1502 / n_samples if n_samples else 0
    print(f"\nB*15:02 (n={n_samples} samples): AF = {af_b1502:.2f}% ({count_b1502}/{total_b}), carrier = {carrier_freq_b1502:.2f}% ({n_carriers_b1502}/{n_samples})")

if __name__ == "__main__":
    main()
