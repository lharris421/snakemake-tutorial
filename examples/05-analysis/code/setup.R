## Shared by every script in code/ and by report.qmd.

suppressPackageStartupMessages({
  library(optparse)
  library(ggplot2)
})

## Where computed results live, read from the same config.yaml the Snakefile
## reads.  The R scripts are told their input and output paths by Snakemake and
## do not need this; report.qmd, which is handed no arguments, does.
results_dir <- local({
  cfg <- yaml::read_yaml(if (interactive()) "../config.yaml" else "config.yaml")
  file.path(path.expand(cfg[["results-loc"]]), "05-analysis")
})

arm_levels <- c("Placebo", "Treatment")
arm_colors <- c("Placebo" = "#7570b3", "Treatment" = "#1b9e77")

## Labels used in Table 1 and in the report, defined once so the two can never
## disagree
var_labels <- c(
  age = "Age (years)",
  sex = "Female",
  bmi = "BMI (kg/m2)",
  smoker = "Smoking status",
  fev1_base = "Baseline FEV1 (L)"
)
