## Everything to do with how results are *presented*: the packages the plotting
## and table scripts need, and the labels and colors they share.
##
## Nothing here affects the cleaned data or the models, which is why those rules
## do not list this file as an input.

suppressPackageStartupMessages({
  library(optparse)
  library(ggplot2)
})

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
