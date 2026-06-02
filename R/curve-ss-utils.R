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
  has_sp <- any(c("sp", "sp_ssb", "sprod", "P_ssb", "pf") %in% names(ts))
  !has_pe2 || !has_sp
}

#' Resolve production column name in curveSS tseries
#' @param ts \code{tseries} data frame.
#' @param type \code{"ssb"} for spawning-biomass surplus production (default),
#'   \code{"ss3"} for \code{r4ss::SSplotYield()} total-biomass surplus production.
#' @export
curveSsProductionCol <- function(ts, type = c("ssb", "ss3")) {
  type <- match.arg(type)
  cols <- if (type == "ss3") {
    c("sprod", "P_obs", "sp_ss3")
  } else {
    c("sp_ssb", "sp", "P_ssb", "pf")
  }
  for (col in cols) {
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
  if (is.null(ts) || !NROW(ts)) {
    return(NULL)
  }
  id_col <- resolveCol(ts, c("run", "id", "scenario"))
  if (is.na(id_col) || !"year" %in% names(ts)) {
    return(NULL)
  }
  do.call(rbind, lapply(split(ts, ts[[id_col]], drop = TRUE), function(x) {
    x[which.max(x$year), , drop = FALSE]
  }))
}

.ssCurveRuns <- function(x) {
  if (is.data.frame(x)) {
    .checkRuns(x)
    return(x)
  }
  if (is.character(x) && length(x) >= 1L && all(nzchar(x))) {
    paths <- normalizePath(x, winslash = "/", mustWork = FALSE)
    is_rds <- vapply(paths, .isSsOutputFile, logical(1))
    is_run <- !is_rds & dir.exists(paths)
    if (length(paths) > 1L || any(is_rds)) {
      if (!all(is_rds | is_run)) {
        bad <- paths[!(is_rds | is_run)]
        stop(
          "Not an SS3 run directory or SS_output .rds: ",
          paste(bad, collapse = ", "),
          call. = FALSE
        )
      }
      ids <- if (!is.null(names(x)) && length(names(x)) == length(x)) {
        unname(names(x))
      } else {
        vapply(paths, .ssOutputId, character(1))
      }
      return(data.frame(id = ids, path = paths, stringsAsFactors = FALSE))
    }
    path <- paths
    if (file.exists(file.path(ssRunDir(path), "Report.sso")) ||
        file.exists(ssCache(path))) {
      return(data.frame(id = basename(path), path = path, stringsAsFactors = FALSE))
    }
    return(ssRuns(path))
  }
  stop(
    paste(
      "Provide an assessment directory, run directory, ssRuns() table,",
      "or character vector of run directories / ss_output.rds paths."
    ),
    call. = FALSE
  )
}

.curveSsTagRun <- function(out, run_id, col = "run") {
  lapply(out, function(df) {
    if (is.data.frame(df) && NROW(df)) {
      cbind(
        stats::setNames(data.frame(run_id, stringsAsFactors = FALSE), col),
        df,
        stringsAsFactors = FALSE
      )
    } else {
      df
    }
  })
}

.curveSsCombinePieces <- function(pieces) {
  pieces <- pieces[!vapply(pieces, is.null, logical(1))]
  if (!length(pieces)) {
    return(NULL)
  }
  parts <- unique(unlist(lapply(pieces, names), use.names = FALSE))
  combined <- lapply(parts, function(part) {
    rows <- lapply(pieces, function(x) x[[part]])
    rows <- rows[!vapply(rows, is.null, logical(1))]
    if (!length(rows)) {
      return(NULL)
    }
    df <- do.call(rbind, rows)
    rownames(df) <- NULL
    df
  })
  names(combined) <- parts
  combined
}

#' Process-error curves across SS3 runs
#'
#' Runs \code{curveSS()} on every nested scenario under an assessment base and
#' row-binds \code{tseries}, \code{curve}, and \code{refpts}. Uses cached
#' \code{ss_output.rds} when available (run \code{SS_outputs()} first).
#'
#' @param x Assessment parent directory, \code{ssRuns()} table, single run directory,
#'   or character vector of run directories / \code{ss_output.rds} paths (optional
#'   names used as scenario ids).
#' @param col Run id column name (default \code{"run"}).
#' @param for_plots Include columns needed for PE diagnostic figures; may call
#'   \code{FLRebuild::curveSS} when enrichment is needed.
#' @param cache Read cached \code{ss_output.rds} per run.
#' @param parallel,workers Parallel \code{curveSS} calls.
#' @param ... Passed to \code{curveSS()} / \code{ssRead()}.
#' @return Named list with combined \code{tseries}, \code{curve}, \code{refpts},
#'   and optional \code{triangle} data frames, or \code{NULL} if no runs succeed.
#' @export
ssCurve <- function(
  x,
  col = "run",
  for_plots = FALSE,
  cache = TRUE,
  parallel = TRUE,
  workers = NULL,
  ...
) {
  runs <- .ssCurveRuns(x)
  if (isTRUE(parallel) && nrow(runs) > 1L) {
    nw <- workers %||% max(1L, parallel::detectCores(logical = TRUE) - 2L)
    message("[ssCurve] workers: ", min(as.integer(nw), nrow(runs)))
  }

  load_one <- function(i) {
    id <- runs$id[[i]]
    path <- runs$path[[i]]
    message("[ssCurve] ", id)
    out <- tryCatch(
      curveSS(path, cache = cache, ...),
      error = function(e) {
        message("[ssCurve] ", id, ": ", conditionMessage(e))
        NULL
      }
    )
    if (is.null(out)) {
      return(NULL)
    }
    .curveSsTagRun(out, id, col = col)
  }

  pieces <- .ssParallel(
    seq_len(nrow(runs)),
    load_one,
    parallel = parallel,
    workers = workers
  )
  combined <- .curveSsCombinePieces(pieces)

  if (is.null(combined)) {
    return(NULL)
  }
  if (isTRUE(for_plots) && curveSsNeedsEnrichment(combined)) {
    if (!requireNamespace("FLRebuild", quietly = TRUE)) {
      return(combined)
    }
    load_fb <- function(i) {
      id <- runs$id[[i]]
      path <- runs$path[[i]]
      out <- tryCatch(
        if (.isSsOutputFile(path)) {
          curveSS(.readSsOutput(path, cache = FALSE))
        } else {
          FLRebuild::curveSS(path, ...)
        },
        error = function(e) {
          message("[ssCurve] FLRebuild ", id, ": ", conditionMessage(e))
          NULL
        }
      )
      if (is.null(out)) {
        return(NULL)
      }
      .curveSsTagRun(out, id, col = col)
    }
    pieces <- .ssParallel(
      seq_len(nrow(runs)),
      load_fb,
      parallel = parallel,
      workers = workers
    )
    combined <- .curveSsCombinePieces(pieces)
  }
  combined
}

#' Load and combine curveSS objects from multiple SS3 directories
#'
#' Uses \code{\link{curveSS}} from sstruth; optionally falls back to
#' \code{FLRebuild::curveSS} when \code{for_plots = TRUE} and enrichment is needed.
#'
#' @param paths Character vector of SS3 run directories or \code{ss_output.rds} paths.
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
  paths <- normalizePath(paths, winslash = "/", mustWork = FALSE)
  ok <- dir.exists(paths) | vapply(paths, .isSsOutputFile, logical(1))
  paths <- paths[ok]
  if (!length(paths)) {
    return(NULL)
  }
  ids <- if (!is.null(names(paths)) && length(names(paths)) == length(paths)) {
    unname(names(paths))
  } else {
    vapply(paths, .ssOutputId, character(1))
  }
  runs <- data.frame(
    id = ids,
    path = paths,
    stringsAsFactors = FALSE
  )
  out <- ssCurve(
    runs,
    col = "id",
    for_plots = for_plots,
    cache = TRUE,
    parallel = parallel,
    workers = workers
  )
  if (is.null(out)) {
    return(NULL)
  }
  if ("run" %in% names(out$tseries) && !"id" %in% names(out$tseries)) {
    for (nm in names(out)) {
      if (is.data.frame(out[[nm]]) && "run" %in% names(out[[nm]])) {
        names(out[[nm]])[names(out[[nm]]) == "run"] <- "id"
      }
    }
  }
  out
}
