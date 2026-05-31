source("setup.R")
library("partykit")

## -- Survival tree for tumor data --------------------

# Load data
data("tumor", package = "pammtools")
head(tumor)
tumor <- as.data.table(tumor)
surv.outcomes <- c("days", "status")
features <- c("age", "transfusion", "complications")

form.general <- as.formula(
  paste0(
    "Surv(", paste(surv.outcomes, collapse = ", "), ") ~ ",
    paste(features, collapse = " + ")
  )
)

# Fit tree
tree.tumor <- ctree(
  formula = form.general,
  data = tumor,
  control = ctree_control(
    mincriterion = .95,
    minbucket = 30,
    maxdepth = 3
  )
)

## Plot and save the tree
# png(
#   filename = "results/tree_tumor.png",
#   width = 2600,
#   height = 1500,
#   res = 250
# )
plot(tree.tumor, tp_args = list(FUN = node_surv))
dev.off()
