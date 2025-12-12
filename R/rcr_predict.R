#' Predict Method for Random Coefficient Regression Models
#'
#' @description
#' Predicts trajectories for new or existing subjects from a fitted random
#' coefficient regression model. Predictions can be made at the population level
#' (fixed effects only) or at the subject level (including random effects).
#'
#' @param object An object of class \code{"rcr_mod"} from \code{\link{rcr_fit}}.
#' @param newdata Optional data frame containing the variables needed for prediction.
#'   If omitted, predictions are made for the original data.
#' @param type Character string specifying the type of prediction:
#'   \itemize{
#'     \item \code{"subject"} (default): Predictions include random effects
#'           (subject-specific predictions). For new subjects not in the training
#'           data, random effects are set to zero (equivalent to population predictions).
#'     \item \code{"population"}: Predictions based on fixed effects only
#'           (marginal/population-averaged predictions).
#'   }
#' @param se.fit Logical. If \code{TRUE}, standard errors of predictions are
#'   returned (only for population-level predictions). Default is \code{FALSE}.
#' @param ... Additional arguments passed to \code{\link[stats]{predict}}.
#'
#' @return If \code{se.fit = FALSE}, a numeric vector of predictions. If
#'   \code{se.fit = TRUE}, a list with components:
#'   \item{fit}{Predicted values}
#'   \item{se.fit}{Standard errors of predictions (approximate)}
#'
#' @details
#' For subject-level predictions (\code{type = "subject"}), the function uses
#' the best linear unbiased predictors (BLUPs) of the random effects. For subjects
#' present in the training data, predictions incorporate their estimated random
#' effects. For new subjects, random effects are assumed to be zero.
#'
#' For population-level predictions (\code{type = "population"}), only the
#' fixed effects are used, providing marginal predictions averaged over the
#' random effects distribution.
#'
#' Standard errors (when \code{se.fit = TRUE}) are computed using approximate
#' methods and are only available for population-level predictions.
#'
#' @export
#' @importFrom stats model.matrix predict
#'
#' @examples
#' data(sim_rcr)
#' mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                random = "intercept_slope")
#'
#' # Subject-specific predictions for original data
#' pred_subj <- rcr_predict(mod, type = "subject")
#'
#' # Population-averaged predictions
#' pred_pop <- rcr_predict(mod, type = "population")
#'
#' # Predictions for new data
#' newdata <- data.frame(id = c(1, 1, 2, 2), time = c(0, 1, 0, 1), x1 = c(0, 0, 1, 1))
#' pred_new <- rcr_predict(mod, newdata = newdata, type = "subject")
#'
#' # Predictions with standard errors (population level only)
#' pred_se <- rcr_predict(mod, newdata = newdata, type = "population", se.fit = TRUE)
#'
#' @seealso \code{\link{rcr_fit}}, \code{\link{rcr_summary}}
rcr_predict <- function(object, newdata = NULL, type = c("subject", "population"),
                        se.fit = FALSE, ...) {
  if (!inherits(object, "rcr_mod")) {
    stop("Object must be of class 'rcr_mod'")
  }

  type <- match.arg(type)
  fit <- object$fit

  # Determine re.form argument for predict.merMod
  if (type == "population") {
    re.form <- NA  # Exclude random effects
  } else {
    re.form <- NULL  # Include random effects
  }

  # Make predictions
  if (is.null(newdata)) {
    # Predictions for original data
    preds <- predict(fit, re.form = re.form, ...)
  } else {
    # Predictions for new data
    preds <- predict(fit, newdata = newdata, re.form = re.form, ...)
  }

  # Compute standard errors if requested
  if (se.fit) {
    if (type == "subject") {
      warning("Standard errors are not available for subject-specific predictions. ",
              "Returning predictions without standard errors.")
      return(preds)
    }

    # Approximate SE using fixed effects only
    # Get design matrix
    if (is.null(newdata)) {
      X <- model.matrix(object$formula, data = object$data)
    } else {
      X <- model.matrix(object$formula, data = newdata)
    }

    # Variance-covariance matrix of fixed effects
    V <- vcov(fit)

    # Standard errors: sqrt(diag(X %*% V %*% t(X)))
    se_vals <- sqrt(rowSums((X %*% V) * X))

    return(list(fit = preds, se.fit = se_vals))
  }

  return(preds)
}


#' Extract Fitted Values from rcr_mod Object
#'
#' @param object An object of class \code{"rcr_mod"}
#' @param ... Additional arguments (not used)
#'
#' @return Numeric vector of fitted values
#' @export
fitted.rcr_mod <- function(object, ...) {
  fitted(object$fit)
}


#' Extract Residuals from rcr_mod Object
#'
#' @param object An object of class \code{"rcr_mod"}
#' @param ... Additional arguments (not used)
#'
#' @return Numeric vector of residuals
#' @export
residuals.rcr_mod <- function(object, ...) {
  residuals(object$fit)
}
