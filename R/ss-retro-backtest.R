#' Timeseries data.frame from \code{r4ss::SS_output()}
#'
#' @param rep A list returned by \code{SS_output()}.
#' @return A single data.frame of the SS3 TIME_SERIES table.
#' @export
tsDf <- function(rep) {
  ts <- rep[["timeseries"]]
  if (is.data.frame(ts)) {
    return(ts)
  }
  if (is.list(ts) && is.data.frame(ts[["timeseries"]])) {
    return(ts[["timeseries"]])
  }
  stop("Could not extract timeseries data.frame from SS_output.")
}

#' Number of fishing fleets
#'
#' @param rep A list returned by \code{SS_output()}.
#' @export
nFish <- function(rep) {
  nf <- rep[["nfishfleets"]]
  if (is.null(nf)) {
    return(NA_integer_)
  }
  if (is.list(nf)) {
    nf <- unlist(nf, use.names = FALSE)
  }
  as.integer(nf[[1]])
}

#' Sum dead(B) catch columns for one timeseries row
#'
#' @param tsdf Timeseries data.frame.
#' @param rowIdx Row index.
#' @param rep A list returned by \code{SS_output()} (for fleet count).
#' @export
deadB <- function(tsdf, rowIdx, rep) {
  nf <- nFish(rep)
  dc <- grep("^dead\\(B\\):", names(tsdf), value = TRUE)
  if (length(dc) == 0L) {
    return(NA_real_)
  }
  use <- seq_len(min(length(dc), nf, na.rm = TRUE))
  sum(as.numeric(tsdf[rowIdx, dc[use], drop = TRUE]), na.rm = TRUE)
}

#' Sum fleet F columns for one timeseries row
#'
#' @param tsdf Timeseries data.frame.
#' @param rowIdx Row index.
#' @export
fleetF <- function(tsdf, rowIdx) {
  fc <- grep("^F:_", names(tsdf), value = TRUE)
  if (length(fc) == 0L) {
    return(NA_real_)
  }
  sum(as.numeric(tsdf[rowIdx, fc, drop = TRUE]), na.rm = TRUE)
}

#' Reported catch total from data file object for one year
#'
#' @param dat List from \code{SS_readdat()}.
#' @param year Calendar year.
#' @param nfish Number of fishing fleets (non-survey).
#' @export
catchDat <- function(dat, year, nfish) {
  if (is.null(dat$catch) || !is.data.frame(dat$catch) || nrow(dat$catch) == 0) {
    return(NA_real_)
  }
  cn <- names(dat$catch)
  yrCol <- if ("year" %in% cn) {
    "year"
  } else if ("yr" %in% cn) {
    "yr"
  } else {
    NA_character_
  }
  flCol <- if ("fleet" %in% cn) {
    "fleet"
  } else if ("fltsvy" %in% cn) {
    "fltsvy"
  } else {
    NA_character_
  }
  catchCol <- if ("catch" %in% cn) {
    "catch"
  } else if ("totcatch" %in% cn) {
    "totcatch"
  } else {
    NA_character_
  }
  if (any(is.na(c(yrCol, catchCol)))) {
    return(NA_real_)
  }
  cx <- dat$catch
  flOk <- if (!is.na(flCol) && !is.na(nfish)) {
    as.numeric(cx[[flCol]]) <= nfish
  } else {
    rep(TRUE, nrow(cx))
  }
  sel <- as.numeric(cx[[yrCol]]) == year & flOk
  sum(as.numeric(cx[[catchCol]][sel]), na.rm = TRUE)
}

#' Terminal year from SS output
#'
#' @param rep A list returned by \code{SS_output()}.
#' @export
endYear <- function(rep) {
  ey <- rep[["endyr"]]
  if (is.list(ey)) {
    ey <- unlist(ey, use.names = FALSE)
  }
  as.integer(ey[[1]])
}

