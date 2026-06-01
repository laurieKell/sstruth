#' Calendar years to forecast for a retrospective peel up to the full assessment span
#'
#' For a peel with terminal year \eqn{T} and a reference (non-peeled) assessment whose
#' output extends through \code{fullLastYr} (typically \code{assessmentMaxYear(repFull)}),
#' returns \eqn{T+1, \ldots, }{T+1,…,}\code{fullLastYr}. Empty if \eqn{T \ge}{T ≥}
#' \code{fullLastYr}.
#'
#' Use these years in \code{forecast.ss} (number of forecast years, input catches or
#' \eqn{F}) so each retrospective run projects across the same calendar horizon as the
#' full assessment, for contrast scenarios: (i) reported catch; (ii) estimated \eqn{F}
#' from the full assessment; (iii) \eqn{F=0}; (iv) \eqn{F=F_\mathrm{MSY}}{F=FMSY}.
#'
#' @param peelEndyr Integer terminal year of the peel (last data year in that retro).
#' @param fullLastYr Last calendar year in the full assessment timeseries (TIME or FORE).
#' @return Integer vector of target years, increasing, or \code{integer(0)}.
#' @seealso \code{\link{assessmentMaxYear}}, \code{\link{baseCatchFTable}},
#'   \code{\link{collectRetro}}, \code{\link{runFlevelProjections}},
#'   \code{\link{runFlevelProjectionsPeels}}.
#' @export
retroForecastTargetYears <- function(peelEndyr, fullLastYr) {
  peelEndyr <- as.integer(peelEndyr[[1]])
  fullLastYr <- as.integer(fullLastYr[[1]])
  if (is.na(peelEndyr) || is.na(fullLastYr) || peelEndyr >= fullLastYr) {
    return(integer(0))
  }
  seq(peelEndyr + 1L, fullLastYr, by = 1L)
}

#' Canonical forecast contrast subfolder names for \code{runFlevelProjections*()}
#'
#' Returns \code{c("catchReported", "fMeanFull", "fZero", "fMsy")}. Use this in
#' case-study configs instead of duplicating literals.
#'
#' @return Character vector of length four.
#' @seealso \code{\link{runFlevelProjections}}, \code{\link{runFlevelProjectionsPeels}}.
#' @export
forecastContrastScenarios <- function() {
  c("catchReported", "fMeanFull", "fZero", "fMsy")
}

#' Summary: target forecast years and reference catch / \eqn{F} table (no SS3 runs)
#'
#' After \code{r4ss::retro()}, reads \code{retro0} and one peel directory, computes
#' calendar years from peel terminal through the full assessment span (see
#' \code{\link{retroForecastTargetYears}}), and builds \code{\link{baseCatchFTable}} for
#' those years. For automated \code{forecast.ss} patching and SS3 runs, use
#' \code{\link{runFlevelProjectionsPeels}}.
#'
#' @param scenarioDir Path to the SS3 scenario directory (contains \code{starter.ss}).
#' @param retroSubdir Name under the scenario dir, usually \code{"retrospectives"}.
#' @param examplePeel Peel index (non-positive; \code{0} = \code{retro0}).
#' @param ssVersion Passed to \code{r4ss::SS_readdat}.
#' @param verbose If \code{TRUE}, \code{message()} a short summary.
#' @return A list with \code{fullLastYr}, \code{peelEndYr}, \code{targetYrs} (integer),
#'   \code{table} (tibble from \code{baseCatchFTable}, possibly empty rows),
#'   \code{peelDir}, \code{baseDir}.
#' @export
retroForecastScenarioSummary <- function(scenarioDir,
                                         retroSubdir = "retrospectives",
                                         examplePeel = -5L,
                                         ssVersion = "3.30",
                                         verbose = TRUE) {
  scenarioDir <- normalizePath(scenarioDir, winslash = "/", mustWork = TRUE)
  retroRoot <- file.path(scenarioDir, retroSubdir)
  peelDir <- file.path(retroRoot, retroTag(examplePeel))
  baseDir <- file.path(retroRoot, "retro0")
  stopifnot(dir.exists(peelDir), dir.exists(baseDir))

  starter <- r4ss::SS_readstarter(file.path(scenarioDir, "starter.ss"), verbose = FALSE)
  datFn <- starter$datfile %||% "data.ss"
  dat <- r4ss::SS_readdat(file.path(scenarioDir, datFn), version = ssVersion, verbose = FALSE)

  repFull <- r4ss::SS_output(baseDir, forecast = TRUE, verbose = FALSE, printstats = FALSE)
  repPeel <- r4ss::SS_output(peelDir, forecast = TRUE, verbose = FALSE, printstats = FALSE)

  fullLastYr <- assessmentMaxYear(repFull)
  peelEndYr <- endYear(repPeel)
  targetYrs <- retroForecastTargetYears(peelEndYr, fullLastYr)

  tab <- if (length(targetYrs)) {
    baseCatchFTable(repFull, dat, targetYrs)
  } else {
    baseCatchFTable(repFull, dat, integer())
  }

  if (verbose) {
    message("Full assessment (retro0) last timeseries year: ", fullLastYr)
    message("Example peel ", examplePeel, " terminal year: ", peelEndYr)
    message(
      "Forecast target calendar years (peel T+1 … full span): ",
      if (length(targetYrs)) paste(range(targetYrs), collapse = "–") else "(none — check peel vs full span)"
    )
  }

  list(
    fullLastYr = fullLastYr,
    peelEndYr = peelEndYr,
    targetYrs = targetYrs,
    table = tab,
    peelDir = peelDir,
    baseDir = baseDir
  )
}

