#' Calculate Intraclass Correlation Coefficient
#'
#' @param object An object of class \code{rcr_mod}.
#' @return Numeric value or list of values.
#' @export
#' @importFrom lme4 VarCorr
rcr_icc <- function(object) {
  vc <- lme4::VarCorr(object$fit)
  var_df <- as.data.frame(vc)
  
  sigma2 <- attr(vc, "sc")^2 # Residual variance
  
  if (object$random_type == "intercept") {
    tau2 <- var_df[var_df$grp == object$id, "vcov"]
    return(tau2 / (tau2 + sigma2))
  } else {
    # For random slope models, return variance components
    return(vc)
  }
}

#' Center Time Variable
#'
#' @param data Data frame.
#' @param time Character. Name of time variable.
#' @param id Character. Name of ID variable (optional). If provided, performs within-subject centering.
#' @param scale Logical. Should variable be scaled?
#' @return Modified data frame.
#' @export
#' @importFrom stats sd
rcr_center_time <- function(data, time, id = NULL, scale = FALSE) {
  x <- data[[time]]
  
  if (!is.null(id)) {
    # Within-subject centering
    means <- tapply(x, data[[id]], mean, na.rm = TRUE)
    data[[paste0(time, "_c")]] <- x - means[as.character(data[[id]])]
  } else {
    # Global centering
    data[[paste0(time, "_c")]] <- x - mean(x, na.rm = TRUE)
  }
  
  if (scale) {
    data[[paste0(time, "_c")]] <- data[[paste0(time, "_c")]] / stats::sd(x, na.rm = TRUE)
  }
  
  data
}

#' Extract Random Effects
#'
#' @param object An object of class \code{rcr_mod}.
#' @return Data frame of random effects.
#' @export
#' @importFrom lme4 ranef
rcr_ranef <- function(object) {
  lme4::ranef(object$fit)
}

#' @export
#' @importFrom stats vcov
vcov.rcr_mod <- function(object, ...) {
  stats::vcov(object$fit, ...)
}

#' @export
#' @importFrom stats coef
coef.rcr_mod <- function(object, ...) {
  stats::coef(object$fit, ...)
}