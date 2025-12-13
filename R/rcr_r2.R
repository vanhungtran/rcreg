#' Calculate R-squared for Random Coefficient Models
#'
#' Computes the Marginal and Conditional R-squared values for mixed-effects models
#' following the method of Nakagawa and Schielzeth (2013).
#'
#' @param object An object of class \code{rcr_mod}.
#' @return A named numeric vector containing:
#'   \item{Marginal}{Proportion of variance explained by fixed effects only.}
#'   \item{Conditional}{Proportion of variance explained by both fixed and random effects.}
#' @export
#' @importFrom stats predict var sigma
#' @importFrom lme4 VarCorr
#' @examples
#' data(sim_rcr)
#' mod <- rcr_fit(y ~ time + x1, data = sim_rcr, random = "intercept_slope")
#' rcr_r2(mod)
rcr_r2 <- function(object) {
  if (!inherits(object, "rcr_mod")) {
    stop("Object must be of class 'rcr_mod'")
  }
  
  fit <- object$fit
  
  # 1. Variance of fixed effects
  # We predict using only fixed effects (re.form = NA)
  pred_fixed <- stats::predict(fit, re.form = NA)
  var_fixed <- stats::var(pred_fixed)
  
  # 2. Variance of random effects
  # Sum of variances of all random components
  vc <- lme4::VarCorr(fit)
  var_random <- sum(sapply(vc, function(x) sum(diag(x))))
  
  # 3. Residual variance
  var_resid <- stats::sigma(fit)^2
  
  # 4. Total variance
  var_total <- var_fixed + var_random + var_resid
  
  # Calculate R2 values
  # Marginal R2: Fixed effects / Total
  r2_marg <- var_fixed / var_total
  
  # Conditional R2: (Fixed + Random) / Total
  r2_cond <- (var_fixed + var_random) / var_total
  
  structure(
    c(Marginal = r2_marg, Conditional = r2_cond),
    class = "rcr_r2"
  )
}