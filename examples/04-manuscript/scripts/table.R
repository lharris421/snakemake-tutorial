## Coverage table, written as a LaTeX fragment for \input{} into the manuscript.
##
## Usage: Rscript scripts/table.R --out out/table1.tex <rds files ...>

if (interactive()) source("setup.R") else source("scripts/setup.R")

suppressPackageStartupMessages({
  library(tidyr)
  library(kableExtra)
})

option_list <- list(
  make_option("--out", type = "character", default = "out/table1.tex"),
  make_option("--level", type = "double", default = 0.95)
)
parsed <- parse_args(OptionParser(option_list = option_list),
                     positional_arguments = TRUE)
opt <- parsed$options
infiles <- parsed$args

res <- do.call(rbind, lapply(infiles, readRDS))

## Coverage separately for the null and non-null coefficients: the naive
## intervals are worst precisely for the variables selection put in the model
## because of noise
res$type <- ifelse(res$truth == 0, "Null", "Non-null")
cov <- aggregate(covered ~ method + n + type, data = res, FUN = mean)
cov$method <- method_labels[cov$method]

wide <- pivot_wider(cov, names_from = c(type, method), values_from = covered,
                    names_sep = " / ")
wide <- wide[order(wide$n), ]

## escape = FALSE so that "$n$" reaches LaTeX as math rather than as literal
## dollar signs; the price is that anything else in the table must be valid LaTeX
tab <- kbl(wide, format = "latex", booktabs = TRUE, digits = 3, linesep = "",
           escape = FALSE,
           col.names = c("$n$", rep(unname(method_labels), 2)),
           align = c("r", rep("c", ncol(wide) - 1)),
           caption = sprintf(paste("Coverage of nominal %g\\%% confidence",
             "intervals for coefficients selected by forward selection, by",
             "whether the selected coefficient is truly zero."),
             100 * opt$level),
           label = "coverage") |>
  add_header_above(c(" " = 1, "Non-null" = 2, "Null" = 2))

dir.create(dirname(opt$out), showWarnings = FALSE, recursive = TRUE)
writeLines(as.character(tab), opt$out)
cat("wrote", opt$out, "\n")
