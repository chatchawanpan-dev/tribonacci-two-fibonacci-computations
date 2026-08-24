# Legacy generated-table archive

The focused main-theorem certificate is directly available at
`../main_reduction_table.csv`. This split archive is retained for the older
auxiliary datasets and has been rebuilt so its copy of
`main_reduction_table.csv` is byte-identical to the direct certificate.

Reconstruct the ZIP from the repository root with:

```sh
cat generated_tables_parts/generated_tables.zip.b64.part_*.txt \
  | base64 -d > generated_tables.zip
```

Checksums for release `v1.0.0`:

- reconstructed ZIP SHA-256:
  `35a3bd327f20831f482f573b628412f2ed6c40fa43f3ec40b3cec059fe0debc4`
- concatenated base64 stream SHA-256:
  `8d516b762461018e2be312a36840cfe7c66ff4022a74b1811f62d4faef358825`
- embedded/direct `main_reduction_table.csv` SHA-256:
  `fe8b7823520b06cd9f6ce2cd9714f3df9dc4635a36528d0b6a61012530bdae98`
