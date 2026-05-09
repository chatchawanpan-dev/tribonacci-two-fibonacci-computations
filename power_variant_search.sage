#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Search for non-negative integer solutions of

    (T_n)^i = (F_m)^j + (F_ell)^j

within a finite search box.

Conventions:
- T_0 = 0, T_1 = 1, T_2 = 1, T_{k+3} = T_{k+2} + T_{k+1} + T_k
- F_0 = 0, F_1 = 1, F_{k+2} = F_{k+1} + F_k
- Indices and exponents are non-negative integers.
- By default, the script enforces l <= m to avoid symmetric duplicates.

Example:
    sage power_variant_search.sage --i-max 8 --j-max 8 --n-max 60 --m-max 60
"""

from sage.all import ZZ
import argparse
import csv
from collections import defaultdict
from time import perf_counter


def fibonacci_list(nmax):
    """Return [F_0, ..., F_nmax] as exact integers."""
    if nmax < 0:
        return []
    if nmax == 0:
        return [ZZ(0)]

    F = [ZZ(0), ZZ(1)]
    for _ in range(2, nmax + 1):
        F.append(F[-1] + F[-2])
    return F


def tribonacci_list(nmax):
    """Return [T_0, ..., T_nmax] as exact integers."""
    if nmax < 0:
        return []
    if nmax == 0:
        return [ZZ(0)]
    if nmax == 1:
        return [ZZ(0), ZZ(1)]

    T = [ZZ(0), ZZ(1), ZZ(1)]
    for _ in range(3, nmax + 1):
        T.append(T[-1] + T[-2] + T[-3])
    return T


def safe_pow(base, exp, include_zero_pow_zero=True):
    """
    Return base^exp unless this is 0^0 and include_zero_pow_zero is False.
    In that excluded case return None.
    """
    if (not include_zero_pow_zero) and base == 0 and exp == 0:
        return None
    return base**exp


def power_table(values, exp, include_zero_pow_zero=True):
    """Compute [values[k]^exp] with optional 0^0 filtering."""
    return [safe_pow(v, exp, include_zero_pow_zero) for v in values]


def build_left_map(T, i, n_max, include_zero_pow_zero=True):
    """Map value -> list of n with T_n^i = value."""
    table = power_table(T[: n_max + 1], i, include_zero_pow_zero)
    value_to_n = defaultdict(list)
    for n, val in enumerate(table):
        if val is not None:
            value_to_n[val].append(n)
    return value_to_n


def build_right_map(F, j, l_max, m_max, include_zero_pow_zero=True, enforce_l_le_m=True):
    """Map value -> list of pairs (ell,m) with F_m^j + F_ell^j = value."""
    upper = max(l_max, m_max)
    F_pow = power_table(F[: upper + 1], j, include_zero_pow_zero)
    value_to_pairs = defaultdict(list)

    if enforce_l_le_m:
        for m in range(m_max + 1):
            fmj = F_pow[m]
            if fmj is None:
                continue
            l_upper = min(l_max, m)
            for l in range(l_upper + 1):
                flj = F_pow[l]
                if flj is None:
                    continue
                value_to_pairs[fmj + flj].append((l, m))
    else:
        for m in range(m_max + 1):
            fmj = F_pow[m]
            if fmj is None:
                continue
            for l in range(l_max + 1):
                flj = F_pow[l]
                if flj is None:
                    continue
                value_to_pairs[fmj + flj].append((l, m))

    return value_to_pairs


def search_solutions(i_min, i_max, j_min, j_max, l_max, m_max, n_max, include_zero_pow_zero=True, enforce_l_le_m=True, verbose=False):
    """
    Return rows (i,j,ell,m,n,value) satisfying T_n^i = F_m^j + F_ell^j
    in the requested search box.
    """
    F = fibonacci_list(max(l_max, m_max))
    T = tribonacci_list(n_max)

    left_maps = {}
    for i in range(i_min, i_max + 1):
        left_maps[i] = build_left_map(T, i, n_max, include_zero_pow_zero)

    rows = []
    for j in range(j_min, j_max + 1):
        right_map = build_right_map(
            F=F,
            j=j,
            l_max=l_max,
            m_max=m_max,
            include_zero_pow_zero=include_zero_pow_zero,
            enforce_l_le_m=enforce_l_le_m,
        )

        if verbose:
            print(f"[j={j}] right-side distinct values: {len(right_map)}")

        right_keys = set(right_map.keys())
        for i in range(i_min, i_max + 1):
            left_map = left_maps[i]
            common = right_keys.intersection(left_map.keys())
            if not common:
                continue

            for val in common:
                for n in left_map[val]:
                    for (l, m) in right_map[val]:
                        rows.append((i, j, l, m, n, val))

    rows.sort(key=lambda r: (r[0], r[1], r[2], r[3], r[4]))
    return rows, F, T


def write_solution_csv(path, rows, F, T):
    """Write rows to CSV with useful derived columns."""
    with open(path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["i", "j", "ell", "m", "n", "T_n", "F_ell", "F_m", "value"])
        for i, j, l, m, n, value in rows:
            writer.writerow([i, j, l, m, n, str(T[n]), str(F[l]), str(F[m]), str(value)])


def print_rows(rows, max_print):
    """Print rows to stdout (optionally truncated)."""
    print(" i   j   l   m   n   value")
    print("------------------------------")
    shown = min(len(rows), max_print)
    for idx in range(shown):
        i, j, l, m, n, value = rows[idx]
        print(f"{i:2d}  {j:2d}  {l:2d}  {m:2d}  {n:2d}  {value}")
    if len(rows) > shown:
        print(f"... ({len(rows) - shown} more rows not shown)")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Explore solutions of (T_n)^i = (F_m)^j + (F_ell)^j in finite bounds."
    )
    parser.add_argument("--i-min", type=int, default=0, help="lower bound for i (default: 0)")
    parser.add_argument("--i-max", type=int, default=6, help="upper bound for i (default: 6)")
    parser.add_argument("--j-min", type=int, default=0, help="lower bound for j (default: 0)")
    parser.add_argument("--j-max", type=int, default=6, help="upper bound for j (default: 6)")
    parser.add_argument("--l-max", type=int, default=60, help="upper bound for l (default: 60)")
    parser.add_argument("--m-max", type=int, default=60, help="upper bound for m (default: 60)")
    parser.add_argument("--n-max", type=int, default=60, help="upper bound for n (default: 60)")
    parser.add_argument(
        "--allow-l-gt-m",
        action="store_true",
        help="if set, do not enforce l <= m (default enforces l <= m)",
    )
    parser.add_argument(
        "--exclude-0pow0",
        action="store_true",
        help="exclude tuples requiring 0^0 (default uses Sage convention 0^0 = 1)",
    )
    parser.add_argument(
        "--csv",
        type=str,
        default="power_variant_solutions.csv",
        help="CSV output file (default: power_variant_solutions.csv)",
    )
    parser.add_argument(
        "--max-print",
        type=int,
        default=200,
        help="maximum number of rows to print (default: 200)",
    )
    parser.add_argument("--verbose", action="store_true", help="print progress information")
    return parser.parse_args()


def main():
    args = parse_args()

    for name, val in [
        ("i_min", args.i_min),
        ("i_max", args.i_max),
        ("j_min", args.j_min),
        ("j_max", args.j_max),
        ("l_max", args.l_max),
        ("m_max", args.m_max),
        ("n_max", args.n_max),
    ]:
        if val < 0:
            raise ValueError(f"{name} must be non-negative.")
    if args.i_min > args.i_max:
        raise ValueError("i_min must be <= i_max.")
    if args.j_min > args.j_max:
        raise ValueError("j_min must be <= j_max.")

    enforce_l_le_m = not args.allow_l_gt_m
    include_zero_pow_zero = not args.exclude_0pow0

    if enforce_l_le_m and args.l_max > args.m_max:
        print(f"Warning: l_max={args.l_max} > m_max={args.m_max}; clamping l_max to m_max.")
        args.l_max = args.m_max

    print("=== Search settings ===")
    print("Equation: (T_n)^i = (F_m)^j + (F_ell)^j")
    print(
        f"Bounds: {args.i_min}<=i<={args.i_max}, {args.j_min}<=j<={args.j_max}, "
        f"0<=l<={args.l_max}, 0<=m<={args.m_max}, 0<=n<={args.n_max}"
    )
    print(f"Constraint: l <= m is {'ON' if enforce_l_le_m else 'OFF'}")
    print(f"0^0 convention: {'include as 1 (Sage default)' if include_zero_pow_zero else 'excluded'}")

    t0 = perf_counter()
    rows, F, T = search_solutions(
        i_min=args.i_min,
        i_max=args.i_max,
        j_min=args.j_min,
        j_max=args.j_max,
        l_max=args.l_max,
        m_max=args.m_max,
        n_max=args.n_max,
        include_zero_pow_zero=include_zero_pow_zero,
        enforce_l_le_m=enforce_l_le_m,
        verbose=args.verbose,
    )
    t1 = perf_counter()

    print("\n=== Results ===")
    print(f"Total solutions found: {len(rows)}")
    print_rows(rows, args.max_print)
    print(f"\nRuntime: {t1 - t0:.4f} seconds")

    if args.csv:
        write_solution_csv(args.csv, rows, F, T)
        print(f"CSV written to: {args.csv}")


if __name__ == "__main__":
    main()
