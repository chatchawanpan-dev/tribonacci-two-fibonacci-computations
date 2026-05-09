# Computational Verification Archive

This directory contains the code and generated data for the finite verification
steps in the Tribonacci/Fibonacci manuscript.  Filenames have been shortened for
GitHub while keeping their purpose explicit.

Run commands from this `computations/` directory.  The main-theorem reduction is
regenerated with

```sh
HOME=/private/tmp sage main_reduction.sage
```

The command writes `main_reduction_table.csv`; redirect terminal output to
`main_reduction_log.txt` when reproducing the archived log.

## Main Theorem Verification

| File | Purpose | SHA-256 |
|---|---|---|
| `main_reduction.sage` | Dujella--Petho reduction, height certification, and interval bounds | `9363dcc8e1a181273b562e13556a33a2b2bd5b6b577bc363eb99aaf852d44774` |
| `main_reduction_table.csv` | Certified reduction table for \(d=0,\ldots,185\) | `a70b66b6d106aa8edbf335c7178dbfbfa1317533a745fd24d05801461725e611` |
| `main_reduction_log.txt` | Regeneration log for the reduction and interval checks | `47d0827a2d5d074389fb97faea554aed9e8a9bba5548222083548a77ec414c03` |
| `verify_main_theorem.sage` | Exact finite search in the reduced box | `b5eb190cdd92e56a214d3351273e09611288686025ed1c9ff65dc193aef7c88d` |
| `verify_main_theorem_output.txt` | Output of the exact finite search | `17623b4415a9b6bc6a28fe9d844f49e05f46aa92ad6cb5bb5b0dad6d07988039` |
| `fixed_pair_check.sage` | Fixed-\((i,j)\) checkpoint examples | `375d370c09639f11b6d82a4c0140a91169ba221682f4101762a8000766654ee2` |
| `fixed_pair_check_output.txt` | Output of the fixed-pair checkpoint | `1c22298bdffd5fad4cdde2d19efe01768795221990117f74d63a12347bad49c4` |

## Power-Variant Bounded Search

| File | Purpose | SHA-256 |
|---|---|---|
| `power_variant_search.sage` | Exact bounded search for \(T_n^i=F_m^j+F_\ell^j\) | `68352a96311fb53afa3c91dd9e0b44781ebb3394bf30a88da43188abb52366c7` |
| `power_variant_i19_n300.csv` | Output for \(1\le i,j\le19\), \(n,m,\ell\le300\) | `e0c84526ef4e137417ede1a8cb1ec7fc2c1b714dc0435eab19962205761ed16e` |
| `power_variant_i49_n300.csv` | Output for \(1\le i,j\le49\), \(n,m,\ell\le300\) | `aa2988f8ac6e79b0c40d254c3aa54087a1d85c398eb0ad42ef932d8654885a1c` |
| `power_variant_i100_n100.csv` | Output for \(1\le i,j\le100\), \(n,m,\ell\le100\) | `59778ffa340fd75833ba2ff379cafc58eb833707275ec4a2a7c6e02075356636` |
| `power_variant_i100_n100_log.txt` | Search log for the \(100\times100\) bounded window | `a3a467fcd57b3521be6e39f1a97f6eb2679856e443f5ca16e520c189dc6a983d` |
| `power_variant_check.sage` | Classifies bounded-search rows against the stated families | `82162737720d7b6287c5543352430261f928d3b1b3d5c981dadce2a5f09731ac` |
| `power_variant_check_default_output.txt` | Classification check for the default bounded windows | `bc3174f218ddd05fd17e3ddfcadf8f361a881b9a0f72ce595600c8f62ba5e50b` |
| `power_variant_check_i100_output.txt` | Classification check for the \(100\times100\) window | `84babda99e0fed63fe4a129ae2a7b2b6ab2e58d84d999ee3defad1b225837ca0` |
| `power_variant_summary.sage` | Summarizes nontrivial families in bounded outputs | `bbfc35d0a9259957d35291d78995184f72105373794dd2ff566dfcc3efc3b560` |
| `power_variant_summary_output.txt` | Output of the bounded-family summary | `34e4469ee3ee117c7d2beab0e3f08f9c8221dd7e29cf88f1ec5fe17d1310c8db` |
| `verify_small_families.sage` | Direct verification of listed small families | `bcae402384d5a02ec75e2775517cfe492fa57a824d490eed72b1356f06f78bf6` |
| `verify_small_families_output.txt` | Output of the small-family verification | `443e35297d4a7273d3cad4b49a9163f4e44d4cf7e5e2274376441ad0b55a09d1` |

## Prime-Power Recurrence Search

| File | Purpose | SHA-256 |
|---|---|---|
| `prime_power_recurrence/README.md` | Overview and run commands | `e8eadafce73eb200bc549eb8f6e0d1c4dcf6d6c515b9342d3fe0eed8fecda827` |
| `prime_power_recurrence/notes/search_summary.md` | Summary of bounded searches | `18bd883e2d5b1dafffa2cd4455476bf7e53100e6aa5a4d6beb47383bfd4e8548` |
| `prime_power_recurrence/notes/modular_strategy.md` | Modular-method roadmap notes | `8f928a51a11d2593f0f598d1c1a5e9a9fc99b4d1c28e35d9562da1c061020d2a` |
| `prime_power_recurrence/scripts/search_prime_powers.py` | Python exact bounded search | `c5a97049ade01f3b2eed86746905ac1cc17e691016ae7f0bf05b55dae86e2cc7` |
| `prime_power_recurrence/magma/search_prime_powers.m` | Magma exact bounded search | `a863ed6472665da20109ba6c2e243e0ae6b22dfd1bf371dd4f9ca310174c57b1` |
| `prime_power_recurrence/magma/frey_33p.m` | Frey-curve helper for signature \((3,3,p)\) | `f8281b8c3a7d181bbbf52886339a3ebe61820a8181d3db7a93ba9ad4b13a15fc` |
| `prime_power_recurrence/magma/local_sieve.m` | Local sieve experiments | `b3d842c6314db01c7d072f6e6429dbda305e264609cfd039a219548b53d3fbb8` |
| `prime_power_recurrence/data/prime_power_m300_n300.csv` | Search A data | `de9acc088ea4127bdf5939170c06dc753be94e2c56c5eb5c4710a6082ff7f072` |
| `prime_power_recurrence/data/prime_power_m300_n300_summary.txt` | Search A summary | `0125a383bea70e869d25d2c37f0d0c223a6a1a9479d8de50bed7825041ee9985` |
| `prime_power_recurrence/data/prime_power_m500_n500_p47.csv` | Search B data | `1511ce24e684957b1e031a7d588e00a2b9b436658f22a4bc5bbf8ca9439153e3` |
| `prime_power_recurrence/data/prime_power_m500_n500_p47_summary.txt` | Search B summary | `331781888d10598f88d9ec279f8e03d36a4cff444d19a38edb84c487498d0014` |
| `prime_power_recurrence/data/prime_power_magma.csv` | Magma search data | `25faca1795823a2cb00f02c025ecbcbe694688c22aef72f04aed8dd8d0858bdb` |
| `prime_power_recurrence/data/prime_power_magma_summary.txt` | Magma search summary | `64f839e78e21022f1df678760b069a5208857a4bd32c77aeea797a7727f5acbd` |
| `prime_power_recurrence/data/local_sieve_summary.txt` | Local sieve output summary | `41cd740e6654fc1be025561256273a733c125cde6612467e28233f144e067bab` |
