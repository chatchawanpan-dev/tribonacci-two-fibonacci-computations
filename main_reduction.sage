#!/usr/bin/env sage
"""
Certified reductions for T_n = F_m + F_ell.

This focused-version script certifies:

  * the real algebraic root alpha and every derived real quantity;
  * the first 100 continued-fraction coefficients of
        tau = log(alpha) / log(phi);
  * genuine nearest-integer witnesses in every Dujella--Petho row;
  * outward-rounded epsilon lower bounds and threshold upper bounds;
  * the minimal polynomial and height bound for a*sqrt(5);
  * the conjugate estimate used in the Tribonacci Binet error.

It writes main_reduction_table.csv.  All proof decisions are made with exact
integers or RealIntervalField enclosures.  Ordinary RealField values are used
only for non-decisive display.
"""

from sage.all import (
    AA,
    QQ,
    QQbar,
    NumberField,
    PolynomialRing,
    RealField,
    RealIntervalField,
    ZZ,
    ceil,
    floor,
)
from sage.env import SAGE_VERSION
import csv
import platform


PREC = 2048
R = RealField(PREC)
RI = RealIntervalField(PREC)

P = PolynomialRing(QQ, "X")
X = P.gen()
trib_poly = X**3 - X**2 - X - 1
assert trib_poly.is_irreducible()
alpha_exact = trib_poly.roots(AA, multiplicities=False)[0]
alpha_i = RI(alpha_exact)
phi_i = (RI(1) + RI(5).sqrt()) / RI(2)
Acoef_i = RI(1) / (-alpha_i**2 + RI(4) * alpha_i - RI(1))

tau_i = alpha_i.log() / phi_i.log()
mu_i = (Acoef_i * RI(5).sqrt()).log() / phi_i.log()

M = ZZ(3) * ZZ(10) ** 35
A_d_i = RI(10) / phi_i.log()
A_m_i = RI("6.3") / phi_i.log()


def exact_endpoint(x):
    """Return the exact dyadic rational represented by an MPFR endpoint."""
    return QQ(x.exact_rational())


def decimal_lower(x, digits=24):
    """A fixed-point decimal guaranteed to be <= the positive endpoint x."""
    scale = ZZ(10) ** digits
    n = ZZ(floor(exact_endpoint(x) * scale))
    return f"{n // scale}.{n % scale:0{digits}d}"


def decimal_upper(x, digits=24):
    """A fixed-point decimal guaranteed to be >= the positive endpoint x."""
    scale = ZZ(10) ** digits
    n = ZZ(ceil(exact_endpoint(x) * scale))
    return f"{n // scale}.{n % scale:0{digits}d}"


def certified_cf(interval, count):
    """
    Certify a continued-fraction prefix by identical endpoint floors.

    The returned list is the exact prefix for every real number in the final
    nested interval, hence in particular for tau.
    """
    current = RI(interval)
    partials = []
    for index in range(count):
        lower_floor = ZZ(floor(current.lower()))
        upper_floor = ZZ(floor(current.upper()))
        if lower_floor != upper_floor:
            raise RuntimeError(
                f"continued-fraction ambiguity at index {index}: "
                f"{lower_floor} != {upper_floor}"
            )
        partials.append(lower_floor)
        remainder = current - RI(lower_floor)
        if remainder.lower() <= 0:
            raise RuntimeError(f"interval contains an integer at index {index}")
        current = RI(1) / remainder
    return partials


def convergents_from_partials(partials):
    p_nm2, p_nm1 = ZZ(0), ZZ(1)
    q_nm2, q_nm1 = ZZ(1), ZZ(0)
    convergents = []
    for a_j in partials:
        p_j = a_j * p_nm1 + p_nm2
        q_j = a_j * q_nm1 + q_nm2
        convergents.append((p_j, q_j))
        p_nm2, p_nm1 = p_nm1, p_j
        q_nm2, q_nm1 = q_nm1, q_j
    return convergents


partials = certified_cf(tau_i, 100)
convergents = convergents_from_partials(partials)


