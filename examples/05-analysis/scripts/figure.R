## rds/analysis.rds -> out/figure1.png
##
## Usage: Rscript scripts/figure.R --in rds/analysis.rds --out out/figure1.png

if (interactive()) source("setup.R") else source("scripts/setup.R")

option_list <- list(
  make_option("--in", type = "character", default = "rds/analysis.rds",
              dest = "infile"),
  make_option("--out", type = "character", default = "out/figure1.png")
)
opt <- parse_args(OptionParser(option_list = option_list))

d <- readRDS(opt$infile)

p <- ggplot(d, aes(arm, change, fill = arm)) +
  geom_hline(yintercept = 0, color = "grey60") +
  geom_boxplot(width = 0.5, outlier.shape = NA, alpha = 0.6) +
  geom_jitter(width = 0.12, size = 1, alpha = 0.5) +
  scale_fill_manual(values = arm_colors, guide = "none") +
  labs(x = NULL, y = "Change in FEV1 at week 12 (L)") +
  theme_minimal()

dir.create(dirname(opt$out), showWarnings = FALSE, recursive = TRUE)
ggsave(opt$out, p, width = 5, height = 3.5, dpi = 200)
cat("wrote", opt$out, "\n")
