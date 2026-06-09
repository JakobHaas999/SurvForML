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