def nearest_distance_bounds(value_i, q):
    """
    Return a certified nearest integer and lower/upper distance endpoints.
    """
    product = value_i * RI(q)
    nearest = ZZ(R(product.center()).round())
    offset = product - RI(nearest)
    if not (offset.lower() > RI("-0.5").lower()):
        raise RuntimeError("nearest-integer interval reaches -1/2")
    if not (offset.upper() < RI("0.5").upper()):
        raise RuntimeError("nearest-integer interval reaches +1/2")
    distance = abs(offset)
    return nearest, distance.lower(), distance.upper()


def certified_row(mu_value_i, k):
    p, q = convergents[k]
    if q <= 6 * M:
        return None
    nearest_mu, mu_lower, mu_upper = nearest_distance_bounds(mu_value_i, q)
    nearest_tau, tau_lower, tau_upper = nearest_distance_bounds(tau_i, q)
    if nearest_tau != p:
        raise RuntimeError(f"convergent numerator is not nearest at k={k}")
    epsilon_i = RI(mu_lower) - RI(M) * RI(tau_upper)
    return {
        "k": k,
        "p": p,
        "q": q,
        "nearest_mu": nearest_mu,
        "nearest_tau": nearest_tau,
        "mu_lower": mu_lower,
        "mu_upper": mu_upper,
        "tau_lower": tau_lower,
        "tau_upper": tau_upper,
        "epsilon_i": epsilon_i,
    }


def first_positive_row(mu_value_i):
    for k in range(len(convergents)):
        row = certified_row(mu_value_i, k)
        if row is not None and row["epsilon_i"].lower() > 0:
            return row
    raise RuntimeError("no certified positive epsilon found")


def threshold_interval(A_i, q, epsilon_lower):
    positive_lower = RI(epsilon_lower)
    if positive_lower.lower() <= 0:
        raise RuntimeError("threshold requested with nonpositive epsilon")
    return (A_i * RI(q) / positive_lower).log() / phi_i.log()


first = first_positive_row(mu_i)
assert first["k"] == 72
assert first["q"] == ZZ("11952668732083860469560629603327231815")
assert convergents[73][1] == ZZ("12725689040428549011872695801566531678")
assert first["epsilon_i"].lower() > RI("0.4").upper()
first_threshold_i = threshold_interval(
    A_d_i, first["q"], first["epsilon_i"].lower()
)
d_final = ZZ(floor(first_threshold_i.upper()))
if d_final != 185:
    raise RuntimeError(f"unexpected d bound: {d_final}")

rows = []
max_threshold_upper = None
max_threshold_d = None
min_epsilon_lower = None
min_epsilon_d = None

for d in range(int(d_final) + 1):
    mu_d_i = (
        (Acoef_i * RI(5).sqrt()) / (RI(1) + phi_i ** (-d))
    ).log() / phi_i.log()
    cert = first_positive_row(mu_d_i)
    threshold_i = threshold_interval(
        A_m_i, cert["q"], cert["epsilon_i"].lower()
    )
    epsilon_lower = cert["epsilon_i"].lower()
    threshold_upper = threshold_i.upper()

    if min_epsilon_lower is None or epsilon_lower < min_epsilon_lower:
        min_epsilon_lower = epsilon_lower
        min_epsilon_d = d
    if max_threshold_upper is None or threshold_upper > max_threshold_upper:
        max_threshold_upper = threshold_upper
        max_threshold_d = d

    rows.append(
        {
            "d": d,
            "k": cert["k"],
            "p": str(cert["p"]),
            "q": str(cert["q"]),
            "q_gt_6M": str(cert["q"] > 6 * M),
            "nearest_mu_q": str(cert["nearest_mu"]),
            "nearest_tau_q": str(cert["nearest_tau"]),
            "mu_dist_lower": decimal_lower(cert["mu_lower"], 30),
            "mu_dist_upper": decimal_upper(cert["mu_upper"], 30),
            "tau_dist_lower": decimal_lower(cert["tau_lower"], 80),
            "tau_dist_upper": decimal_upper(cert["tau_upper"], 80),
            "epsilon_lower": decimal_lower(epsilon_lower, 30),
            "threshold_upper": decimal_upper(threshold_upper, 20),
        }
    )

if min_epsilon_lower <= RI("0.00049").upper():
    raise RuntimeError("uniform epsilon lower bound 0.00049 failed")
if max_threshold_upper >= RI("199").lower():
    raise RuntimeError("uniform m threshold below 199 failed")
if set(row["k"] for row in rows) - {72, 73}:
    raise RuntimeError("unexpected convergent index in second reduction")
