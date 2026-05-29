source("setup.R")

#####################################
## Benchmark study for ##############
## Random Survival Forests ##########

## Define tasks
tsk.gbsg <- tsk("gbsg", id = "gbsg")
data("tumor", package = "pammtools")
tsk.tumor <- TaskSurv$new(
  id = "tumor",
  backend = tumor,
  time = "days",
  event = "status"
)

tasks <- list(
  tsk.gbsg,
  tsk.tumor
)

# Overview over tasks
tsk.summary <- rbindlist(lapply(tasks, function(task) {
  target <- task$data(cols = task$target_names)
  data.table(
    task = task$id,
    n = task$nrow,
    p = length(task$feature_names),
    event_rate = mean(target$status == 1),
    censoring_rate = mean(target$status == 0)
  )
}))
tsk.summary

## Define Learners

# Tuned Random Survival Forest
tuner <- tnr("random_search")
learner <- lrn("surv.rfsrc", ntree = 500, predict_type = "distr")
# Inner resampling
resampling <- rsmp("cv", folds = 5)
msr.graf <- msr("surv.graf", p_max = 0.8)
terminator <- trm("evals", n_evals = 30)
search.space <- ParamSet$new(
  params = list(
    mtry.ratio = p_dbl(.1, 1),
    nodesize = p_int(3, 50)
  )
)
at.rsf <- AutoTuner$new(
  tuner = tuner,
  learner = learner,
  resampling = resampling,
  measure = msr.graf,
  terminator = terminator,
  search_space = search.space,
  id = "surv.rsf.tuned"
)

# Define untuned learners
lrn.kaplan <- lrn("surv.kaplan", id = "Kaplan", predict_type = "distr")
lrn.cox <- lrn("surv.coxph", id = "Coxph", predict_type = "distr")
lrn.rsf.base <- lrn("surv.rfsrc",
  id = "Rsf.untuned",
  ntree = 500,
  predict_type = "distr"
)

learners <- list(
  lrn.kaplan,
  lrn.cox,
  lrn.rsf.base,
  at.rsf
)

## Define outer resampling
outer.resampling <- rsmp("repeated_cv", folds = 5, repeats = 3)

## Define Benchmark Grid
bmr.grd <- benchmark_grid(
  tasks = tasks,
  learners = learners,
  resamplings = outer.resampling
)

## Run Benchmark
set.seed(1645)
lgr::get_logger("mlr3")$set_threshold("warn")
future::plan(future::multisession, workers = 7)
bmr <- tryCatch(
  {
    with_progress(
      benchmark(bmr.grd, store_models = TRUE)
    )
  },
  finally = {
    future::plan(future::sequential)
  }
)


## Define measures
measures <- list(msr.graf, msr("surv.cindex"))

## Show results
results <- bmr$aggregate(measures)[
  ,
  .(task_id, learner_id, surv.cindex, surv.graf)
]

## Plot results
p.cindex <- autoplot(bmr, measure = msr("surv.cindex"))
p.graf <- autoplot(bmr, measure = msr.graf)

## Save results
saveRDS(results, file = "results/benchmark_results.rds")
ggsave(
  filename = "results/benchmark_cindex.png",
  plot = p.cindex,
  width = 8,
  height = 5,
  dpi = 300
)
ggsave(
  filename = "results/benchmark_graf.png",
  plot = p.graf,
  width = 8,
  height = 5,
  dpi = 300
)
