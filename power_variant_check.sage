#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Computational checker for the global classification of

    T_n^i = F_m^j + F_ell^j,    i,j >= 1,  m >= ell >= 0.

This script validates that every tuple in a finite exhaustive CSV dataset
belongs to one of the classes stated in Theorem~\ref{thm:global-power},
and that every family/exception tuple inside the same finite box is present.

Expected CSV columns: i,j,ell,m,n (or the legacy column i,j,l,m,n; extra columns are ignored).

Usage:
  sage power_variant_check.sage
  sage power_variant_check.sage --csv power_variant_i49_n300.csv
"""

import csv
from pathlib import Path
import argparse

# Complete (n,m,ell)-classification for T_n = F_m + F_ell
THEOREM_MAIN_TRIPLES = {
    (0, 0, 0),
    (1, 1, 0), (1, 2, 0),
    (2, 1, 0), (2, 2, 0),
    (3, 1, 1), (3, 2, 1), (3, 2, 2), (3, 3, 0),
    (4, 3, 3), (4, 4, 1), (4, 4, 2),
    (5, 5, 3), (6, 6, 5), (6, 7, 0),
    (7, 8, 4), (10, 12, 5),
}

SPORADIC_EXTRAS = {
    (1, 2, 6, 4, 3),
    (2, 1, 3, 4, 1),
    (2, 1, 3, 4, 2),
    (3, 1, 3, 5, 4),
    (4, 1, 3, 7, 4),
    (2, 1, 4, 7, 4),
}


def in_bounds(t, i_min, i_max, j_min, j_max, n_max, m_max):
    i, j, n, m, ell = t
    return (
        i_min <= i <= i_max and
        j_min <= j <= j_max and
        0 <= ell <= m <= m_max and
        0 <= n <= n_max
    )


def classify(i, j, n, m, ell):
    # Class I: universal small-value families (all i,j >= 1)
    if n == 0 and (m, ell) == (0, 0):
        return "I(a): n=0, (m,ell)=(0,0), arbitrary i,j"
    if n in (1, 2) and (m, ell) in ((1, 0), (2, 0)):
        return "I(b): n=1,2 with (m,ell)=(1,0),(2,0), arbitrary i,j"
    if n == 3 and (m, ell) in ((1, 1), (2, 1), (2, 2)) and i == 1:
        return "I(c): n=3, (m,ell) in {(1,1),(2,1),(2,2)}, i=1"

    # Class II: (i,j)=(1,1) branch from Theorem 1.1
    if (i, j) == (1, 1) and (n, m, ell) in THEOREM_MAIN_TRIPLES:
        return "II: (i,j)=(1,1) branch"

    # Class III: explicit infinite power-collapse families
    if n == 3:
        if (m, ell) == (3, 0) and i == j:
            return "III(2.i): n=3, (3,0), i=j"
        if (m, ell) == (3, 3) and i == j + 1:
            return "III(2.ii): n=3, (3,3), i=j+1"
        if (m, ell) == (6, 0) and i == 3 * j:
            return "III(2.iii): n=3, (6,0), i=3j"
        if (m, ell) == (6, 6) and i == 3 * j + 1:
            return "III(2.iv): n=3, (6,6), i=3j+1"

    if n == 4:
        if (m, ell) == (3, 0) and j == 2 * i:
            return "III(4.i): n=4, (3,0), j=2i"
        if (m, ell) == (3, 3) and j == 2 * i - 1:
            return "III(4.ii): n=4, (3,3), j=2i-1"
        if (m, ell) == (6, 0) and 2 * i == 3 * j:
            return "III(4.iii): n=4, (6,0), 2i=3j"
        if (m, ell) == (6, 6) and 2 * i == 3 * j + 1:
            return "III(4.iv): n=4, (6,6), 2i=3j+1"

    if n == 6 and (m, ell) == (7, 0) and i == j:
        return "III(13): n=6, (7,0), i=j"

    if n == 9 and (m, ell) == (4, 0) and j == 4 * i:
        return "III(81): n=9, (4,0), j=4i"

    # Class IV: sporadic extras
    if (i, j, n, m, ell) in SPORADIC_EXTRAS:
        return "IV: sporadic extra"

    return None


def expected_tuples(i_min, i_max, j_min, j_max, n_max, m_max):
    out = set()

    for i in range(i_min, i_max + 1):
        for j in range(j_min, j_max + 1):
            # Class I(a),(b),(c)
            for n, m, ell in [
                (0, 0, 0),
                (1, 1, 0), (1, 2, 0),
                (2, 1, 0), (2, 2, 0),
            ]:
                t = (i, j, n, m, ell)
                if in_bounds(t, i_min, i_max, j_min, j_max, n_max, m_max):
                    out.add(t)

            for n, m, ell in [(3, 1, 1), (3, 2, 1), (3, 2, 2)]:
                t = (1, j, n, m, ell)
                if in_bounds(t, i_min, i_max, j_min, j_max, n_max, m_max):
                    out.add(t)

            # Class III families
            fam_candidates = [
                (j, j, 3, 3, 0),
                (j + 1, j, 3, 3, 3),
                (3 * j, j, 3, 6, 0),
                (3 * j + 1, j, 3, 6, 6),
                (i, 2 * i, 4, 3, 0),
                (i, 2 * i - 1, 4, 3, 3),
            ]
            for cand in fam_candidates:
                if in_bounds(cand, i_min, i_max, j_min, j_max, n_max, m_max):
                    out.add(cand)

            # 2i=3j
            if 3 * j % 2 == 0:
                ii = (3 * j) // 2
                t = (ii, j, 4, 6, 0)
                if in_bounds(t, i_min, i_max, j_min, j_max, n_max, m_max):
                    out.add(t)

            # 2i=3j+1
            if (3 * j + 1) % 2 == 0:
                ii = (3 * j + 1) // 2
                t = (ii, j, 4, 6, 6)
                if in_bounds(t, i_min, i_max, j_min, j_max, n_max, m_max):
                    out.add(t)

            t13 = (j, j, 6, 7, 0)
            if in_bounds(t13, i_min, i_max, j_min, j_max, n_max, m_max):
                out.add(t13)

            t81 = (i, 4 * i, 9, 4, 0)
            if in_bounds(t81, i_min, i_max, j_min, j_max, n_max, m_max):
                out.add(t81)

    # Class II branch, only for i=j=1
    if i_min <= 1 <= i_max and j_min <= 1 <= j_max:
        for n, m, ell in THEOREM_MAIN_TRIPLES:
            t = (1, 1, n, m, ell)
            if in_bounds(t, i_min, i_max, j_min, j_max, n_max, m_max):
                out.add(t)

    # Class IV sporadics
    for t in SPORADIC_EXTRAS:
        if in_bounds(t, i_min, i_max, j_min, j_max, n_max, m_max):
            out.add(t)

    return out


def read_dataset(path):
    rows = []
    with open(path, newline="") as f:
        rd = csv.DictReader(f)
        for r in rd:
            i = int(r["i"])
            j = int(r["j"])
            ell_col = "ell" if "ell" in r else "l"
            ell = int(r[ell_col])
            m = int(r["m"])
            n = int(r["n"])
            rows.append((i, j, n, m, ell))
    return rows


def analyze(path):
    rows = read_dataset(path)
    if not rows:
        print(f"DATASET={Path(path).name}")
        print("empty dataset")
        print("-" * 72)
        return

    i_vals = [t[0] for t in rows]
    j_vals = [t[1] for t in rows]
    n_vals = [t[2] for t in rows]
    m_vals = [t[3] for t in rows]

    i_min, i_max = min(i_vals), max(i_vals)
    j_min, j_max = min(j_vals), max(j_vals)
    n_max, m_max = max(n_vals), max(m_vals)

    observed = set(rows)

    class_counts = {}
    unmatched = []
    for t in rows:
        label = classify(*t)
        if label is None:
            unmatched.append(t)
        else:
            class_counts[label] = class_counts.get(label, 0) + 1

    expected = expected_tuples(i_min, i_max, j_min, j_max, n_max, m_max)
    missing_expected = sorted(expected - observed)

    print(f"DATASET={Path(path).name}")
    print(f"bounds: i in [{i_min},{i_max}], j in [{j_min},{j_max}], n<= {n_max}, m<= {m_max}")
    print(f"observed_solutions={len(rows)}")
    print(f"observed_unique={len(observed)}")
    print(f"all_observed_covered={len(unmatched)==0}")
    print(f"missing_expected={len(missing_expected)}")

    print("class_counts=")
    for k in sorted(class_counts):
        print(f"  {k}: {class_counts[k]}")

    if unmatched:
        print("first_unmatched=")
        for t in sorted(unmatched)[:20]:
            print("  ", t)

    if missing_expected:
        print("first_missing_expected=")
        for t in missing_expected[:20]:
            print("  ", t)

    print("-" * 72)


def parse_args():
    p = argparse.ArgumentParser(description="Check global classification on exhaustive CSV datasets.")
    p.add_argument(
        "--csv",
        action="append",
        default=[],
        help="CSV file to analyze (can be passed multiple times).",
    )
    return p.parse_args()


def main():
    args = parse_args()

    if args.csv:
        paths = [Path(x) for x in args.csv]
    else:
        paths = [
            Path("power_variant_i19_n300.csv"),
            Path("power_variant_i49_n300.csv"),
        ]

    for p in paths:
        if not p.exists():
            print(f"DATASET={p.name}")
            print("file_not_found=True")
            print("-" * 72)
            continue
        analyze(p)


if __name__ == "__main__":
    main()
