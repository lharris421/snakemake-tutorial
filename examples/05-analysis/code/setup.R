## Shared by every script in code/ and by report.qmd.

suppressPackageStartupMessages({
  library(optparse)
  library(ggplot2)
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
