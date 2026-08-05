## Creates data/trial.csv, the "raw data" for this example.
##
## This script is NOT part of the pipeline.  It stands in for the data you were
## handed by an investigator, and it is run once, by hand:
##
##   Rscript data/make-raw-data.R
##
## The messiness below (inconsistent sex coding, an impossible age, missing BMI,
## a duplicated row) is deliberate: it is what scripts/clean.R has to deal with.

set.seed(20240115)
n <- 200

id <- sprintf("PT-%03d", 1:n)
arm <- rep(c("Placebo", "Treatment"), each = n / 2)
age <- round(rnorm(n, 58, 11))
sex <- sample(c("F", "female", "Female", "M", "male", "Male"), n, replace = TRUE)
bmi <- round(rnorm(n, 28, 5), 1)
smoker <- sample(c("Never", "Former", "Current"), n, replace = TRUE,
                 prob = c(0.5, 0.35, 0.15))
site <- sample(c("Denver", "Aurora", "Boulder"), n, replace = TRUE)

## FEV1 (L) at baseline and week 12; treatment adds about 0.15 L
fev1_base <- round(rnorm(n, 2.6 - 0.012 * (age - 58), 0.55), 3)
effect <- ifelse(arm == "Treatment", 0.15, 0)
fev1_wk12 <- round(fev1_base + effect + rnorm(n, 0.02, 0.25), 3)

d <- data.frame(patient_id = id, arm = arm, visit_date = "2023-04-15",
                age = age, sex = sex, bmi = bmi, smoker = smoker, site = site,
                fev1_base = fev1_base, fev1_wk12 = fev1_wk12)

## Introduce the usual problems
d$bmi[sample(n, 12)] <- NA                  # missing covariate
d$fev1_wk12[sample(n, 9)] <- NA             # loss to follow-up
d$age[3] <- 999                             # impossible value
d$visit_date <- format(as.Date("2023-04-15") + sample(0:120, n, replace = TRUE),
                       "%m/%d/%Y")          # dates as US-format strings
d <- rbind(d, d[17, ])                      # a duplicated record

dir.create("data", showWarnings = FALSE)
write.csv(d, "data/trial.csv", row.names = FALSE)
cat("wrote data/trial.csv --", nrow(d), "rows\n")
