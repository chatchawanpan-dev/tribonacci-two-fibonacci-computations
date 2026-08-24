#!/usr/bin/env bash
set -euo pipefail

bundle_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
sage_cache_dir=$(mktemp -d)
trap 'rm -rf -- "$sage_cache_dir"' EXIT

cd "$bundle_dir"

DOT_SAGE="$sage_cache_dir" sage main_reduction.sage > main_reduction_log.txt
sage verify_main_theorem.sage > verify_main_theorem_output.txt
python3 independent_exact_search.py > independent_exact_search_output.txt
python3 validate_bundle.py > validate_bundle_output.txt

shasum -a 256 \
  main_reduction.sage \
  first_reduction_certificate.csv \
  main_reduction_table.csv \
  main_reduction_log.txt \
  verify_main_theorem.sage \
  verify_main_theorem_output.txt \
  independent_exact_search.py \
  independent_exact_search_output.txt \
  validate_bundle.py \
  validate_bundle_output.txt \
  ENVIRONMENT.md \
  CHECKSUMS.md \
  README.md \
  regenerate.sh \
  generated_tables_parts/README.md \
  generated_tables_parts/generated_tables.zip.b64.part_*.txt > SHA256SUMS.txt

printf 'Regeneration and validation: PASS\n'
