# Tested environment

The `v1.0.0` release was regenerated and validated with:

- SageMath 10.9
- Sage runtime Python 3.12.13
- independent-verifier Python 3.9.6
- macOS Darwin 24.6.0 on arm64
- `RealIntervalField` precision: 2048 bits

The reduction layer uses Sage exact algebraic numbers (`AA`, `QQbar`, number
fields, and exact integers) together with outward-rounded real intervals. The
two finite-search programs use exact integer recurrence arithmetic only. No
third-party Python packages are required by the independent verifier.

Run `./regenerate.sh` from the repository root. A private Sage cache is selected
through `DOT_SAGE`; no user home-directory setting is overridden.
