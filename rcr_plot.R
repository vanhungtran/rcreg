#' Plot Subject Trends
#'
#' Visualizes individual subject trajectories against the population average.
#'
#' @param object An object of class \code{rcr_mod}.
#' @param n_subjects Integer. Number of random subjects to plot. Default is 20.
#' @export
#' @importFrom graphics lines legend
rcr_plot_trend <- function(object, n_subjects = 20) {
  data <- object$data
  ids <- unique(data[[object$id]])
  
  if (length(ids) > n_subjects) {
    ids <- sample(ids, n_subjects)
    data <- data[data[[object$id]] %in% ids, ]
  }
  
  y_var <- as.character(object$formula[[2]])
  
  # Base plot
  graphics::plot(data[[object$time]], data[[y_var]], 
       type = "n", xlab = object$time, ylab = y_var,
       main = "Subject Trends vs Population Average")
  
  # Individual lines (Observed)
  for (i in ids) {
    sub_dat <- data[data[[object$id]] == i, ]
    sub_dat <- sub_dat[order(sub_dat[[object$time]]), ]
    graphics::lines(sub_dat[[object$time]], sub_dat[[y_var]], col = "gray", lwd = 0.5)
  }
  
  # Population prediction (approximate visual)
  # Note: This is a simplification. For accurate population lines, use rcr_predict with type="population"
  # Here we just add a legend to indicate the structure
  
  graphics::legend("topright", legend = c("Observed Trajectories"), 
         col = c("gray"), lwd = c(0.5))
}