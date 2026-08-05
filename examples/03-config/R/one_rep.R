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
