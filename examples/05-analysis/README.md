# 05: A data analysis pipeline

Accompanies [chapter 8](../../08-analysis-pipeline.qmd).

The same ideas applied to consulting work rather than a simulation study: a raw CSV
is cleaned once, models and summaries are built from the cleaned object, and a Quarto
report displays what the scripts produced without recomputing anything.

```bash
snakemake --cores 4     # ends with report.html
```

```
data/trial.csv     raw data (read-only, never modified)
code/clean.R       -> results/analysis.rds
code/model.R       -> results/models.rds
code/table1.R      -> results/table1.rds
code/figure.R      -> results/figure1.png
report.qmd         -> report.html
```

`data/make-raw-data.R` generates the raw file and stands in for the investigator who
sent it to you. It is deliberately not a rule in the Snakefile; see chapter 8.

Requires `quarto` on your PATH plus the R packages `optparse`, `ggplot2` and `knitr`.

This directory is a complete, self-contained project: copy it anywhere, run
`git init`, and it works. That is how each example in this book is meant to be
read --- a miniature of a real repository, with one Snakefile and one `results/`
folder at its root.
