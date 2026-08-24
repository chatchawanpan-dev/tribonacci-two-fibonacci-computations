# Certified computation manifest

Release: `v1.0.0`
Regenerated: 2026-08-24

`SHA256SUMS.txt` is the authoritative machine-readable checksum manifest for
the focused main-theorem bundle. Regenerate the complete bundle and manifest
with:

```sh
./regenerate.sh
```

The release validation requires all of the following:

- exact algebraic isolation of the Tribonacci root;
- a certified 100-term continued-fraction prefix;
- half-unit nearest-integer checks for the first reduction and all 186 second-reduction rows;
- first-reduction index `k = 72` and certified epsilon greater than `0.4`;
- `d <= 185`, `m <= 198`, and hence `n <= 159`;
- exact degree-six minimal polynomial
  `1936*x^6 - 880*x^4 + 100*x^2 - 125`;
- directed checks for both Matveev constants and the coarse scalar bound;
- two exact finite searches returning the same 17 triples and largest value 149;
- structural validation of the direct CSV files.

The generated CSVs are stored directly in the repository root. The legacy
split archive is retained only for the older auxiliary projects and is rebuilt
for this release so its copy of `main_reduction_table.csv` matches the direct
certificate.
