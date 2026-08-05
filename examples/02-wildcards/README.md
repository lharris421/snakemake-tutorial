# 02: Wildcards

Accompanies [chapter 3](../../03-wildcards.qmd).

The two near-identical `sim_naive` / `sim_split` rules from example 01 have collapsed
into one `sim` rule with wildcards, and `expand()` turns the parameter grid into the
18 files the figure depends on.

```bash
snakemake -n                                 # 18 simulations + 1 figure
snakemake --cores 4                          # about 10 seconds
snakemake --cores 4 results/sim/n50_rho0_naive.rds   # just one scenario
```
