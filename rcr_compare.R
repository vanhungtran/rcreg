#' Compare Random Coefficient Regression Models
#'
#' Compares multiple fitted \code{rcr_mod} objects using information criteria
#' (AIC, BIC) and Likelihood Ratio Tests (LRT) to help select the best model
#' specification.
#'
#' @param ... Objects of class \code{rcr_mod} to compare.
#' @return A data frame of class \code{anova} and \code{data.frame} containing
#'   comparison statistics (AIC, BIC, logLik, deviance, Chisq, Chi Df, Pr(>Chisq)).
#' @export
#' @importFrom stats anova
#' @examples
#' \dontrun{
#' mod1 <- rcr_fit(y ~ time + x1, data = sim_rcr, random = "intercept")
#' mod2 <- rcr_fit(y ~ time + x1, data = sim_rcr, random = "intercept_slope")
#' rcr_compare(mod1, mod2)
#' }
rcr_compare <- function(...) {
  models <- list(...)
  
  # Validation
  if (length(models) < 2) {
    stop("At least two models are required for comparison.")
  }
  
  if (!all(sapply(models, inherits, "rcr_mod"))) {
    stop("All objects must be of class 'rcr_mod'.")
  }
  
  # Extract internal lmerMod objects
  fits <- lapply(models, function(x) x$fit)
  
  # Perform comparison using stats::anova
  # We use do.call to pass the list of models as individual arguments
  res <- do.call(stats::anova, fits)
  
  return(res)
}