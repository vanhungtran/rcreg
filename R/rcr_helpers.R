#' Calculate Intraclass Correlation Coefficient (ICC)
#'
#' @description
#' Computes the intraclass correlation coefficient(s) from a fitted random
#' coefficient regression model. The ICC represents the proportion of total
#' variance attributable to between-subject differences.
#'
#' @param object An object of class \code{"rcr_mod"} from \code{\link{rcr_fit}}.
#'
#' @return For random intercept models, a single numeric value representing the ICC.
#'   For random intercept and slope models, a named list containing:
#'   \item{intercept}{ICC for the intercept (at time = 0)}
#'   \item{slope_var}{Variance of the random slope}
#'
#' @details
#' For a random intercept model, the ICC is calculated as:
#' \deqn{ICC = \frac{\sigma^2_{b0}}{\sigma^2_{b0} + \sigma^2_\varepsilon}}
#'
#' where \eqn{\sigma^2_{b0}} is the variance of the random intercept and
#' \eqn{\sigma^2_\varepsilon} is the residual variance.
#'
#' For models with random slopes, the ICC depends on the value of the time
#' variable due to the varying total variance. The function returns the ICC
#' at time = 0 (intercept ICC) and the variance of the random slope.
#'
#' @export
#' @importFrom lme4 VarCorr
#' @importFrom stats sigma
#'
#' @examples
#' data(sim_rcr)
#' mod1 <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                 random = "intercept")
#' rcr_icc(mod1)
#'
#' mod2 <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                 random = "intercept_slope")
#' rcr_icc(mod2)
#'
#' @seealso \code{\link{rcr_fit}}, \code{\link{rcr_summary}}
rcr_icc <- function(object) {
  if (!inherits(object, "rcr_mod")) {
    stop("Object must be of class 'rcr_mod'")
  }

  fit <- object$fit

  # Extract variance components
  vc <- lme4::VarCorr(fit)
  vc_list <- as.data.frame(vc)

  # Residual variance
  sigma_e_sq <- sigma(fit)^2

  # Extract random effect variances
  random_type <- object$random_type

  if (random_type == "intercept") {
    # Simple ICC for random intercept only
    sigma_b0_sq <- vc_list$vcov[1]
    icc <- sigma_b0_sq / (sigma_b0_sq + sigma_e_sq)
    return(icc)

  } else if (random_type == "slope") {
    # For slope-only model, ICC is not straightforward
    # Return slope variance
    sigma_b1_sq <- vc_list$vcov[1]
    return(list(slope_var = sigma_b1_sq, residual_var = sigma_e_sq))

  } else if (random_type == "intercept_slope") {
    # For intercept + slope model, ICC varies with time
    # Return ICC at time = 0 and slope variance
    sigma_b0_sq <- vc_list$vcov[vc_list$grp == object$id & grepl("Intercept", vc_list$var1)]
    sigma_b1_sq <- vc_list$vcov[vc_list$grp == object$id & grepl(object$time, vc_list$var1) &
                                  !grepl("Intercept", vc_list$var1)]

    # If covariance exists
    if (nrow(vc_list) >= 3) {
      cov_b0_b1 <- vc_list$vcov[vc_list$grp == object$id & !is.na(vc_list$var2)]
      if (length(cov_b0_b1) == 0) cov_b0_b1 <- 0
    } else {
      cov_b0_b1 <- 0
    }

    # ICC at time = 0
    icc_intercept <- sigma_b0_sq / (sigma_b0_sq + sigma_e_sq)

    return(list(
      intercept = icc_intercept,
      slope_var = sigma_b1_sq,
      cov_intercept_slope = cov_b0_b1
    ))
  }
}


