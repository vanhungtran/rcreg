#' Simulated Repeated Measures Data for Random Coefficient Regression
#'
#' @description
#' A simulated dataset in long format for demonstrating random coefficient
#' regression models with repeated measurements. Contains longitudinal data
#' for 100 subjects measured at 5 time points each.
#'
#' @format A data frame with 500 rows and 4 variables:
#' \describe{
#'   \item{id}{Subject identifier (integer, 1-100)}
#'   \item{time}{Time of measurement (numeric, 0-4)}
#'   \item{x1}{Time-invariant covariate (numeric, standard normal)}
#'   \item{y}{Response variable (numeric)}
#' }
#'
#' @details
#' The data were generated according to the following random coefficient model:
#'
#' \deqn{y_{ij} = 10 + 2 \cdot t_{ij} + 1.5 \cdot x_{1i} + b_{0i} + b_{1i} \cdot t_{ij} + \varepsilon_{ij}}
#'
#' where:
#' \itemize{
#'   \item \eqn{i = 1, \ldots, 100} indexes subjects
#'   \item \eqn{j = 1, \ldots, 5} indexes time points
#'   \item \eqn{(b_{0i}, b_{1i})^\top \sim N(0, D)} with
#'         \eqn{D = \begin{pmatrix} 4 & 0.5 \\ 0.5 & 1 \end{pmatrix}}
#'   \item \eqn{\varepsilon_{ij} \sim N(0, 4)}
#'   \item \eqn{x_{1i} \sim N(0, 1)} (time-invariant covariate)
#' }
#'
#' This generates data with:
#' \itemize{
#'   \item Random intercept variance: 4
#'   \item Random slope variance: 1
#'   \item Covariance between random intercept and slope: 0.5
#'   \item Residual variance: 4
#'   \item Fixed effects: intercept = 10, time slope = 2, x1 coefficient = 1.5
#' }
#'
#' @source Simulated data using \code{set.seed(123)} for reproducibility
#'
#' @examples
#' data(sim_rcr)
#' head(sim_rcr)
#'
#' # Summary statistics
#' summary(sim_rcr)
#'
#' # Visualize trajectories for first 10 subjects
#' if (require(ggplot2)) {
#'   library(ggplot2)
#'   ggplot(subset(sim_rcr, id <= 10), aes(x = time, y = y, group = id, color = factor(id))) +
#'     geom_line() +
#'     geom_point() +
#'     theme_minimal() +
#'     labs(title = "Individual Trajectories (First 10 Subjects)",
#'          color = "Subject ID")
#' }
#'
#' # Fit a random intercept and slope model
#' mod <- rcr_fit(y ~ time + x1, data = sim_rcr, id = "id", time = "time",
#'                random = "intercept_slope")
#' rcr_summary(mod)
"sim_rcr"
