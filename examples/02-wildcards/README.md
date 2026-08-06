# 02: Wildcards

Accompanies [chapter 4](../../04-wildcards.qmd).

The two near-identical `sim_naive` / `sim_split` rules from example 01 have collapsed
into one `sim` rule with wildcards, and `expand()` turns the parameter grid into the
18 files the figure depends on.

```bash
snakemake -n                                 # 18 simulations + 1 figure
snakemake --cores 4                          # about 10 seconds
snakemake --cores 4 rds/sim/n50_rho0_naive.rds   # just one scenario
```

This directory is a complete, self-contained project: copy it anywhere, run
`git init`, and it works. That is how each example in this book is meant to be
read --- a miniature of a real repository, with one Snakefile at its root, `rds/` for
computed results and `out/` for figures and tables.