#' Center Time Variable
#'
#' @description
#' Centers the time variable either globally (grand-mean centering) or within
#' subjects/groups (group-mean centering). Useful for improving interpretability
#' of random intercepts and reducing collinearity.
#'
#' @param data A data frame containing the variables.
#' @param time Character string specifying the name of the time variable to center.
#' @param id Optional character string specifying the name of the subject/group
#'   identifier. If provided, within-subject centering is performed. If \code{NULL}
#'   (default), global centering is performed.
#' @param scale Logical. If \code{TRUE}, the time variable is also scaled by
#'   its standard deviation after centering. Default is \code{FALSE}.
#'
#' @return The input data frame with an additional column named
#'   \code{<time>_centered} containing the centered (and optionally scaled) time values.
#'
#' @details
#' \strong{Global centering} subtracts the overall mean of the time variable:
#' \deqn{t_{ij}^* = t_{ij} - \bar{t}}
#'
#' \strong{Within-subject centering} subtracts each subject's mean time:
#' \deqn{t_{ij}^* = t_{ij} - \bar{t}_i}
#'
#' Global centering is typically used to improve interpretation of the random
#' intercept as the expected value when time = 0 (now at the mean time point).
#' Within-subject centering can be useful for separating between-subject and
#' within-subject effects.
#'
#' @export
#'
#' @examples
#' data(sim_rcr)
#'
#' # Global centering
#' sim_rcr_c1 <- rcr_center_time(sim_rcr, time = "time")
#' head(sim_rcr_c1)
#'
#' # Within-subject centering
#' sim_rcr_c2 <- rcr_center_time(sim_rcr, time = "time", id = "id")
#' head(sim_rcr_c2)
#'
#' # Global centering with scaling
#' sim_rcr_c3 <- rcr_center_time(sim_rcr, time = "time", scale = TRUE)
#' head(sim_rcr_c3)
#'
#' @seealso \code{\link{rcr_fit}}
rcr_center_time <- function(data, time, id = NULL, scale = FALSE) {

  if (!time %in% names(data)) {
    stop("Time variable '", time, "' not found in data.")
  }

  if (!is.null(id) && !id %in% names(data)) {
    stop("ID variable '", id, "' not found in data.")
  }

  # Create new column name
  new_col <- paste0(time, "_centered")

  if (is.null(id)) {
    # Global centering
    time_mean <- mean(data[[time]], na.rm = TRUE)
    data[[new_col]] <- data[[time]] - time_mean

    if (scale) {
      time_sd <- sd(data[[time]], na.rm = TRUE)
      data[[new_col]] <- data[[new_col]] / time_sd
    }

  } else {
    # Within-subject centering
    data[[new_col]] <- ave(data[[time]], data[[id]], FUN = function(x) {
      centered <- x - mean(x, na.rm = TRUE)
      if (scale) {
        time_sd <- sd(data[[time]], na.rm = TRUE)  # Use global SD for consistency
        centered <- centered / time_sd
      }
      return(centered)
    })
  }

  return(data)
}


#' Extract Random Effects from rcr_mod Object
#'
#' @description
#' Convenience function to extract random effects (BLUPs) from a fitted
#' random coefficient regression model.
#'
#' @param object An object of class \code{"rcr_mod"} from \code{\link{rcr_fit}}.
#' @param ... Additional arguments passed to \code{\link[lme4]{ranef}}.
#'
#' @return A data frame (or list of data frames) containing the random effects
#'   for each subject/group.
#'
#' @export
#' @importFrom lme4 ranef
#'
#' @examples
#' data(sim_rcr)
#' mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                random = "intercept_slope")
#' re <- rcr_ranef(mod)
#' head(re)
#'
#' @seealso \code{\link{rcr_fit}}, \code{\link[lme4]{ranef}}
rcr_ranef <- function(object, ...) {
  if (!inherits(object, "rcr_mod")) {
    stop("Object must be of class 'rcr_mod'")
  }
  lme4::ranef(object$fit, ...)
}


#' Extract Variance-Covariance Matrix from rcr_mod Object
#'
#' @param object An object of class \code{"rcr_mod"}
#' @param ... Additional arguments (not used)
#'
#' @return Variance-covariance matrix of fixed effects
#' @export
vcov.rcr_mod <- function(object, ...) {
  vcov(object$fit)
}


#' Extract Coefficients from rcr_mod Object
#'
#' @param object An object of class \code{"rcr_mod"}
#' @param ... Additional arguments (not used)
#'
#' @return Named vector of fixed effects coefficients
#' @export
coef.rcr_mod <- function(object, ...) {
  lme4::fixef(object$fit)
}
