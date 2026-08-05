## Forward selection by AIC
select_forward <- function(X, y) {
  d <- data.frame(y = y, X)
  upper <- reformulate(colnames(X), "y")
  fit <- step(lm(y ~ 1, data = d), scope = list(lower = ~1, upper = upper),
              direction = "forward", trace = 0)
  setdiff(names(coef(fit)), "(Intercept)")
}