#' Last calendar year present in SS3 timeseries output (TIME or FORE)
#'
#' Uses area 1 and spawn seasons, matching \code{spawnIx()} / \code{refIx()}.
#' Horizons with target year beyond this value are outside the assessment run
#' (data + forecast as configured in the original model).
#'
#' @param rep A list returned by \code{SS_output(..., forecast = TRUE)}.
#' @return Integer year, or \code{NA_integer_} if no matching rows.
#' @export
assessmentMaxYear <- function(rep) {
  ts <- tsDf(rep)
  ss <- rep[["spawnseas"]]
  if (is.null(ss) || length(ss) == 0L) {
    ss <- 1L
  }
  sub <- ts[["Area"]] == 1L & ts[["Seas"]] %in% ss & ts[["Era"]] %in% c("TIME", "FORE")
  if (!any(sub)) {
    return(NA_integer_)
  }
  max(as.integer(ts[["Yr"]][sub]), na.rm = TRUE)
}

#' Subdirectory name for a retrospective peel
#'
#' @param yr Peel index (non-positive integer; \code{0} is \code{retro0}).
#' @export
retroTag <- function(yr) {
  paste0("retro", yr)
}

#' One-step-ahead peel metrics vs base assessment
#'
#' @param repPeel \code{SS_output()} for the peel.
#' @param repBase \code{SS_output()} for the base (\code{retro0}).
#' @param dat Data list from \code{SS_readdat()} for the scenario.
#' @param peelLabel Character peel label.
#' @param pathPeel Path to peel directory (for errors).
#' @export
peelOne <- function(repPeel, repBase, dat, peelLabel, pathPeel) {
  tsP <- tsDf(repPeel)
  tsB <- tsDf(repBase)
  fore <- tsP[tsP$Era == "FORE", , drop = FALSE]
  if (nrow(fore) < 1L) {
    stop("No FORE rows in timeseries for peel ", peelLabel, " (", pathPeel, ")")
  }
  endT <- endYear(repPeel)
  fcYr <- endT + 1L
  iFore <- which(fore$Yr == fcYr)[1]
  if (is.na(iFore)) {
    iFore <- 1L
  }
  refB <- tsB[tsB$Era == "TIME" & tsB$Yr == fcYr, , drop = FALSE]
  baseRefEra <- "TIME"
  if (nrow(refB) < 1L) {
    refB <- tsB[tsB$Era == "FORE" & tsB$Yr == fcYr, , drop = FALSE]
    baseRefEra <- "FORE"
  }
  if (nrow(refB) < 1L) {
    stop(
      "No TIME or FORE row for forecast year ", fcYr, " in base model (peel ",
      peelLabel, "). Check timeseries Eras and years."
    )
  }
  nf <- nFish(repBase)
  catchFore <- deadB(fore, iFore, repPeel)
  forecastF <- fleetF(fore, iFore)
  catchEst <- deadB(refB, 1L, repBase)
  estF <- fleetF(refB, 1L)
  catchRep <- catchDat(dat, fcYr, nf)
  tibble::tibble(
    peel = peelLabel,
    terminalYr = endT,
    forecastYr = fcYr,
    baseRefEra = baseRefEra,
    catchFore = catchFore,
    forecastF = forecastF,
    catchEstBaseTime = catchEst,
    estFBaseTime = estF,
    catchReportedData = catchRep,
    relErrCatchVsEst = if (catchEst != 0 && is.finite(catchEst)) (catchFore - catchEst) / catchEst else NA_real_,
    relErrFVsEst = if (estF != 0 && is.finite(estF)) (forecastF - estF) / estF else NA_real_,
    relErrCatchVsReported = if (!is.na(catchRep) && catchRep != 0 && is.finite(catchRep)) (catchFore - catchRep) / catchRep else NA_real_
  )
}

