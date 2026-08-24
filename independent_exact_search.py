#!/usr/bin/env python3
"""Independent exact two-sum verification of the seventeen triples."""

N_MAX = 159
M_MAX = 198


def fibonacci(nmax):
    values = [0] * (nmax + 1)
    if nmax >= 1:
        values[1] = 1
    for k in range(nmax - 1):
        values[k + 2] = values[k + 1] + values[k]
    return values


def tribonacci(nmax):
    values = [0] * (nmax + 1)
    if nmax >= 1:
        values[1] = 1
    if nmax >= 2:
        values[2] = 1
    for k in range(nmax - 2):
        values[k + 3] = values[k + 2] + values[k + 1] + values[k]
    return values


expected = {
    (0, 0, 0),
    (1, 1, 0),
    (1, 2, 0),
    (2, 1, 0),
    (2, 2, 0),
    (3, 1, 1),
    (3, 2, 1),
    (3, 2, 2),
    (3, 3, 0),
    (4, 3, 3),
    (4, 4, 1),
    (4, 4, 2),
    (5, 5, 3),
    (6, 6, 5),
    (6, 7, 0),
    (7, 8, 4),
    (10, 12, 5),
}

F = fibonacci(M_MAX)
T = tribonacci(N_MAX)

# Construct the ordered pair-sum index once, independently of the nested-loop
# implementation in verify_main_theorem.sage.
pair_indices = {}
for m in range(M_MAX + 1):
    for ell in range(m + 1):
        pair_indices.setdefault(F[m] + F[ell], []).append((m, ell))

found = {
    (n, m, ell)
    for n, value in enumerate(T)
    for m, ell in pair_indices.get(value, ())
}

assert found == expected
assert max(T[n] for n, _, _ in found) == 149
assert not any(n == N_MAX or m == M_MAX or m - ell == 185 for n, m, ell in found)

print("method = independent exact pair-sum index")
print("search_box_n_max =", N_MAX)
print("search_box_m_max =", M_MAX)
print("solution_count =", len(found))
print("largest_common_value =", max(T[n] for n, _, _ in found))
print("boundary_solution_n159 =", False)
print("boundary_solution_m198 =", False)
print("boundary_solution_d185 =", False)
print("solutions =", sorted(found))
print("verification_status = PASS")
