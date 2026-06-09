source("setup.R")

## Variable Importance Random Survival Forest

# Load data
data("tumor", package = "pammtools")
tumor <- as.data.table(tumor)
# tumor <- tumor[, .(days, status, age, transfusion, complications)]

# Fit a random survival forest
set.seed(12)
rsf.fit <- rfsrc(
  formula = Surv(days, status) ~ .,
  data = tumor,
  importance = "random",
  ntree = 1000
)

rsf.fit$importance

importance.dt <- data.table(
  feature = names(rsf.fit$importance),
  importance = rsf.fit$importance
)

plt.importance <- ggplot(
  importance.dt,
  aes(x = reorder(feature, importance), y = importance)
) +
  geom_col(fill = "#2C5282", color = "#F5F7FA") +
  coord_flip() +
  theme_bw() +
  labs(x = "Feature", y = "Importance")

## Save plot
ggsave(
  filename = "results/feature_importance_rsf.png",
  plot = plt.importance,
  width = 6,
  height = 3,
  units = "in",
  dpi = 300
)
