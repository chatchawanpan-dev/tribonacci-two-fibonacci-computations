#!/usr/bin/env sage
"""
Feedback-17 corrected Dujella--Petho reduction and numerical certification for
T_n = F_m + F_ell.

This script uses the Tribonacci normalization
T_0=0, T_1=T_2=1 and the corrected Binet coefficient

    A = 1/(-alpha^2 + 4 alpha - 1).

It recomputes:
  1. the first reduction for d=m-ell;
  2. the second reduction for m over all d in the resulting range;
  3. interval lower bounds for the epsilon quantities used in the
     Dujella--Petho lemma, including the nearest-integer certificates.
  4. the minimal polynomial and logarithmic height of A sqrt(5).

Outputs:
  - main_reduction_table.csv
  - a run log with the first-reduction denominator and interval certificate
"""

from sage.all import NumberField, PolynomialRing, QQ, RealField, RealIntervalField, ZZ, log, continued_fraction
import csv

PREC = 1000
R = RealField(PREC)
RI = RealIntervalField(PREC)

x = R["x"].gen()
alpha = max((x**3 - x**2 - x - 1).roots(multiplicities=False))
phi = (R(1) + R(5).sqrt()) / R(2)
Acoef = R(1) / (-alpha**2 + R(4)*alpha - R(1))

# RealIntervalField does not need to factor the cubic here: we enclose the
# high-precision real root in a deliberately wider interval and then propagate
# all subsequent quantities interval-arithmetically.
alpha_radius = R(2) ** (-900)
alpha_i = RI(alpha - alpha_radius, alpha + alpha_radius)
phi_i = (RI(1) + RI(5).sqrt()) / RI(2)
Acoef_i = RI(1) / (-alpha_i**2 + RI(4)*alpha_i - RI(1))

# Certification for the conjugate-root estimate in Lemma 2.1.
# If beta and gamma are the nonreal roots, then beta*gamma=1/alpha and
# Re(beta)=(1-alpha)/2. This avoids nonreal root isolation while keeping the
# calculation interval-arithmetic based.
beta_re_i = (RI(1) - alpha_i) / RI(2)
beta_abs_i = (RI(1) / alpha_i).sqrt()
beta_im_sq_i = RI(1) / alpha_i - beta_re_i**2
beta_im_i = beta_im_sq_i.sqrt()
D_re_i = -(beta_re_i**2 - beta_im_i**2) + RI(4)*beta_re_i - RI(1)
D_im_i = beta_im_i * (RI(4) - RI(2)*beta_re_i)
D_abs_sq_i = D_re_i**2 + D_im_i**2
b_abs_i = RI(1) / D_abs_sq_i.sqrt()

M = ZZ(3) * ZZ(10)**35
A_d = R(10) / log(phi)
A_m = R("6.3") / log(phi)

tau = log(alpha) / log(phi)
tau_i = log(alpha_i) / log(phi_i)
mu = log(Acoef * R(5).sqrt()) / log(phi)
mu_i = log(Acoef_i * RI(5).sqrt()) / log(phi_i)

cf = continued_fraction(tau)
convs = list(cf.convergents()[:260])


def dist_nearest_real(x):
    return abs(x - x.round())


def interval_dist_lower(x_interval, nearest_integer):
    n = RI(nearest_integer)
    y = x_interval - n
    lo = y.lower()
    hi = y.upper()
    if lo <= 0 <= hi:
        return RI(0)
    return min(abs(lo), abs(hi))


def certified_epsilon(mu_interval, q, nearest_mu, nearest_tau):
    q_i = RI(q)
    mu_dist_lb = interval_dist_lower(mu_interval * q_i, nearest_mu)
    tau_dist_ub = abs(tau_i * q_i - RI(nearest_tau)).upper()
    eps_lower = mu_dist_lb - RI(M) * tau_dist_ub
    return eps_lower, mu_dist_lb, tau_dist_ub


def first_positive_for_mu(mu_real, mu_interval, start_k=0):
    for k, conv in enumerate(convs[start_k:], start=start_k):
        q = ZZ(conv.denominator())
        if q <= 6 * M:
            continue
        nearest_mu = ZZ((mu_real * R(q)).round())
        nearest_tau = ZZ((tau * R(q)).round())
        eps_real = dist_nearest_real(mu_real * R(q)) - R(M) * dist_nearest_real(tau * R(q))
        eps_lower, mu_dist_lower, tau_dist_upper = certified_epsilon(
            mu_interval, q, nearest_mu, nearest_tau
        )
        if eps_real > 0 and eps_lower > 0:
            return {
                "k": k,
                "conv": conv,
                "epsilon": eps_real,
                "epsilon_lower": eps_lower,
                "nearest_mu": nearest_mu,
                "nearest_tau": nearest_tau,
                "mu_dist_lower": mu_dist_lower,
                "tau_dist_upper": tau_dist_upper,
            }
    raise RuntimeError("No positive epsilon found")


k1_cert = first_positive_for_mu(mu, mu_i)
k1 = k1_cert["k"]
conv1 = k1_cert["conv"]
eps1 = k1_cert["epsilon"]
eps1_lower = k1_cert["epsilon_lower"]
q1 = ZZ(conv1.denominator())
d_bound_real = log(A_d * R(q1) / eps1) / log(phi)
d_bound_lower_eps = log(A_d * R(q1) / R(eps1_lower.lower())) / log(phi)
d_final = ZZ(d_bound_lower_eps.floor())

