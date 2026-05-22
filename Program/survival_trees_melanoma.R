source("setup.R")

## Load data
data("Melanoma", package = "MASS")
# ?MASS::Melanoma
head(Melanoma)

Melanoma$status <- 1 * (Melanoma$status == 1)
table(Melanoma$status)

# Fit a survival tree with "logrank" statistic
tree.melanoma <- rfsrc(
  formula = Surv(time, status) ~ .,
  data = Melanoma,
  ntree = 1,
  splitrule = "logrank",
  mtry = ncol(Melanoma) - 2,
  nodesize = 15,
  nsplit = 0,
  bootstrap = "none",
  membership = TRUE,
  forest = TRUE
)

tr <- get.tree(tree.melanoma, tree.id = 1, show.plots = TRUE)
plot(tr)

pred.tree <- predict(tree.melanoma,
  newdata = Melanoma,
  membership = TRUE
)
Melanoma$terminal.node <- as.factor(pred.tree$membership)
table(Melanoma$terminal.node)

# Kaplan Meier estimates
km.nodes <- survfit(
  Surv(time, status) ~ terminal.node,
  data = Melanoma
)
