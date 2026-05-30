source("setup.R")

## -- Visualization of Concordance-index

# Example data
cindex.dt <- data.table(
  panel = factor(
    rep(c(
      "1. Concordant pair",
      "2. Discordant pair",
      "3. Tied pair"
    ), each = 2),
    levels = c(
      "1. Concordant pair",
      "2. Discordant pair",
      "3. Tied pair"
    )
  ),
  individual = rep(c("Patient A", "Patient B"), 3),
  time = c(
    2, 5,
    2, 5,
    2, 5
  ),
  status = c(
    1, 0,
    1, 1,
    1, 0
  ),
  riskhat = c(
    0.8, 0.2,
    0.2, 0.8,
    0.5, 0.5
  )
)

cindex.dt[, `:=`(
  y = fifelse(individual == "Patient A", 2, 1),
  endpoint = fifelse(status == 1, "Event", "Censored"),
  risklabel = sprintf("Predicted risk = %s", riskhat)
)]

cindex.plot <- ggplot(cindex.dt) +
  geom_segment(
    aes(x = 0, xend = time, y = y, yend = y),
    linewidth = 1
  ) +
  geom_point(
    aes(x = time, y = y, shape = endpoint),
    size = 3.5
  ) +
  geom_text(
    aes(x = 0.15, y = y + 0.08, label = risklabel),
    hjust = 0,
    size = 3.4
  ) +
  facet_wrap(~panel, nrow = 1) +
  scale_shape_manual(
    values = c("Event" = 16, "Censored" = 4)
  ) +
  scale_y_continuous(
    breaks = c(1, 2),
    labels = c("Patient B", "Patient A"),
    limits = c(0.25, 2.45)
  ) +
  scale_x_continuous(
    limits = c(0, 6)
  ) +
  labs(
    x = "Observed follow-up time",
    y = NULL,
    shape = NULL
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(face = "bold")
  )

cindex.plot

## Save plot
ggsave(
  filename = "c_index_plot.svg",
  plot = cindex.plot,
  path = "results",
  width = 10,
  height = 5,
  units = "in",
  bg = "white"
)

## Graphical plot of permissible pairs for c index

# Save as png
png("results/graph_c_index.png", width = 1000, height = 200)
par(mar = c(0, 0, 0, 0))
# Coordinates of the five vertexes
x <- 1:5
y <- rep(0, length(x))

plot(
  NA,
  xlim = c(0.6, 5.4),
  ylim = c(-0.5, 0.2),
  asp = 1,
  axes = FALSE,
  xlab = "",
  ylab = ""
)

nodes.col <- character(5)
nodes.col[seq_along(nodes.col) %% 2 == 1] <- "black"
nodes.col[seq_along(nodes.col) %% 2 == 0] <- "red"

points(
  x, y,
  pch = 21,
  cex = 3.5,
  bg = nodes.col,
  lwd = 1.3
)

labels <- expression(t[1], t[2], t[3], t[4], t[5])

text(
  x = x,
  y = y + 0.22,
  labels = labels,
  cex = 1.45
)

dev.off()
