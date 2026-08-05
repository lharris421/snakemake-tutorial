# 01: A first Snakefile

Accompanies [chapter 2](../../02-first-snakefile.qmd).

Three rules and a `rule all`: two simulations and a figure that depends on both.

```bash
snakemake -n          # dry run: what would be done?
snakemake --cores 2   # do it
```

The simulations write to `rds/` and the figure to `out/`. Both are regenerable and
neither is checked in --- delete them and run `snakemake --cores 2` again.

This directory is a complete, self-contained project: copy it anywhere, run
`git init`, and it works. That is how each example in this book is meant to be
read --- a miniature of a real repository, with one Snakefile at its root, `rds/` for
computed results and `out/` for figures and tables.
