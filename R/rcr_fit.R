#' Fit Random Coefficient Regression Models for Repeated Measurements
#'
#' @description
#' Fits random coefficient regression models (random intercept and/or random slope
#' linear mixed models) for repeated measurement data using \code{lme4::lmer}.
#' This function provides a high-level interface that simplifies model specification
#' for longitudinal data with subject-specific random effects.
#'
#' @details
#' The model fitted is:
#' \deqn{y_{ij} = \beta_0 + \beta_1 t_{ij} + \mathbf{x}_{ij}^\top \boldsymbol{\beta}_x
#'              + b_{0i} + b_{1i} t_{ij} + \varepsilon_{ij}}
#'
#' where for subject \eqn{i = 1,\dots,N}, measurement \eqn{j = 1,\dots,n_i}:
#' \itemize{
#'   \item \eqn{(b_{0i}, b_{1i})^\top \sim N(0, D)} are random effects
#'   \item \eqn{\varepsilon_{ij} \sim N(0, \sigma^2)} are residuals
#'   \item All random effects and residuals are independent
#' }
#'
#' The \code{random} argument controls which random effects are included:
#' \itemize{
#'   \item \code{"intercept"}: Random intercept only, \eqn{(1 | id)}
#'   \item \code{"slope"}: Random slope only, \eqn{(0 + time | id)}
#'   \item \code{"intercept_slope"}: Both random intercept and slope with
#'         correlation, \eqn{(1 + time | id)}
#' }
#'
#' @param formula A two-sided linear formula describing the fixed-effects part
#'   of the model, with the response on the left of a \code{~} operator and
#'   the predictors on the right (e.g., \code{y ~ time + x1 + x2}).
#' @param data A data frame containing the variables in the model.
#' @param id Character string specifying the name of the subject/cluster
#'   identifier variable in \code{data}.
#' @param time Character string specifying the name of the time variable in
#'   \code{data}. This variable will be used in the random effects specification.
#' @param random Character string specifying the random effects structure.
#'   Options are \code{"intercept"} (default), \code{"slope"}, or
#'   \code{"intercept_slope"}.
#' @param REML Logical. Should the model be fitted by REML (TRUE, default) or
#'   maximum likelihood (FALSE)?
#' @param ... Additional arguments passed to \code{\link[lme4]{lmer}}.
#'
#' @return An object of class \code{"rcr_mod"}, which is a list containing:
#' \item{fit}{The fitted \code{lmerMod} object from \code{lme4::lmer}}
#' \item{formula}{The original fixed-effects formula}
#' \item{random_formula}{The constructed random-effects formula}
#' \item{id}{The name of the ID variable}
#' \item{time}{The name of the time variable}
#' \item{random_type}{The type of random effects structure}
#' \item{data}{The original data frame (optionally)}
#'
#' @export
#' @importFrom lme4 lmer
#' @importFrom stats as.formula
#'
#' @examples
#' # Load example data
#' data(sim_rcr)
#'
#' # Fit random intercept model
#' mod1 <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                 random = "intercept")
#'
#' # Fit random intercept and slope model
#' mod2 <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                 random = "intercept_slope")
#'
#' # Fit random slope only model
#' mod3 <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                 random = "slope")
#'
#' @seealso \code{\link{rcr_summary}}, \code{\link{rcr_predict}}, \code{\link{rcr_diagnostics}}
rcr_fit <- function(formula, data, id, time, random = c("intercept", "slope", "intercept_slope"),
                    REML = TRUE, ...) {

  # Match and validate arguments
  random <- match.arg(random)

  # Check that required variables exist in data
  if (!id %in% names(data)) {
    stop("ID variable '", id, "' not found in data.")
  }
  if (!time %in% names(data)) {
    stop("Time variable '", time, "' not found in data.")
  }
  if (any(is.na(data[[id]]))) {
    stop("ID variable '", id, "' contains missing values; please remove or impute before fitting.")
  }
  if (any(is.na(data[[time]]))) {
    stop("Time variable '", time, "' contains missing values; please remove or impute before fitting.")
  }

  # Validate that data is a data frame
  if (!is.data.frame(data)) {
    stop("'data' must be a data frame.")
  }

  # Validate time variable type
  if (!is.numeric(data[[time]])) {
    stop("Time variable '", time, "' must be numeric.")
  }

  # Construct random effects formula based on random type
  random_formula <- switch(
    random,
    intercept = paste0("(1 | ", id, ")"),
    slope = paste0("(0 + ", time, " | ", id, ")"),
    intercept_slope = paste0("(1 + ", time, " | ", id, ")")
  )

  # Combine fixed and random effects into full formula
  # Convert formula to character, append random part
  fixed_part <- deparse(formula)
  full_formula_str <- paste(fixed_part, "+", random_formula)
  full_formula <- as.formula(full_formula_str)

  # Fit the model using lme4::lmer
  fit <- lme4::lmer(full_formula, data = data, REML = REML, ...)

  # Create rcr_mod object
  out <- structure(
    list(
      fit = fit,
      formula = formula,
      random_formula = random_formula,
      id = id,
      time = time,
      random_type = random,
      data = data,
      call = match.call()
    ),
    class = "rcr_mod"
  )

  return(out)
}


#' Print method for rcr_mod objects
#'
#' @param x An object of class \code{"rcr_mod"}
#' @param ... Additional arguments (not used)
#'
#' @return Invisibly returns the input object
#' @export
print.rcr_mod <- function(x, ...) {
  cat("Random Coefficient Regression Model\n")
  cat("====================================\n\n")
  cat("Random effects structure:", x$random_type, "\n")
  cat("Random formula:", x$random_formula, "\n")
  cat("ID variable:", x$id, "\n")
  cat("Time variable:", x$time, "\n\n")
  cat("Fixed effects formula:\n")
  print(x$formula)
  cat("\n")
  cat("Use rcr_summary() for detailed results.\n")
  invisible(x)
}