assert len(rows) == 186
assert [row["d"] for row in rows] == list(range(186))
assert ZZ(floor(max_threshold_upper)) == 198

with open("main_reduction_table.csv", "w", newline="") as handle:
    writer = csv.DictWriter(
        handle,
        fieldnames=[
            "d",
            "k",
            "p",
            "q",
            "q_gt_6M",
            "nearest_mu_q",
            "nearest_tau_q",
            "mu_dist_lower",
            "mu_dist_upper",
            "tau_dist_lower",
            "tau_dist_upper",
            "epsilon_lower",
            "threshold_upper",
        ],
    )
    writer.writeheader()
    writer.writerows(rows)


first_certificate = {
    "cf_indexing": "zero_based",
    "k": first["k"],
    "p": str(first["p"]),
    "q": str(first["q"]),
    "q_gt_6M": str(first["q"] > 6 * M),
    "nearest_mu_q": str(first["nearest_mu"]),
    "nearest_tau_q": str(first["nearest_tau"]),
    "mu_dist_lower": decimal_lower(first["mu_lower"], 40),
    "mu_dist_upper": decimal_upper(first["mu_upper"], 40),
    "tau_dist_lower": decimal_lower(first["tau_lower"], 90),
    "tau_dist_upper": decimal_upper(first["tau_upper"], 90),
    "epsilon_lower": decimal_lower(first["epsilon_i"].lower(), 40),
    "threshold_upper": decimal_upper(first_threshold_i.upper(), 30),
}
with open("first_reduction_certificate.csv", "w", newline="") as handle:
    writer = csv.DictWriter(handle, fieldnames=list(first_certificate))
    writer.writeheader()
    writer.writerow(first_certificate)


# Certified conjugate estimates for the Tribonacci error.
beta_re_i = (RI(1) - alpha_i) / RI(2)
beta_abs_i = (RI(1) / alpha_i).sqrt()
beta_im_i = (RI(1) / alpha_i - beta_re_i**2).sqrt()
den_re_i = -(beta_re_i**2 - beta_im_i**2) + RI(4) * beta_re_i - RI(1)
den_im_i = beta_im_i * (RI(4) - RI(2) * beta_re_i)
b_abs_i = RI(1) / (den_re_i**2 + den_im_i**2).sqrt()
assert beta_abs_i.upper() < RI("0.738").lower()
assert b_abs_i.upper() < RI("0.2600").lower()


# Exact minimal polynomial and an interval height check for a*sqrt(5).
K = NumberField(trib_poly, "aa")
aa = K.gen()
QK = PolynomialRing(K, "Y")
Y = QK.gen()
L = K.extension(Y**2 - 5, "ss")
ss = L.gen()
theta = (L(1) / (-L(aa) ** 2 + 4 * L(aa) - 1)) * ss
theta_minpoly = theta.absolute_minpoly()
theta_integral = (
    theta_minpoly * theta_minpoly.denominator()
).change_ring(ZZ)
expected_theta_integral = 1936 * X**6 - 880 * X**4 + 100 * X**2 - 125
assert P(theta_integral) == expected_theta_integral
assert P(theta_integral).is_irreducible()
theta_roots = theta_integral.roots(QQbar)
theta_moduli_i = [RI(abs(root)) for root, multiplicity in theta_roots for _ in range(multiplicity)]
assert len(theta_moduli_i) == 6
assert max(modulus.upper() for modulus in theta_moduli_i) < RI("0.752").lower()
height_theta_i = RI(abs(theta_integral.leading_coefficient())).log() / RI(6)
assert height_theta_i.upper() < RI("1.2614").lower()


# Conservative bounds printed in the paper.
first_conservative_i = threshold_interval(A_d_i, first["q"], RI("0.4").lower())
q73 = convergents[73][1]
second_conservative_i = threshold_interval(A_m_i, q73, RI("0.00049").lower())


