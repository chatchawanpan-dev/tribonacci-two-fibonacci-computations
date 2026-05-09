// Frey curve experiments for the signature (3,3,p) equation
//
//     a^3 + b^3 = c^p.
//
// For the recurrence problem, use a=F_m, b=F_ell, c=T_n. A standard Frey curve
// for this signature is
//
//     E_{a,b}: y^2 = x^3 + 3ab x + (b^3-a^3).
//
// Its discriminant is -2^4 * 3^3 * (a^3+b^3)^2, so if a^3+b^3=c^p then
// primes dividing c are candidates for removal after level lowering.

SetColumns(0);

function FibonacciList(N)
    F := [ Integers() | 0 : i in [0..N] ];
    if N ge 1 then
        F[2] := 1;
    end if;
    for k in [2..N] do
        F[k + 1] := F[k] + F[k - 1];
    end for;
    return F;
end function;

function TribonacciList(N)
    T := [ Integers() | 0 : i in [0..N] ];
    if N ge 1 then
        T[2] := 1;
    end if;
    if N ge 2 then
        T[3] := 1;
    end if;
    for k in [3..N] do
        T[k + 1] := T[k] + T[k - 1] + T[k - 2];
    end for;
    return T;
end function;

function Frey33(a, b)
    return EllipticCurve([ 0, 0, 0, 3*a*b, b^3 - a^3 ]);
end function;

procedure PrintFrey33Data(m, ell, n, p)
    M := Max([m, ell]);
    F := FibonacciList(M);
    T := TribonacciList(n);
    a := F[m + 1];
    b := F[ell + 1];
    c := T[n + 1];
    if a^3 + b^3 ne c^p then
        error "The requested tuple does not satisfy a^3+b^3=c^p";
    end if;

    E := Frey33(a, b);
    Emin := MinimalModel(E);

    printf "Tuple: m=%o ell=%o n=%o p=%o\n", m, ell, n, p;
    printf "a=F_m=%o\nb=F_ell=%o\nc=T_n=%o\n", a, b, c;
    printf "E: %o\n", E;
    printf "Discriminant(E)=%o\n", Discriminant(E);
    printf "Minimal discriminant=%o\n", Discriminant(Emin);
    printf "Conductor=%o\n", Conductor(Emin);
    printf "jInvariant=%o\n", jInvariant(Emin);
    printf "Bad primes=%o\n", BadPrimes(Emin);
end procedure;

// Known imprimitive examples from the power-collapse families.
PrintFrey33Data(3, 3, 4, 2);  // 2^3 + 2^3 = 4^2
PrintFrey33Data(6, 6, 4, 5);  // 8^3 + 8^3 = 4^5
