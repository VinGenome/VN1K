"""
Multi-cohort HLA allele-frequency comparison (scatter).

Panels are ordered HLA-A, HLA-B, HLA-C, then HLA-DQB1, HLA-DRB1, HLA-DPB1; y-axis AF is 0–0.5 on all panels.

Inputs:
  - VN1K: VN1k_1015.HISAT_result.csv (+ optional sample_ids.txt filter)
  - KHV: merged_hisat_hla_99KHV.csv
  - Hanoi_Kinh, Hanoi_Kinh2, HoaBinh_Muong: tab-separated ID / Allele / AF tables
  - VN_Kinh_DQB1: kinh_dqb1.txt
"""
from __future__ import annotations

import csv
from collections import Counter, defaultdict
from pathlib import Path
from typing import Callable, Dict, Iterable, List, Mapping, Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.lines import Line2D

BASE = Path(__file__).resolve().parent

# --- cohort definitions: (legend label, internal id, n_override or None) ---
# n_override is used only when a cohort is summary-only (no per-sample file here).
COHORT_ORDER: List[Tuple[str, str, Optional[int]]] = [
    ("VN1K", "vn1k", None),
    ("99KHV", "khv", None),
    ("Hanoi_Kinh_2", "hanoi_kinh2", 170),
    ("Hanoi_Kinh_1", "hanoi_kinh", 103),
    ("Hoabinh_Muong", "hoabinh_muong", 81),
    ("Vietnam_DQB1", "vn_kinh_dqb1", 2076),
]

# Row-major 2×3: class I first (A, B, C), then class II (DQB1, DRB1, DPB1)
GENE_PANEL_ORDER = ["A", "B", "C", "DQB1", "DRB1", "DPB1"]

# Genes available from each summary text file (others computed from genotype CSVs)
SUMMARY_GENES: Dict[str, Tuple[str, ...]] = {
    "hanoi_kinh": ("DQB1", "DRB1"),
    "hanoi_kinh2": ("A", "B", "C", "DQB1", "DRB1"),
    "hoabinh_muong": ("DQB1", "DRB1"),
    "vn_kinh_dqb1": ("DQB1",),
}

VN1K_CSV = BASE / "VN1k_1015.HISAT_result.csv"
VN1K_SAMPLE_IDS = BASE / "sample_ids.txt"
# Blank these DQB1 calls before AF merge (HISAT call-level typos), e.g. ``DQB1_2`` = ``06:130`` on VN_03_00_0850.
VN1K_DROP_DQB1_LOCUS_LABELS = frozenset({"DQB1*06:130"})
# KHV: SampleIDs are normalized (strip .hisat / _hisat / hisat_ tags) and deduplicated before AF — see load_khv_rows().
KHV_CSV = BASE / "merged_hisat_hla_99KHV.csv"
SUMMARY_PATHS: Dict[str, Path] = {
    "hanoi_kinh": BASE / "hanoi_kinh.txt",
    "hanoi_kinh2": BASE / "hanoi_kinh2.txt",
    "hoabinh_muong": BASE / "hoabinh_muong.txt",
    "vn_kinh_dqb1": BASE / "kinh_dqb1.txt",
}

OUT_PNG = BASE / "HLA_AF_cohort_comparison.png"
OUT_PDF = BASE / "HLA_AF_cohort_comparison.pdf"
OUT_MERGED_CSV = BASE / "merged_hla_af_by_cohort.csv"
OUT_SOURCE_PLOT_CSV = BASE / "source_data_hla_af_cohort_comparison_plot.csv"
OUT_SOURCE_GENE_COUNT_CSV = BASE / "source_data_hla_gene_allele_counts.csv"
TOP_N = 16

# Compact layout for embedding in larger composite figures (extra-narrow)
FIGSIZE_INCH = (4.45, 3.42)
SAVE_PNG_DPI = 150
FS_TICK = 4.25
FS_AXIS_LABEL = 5.25
FS_TITLE = 6.25
FS_LEGEND = 4.25
FS_PANEL_TAG = 8.0
SCATTER_AREA_SCALE = 0.42  # matplotlib scatter `s` is marker area
LEGEND_NCOL = 6


