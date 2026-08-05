## One cell of the simulation grid.
##
## Usage: Rscript code/sim.R --n 100 --rho 50 --method naive \
##          --iterations 200 --out results/sim/n100_rho50_naive.rds

## Run from the project root by Snakemake; run from code/ when you are poking at
## it interactively in RStudio
if (interactive()) source("setup.R") else source("code/setup.R")

option_list <- list(
  make_option("--n", type = "integer", default = 100),
  make_option("--rho", type = "integer", default = 50),   # as a percent
  make_option("--method", type = "character", default = "naive"),
  make_option("--iterations", type = "integer", default = 200),
  make_option("--seed", type = "double", default = 1234),
  make_option("--level", type = "double", default = 0.95),
  make_option("--out", type = "character", default = "results/sim.rds")
)
opt <- parse_args(OptionParser(option_list = option_list))

## One seed per replication, derived from the master seed, so replication 7 is
## the same data set whether you ask for 20 replications or 200
set.seed(opt$seed)
seeds <- round(runif(opt$iterations) * 1e9)

res <- lapply(1:opt$iterations, function(i) {
  set.seed(seeds[i])
  out <- one_rep(opt$n, opt$rho / 100, opt$method, opt$level)
  if (!is.null(out)) out$iteration <- i
  out
})
res <- do.call(rbind, res)
res$method <- opt$method
res$n <- opt$n
res$rho <- opt$rho
res$covered <- res$lower <= res$truth & res$truth <= res$upper

dir.create(dirname(opt$out), showWarnings = FALSE, recursive = TRUE)
saveRDS(res, opt$out)
cat("wrote", opt$out, "-- coverage:", round(mean(res$covered), 3), "\n")
