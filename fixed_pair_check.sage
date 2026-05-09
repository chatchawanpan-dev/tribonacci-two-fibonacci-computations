"""
Numerical checkpoint for the fixed-(i,j) framework in Section S:global-powers.

For selected exponent pairs (i,j), this script:
1) enumerates exact solutions of T_n^i = F_m^j + F_ell^j in a finite box,
2) checks the comparability inequalities (eq:nm1-ij, eq:nm2-ij),
3) evaluates the two linear forms Lambda_1 and Lambda_2,
4) verifies the upper bounds used in Steps 3--4 with explicit constants.

Run:
  HOME=/tmp sage fixed_pair_check.sage
"""

from sage.all import RealField, ZZ, log, continued_fraction, polygen


def fib_list(mmax):
    F = [ZZ(0), ZZ(1)]
    for _ in range(2, mmax + 1):
        F.append(F[-1] + F[-2])
    return F


def trib_list(nmax):
    T = [ZZ(0), ZZ(1), ZZ(1)]
    for _ in range(3, nmax + 1):
        T.append(T[-1] + T[-2] + T[-3])
    return T


def solve_box(i, j, nmax, mmax):
    F = fib_list(mmax)
    T = trib_list(nmax)
    sol = []
    for n in range(nmax + 1):
        lhs = T[n] ** i
        for m in range(mmax + 1):
            rhs_m = F[m] ** j
            for ell in range(m + 1):
                if lhs == rhs_m + F[ell] ** j:
                    sol.append((n, m, ell, int(T[n]), int(F[m]), int(F[ell])))
    return sol, F, T


def fixed_ij_constants(i, j, prec=220):
    R = RealField(prec)
    x = polygen(R)
    roots = (x**3 - x**2 - x - 1).roots(multiplicities=False)
    alpha = max(roots)
    sqrt5 = R(5).sqrt()
    phi = (R(1) + sqrt5) / R(2)
    # Tribonacci normalization T_0=0, T_1=T_2=1.
    # The leading coefficient is 1/(-alpha^2+4 alpha-1), not alpha times this.
    a = R(1) / (-alpha**2 + R(4) * alpha - R(1))

    lam = (R(j) * log(phi)) / (R(i) * log(alpha))
    kappa = min(R(1), R(j) / R(i))

    cT = (R(i) / R(2)) * (a + R(1) / R(2)) ** (i - 1)
    cF = (R(j) / R(2)) * (R(1) / sqrt5 + R(1) / R(2)) ** (j - 1)

    cT1 = R(2) * (sqrt5**j) * cT * (alpha ** (R(2) * i - R(1) + R(2) * lam)) * (phi ** (-j))
    cF1 = R(2) * (sqrt5**j) * cF
    Cstar = cT1 + cF1

    A_nm = (R(j) * log(phi)) / (R(i) * log(alpha))
    B_nm = R(2) + (log(R(2)) - R(j) * log(phi)) / (R(i) * log(alpha))
    A_mn = (R(i) * log(alpha)) / (R(j) * log(phi))

    return {
        "R": R,
        "alpha": alpha,
        "phi": phi,
        "sqrt5": sqrt5,
        "a": a,
        "lam": lam,
        "kappa": kappa,
        "cT": cT,
        "cF": cF,
        "Cstar": Cstar,
        "A_nm": A_nm,
        "B_nm": B_nm,
        "A_mn": A_mn,
    }


def analyze_case(i, j, nmax=80, mmax=80):
    const = fixed_ij_constants(i, j)
    R = const["R"]
    alpha = const["alpha"]
    phi = const["phi"]
    sqrt5 = const["sqrt5"]
    a = const["a"]
    kappa = const["kappa"]
    Cstar = const["Cstar"]
    A_nm = const["A_nm"]
    B_nm = const["B_nm"]
    A_mn = const["A_mn"]

    sol, F, T = solve_box(i, j, nmax, mmax)

    comp_fail_1 = []
    comp_fail_2 = []
    max_ratio_L1 = R(0)
    max_ratio_L2 = R(0)

    for (n, m, ell, _, _, _) in sol:
        if n >= 1 and m >= 1:
            if R(n) > A_nm * R(m) + B_nm + R("1e-40"):
                comp_fail_1.append((n, m, ell))
            if R(m) > A_mn * (R(n) - R(1)) + R(2) + R("1e-40"):
                comp_fail_2.append((n, m, ell))

            d = m - ell
            L1 = abs((a**i) * (sqrt5**j) * (alpha ** (i * n)) * (phi ** (-j * m)) - R(1))
            rhs1 = (R(1) + Cstar) * (phi ** (-kappa * d))
            if rhs1 > 0:
                max_ratio_L1 = max(max_ratio_L1, L1 / rhs1)

            L2 = abs((a**i) * (sqrt5**j) * (alpha ** (i * n)) * (phi ** (-j * m)) / (R(1) + phi ** (-j * d)) - R(1))
            rhs2 = Cstar * (phi ** (-kappa * m))
            if rhs2 > 0:
                max_ratio_L2 = max(max_ratio_L2, L2 / rhs2)

    tau = (R(i) * log(alpha)) / (R(j) * log(phi))
    cf = continued_fraction(tau)
    conv = None
    for c in cf.convergents():
        if c.denominator() > 6 * mmax:
            conv = c
            break

    print("CASE (i,j)=", (i, j), "box=", (nmax, mmax))
    print("tribonacci_binet_a=", a.n(20))
    print("solutions_in_box=", len(sol))
    print("kappa=", kappa.n(20))
    print("Cstar=", Cstar.n(20))
    print("comparability_fail_eq_nm1=", len(comp_fail_1))
    print("comparability_fail_eq_nm2=", len(comp_fail_2))
    print("max_ratio_L1_over_rhs1=", max_ratio_L1.n(20))
    print("max_ratio_L2_over_rhs2=", max_ratio_L2.n(20))
    if conv is not None:
        print("first_convergent_q_gt_6M=", (int(conv.numerator()), int(conv.denominator())))
    else:
        print("first_convergent_q_gt_6M=", None)
    print("-" * 70)


if __name__ == "__main__":
    analyze_case(1, 2, nmax=80, mmax=80)
    analyze_case(2, 3, nmax=80, mmax=80)
