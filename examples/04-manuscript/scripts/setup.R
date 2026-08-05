## Shared by every script in scripts/.  Anything used by more than one script --
## packages, simulation functions, plot labels, colors -- belongs here, so that
## a figure and the table it summarizes can never disagree about what "naive"
## means.

suppressPackageStartupMessages({
  library(optparse)
  library(ggplot2)
})

method_labels <- c(
  "naive" = "Naive",
  "split" = "Sample splitting"
)

colors <- c("naive" = "#d95f02", "split" = "#1b9e77")

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