#' TIME + FORE trajectory rows for one peel (spawn bio, catch, sum F, MSY ratios)
#'
#' One row per calendar year in the peel's timeseries (Area 1, spawn seasons),
#' with \code{phase} = historical (year <= terminal) vs forecast. MSY-relative
#' metrics use the same definitions as \code{peelRatios()}: \strong{Bratio}
#' (\code{Bratio_Y} derived quantity), \strong{F/FMSY} via \code{fFmsy()},
#' \strong{catch/MSY} via \code{catchMsy()} on dead catch.
#'
#' Approximate 95\% intervals use \eqn{\pm 1.96} SE: \strong{Bratio} from
#' \code{dqSd(..., Bratio_Y)}; \strong{F/FMSY} scaling \eqn{F_Y} SE with
#' \code{annF_SPR}/\code{annF_MSY} fixed; \strong{catch/MSY} from \code{Dead_Catch_MSY}
#' SE only (dead catch treated as known).
#'
#' @param rep A list returned by \code{SS_output(..., forecast = TRUE)}.
#' @param peelLabel Character peel label (e.g. \code{"0"}, \code{"-1"}).
#' @param scenario Scenario name (e.g. basename of scenario dir).
#' @return A tibble including \code{bratioLo}/\code{bratioHi},
#'   \code{ffmsyLo}/\code{ffmsyHi}, \code{catchMsyRatioLo}/\code{catchMsyRatioHi}.
#' @export
peelTrajLong <- function(rep, peelLabel, scenario) {
  ts <- tsDf(rep)
  ss <- rep[["spawnseas"]]
  if (is.null(ss) || length(ss) == 0L) {
    ss <- 1L
  }
  sub <- ts[["Area"]] == 1L & ts[["Seas"]] %in% ss & ts[["Era"]] %in% c("TIME", "FORE")
  x <- ts[sub, , drop = FALSE]
  if (nrow(x) < 1L) {
    return(tibble::tibble())
  }
  yrs <- sort(unique(as.integer(x[["Yr"]])))
  endT <- endYear(rep)
  out <- vector("list", length(yrs))
  for (j in seq_along(yrs)) {
    y <- yrs[j]
    rows <- which(as.integer(x[["Yr"]]) == y)
    if (length(rows) < 1L) {
      next
    }
    pref <- x[rows, , drop = FALSE]
    iPick <- if (any(pref[["Era"]] == "TIME")) {
      which(pref[["Era"]] == "TIME")[1]
    } else {
      rows[1L]
    }
    spawnBio <- as.numeric(pref[iPick, "SpawnBio", drop = TRUE])
    catchTot <- deadB(pref, iPick, rep)
    fTot <- fleetF(pref, iPick)
    phase <- if (y <= endT) {
      "historical"
    } else {
      "forecast"
    }
    bratio <- dqVal(rep, paste0("Bratio_", y))
    ffmsy <- fFmsy(rep, y)
    catchMsyRatio <- catchMsy(rep, catchTot)
    z <- 1.96
    bSd <- dqSd(rep, paste0("Bratio_", y))
    bratioLo <- if (!is.na(bSd) && is.finite(bSd) && is.finite(bratio)) {
      bratio - z * bSd
    } else {
      NA_real_
    }
    bratioHi <- if (!is.na(bSd) && is.finite(bSd) && is.finite(bratio)) {
      bratio + z * bSd
    } else {
      NA_real_
    }
    if (!is.na(bratioLo)) {
      bratioLo <- max(0, bratioLo)
    }
    fSd <- dqSd(rep, paste0("F_", y))
    annSpr <- dqVal(rep, "annF_SPR")
    annMsy <- dqVal(rep, "annF_MSY")
    seFf <- if (
      !is.na(fSd) &&
        is.finite(fSd) &&
        !is.na(annSpr) &&
        !is.na(annMsy) &&
        annMsy > 0
    ) {
      abs(annSpr / annMsy) * fSd
    } else {
      NA_real_
    }
    ffmsyLo <- if (!is.na(seFf) && is.finite(seFf) && is.finite(ffmsy)) {
      ffmsy - z * seFf
    } else {
      NA_real_
    }
    ffmsyHi <- if (!is.na(seFf) && is.finite(seFf) && is.finite(ffmsy)) {
      ffmsy + z * seFf
    } else {
      NA_real_
    }
    if (!is.na(ffmsyLo)) {
      ffmsyLo <- max(0, ffmsyLo)
    }
    dmsy <- dqVal(rep, "Dead_Catch_MSY")
    seDmsy <- dqSd(rep, "Dead_Catch_MSY")
    seCm <- if (
      is.finite(catchTot) &&
        !is.na(dmsy) &&
        dmsy > 0 &&
        !is.na(seDmsy) &&
        is.finite(seDmsy)
    ) {
      abs(catchTot / (dmsy^2)) * seDmsy
    } else {
      NA_real_
    }
    catchMsyLo <- if (!is.na(seCm) && is.finite(seCm) && is.finite(catchMsyRatio)) {
      catchMsyRatio - z * seCm
    } else {
      NA_real_
    }
    catchMsyHi <- if (!is.na(seCm) && is.finite(seCm) && is.finite(catchMsyRatio)) {
      catchMsyRatio + z * seCm
    } else {
      NA_real_
    }
    if (!is.na(catchMsyLo)) {
      catchMsyLo <- max(0, catchMsyLo)
    }
    out[[j]] <- tibble::tibble(
      scenario = scenario,
      peel = peelLabel,
      year = y,
      phase = phase,
      spawnBio = spawnBio,
      catch = catchTot,
      fTotal = fTot,
      bratio = bratio,
      ffmsy = ffmsy,
      catchMsyRatio = catchMsyRatio,
      bratioLo = bratioLo,
      bratioHi = bratioHi,
      ffmsyLo = ffmsyLo,
      ffmsyHi = ffmsyHi,
      catchMsyRatioLo = catchMsyLo,
      catchMsyRatioHi = catchMsyHi,
      terminalYr = endT
    )
  }
  dplyr::bind_rows(out)
}

