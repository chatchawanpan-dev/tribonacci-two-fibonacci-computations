"""
Global-scope finite-range summary for
    T_n^i = F_m^j + F_ell^j
using precomputed CSV files.

Run:
  HOME=/tmp sage power_variant_summary.sage
"""

import csv
from pathlib import Path


def read_rows(path):
    rows = []
    with open(path, newline="") as f:
        rd = csv.DictReader(f)
        for r in rd:
            rows.append({k: int(v) for k, v in r.items()})
    return rows


def ell_value(r):
    return r["ell"] if "ell" in r else r["l"]


def in_family_A(r):
    # (i,j,ell,m,n) = (j+1, j, 3, 3, 3)
    i, j, ell, m, n = r["i"], r["j"], ell_value(r), r["m"], r["n"]
    return (ell, m, n) == (3, 3, 3) and i == j + 1


def in_family_B(r):
    # (i,j,ell,m,n) = (i, 2i-1, 3, 3, 4)
    i, j, ell, m, n = r["i"], r["j"], ell_value(r), r["m"], r["n"]
    return (ell, m, n) == (3, 3, 4) and j == 2 * i - 1


def in_family_C(r):
    # (i,j,ell,m,n) = (3j+1, j, 6, 6, 3)
    i, j, ell, m, n = r["i"], r["j"], ell_value(r), r["m"], r["n"]
    return (ell, m, n) == (6, 6, 3) and i == 3 * j + 1


def in_family_D(r):
    # (i,j,ell,m,n) = (3k+2, 2k+1, 6, 6, 4), equivalently 2i = 3j+1
    i, j, ell, m, n = r["i"], r["j"], ell_value(r), r["m"], r["n"]
    return (ell, m, n) == (6, 6, 4) and 2 * i == 3 * j + 1


def analyze_dataset(path):
    rows = read_rows(path)

    nontrivial = [
        r for r in rows
        if r["i"] >= 2 and r["j"] >= 2 and r["n"] >= 1 and ell_value(r) >= 1 and r["m"] >= 1
    ]

    famA = [r for r in nontrivial if in_family_A(r)]
    famB = [r for r in nontrivial if in_family_B(r)]
    famC = [r for r in nontrivial if in_family_C(r)]
    famD = [r for r in nontrivial if in_family_D(r)]

    in_union = [r for r in nontrivial if in_family_A(r) or in_family_B(r) or in_family_C(r) or in_family_D(r)]
    outside_union = [r for r in nontrivial if r not in in_union]

    nml_values = sorted(set((ell_value(r), r["m"], r["n"]) for r in nontrivial))
    n_ge_5 = [r for r in nontrivial if r["n"] >= 5]

    print("DATASET=", Path(path).name)
    print("total_solutions=", len(rows))
    print("nontrivial_solutions=", len(nontrivial))
    print("nontrivial_distinct_(l,m,n)=", nml_values)
    print("family_counts=", {
        "A(j+1,j,3,3,3)": len(famA),
        "B(i,2i-1,3,3,4)": len(famB),
        "C(3j+1,j,6,6,3)": len(famC),
        "D(2i=3j+1,6,6,4)": len(famD),
    })
    print("all_nontrivial_in_four_families=", len(outside_union) == 0)
    print("nontrivial_with_n_ge_5=", len(n_ge_5))
    print("-" * 70)


if __name__ == "__main__":
    base = Path(".")
    analyze_dataset(base / "power_variant_i19_n300.csv")
    analyze_dataset(base / "power_variant_i49_n300.csv")
