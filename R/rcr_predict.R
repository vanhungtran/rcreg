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
#' @param interval Character string indicating if confidence or prediction
#'   intervals should be returned for population-level predictions. Options are
#'   \code{"none"} (default), \code{"confidence"}, or \code{"prediction"}.
#' @param level Confidence level for intervals (default 0.95).
#' @param ... Additional arguments passed to \code{\link[stats]{predict}}.
#'
#' @return If \code{se.fit = FALSE}, a numeric vector of predictions. If
#'   \code{se.fit = TRUE} and \code{interval = "none"}, a list with components:
#'   \item{fit}{Predicted values}
#'   \item{se.fit}{Standard errors of predictions (approximate)}
#'   If \code{interval != "none"}, a data frame with columns \code{fit},
#'   optional \code{se.fit}, and interval bounds \code{lwr}, \code{upr}.
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
#' @importFrom stats model.matrix predict qnorm delete.response terms
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
                        se.fit = FALSE,
                        interval = c("none", "confidence", "prediction"),
                        level = 0.95,
                        ...) {
  if (!inherits(object, "rcr_mod")) {
    stop("Object must be of class 'rcr_mod'")
  }

  type <- match.arg(type)
  interval <- match.arg(interval)
  fit <- object$fit

  # Validate level
  if (!is.numeric(level) || length(level) != 1 || level <= 0 || level >= 1) {
    stop("`level` must be a single number between 0 and 1.")
  }

  # Validate newdata columns when provided
  if (!is.null(newdata)) {
    if (!is.data.frame(newdata)) {
      stop("`newdata` must be a data frame.")
    }

    required_cols <- c(object$id, object$time)
    missing_cols <- setdiff(required_cols, names(newdata))
    if (type == "subject" && length(missing_cols) > 0) {
      stop("`newdata` for subject-level predictions must contain columns: ",
           paste(missing_cols, collapse = ", "))
    }
    if (type == "population" && !(object$time %in% names(newdata))) {
      stop("`newdata` must contain the time variable '", object$time, "'.")
    }
  }

  if (interval != "none" && type != "population") {
    stop("Intervals are only available for population-level predictions. ",
         "Use type = 'population'.")
  }

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

  # Compute standard errors / intervals if requested (population-level only)
  if (se.fit || interval != "none") {
    if (type == "subject") {
      warning("Standard errors and intervals are not available for subject-specific predictions. ",
              "Returning predictions without them.")
      return(preds)
    }

    # Use original data if newdata is NULL; otherwise use provided data
    base_data <- if (is.null(newdata)) object$data else newdata

    # Design matrix for fixed effects (use formula without response)
    # Extract RHS of formula using delete.response
    terms_obj <- terms(object$formula)
    X <- model.matrix(delete.response(terms_obj), data = base_data)
    
    # Ensure X is a matrix (not dropped to vector for single row)
    X <- as.matrix(X)

    # Variance-covariance matrix of fixed effects
    V <- as.matrix(vcov(fit))

    # Standard errors: sqrt(diag(X %*% V %*% t(X)))
    # Compute element-wise: for each row i, se[i] = sqrt(X[i,] %*% V %*% X[i,])
    XVX <- (X %*% V) * X  # Element-wise multiplication
    se_vals <- sqrt(rowSums(XVX))

    # Interval bounds if requested
    if (interval != "none") {
      z <- qnorm(1 - (1 - level) / 2)
      interval_sd <- se_vals

      # Prediction interval accounts for residual variance
      if (interval == "prediction") {
        interval_sd <- sqrt(se_vals^2 + sigma(fit)^2)
      }

      lwr <- preds - z * interval_sd
      upr <- preds + z * interval_sd

      if (se.fit) {
        return(data.frame(fit = preds, se.fit = se_vals, lwr = lwr, upr = upr))
      }
      return(data.frame(fit = preds, lwr = lwr, upr = upr))
    }

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
