#' Copy SS3 model files (flat directory, no recursion)
#'
#' @param fromDir Source directory (e.g. \code{retro0}).
#' @param toDir Destination directory (created if needed).
#' @noRd
copySsModelFlat <- function(fromDir, toDir) {
  if (!dir.exists(fromDir)) {
    stop("Source directory not found: ", fromDir)
  }
  if (dir.exists(toDir)) {
    unlink(toDir, recursive = TRUE)
  }
  dir.create(toDir, recursive = TRUE, showWarnings = FALSE)
  fs <- list.files(fromDir, full.names = TRUE)
  for (f in fs) {
    if (isTRUE(file.info(f)$isdir[[1]])) {
      next
    }
    file.copy(f, file.path(toDir, basename(f)), overwrite = TRUE)
  }
}

#' Remove typical SS3 run outputs so a projection folder can be re-run
#'
#' Keeps input files (e.g. \code{data.ss}, \code{control.ss}). Removes \code{*.sso},
#' new par files, ADMB side files, etc. Converged \code{ss3.par}/\code{ss.par} must be
#' copied back from the peel separately.
#'
#' @noRd
removeSs3ProjectionOutputs <- function(dir) {
  if (!dir.exists(dir)) {
    return(invisible(NULL))
  }
  fl <- list.files(dir, full.names = TRUE)
  for (f in fl) {
    if (isTRUE(file.info(f)$isdir[[1]])) {
      next
    }
    bn <- basename(f)
    ex <- tolower(tools::file_ext(bn))
    rm <- ex == "sso" ||
      ex == "ss_new" ||
      ex %in% c("std", "cor", "cov") ||
      grepl("^admodel\\.", bn, ignore.case = TRUE) ||
      bn %in% c(
        "console.output.txt",
        "fmin.log",
        "ss.par",
        "ss3.par",
        "variance.sso"
      )
    if (isTRUE(rm)) {
      unlink(f)
    }
  }
  invisible(NULL)
}

#' Copy converged parameter file(s) from the reference peel directory
#'
#' @noRd
copyConvergedParFromPeel <- function(peelDir, destDir) {
  for (nm in c("ss3.par", "ss.par")) {
    src <- file.path(peelDir, nm)
    if (file.exists(src)) {
      file.copy(src, file.path(destDir, nm), overwrite = TRUE)
    }
  }
}

#' Reset \code{forecast.ss} and \code{starter.ss} from the peel (before re-patching)
#'
#' @noRd
resetForecastStarterFromPeel <- function(peelDir, destDir) {
  for (nm in c("forecast.ss", "starter.ss")) {
    src <- file.path(peelDir, nm)
    if (file.exists(src)) {
      file.copy(src, file.path(destDir, nm), overwrite = TRUE)
    }
  }
}

#' TRUE if a projection folder already has a finished SS3 report
#'
#' @noRd
projectionRunComplete <- function(scenDir) {
  file.exists(file.path(scenDir, "Report.sso"))
}

#' Patch starter.ss to start from ss.par and skip estimation (forecast / projection pass)
#'
#' Sets \code{init_values_src = 1} and \code{last_estimation_phase = 0} (SS3.30 line order
#' as written by \code{r4ss::SS_writestarter}).
#'
#' @param starterPath Path to \code{starter.ss}.
#' @noRd
patchStarterProjectionPass <- function(starterPath) {
  lines <- readLines(starterPath, warn = FALSE)
  idxInit <- grep("#_init_values_src", lines, fixed = TRUE)
  idxPhase <- grep("#_last_estimation_phase", lines, fixed = TRUE)
  if (length(idxInit) != 1L || length(idxPhase) != 1L) {
    stop("Could not find init_values_src or last_estimation_phase lines in ", starterPath)
  }
  lines[idxInit] <- sub("^[0-9]+", "1", lines[idxInit])
  lines[idxPhase] <- sub("^[0-9]+", "0", lines[idxPhase])
  writeLines(lines, starterPath)
}

#' Locate \code{data.ss} (or first \code{data*.ss}) in a run directory
#'
#' @noRd
findDataSs <- function(dir) {
  f <- file.path(dir, "data.ss")
  if (file.exists(f)) {
    return(f)
  }
  alt <- list.files(dir, pattern = "^data.*\\.ss$", full.names = TRUE)
  if (length(alt)) {
    return(alt[[1]])
  }
  stop("No data.ss (or data*.ss) in ", dir)
}

