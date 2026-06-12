# SurvForML

SurvForML contains R code and a Quarto presentation on **Survival Trees** and
**Random Survival Forests** for censored time-to-event data.

The repository is mainly educational. It starts with classical CART examples,
introduces survival-specific splitting via the log-rank statistic, explains
Random Survival Forests, and evaluates survival models with metrics such as the
concordance index, Graf score and Brier score.

## Repository Structure

```text
.
├── program/
│   ├── analysis/              # Analysis scripts and benchmark code
│   └── plots-presentation/    # Scripts used to create slide figures/tables
├── results/                   # Generated plots and saved benchmark output
├── presentation.qmd           # Quarto reveal.js presentation
├── references.bib             # Bibliography for the presentation
├── setup.R                    # Shared package setup
└── SurvForML.Rproj            # RStudio project file
```

## Main Files

- `presentation.qmd`: Quarto reveal.js slides for the seminar presentation.
- `setup.R`: installs missing R packages, loads dependencies and sets the global
  `ggplot2` theme.
- `program/analysis/CARTs.R`: CART examples for classification and regression.
- `program/analysis/logrank_splitting.R`: log-rank splitting example on the
  `pammtools::tumor` data set.
- `program/analysis/tumor_ful.R`: end-to-end example on the `tumor` data set
  with a survival tree, untuned Random Survival Forest, tuned Random Survival
  Forest, C-index evaluation and Brier-score plotting.
- `program/analysis/benchmark_rsf_gbsg_tumor.R`: benchmark comparing baseline
  and Random Survival Forest learners on the `gbsg` and `tumor` survival tasks.
- `program/plots-presentation/`: scripts for figures, LaTeX tables and package
  citation output used in the presentation.
- `results/`: generated figures and saved `.rds` outputs used by the slides.

## Requirements

You need:

- R
- RStudio, optional but convenient
- Quarto, for rendering `presentation.qmd`
- CRAN packages listed in `setup.R`

Install and load the R dependencies with:

```r
source("setup.R")
```

For reproducible package versions, consider initializing `renv` after the setup
works locally:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

## Reproducing the Main Outputs

Clone the repository:

```bash
git clone https://github.com/JakobHaas999/SurvForML.git
cd SurvForML
```

Run the setup:

```r
source("setup.R")
```

Run the benchmark:

```r
source("program/analysis/benchmark_rsf_gbsg_tumor.R")
```

This writes:

- `results/benchmark_results.rds`
- `results/benchmark_cindex.png`
- `results/benchmark_graf.png`

Run the full tumor-data example:

```r
source("program/analysis/tumor_ful.R")
```

This writes:

- `results/brier_base_forest.png`

Generate slide figures and tables by running the scripts in:

```text
program/plots-presentation/
```

Render the presentation with:

```bash
quarto render presentation.qmd
```

The rendered HTML output is ignored by Git via `.gitignore`.

## Models and Evaluation

The analysis uses:

- Kaplan-Meier baseline models
- Cox proportional hazards models
- Single survival trees
- Random Survival Forests
- Tuned Random Survival Forests

The main evaluation criteria are:

- Concordance index
- Graf score
- Brier score over time

## Data

The examples use built-in or package-provided data sets:

- `iris` and `mtcars` for introductory CART examples
- `pammtools::tumor` for survival-tree and Random Survival Forest examples
- `gbsg` from the `mlr3proba` survival task collection for benchmarking

## Notes

The scripts are designed for teaching and presentation purposes. For a fully
reproducible research workflow, the next useful step is to add an `renv.lock`
file after confirming that all scripts run successfully in the intended R
environment.