#' Run \code{r4ss::retro()} on directories in parallel via \code{future}
#'
#' Uses \code{future.apply::future_lapply()} when there is more than one directory and
#' \code{retroWorkers > 1}; otherwise a single worker runs scenarios sequentially.
#'
#' @param dirs Character vector of SS3 scenario directories.
#' @param params Named list with \code{retroWorkers}, \code{retroSubdir},
#'   \code{retroYears}, \code{ssExe}, \code{retroVerbose}.
#' @export
runRetros <- function(dirs, params) {
  nWorkers <- params$retroWorkers
  if (is.null(nWorkers)) {
    nWorkers <- max(1L, parallelly::availableCores(omit = 1L))
  } else {
    nWorkers <- as.integer(nWorkers)
  }
  retroOne <- function(d) {
    r4ss::retro(
      dir = d,
      newsubdir = params$retroSubdir,
      years = params$retroYears,
      exe = params$ssExe,
      verbose = params$retroVerbose
    )
  }
  oldPlan <- future::plan(future::multisession, workers = nWorkers)
  tryCatch(
    {
      if (length(dirs) <= 1L || nWorkers <= 1L) {
        lapply(dirs, retroOne)
      } else {
        future.apply::future_lapply(dirs, retroOne)
      }
    },
    finally = {
      future::plan(oldPlan)
    }
  )
}

#' Single value from SS3 derived quantities
#'
#' @param rep A list returned by \code{SS_output()}.
#' @param label Row label in \code{derived_quants}.
#' @export
dqVal <- function(rep, label) {
  dq <- rep[["derived_quants"]]
  if (is.null(dq) || !is.data.frame(dq) || !nrow(dq)) {
    return(NA_real_)
  }
  hit <- dq[["Label"]] == label
  if (!any(hit)) {
    return(NA_real_)
  }
  suppressWarnings(as.numeric(dq[hit, "Value"][[1]]))
}

