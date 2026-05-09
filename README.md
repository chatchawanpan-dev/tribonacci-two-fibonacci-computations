# tribonacci-two-fibonacci-computations

Computational files for the Tribonacci equation manuscript.

The generated tables that are larger than the ordinary source/output files are stored as a split base64 archive in `generated_tables_parts/`.

To reconstruct the archive, download the part files and run:

```sh
cat generated_tables_parts/generated_tables.zip.b64.part_*.txt | base64 -d > generated_tables.zip
unzip generated_tables.zip
```

The archive SHA-256 is `a250f501e6c2df9add9defb0bbead5f77ef5f697b3cb780b00a45f7970957e7e`.
The base64 stream SHA-256 is `87efe9f791710dc3b2c4d7d91e1a17402aac502f9e2fec24f29fd3e0ff428dae`.
