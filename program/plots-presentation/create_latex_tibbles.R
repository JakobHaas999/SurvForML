source("setup.R")

## Create tables in latex code

## Head of tumor data as latex table
data("tumor", package = "pammtools")
kable(
  head(tumor, 4),
  format = "latex",
  booktabs = TRUE,
  digits = 3,
  caption = "Head of pammtools::tumor dataset",
  label = "tumor"
) |>
  kable_styling(latex_options = c("hold_position", "scale_down"))

## Head of gbsg data as latex tibble
gbsg <- as.data.table(survival::gbsg)
cols <- c("rfstime", "status", setdiff(names(gbsg), c("rfstime", "status")))

gbsg <- gbsg[, ..cols]

kable(
  head(gbsg, 4),
  format = "latex",
  booktabs = TRUE,
  digits = 3,
  caption = "Head of survival::gbsg dataset",
  label = "gbsg"
) |>
  kable_styling(latex_options = c("hold_position", "scale_down"))


# Summary of tasks of benchmark
kable(
  readRDS("results/tasks_summary.rds"),
  format = "latex",
  booktabs = TRUE,
  digits = 3,
  caption = "Summary of tasks",
  label = "task-summ"
) |>
  kable_styling(latex_options = c("hold_position", "scale_down"))
