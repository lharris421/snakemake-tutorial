## rds/analysis.rds -> rds/table1.rds
##
## Usage: Rscript code/table1.R --in rds/analysis.rds --out rds/table1.rds
##
## Baseline characteristics by arm, saved as a plain data frame.  The report
## formats it; this script decides what is in it.

library(optparse)

## Labels used in Table 1 and in the report, defined once so the two can never
## disagree
var_labels <- c(
  age = "Age (years)",
  sex = "Female",
  bmi = "BMI (kg/m2)",
  smoker = "Smoking status",
  fev1_base = "Baseline FEV1 (L)"
)

option_list <- list(
  make_option("--in", type = "character", default = "rds/analysis.rds",
              dest = "infile"),
  make_option("--out", type = "character", default = "rds/table1.rds")
)
opt <- parse_args(OptionParser(option_list = option_list))

d <- readRDS(opt$infile)

mean_sd <- function(x) sprintf("%.1f (%.1f)", mean(x, na.rm = TRUE),
                               sd(x, na.rm = TRUE))
n_pct <- function(x) sprintf("%d (%.0f%%)", sum(x, na.rm = TRUE),
                             100 * mean(x, na.rm = TRUE))

by_arm <- function(f) tapply(seq_len(nrow(d)), d$arm, function(i) f(d[i, ]))

rows <- rbind(
  data.frame(Characteristic = var_labels["age"],
             t(by_arm(function(x) mean_sd(x$age)))),
  data.frame(Characteristic = var_labels["sex"],
             t(by_arm(function(x) n_pct(x$sex == "Female")))),
  data.frame(Characteristic = var_labels["bmi"],
             t(by_arm(function(x) mean_sd(x$bmi)))),
  data.frame(Characteristic = paste("  ", levels(d$smoker)),
             t(sapply(levels(d$smoker), function(lv)
               by_arm(function(x) n_pct(x$smoker == lv))))),
  data.frame(Characteristic = var_labels["fev1_base"],
             t(by_arm(function(x) mean_sd(x$fev1_base))))
)
rownames(rows) <- NULL

## Insert a header row for the smoking block
rows <- rbind(rows[1:3, ],
              data.frame(Characteristic = var_labels["smoker"],
                         Placebo = "", Treatment = ""),
              rows[4:nrow(rows), ])
rownames(rows) <- NULL

attr(rows, "n") <- table(d$arm)

dir.create(dirname(opt$out), showWarnings = FALSE, recursive = TRUE)
saveRDS(rows, opt$out)
print(rows)
cat("wrote", opt$out, "\n")
