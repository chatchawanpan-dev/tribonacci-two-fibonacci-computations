# Certified computational supplement

This repository contains the computational certificates for the manuscript
**"Tribonacci Numbers That Are Sums of Two Fibonacci Numbers."** The certified
release proves the two Dujella--Petho reductions and independently verifies the
complete finite search.

## One-command regeneration

Requirements:

- SageMath 10.9 or later
- Python 3.9 or later (standard library only)

From the repository root, run:

```sh
./regenerate.sh
```

The command regenerates both certificates, both exact-search outputs, validates
the mathematical invariants, and writes `SHA256SUMS.txt`.

## Main-theorem files

| File | Purpose |
|---|---|
| `main_reduction.sage` | Exact algebraic root isolation, certified continued fractions, directed interval bounds, height checks, and proof-constant regression checks |
| `first_reduction_certificate.csv` | One-row machine-readable certificate for the first reduction |
| `main_reduction_table.csv` | Directly downloadable 186-row certificate for every `d = 0,...,185` |
| `main_reduction_log.txt` | Captured output from the certified reduction |
| `verify_main_theorem.sage` | Exact integer search over `0 <= n <= 159` and `0 <= ell <= m <= 198` |
| `verify_main_theorem_output.txt` | Captured output from the Sage exact search |
| `independent_exact_search.py` | Independent pure-Python pair-sum verifier |
| `independent_exact_search_output.txt` | Captured output from the independent verifier |
| `validate_bundle.py` | Structural and mathematical validation of all generated files |
| `validate_bundle_output.txt` | Captured validation result |
| `ENVIRONMENT.md` | Tested software versions and arithmetic model |
| `SHA256SUMS.txt` | Machine-readable SHA-256 manifest |

Continued-fraction indices are zero-based. Every CSV decimal used in a strict
proof inequality is serialized by flooring a lower endpoint or ceiling an upper
endpoint. The certificate generator aborts if the continued-fraction prefix is
ambiguous, a nearest-integer interval reaches either half-unit boundary, a
denominator fails `q > 6M`, or a proof threshold fails.

The release verifies:

- first reduction: `d <= 185`;
- second reduction: `m <= 198`;
- growth closure: `n <= 159`;
- exact solution count: 17;
- largest common value: 149;
- both independent finite searches: `PASS`.

## Release citation

For reproducible citation, use the immutable GitHub release rather than the
mutable `main` branch:

<https://github.com/chatchawanpan-dev/tribonacci-two-fibonacci-computations/releases/tag/v1.0.0>

The older files in `generated_tables_parts/`, `prime_power_recurrence/`, and the
power-variant scripts are retained as legacy material. The direct CSV files in
the repository root are authoritative for the focused main theorem.