#' Standard error of a derived quantity (SS3 \code{Report.sso} \code{StdDev} column)
#'
#' @param rep A list returned by \code{SS_output()}.
#' @param label Row label in \code{derived_quants}.
#' @export
dqSd <- function(rep, label) {
  dq <- rep[["derived_quants"]]
  if (is.null(dq) || !is.data.frame(dq) || !nrow(dq)) {
    return(NA_real_)
  }
  hit <- dq[["Label"]] == label
  if (!any(hit)) {
    return(NA_real_)
  }
  suppressWarnings(as.numeric(dq[hit, "StdDev"][[1]]))
}

#' Row index in timeseries for spawn season and era
#'
#' @param rep A list returned by \code{SS_output()}.
#' @param yr Calendar year.
#' @param era \code{"TIME"} or \code{"FORE"}.
#' @export
spawnIx <- function(rep, yr, era) {
  ts <- tsDf(rep)
  ss <- rep[["spawnseas"]]
  if (is.null(ss) || length(ss) == 0L) {
    ss <- 1L
  }
  w <- which(
    ts[["Area"]] == 1L &
      ts[["Seas"]] %in% ss &
      ts[["Era"]] == era &
      as.integer(ts[["Yr"]]) == as.integer(yr)
  )
  if (length(w) == 0L) {
    return(NA_integer_)
  }
  w[[1]]
}

#' Base-model row index: TIME year, else FORE
#'
#' Used so reference metrics align with years the unpeeled assessment actually
#' fits (TIME) or projects (FORE with catch/\eqn{F} inputs).
#'
#' @param repBase A list returned by \code{SS_output()} for the base model.
#' @param yr Calendar year.
#' @export
refIx <- function(repBase, yr) {
  i <- spawnIx(repBase, yr, "TIME")
  if (!is.na(i)) {
    return(i)
  }
  spawnIx(repBase, yr, "FORE")
}

#' F / F_MSY style ratio from derived quantities
#'
#' Uses \eqn{F_Y \times}{F_Y x} annF_SPR / annF_MSY.
#'
#' @param rep A list returned by \code{SS_output()}.
#' @param yr Calendar year.
#' @export
fFmsy <- function(rep, yr) {
  fv <- dqVal(rep, paste0("F_", yr))
  annSpr <- dqVal(rep, "annF_SPR")
  annMsy <- dqVal(rep, "annF_MSY")
  if (is.na(fv) || is.na(annSpr) || is.na(annMsy) || annMsy <= 0) {
    return(NA_real_)
  }
  fv * annSpr / annMsy
}

#' SSB relative to virgin biomass
#'
#' @param rep A list returned by \code{SS_output()}.
#' @param yr Calendar year.
#' @export
ssbOver0 <- function(rep, yr) {
  ssb <- dqVal(rep, paste0("SSB_", yr))
  vir <- dqVal(rep, "SSB_Virgin")
  if (is.na(ssb) || is.na(vir) || vir <= 0) {
    return(NA_real_)
  }
  ssb / vir
}

#' Dead catch relative to MSY benchmark
#'
#' @param rep A list returned by \code{SS_output()}.
#' @param deadCatchTotal Total dead catch (same units as \code{Dead_Catch_MSY}).
#' @export
catchMsy <- function(rep, deadCatchTotal) {
  dmsy <- dqVal(rep, "Dead_Catch_MSY")
  if (is.na(deadCatchTotal) || is.na(dmsy) || dmsy <= 0) {
    return(NA_real_)
  }
  deadCatchTotal / dmsy
}

