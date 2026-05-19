## Function survTree ---------------------------------------------------

## Helper Function that does the split for a variable
splitVar <- function(x, y) {
  if (var(x) == 0) {
    return(c(stat = Inf, split = NA))
  }

  splits <- sort(unique(x))[-1]
  stats <- c()

  for (i in seq_along(splits)) {
    sp <- x >= splits[i]
    xbinary <- as.numeric(sp)
    stats[i] <- survdiff(y ~ xbinary)$chisq
  }
}
