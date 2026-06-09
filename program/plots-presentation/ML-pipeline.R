source("setup.R")

## -- Creating a graph of machine learning pipeline --------------


pipeline <- grViz("
digraph pipeline {
  graph [
    layout = dot,
    rankdir = LR,
    bgcolor = transparent,
    nodesep = 0.55,
    ranksep = 0.75
  ]
  node [
    shape = box,
    style = 'rounded,filled',
    fillcolor = '#F5F7FA',
    color = '#2C5282',
    penwidth = 1.5,
    fontname = Helvetica,
    fontsize = 16,
    margin = 0.18
  ]
  edge [
    color = '#2C5282',
    penwidth = 1.5,
    arrowsize = 0.8
  ]
  D     [label = 'Data']
  Train [label = 'Training Data']
  Test  [label = 'Test Data']
  Model [label = 'Learner/Model']
  Pred  [label = 'Predictions']
  Eval  [label = 'Evaluation']
  D -> Train
  D -> Test
  Train -> Model
  Model -> Pred
  Test -> Pred
  Pred -> Eval
  { rank = same; Train; Test }
  { rank = same; Model; Pred; Eval }
}
")

pipeline

# Save pipeline
# Export DiagrammeR object to SVG
pipeline.svg <- export_svg(pipeline)
rsvg_png(
  charToRaw(pipeline.svg),
  file = "results/ml_pipeline.png",
  width = 2200,
  height = 650
)
