## Usage: Rscript figure.R <output file> <input rds files ...>

library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
outfile <- args[1]
infiles <- args[-1]

res <- do.call(rbind, lapply(infiles, readRDS))

cov <- aggregate(covered ~ method + n + rho, data = res, FUN = mean)
cov$rho <- factor(cov$rho, levels = sort(unique(cov$rho)),
                  labels = paste("rho =", sort(unique(cov$rho)) / 100))

p <- ggplot(cov, aes(n, covered, color = method, group = method)) +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = 0.95, linetype = 2) +
  facet_wrap(~rho) +
  scale_x_log10(breaks = sort(unique(cov$n))) +
  coord_cartesian(ylim = c(0.5, 1)) +
  labs(x = "n", y = "Coverage of 95% CI", color = "Method") +
  theme_minimal()

dir.create(dirname(outfile), showWarnings = FALSE, recursive = TRUE)
ggsave(outfile, p, width = 7, height = 3)
cat("wrote", outfile, "\n")
