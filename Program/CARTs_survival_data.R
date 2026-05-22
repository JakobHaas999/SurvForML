source("setup.R")

## Simulate data from cox model
n <- 1000
covariates <- data.frame(
  x1 = rnorm(n),
  x2 = rbinom(n, 1, 0.4),
  x3 = runif(n, min = -2, max = 2)
)

beta <- c(
  x1 = 0.6,
  x2 = -0.5,
  x3 = 0.4
)

df <- simulateCoxExp(
  n = n,
  covariates = covariates,
  beta = beta,
  lambda0 = 0.02,
  seed = 123
)

# Look at simulated data
# head(df)
table(df$status)
attr(df, "censoring.rate")

# Run the benchmark
# Train test split 70/30
set.seed(124)
train.size <- .7
train.idx <- sample(
  seq_len(n),
  floor(train.size * n),
  replace = FALSE
)
train <- df[train.idx, ]
test <- df[-train.idx, ]


## Regression tree #########################
## time ~ covariates #######################
# Bad fit because censoring is ignored
# Don't do that in praxis
train.tree <- train[, c("time", paste0("x", 1:3))]
fit.tree <- rpart(
  time ~ .,
  data = train.tree,
  method = "anova"
)

# Measures
pred.tree <- predict(fit.tree, newdata = test)
# C-index
cindex.tree <- concordance(
  Surv(time, status) ~ pred.tree,
  data = test
)$concordance

## Cox-model ###############################
## time ~ covariates #######################
train.cox <- train[, c("time", "status", paste0("x", 1:3))]
fit.coxph <- coxph(
  Surv(time, status) ~ .,
  data = train.cox
)
pred.cox <- predict(fit.coxph, newdata = test, type = "lp")
cindex.cox <- concordance(
  Surv(time, status) ~ pred.cox,
  data = test,
  reverse = TRUE
)$concordance


# True risk score
cindex.true <- concordance(
  Surv(time, status) ~ eta,
  data = test,
  reverse = TRUE
)$concordance

## Summary tables
cindexes <- data.frame(
  model = c("True predictor", "Cox Model", "Regression tree"),
  cindex = c(cindex.true, cindex.cox, cindex.tree)
)
cindexes

##
mse.true.events <- mean(
  (test$true.event.time[test$status == 1] - pred.tree[test$status == 1])^2
)

mse.true.censored <- mean(
  (test$true.event.time[test$status == 0] - pred.tree[test$status == 0])^2
)

c(
  true_mse_events = mse.true.events,
  true_mse_censored = mse.true.censored
)
