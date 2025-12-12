#' Diagnostic Plots for Random Coefficient Regression Models
#'
#' @description
#' Produces diagnostic plots for fitted random coefficient regression models,
#' including residual plots and QQ-plots for assessing model assumptions.
#'
#' @param object An object of class \code{"rcr_mod"} from \code{\link{rcr_fit}}.
#' @param which Integer vector specifying which plots to produce:
#'   \itemize{
#'     \item 1: Residuals vs Fitted values
#'     \item 2: QQ-plot of residuals
#'     \item 3: Scale-Location plot (sqrt of standardized residuals vs fitted)
#'     \item 4: QQ-plot of random effects
#'   }
#'   Default is \code{c(1, 2, 4)} to show residual vs fitted, residual QQ-plot,
#'   and random effects QQ-plot.
#' @param ask Logical. If \code{TRUE} (and the R session is interactive), the
#'   user is asked before each plot. Default is \code{TRUE} if multiple plots
#'   are requested.
#' @param ... Additional arguments (not currently used).
#'
#' @details
#' The diagnostic plots help assess key assumptions of the random coefficient
#' regression model:
#' \itemize{
#'   \item \strong{Residuals vs Fitted}: Checks linearity and homoscedasticity.
#'         Residuals should be randomly scattered around zero with constant variance.
#'   \item \strong{QQ-plot of Residuals}: Checks normality of level-1 residuals.
#'         Points should fall approximately on the diagonal line.
#'   \item \strong{Scale-Location}: Checks homoscedasticity. The line should be
#'         approximately horizontal.
#'   \item \strong{QQ-plot of Random Effects}: Checks normality of random effects.
#'         Separate plots are produced for each random effect component (intercept, slope).
#' }
#'
#' @return Invisibly returns \code{NULL}. The function is called for its side
#'   effect of producing plots.
#'
#' @export
#' @importFrom stats qqnorm qqline residuals fitted
#' @importFrom graphics par plot abline points
#' @importFrom lme4 ranef
#'
#' @examples
#' data(sim_rcr)
#' mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                random = "intercept_slope")
#'
#' # All default diagnostic plots
#' rcr_diagnostics(mod)
#'
#' # Only residual plots
#' rcr_diagnostics(mod, which = c(1, 2))
#'
#' # All four plots
#' rcr_diagnostics(mod, which = 1:4)
#'
#' @seealso \code{\link{rcr_fit}}, \code{\link{rcr_summary}}
rcr_diagnostics <- function(object, which = c(1, 2, 4), ask = NULL, ...) {
  if (!inherits(object, "rcr_mod")) {
    stop("Object must be of class 'rcr_mod'")
  }

  fit <- object$fit

  # Determine if we should ask before each plot
  if (is.null(ask)) {
    ask <- length(which) > 1 && interactive()
  }

  # Store current par settings and restore on exit
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par))

  if (ask) {
    par(ask = TRUE)
  }

  # Extract residuals and fitted values
  resid_vals <- residuals(fit)
  fitted_vals <- fitted(fit)

  # Plot 1: Residuals vs Fitted
  if (1 %in% which) {
    plot(fitted_vals, resid_vals,
         xlab = "Fitted values",
         ylab = "Residuals",
         main = "Residuals vs Fitted",
         pch = 20, col = "steelblue")
    abline(h = 0, lty = 2, col = "red", lwd = 2)
    # Add lowess smooth
    lines(lowess(fitted_vals, resid_vals), col = "darkred", lwd = 2)
  }

  # Plot 2: QQ-plot of residuals
  if (2 %in% which) {
    qqnorm(resid_vals, main = "Normal Q-Q Plot: Residuals",
           pch = 20, col = "steelblue")
    qqline(resid_vals, col = "red", lwd = 2)
  }

  # Plot 3: Scale-Location
  if (3 %in% which) {
    sqrt_std_resid <- sqrt(abs(scale(resid_vals)))
    plot(fitted_vals, sqrt_std_resid,
         xlab = "Fitted values",
         ylab = expression(sqrt("|Standardized residuals|")),
         main = "Scale-Location",
         pch = 20, col = "steelblue")
    # Add lowess smooth
    lines(lowess(fitted_vals, sqrt_std_resid), col = "darkred", lwd = 2)
  }

  # Plot 4: QQ-plot of random effects
  if (4 %in% which) {
    re <- lme4::ranef(fit, condVar = FALSE)
    re_df <- re[[1]]  # Extract first (and typically only) grouping factor

    # Determine number of random effects
    n_re <- ncol(re_df)
    re_names <- colnames(re_df)

    # Create QQ-plot for each random effect
    for (i in 1:n_re) {
      re_vals <- re_df[[i]]
      qqnorm(re_vals,
             main = paste("Normal Q-Q Plot: Random Effect -", re_names[i]),
             pch = 20, col = "steelblue")
      qqline(re_vals, col = "red", lwd = 2)
    }
  }

  invisible(NULL)
}


#' Plot Method for rcr_mod Objects
#'
#' @description
#' Convenience plot method that calls \code{\link{rcr_diagnostics}} with
#' default settings.
#'
#' @param x An object of class \code{"rcr_mod"}
#' @param ... Additional arguments passed to \code{\link{rcr_diagnostics}}
#'
#' @return Invisibly returns \code{NULL}
#' @export
#'
#' @examples
#' data(sim_rcr)
#' mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                random = "intercept_slope")
#' plot(mod)
plot.rcr_mod <- function(x, ...) {
  rcr_diagnostics(x, ...)
}
