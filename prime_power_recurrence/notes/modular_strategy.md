# Modular-Method Strategy Notes

## Equation

Study

```tex
F_m^r + F_\ell^r = T_n^p,
```

with \(r,p\) prime, \(m\ge \ell\ge 0\), and the primitive nonzero condition

```tex
F_mF_\ell T_n \ne 0,\qquad \gcd(F_m,F_\ell,T_n)=1.
```

The current manuscript already gives effective computability for fixed
\((i,j)\) in

```tex
T_n^i = F_m^j + F_\ell^j.
```

The new goal is a modular-method theorem for varying prime exponent \(p\).

## First Conjecture

For prime \(r,p\), there are no primitive nonzero solutions of

```tex
F_m^r + F_\ell^r = T_n^p.
```

The bounded searches should be cited as evidence, not as proof.

## Why Start With r = 3

For \(r=3\), the equation

```tex
a^3+b^3=c^p
```

has a standard Frey curve

```tex
E_{a,b}: y^2 = x^3 + 3abx + (b^3-a^3),
```

with

```tex
\Delta(E_{a,b}) = -2^4 3^3 (a^3+b^3)^2.
```

Substituting \(a=F_m\), \(b=F_\ell\), \(c=T_n\), the discriminant becomes

```tex
\Delta(E_{m,\ell}) = -2^4 3^3 T_n^{2p}.
```

In a primitive solution, primes dividing \(T_n\) are expected to be removable
from the mod-\(p\) conductor after level lowering. The remaining conductor
should be controlled by \(2,3\) and primes dividing \(F_mF_\ell\), with special
care at primes \(2\) and \(3\).

## Main Proof Tasks

1. Remove degenerate cases:
   \(\ell=0\), \(T_n\in\{0,1\}\), \(F_\ell=F_m\), and the small power-collapse
   identities already present in the manuscript.

2. Establish a clean primitive setup:
   use
   \(\gcd(F_m,F_\ell)=F_{\gcd(m,\ell)}\), so primitive solutions force strong
   restrictions on \(\gcd(m,\ell)\).

3. Prove irreducibility of the mod-\(p\) representation for the Frey curve,
   at least for \(p\ge 5\), or cite/apply a known criterion once the curve's
   rational isogenies are understood.

4. Compute the minimal discriminant and conductor of \(E_{F_m,F_\ell}\).
   The Magma file `frey_33p.m` starts this.

5. Apply level lowering. The expected lowered level should remove primes
   dividing \(T_n\). The key technical point is to determine exactly which
   primes dividing \(F_mF_\ell\) remain.

6. Compare with newforms at the lowered level:
   use trace congruences
   \(a_q(E)\equiv a_q(f)\pmod{\mathfrak p}\)
   at auxiliary primes \(q\nmid 6F_mF_\ell T_n\).

7. Use recurrence restrictions:
   ranks of apparition and primitive prime divisors for Fibonacci and
   Tribonacci terms should force auxiliary primes with incompatible traces.

## Secondary Branches

- \(r=2\): useful but may be better handled through Gaussian-integer descent
  before modular methods.
- \(r=5\): likely requires Frey data over a real subfield of a cyclotomic
  field or a more specialized generalized-Fermat construction. Treat this
  after the \(r=3\) case is understood.

## Immediate Computation Questions

- Does the exact search find any primitive nonzero solution for
  \(r,p\le 31\), \(m,n\le 300\)?
- For the known imprimitive \(r=3\) examples, what conductors do the Frey curves
  have after minimization?
- Which small moduli give local obstructions for nonzero residue solutions?

