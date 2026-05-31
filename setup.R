##### setup file --------------------------------------

######### Packages

# List of required packages
packages <- c(
  "randomForestSRC",
  "survival",
  "mlr3",
  "rpart",
  "rpart.plot",
  "data.table",
  "ggplot2",
  "survminer",
  "gt",
  "DiagrammeR",
  "DiagrammeRsvg",
  "rsvg",
  "mlr3proba",
  "mlr3tuning",
  "randomForestSRC",
  "paradox",
  "mlr3extralearners",
  "future",
  "progressr",
  "mlr3viz",
  "checkmate",
  "lgr",
  "partykit",
  "knitr",
  "kableExtra"
)

# Function that checks if a package is installed and installs it if not
# Input:
#  - a character(1) which is the name of the package
checkInstalled <- function(pkg) {
  stopifnot(is.character(pkg) && length(pkg) == 1) # base R assert

  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(sprintf("'%s' was not installed", pkg))
    install.packages(pkg, dependencies = TRUE)
  }
}

for (p in packages) {
  checkInstalled(p)
  suppressPackageStartupMessages(library(p, character.only = TRUE))
}

# Remove variables that are not needed anymore
rm(p, packages, checkInstalled)

# Set global theme
ggplot2::theme_set(ggplot2::theme_bw())
