## Usage: Rscript figure.R <output file> <input rds files ...>
## e.g.:  Rscript figure.R results/figure1.pdf results/sim-naive.rds results/sim-split.rds

library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
outfile <- args[1]
infiles <- args[-1]

res <- do.call(rbind, lapply(infiles, readRDS))

## Coverage, separately for the two truly non-null coefficients and the eight
## null ones, since that is where the two methods differ most
res$type <- ifelse(res$truth == 0, "Null (beta = 0)", "Non-null")
cov <- aggregate(covered ~ method + type, data = res, FUN = mean)

p <- ggplot(cov, aes(type, covered, fill = method)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_hline(yintercept = 0.95, linetype = 2) +
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
  labs(x = NULL, y = "Coverage of 95% CI", fill = "Method") +
  theme_minimal()

dir.create(dirname(outfile), showWarnings = FALSE, recursive = TRUE)
ggsave(outfile, p, width = 6, height = 3.5)
cat("wrote", outfile, "\n")
