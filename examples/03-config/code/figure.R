## Coverage against n, one panel per correlation level.
##
## Usage: Rscript code/figure.R --out out/figure1.pdf <rds files ...>

if (interactive()) source("setup.R") else source("code/setup.R")

option_list <- list(
  make_option("--out", type = "character", default = "out/figure1.pdf"),
  make_option("--level", type = "double", default = 0.95)
)
parsed <- parse_args(OptionParser(option_list = option_list),
                     positional_arguments = TRUE)
opt <- parsed$options
infiles <- parsed$args

res <- do.call(rbind, lapply(infiles, readRDS))

cov <- aggregate(covered ~ method + n + rho, data = res, FUN = mean)
cov$rho <- factor(cov$rho, levels = sort(unique(cov$rho)),
                  labels = paste("rho =", sort(unique(cov$rho)) / 100))

p <- ggplot(cov, aes(n, covered, color = method, group = method)) +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = opt$level, linetype = 2) +
  facet_wrap(~rho) +
  scale_x_log10(breaks = sort(unique(cov$n))) +
  scale_color_manual(values = colors, labels = method_labels) +
  coord_cartesian(ylim = c(0.5, 1)) +
  labs(x = "n", y = sprintf("Coverage of %g%% CI", 100 * opt$level),
       color = "Method") +
  theme_minimal()

dir.create(dirname(opt$out), showWarnings = FALSE, recursive = TRUE)
ggsave(opt$out, p, width = 7, height = 3)
cat("wrote", opt$out, "\n")