def two_field_from_tail(tail: str) -> Optional[str]:
    if not tail or not str(tail).strip():
        return None
    s = str(tail).strip().replace("G", "")
    parts = s.split(":")
    if len(parts) >= 2:
        return ":".join(parts[:2])
    return parts[0] if parts else None


def standardize_locus_label(gene: str, allele_tail: str) -> Optional[str]:
    """Return e.g. DQB1*03:01 given gene and allele part after optional HLA- prefix."""
    tf = two_field_from_tail(allele_tail)
    if not tf:
        return None
    g = gene.upper().replace("HLA-", "")
    return f"{g}*{tf}"


def parse_prefixed_allele(cell: str) -> Optional[Tuple[str, str]]:
    """
    Parse A*11:01:01:01 or DRB1*12:02:01 -> (gene letter/name, tail after *).
    """
    if not cell or not str(cell).strip():
        return None
    s = str(cell).strip()
    if "*" not in s:
        return None
    gene, rest = s.split("*", 1)
    gene = gene.upper().replace("HLA-", "")
    if not rest:
        return None
    return gene, rest


def af_from_genotype_rows(
    rows: List[Mapping[str, str]],
    sample_id_key: str,
    gene_cols: Mapping[str, Tuple[str, str]],
) -> Tuple[Dict[str, Dict[str, float]], int]:
    """Per-gene allele frequency (0-1) from diploid columns; returns (af_dict, n_samples)."""
    n = len(rows)
    out: Dict[str, Dict[str, float]] = defaultdict(dict)
    for gene, (c1, c2) in gene_cols.items():
        alleles: List[str] = []
        for r in rows:
            for col in (c1, c2):
                raw = (r.get(col) or "").strip()
                if not raw:
                    continue
                if "*" in raw:
                    p = parse_prefixed_allele(raw)
                    if not p:
                        continue
                    g, tail = p
                    if g != gene:
                        continue
                    lab = standardize_locus_label(gene, tail)
                else:
                    lab = standardize_locus_label(gene, raw)
                if lab:
                    alleles.append(lab)
        total = len(alleles)
        if not total:
            continue
        cnt = Counter(alleles)
        for a, c in cnt.items():
            out[gene][a] = c / total
    return out, n


