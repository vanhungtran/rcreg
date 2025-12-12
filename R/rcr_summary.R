#' Summary Method for Random Coefficient Regression Models
#'
#' @description
#' Provides a clean, comprehensive summary of a fitted random coefficient
#' regression model, including fixed effects estimates, random effects variance
#' components, residual variance, and intraclass correlation coefficient(s).
#'
#' @param object An object of class \code{"rcr_mod"} from \code{\link{rcr_fit}}.
#' @param ... Additional arguments (not currently used).
#'
#' @return An object of class \code{"rcr_summary"}, which is a list containing:
#' \item{fixed_effects}{Data frame of fixed effects estimates, standard errors,
#'   t-values, and confidence intervals}
#' \item{random_effects}{Data frame of random effects variance/covariance components}
#' \item{residual_variance}{Residual variance estimate}
#' \item{icc}{Intraclass correlation coefficient(s)}
#' \item{aic}{Akaike Information Criterion}
#' \item{bic}{Bayesian Information Criterion}
#' \item{logLik}{Log-likelihood}
#' \item{nobs}{Number of observations}
#' \item{ngrps}{Number of groups/subjects}
#' \item{random_type}{Type of random effects structure}
#'
#' @export
#' @importFrom lme4 fixef VarCorr ranef
#' @importFrom stats coef confint vcov sigma AIC BIC logLik
#'
#' @examples
#' data(sim_rcr)
#' mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                random = "intercept_slope")
#' rcr_summary(mod)
#'
#' @seealso \code{\link{rcr_fit}}, \code{\link{rcr_icc}}
rcr_summary <- function(object, ...) {
  if (!inherits(object, "rcr_mod")) {
    stop("Object must be of class 'rcr_mod'")
  }

  fit <- object$fit

  # Extract fixed effects
  fe <- lme4::fixef(fit)
  fe_se <- sqrt(diag(vcov(fit)))
  fe_t <- fe / fe_se

  # Confidence intervals (95%)
  ci <- tryCatch(
    confint(fit, parm = "beta_", method = "Wald", quiet = TRUE),
    error = function(e) {
      # Fallback: manual calculation
      cbind(fe - 1.96 * fe_se, fe + 1.96 * fe_se)
    }
  )

  # Ensure CI matrix has correct dimensions
  if (is.null(dim(ci))) {
    ci <- matrix(ci, ncol = 2)
  }
  if (nrow(ci) != length(fe)) {
    # Manual calculation
    ci <- cbind(fe - 1.96 * fe_se, fe + 1.96 * fe_se)
  }

  fixed_df <- data.frame(
    Estimate = fe,
    Std.Error = fe_se,
    t.value = fe_t,
    CI.lower = ci[, 1],
    CI.upper = ci[, 2]
  )

  # Extract random effects variance components
  vc <- lme4::VarCorr(fit)
  vc_df <- as.data.frame(vc)

  # Extract residual variance
  resid_var <- sigma(fit)^2

  # Calculate ICC
  icc_val <- rcr_icc(object)

  # Model fit statistics
  aic <- AIC(fit)
  bic <- BIC(fit)
  ll <- logLik(fit)
  nobs <- nobs(fit)
  ngrps <- lme4::ngrps(fit)

  # Create summary object
  out <- structure(
    list(
      fixed_effects = fixed_df,
      random_effects = vc_df,
      residual_variance = resid_var,
      icc = icc_val,
      aic = aic,
      bic = bic,
      logLik = as.numeric(ll),
      nobs = nobs,
      ngrps = ngrps,
      random_type = object$random_type,
      formula = object$formula,
      random_formula = object$random_formula,
      id = object$id,
      time = object$time,
      call = object$call
    ),
    class = "rcr_summary"
  )

  return(out)
}


#' Print method for rcr_summary objects
#'
#' @param x An object of class \code{"rcr_summary"}
#' @param digits Number of digits to display
#' @param ... Additional arguments (not used)
#'
#' @return Invisibly returns the input object
#' @export
print.rcr_summary <- function(x, digits = 3, ...) {
  cat("Random Coefficient Regression Model Summary\n")
  cat("============================================\n\n")

  cat("Call:\n")
  print(x$call)
  cat("\n")

  cat("Random effects structure:", x$random_type, "\n")
  cat("Random formula:", x$random_formula, "\n")
  cat("Number of observations:", x$nobs, "\n")
  cat("Number of groups (", x$id, "):", x$ngrps, "\n\n", sep = "")

  cat("Fixed Effects:\n")
  print(round(x$fixed_effects, digits))
  cat("\n")

  cat("Random Effects Variance Components:\n")
  print(x$random_effects, digits = digits)
  cat("\n")

  cat("Residual variance:", round(x$residual_variance, digits), "\n")
  cat("Residual std.dev.:", round(sqrt(x$residual_variance), digits), "\n\n")

  cat("Intraclass Correlation Coefficient(s):\n")
  if (is.list(x$icc)) {
    for (nm in names(x$icc)) {
      cat("  ", nm, ": ", round(x$icc[[nm]], digits), "\n", sep = "")
    }
  } else {
    cat("  ICC:", round(x$icc, digits), "\n")
  }
  cat("\n")

  cat("Model Fit Statistics:\n")
  cat("  AIC:", round(x$aic, 2), "\n")
  cat("  BIC:", round(x$bic, 2), "\n")
  cat("  Log-likelihood:", round(x$logLik, 2), "\n")

  invisible(x)
}
