# 01: A first Snakefile

Accompanies [chapter 2](../../02-first-snakefile.qmd).

Three rules and a `rule all`: two simulations and a figure that depends on both.

```bash
snakemake -n          # dry run: what would be done?
snakemake --cores 2   # do it
```

Simulation output goes to the shared `results/01-first-rules/` folder at the top of
the repository; the figure is written to `out/` here. Both are regenerable and
neither is checked in --- delete them and run `snakemake --cores 2` again.
