#' Compare Multiple Random Coefficient Regression Models
#'
#' @description
#' Provides a tidy comparison table for two or more fitted \code{rcr_mod}
#' objects, including AIC, BIC, log-likelihood, number of parameters, and
#' sample size. Useful for comparing random effects structures or fixed-effects
#' specifications.
#'
#' @param ... One or more objects of class \code{"rcr_mod"}.
#' @param .models Optional list of \code{rcr_mod} objects (helps when models are
#'   stored in a list).
#'
#' @return A data frame (class \code{"rcr_compare"}) with columns:
#' \item{model}{Model name (from argument name or generated as model1, model2, ...)}
#' \item{random_type}{Random effects structure}
#' \item{aic}{Akaike Information Criterion}
#' \item{bic}{Bayesian Information Criterion}
#' \item{logLik}{Log-likelihood}
#' \item{df}{Number of estimated parameters used in log-likelihood}
#' \item{nobs}{Number of observations}
#'
#' @export
#' @importFrom stats AIC BIC logLik nobs
#'
#' @examples
#' data(sim_rcr)
#' mod_int <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                    random = "intercept")
#' mod_both <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                     random = "intercept_slope")
#' rcr_compare(mod_int, mod_both)
rcr_compare <- function(..., .models = NULL) {
  models <- c(list(...), .models)

  if (length(models) < 2) {
    stop("Provide at least two 'rcr_mod' objects to compare.")
  }

  out <- lapply(seq_along(models), function(i) {
    m <- models[[i]]
    if (!inherits(m, "rcr_mod")) {
      stop("All inputs must be of class 'rcr_mod'.")
    }

    nm <- names(models)[i]
    if (is.null(nm) || nm == "") nm <- paste0("model", i)

    ll <- logLik(m$fit)

    data.frame(
      model = nm,
      random_type = m$random_type,
      aic = AIC(m$fit),
      bic = BIC(m$fit),
      logLik = as.numeric(ll),
      df = attr(ll, "df"),
      nobs = nobs(m$fit),
      stringsAsFactors = FALSE
    )
  })

  out_df <- do.call(rbind, out)
  out_df <- out_df[order(out_df$aic), ]
  rownames(out_df) <- NULL
  class(out_df) <- c("rcr_compare", class(out_df))
  out_df
}


#' Print method for rcr_compare objects
#'
#' @param x An object of class \code{"rcr_compare"}.
#' @param ... Additional arguments passed to \code{print.data.frame}.
#'
#' @return Invisibly returns \code{x}.
#' @export
print.rcr_compare <- function(x, ...) {
  print.data.frame(x, row.names = FALSE, ...)
  invisible(x)
}
