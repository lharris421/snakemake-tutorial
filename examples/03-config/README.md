# 03: Configuration

Accompanies [chapter 4](../../04-config.qmd).

The parameter grid, the number of iterations, the seed and the confidence level have
moved out of the Snakefile and into `config.yaml`. The R scripts have moved into `code/`
and share a `setup.R`.

```bash
snakemake --cores 4                          # 200 iterations, ~10 seconds
snakemake --cores 4 --config iterations=20   # smoke test, ~2 seconds
```

Note that changing `iterations` on the command line does *not* trigger a rerun on its
own — see chapter 9 on `--forcerun` for why, and what to do about it.

This directory is a complete, self-contained project: copy it anywhere, run
`git init`, and it works. That is how each example in this book is meant to be
read --- a miniature of a real repository, with one Snakefile at its root, `rds/` for
computed results and `out/` for figures and tables.
