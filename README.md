# Snakemake for biostatisticians

A hands-on tutorial on using [Snakemake](https://snakemake.readthedocs.io/) for
reproducible simulation studies, manuscripts and analysis reports.

**Read it at <https://lharris421.github.io/snakemake-tutorial/>.**

Built as a [Quarto](https://quarto.org/) book.

## Publishing

GitHub Pages serves the `docs/` folder from `main`, so the rendered site is
committed along with the source. After editing a chapter:

```bash
quarto render
git add -A && git commit -m "..." && git push
```

If you would rather have the site rebuild itself on every push,
`tools/github-pages-workflow.yml` is a ready-made GitHub Actions workflow. Moving
it to `.github/workflows/` requires a token with the `workflow` scope
(`gh auth refresh -s workflow`), after which you would switch the Pages source
from "main /docs" to "GitHub Actions" and can stop committing `docs/`.

## Structure

```
index.qmd, 01-*.qmd … 10-*.qmd   the chapters
_common.R                        embed_file() / transcript() helpers
examples/                        five complete, runnable projects
transcripts/                     terminal output, captured from real runs
tools/capture-transcripts.sh     regenerates transcripts/
```

Every code block in the book is read from a file in `examples/` at render time, and
every terminal transcript is captured from an actual run. Nothing in the text is
typed by hand, so the tutorial cannot drift away from code that works.

## The examples

Each one is a complete, self-contained project — copy the directory anywhere, run
`git init`, and it works. That is deliberate: each is a miniature of a real
repository, with one Snakefile at its root, `rds/` for computed results and `out/`
for figures and tables --- the layout the book argues for.

| | Chapter | Adds |
|---|---|---|
| `examples/01-first-rules` | 2–3 | rules, `rule all`, dry runs, what triggers a rerun |
| `examples/02-wildcards` | 4 | wildcards, `expand()` |
| `examples/03-config` | 5 | `config.yaml`, results keyed by iteration count |
| `examples/04-manuscript` | 7 | figure and table rules, `latexmk`, logs, benchmarks |
| `examples/05-analysis` | 8 | cleaning → models → tables → Quarto report |

```bash
cd examples/01-first-rules
snakemake --cores 2
```

## Building the book

```bash
quarto render                        # writes docs/
bash tools/capture-transcripts.sh    # re-run every example, refresh transcripts/
bash tools/verify-examples.sh        # build all five examples from scratch
```

Rendering needs Quarto, R with `ggplot2`, and the packages each example uses;
`examples/04-manuscript` additionally needs a LaTeX installation with `latexmk`
([TinyTeX](https://yihui.org/tinytex/) is the easy route) plus `tidyr` and
`kableExtra`, and `examples/05-analysis` needs `knitr`.

Written against Snakemake 9.13. Several flags used here do not exist in version 7
or earlier.

## Credit

The format and spirit are modeled on the [University of Iowa Biostatistics HPC
tutorial](https://iowabiostat.github.io/hpc/) by Patrick Breheny and Grant Brown.
The manuscript conventions in chapter 7 follow Patrick Breheny's [manuscript
template](https://github.com/pbreheny/manuscript-template).
