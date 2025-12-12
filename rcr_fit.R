#' Fit Random Coefficient Regression Models
#'
#' Fits a linear mixed-effects model with specific random effects structures
#' designed for repeated measures data.
#'
#' @param formula A two-sided linear formula object describing the fixed-effects part of the model.
#' @param data A data frame containing the variables named in formula.
#' @param id Character string. The name of the subject/grouping identifier variable.
#' @param time Character string. The name of the time variable.
#' @param random Character string. One of "intercept", "slope", or "intercept_slope".
#'   \itemize{
#'     \item "intercept": Random intercept only (1 | id)
#'     \item "slope": Random slope only (0 + time | id)
#'     \item "intercept_slope": Random intercept and slope (1 + time | id)
#'   }
#' @param REML Logical. Should REML estimation be used? Default is TRUE.
#' @param ... Additional arguments passed to \code{\link[lme4]{lmer}}.
#'
#' @return An object of class \code{rcr_mod}.
#' @export
#' @importFrom lme4 lmer ngrps
#' @importFrom stats as.formula nobs
rcr_fit <- function(formula, data, id, time, random = c("intercept_slope", "intercept", "slope"), REML = TRUE, ...) {
  random <- match.arg(random)

  # Input validation
  if (!id %in% names(data)) stop(paste("Variable", id, "not found in data"))
  if (!time %in% names(data)) stop(paste("Variable", time, "not found in data"))

  # Construct random effects formula
  random_part <- switch(random,
    intercept = paste("(1 |", id, ")"),
    slope = paste("(0 +", time, "|", id, ")"),
    intercept_slope = paste("(1 +", time, "|", id, ")")
  )

  # Combine formulas
  fixed_char <- deparse(formula)
  full_formula_str <- paste(fixed_char, "+", random_part)
  full_formula <- stats::as.formula(full_formula_str)

  # Fit model
  fit <- lme4::lmer(full_formula, data = data, REML = REML, ...)

  # Create return object
  structure(
    list(
      fit = fit,
      formula = formula,
      random_formula = random_part,
      id = id,
      time = time,
      random_type = random,
      data = data,
      call = match.call()
    ),
    class = "rcr_mod"
  )
}

#' @export
print.rcr_mod <- function(x, ...) {
  cat("Random Coefficient Regression Model\n")
  cat("-----------------------------------\n")
  cat("Fixed Effects Formula:", deparse(x$formula), "\n")
  cat("Random Effects:", x$random_type, "\n")
  cat("Grouping Variable:", x$id, "\n")
  cat("Observations:", stats::nobs(x$fit), "\n")
  cat("Groups:", lme4::ngrps(x$fit), "\n\n")
  print(x$fit, ...)
}