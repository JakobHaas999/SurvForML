## Log rank splitting example for survival trees

source("setup.R")

# Load data
data("tumor", package = "pammtools")
tumor <- as.data.table(tumor)
head(tumor)
# Select relevant columns
tumor <- tumor[, .(days, status, complications, transfusion, age)]


### Part 1: Only binary features
# Calculate log-rank test statistic for every feature

# Select only binary features
features <- setdiff(colnames(tumor), c("days", "status", "age"))
log.rank.binary <- list()

for (feat in features) {
  logrank.test <- survdiff(
    formula = as.formula(paste("Surv(days, status) ~", feat)),
    data = tumor,
    rho = 0
  )

  km.fit <- survfit(
    formula = as.formula(paste("Surv(days, status) ~", feat)),
    data = tumor
  )

  km.plot <- ggsurvplot(
    km.fit,
    data = tumor,
    ggtheme = theme_bw(),
    palette = c("#E0A82E", "#124734"),
    legend.title = feat,
    xlab = "Time in days",
    pval = sprintf(
      "Log-rank statistic: %.2f",
      sqrt(logrank.test$chisq)
    ),
    pval.coord = c(2000, 0.95),
    pval.size = 8,
    conf.int = TRUE
  )
  log.rank.binary[[feat]] <- list(logrank = logrank.test$chisq, plot = km.plot)
}

# Combinied plots
com.plot <- arrange_ggsurvplots(
  x <- lapply(log.rank.binary, function(x) x$plot),
  print = FALSE,
  ncol = 2
)


### Part 2: Numeric feature age
# Calculate log-rank statistic for every split point

# Find all possible split points
ready.to.split <- sort(unique(tumor$age))
split.points <- ready.to.split[-length(ready.to.split)] + diff(ready.to.split) / 2


log.rank.age <- list()

# Loop through all possible split points
for (sp in split.points) {
  dt <- data.table(
    days = tumor$days,
    status = tumor$status,
    age.ind = ifelse(tumor$age < sp, 0, 1)
  )

  # Logrank test
  logrank.test <- survdiff(
    formula = Surv(days, status) ~ age.ind,
    data = dt,
    rho = 0
  )

  # Kaplan Meier
  km.fit <- survfit(
    formula = Surv(days, status) ~ age.ind,
    data = dt
  )

  # Survival curves
  km.plot <- ggsurvplot(
    km.fit,
    data = dt,
    ggtheme = surv.theme,
    palette = surv.palette,
    legend.title = feat,
    xlab = "Time in days",
    pval = sprintf(
      "Log-rank statistic: %.2f",
      sqrt(logrank.test$chisq)
    ),
    pval.coord = c(2000, 0.95),
    pval.size = 8,
    conf.int = TRUE
  )

  log.rank.age[[as.character(sp)]] <- list(logrank = logrank.test$chisq, plot = km.plot)
}

# Find minimum
maximizer <- names(log.rank.age)[
  which.max(lapply(log.rank.age, function(x) x$logrank))
]
maximizer

###

### Save plot
ggsave(
  filename = "results/logrank_splits_tumor.png",
  plot = com.plot,
  width = 15,
  height = 4.5,
  units = "in",
  dpi = 300,
  bg = "white"
)
