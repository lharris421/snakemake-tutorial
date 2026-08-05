## One cell of the simulation grid.
##
## Usage: Rscript code/sim.R --n 100 --rho 50 --method naive \
##          --iterations 200 --out rds/200/sim/n100_rho50_naive.rds

library(optparse)

## Generate n observations on p predictors with AR(1) correlation rho.  The
## first two coefficients are 1 and -1; the rest are zero.
gen_data <- function(n, rho, p = 10) {
  Sigma <- rho^abs(outer(1:p, 1:p, "-"))
  X <- matrix(rnorm(n * p), n, p) %*% chol(Sigma)
  colnames(X) <- paste0("x", 1:p)
  beta <- c(1, -1, rep(0, p - 2))
  names(beta) <- colnames(X)
  y <- as.numeric(X %*% beta) + rnorm(n)
  list(X = X, y = y, beta = beta)
}

## Forward selection by AIC
select_forward <- function(X, y) {
  d <- data.frame(y = y, X)
  upper <- reformulate(colnames(X), "y")
  fit <- step(lm(y ~ 1, data = d), scope = list(lower = ~1, upper = upper),
              direction = "forward", trace = 0)
  setdiff(names(coef(fit)), "(Intercept)")
}

## One replication: select variables, then form intervals for the selected
## coefficients.  "naive" uses the same data twice; "split" selects on half the
## data and does inference on the other half.
one_rep <- function(n, rho, method, level = 0.95) {
  dat <- gen_data(n, rho)
  d <- data.frame(y = dat$y, dat$X)
  if (method == "naive") {
    sel <- select_forward(dat$X, dat$y)
    if (length(sel) == 0) return(NULL)
    ci <- confint(lm(reformulate(sel, "y"), data = d), level = level)
  } else if (method == "split") {
    half <- sample(nrow(d), floor(nrow(d) / 2))
    sel <- select_forward(dat$X[half, , drop = FALSE], dat$y[half])
    if (length(sel) == 0) return(NULL)
    ci <- confint(lm(reformulate(sel, "y"), data = d[-half, , drop = FALSE]),
                  level = level)
  } else {
    stop("unknown method: ", method)
  }
  ci <- ci[rownames(ci) != "(Intercept)", , drop = FALSE]
  data.frame(variable = rownames(ci), lower = ci[, 1], upper = ci[, 2],
             truth = dat$beta[rownames(ci)], row.names = NULL)
}

option_list <- list(
  make_option("--n", type = "integer", default = 100),
  make_option("--rho", type = "integer", default = 50),   # as a percent
  make_option("--method", type = "character", default = "naive"),
  make_option("--iterations", type = "integer", default = 200),
  make_option("--seed", type = "double", default = 1234),
  make_option("--level", type = "double", default = 0.95),
  make_option("--out", type = "character", default = "rds/sim.rds")
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
