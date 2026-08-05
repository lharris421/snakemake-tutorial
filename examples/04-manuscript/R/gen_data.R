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