def load_vn1k_rows() -> Tuple[List[Mapping[str, str]], str]:
    with open(VN1K_CSV, newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        return [], ""
    sample_id_key = next(iter(rows[0].keys()))
    if VN1K_SAMPLE_IDS.exists():
        with open(VN1K_SAMPLE_IDS, encoding="utf-8") as f:
            lines = [ln.strip() for ln in f if ln.strip()]
        sid_set = set(lines[1:]) if lines and lines[0].lower() in ("sample_id", "sampleid") else set(lines)
        filt = [r for r in rows if (r.get(sample_id_key) or "").strip() in sid_set]
        out = filt if filt else rows
    else:
        out = rows
    if VN1K_DROP_DQB1_LOCUS_LABELS:
        fixed: List[Mapping[str, str]] = []
        for r in out:
            rr = dict(r)
            for col in ("DQB1_1", "DQB1_2"):
                raw = (rr.get(col) or "").strip()
                if not raw:
                    continue
                if "*" in raw:
                    p = parse_prefixed_allele(raw)
                    if not p or p[0].upper() != "DQB1":
                        continue
                    lab = standardize_locus_label("DQB1", p[1])
                else:
                    lab = standardize_locus_label("DQB1", raw)
                if lab and lab in VN1K_DROP_DQB1_LOCUS_LABELS:
                    rr[col] = ""
            fixed.append(rr)
        out = fixed
    return out, sample_id_key


def normalize_khv_sample_id(sample_id: str) -> str:
    """
    Remove HISAT-style filename decorations from a sample id before merge.

    Handles suffixes ``.hisat`` / ``_hisat`` and prefixes ``_hisat`` / ``hisat_`` (case-insensitive), repeatedly.
    """
    s = (sample_id or "").strip()
    if not s:
        return s
    for _ in range(8):
        low = s.lower()
        changed = False
        if low.endswith(".hisat"):
            s = s[: -len(".hisat")].strip()
            changed = True
        elif low.endswith("_hisat"):
            s = s[: -len("_hisat")].strip()
            changed = True
        elif low.startswith("_hisat"):
            s = s[len("_hisat") :].strip()
            changed = True
        elif low.startswith("hisat_"):
            s = s[len("hisat_") :].strip()
            changed = True
        if not changed:
            break
    return s


def load_khv_rows() -> List[Mapping[str, str]]:
    """
    Load KHV genotypes; strip ``.hisat`` / ``_hisat`` from SampleID and drop duplicate individuals
    (e.g. ``HG02140`` and ``hg02140.hisat`` in the same merge).
    """
    with open(KHV_CSV, newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    seen: Dict[str, Mapping[str, str]] = {}
    out: List[Mapping[str, str]] = []
    for r in rows:
        raw = (r.get("SampleID") or "").strip()
        cleaned = normalize_khv_sample_id(raw)
        key = cleaned.upper() if cleaned else raw.upper()
        if key in seen:
            continue
        rr = dict(r)
        rr["SampleID"] = cleaned
        seen[key] = rr
        out.append(rr)
    return out


def gene_cols_vn1k() -> Dict[str, Tuple[str, str]]:
    return {
        "A": ("A_1", "A_2"),
        "B": ("B_1", "B_2"),
        "C": ("C_1", "C_2"),
        "DRB1": ("DRB1_1", "DRB1_2"),
        "DQB1": ("DQB1_1", "DQB1_2"),
        "DPB1": ("DPB1_1", "DPB1_2"),
    }


def gene_cols_khv() -> Dict[str, Tuple[str, str]]:
    return {
        "A": ("A1", "A2"),
        "B": ("B1", "B2"),
        "C": ("C1", "C2"),
        "DRB1": ("DRB11", "DRB12"),
        "DQB1": ("DQB11", "DQB12"),
        "DPB1": ("DPB11", "DPB12"),
    }


def load_summary_af(path: Path) -> Dict[str, Dict[str, float]]:
    """Gene -> allele_label -> AF (0-1)."""
    out: Dict[str, Dict[str, float]] = defaultdict(dict)
    with open(path, encoding="utf-8") as f:
        header = f.readline()
        if not header:
            return out
        cols = header.strip().split("\t")
        # resolve allele column name (typo Alllele in kinh_dqb1.txt)
        allele_col_idx = None
        af_col_idx = None
        for i, name in enumerate(cols):
            low = name.lower()
            if low in ("allele", "alllele"):
                allele_col_idx = i
            if low == "af":
                af_col_idx = i
        if allele_col_idx is None or af_col_idx is None:
            return out
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split("\t")
            if max(allele_col_idx, af_col_idx) >= len(parts):
                continue
            cell = parts[allele_col_idx].strip()
            try:
                af = float(parts[af_col_idx].strip())
            except ValueError:
                continue
            parsed = parse_prefixed_allele(cell)
            if not parsed:
                continue
            gene, tail = parsed
            lab = standardize_locus_label(gene, tail)
            if not lab:
                continue
            g = lab.split("*", 1)[0]
            out[g][lab] = af
    return out


def merge_cohort_af() -> Tuple[Dict[str, Dict[str, Dict[str, float]]], Dict[str, int]]:
    """
    nested[gene][cohort_id][allele] = AF
    cohort_n[cohort_id] = sample size for legend
    """
    nested: Dict[str, Dict[str, Dict[str, float]]] = defaultdict(
        lambda: defaultdict(dict)
    )
    cohort_n: Dict[str, int] = {}

    vn_rows, sid_key = load_vn1k_rows()
    af_vn, n_vn = af_from_genotype_rows(vn_rows, sid_key, gene_cols_vn1k())
    cohort_n["vn1k"] = n_vn
    for g, m in af_vn.items():
        nested[g]["vn1k"].update(m)

    khv_rows = load_khv_rows()
    af_k, n_k = af_from_genotype_rows(khv_rows, "SampleID", gene_cols_khv())
    assert n_k == len(khv_rows), (n_k, len(khv_rows))
    # Legend n must match deduped genomes (raw CSV can have duplicate IDs, e.g. HG02140 + hg02140.hisat).
    cohort_n["khv"] = len(khv_rows)
    for g, m in af_k.items():
        nested[g]["khv"].update(m)

    for cid, genes in SUMMARY_GENES.items():
        path = SUMMARY_PATHS[cid]
        if not path.exists():
            continue
        sm = load_summary_af(path)
        for g in genes:
            for allele, v in sm.get(g, {}).items():
                nested[g][cid][allele] = v
        if cid not in cohort_n:
            override = next((o for lab, x, o in COHORT_ORDER if x == cid), None)
            cohort_n[cid] = int(override) if override is not None else 0

    print(
        f"KHV (99KHV): n={cohort_n['khv']} genotypes after SampleID normalize/dedupe "
        f"({KHV_CSV.name}; see normalize_khv_sample_id / load_khv_rows)."
    )
    return nested, cohort_n


def cohort_in_gene_panel(cohort_id: str, gene: str) -> bool:
    if cohort_id in ("vn1k", "khv"):
        return True
    if cohort_id == "vn_kinh_dqb1":
        return gene == "DQB1"
    if cohort_id == "hanoi_kinh":
        return gene in SUMMARY_GENES["hanoi_kinh"]
    if cohort_id == "hanoi_kinh2":
        return gene in SUMMARY_GENES["hanoi_kinh2"]
    if cohort_id == "hoabinh_muong":
        return gene in SUMMARY_GENES["hoabinh_muong"]
    return False


def drb1_exclude_cohort(cohort_id: str) -> bool:
    """Manuscript-style: Vietnam_DQB1 series is DQB1-only."""
    return cohort_id == "vn_kinh_dqb1"


def pick_alleles_for_gene(
    gene: str,
    nested: Mapping[str, Mapping[str, Mapping[str, float]]],
    top_n: int,
) -> List[str]:
    ref = nested.get(gene, {}).get("vn1k", {})
    scored: List[Tuple[float, str]] = []
    for a in ref:
        scored.append((ref[a], a))
    if not scored:
        # fallback: union sorted by max AF across cohorts
        union: Dict[str, float] = {}
        for cid, amap in nested.get(gene, {}).items():
            for a, v in amap.items():
                union[a] = max(union.get(a, 0.0), v)
        scored = sorted(((v, a) for a, v in union.items()), reverse=True)
    else:
        scored.sort(reverse=True)
    return [a for _, a in scored[:top_n]]


def cohort_style(
    legend_label: str,
    cohort_id: str,
    n: int,
) -> Tuple[str, str, float, Callable[..., Iterable]]:
    """color, marker, markersize, kwargs factory for edgecolors/facecolors."""
    label = f"{legend_label} (n={n})"
    if cohort_id == "vn1k":
        return label, "red", 36, lambda: {"marker": "D", "c": "red", "edgecolors": "darkred", "linewidths": 0.4}
    if cohort_id == "khv":
        return label, "orange", 30, lambda: {
            "marker": "s",
            "facecolors": "none",
            "edgecolors": "darkorange",
            "linewidths": 1.0,
        }
    if cohort_id == "hanoi_kinh2":
        return label, "goldenrod", 32, lambda: {
            "marker": "o",
            "facecolors": "none",
            "edgecolors": "goldenrod",
            "linewidths": 1.0,
        }
    if cohort_id == "hanoi_kinh":
        return label, "royalblue", 34, lambda: {
            "marker": "^",
            "facecolors": "none",
            "edgecolors": "royalblue",
            "linewidths": 1.0,
        }
    if cohort_id == "hoabinh_muong":
        return label, "cadetblue", 34, lambda: {
            "marker": "v",
            "facecolors": "none",
            "edgecolors": "cadetblue",
            "linewidths": 1.0,
        }
    if cohort_id == "vn_kinh_dqb1":
        return label, "navy", 52, lambda: {"marker": "+", "c": "navy", "linewidths": 1.2}
    return label, "gray", 24, lambda: {"marker": "o", "c": "gray"}


def cohort_legend_proxy(legend_label: str, cohort_id: str, n: int) -> Line2D:
    """Line2D proxy so the figure legend lists every cohort (panel 1 is HLA-A, not DQB1)."""
    lab, _c, _ms, kw_factory = cohort_style(legend_label, cohort_id, n)
    kw = kw_factory()
    mk = kw["marker"]
    mew = float(kw.get("linewidths", 1.0))
    if cohort_id == "vn1k":
        return Line2D(
            [],
            [],
            linestyle="None",
            marker=mk,
            markersize=4.5,
            markerfacecolor="red",
            markeredgecolor=kw.get("edgecolors", "darkred"),
            markeredgewidth=mew * 0.8,
            label=lab,
        )
    if cohort_id == "vn_kinh_dqb1":
        return Line2D(
            [],
            [],
            linestyle="None",
            marker=mk,
            markersize=5.2,
            markerfacecolor="none",
            markeredgecolor="navy",
            markeredgewidth=mew * 0.8,
            label=lab,
        )
    if kw.get("facecolors") == "none":
        ec = kw.get("edgecolors", "gray")
        return Line2D(
            [],
            [],
            linestyle="None",
            marker=mk,
            markersize=4.0,
            markerfacecolor="none",
            markeredgecolor=ec,
            markeredgewidth=mew * 0.8,
            label=lab,
        )
    fc = kw.get("c", "gray")
    return Line2D(
        [],
        [],
        linestyle="None",
        marker=mk,
        markersize=4.0,
        markerfacecolor=fc,
        markeredgecolor=fc,
        markeredgewidth=mew * 0.8,
        label=lab,
    )


def write_merged_csv(
    nested: Mapping[str, Mapping[str, Mapping[str, float]]],
    cohort_n: Mapping[str, int],
) -> None:
    """Tidy table: cohort_label, cohort_id, n_samples, gene, allele, AF."""
    id_to_label = {cid: lab for lab, cid, _ in COHORT_ORDER}
    with open(OUT_MERGED_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["cohort_label", "cohort_id", "n_samples", "gene", "allele", "AF"])
        for gene in sorted(nested.keys()):
            for cid, amap in nested[gene].items():
                lab = id_to_label.get(cid, cid)
                n = cohort_n.get(cid, "")
                for allele, v in sorted(amap.items()):
                    w.writerow([lab, cid, n, gene, allele, f"{v:.8g}"])
    print(f"Saved: {OUT_MERGED_CSV}")


def write_plot_source_csv(
    nested: Mapping[str, Mapping[str, Mapping[str, float]]],
    cohort_n: Mapping[str, int],
) -> None:
    """Point-level source table for the scatter plot (one row per plotted point)."""
    id_to_label = {cid: lab for lab, cid, _ in COHORT_ORDER}
    with open(OUT_SOURCE_PLOT_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "panel_gene",
                "cohort_label",
                "cohort_id",
                "n_samples",
                "x_index",
                "allele",
                "allele_display",
                "AF",
            ]
        )
        for gene in GENE_PANEL_ORDER:
            alleles = pick_alleles_for_gene(gene, nested, TOP_N)
            for legend_label, cohort_id, _n_override in COHORT_ORDER:
                if not cohort_in_gene_panel(cohort_id, gene):
                    continue
                if gene == "DRB1" and drb1_exclude_cohort(cohort_id):
                    continue
                n = cohort_n.get(cohort_id, 0) or (
                    next((o for lab, x, o in COHORT_ORDER if x == cohort_id), None) or 0
                )
                label = id_to_label.get(cohort_id, legend_label)
                for i, allele in enumerate(alleles):
                    af = nested.get(gene, {}).get(cohort_id, {}).get(allele)
                    if af is None:
                        continue
                    w.writerow(
                        [
                            gene,
                            label,
                            cohort_id,
                            n,
                            i,
                            allele,
                            allele.split("*", 1)[-1] if "*" in allele else allele,
                            f"{af:.8g}",
                        ]
                    )
    print(f"Saved: {OUT_SOURCE_PLOT_CSV}")


def write_gene_count_source_csv(
    nested: Mapping[str, Mapping[str, Mapping[str, float]]],
    cohort_n: Mapping[str, int],
) -> None:
    """
    Gene-level source table for allele-count style displays.

    - n_distinct_alleles: number of unique alleles observed in that gene/cohort
    - total_allele_copies: diploid total used for AF denominator (2N when complete)
    """
    id_to_label = {cid: lab for lab, cid, _ in COHORT_ORDER}
    with open(OUT_SOURCE_GENE_COUNT_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "cohort_label",
                "cohort_id",
                "gene",
                "n_samples",
                "n_distinct_alleles",
                "total_allele_copies",
            ]
        )
        for legend_label, cohort_id, _n_override in COHORT_ORDER:
            n = cohort_n.get(cohort_id, 0) or (
                next((o for lab, x, o in COHORT_ORDER if x == cohort_id), None) or 0
            )
            label = id_to_label.get(cohort_id, legend_label)
            for gene in GENE_PANEL_ORDER:
                if not cohort_in_gene_panel(cohort_id, gene):
                    continue
                if gene == "DRB1" and drb1_exclude_cohort(cohort_id):
                    continue
                n_distinct = len(nested.get(gene, {}).get(cohort_id, {}))
                total_allele_copies = int(round(2 * n)) if n else 0
                w.writerow(
                    [label, cohort_id, gene, n, n_distinct, total_allele_copies]
                )
    print(f"Saved: {OUT_SOURCE_GENE_COUNT_CSV}")


