# 04: Simulation to manuscript

Accompanies chapters [6](../../06-figures-tables.qmd) and [7](../../07-manuscript.qmd).

The capstone. 18 simulations feed a figure and a table, which feed two LaTeX
documents (a journal version and a double-spaced review version) that share all of
their content through `main.tex`.

```bash
snakemake --cores 4            # ~15 seconds, ends with build/paper.pdf
snakemake --cores 4 results/figure1.pdf   # just the figure
```

Then edit `code/sim.R` and run `snakemake --cores 4` again: the simulations, the
figure, the table and both PDFs all rebuild, in order. That cascade is the argument
for the whole approach.

Requires a LaTeX installation providing `latexmk` ([TinyTeX](https://yihui.org/tinytex/)
is the easy option) plus the R packages `optparse`, `ggplot2`, `tidyr` and `kableExtra`.

| Directory | Contents |
|---|---|
| `code/` | R scripts, all sourcing `code/setup.R` |
| `results/` | figures, tables and simulation output (regenerable) |
| `logs/` | one log per job, so a failure is easy to find |
| `benchmarks/` | runtime and memory per simulation |
| `build/` | compiled PDFs |

This directory is a complete, self-contained project: copy it anywhere, run
`git init`, and it works. That is how each example in this book is meant to be
read --- a miniature of a real repository, with one Snakefile and one `results/`
folder at its root.