#' Reported catch and estimated fishing mortality from the reference assessment
#'
#' Pulls **TIME** rows first, then **FORE** if needed, matching
#' \code{spawnIx()} / \code{refIx()} logic. Reported catch uses \code{catchDat()}.
#'
#' @param repFull Output from \code{r4ss::SS_output()} for the **non-peeled** model.
#' @param dat Output from \code{r4ss::SS_readdat()}.
#' @param years Integer vector of calendar years.
#' @return A tibble with columns \code{year}, \code{reportedCatch}, \code{estF},
#'   \code{deadCatchTs} (from timeseries), \code{era} (\code{TIME} or \code{FORE}).
#' @seealso \code{\link{retroForecastTargetYears}}, \code{\link{catchDat}},
#'   \code{\link{refIx}}.
#' @export
baseCatchFTable <- function(repFull, dat, years) {
  if (length(years) < 1L) {
    return(tibble::tibble(
      year = integer(),
      reportedCatch = double(),
      estF = double(),
      deadCatchTs = double(),
      era = character()
    ))
  }
  nf <- nFish(repFull)
  tsB <- tsDf(repFull)
  rows <- vector("list", length(years))
  for (i in seq_along(years)) {
    y <- as.integer(years[i])
    iTime <- spawnIx(repFull, y, "TIME")
    era <- "TIME"
    ix <- iTime
    if (is.na(ix)) {
      ix <- spawnIx(repFull, y, "FORE")
      era <- "FORE"
    }
    deadTs <- if (!is.na(ix)) deadB(tsB, ix, repFull) else NA_real_
    estF <- if (!is.na(ix)) fleetF(tsB, ix) else NA_real_
    rows[[i]] <- tibble::tibble(
      year = y,
      reportedCatch = catchDat(dat, y, nf),
      estF = estF,
      deadCatchTs = deadTs,
      era = era
    )
  }
  dplyr::bind_rows(rows)
}

#' Reference management trajectories from the full (non-peeled) assessment
#'
#' Returns calendar-year series for: \strong{(i)} reported catch in the data file
#' (\code{catchDat}); \strong{(ii)} estimated sum apical \eqn{F} from the assessment
#' timeseries (TIME, else FORE); \strong{(iii)} \eqn{F_\mathrm{MSY}}{FMSY} as the
#' scalar \code{annF_MSY} benchmark from derived quantities (repeated each year for
#' plotting a flat reference trajectory); \strong{(iv)} \eqn{F=0} as a constant
#' zero benchmark (management reference, not from a separate SS3 run).
#'
#' These are \emph{not} alternative SS3 forecast runs; they summarize what the
#' converged reference model says about observed catch, estimated \eqn{F}, and the
#' MSY fishing-mortality benchmark. Contrast with peel-specific \code{peelTrajLong()}
#' outputs, which come from each retrospective folder’s \code{SS_output}.
#'
#' @param repFull Output from \code{r4ss::SS_output()} for \strong{retro0} (or the
#'   full assessment directory).
#' @param dat Output from \code{r4ss::SS_readdat()}.
#' @param years Integer vector of calendar years.
#' @return A tibble with \code{year}, \code{reportedCatch}, \code{estF},
#'   \code{deadCatchTs}, \code{era}, \code{fMsyBenchmark} (\code{annF_MSY}),
#'   \code{fZeroBenchmark} (always \code{0}).
#' @seealso \code{\link{baseCatchFTable}}, \code{\link{peelTrajLong}}.
#' @export
referenceManagementTable <- function(repFull, dat, years) {
  tab <- baseCatchFTable(repFull, dat, years)
  if (nrow(tab) < 1L) {
    return(tab)
  }
  fm <- dqVal(repFull, "annF_MSY")
  dplyr::mutate(tab, fMsyBenchmark = fm, fZeroBenchmark = 0)
}
