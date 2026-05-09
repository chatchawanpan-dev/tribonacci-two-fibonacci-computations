"""
Verify the universal families in Proposition (trivial families) for
T_n^i = F_m^j + F_ell^j, and search for the first non-family tuples in a finite box.

Run:
  HOME=/tmp sage verify_small_families.sage
"""

def fib_list(M):
    F = [0, 1]
    for _ in range(2, M + 1):
        F.append(F[-1] + F[-2])
    return F


def trib_list(N):
    T = [0, 1, 1]
    for _ in range(3, N + 1):
        T.append(T[-1] + T[-2] + T[-3])
    return T


I_MAX = 20
J_MAX = 20
N_MAX = 30
M_MAX = 30

F = fib_list(M_MAX)
T = trib_list(N_MAX)


def in_trivial_family(i, j, n, m, ell):
    if n == 0 and (m, ell) == (0, 0):
        return True
    if n in (1, 2) and (m, ell) in ((1, 0), (2, 0)):
        return True
    if n == 3 and (m, ell) == (3, 0) and i == j:
        return True
    if n == 6 and (m, ell) == (7, 0) and i == j:
        return True
    return False


# Check proposition families directly in the box.
family_verified = True
for i in range(1, I_MAX + 1):
    for j in range(1, J_MAX + 1):
        candidates = [(0, 0, 0), (1, 1, 0), (1, 2, 0), (2, 1, 0), (2, 2, 0)]
        if i == j:
            candidates += [(3, 3, 0), (6, 7, 0)]
        for (n, m, ell) in candidates:
            if T[n] ** i != F[m] ** j + F[ell] ** j:
                family_verified = False


# Gather non-family solutions in the finite box.
nonfamily = []
for i in range(1, I_MAX + 1):
    for j in range(1, J_MAX + 1):
        for n in range(0, N_MAX + 1):
            lhs = T[n] ** i
            for m in range(0, M_MAX + 1):
                for ell in range(0, m + 1):
                    if lhs == F[m] ** j + F[ell] ** j and not in_trivial_family(i, j, n, m, ell):
                        nonfamily.append((i, j, n, m, ell, T[n], F[m], F[ell]))

by_ji = sorted(nonfamily, key=lambda t: (t[1], t[0], t[2], t[3], t[4]))
by_ji_jgt1 = [u for u in by_ji if u[1] > 1]
by_ji_jgt1_both_gt1 = [u for u in by_ji_jgt1 if min(u[6], u[7]) > 1 and u[4] > 0]

print("box=", (I_MAX, J_MAX, N_MAX, M_MAX))
print("family_verified=", family_verified)
print("nonfamily_total=", len(nonfamily))
print("first_nonfamily_by_(j,i,n,m,ell)=", by_ji[0] if by_ji else None)
print("first_nonfamily_j_gt_1=", by_ji_jgt1[0] if by_ji_jgt1 else None)
print("first_nonfamily_j_gt_1_with_Fm_Fell_gt_1_and_ell_gt_0=", by_ji_jgt1_both_gt1[0] if by_ji_jgt1_both_gt1 else None)