#' Multi-horizon management ratios for one peel
#'
#' Reference values use \code{refIx(repBase, yr)}: a \strong{TIME} row (data years
#' with reported catch and estimated \eqn{F}) or \strong{FORE} row (forecast years
#' with inputs). Rows with target year \eqn{T+h} beyond \code{assessmentMaxYear(repBase)}
#' are omitted (no ratios past the original assessment’s timeseries range).
#'
#' @param repPeel \code{SS_output()} for the peel.
#' @param repBase \code{SS_output()} for the base.
#' @param peelLabel Character peel label.
#' @param forecastHorizons Integer vector of steps ahead (default \code{1:3}).
#' @export
peelRatios <- function(repPeel, repBase, peelLabel, forecastHorizons = NULL) {
  endT <- endYear(repPeel)
  if (is.null(forecastHorizons)) {
    forecastHorizons <- 1:3
  }
  yrMax <- assessmentMaxYear(repBase)
  rows <- list()
  for (j in seq_along(forecastHorizons)) {
    h <- as.integer(forecastHorizons[j])
    fcYr <- endT + h
    if (!is.na(yrMax) && fcYr > yrMax) {
      next
    }
    iFore <- spawnIx(repPeel, fcYr, "FORE")
    tsP <- tsDf(repPeel)
    catchFore <- if (!is.na(iFore)) deadB(tsP, iFore, repPeel) else NA_real_
    iRef <- refIx(repBase, fcYr)
    tsB <- tsDf(repBase)
    catchRef <- if (!is.na(iRef)) deadB(tsB, iRef, repBase) else NA_real_
    rows[[j]] <- tibble::tibble(
      peel = peelLabel,
      horizon = h,
      forecastYr = fcYr,
      foreBratio = dqVal(repPeel, paste0("Bratio_", fcYr)),
      refBratio = dqVal(repBase, paste0("Bratio_", fcYr)),
      foreSsbVirgin = ssbOver0(repPeel, fcYr),
      refSsbVirgin = ssbOver0(repBase, fcYr),
      foreFfmsy = fFmsy(repPeel, fcYr),
      refFfmsy = fFmsy(repBase, fcYr),
      foreCatchMsy = catchMsy(repPeel, catchFore),
      refCatchMsy = catchMsy(repBase, catchRef)
    )
  }
  dplyr::bind_rows(rows)
}

#' Plot peel vs base management ratios over forecast years
#'
#' @param ratioHor Data frame from stacking \code{peelRatios()} output with a
#'   \code{scenario} column.
#' @param foreCol Name of forecast column.
#' @param refCol Name of reference column.
#' @param ylab Y axis label (expression or character).
#' @param title Plot title.
#' @export
plotRatios <- function(ratioHor, foreCol, refCol, ylab, title) {
  foreDf <- dplyr::transmute(
    ratioHor,
    scenario,
    peel,
    horizon,
    forecastYr,
    fore = .data[[foreCol]]
  )
  refDf <- dplyr::summarise(
    dplyr::group_by(ratioHor, scenario, forecastYr),
    ref = dplyr::first(.data[[refCol]]),
    .groups = "drop"
  )
  ggplot2::ggplot(foreDf, ggplot2::aes(forecastYr, fore, colour = peel, group = peel)) +
    ggplot2::geom_line(linewidth = 0.65) +
    ggplot2::geom_point(size = 1.8, alpha = 0.85) +
    ggplot2::geom_line(
      data = refDf,
      ggplot2::aes(forecastYr, ref),
      inherit.aes = FALSE,
      colour = "black",
      linewidth = 0.75
    ) +
    ggplot2::facet_wrap(~scenario, ncol = 1L, scales = "free") +
    ggplot2::labs(
      title = title,
      subtitle = "Peel FORE (colour) vs base assessment for that year (black).",
      x = "Calendar year (forecast target)",
      y = ylab
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "bottom")
}

