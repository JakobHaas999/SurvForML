## Full example of steps for random survival forests --------------
## and survival trees on  tumor data ------------------------------

source("setup.R")

# Load data
data("tumor", package = "pammtools")
head(tumor)
n <- nrow(tumor)
p <- ncol(tumor) - 2
form.general <- Surv(days, status) ~ .

## -- train test split ----------------------
# we preform a simple holdout split
set.seed(28)
train.size <- 0.67
train.ind <- sample(
  x = seq_len(n),
  size = floor(train.size * n),
  replace = FALSE
)
train <- tumor[train.ind, ]
test <- tumor[-train.ind, ]

## -- Fit models -----------------------------

# 1) Fit a single survival tree
tree <- rfsrc(
  formula = form.general,
  data = train,
  mtry = p,
  bootstrap = "none",
  ntree = 1,
  nsplit = 0
)

# 2) Fit a random survial forest with default settings
set.seed(29)
forest.untuned <- rfsrc(
  formula = form.general,
  data = train,
  ntree = 500
)

# 3) Fit a random survival forest with tuned mtry
## Tuning process
set.seed(30)

# Grid search
mtry.vals <- seq(1, p, by = 1)
errors <- numeric(length(mtry.vals))
names(errors) <- mtry.vals

# Repeated 5-fold cv for inner resampling
K <- 5
fold.id <- sample(rep(seq_len(K), length.out = nrow(train)))

for (i in seq_along(mtry.vals)) {
  mtry <- mtry.vals[i]

  cindex.fold <- vapply(1:K, function(k) {
    train.cv <- train[fold.id != k, ]
    test.cv <- train[fold.id == k, ]

    fit.cv <- rfsrc(
      formula = form.general,
      data = train.cv,
      ntree = 500,
      mtry = mtry
    )
    pred.cv <- predict(fit.cv, newdata = test.cv)

    concordance(
      object = Surv(days, status) ~ pred.cv$predicted,
      data = test.cv,
      reverse = TRUE
    )$concordance
  }, numeric(1))

  errors[[i]] <- 1 - mean(cindex.fold)
}

best.mtry <- as.numeric(names(which.min(errors)))

# Fit tuned rsf
set.seed(31)
forest.tuned <- rfsrc(
  formula = form.general,
  data = train,
  ntree = 500,
  mtry = best.mtry
)

# Save models in a list
model.list <- list(
  tree = tree,
  base_forest = forest.untuned,
  tuned_forest = forest.tuned
)

# -- Predict models --------------------------
model.pred <- lapply(model.list, function(m) {
  predict(m, newdata = test)
})


# -- Evaluate models -------------------------

## 1) C-Index
c.index <- vapply(names(model.pred), function(model) {
  test.eval <- test
  test.eval$risk <- model.pred[[model]]$predicted

  concordance(
    object = Surv(days, status) ~ risk,
    data = test.eval,
    reverse = TRUE
  )$concordance
}, numeric(1))

c.index

## 2) Brier Score over time
eval.times <- seq(
  from = min(test$days[test$status == 1]),
  to = max(test$days[test$status == 1]),
  length.out = 100
)

brier <- pec(
  object = model.list,
  formula = form.general,
  data = test,
  times = eval.times,
  cens.model = "marginal",
  exact = FALSE,
  splitMethod = "none"
)

plot(brier)


###### Plot for presentation
## Brier score for base forest for thesis
brier.forest <- pec(
  object = model.list["base_forest"],
  formula = form.general,
  data = test,
  times = eval.times,
  cens.model = "marginal",
  exact = FALSE,
  splitMethod = "none"
)

png(
  filename = "results/brier_base_forest.png",
  width = 1000,
  height = 700
)
plot(
  brier.forest,
  xlab = "Days",
  ylab = "Brier score",
  legend = FALSE,
  col = c("gray40", "red"),
  lwd = 2
)
grid()
legend(
  "topright",
  legend = c("Reference", "Random Survival Forest"),
  col = c("gray40", "red"),
  lwd = 2,
  bty = "n"
)
dev.off()