#' Read SS3 data file; uses \code{[[} to avoid partial matching on \code{$catch}.
#'
#' @noRd
readSsDat <- function(dir, version = "3.30") {
  fp <- findDataSs(dir)
  r4ss::SS_readdat(fp, version = version, verbose = FALSE)
}

#' Build \code{ForeCatch} for fixed dead catch by fleet from a reference \code{SS_readdat} list
#'
#' Rows use calendar year \code{y} from \code{forecastYears}. Catch values come from the
#' reference data for year \code{y} when present; otherwise the last available year
#' \eqn{\le y}{<= y} for that fleet (season structure preserved).
#'
#' @noRd
foreCatchReportedFromDat <- function(dat, forecastYears, nfish, inputBasis) {
  cx <- dat[["catch"]]
  if (is.null(cx) || !is.data.frame(cx) || nrow(cx) < 1L) {
    stop("dat[['catch']] is missing or empty")
  }
  yrCol <- if ("year" %in% names(cx)) {
    "year"
  } else if ("yr" %in% names(cx)) {
    "yr"
  } else {
    stop("catch table needs year or yr column")
  }
  catchCol <- if ("catch" %in% names(cx)) {
    "catch"
  } else if ("totcatch" %in% names(cx)) {
    "totcatch"
  } else {
    stop("catch table needs catch or totcatch column")
  }
  if (!"fleet" %in% names(cx)) {
    stop("catch table needs fleet column")
  }
  seasCol <- if ("seas" %in% names(cx)) {
    "seas"
  } else if ("season" %in% names(cx)) {
    "season"
  } else {
    NULL
  }
  cx <- cx[!is.na(cx[[yrCol]]) & cx[[yrCol]] > -900L, , drop = FALSE]

  rows <- list()
  for (y in forecastYears) {
    for (fl in seq_len(nfish)) {
      hit <- cx[cx[[yrCol]] == y & cx[["fleet"]] == fl, , drop = FALSE]
      if (nrow(hit) == 0L) {
        prev <- cx[cx[["fleet"]] == fl & cx[[yrCol]] <= y, , drop = FALSE]
        if (nrow(prev) == 0L) {
          next
        }
        yTake <- max(prev[[yrCol]])
        hit <- cx[cx[[yrCol]] == yTake & cx[["fleet"]] == fl, , drop = FALSE]
      }
      if (nrow(hit) == 0L) {
        next
      }
      for (i in seq_len(nrow(hit))) {
        seasVal <- if (!is.null(seasCol)) {
          hit[[seasCol]][i]
        } else {
          1L
        }
        cv <- hit[[catchCol]][i]
        if (isTRUE(as.integer(inputBasis) == -1L)) {
          rows[[length(rows) + 1L]] <- data.frame(
            year = y,
            seas = seasVal,
            fleet = fl,
            catch_or_F = cv,
            basis = 2L,
            stringsAsFactors = FALSE
          )
        } else {
          rows[[length(rows) + 1L]] <- data.frame(
            year = y,
            seas = seasVal,
            fleet = fl,
            catch_or_F = cv,
            stringsAsFactors = FALSE
          )
        }
      }
    }
  }
  out <- if (length(rows)) {
    do.call(rbind, rows)
  } else {
    data.frame()
  }
  if (nrow(out) < 1L) {
    stop(
      "Empty ForeCatch for reported catch; check reference data catch table and Nfleet."
    )
  }
  out
}