def plot_main() -> None:
    nested, cohort_n = merge_cohort_af()
    write_merged_csv(nested, cohort_n)
    write_plot_source_csv(nested, cohort_n)
    write_gene_count_source_csv(nested, cohort_n)

    fig, axes = plt.subplots(2, 3, figsize=FIGSIZE_INCH, sharex=False, sharey=False)
    axes_flat = axes.ravel()

    legend_handles: List[Line2D] = []
    for legend_label, cohort_id, _n_override in COHORT_ORDER:
        n = cohort_n.get(cohort_id, 0) or (
            next((o for lab, x, o in COHORT_ORDER if x == cohort_id), None) or 0
        )
        legend_handles.append(cohort_legend_proxy(legend_label, cohort_id, n))
    legend_labels = [h.get_label() for h in legend_handles]

    for ax_idx, gene in enumerate(GENE_PANEL_ORDER):
        ax = axes_flat[ax_idx]
        alleles = pick_alleles_for_gene(gene, nested, TOP_N)
        x = np.arange(len(alleles))
        for legend_label, cohort_id, _n_override in COHORT_ORDER:
            if not cohort_in_gene_panel(cohort_id, gene):
                continue
            if gene == "DRB1" and drb1_exclude_cohort(cohort_id):
                continue

            n = cohort_n.get(cohort_id, 0) or (
                next((o for lab, x, o in COHORT_ORDER if x == cohort_id), None) or 0
            )
            _lab, _c, ms, kw_factory = cohort_style(legend_label, cohort_id, n)
            ms = ms * SCATTER_AREA_SCALE
            kw = kw_factory()
            ys = []
            xs = []
            for i, a in enumerate(alleles):
                af = nested.get(gene, {}).get(cohort_id, {}).get(a)
                if af is None:
                    continue
                xs.append(i)
                ys.append(af)
            if not xs:
                continue
            ax.scatter(xs, ys, s=ms, zorder=3, **kw)

        ax.set_xticks(x)
        ax.set_xticklabels(
            [a.split("*", 1)[-1] if "*" in a else a for a in alleles],
            rotation=90,
            fontsize=FS_TICK,
        )
        ax.tick_params(axis="y", labelsize=FS_TICK)
        ax.set_ylabel("AF", fontsize=FS_AXIS_LABEL)
        ax.set_title(f"HLA-{gene}", fontsize=FS_TITLE, pad=2)
        ax.set_ylim(0, 0.5)
        ax.margins(x=0.01)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)

    # Single legend from first panel handles (same colors/markers across panels)
    fig.legend(
        legend_handles,
        legend_labels,
        loc="upper center",
        ncol=LEGEND_NCOL,
        frameon=True,
        fontsize=FS_LEGEND,
        handlelength=0.85,
        handletextpad=0.22,
        columnspacing=0.42,
        borderpad=0.18,
        bbox_to_anchor=(0.5, 1.005),
    )
    fig.text(0.02, 0.98, "a)", fontsize=FS_PANEL_TAG, va="top", ha="left", fontweight="bold")
    plt.tight_layout(rect=[0, 0, 1, 0.86], pad=0.25, h_pad=0.38, w_pad=0.16)
    plt.savefig(OUT_PNG, dpi=SAVE_PNG_DPI, bbox_inches="tight")
    plt.savefig(OUT_PDF, bbox_inches="tight")
    plt.close()
    print(f"Saved: {OUT_PNG}")
    print(f"Saved: {OUT_PDF}")


if __name__ == "__main__":
    plot_main()
