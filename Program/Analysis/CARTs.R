########################################
## Example for CARTS -------------------

source("setup.R")

## Classification tree -----------------
head(iris)

tree.iris <- rpart(
  formula = Species ~ .,
  data = iris,
  control = rpart.control(
    minsplit = 10,
    cp = 0.1,
    maxdepth = 4
  )
)

png(
  filename = "results/iris_tree.png",
  width = 1200,
  height = 800,
  res = 150
)

rpart.plot(
  tree.iris,
  type = 2,
  extra = 104,
  fallen.leaves = TRUE,
  box.palette = "YlGnBl",
  shadow.col = "gray"
)

dev.off()

## Regression tree --------------------
head(mtcars)

tree.mtcars <- rpart(
  formula = mpg ~ .,
  data = mtcars
)

rpart.plot(
  tree.mtcars,
  type = 2,
  fallen.leaves = TRUE,
  box.palette = "Greens",
  shadow.col = "gray"
)
