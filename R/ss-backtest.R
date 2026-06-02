#' Convert peel depths to \code{r4ss::retro()} year indices
#'
#' @param peelYears Non-negative integers: \code{0} = full fit, \code{1} = peel one
#'   year, \code{5} = peel five years, etc.
#' @return Integer vector for \code{r4ss::retro(..., years = )} (e.g. \code{c(0, -1, -5)}).
#' @export
retroYearsFromPeel <- function(peelYears) {
  peelYears <- sort(unique(as.integer(peelYears)))
  if (any(is.na(peelYears) | peelYears < 0L)) {
    stop("peelYears must be non-negative integers.", call. = FALSE)
  }
  ifelse(peelYears == 0L, 0L, -peelYears)
}

#' Build parameter list for \code{\link{retroBacktestData}} from one scenario directory
#'
#' @param runDir SS3 scenario directory (contains \code{starter.ss}).
#' @param peelYears Peel depths passed to \code{\link{retroYearsFromPeel}}.
#' @param retroSubdir Retrospective output subdirectory name.
#' @param forecastHorizons Forecast horizons for ratio tables.
#' @param runRetro If \code{TRUE}, run \code{r4ss::retro()} when collecting.
#' @param ssExe SS3 executable.
#' @param retroWorkers Parallel workers for retro / collect.
#' @export
ssBacktestParams <- function(
  runDir,
  peelYears = c(0, 1, 5, 10, 20),
  retroSubdir = "retrospectives",
  forecastHorizons = 1:3,
  runRetro = FALSE,
  ssExe = Sys.getenv("SS3_EXE", unset = "ss3"),
  retroWorkers = NULL,
  ssVersion = "3.30",
  retroVerbose = FALSE
) {
  runDir <- normalizePath(runDir, winslash = "/", mustWork = TRUE)
  list(
    ssBase = runDir,
    scenarioDirs = "",
    retroSubdir = retroSubdir,
    retroYears = retroYearsFromPeel(peelYears),
    forecastHorizons = forecastHorizons,
    runRetro = runRetro,
    ssExe = ssExe,
    retroWorkers = retroWorkers,
    ssVersion = ssVersion,
    retroVerbose = retroVerbose,
    parallelCollect = TRUE
  )
}

.peelEndYear <- function(peelDir, ssVersion = "3.30") {
  dat <- readSsDat(peelDir, version = ssVersion)
  as.integer(unlist(dat["endyr"])[1])
}

.fullAssessmentYear <- function(retroRoot, ssVersion = "3.30", cache = TRUE) {
  baseDir <- file.path(retroRoot, "retro0")
  rep <- if (isTRUE(cache) && file.exists(ssCache(baseDir))) {
    readRDS(ssCache(baseDir))
  } else {
    ssRead(baseDir, writeCache = isTRUE(cache))
  }
  if (is.null(rep)) {
    stop("Could not read SS_output from ", baseDir, call. = FALSE)
  }
  assessmentMaxYear(rep)
}

