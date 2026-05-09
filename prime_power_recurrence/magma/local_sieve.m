// Local residue-period sieve for
//
//     F_m^r + F_ell^r = T_n^p.
//
// This does not prove the modular-method theorem by itself. It is a quick way
// to find congruence obstructions or learn which small moduli are useless.

SetColumns(0);

RValues := [ 2, 3, 5, 7 ];
PValues := [ 2, 3, 5, 7, 11, 13, 17 ];
Moduli := [ q : q in PrimesInInterval(2, 97) ];

function FibPeriodResidues(q)
    residues := [ Integers() | 0, 1 ];
    a := 0;
    b := 1;
    while true do
        c := (a + b) mod q;
        a := b;
        b := c;
        if a eq 0 and b eq 1 then
            Prune(~residues);
            return residues;
        end if;
        Append(~residues, b);
    end while;
end function;

function TribPeriodResidues(q)
    residues := [ Integers() | 0, 1, 1 ];
    a := 0;
    b := 1;
    c := 1;
    while true do
        d := (a + b + c) mod q;
        a := b;
        b := c;
        c := d;
        if a eq 0 and b eq 1 and c eq 1 then
            Prune(~residues);
            Prune(~residues);
            return residues;
        end if;
        Append(~residues, c);
    end while;
end function;

function HasLocalSolution(r, p, q : PrimitiveMod := true)
    F := Setseq(Seqset(FibPeriodResidues(q)));
    T := Setseq(Seqset(TribPeriodResidues(q)));
    for x in F do
        for y in F do
            for z in T do
                if (not PrimitiveMod) or not (x mod q eq 0 and y mod q eq 0 and z mod q eq 0) then
                    if (x^r + y^r - z^p) mod q eq 0 then
                        return true;
                    end if;
                end if;
            end for;
        end for;
    end for;
    return false;
end function;

for r in RValues do
    for p in PValues do
        obstructing := [];
        for q in Moduli do
            if not HasLocalSolution(r, p, q : PrimitiveMod := true) then
                Append(~obstructing, q);
            end if;
        end for;
        if #obstructing gt 0 then
            printf "r=%o p=%o primitive-mod-q local obstruction primes: %o\n", r, p, obstructing;
        end if;
    end for;
end for;
