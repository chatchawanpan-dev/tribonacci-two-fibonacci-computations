# Computation Summary

Date: 2026-05-07

## Exact Search: Prime Exponents

Equation:

```tex
F_m^r + F_\ell^r = T_n^p,\qquad m\ge \ell\ge 0.
```

Primitive nonzero means

```tex
F_mF_\ell T_n \ne 0,\qquad \gcd(F_m,F_\ell,T_n)=1.
```

### Search A

Bounds:

```text
r in {2,3,5,7,11,13}
p in {2,3,5,7,11,13,17,19,23,29,31}
0 <= ell <= m <= 300
0 <= n <= 300
```

Output files:

```text
data/prime_power_m300_n300.csv
data/prime_power_m300_n300_summary.txt
data/prime_power_magma.csv
data/prime_power_magma_summary.txt
```

Result:

```text
total solutions = 351
primitive nonzero solutions = 0
```

Class counts:

```text
zero = 66
one-zero-side = 241
one-zero-side with p=r and F_m=T_n = 36
small-value imprimitive = 8
```

The Python and Magma CSV outputs are identical row-for-row.

### Search B

Bounds:

```text
r in {2,3,5,7,11,13,17,19}
p in {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47}
0 <= ell <= m <= 500
0 <= n <= 500
```

Output files:

```text
data/prime_power_m500_n500_p47.csv
data/prime_power_m500_n500_p47_summary.txt
```

Result:

```text
total solutions = 626
primitive nonzero solutions = 0
```

Class counts:

```text
zero = 120
one-zero-side = 449
one-zero-side with p=r and F_m=T_n = 48
small-value imprimitive = 9
```

## Local Sieve

Magma file:

```text
magma/local_sieve.m
```

Tested:

```text
r in {2,3,5,7}
p in {2,3,5,7,11,13,17}
q prime, q <= 97
```

The corrected primitive-mod-\(q\) sieve found no immediate local obstruction in
this range. This is useful negative information: the desired theorem will need
the Frey curve, level lowering, and trace comparisons, not just elementary
congruence obstructions.

## Frey Curve Check for r = 3

Magma file:

```text
magma/frey_33p.m
```

For the known imprimitive examples

```tex
2^3+2^3=4^2,\qquad 8^3+8^3=4^5,
```

Magma gives the Frey curve

```tex
y^2=x^3+3abx+(b^3-a^3)
```

with minimal discriminant

```text
-110592
```

and conductor

```text
576
```

in both cases. The \(j\)-invariant is \(1728\), reflecting the imprimitive
\(a=b\) power-collapse situation.

## Current Conjectural Direction

The computation supports the following theorem target.

```tex
Let r and p be primes. The equation
F_m^r+F_\ell^r=T_n^p
has no primitive nonzero solutions in integers n,m,\ell with m\ge\ell\ge0.
```

The first modular-method case to attack is \(r=3\), using the Frey curve

```tex
E_{m,\ell}: y^2=x^3+3F_mF_\ell x+(F_\ell^3-F_m^3).
```

