#' Check whether a curveSS object needs FLRebuild enrichment for PE plots
#' @param pe List returned by \code{\link{curveSS}}.
#' @export
curveSsNeedsEnrichment <- function(pe) {
  ts <- pe$tseries
  if (is.null(ts) || !NROW(ts)) {
    return(TRUE)
  }
  has_pe2 <- "pe2" %in% names(ts) &&
    any(is.finite(ts$pe2) & abs(ts$pe2) > 1e-6, na.rm = TRUE)
  has_sp <- any(c("sp", "P_ssb", "pf") %in% names(ts))
  !has_pe2 || !has_sp
}

#' Resolve production column name in curveSS tseries
#' @param ts \code{tseries} data frame.
#' @export
curveSsProductionCol <- function(ts) {
  for (col in c("sp", "P_ssb", "pf")) {
    if (col %in% names(ts)) {
      return(col)
    }
  }
  NULL
}

#' Terminal (latest year) row per scenario id
#' @param ts \code{tseries} data frame with \code{id} and \code{year}.
#' @export
curveSsTerminalRows <- function(ts) {
  if (is.null(ts) || !NROW(ts) || !"id" %in% names(ts)) {
    return(NULL)
  }
  do.call(rbind, lapply(split(ts, ts$id, drop = TRUE), function(x) {
    x[which.max(x$year), , drop = FALSE]
  }))
}

#' Load and combine curveSS objects from multiple SS3 directories
#'
#' Uses \code{\link{curveSS}} from sstruth; optionally falls back to
#' \code{FLRebuild::curveSS} when \code{for_plots = TRUE} and enrichment is needed.
#'
#' @param paths Character vector of SS3 run directories.
#' @param for_plots Request PE columns needed for diagnostic figures.
#' @param parallel Run \code{curveSS} calls in parallel when length(paths) > 1.
#' @param workers Parallel worker count.
#' @export
curveSsLoadCombined <- function(
  paths,
  for_plots = FALSE,
  parallel = FALSE,
  workers = NULL
) {
  paths <- paths[dir.exists(paths)]
  if (!length(paths)) {
    return(NULL)
  }
  load_one <- function(p) {
    sid <- gsub("Scenario-", "Scenario ", basename(p))
    out <- curveSS(p)
    lapply(out, function(df) {
      if (is.data.frame(df)) {
        cbind(id = sid, df, stringsAsFactors = FALSE)
      } else {
        df
      }
    })
  }
  runs <- if (isTRUE(parallel) && length(paths) > 1L &&
      requireNamespace("future.apply", quietly = TRUE) &&
      requireNamespace("future", quietly = TRUE)) {
    nw <- workers
    if (is.null(nw)) {
      nw <- max(1L, parallel::detectCores(logical = TRUE) - 2L)
    }
    nw <- min(as.integer(nw), length(paths))
    old <- future::plan(future::multisession, workers = nw)
    on.exit(future::plan(old), add = TRUE)
    future.apply::future_lapply(paths, load_one)
  } else {
    lapply(paths, load_one)
  }
  runs <- runs[!vapply(runs, is.null, logical(1))]
  if (!length(runs)) {
    return(NULL)
  }
  pe <- {
    parts <- names(runs[[1]])
    combined <- lapply(parts, function(part) {
      do.call(rbind, lapply(runs, `[[`, part))
    })
    names(combined) <- parts
    combined
  }
  if (isTRUE(for_plots) && curveSsNeedsEnrichment(pe)) {
    if (!requireNamespace("FLRebuild", quietly = TRUE)) {
      return(pe)
    }
    if (requireNamespace("magrittr", quietly = TRUE)) {
      suppressPackageStartupMessages(library(magrittr, quietly = TRUE))
    }
    load_fb <- function(p) {
      sid <- gsub("Scenario-", "Scenario ", basename(p))
      out <- FLRebuild::curveSS(p)
      lapply(out, function(df) {
        if (is.data.frame(df)) {
          cbind(id = sid, df, stringsAsFactors = FALSE)
        } else {
          df
        }
      })
    }
    runs <- if (isTRUE(parallel) && length(paths) > 1L &&
        requireNamespace("future.apply", quietly = TRUE)) {
      nw <- workers
      if (is.null(nw)) {
        nw <- max(1L, parallel::detectCores(logical = TRUE) - 2L)
      }
      old <- future::plan(future::multisession, workers = min(nw, length(paths)))
      on.exit(future::plan(old), add = TRUE)
      future.apply::future_lapply(paths, load_fb)
    } else {
      lapply(paths, load_fb)
    }
    parts <- names(runs[[1]])
    combined <- lapply(parts, function(part) {
      do.call(rbind, lapply(runs, `[[`, part))
    })
    names(combined) <- parts
    return(combined)
  }
  pe
}
