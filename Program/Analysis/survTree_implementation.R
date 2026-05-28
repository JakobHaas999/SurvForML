#######################################
## Implementation of a survival tree ##
#######################################

##############
# TODO

source("setup.R")

## Function to fit a survival tree
survTree <- function(formula, data, minsize = 3) {
  ## asserts
  assertFormula(formula)
  assertDataFrame(data)
  assertIntegerish(minsize, lower = 1)

  data <- as.data.frame(data)

  mf <- model.frame(formula, data = data)
  y <- model.response(mf)

  if (!inherits(y, "Surv")) {
    stop("Target of 'formula' must be a survival::Surv object.")
  }

  xvars <- attr(terms(formula), "term.labels")

  node.counter <- 0L
  tree.rows <- list()
  fits <- list()

  ## Helper-Function for Nelson-Aalen Estimator
  nelson.aalen <- function(d) {
    fit <- survfit(formula, data = d)
    data.frame(
      time = fit$time,
      chf = fit$cumhaz
    )
  }

  ## Helper-Function to perform a Log-Rank test on
  ## given data d
  logrank.stat <- function(d, group) {
    d$.group <- factor(group)

    if (length(unique(d$.group)) < 2L) {
      return(NA_real_)
    }

    fit <- tryCatch(
      survdiff(
        update(formula, . ~ .group),
        data = d,
        rho = 0
      ),
      error = function(e) NULL
    )

    if (is.null(fit)) {
      return(NA_real_)
    }

    fit$chisq
  }

  ## Helper-Function that finds for given data d the best split
  find.best.split <- function(d) {
    best <- list(
      stat = -Inf,
      split.text = NA_character_,
      left = NULL,
      right = NULL
    )

    for (x in xvars) {
      z <- d[[x]]

      if (is.numeric(z)) {
        vals <- sort(unique(z[!is.na(z)]))
        if (length(z) < 2L) next
        cuts <- head(vals, -1L)

        for (cut in cuts) {
          left <- !is.na(z) & z <= cut
          right <- !is.na(z) & z > cut

          if (sum(left) < minsize || sum(right) < minsize) next

          stat <- logrank.stat(
            d[left | right, , drop = FALSE],
            left[left | right]
          )

          if (!is.na(stat) && stat > best$stat) {
            best <- list(
              stat = stat,
              split.text = paste0(x, " <= ", cut),
              left = left,
              right = right
            )
          }
        }
      } else {
        z <- as.factor(z)
        levs <- levels(z)

        if (length(levs) < 2L) next

        for (lev in levs) {
          left <- !is.na(z) & z == lev
          right <- !is.na(z) & z != lev

          if (sum(left) < minsize || sum(right) < minsize) next

          stat <- logrank.stat(
            d[left | right, , drop = FALSE],
            left[left | right]
          )

          if (!is.na(stat) && stat > best$stat) {
            best <- list(
              stat = stat,
              split.text = paste0(x, " == ", lev),
              left = left,
              right = right
            )
          }
        }
      }
    }

    if (is.infinite(best$stat)) {
      return(NULL)
    }

    best
  }

  ## Helper-Function that grows a tree
  grow <- function(d) {
    node.counter <<- node.counter + 1
    node.number <- node.counter

    split <- NULL

    if (nrow(d) >= 2 * minsize) {
      split <- find.best.split(d)
    }

    is.terminal <- is.null(split)
    row.index <- length(tree.rows) + 1

    tree.rows[[row.index]] <<- data.frame(
      "Node-Number" = node.number,
      "Nobs" = nrow(d),
      "Split" = if (is.terminal) NA_character_ else split$split.text,
      "Terminal-Node" = is.terminal,
      "Child-Node" = NA_character_,
      check.names = FALSE
    )

    if (is.terminal) {
      fits[[as.character(node.number)]] <<- nelson.aalen(d)
      return(node.number)
    }

    left.node <- grow(d[split$left, , drop = FALSE])
    right.node <- grow(d[split$right, , drop = FALSE])

    tree.rows[[row.index]][["Child-Node"]] <<- paste(left.node, right.node, sep = ", ")

    node.number
  }

  grow(data)

  list(
    Tree = do.call(rbind, tree.rows),
    Fits = fits
  )
}

survTree(
  formula = Surv(days, status) ~ age + transfusion + complications,
  data = tumor,
  minsize = 10
)

df <- MASS::Melanoma
df$status <- 1 * (df$status == 1)

survTree(
  Surv(time, status) ~ sex + age + year + thickness + ulcer,
  data = df,
  minsize = 10L
)