rows = []
max_w = R(0)
max_row = None

for d in range(int(d_final) + 1):
    mu_d = log((Acoef * R(5).sqrt()) / (R(1) + phi**(-d))) / log(phi)
    mu_d_i = log((Acoef_i * RI(5).sqrt()) / (RI(1) + phi_i**(-d))) / log(phi_i)
    cert = first_positive_for_mu(mu_d, mu_d_i)
    k = cert["k"]
    conv = cert["conv"]
    eps = cert["epsilon"]
    eps_lower = cert["epsilon_lower"]
    q = ZZ(conv.denominator())
    w = log(A_m * R(q) / eps) / log(phi)
    w_cert = log(A_m * R(q) / R(eps_lower.lower())) / log(phi)
    row = {
        "d": d,
        "k": k,
        "p": str(ZZ(conv.numerator())),
        "q": str(q),
        "epsilon": str(eps.n(50)),
        "epsilon_lower": str(R(eps_lower.lower()).n(50)),
        "nearest_mu_q": str(cert["nearest_mu"]),
        "nearest_tau_q": str(cert["nearest_tau"]),
        "mu_dist_lower": str(R(cert["mu_dist_lower"]).n(50)),
        "tau_dist_upper": str(R(cert["tau_dist_upper"]).n(50)),
        "w": str(w.n(40)),
        "w_certified": str(w_cert.n(40)),
    }
    rows.append(row)
    if w_cert > max_w:
        max_w = w_cert
        max_row = row

out_csv = "main_reduction_table.csv"
with open(out_csv, "w", newline="") as f:
    writer = csv.DictWriter(
        f,
        fieldnames=[
            "d",
            "k",
            "p",
            "q",
            "epsilon",
            "epsilon_lower",
            "nearest_mu_q",
            "nearest_tau_q",
            "mu_dist_lower",
            "tau_dist_upper",
            "w",
            "w_certified",
        ],
    )
    writer.writeheader()
    writer.writerows(rows)

print("corrected_A =", Acoef.n(50))
print("corrected_A_sqrt5 =", (Acoef * R(5).sqrt()).n(50))
print("alpha_interval_radius_exact = 2^-900")
print("alpha_interval_lower =", alpha_i.lower().n(80))
print("alpha_interval_upper =", alpha_i.upper().n(80))
print("beta_re_interval_lower =", beta_re_i.lower().n(80))
print("beta_re_interval_upper =", beta_re_i.upper().n(80))
print("beta_im_abs_interval_lower =", beta_im_i.lower().n(80))
print("beta_im_abs_interval_upper =", beta_im_i.upper().n(80))
print("beta_abs_interval_lower =", beta_abs_i.lower().n(80))
print("beta_abs_interval_upper =", beta_abs_i.upper().n(80))
print("b_abs_interval_lower =", b_abs_i.lower().n(80))
print("b_abs_interval_upper =", b_abs_i.upper().n(80))
print("certified_beta_abs_upper =", beta_abs_i.upper().n(30))
print("certified_beta_decimal_bound =", "0.738")
print("certified_beta_bound_check =", beta_abs_i.upper() < R("0.738"))
print("certified_b_abs_upper =", "0.2600")
print("certified_b_bound_check =", b_abs_i.upper() < R("0.2600"))
P.<X> = PolynomialRing(QQ)
K.<aa> = NumberField(X**3 - X**2 - X - 1)
QK.<Y> = PolynomialRing(K)
L.<ss> = K.extension(Y**2 - 5)
theta = (L(1) / (-L(aa)**2 + 4*L(aa) - 1)) * ss
Ptheta = theta.minpoly()
Ptheta_abs = theta.absolute_minpoly()
Ptheta_abs_integral = (Ptheta_abs * Ptheta_abs.denominator()).change_ring(ZZ)
print("relative_minpoly_A_sqrt5 =", Ptheta)
print("absolute_minpoly_A_sqrt5_monic =", Ptheta_abs)
print("absolute_minpoly_A_sqrt5_integral =", Ptheta_abs_integral)
print("height_A_sqrt5 =", theta.global_height().n(50))
print("tau =", tau.n(50))
print("mu =", mu.n(50))
print("first_reduction_k =", k1)
print("first_reduction_p =", ZZ(conv1.numerator()))
print("first_reduction_q =", q1)
print("first_reduction_q_gt_6M =", q1 > 6 * M)
print("first_reduction_nearest_mu_q =", k1_cert["nearest_mu"])
print("first_reduction_nearest_tau_q =", k1_cert["nearest_tau"])
print("first_reduction_mu_dist_lower =", R(k1_cert["mu_dist_lower"]).n(50))
print("first_reduction_tau_dist_upper =", R(k1_cert["tau_dist_upper"]).n(50))
print("first_reduction_epsilon =", eps1.n(50))
print("first_reduction_epsilon_lower =", R(eps1_lower.lower()).n(50))
print("d_bound_real =", d_bound_real.n(50))
print("d_bound_certified =", d_bound_lower_eps.n(50))
print("d_final =", d_final)
print("rows =", len(rows))
print("max_w_certified_row =", max_row)
print("max_w_certified =", max_w.n(50))
print("m_final =", ZZ(max_w.floor()))
print("wrote", out_csv)
