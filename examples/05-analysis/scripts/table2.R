## rds/analysis.rds -> rds/table2.rds
##
## Usage: Rscript scripts/table2.R --in rds/analysis.rds --out rds/table2.rds
##
## The results table: the treatment effect from each model specification, formatted
## the way it will be printed.  Table 1 describes who was studied; this one says
## what happened.

library(optparse)

option_list <- list(
  make_option("--in", type = "character", default = "rds/analysis.rds",
              dest = "infile"),
  make_option("--out", type = "character", default = "rds/table2.rds")
)
opt <- parse_args(OptionParser(option_list = option_list))

fit <- readRDS(opt$infile)
eff <- fit$effects

model_labels <- c(unadjusted = "Unadjusted",
                  adjusted   = "Adjusted",
                  full       = "Fully adjusted")

rows <- data.frame(
  Model = unname(model_labels[eff$model]),
  Effect = sprintf("%.3f (%.3f to %.3f)", eff$estimate, eff$lower, eff$upper),
  p = ifelse(eff$p < 0.001, "<0.001", sprintf("%.3f", eff$p)),
  n = eff$n
)

## The report quotes the headline number in a sentence as well as printing the
## table; keeping the formatted string here means the two cannot disagree
attr(rows, "headline") <- rows$Effect[eff$model == "adjusted"]

dir.create(dirname(opt$out), showWarnings = FALSE, recursive = TRUE)
saveRDS(rows, opt$out)
print(rows)
cat("wrote", opt$out, "\n")
