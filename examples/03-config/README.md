# 03: Configuration

Accompanies [chapter 4](../../04-config.qmd).

The iteration count has moved out of the R script and into `config.yaml`, where it
also names the directory results are cached in. The R scripts have moved into
`code/` and share a `setup.R`, which every rule that uses one of them lists as an
input.

```bash
snakemake --cores 4                          # 200 iterations, ~10 seconds
snakemake --cores 4 --config iterations=20   # smoke test, ~2 seconds
```

The two runs do not collide: results are stored under `rds/<iterations>/`, so the
20-iteration smoke test and the 200-iteration run sit side by side and switching
between them costs only the figure. See chapter 4 on why `iterations` is part of
the path while `seed` is a `params` value.

This directory is a complete, self-contained project: copy it anywhere, run
`git init`, and it works. That is how each example in this book is meant to be
read --- a miniature of a real repository, with one Snakefile at its root, `rds/` for
computed results and `out/` for figures and tables.
