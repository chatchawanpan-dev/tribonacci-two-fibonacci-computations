#!/usr/bin/env python3
"""Exact searches for F_m^r + F_ell^r = T_n^p.

The script is intentionally independent of Sage/Magma so that large bounded
searches can be run quickly with Python's arbitrary-precision integers. Magma
scripts in ../magma handle the arithmetic-geometry side.
"""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from math import gcd
from pathlib import Path
from time import perf_counter


DEFAULT_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]


def parse_int_list(text: str) -> list[int]:
    return [int(x.strip()) for x in text.split(",") if x.strip()]


def fibonacci_list(nmax: int) -> list[int]:
    if nmax < 0:
        return []
    if nmax == 0:
        return [0]
    seq = [0, 1]
    for _ in range(2, nmax + 1):
        seq.append(seq[-1] + seq[-2])
    return seq


def tribonacci_list(nmax: int) -> list[int]:
    if nmax < 0:
        return []
    if nmax == 0:
        return [0]
    if nmax == 1:
        return [0, 1]
    seq = [0, 1, 1]
    for _ in range(3, nmax + 1):
        seq.append(seq[-1] + seq[-2] + seq[-3])
    return seq


def triple_gcd(a: int, b: int, c: int) -> int:
    return gcd(gcd(abs(a), abs(b)), abs(c))


def build_right_map(fib: list[int], r: int, mmax: int) -> dict[int, list[tuple[int, int]]]:
    fpow = [x**r for x in fib[: mmax + 1]]
    out: dict[int, list[tuple[int, int]]] = defaultdict(list)
    for m in range(mmax + 1):
        fm = fpow[m]
        for ell in range(m + 1):
            out[fm + fpow[ell]].append((ell, m))
    return out


def classify_solution(r: int, p: int, ell: int, m: int, n: int, fl: int, fm: int, tn: int, g: int) -> str:
    if tn == 0 and fm == 0 and fl == 0:
        return "zero"
    if fl == 0:
        if p == r and fm == tn:
            return "one-zero-side: p=r and F_m=T_n"
        return "one-zero-side"
    if tn in (1, 2, 4, 13, 81) or fm in (1, 2, 3, 8, 13) or fl in (1, 2, 3, 8, 13):
        if g > 1:
            return "small-value imprimitive"
        return "small-value"
    if g > 1:
        return "imprimitive"
    return "primitive-nonzero"


def search(r_values: list[int], p_values: list[int], mmax: int, nmax: int) -> list[dict[str, object]]:
    fib = fibonacci_list(mmax)
    trib = tribonacci_list(nmax)
    rows: list[dict[str, object]] = []

    right_maps = {r: build_right_map(fib, r, mmax) for r in r_values}

    for r in r_values:
        right = right_maps[r]
        for p in p_values:
            for n, tn in enumerate(trib):
                target = tn**p
                pairs = right.get(target)
                if pairs is None:
                    continue
                for ell, m in pairs:
                    fl, fm = fib[ell], fib[m]
                    g = triple_gcd(fl, fm, tn)
                    nonzero = fl != 0 and fm != 0 and tn != 0
                    primitive = g == 1
                    rows.append(
                        {
                            "r": r,
                            "p": p,
                            "ell": ell,
                            "m": m,
                            "n": n,
                            "F_ell": fl,
                            "F_m": fm,
                            "T_n": tn,
                            "value": target,
                            "gcd": g,
                            "primitive": int(primitive),
                            "nonzero": int(nonzero),
                            "classification": classify_solution(r, p, ell, m, n, fl, fm, tn, g),
                        }
                    )

    rows.sort(key=lambda row: (row["r"], row["p"], row["n"], row["m"], row["ell"]))
    return rows


def write_csv(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "r",
        "p",
        "ell",
        "m",
        "n",
        "F_ell",
        "F_m",
        "T_n",
        "value",
        "gcd",
        "primitive",
        "nonzero",
        "classification",
    ]
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def print_summary(rows: list[dict[str, object]], max_rows: int) -> None:
    print(f"solutions={len(rows)}")
    primitive_nonzero = [row for row in rows if row["primitive"] == 1 and row["nonzero"] == 1]
    print(f"primitive_nonzero={len(primitive_nonzero)}")

    by_rp: dict[tuple[int, int], int] = defaultdict(int)
    by_class: dict[str, int] = defaultdict(int)
    for row in rows:
        by_rp[(int(row["r"]), int(row["p"]))] += 1
        by_class[str(row["classification"])] += 1

    print("class_counts:")
    for label in sorted(by_class):
        print(f"  {label}: {by_class[label]}")

    print("nonempty_(r,p)_counts:")
    for (r, p), count in sorted(by_rp.items()):
        print(f"  r={r}, p={p}: {count}")

    print("first_rows:")
    for row in rows[:max_rows]:
        print(
            "  "
            f"r={row['r']} p={row['p']} n={row['n']} m={row['m']} ell={row['ell']} "
            f"T_n={row['T_n']} F_m={row['F_m']} F_ell={row['F_ell']} "
            f"gcd={row['gcd']} {row['classification']}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--r-list", default="2,3,5,7,11,13", help="comma-separated exponents r")
    parser.add_argument("--p-list", default=",".join(map(str, DEFAULT_PRIMES)), help="comma-separated prime exponents p")
    parser.add_argument("--m-max", type=int, default=300)
    parser.add_argument("--n-max", type=int, default=300)
    parser.add_argument("--csv", default="data/prime_power_search.csv")
    parser.add_argument("--max-rows", type=int, default=120)
    args = parser.parse_args()

    t0 = perf_counter()
    rows = search(parse_int_list(args.r_list), parse_int_list(args.p_list), args.m_max, args.n_max)
    elapsed = perf_counter() - t0
    write_csv(Path(args.csv), rows)
    print_summary(rows, args.max_rows)
    print(f"csv={args.csv}")
    print(f"elapsed_seconds={elapsed:.3f}")


if __name__ == "__main__":
    main()
