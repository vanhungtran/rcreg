#' Simulate Data for Random Coefficient Regression
#'
#' Generates a simulated dataset suitable for fitting random coefficient models,
#' allowing control over sample size, time points, and variance components.
#'
#' @param n_subjects Integer. Number of unique subjects.
#' @param n_timepoints Integer. Number of time points per subject.
#' @param beta Numeric vector of length 3. Fixed effects for Intercept, Time, and Covariate (x1).
#' @param sigma_u Numeric vector of length 2. Standard deviations for random Intercept and Slope.
#' @param rho Numeric. Correlation between random intercept and slope.
#' @param sigma_e Numeric. Residual standard deviation.
#' @param seed Integer. Random seed for reproducibility.
#'
#' @return A data frame in long format.
#' @export
#' @importFrom stats rnorm
#' @examples
#' # Simulate a small dataset
#' dat <- rcr_simulate(n_subjects = 50, n_timepoints = 4)
#' head(dat)
rcr_simulate <- function(n_subjects = 100, n_timepoints = 5, 
                         beta = c(10, 2, 1.5), 
                         sigma_u = c(2, 1), 
                         rho = 0.25, 
                         sigma_e = 2, 
                         seed = NULL) {
  
  if (!is.null(seed)) set.seed(seed)
  
  # Validate inputs
  if (abs(rho) > 1) stop("Correlation 'rho' must be between -1 and 1.")
  
  # 1. Generate Subject-Level Random Effects
  # We use the Cholesky decomposition method for bivariate normal generation
  # Covariance matrix
  cov_u <- rho * sigma_u[1] * sigma_u[2]
  Sigma <- matrix(c(sigma_u[1]^2, cov_u, cov_u, sigma_u[2]^2), 2, 2)
  
  # Generate standard normal matrix (n x 2)
  Z <- matrix(stats::rnorm(n_subjects * 2), n_subjects, 2)
  
  # Transform to correlated random effects
  # L is lower triangular Cholesky factor: Sigma = L %*% t(L)
  L <- t(chol(Sigma))
  U <- t(L %*% t(Z)) # Random effects matrix (n x 2)
  colnames(U) <- c("b0", "b1")
  
  # 2. Generate Data Structure
  id <- rep(1:n_subjects, each = n_timepoints)
  time <- rep(0:(n_timepoints - 1), times = n_subjects)
  
  # Subject-level covariate x1 (time-invariant)
  x1_subj <- stats::rnorm(n_subjects)
  x1 <- x1_subj[id]
  
  # 3. Construct Response
  # y = (beta0 + b0) + (beta1 + b1)*time + beta2*x1 + error
  epsilon <- stats::rnorm(length(id), 0, sigma_e)
  
  y <- (beta[1] + U[id, 1]) + (beta[2] + U[id, 2]) * time + beta[3] * x1 + epsilon
  
  data.frame(id = id, time = time, x1 = x1, y = y)
}