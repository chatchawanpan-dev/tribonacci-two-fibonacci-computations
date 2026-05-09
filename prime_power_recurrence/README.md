# Prime-Power Recurrence Search

This folder starts a follow-up project to the Tribonacci/Fibonacci manuscript.
The working equation is the recurrence-restricted generalized Fermat equation

```tex
F_m^r + F_\ell^r = T_n^p, \qquad m \ge \ell \ge 0,
```

where \(r\) is fixed, usually a small prime, and \(p\) is prime.

## Initial Research Target

The first serious target is the primitive nonzero equation

```tex
F_m^r + F_\ell^r = T_n^p, \qquad F_mF_\ell T_n \ne 0,\qquad
\gcd(F_m,F_\ell,T_n)=1.
```

Computational evidence should be collected for prime \(r,p\). The current
bounded searches are expected to show that all observed solutions are
degenerate or imprimitive power-collapse identities coming from small values
such as

```tex
T_3=2,\quad T_4=4,\quad T_6=13,\quad F_3=2,\quad F_6=8,\quad F_7=13.
```

This suggests the following next-paper conjecture.

```tex
Conjecture. Let r and p be primes. The equation
F_m^r + F_\ell^r = T_n^p
has no primitive nonzero solutions in integers n,m,\ell with m \ge \ell \ge 0.
```

The modular-method version should first be pursued for \(r=3\), then \(r=5\).
The case \(r=2\) is also useful, but it has a Gaussian-integer descent flavor
and may not be the best first showcase for Darmon-style Frey curves.

## Contents

- `scripts/search_prime_powers.py`:
  exact bounded search for prime-exponent equations, with primitive/nonzero
  flags and CSV output.
- `magma/search_prime_powers.m`:
  Magma exact search for the same equation.
- `magma/frey_33p.m`:
  Magma functions for the standard Frey curve attached to
  \(a^3+b^3=c^p\), intended for the \(r=3\) branch.
- `magma/local_sieve.m`:
  residue-period local sieve for quick modular obstruction experiments.
- `notes/modular_strategy.md`:
  proof strategy and tasks for turning the computation into a theorem.

## Suggested Workflow

Run the broad exact search:

```bash
python3 scripts/search_prime_powers.py \
  --r-list 2,3,5,7,11,13 \
  --p-list 2,3,5,7,11,13,17,19,23,29,31 \
  --m-max 300 --n-max 300 \
  --csv data/prime_power_m300_n300.csv
```

Run the Magma search:

```bash
/Applications/Magma/magma magma/search_prime_powers.m
```

Run the local sieve:

```bash
/Applications/Magma/magma magma/local_sieve.m
```
