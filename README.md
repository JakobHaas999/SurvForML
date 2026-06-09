# SurvForML

This repository contains material for a presentation on **Survival Trees** and
**Random Survival Forests**. It combines short R examples, explanatory plots and
a benchmark study for survival models.

The project starts with classical CART models, explains why ordinary regression
trees are not appropriate for censored survival data, introduces log-rank based
survival-tree splitting, and then moves to Random Survival Forests and model
evaluation with survival-specific metrics.

## Contents

```text
.
├── program/
│   ├── analysis/              # Example analyses and benchmark scripts
│   └── plots-presentation/    # Scripts that generate figures for the slides
├── results/                   # Generated plots and benchmark output
├── presentation.qmd           # Quarto / reveal.js presentation
├── references.bib             # Bibliography used by the presentation
├── setup.R                    # Package loading and shared plotting setup
└── SurvForML.Rproj            # RStudio project file
```

## Main Files

- `presentation.qmd`: Quarto reveal.js slides for the presentation.
- `setup.R`: installs missing R packages, loads dependencies and sets a global
  `ggplot2` theme.
- `program/analysis/CARTs.R`: classification and regression tree examples using
  `rpart`.
- `program/analysis/CARTs_survival_data.R`: simulation showing why treating
  observed survival time as an ordinary regression target is problematic under
  censoring.
- `program/analysis/logrank_splitting.R`: log-rank splitting example on the
  `pammtools::tumor` data set.
- `program/analysis/survTree_implementation.R`: simple educational
  implementation of a survival tree.
- `program/analysis/benchmark_rsf_gbsg_tumor.R`: benchmark comparing Kaplan,
  Cox PH, untuned Random Survival Forests and tuned Random Survival Forests.
- `program/plots-presentation/`: figure-generation scripts used by the slides.

## Requirements

The project is written in R and uses Quarto for the presentation.

You need:

- R
- RStudio, optional but convenient
- Quarto
- CRAN packages loaded in `setup.R`

Most dependencies are installed automatically by running:

```r
source("setup.R")
```

For reproducible package versions, initialize `renv` after the packages are
installed and snapshot the working environment:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

## Reproducing the Results

Clone the repository and open the RStudio project:

```bash
git clone https://github.com/JakobHaas999/SurvForML.git
cd SurvForML
```

Then run the setup:

```r
source("setup.R")
```

Generate the main benchmark results:

```r
source("program/analysis/benchmark_rsf_gbsg_tumor.R")
```

This writes:

- `results/benchmark_results.rds`
- `results/benchmark_cindex.png`
- `results/benchmark_graf.png`

Generate presentation figures by running the scripts in
`program/plots-presentation/`.

Render the slides with:

```bash
quarto render presentation.qmd
```

The rendered HTML output is ignored by Git via `.gitignore`.

## Benchmark

The benchmark uses two survival tasks:

- `gbsg` from `mlr3proba`
- `tumor` from `pammtools`

The compared learners are:

- Kaplan-Meier baseline
- Cox proportional hazards model
- Random Survival Forest without tuning
- Random Survival Forest with random-search tuning

Evaluation uses:

- Concordance index
- Graf score

## Notes

This repository is mainly educational. The custom `survTree()` implementation is
intended to make the construction of survival trees transparent; for production
analysis, prefer maintained packages such as `partykit`, `randomForestSRC` or
the `mlr3proba` ecosystem.
