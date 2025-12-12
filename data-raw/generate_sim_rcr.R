# Script to generate sim_rcr dataset
# Run this script to regenerate the data

library(MASS)

set.seed(123)

# Parameters
n_subjects <- 100
n_timepoints <- 5
beta0 <- 10          # Fixed intercept
beta1 <- 2           # Fixed slope for time
beta_x1 <- 1.5       # Fixed effect for x1

# Random effects variance-covariance matrix
D <- matrix(c(4, 0.5, 0.5, 1), nrow = 2)  # Var(b0)=4, Var(b1)=1, Cov=0.5
sigma_e <- 2         # Residual SD (variance = 4)

# Generate data
sim_rcr <- data.frame()

for (i in 1:n_subjects) {
  # Generate random effects for this subject
  b <- mvrnorm(n = 1, mu = c(0, 0), Sigma = D)
  b0i <- b[1]
  b1i <- b[2]

  # Generate time-invariant covariate
  x1i <- rnorm(1, 0, 1)

  # Generate repeated measurements
  for (j in 1:n_timepoints) {
    time_j <- j - 1  # Time: 0, 1, 2, 3, 4

    # Generate response
    epsilon_ij <- rnorm(1, 0, sigma_e)
    y_ij <- beta0 + beta1 * time_j + beta_x1 * x1i + b0i + b1i * time_j + epsilon_ij

    # Add to dataset
    sim_rcr <- rbind(sim_rcr, data.frame(
      id = i,
      time = time_j,
      x1 = x1i,
      y = y_ij
    ))
  }
}

# Ensure proper types
sim_rcr$id <- as.integer(sim_rcr$id)
sim_rcr$time <- as.numeric(sim_rcr$time)
sim_rcr$x1 <- as.numeric(sim_rcr$x1)
sim_rcr$y <- as.numeric(sim_rcr$y)

# Save to data/ directory
usethis::use_data(sim_rcr, overwrite = TRUE)

# Print summary
cat("Dataset 'sim_rcr' generated successfully!\n")
cat("Dimensions:", nrow(sim_rcr), "rows x", ncol(sim_rcr), "columns\n")
cat("Subjects:", length(unique(sim_rcr$id)), "\n")
cat("Time points per subject:", table(table(sim_rcr$id))[1], "\n")
print(head(sim_rcr))
print(summary(sim_rcr))