#' Collect one-step and multi-step retrospective tables for one scenario
#'
#' Reads \code{retro*} folders under \code{file.path(ssDir, params$retroSubdir)}.
#'
#' @param ssDir Path to the scenario directory (containing \code{starter.ss}).
#' @param params Named list: \code{retroSubdir}, \code{retroYears},
#'   \code{forecastHorizons}, \code{ssVersion}, etc.
#' @return A list with elements \code{res} (one-step), \code{ratioHor} (multi-step),
#'   and \code{traj} (TIME+FORE trajectories per peel: spawn bio, catch, sum F).
#' @seealso \code{\link{retroForecastTargetYears}}, \code{\link{baseCatchFTable}} for
#'   full-span forecast contrast years and reference catch/\eqn{F} lookup from the
#'   non-peeled run.
#' @export
collectRetro <- function(ssDir, params) {
  rd <- file.path(ssDir, params$retroSubdir)
  if (!dir.exists(rd)) {
    stop("Retrospectives folder still missing after retro(): ", rd)
  }
  peels <- params$retroYears
  subdirs <- retroTag(peels)
  paths <- file.path(rd, subdirs)
  ok <- dir.exists(paths)
  if (!all(ok)) {
    stop(
      "Missing retro director(ies) for requested peels:\n",
      paste(paths[!ok], collapse = "\n")
    )
  }

  basePath <- paths[peels == 0][1]
  if (is.na(basePath) || !dir.exists(basePath)) {
    basePath <- ssDir
  }
  repBase <- r4ss::SS_output(basePath, forecast = TRUE, verbose = FALSE, printstats = FALSE)
  starter <- r4ss::SS_readstarter(file.path(ssDir, "starter.ss"), verbose = FALSE)
  datFn <- starter$datfile %||% "data.ss"
  dat <- r4ss::SS_readdat(file.path(ssDir, datFn), version = params$ssVersion, verbose = FALSE)

  outRes <- vector("list", length(peels))
  outRatio <- vector("list", length(peels))
  outTraj <- vector("list", length(peels))
  fh <- params$forecastHorizons
  scen <- basename(ssDir)
  for (i in seq_along(peels)) {
    rp <- r4ss::SS_output(paths[i], forecast = TRUE, verbose = FALSE, printstats = FALSE)
    pl <- as.character(peels[i])
    outRes[[i]] <- peelOne(
      repPeel = rp,
      repBase = repBase,
      dat = dat,
      peelLabel = pl,
      pathPeel = paths[i]
    )
    outRatio[[i]] <- peelRatios(rp, repBase, pl, fh)
    outTraj[[i]] <- peelTrajLong(rp, pl, scen)
  }
  list(
    res = dplyr::mutate(dplyr::bind_rows(outRes), scenario = scen, .before = 1),
    ratioHor = dplyr::mutate(dplyr::bind_rows(outRatio), scenario = scen, .before = 1),
    traj = dplyr::bind_rows(outTraj)
  )
}

