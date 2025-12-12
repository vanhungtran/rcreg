#' Predictions from rcr_mod Objects
#'
#' @param object An object of class \code{rcr_mod}.
#' @param newdata Optional data frame for predictions.
#' @param type Character string. "subject" for subject-specific predictions (conditional on random effects),
#'   or "population" for population-averaged predictions (fixed effects only).
#' @param se.fit Logical. Should standard errors be returned? (Only for type="population").
#' @param ... Additional arguments passed to \code{\link[stats]{predict}}.
#'
#' @return A vector of predictions or a list if se.fit=TRUE.
#' @export
#' @importFrom stats predict model.matrix terms model.frame delete.response vcov
#' @importFrom lme4 getME
rcr_predict <- function(object, newdata = NULL, type = c("subject", "population"), se.fit = FALSE, ...) {
  type <- match.arg(type)

  # Determine re.form based on type
  # NULL includes all random effects (subject specific)
  # NA excludes random effects (population averaged)
  re_form <- if (type == "subject") NULL else NA

  if (se.fit && type == "subject") {
    warning("Standard errors for subject-specific predictions are not currently supported. Setting se.fit = FALSE.")
    se.fit <- FALSE
  }

  pred <- stats::predict(object$fit, newdata = newdata, re.form = re_form, ...)

  if (se.fit) {
    # Calculate SE for population predictions
    if (missing(newdata) || is.null(newdata)) {
       X <- lme4::getME(object$fit, "X")
    } else {
       # Construct X for newdata
       # Note: This assumes simple formulas. Complex terms might require more robust handling.
       tt <- stats::delete.response(stats::terms(object$fit))
       mf <- stats::model.frame(tt, newdata)
       X <- stats::model.matrix(tt, mf)
    }
    
    V <- stats::vcov(object$fit)
    se <- sqrt(diag(X %*% V %*% t(X)))
    
    return(list(fit = pred, se.fit = se))
  }

  pred
}

#' @export
#' @importFrom stats fitted
fitted.rcr_mod <- function(object, ...) {
  stats::fitted(object$fit, ...)
}

#' @export
#' @importFrom stats residuals
residuals.rcr_mod <- function(object, ...) {
  stats::residuals(object$fit, ...)
}