#' Two-stage back-test projections for one retrospective peel
#'
#' \enumerate{
#'   \item Hindcast with **reported catch** from peel terminal through the full
#'     assessment year (\code{\link{retroForecastTargetYears}}).
#'   \item Management projection for \code{managementYears} at \eqn{F=0} and
#'     \eqn{F=F_\mathrm{MSY}}{F=FMSY}, chained from the hindcast end state when present.
#' }
#'
#' @param peelDir Path to \code{retro*} folder (converged \code{ss3.par} required).
#' @param referenceDataDir Full-assessment directory (\code{retro0}) for reported catch.
#' @param fullLastYr Last calendar year of the full assessment.
#' @param outSubdir Subfolder under \code{peelDir} for projection outputs (default \code{"backtest"}).
#' @param managementYears Length of \eqn{F=0} / \eqn{F=F_\mathrm{MSY}} projection.
#' @inheritParams runFlevelProjections
#' @return Invisibly, a list with \code{catchReported}, \code{fZero}, and \code{fMsy} exit codes.
#' @export
runBacktestProjectionsPeel <- function(
  peelDir,
  referenceDataDir,
  fullLastYr,
  outSubdir = "backtest",
  managementYears = 100L,
  ssExe = "ss3",
  ssVersion = "3.30",
  runLogical = TRUE,
  reuseProjectionWorkdir = TRUE,
  removeProjectionWorkdir = TRUE,
  skipExistingForecastRuns = FALSE,
  nohess = TRUE
) {
  peelDir <- normalizePath(peelDir, winslash = "/", mustWork = TRUE)
  fullLastYr <- as.integer(fullLastYr)
  peelEndyr <- .peelEndYear(peelDir, ssVersion = ssVersion)
  hindcastYrs <- retroForecastTargetYears(peelEndyr, fullLastYr)
  outParent <- file.path(peelDir, outSubdir)
  codes <- list(catchReported = NA_integer_, fZero = NA_integer_, fMsy = NA_integer_)

  mgmtBase <- peelDir
  if (length(hindcastYrs)) {
    message(
      "[backtest] ", basename(peelDir),
      ": reported catch ", min(hindcastYrs), "–", max(hindcastYrs)
    )
    codes$catchReported <- runFlevelProjections(
      baseDir = peelDir,
      outParent = outParent,
      ssExe = ssExe,
      ssVersion = ssVersion,
      scenarios = "catchReported",
      referenceDataDir = referenceDataDir,
      forecastYears = hindcastYrs,
      runLogical = runLogical,
      reuseProjectionWorkdir = reuseProjectionWorkdir,
      removeProjectionWorkdir = removeProjectionWorkdir,
      skipExistingForecastRuns = skipExistingForecastRuns,
      nohess = nohess
    )
    catchDir <- file.path(outParent, "catchReported")
    if (isTRUE(runLogical) && !projectionRunComplete(catchDir)) {
      stop("catchReported projection did not produce Report.sso in ", catchDir, call. = FALSE)
    }
    mgmtBase <- catchDir
  } else {
    message("[backtest] ", basename(peelDir), ": no hindcast years (peel at full span)")
  }

  mgmtStart <- fullLastYr + 1L
  mgmtYrs <- seq(mgmtStart, by = 1L, length.out = as.integer(managementYears))
  message(
    "[backtest] ", basename(peelDir),
    ": F=0 and F=FMSY for ", managementYears, " yrs (",
    mgmtStart, "–", max(mgmtYrs), ")"
  )
  mgmtCodes <- runFlevelProjections(
    baseDir = mgmtBase,
    outParent = outParent,
    ssExe = ssExe,
    ssVersion = ssVersion,
    scenarios = c("fZero", "fMsy"),
    forecastYears = mgmtYrs,
    runLogical = runLogical,
    reuseProjectionWorkdir = reuseProjectionWorkdir,
    removeProjectionWorkdir = removeProjectionWorkdir,
    skipExistingForecastRuns = skipExistingForecastRuns,
    nohess = nohess
  )
  codes$fZero <- mgmtCodes[["fZero"]]
  codes$fMsy <- mgmtCodes[["fMsy"]]
  invisible(codes)
}

#' Back-test projections for all peels under \code{retrospectives/}
#'
#' @param retroRoot Path containing \code{retro0}, \code{retro-1}, \ldots
#' @param retroYears Peel indices (\code{NULL} = all \code{retro*} folders).
#' @inheritParams runBacktestProjectionsPeel
#' @inheritParams runFlevelProjectionsPeels
#' @export
runBacktestProjectionsPeels <- function(
  retroRoot,
  retroYears = NULL,
  referenceDataDir = NULL,
  fullLastYr = NULL,
  outSubdir = "backtest",
  managementYears = 100L,
  ssExe = "ss3",
  ssVersion = "3.30",
  runLogical = TRUE,
  parallelPeels = FALSE,
  peelWorkers = NULL,
  ...
) {
  retroRoot <- normalizePath(retroRoot, winslash = "/", mustWork = TRUE)
  referenceDataDir <- referenceDataDir %||% file.path(retroRoot, "retro0")
  if (is.null(fullLastYr)) {
    fullLastYr <- .fullAssessmentYear(retroRoot, ssVersion = ssVersion)
  }

  if (is.null(retroYears)) {
    peelTags <- sort(list.files(retroRoot, pattern = "^retro"))
  } else {
    peelTags <- retroTag(as.integer(retroYears))
  }
  peelTags <- peelTags[dir.exists(file.path(retroRoot, peelTags))]
  if (!length(peelTags)) {
    stop("No retro* directories under ", retroRoot, call. = FALSE)
  }

  runOne <- function(tag) {
    runBacktestProjectionsPeel(
      peelDir = file.path(retroRoot, tag),
      referenceDataDir = referenceDataDir,
      fullLastYr = fullLastYr,
      outSubdir = outSubdir,
      managementYears = managementYears,
      ssExe = ssExe,
      ssVersion = ssVersion,
      runLogical = runLogical,
      ...
    )
  }

  if (isTRUE(parallelPeels) && length(peelTags) > 1L) {
    nw <- peelWorkers %||% max(1L, parallel::detectCores(logical = TRUE) - 1L)
    nw <- min(as.integer(nw), length(peelTags))
    old <- future::plan(future::multisession, workers = nw)
    on.exit(future::plan(old), add = TRUE)
    out <- stats::setNames(
      future.apply::future_lapply(peelTags, function(tag) runOne(tag)),
      peelTags
    )
  } else {
    out <- stats::setNames(lapply(peelTags, runOne), peelTags)
  }
  invisible(out)
}

