#!/usr/bin/env python3
"""Validate the generated reduction certificates and exact-search outputs."""

import csv
from decimal import Decimal
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def read_rows(name):
    with (ROOT / name).open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


first_rows = read_rows("first_reduction_certificate.csv")
assert len(first_rows) == 1
first = first_rows[0]
assert first["cf_indexing"] == "zero_based"
assert int(first["k"]) == 72
assert first["q"] == "11952668732083860469560629603327231815"
assert first["q_gt_6M"] == "True"
assert Decimal(first["epsilon_lower"]) > Decimal("0.4")
assert Decimal(first["threshold_upper"]) < Decimal("186")

rows = read_rows("main_reduction_table.csv")
assert len(rows) == 186
assert [int(row["d"]) for row in rows] == list(range(186))
assert {int(row["k"]) for row in rows} <= {72, 73}
assert all(row["q_gt_6M"] == "True" for row in rows)
assert min(Decimal(row["epsilon_lower"]) for row in rows) > Decimal("0.00049")
assert max(Decimal(row["threshold_upper"]) for row in rows) < Decimal("199")

sage_output = (ROOT / "verify_main_theorem_output.txt").read_text(encoding="utf-8")
independent_output = (ROOT / "independent_exact_search_output.txt").read_text(
    encoding="utf-8"
)
assert "solution_count = 17" in sage_output
assert "verification_status = PASS" in sage_output
assert "solution_count = 17" in independent_output
assert "largest_common_value = 149" in independent_output
assert "verification_status = PASS" in independent_output

print("first_reduction_rows =", len(first_rows))
print("second_reduction_rows =", len(rows))
print("solution_count = 17")
print("largest_common_value = 149")
print("bundle_validation_status = PASS")
