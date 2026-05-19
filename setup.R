##### setup file --------------------------------------

######### Packages

# List of required packages
packages <- c(
  "randomForestSRC",
  "survival",
  "mlr3",
  "rpart",
  "rpart.plot"
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
