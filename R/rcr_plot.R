#' Plot Observed and Predicted Trajectories
#'
#' @description
#' Creates a quick ggplot overlay of observed outcomes (when available) and
#' model-predicted trajectories from an \code{rcr_mod} object. Useful for a
#' visual check of model fit by subject or overall.
#'
#' @param object An object of class \code{"rcr_mod"}.
#' @param newdata Optional data frame for prediction. If \code{NULL}, the
#'   original data used to fit the model are used.
#' @param type Prediction type passed to \code{\link{rcr_predict}}:
#'   \code{"subject"} (default) or \code{"population"}.
#' @param overlay_observed Logical; if \code{TRUE} (default) and the response
#'   variable is present in the data, observed points are shown.
#' @param ... Additional arguments passed to \code{\link{rcr_predict}}.
#'
#' @return A \code{ggplot} object (requires the \pkg{ggplot2} package).
#' @export
#'
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   data(sim_rcr)
#'   mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                  random = "intercept_slope")
#'   p <- rcr_plot_predictions(mod)
#'   print(p)
#' }
rcr_plot_predictions <- function(object, newdata = NULL,
                                 type = c("subject", "population"),
                                 overlay_observed = TRUE,
                                 ...) {
  if (!inherits(object, "rcr_mod")) {
    stop("Object must be of class 'rcr_mod'.")
  }
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for plotting. Please install it.")
  }

  type <- match.arg(type)

  data_for_pred <- if (is.null(newdata)) object$data else newdata
  if (is.null(data_for_pred)) {
    stop("No data available for plotting. Provide 'newdata' or fit with data stored.")
  }
  if (!is.data.frame(data_for_pred)) {
    stop("Data must be provided as a data frame.")
  }
  if (!object$time %in% names(data_for_pred)) {
    stop("Data must contain the time variable '", object$time, "'.")
  }
  if (type == "subject" && !object$id %in% names(data_for_pred)) {
    stop("Subject-level plots require the ID variable '", object$id, "' in the data.")
  }

  preds <- rcr_predict(object, newdata = data_for_pred, type = type, ...)

  plot_df <- data.frame(
    id = if (object$id %in% names(data_for_pred)) data_for_pred[[object$id]] else NA,
    time = data_for_pred[[object$time]],
    pred = preds
  )

  # Identify response variable (left-hand side of formula)
  response_var <- all.vars(object$formula)[1]

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = time, y = pred))

  if (type == "subject" && object$id %in% names(plot_df)) {
    p <- p + ggplot2::geom_line(ggplot2::aes_string(group = "id", color = "id"),
                                linewidth = 0.8, alpha = 0.9) +
      ggplot2::guides(color = ggplot2::guide_legend(title = object$id))
  } else {
    p <- p + ggplot2::geom_line(color = "steelblue", linewidth = 1.1)
  }

  if (overlay_observed && !is.null(response_var) && response_var %in% names(data_for_pred)) {
    p <- p + ggplot2::geom_point(
      data = data_for_pred,
      ggplot2::aes_string(x = object$time, y = response_var,
                          group = if (object$id %in% names(data_for_pred)) object$id else NULL),
      color = "gray40",
      alpha = 0.6,
      size = 2
    )
  }

  p + ggplot2::labs(
    x = object$time,
    y = "Predicted value",
    color = "ID",
    title = "Observed vs Predicted Trajectories"
  ) +
    ggplot2::theme_minimal()
}