#' Apply projection scenario to an \code{SS_readforecast} list (\code{readAll = TRUE})
#'
#' \describe{
#'   \item{\code{catchReported}}{Fixed catches from \code{referenceDat} (full assessment
#'     \code{retro0}); \code{Forecast = 2} with \code{ForeCatch} filled (input catch
#'     overrides \eqn{F}{F} policy in SS3).}
#'   \item{\code{fMeanFull}}{\code{Forecast = 4} (mean \eqn{F}{F} multiplier); relative
#'     \eqn{F}{F} averaging range set to styr--endyr (\code{-999} / \code{0} on
#'     \code{Fcast_years[3:4]}).}
#'   \item{\code{fZero}}{\code{Forecast = 5}, \code{F_scalar = 0}}
#'   \item{\code{fMsy}}{\code{Forecast = 2} (F at MSY benchmark)}
#' }
#'
#' @param fc List from \code{r4ss::SS_readforecast(..., readAll = TRUE)}.
#' @param scenario One of \code{catchReported}, \code{fMeanFull}, \code{fZero}, \code{fMsy}.
#' @param referenceDat List from \code{SS_readdat} for the reference assessment (e.g.
#'   \code{retro0}); required for \code{catchReported}.
#' @param forecastYears Integer vector of calendar years (length \code{Nforecastyrs}).
#' @noRd
patchForecastForScenario <- function(fc, scenario, referenceDat, forecastYears) {
  scenario <- match.arg(
    scenario,
    choices = c("catchReported", "fMeanFull", "fZero", "fMsy")
  )
  fc$ForeCatch <- NULL
  if (identical(scenario, "catchReported")) {
    if (is.null(referenceDat)) {
      stop("referenceDat is required for scenario 'catchReported'")
    }
    nfish <- as.integer(unlist(referenceDat["Nfleet"])[1])
    if (is.na(nfish) || nfish < 1L) {
      stop("Invalid Nfleet in reference data")
    }
    ib <- as.integer(unlist(fc["InputBasis"])[1])
    fc$ForeCatch <- foreCatchReportedFromDat(referenceDat, forecastYears, nfish, ib)
    fc$Forecast <- 2
    fc$F_scalar <- 1
  } else if (identical(scenario, "fMeanFull")) {
    fc$Forecast <- 4
    fc$F_scalar <- 1
    fy <- fc[["Fcast_years"]]
    if (is.null(fy) || length(fy) < 4L) {
      stop("fc[['Fcast_years']] must have at least 4 elements")
    }
    fc[["Fcast_years"]][3L] <- -999
    fc[["Fcast_years"]][4L] <- 0
  } else if (identical(scenario, "fZero")) {
    fc$Forecast <- 5
    fc$F_scalar <- 0
  } else if (identical(scenario, "fMsy")) {
    fc$Forecast <- 2
    fc$F_scalar <- 1
  }
  fc
}

