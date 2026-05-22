## Function that simulates from the cox model

simulateCoxExp <- function(n = 500,
                           covariates,
                           beta,
                           lambda0,
                           seed = NULL) {
  # TODO asserts

  if (!is.null(seed)) set.seed(seed)

  # Linear predictor
  X <- as.matrix(covariates[, names(beta), drop = FALSE])
  eta <- as.vector(X %*% beta)

  # Simulate event times
  u <- runif(n)
  event.time <- -log(u) / (lambda0 * exp(eta))

  # Simulate censoring times
  censor.limit <- as.numeric(quantile(event.time, probs = 0.3))
  censor.time <- runif(n, min = 0, max = censor.limit)
  time <- pmin(event.time, censor.time)
  status <- as.integer(event.time <= censor.time)

  res <- data.frame(
    time = time,
    status = status,
    covariates,
    true.event.time = event.time,
    censor.time = censor.time,
    eta = eta
  )
  attr(res, "censoring.rate") <- mean(res$status == 0)
  res
}
