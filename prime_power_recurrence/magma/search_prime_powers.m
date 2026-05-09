// Exact Magma search for F_m^r + F_ell^r = T_n^p.
//
// Adjust the constants below and run:
//   /Applications/Magma/magma magma/search_prime_powers.m

SetColumns(0);

RValues := [ 2, 3, 5, 7, 11, 13 ];
PValues := [ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31 ];
MMax := 300;
NMax := 300;
OutputFile := "data/prime_power_magma.csv";

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

function TripleGCD(a, b, c)
    return GCD(GCD(Abs(a), Abs(b)), Abs(c));
end function;

function ClassLabel(r, p, ell, m, n, fl, fm, tn, g)
    if tn eq 0 and fm eq 0 and fl eq 0 then
        return "zero";
    end if;
    if fl eq 0 then
        if p eq r and fm eq tn then
            return "one-zero-side: p=r and F_m=T_n";
        end if;
        return "one-zero-side";
    end if;
    if tn in {1, 2, 4, 13, 81} or fm in {1, 2, 3, 8, 13} or fl in {1, 2, 3, 8, 13} then
        if g gt 1 then
            return "small-value imprimitive";
        end if;
        return "small-value";
    end if;
    if g gt 1 then
        return "imprimitive";
    end if;
    return "primitive-nonzero";
end function;

function RightMap(F, r, M)
    A := AssociativeArray(Integers());
    FPow := [ F[k + 1]^r : k in [0..M] ];
    for m in [0..M] do
        for ell in [0..m] do
            v := FPow[m + 1] + FPow[ell + 1];
            if IsDefined(A, v) then
                pairs := A[v];
            else
                pairs := [* *];
            end if;
            Append(~pairs, <ell, m>);
            A[v] := pairs;
        end for;
    end for;
    return A;
end function;

F := FibonacciList(MMax);
T := TribonacciList(NMax);

out := Open(OutputFile, "w");
fprintf out, "r,p,ell,m,n,F_ell,F_m,T_n,value,gcd,primitive,nonzero,classification\n";

total := 0;
primitiveNonzero := 0;

for r in RValues do
    printf "Building right map for r=%o\n", r;
    right := RightMap(F, r, MMax);
    for p in PValues do
        countRP := 0;
        for n in [0..NMax] do
            target := T[n + 1]^p;
            if IsDefined(right, target) then
                for pair in right[target] do
                    ell := pair[1];
                    m := pair[2];
                    fl := F[ell + 1];
                    fm := F[m + 1];
                    tn := T[n + 1];
                    g := TripleGCD(fl, fm, tn);
                    primitive := g eq 1;
                    nonzero := fl ne 0 and fm ne 0 and tn ne 0;
                    label := ClassLabel(r, p, ell, m, n, fl, fm, tn, g);
                    fprintf out, "%o,%o,%o,%o,%o,%o,%o,%o,%o,%o,%o,%o,%o\n",
                        r, p, ell, m, n, fl, fm, tn, target, g,
                        primitive select 1 else 0,
                        nonzero select 1 else 0,
                        label;
                    total +:= 1;
                    countRP +:= 1;
                    if primitive and nonzero then
                        primitiveNonzero +:= 1;
                    end if;
                end for;
            end if;
        end for;
        if countRP gt 0 then
            printf "r=%o p=%o solutions=%o\n", r, p, countRP;
        end if;
    end for;
end for;

delete out;

printf "Total solutions: %o\n", total;
printf "Primitive nonzero solutions: %o\n", primitiveNonzero;
printf "Wrote %o\n", OutputFile;