#' Run SS3 projections for four forecast reference scenarios
#'
#' Copies a **converged** model directory (must contain \code{ss3.par} or \code{ss.par}),
#' writes scenario subfolders under \code{outParent}. Scenarios:
#' \strong{reported catch} (fixed catches from the reference assessment data file),
#' \strong{mean historical F} (\code{Forecast = 4}, relative \eqn{F}{F} averaged over
#' styr--endyr), \strong{\eqn{F=0}{F=0}} (\code{Forecast = 5}, \code{F_scalar = 0}),
#' \strong{\eqn{F=F_\mathrm{MSY}}{F=FMSY}} (\code{Forecast = 2}). Patches
#' \code{starter.ss} to read \code{ss3.par}/\code{ss.par} and use
#' \code{last_estimation_phase = 0}, then runs the executable in each folder.
#' That projection pass does \strong{not} re-estimate the assessment; it only evaluates
#' benchmarks/forecast using the converged parameters.
#'
#' Reported catches are read from \code{referenceDataDir} (default: \code{retro0} next to
#' the peel). Forecast calendar years are \code{seq(peel endyr + 1, length.out = Nforecastyrs)}
#' from \code{forecast.ss}.
#'
#' Requires Stock Synthesis 3.30.x-compatible \code{forecast.ss} (as read by
#' \code{r4ss::SS_readforecast(..., readAll = TRUE)}).
#'
#' @param baseDir Path to the reference run (e.g. \code{.../retrospectives/retro-3}).
#' @param outParent Parent folder; creates e.g. \code{file.path(outParent, "catchReported")},
#'   \code{fMeanFull}, \code{fZero}, \code{fMsy}.
#' @param ssExe SS3 executable name or path (e.g. \code{"ss3"} or \code{"ss3.exe"}).
#' @param ssVersion Passed to \code{r4ss::SS_readforecast} / \code{SS_readdat}.
#' @param scenarios Character vector, subset of
#'   \code{c("catchReported", "fMeanFull", "fZero", "fMsy")}.
#' @param referenceDataDir Directory with the **full** assessment data file (usually
#'   \code{.../retrospectives/retro0}). Used only for \code{catchReported}. Default:
#'   \code{file.path(dirname(baseDir), "retro0")}.
#' @param forecastYears Optional integer vector of calendar forecast years. Overrides
#'   \code{Nforecastyrs} from \code{forecast.ss} (length sets \code{Nforecastyrs}).
#' @param runLogical If \code{FALSE}, only copy and patch files; do not call the executable.
#' @param reuseProjectionWorkdir If \code{TRUE} (default), copy the peel into a single
#'   working directory \code{file.path(outParent, ".ss3_projection_work")}, re-patch
#'   \code{forecast.ss}/\code{starter.ss} from the peel between scenarios, and snapshot
#'   results into each \code{outParent/<scenario>} folder. This avoids one full directory
#'   copy from the peel per scenario (faster I/O). If \code{FALSE}, each scenario folder
#'   is populated by a full \code{copySsModelFlat} from \code{baseDir} (older behaviour).
#' @param removeProjectionWorkdir If \code{TRUE} (default) and \code{reuseProjectionWorkdir},
#'   delete \code{.ss3_projection_work} after all scenarios finish.
#' @param skipExistingForecastRuns If \code{TRUE}, do not invoke SS3 for a scenario when
#'   \code{file.path(outParent, <scenario>)} already contains \code{Report.sso} (resume /
#'   avoid redundant runs). Delete \code{Report.sso} (or the whole scenario folder) to force
#'   a new run. Ignored when \code{runLogical} is \code{FALSE}. Default \code{FALSE}.
#' @param nohess If \code{TRUE} (default), invoke SS3 with \code{-nohess}. Projection passes
#'   do not re-estimate parameters; Hessian/sdreport is usually unnecessary and slow.
#' @return Invisibly, a named integer vector of \code{system2} exit codes (\code{NA} if not run).
#' @seealso \code{\link{runFlevelProjectionsPeels}}; \code{vignette("ss3-retro-projections", package = "sstruth")}.
#' @export
runFlevelProjections <- function(
    baseDir,
    outParent,
    ssExe = "ss3",
    ssVersion = "3.30",
    scenarios = c("catchReported", "fMeanFull", "fZero", "fMsy"),
    referenceDataDir = NULL,
    forecastYears = NULL,
    runLogical = TRUE,
    reuseProjectionWorkdir = TRUE,
    removeProjectionWorkdir = TRUE,
    skipExistingForecastRuns = FALSE,
    nohess = TRUE) {
  if (!any(file.exists(file.path(baseDir, c("ss3.par", "ss.par"))))) {
    stop("No ss3.par or ss.par in baseDir (need converged run): ", baseDir)
  }
  fcPath <- file.path(baseDir, "forecast.ss")
  if (!file.exists(fcPath)) {
    stop("forecast.ss not found in baseDir: ", baseDir)
  }
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Package r4ss is required for runFlevelProjections()")
  }

  referenceDataDir <- referenceDataDir %||% file.path(dirname(baseDir), "retro0")
  if (any(scenarios == "catchReported") && !dir.exists(referenceDataDir)) {
    stop(
      "referenceDataDir not found (needed for catchReported): ",
      referenceDataDir
    )
  }

  fcTemplate <- r4ss::SS_readforecast(
    fcPath,
    version = ssVersion,
    readAll = TRUE,
    verbose = FALSE
  )
  datPeel <- readSsDat(baseDir, version = ssVersion)
  peelEndyr <- as.integer(unlist(datPeel["endyr"])[1])
  if (is.na(peelEndyr)) {
    stop("Could not read endyr from peel data file in ", baseDir)
  }
  if (!is.null(forecastYears)) {
    forecastYears <- as.integer(forecastYears)
    if (!length(forecastYears)) {
      stop("forecastYears must be a non-empty integer vector.", call. = FALSE)
    }
    ny <- length(forecastYears)
  } else {
    ny <- as.integer(unlist(fcTemplate["Nforecastyrs"])[1])
    if (is.na(ny) || ny < 1L) {
      stop("Invalid Nforecastyrs in ", fcPath)
    }
    forecastYears <- seq(peelEndyr + 1L, by = 1L, length.out = ny)
  }

  datRef <- NULL
  if (any(scenarios == "catchReported")) {
    datRef <- readSsDat(referenceDataDir, version = ssVersion)
  }

  dir.create(outParent, recursive = TRUE, showWarnings = FALSE)

  exitCodes <- stats::setNames(rep(NA_integer_, length(scenarios)), scenarios)

  resolveExe <- function() {
    exe <- ssExe
    if (.Platform$OS.type == "windows" && !grepl("\\.exe$", exe, ignore.case = TRUE)) {
      exeTry <- paste0(ssExe, ".exe")
      if (nzchar(Sys.which(exeTry))) {
        exe <- exeTry
      }
    }
    exe
  }

  runSs3Exe <- function(exe) {
    ssArgs <- if (isTRUE(nohess)) "-nohess" else character()
    system2(exe, ssArgs, wait = TRUE)
  }

  ## Patch forecast + starter for one scenario; optionally run SS3 in runDir (working directory restored)
  patchWriteRunInDir <- function(runDir, sc) {
    fc <- r4ss::SS_readforecast(
      file.path(runDir, "forecast.ss"),
      version = ssVersion,
      readAll = TRUE,
      verbose = FALSE
    )
    fc <- patchForecastForScenario(fc, sc, datRef, forecastYears)
    fc$Nforecastyrs <- ny
    r4ss::SS_writeforecast(fc, dir = runDir, overwrite = TRUE, verbose = FALSE)
    patchStarterProjectionPass(file.path(runDir, "starter.ss"))
    if (!isTRUE(runLogical)) {
      return(NA_integer_)
    }
    exe <- resolveExe()
    ow <- getwd()
    on.exit(setwd(ow), add = TRUE)
    setwd(runDir)
    runSs3Exe(exe)
  }

  if (isTRUE(reuseProjectionWorkdir)) {
    workDir <- file.path(outParent, ".ss3_projection_work")
    copySsModelFlat(baseDir, workDir)
    for (sc in scenarios) {
      scenDir <- file.path(outParent, sc)
      if (isTRUE(skipExistingForecastRuns) && isTRUE(runLogical) &&
        projectionRunComplete(scenDir)) {
        message("Skipping SS3 for ", sc, ": Report.sso already in ", scenDir)
        exitCodes[[sc]] <- 0L
        next
      }
      ## Clean prior scenario outputs, then restore converged par (removeSs3ProjectionOutputs
      ## deletes ss3.par/ss.par; they must come from the peel after cleaning).
      removeSs3ProjectionOutputs(workDir)
      copyConvergedParFromPeel(baseDir, workDir)
      resetForecastStarterFromPeel(baseDir, workDir)
      exitCodes[[sc]] <- patchWriteRunInDir(workDir, sc)
      copySsModelFlat(workDir, scenDir)
    }
    if (isTRUE(removeProjectionWorkdir) && dir.exists(workDir)) {
      unlink(workDir, recursive = TRUE)
    }
  } else {
    for (sc in scenarios) {
      scenDir <- file.path(outParent, sc)
      if (isTRUE(skipExistingForecastRuns) && isTRUE(runLogical) &&
        projectionRunComplete(scenDir)) {
        message("Skipping SS3 for ", sc, ": Report.sso already in ", scenDir)
        exitCodes[[sc]] <- 0L
        next
      }
      copySsModelFlat(baseDir, scenDir)
      exitCodes[[sc]] <- patchWriteRunInDir(scenDir, sc)
    }
  }

  invisible(exitCodes)
}

