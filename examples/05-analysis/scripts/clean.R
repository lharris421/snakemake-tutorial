## data/trial.csv -> rds/clean.rds
##
## Usage: Rscript scripts/clean.R --in data/trial.csv --out rds/analysis.rds
##
## Every decision about the data -- what counts as missing, which records are
## dropped, how sex is coded -- is made here and nowhere else.  Downstream
## scripts read the .rds and never touch the raw file.

library(optparse)

arm_levels <- c("Placebo", "Treatment")

option_list <- list(
  make_option("--in", type = "character", default = "data/trial.csv",
              dest = "infile"),
  make_option("--out", type = "character", default = "rds/clean.rds")
)
opt <- parse_args(OptionParser(option_list = option_list))

raw <- read.csv(opt$infile, stringsAsFactors = FALSE)
log_step <- function(d, msg) {
  cat(sprintf("%-45s n = %d\n", msg, nrow(d)))
  invisible(d)
}
log_step(raw, "raw file")

d <- raw[!duplicated(raw$patient_id), ]
log_step(d, "after dropping duplicate patient records")

## Sex arrives as F/f/female/Female/M/male/Male
d$sex <- ifelse(toupper(substr(d$sex, 1, 1)) == "F", "Female", "Male")

## Ages over 120 are data entry errors, not centenarians
d$age[d$age > 120] <- NA
log_step(d[!is.na(d$age), ], "with a usable age")

d$visit_date <- as.Date(d$visit_date, format = "%m/%d/%Y")
d$arm <- factor(d$arm, levels = arm_levels)
d$smoker <- factor(d$smoker, levels = c("Never", "Former", "Current"))
d$change <- d$fev1_wk12 - d$fev1_base

## The primary analysis needs a week 12 measurement
d <- d[!is.na(d$change), ]
log_step(d, "with a week 12 measurement (analysis set)")

dir.create(dirname(opt$out), showWarnings = FALSE, recursive = TRUE)
saveRDS(d, opt$out)
cat("wrote", opt$out, "\n")
