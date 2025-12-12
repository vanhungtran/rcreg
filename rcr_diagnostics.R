#' Diagnostic Plots for rcr_mod Objects
#'
#' @param object An object of class \code{rcr_mod}.
#' @param which Numeric vector. Which plots to show?
#'   1: Residuals vs Fitted
#'   2: Normal Q-Q
#'   3: Scale-Location
#'   4: Random Effects Q-Q
#' @param ... Additional arguments passed to plot functions.
#'
#' @export
#' @importFrom graphics plot abline par points title lines
#' @importFrom stats qqnorm qqline residuals fitted lowess
#' @importFrom lme4 ranef
rcr_diagnostics <- function(object, which = c(1, 2, 4), ...) {
  resid <- stats::residuals(object)
  fit_vals <- stats::fitted(object)
  
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par))
  
  num_plots <- length(which)
  if (num_plots > 1) {
    graphics::par(mfrow = c(min(num_plots, 2), ceiling(num_plots/2)))
  }
  
  if (1 %in% which) {
    graphics::plot(fit_vals, resid, main = "Residuals vs Fitted", 
         xlab = "Fitted values", ylab = "Residuals", ...)
    graphics::abline(h = 0, lty = 2, col = "gray")
  }
  
  if (2 %in% which) {
    stats::qqnorm(resid, main = "Normal Q-Q (Residuals)")
    stats::qqline(resid, col = "red")
  }
  
  if (3 %in% which) {
    sqrt_abs_resid <- sqrt(abs(resid))
    graphics::plot(fit_vals, sqrt_abs_resid, main = "Scale-Location",
         xlab = "Fitted values", ylab = "Sqrt(|Residuals|)", ...)
    graphics::lines(stats::lowess(fit_vals, sqrt_abs_resid), col = "red")
  }
  
  if (4 %in% which) {
    re <- lme4::ranef(object$fit)
    # Plot for the first random effect (usually intercept)
    re_df <- as.data.frame(re[[1]])
    stats::qqnorm(re_df[,1], main = paste("Normal Q-Q (Random Effects:", names(re_df)[1], ")"))
    stats::qqline(re_df[,1], col = "red")
  }
}

#' @export
plot.rcr_mod <- function(x, ...) {
  rcr_diagnostics(x, ...)
}