#' Run forecast scenarios for each retrospective peel
#'
#' For each \code{retro*} folder under \code{retroRoot}, calls
#' \code{\link{runFlevelProjections}} with \code{baseDir = file.path(retroRoot, tag)} and
#' \code{outParent} set to that peel directory (or \code{file.path(baseDir, withinPeel)}).
#' Scenario runs are written as subfolders of each retrospective directory, e.g.
#' \code{retroRoot/retro-5/catchReported}, \code{retroRoot/retro-5/fMeanFull}, \ldots
#'
#' @param retroRoot Path to \code{retrospectives/} (contains \code{retro0}, \code{retro-1}, ...).
#' @param withinPeel Optional subdirectory name **inside** each \code{retro*} folder where
#'   scenario folders are created. \code{NULL} or \code{""} (default): scenarios sit directly
#'   under \code{retroRoot/retro-5/}, etc. Example: \code{"f_projections"} gives
#'   \code{retroRoot/retro-5/f_projections/catchReported}.
#' @param ssExe Passed to \code{runFlevelProjections}.
#' @param ssVersion Passed to \code{runFlevelProjections}.
#' @param scenarios Passed to \code{runFlevelProjections}.
#' @param referenceDataDir Passed to \code{runFlevelProjections} (default \code{NULL}:
#'   each peel uses \code{file.path(retroRoot, "retro0")} via \code{runFlevelProjections}).
#' @param retroYears Integer vector of peel indices (e.g. \code{0:-10}); \code{NULL}
#'   uses every directory in \code{retroRoot} whose name matches \code{^retro}.
#' @param runLogical Passed to \code{runFlevelProjections}.
#' @param reuseProjectionWorkdir Passed to \code{runFlevelProjections}.
#' @param removeProjectionWorkdir Passed to \code{runFlevelProjections}.
#' @param skipExistingForecastRuns Passed to \code{runFlevelProjections}.
#' @param nohess Passed to \code{runFlevelProjections}.
#' @param parallelPeels If \code{TRUE} and there is more than one peel folder, run
#'   \code{runFlevelProjections} per peel in parallel via \code{future.apply} (separate
#'   processes; each peel uses its own working copy). Default \code{FALSE} (sequential).
#' @param peelWorkers Maximum parallel workers when \code{parallelPeels} is \code{TRUE}.
#'   \code{NULL} caps at \code{min(available cores omit 1, number of peels)}.
#' @return Invisibly, a named list: names are peel folders (\code{retro0}, ...); each
#'   element is the exit-code vector from \code{runFlevelProjections}.
#' @seealso \code{\link{runFlevelProjections}}; \code{vignette("ss3-retro-projections", package = "sstruth")}.
#' @export
runFlevelProjectionsPeels <- function(
    retroRoot,
    withinPeel = NULL,
    ssExe = "ss3",
    ssVersion = "3.30",
    scenarios = c("catchReported", "fMeanFull", "fZero", "fMsy"),
    referenceDataDir = NULL,
    retroYears = NULL,
    runLogical = TRUE,
    reuseProjectionWorkdir = TRUE,
    removeProjectionWorkdir = TRUE,
    skipExistingForecastRuns = FALSE,
    nohess = TRUE,
    parallelPeels = FALSE,
    peelWorkers = NULL) {
  if (!dir.exists(retroRoot)) {
    stop("retroRoot not found: ", retroRoot)
  }
  if (!is.null(referenceDataDir) && !dir.exists(referenceDataDir)) {
    stop("referenceDataDir not found: ", referenceDataDir)
  }

  if (is.null(retroYears)) {
    peelTags <- sort(list.files(retroRoot, pattern = "^retro"))
  } else {
    peelTags <- retroTag(as.integer(retroYears))
    miss <- !file.exists(file.path(retroRoot, peelTags))
    if (any(miss)) {
      stop(
        "Missing peel folder(s): ",
        paste(peelTags[miss], collapse = ", "),
        " under ",
        retroRoot
      )
    }
  }
  if (length(peelTags) < 1L) {
    stop("No retro* directories found in ", retroRoot)
  }

  useSub <- !is.null(withinPeel) && nzchar(as.character(withinPeel)[1])

  runOnePeel <- function(tag) {
    baseDir <- file.path(retroRoot, tag)
    peelOut <- if (useSub) {
      file.path(baseDir, withinPeel)
    } else {
      baseDir
    }
    runFlevelProjections(
      baseDir = baseDir,
      outParent = peelOut,
      ssExe = ssExe,
      ssVersion = ssVersion,
      scenarios = scenarios,
      referenceDataDir = referenceDataDir,
      runLogical = runLogical,
      reuseProjectionWorkdir = reuseProjectionWorkdir,
      removeProjectionWorkdir = removeProjectionWorkdir,
      skipExistingForecastRuns = skipExistingForecastRuns,
      nohess = nohess
    )
  }

  useParallel <- isTRUE(parallelPeels) && length(peelTags) > 1L
  if (useParallel) {
    nwMax <- if (is.null(peelWorkers)) {
      max(1L, parallelly::availableCores(omit = 1L))
    } else {
      max(1L, as.integer(peelWorkers))
    }
    nw <- min(nwMax, length(peelTags))
    oldPlan <- future::plan(future::multisession, workers = nw)
    tryCatch(
      {
        allCodes <- future.apply::future_lapply(peelTags, runOnePeel)
      },
      finally = {
        future::plan(oldPlan)
      }
    )
    names(allCodes) <- peelTags
  } else {
    allCodes <- vector("list", length(peelTags))
    names(allCodes) <- peelTags
    for (i in seq_along(peelTags)) {
      allCodes[[i]] <- runOnePeel(peelTags[[i]])
    }
  }

  invisible(allCodes)
}
