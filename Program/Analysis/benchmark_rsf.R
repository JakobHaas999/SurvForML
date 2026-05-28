source("setup.R")

#####################################
## Benchmark study for ##############
## Random Survival Forests ##########

# Define tasks
# as.data.table(mlr_tasks)[task_type == "surv"]
tsk.gbsg <- tsk("gbsg")
data("tumor", package = "pammtools")
tsk.tumor <- TaskSurv$new(
  id = "tumor",
  backend = tumor,
  time = "days",
  event = "status"
)

tasks <- list(
  tsk.gbsg = tsk.gbsg,
  tsk.tumor = tsk.tumor
)

# Overview over tasks
tsk.summary <- rbindlist(lapply(tasks, function(task) {
  target <- task$data(cols = task$target_names)
  data.table(
    task = task$id,
    n = task$nrow,
    p = length(task$feature_names),
    events = sum(target$status == 1),
    event_rate = mean(target$status == 1),
    censoring_rate = mean(target$status == 0)
  )
}))
tsk.summary

# Define learners
# as.data.table(mlr_learners)[task_type == "surv", .(key, label)]
kaplan.lrn <- lrn("surv.kaplan", predict_type = "distr", id = "Kaplan")
coxph.lrn <- lrn("surv.coxph", predict_type = "distr", id = "Cox")
base.rsf.lrn <- lrn("surv.rfsrc",
  predict_type = "distr",
  ntree = 500,
  id = "base.rsf"
)


# Define meausres
measure.cindex <- msr("surv.cindex")
measure.graf <- msr("surv.graf")
measures <- list(measure.cindex, measure.graf)

# Define tuning instance
at.rsf <- AutoTuner$new(
  tuner = tnr("random_search"),
  learner = lrn("surv.rfsrc", predict_type = "distr", ntree = 500),
  resampling = rsmp("cv", folds = 3),
  measure = measure.brier,
  search_space = ps(
    mtry.ratio = p_dbl(0.1, 1),
    nodesize = p_int(3, 50)
  ),
  terminator = trm("evals", n_evals = 30),
  store_tuning_instance = TRUE,
  id = "surv.rfsrc.tuned"
)

learners <- list(
  kaplan.lrn,
  coxph.lrn,
  base.rsf.lrn,
  at.rsf
)

# Outer resampling
outer.rsmp <- rsmp("repeated_cv", folds = 5, repeats = 3)

bmr.grd <- benchmark_grid(
  tasks = tasks,
  learners = learners,
  resamplings = outer.rsmp
)


set.seed(1840)
lgr::get_logger("mlr3")$set_threshold("warn")
# Run benchmark
plan("multisession", workers = 7)
with_progress(bmr <- benchmark(bmr.grd))



results <- bmr$aggregate(measures)[
  , .(task_id, learner_id, surv.cindex, surv.graf)
]
results
# Save file
saveRDS(results, file = "results/benchmark_results.rds")


p.cindex <- autoplot(bmr, measure = measure.cindex)
p.graf <- autoplot(bmr, measure = measure.graf)
# Save plots
ggsave(
  filename = "Results/benchmark_cindex.png",
  plot = p.cindex,
  width = 8,
  height = 5,
  dpi = 300
)
ggsave(
  filename = "Results/benchmark_graf.png",
  plot = p.graf,
  width = 8,
  height = 5,
  dpi = 300
)