# Directed checks for the numerical Matveev and coarse scalar chains.
matveev_first_i = (
    RI("1.4")
    * RI(30) ** 6
    * RI(3) ** (RI(9) / RI(2))
    * RI(6) ** 2
    * (RI(1) + RI(6).log())
    * RI("8.3")
    * RI("1.22")
    * RI("1.45")
)
matveev_second_i = (
    RI("1.4")
    * RI(30) ** 7
    * RI(4) ** (RI(9) / RI(2))
    * RI(6) ** 2
    * (RI(1) + RI(6).log())
    * RI("8.3")
    * RI("1.22")
    * RI("1.45")
)
assert matveev_first_i.upper() < RI("2.113e14").lower()
assert matveev_second_i.upper() < RI("2.3134e16").lower()
assert (RI(3) * phi_i.log()).upper() < RI("1.4437").lower()
assert (RI(6) * RI(2).log()).upper() < RI("4.1589").lower()

coarse_product_i = RI("6.98e16") * RI("4.40e14")
assert coarse_product_i.upper() < RI("3.072e31").lower()

M0_i = RI(3) * RI(10) ** 35
one_plus_log_M0_i = RI(1) + M0_i.log()
g_M0_i = (
    RI("3.072e31") * one_plus_log_M0_i**2
    + RI("2.00e17") * one_plus_log_M0_i
    + RI(3)
)
gprime_M0_i = (
    RI("6.144e31") * one_plus_log_M0_i + RI("2.00e17")
) / M0_i
assert one_plus_log_M0_i.upper() < RI(83).lower()
assert g_M0_i.upper() < RI("2.12e35").lower()
assert g_M0_i.upper() < M0_i.lower()
assert gprime_M0_i.upper() < RI("0.018").lower()

print("sage_version =", SAGE_VERSION)
print("python_version =", platform.python_version())
print("precision_bits =", PREC)
print("alpha_exact_minpoly =", trib_poly)
print("alpha_interval_lower =", decimal_lower(alpha_i.lower(), 80))
print("alpha_interval_upper =", decimal_upper(alpha_i.upper(), 80))
print("certified_cf_terms =", len(partials))
print("cf_partials_0_through_99 =", partials)
for k in (72, 73):
    print(f"p_{k} =", convergents[k][0])
    print(f"q_{k} =", convergents[k][1])
    print(f"q_{k}_gt_6M =", convergents[k][1] > 6 * M)
print("first_reduction_k =", first["k"])
print("first_reduction_nearest_mu_q =", first["nearest_mu"])
print("first_reduction_nearest_tau_q =", first["nearest_tau"])
print(
    "first_reduction_epsilon_lower =",
    decimal_lower(first["epsilon_i"].lower(), 40),
)
print(
    "first_reduction_threshold_upper =",
    decimal_upper(first_threshold_i.upper(), 30),
)
print(
    "first_conservative_threshold_upper =",
    decimal_upper(first_conservative_i.upper(), 30),
)
print("d_final =", d_final)
print("second_reduction_rows =", len(rows))
print("second_reduction_indices =", sorted(set(row["k"] for row in rows)))
print("min_epsilon_d =", min_epsilon_d)
print("min_epsilon_lower =", decimal_lower(min_epsilon_lower, 40))
print("max_threshold_d =", max_threshold_d)
print("max_threshold_upper =", decimal_upper(max_threshold_upper, 30))
print(
    "second_conservative_threshold_upper =",
    decimal_upper(second_conservative_i.upper(), 30),
)
print("m_final =", ZZ(floor(max_threshold_upper)))
print("beta_abs_upper =", decimal_upper(beta_abs_i.upper(), 30))
print("b_abs_upper =", decimal_upper(b_abs_i.upper(), 30))
print("theta_integral_minpoly =", theta_integral)
print("theta_conjugate_modulus_upper =", decimal_upper(max(m.upper() for m in theta_moduli_i), 30))
print("height_theta_upper =", decimal_upper(height_theta_i.upper(), 30))
print("matveev_first_constant_upper =", decimal_upper(matveev_first_i.upper(), 6))
print("matveev_second_constant_upper =", decimal_upper(matveev_second_i.upper(), 6))
print("coarse_product_upper =", decimal_upper(coarse_product_i.upper(), 6))
print("one_plus_log_M0_upper =", decimal_upper(one_plus_log_M0_i.upper(), 12))
print("g_M0_upper =", decimal_upper(g_M0_i.upper(), 6))
print("gprime_M0_upper =", decimal_upper(gprime_M0_i.upper(), 12))
print("wrote first_reduction_certificate.csv")
print("wrote main_reduction_table.csv")
