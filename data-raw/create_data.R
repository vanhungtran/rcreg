# Simple script to create sim_rcr.rda without package dependencies
# This avoids circular dependency issues

set.seed(123)

# Parameters
n_subjects <- 100
n_timepoints <- 5
beta0 <- 10
beta1 <- 2
beta_x1 <- 1.5
sigma_b0 <- 2      # SD of random intercept (variance = 4)
sigma_b1 <- 1      # SD of random slope (variance = 1)
rho <- 0.25        # Correlation between b0 and b1 (cov = 0.5)
sigma_e <- 2       # Residual SD

# Create empty data frame
sim_rcr <- data.frame(
  id = integer(),
  time = numeric(),
  x1 = numeric(),
  y = numeric()
)

for (i in 1:n_subjects) {
  # Generate correlated random effects using Cholesky decomposition
  z <- rnorm(2)
  b0i <- sigma_b0 * z[1]
  b1i <- sigma_b1 * (rho * z[1] + sqrt(1 - rho^2) * z[2])

  # Generate time-invariant covariate
  x1i <- rnorm(1, 0, 1)

  # Generate repeated measurements
  for (j in 0:(n_timepoints - 1)) {
    epsilon_ij <- rnorm(1, 0, sigma_e)
    y_ij <- beta0 + beta1 * j + beta_x1 * x1i + b0i + b1i * j + epsilon_ij

    sim_rcr <- rbind(sim_rcr, data.frame(
      id = as.integer(i),
      time = as.numeric(j),
      x1 = x1i,
      y = y_ij
    ))
  }
}

# Save to data directory
if (!dir.exists("../data")) {
  dir.create("../data")
}

save(sim_rcr, file = "../data/sim_rcr.rda", compress = "bzip2")

cat("Dataset 'sim_rcr' created successfully!\n")
cat("Dimensions:", nrow(sim_rcr), "rows x", ncol(sim_rcr), "columns\n")
cat("First few rows:\n")
print(head(sim_rcr, 10))
