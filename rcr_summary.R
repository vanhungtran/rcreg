#' Summary of Random Coefficient Regression Model
#'
#' @param object An object of class \code{rcr_mod}.
#' @param ... Additional arguments.
#'
#' @return An object of class \code{rcr_summary}.
#' @export
#' @importFrom lme4 fixef VarCorr ngrps
#' @importFrom stats AIC BIC logLik nobs vcov
rcr_summary <- function(object, ...) {
  fit <- object$fit

  # Fixed effects
  fe <- lme4::fixef(fit)
  se <- sqrt(diag(as.matrix(stats::vcov(fit))))
  tval <- fe / se
  fe_tab <- data.frame(
    Estimate = fe,
    Std.Error = se,
    t.value = tval
  )
  # Simple approx CI
  fe_tab$Lower.95 <- fe - 1.96 * se
  fe_tab$Upper.95 <- fe + 1.96 * se

  # Variance components
  vc <- lme4::VarCorr(fit)
  vc_df <- as.data.frame(vc)

  res <- list(
    fixed_effects = fe_tab,
    random_effects = vc_df,
    aic = stats::AIC(fit),
    bic = stats::BIC(fit),
    logLik = stats::logLik(fit),
    nobs = stats::nobs(fit),
    ngrps = lme4::ngrps(fit),
    random_type = object$random_type,
    call = object$call
  )

  class(res) <- "rcr_summary"
  res
}

#' @export
print.rcr_summary <- function(x, ...) {
  cat("Random Coefficient Regression Model Summary\n")
  cat("===========================================\n")
  cat("Call:\n")
  print(x$call)
  cat("\n")

  cat("Fit Statistics:\n")
  cat("AIC:", format(x$aic, digits=4), "| BIC:", format(x$bic, digits=4),
      "| logLik:", format(x$logLik, digits=4), "\n\n")

  cat("Random Effects:\n")
  print(x$random_effects)
  cat("\n")

  cat("Fixed Effects:\n")
  print(x$fixed_effects, digits = 4)
  invisible(x)
}