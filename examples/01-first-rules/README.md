# 01: A first Snakefile

Accompanies [chapter 2](../../02-first-snakefile.qmd).

Three rules and a `rule all`: two simulations and a figure that depends on both.

```bash
snakemake -n          # dry run: what would be done?
snakemake --cores 2   # do it
```

Everything is written to `results/`, which is regenerable and not checked in.
Delete it and run `snakemake --cores 2` again to rebuild from scratch.

This directory is a complete, self-contained project: copy it anywhere, run
`git init`, and it works. That is how each example in this book is meant to be
read --- a miniature of a real repository, with one Snakefile and one `results/`
folder at its root.