#' Retrospective back-testing workflow
#'
#' Runs tail-cut retrospectives (\code{r4ss::retro()}), optional two-stage forecast
#' projections (reported catch to the current year, then \eqn{F=0} and \eqn{F=F_\mathrm{MSY}}
#' for \code{managementYears}), and optionally collects diagnostic tables.
#'
#' @param runDir SS3 scenario directory.
#' @param peelYears Peel depths in years (\code{0}, \code{1}, \code{5}, \code{10}, \code{20}, ...).
#' @param retroSubdir Output subdirectory for peels (default \code{"retrospectives"}).
#' @param runRetro Run \code{r4ss::retro()} re-fits.
#' @param runForecast Run hindcast + management projections (\code{\link{runBacktestProjectionsPeels}}).
#' @param collect If \code{TRUE}, return \code{\link{retroBacktestData}} tables.
#' @param managementYears Length of \eqn{F=0} / \eqn{F=F_\mathrm{MSY}} projections.
#' @param forecastHorizons Horizons for retrospective ratio tables.
#' @param ssExe SS3 executable.
#' @param ssVersion SS3 / r4ss version string.
#' @param retroWorkers Parallel workers for retros.
#' @param peelWorkers Parallel workers for projection peels.
#' @param parallelPeels Parallelize across peels in the forecast step.
#' @param retroVerbose Verbose \code{r4ss::retro()} output.
#' @param ... Passed to \code{\link{runBacktestProjectionsPeels}}.
#' @return If \code{collect = TRUE}, the list from \code{\link{retroBacktestData}}; otherwise
#'   invisibly, a list with \code{params}, \code{retroRoot}, and \code{forecast} status.
#' @export
ssBacktest <- function(
  runDir,
  peelYears = c(0, 1, 5, 10, 20),
  retroSubdir = "retrospectives",
  runRetro = TRUE,
  runForecast = TRUE,
  collect = TRUE,
  managementYears = 100L,
  forecastHorizons = 1:3,
  ssExe = Sys.getenv("SS3_EXE", unset = "ss3"),
  ssVersion = "3.30",
  retroWorkers = NULL,
  peelWorkers = NULL,
  parallelPeels = FALSE,
  retroVerbose = FALSE,
  ...
) {
  params <- ssBacktestParams(
    runDir = runDir,
    peelYears = peelYears,
    retroSubdir = retroSubdir,
    forecastHorizons = forecastHorizons,
    runRetro = FALSE,
    ssExe = ssExe,
    retroWorkers = retroWorkers,
    ssVersion = ssVersion,
    retroVerbose = retroVerbose
  )
  retroRoot <- file.path(params$ssBase, params$retroSubdir)
  forecastStatus <- NULL

  if (isTRUE(runRetro)) {
    message("[ssBacktest] retrospectives: peel years ", paste(peelYears, collapse = ", "))
    params$runRetro <- TRUE
    runRetros(params$ssBase, params)
    params$runRetro <- FALSE
  }

  if (isTRUE(runForecast)) {
    if (!dir.exists(retroRoot)) {
      stop(
        "Retrospectives not found at ", retroRoot,
        "; run with runRetro = TRUE first.",
        call. = FALSE
      )
    }
    message("[ssBacktest] forecast projections (managementYears = ", managementYears, ")")
    forecastStatus <- runBacktestProjectionsPeels(
      retroRoot = retroRoot,
      retroYears = params$retroYears,
      managementYears = managementYears,
      ssExe = ssExe,
      ssVersion = ssVersion,
      parallelPeels = parallelPeels,
      peelWorkers = peelWorkers,
      ...
    )
  }

  if (isTRUE(collect)) {
    out <- retroBacktestData(params)
    out$forecastStatus <- forecastStatus
    return(out)
  }
  invisible(list(params = params, retroRoot = retroRoot, forecast = forecastStatus))
}
