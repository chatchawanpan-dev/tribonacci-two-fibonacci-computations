#!/usr/bin/env sage
"""
Feedback-17 finite verification for the main theorem.

This script verifies the reduced search box obtained after the corrected
Tribonacci Binet coefficient:

    0 <= n <= 159, 0 <= ell <= m <= 198.

It performs exact integer recurrence computations and checks that the solution
set is precisely the list stated in the manuscript.
"""

N_MAX = 159
M_MAX = 198


def fibonacci_numbers(nmax):
    F = [0] * (nmax + 1)
    if nmax >= 1:
        F[1] = 1
    for k in range(nmax - 1):
        F[k + 2] = F[k + 1] + F[k]
    return F


def tribonacci_numbers(nmax):
    T = [0] * (nmax + 1)
    if nmax >= 1:
        T[1] = 1
    if nmax >= 2:
        T[2] = 1
    for k in range(nmax - 2):
        T[k + 3] = T[k + 2] + T[k + 1] + T[k]
    return T


expected = [
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
]

F = fibonacci_numbers(M_MAX)
T = tribonacci_numbers(N_MAX)

solutions = []
for n in range(N_MAX + 1):
    value = T[n]
    for m in range(M_MAX + 1):
        for ell in range(m + 1):
            if value == F[m] + F[ell]:
                solutions.append((n, m, ell))

assert solutions == expected

print("search_box_n_max =", N_MAX)
print("search_box_m_max =", M_MAX)
print("solution_count =", len(solutions))
for triple in solutions:
    n, m, ell = triple
    print((n, m, ell), "value =", T[n])
print("verification_status = PASS")
