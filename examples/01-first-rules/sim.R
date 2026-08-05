## Coverage of confidence intervals after stepwise selection.
##
## Usage:  Rscript sim.R <method> <output file>
## e.g.:   Rscript sim.R naive ../../results/01-first-rules/sim-naive.rds

args <- commandArgs(trailingOnly = TRUE)
method <- args[1]
outfile <- args[2]

n <- 100
rho <- 0.5
iterations <- 200
seed <- 1234

## Generate n observations on 10 predictors with AR(1) correlation rho.
## The first two coefficients are 1 and -1; the other eight are zero.
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

## One replication: select variables, then form 95% intervals for the selected
## coefficients.  "naive" uses the same data twice; "split" selects on half the
## data and does inference on the other half.
one_rep <- function(n, rho, method) {
  dat <- gen_data(n, rho)
  d <- data.frame(y = dat$y, dat$X)
  if (method == "naive") {
    sel <- select_forward(dat$X, dat$y)
    if (length(sel) == 0) return(NULL)
    ci <- confint(lm(reformulate(sel, "y"), data = d))
  } else if (method == "split") {
    half <- sample(nrow(d), floor(nrow(d) / 2))
    sel <- select_forward(dat$X[half, , drop = FALSE], dat$y[half])
    if (length(sel) == 0) return(NULL)
    ci <- confint(lm(reformulate(sel, "y"), data = d[-half, , drop = FALSE]))
  } else {
    stop("unknown method: ", method)
  }
  ci <- ci[rownames(ci) != "(Intercept)", , drop = FALSE]
  data.frame(variable = rownames(ci), lower = ci[, 1], upper = ci[, 2],
             truth = dat$beta[rownames(ci)], row.names = NULL)
}

set.seed(seed)
res <- lapply(1:iterations, function(i) {
  out <- one_rep(n, rho, method)
  if (!is.null(out)) out$iteration <- i
  out
})
res <- do.call(rbind, res)
res$method <- method
res$n <- n
res$rho <- rho
res$covered <- res$lower <= res$truth & res$truth <= res$upper

dir.create(dirname(outfile), showWarnings = FALSE, recursive = TRUE)
saveRDS(res, outfile)
cat("wrote", outfile, "-- coverage:", round(mean(res$covered), 3), "\n")