#' Assemble retrospective back-test tables (R Markdown / case studies)
#'
#' Optionally runs \code{\link{runRetros}}, then \code{\link{collectRetro}} per scenario
#' and returns the same structure as the **PE-backtest** example: wide and long
#' trajectories, MSY-ratio long table, reference management table from the first
#' scenario’s \code{retro0}, one-step errors, and multi-horizon ratios.
#'
#' @param params Named list: \code{ssBase}, \code{scenarioDirs}, \code{retroSubdir},
#'   \code{retroYears}, \code{forecastHorizons}, \code{ssVersion}, \code{runRetro},
#'   \code{ssExe}, \code{retroVerbose}, \code{retroWorkers}. Optional
#'   \code{parallelCollect} (default \code{TRUE}): when \code{TRUE} and there are
#'   multiple scenario directories, \code{collectRetro} runs in parallel using the same
#'   worker count as \code{retroWorkers} (default: one fewer than detected cores).
#' @return A list with \code{trajWide}, \code{trajLong}, \code{trajMsyLong},
#'   \code{referenceMgmt}, \code{oneStep}, \code{ratioHorizon}.
#' @export
retroBacktestData <- function(params) {
  ssScenarioDirs <- file.path(params$ssBase, params$scenarioDirs)
  retroPaths <- file.path(ssScenarioDirs, params$retroSubdir)
  missingRetro <- !dir.exists(retroPaths)

  if (isTRUE(params$runRetro)) {
    runRetros(ssScenarioDirs, params)
  } else if (any(missingRetro)) {
    stop(
      "Retrospectives folder not found (params$runRetro is FALSE):\n",
      paste0("  ", retroPaths[missingRetro], collapse = "\n"),
      "\n\nSet params$runRetro=TRUE, or run retro() / your case-study retro driver, ",
      "then knit with runRetro=FALSE.",
      call. = FALSE
    )
  }

  parallelCollect <- params$parallelCollect
  if (is.null(parallelCollect)) {
    parallelCollect <- TRUE
  }
  nColl <- params$retroWorkers
  if (is.null(nColl)) {
    nColl <- max(1L, parallelly::availableCores(omit = 1L))
  } else {
    nColl <- as.integer(nColl)
  }
  useParallel <- isTRUE(parallelCollect) &&
    length(ssScenarioDirs) > 1L &&
    nColl > 1L

  if (useParallel) {
    nw <- min(nColl, length(ssScenarioDirs))
    oldPlan <- future::plan(future::multisession, workers = nw)
    tryCatch(
      {
        collected <- future.apply::future_lapply(
          ssScenarioDirs,
          collectRetro,
          params = params
        )
      },
      finally = {
        future::plan(oldPlan)
      }
    )
  } else {
    collected <- lapply(ssScenarioDirs, collectRetro, params = params)
  }
  res <- dplyr::bind_rows(lapply(collected, `[[`, "res"))
  ratioHor <- dplyr::bind_rows(lapply(collected, `[[`, "ratioHor"))
  traj <- dplyr::bind_rows(lapply(collected, `[[`, "traj"))
  stopifnot(nrow(res) > 0, nrow(ratioHor) > 0, nrow(traj) > 0)

  trajLong <- dplyr::bind_rows(
    dplyr::transmute(
      traj,
      scenario,
      peel,
      year,
      phase,
      terminalYr,
      metric = "spawnBio",
      value = spawnBio
    ),
    dplyr::transmute(
      traj,
      scenario,
      peel,
      year,
      phase,
      terminalYr,
      metric = "catch",
      value = catch
    ),
    dplyr::transmute(
      traj,
      scenario,
      peel,
      year,
      phase,
      terminalYr,
      metric = "fTotal",
      value = fTotal
    )
  )

  trajMsyLong <- dplyr::bind_rows(
    dplyr::transmute(
      traj,
      scenario,
      peel,
      year,
      phase,
      terminalYr,
      metric = "bratio",
      value = bratio,
      ciLo = bratioLo,
      ciHi = bratioHi
    ),
    dplyr::transmute(
      traj,
      scenario,
      peel,
      year,
      phase,
      terminalYr,
      metric = "ffmsy",
      value = ffmsy,
      ciLo = ffmsyLo,
      ciHi = ffmsyHi
    ),
    dplyr::transmute(
      traj,
      scenario,
      peel,
      year,
      phase,
      terminalYr,
      metric = "catchMsyRatio",
      value = catchMsyRatio,
      ciLo = catchMsyRatioLo,
      ciHi = catchMsyRatioHi
    )
  )

  sc0 <- ssScenarioDirs[[1]]
  retroRoot0 <- file.path(sc0, params$retroSubdir)
  baseRetro0 <- file.path(retroRoot0, "retro0")
  starter0 <- r4ss::SS_readstarter(file.path(sc0, "starter.ss"), verbose = FALSE)
  datFile <- starter0$datfile
  if (is.null(datFile) || !nzchar(datFile)) {
    datFile <- "data.ss"
  }
  dat0 <- r4ss::SS_readdat(
    file.path(sc0, datFile),
    version = params$ssVersion,
    verbose = FALSE
  )
  repFull <- r4ss::SS_output(baseRetro0, forecast = TRUE, verbose = FALSE, printstats = FALSE)
  refYears <- sort(unique(traj$year))
  referenceMgmt <- dplyr::mutate(
    referenceManagementTable(repFull, dat0, refYears),
    scenario = basename(sc0),
    .before = 1
  )

  list(
    trajWide = traj,
    trajLong = trajLong,
    trajMsyLong = trajMsyLong,
    referenceMgmt = referenceMgmt,
    oneStep = res,
    ratioHorizon = ratioHor
  )
}
