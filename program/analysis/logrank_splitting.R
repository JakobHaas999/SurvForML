## Log rank splitting example for survival trees

source("setup.R")

# Load data
data("tumor", package = "pammtools")
tumor <- as.data.table(tumor)
head(tumor)
# Select relevant columns
tumor <- tumor[, .(days, status, complications, transfusion, age)]

surv.theme <- theme_bw() +
  theme(
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 13),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.position = "bottom",
    plot.margin = margin(5, 5, 5, 5)
  )
surv.palette <- c("#E0A82E", "#124734")

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
    ggtheme = surv.theme,
    palette = surv.palette,
    legend.title = feat,
    xlab = "Time in days",
    ylab = "Survival probability",
    pval = sprintf(
      "Log-rank statistic: %.2f",
      sqrt(logrank.test$chisq)
    ),
    pval.coord = c(1400, 0.95),
    pval.size = 5.5,
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

### Save plot
ggsave(
  filename = "results/logrank_splits_tumor.png",
  plot = com.plot,
  width = 16,
  height = 7.5,
  units = "in",
  dpi = 300,
  bg = "white"
)
