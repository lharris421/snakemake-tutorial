## rds/analysis.rds -> rds/models.rds
##
## Usage: Rscript code/model.R --in rds/analysis.rds --out rds/models.rds
##
## One model per named specification.  Adding a sensitivity analysis means adding
## an entry to this list, not editing the report.

if (interactive()) source("setup.R") else source("code/setup.R")

option_list <- list(
  make_option("--in", type = "character", default = "rds/analysis.rds",
              dest = "infile"),
  make_option("--out", type = "character", default = "rds/models.rds")
)
opt <- parse_args(OptionParser(option_list = option_list))

d <- readRDS(opt$infile)

specs <- list(
  unadjusted = change ~ arm,
  adjusted   = change ~ arm + age + sex + fev1_base,
  full       = change ~ arm + age + sex + bmi + smoker + fev1_base
)

fits <- lapply(specs, function(f) lm(f, data = d))

## Pull the treatment effect out of each fit into one tidy data frame
effects <- do.call(rbind, lapply(names(fits), function(nm) {
  fit <- fits[[nm]]
  ci <- confint(fit)["armTreatment", ]
  data.frame(model = nm,
             estimate = unname(coef(fit)["armTreatment"]),
             lower = ci[1], upper = ci[2],
             p = summary(fit)$coefficients["armTreatment", "Pr(>|t|)"],
             n = length(residuals(fit)),
             row.names = NULL)
}))

dir.create(dirname(opt$out), showWarnings = FALSE, recursive = TRUE)
saveRDS(list(fits = fits, effects = effects), opt$out)
print(effects, digits = 3)
cat("wrote", opt$out, "\n")
