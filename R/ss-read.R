.ssCacheName <- function() "ss_output.rds"

#' Resolve SS3 scenario folder to run directory
#'
#' Handles nested layouts such as \code{Sc1_Base/Sc1_Base/Report.sso}.
#'
#' @param path Scenario path under the assessment base.
#' @export
ssRunDir <- function(path) {
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(path)) {
    return(path)
  }
  if (file.exists(file.path(path, "Report.sso"))) {
    return(path)
  }
  inner <- file.path(path, basename(path))
  if (dir.exists(inner) && file.exists(file.path(inner, "Report.sso"))) {
    return(normalizePath(inner, winslash = "/", mustWork = TRUE))
  }
  path
}

.relativeToBase <- function(path, base) {
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  base <- normalizePath(base, winslash = "/", mustWork = TRUE)
  base <- sub("/$", "", base)
  if (!startsWith(path, base)) {
    return(path)
  }
  sub(paste0("^", gsub("([\\W])", "\\\\\\1", base), "/?"), "", path)
}

#' SS3 run directories with \code{Report.sso}
#'
#' With \code{ids = NULL}, recursively scans \code{base}. With \code{ids}, resolves
#' scenario folders under \code{base}.
#'
#' @param base Assessment parent directory.
#' @param ids Optional scenario ids relative to \code{base}.
#' @return Data frame \code{id}, \code{path}.
#' @export
ssRuns <- function(base, ids = NULL) {
  if (is.null(ids)) {
    if (!dir.exists(base)) {
      stop("Directory not found: ", base, call. = FALSE)
    }
    base <- normalizePath(base, winslash = "/", mustWork = TRUE)
    hits <- list.files(
      base,
      pattern = "^Report\\.sso$",
      recursive = TRUE,
      full.names = TRUE,
      include.dirs = FALSE,
      no.. = TRUE
    )
    if (!length(hits)) {
      return(data.frame(id = character(0), path = character(0), stringsAsFactors = FALSE))
    }
    dirs <- sort(unique(normalizePath(dirname(hits), winslash = "/", mustWork = FALSE)))
    return(data.frame(
      id = vapply(dirs, .relativeToBase, character(1), base = base),
      path = dirs,
      stringsAsFactors = FALSE
    ))
  }
  paths <- ssPaths(base, ids)
  data.frame(id = names(paths), path = unname(paths), stringsAsFactors = FALSE)
}

#' Named absolute run paths
#'
#' @param base Assessment parent directory.
#' @param ids Scenario ids relative to \code{base}.
#' @param runs Optional \code{ssRuns()} table.
#' @export
ssPaths <- function(base, ids, runs = NULL) {
  if (!is.null(runs) && is.data.frame(runs) && all(c("id", "path") %in% names(runs))) {
    return(stats::setNames(as.character(runs$path), as.character(runs$id)))
  }
  raw <- file.path(base, ids)
  stats::setNames(
    vapply(raw, ssRunDir, character(1), USE.NAMES = FALSE),
    ids
  )
}

#' Cached \code{SS_output} file path
#' @param runDir SS3 run directory.
#' @export
ssCache <- function(runDir) {
  file.path(runDir, .ssCacheName())
}

#' Read \code{SS_output} for one run
#'
#' Uses \code{ss_output.rds} in each run folder, then \code{ss.RData}, then
#' \code{Report.sso}. Fresh reads are written to \code{ss_output.rds} when
#' \code{writeCache = TRUE}. Run \code{SS_outputs()} once to populate caches,
#' then use \code{ssLazyLoad()} or \code{getSS(..., cache = TRUE)} without
#' re-parsing \code{Report.sso}.
#'
#' @param runDir SS3 run directory.
#' @param refresh Ignore cache and re-read \code{Report.sso}.
#' @param cacheOnly If \code{TRUE}, read only from \code{ss_output.rds} (no fallback).
#' @param covar,forecast Passed to \code{r4ss::SS_output()}.
#' @param writeCache Write \code{ss_output.rds} after a fresh read.
#' @export
ssRead <- function(
  runDir,
  refresh = FALSE,
  cacheOnly = FALSE,
  covar = FALSE,
  forecast = FALSE,
  writeCache = TRUE
) {
  runDir <- ssRunDir(runDir)
  cache <- ssCache(runDir)
  if (!isTRUE(refresh)) {
    if (file.exists(cache)) {
      return(readRDS(cache))
    }
    if (isTRUE(cacheOnly)) {
      stop("No cache at ", cache, "; run SS_outputs() first.", call. = FALSE)
    }
    rdata <- file.path(runDir, "ss.RData")
    if (file.exists(rdata)) {
      env <- new.env(parent = emptyenv())
      load(rdata, envir = env)
      if (exists("ss", envir = env, inherits = FALSE)) {
        rep <- get("ss", envir = env, inherits = FALSE)
        if (isTRUE(writeCache) && !is.null(rep)) {
          saveRDS(rep, cache)
        }
        return(rep)
      }
    }
  }
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Package 'r4ss' is required.", call. = FALSE)
  }
  if (!file.exists(file.path(runDir, "Report.sso"))) {
    return(NULL)
  }
  rep <- r4ss::SS_output(
    dir = runDir,
    verbose = FALSE,
    printstats = FALSE,
    forecast = isTRUE(forecast),
    covar = isTRUE(covar),
    hidewarn = TRUE,
    NoCompOK = TRUE
  )
  if (isTRUE(writeCache) && !is.null(rep)) {
    saveRDS(rep, ssCache(runDir))
  }
  rep
}

.ssParallel <- function(x, fun, parallel = TRUE, workers = NULL) {
  if (requireNamespace("diags", quietly = TRUE)) {
    return(diags::parallelLapply(x, fun, parallel = parallel, workers = workers))
  }
  if (isTRUE(parallel) && length(x) > 1L &&
      requireNamespace("future.apply", quietly = TRUE) &&
      requireNamespace("future", quietly = TRUE)) {
    nw <- workers
    if (is.null(nw)) {
      nw <- max(1L, parallel::detectCores(logical = TRUE) - 2L)
    }
    nw <- min(as.integer(nw), length(x))
    old <- future::plan(future::multisession, workers = nw)
    on.exit(future::plan(old), add = TRUE)
    return(future.apply::future_lapply(x, fun, future.seed = TRUE))
  }
  lapply(x, fun)
}

.checkRuns <- function(runs) {
  if (!is.data.frame(runs) || !all(c("id", "path") %in% names(runs))) {
    stop("runs must be a data frame with columns id and path.", call. = FALSE)
  }
  invisible(runs)
}

#' Read and cache \code{SS_output} for all runs under a directory
#'
#' Like \code{r4ss::SS_output()}, but discovers every nested \code{Report.sso}
#' (via \code{ssRuns()}) and writes \code{ss_output.rds} into each run folder.
#'
#' @param x Assessment parent directory to scan, or a \code{ssRuns()} table with
#'   columns \code{id} and \code{path}.
#' @param refresh Re-read \code{Report.sso} even when cached.
#' @param covar,forecast Passed to \code{r4ss::SS_output()}.
#' @param parallel,workers Parallel collection.
#' @return Status data frame per run (\code{id}, \code{path}, \code{cache}, \code{ok}, ...).
#' @export
SS_outputs <- function(
  x,
  covar = FALSE,
  forecast = FALSE,
  refresh = FALSE,
  parallel = TRUE,
  workers = NULL
) {
  runs <- if (is.data.frame(x)) {
    x
  } else if (is.character(x) && length(x) == 1L && nzchar(x)) {
    ssRuns(x)
  } else {
    stop("Provide an assessment directory or ssRuns() table.", call. = FALSE)
  }
  .checkRuns(runs)
  if (isTRUE(parallel) && nrow(runs) > 1L) {
    nw <- workers %||% max(1L, parallel::detectCores(logical = TRUE) - 2L)
    message("[SS_outputs] workers: ", min(as.integer(nw), nrow(runs)))
  }
  status <- .ssParallel(
    seq_len(nrow(runs)),
    function(i) {
      id <- runs$id[[i]]
      path <- runs$path[[i]]
      had <- file.exists(ssCache(path))
      message("[SS_outputs] ", id, if (had && !refresh) " (cached)" else "")
      if (had && !refresh) {
        ok <- isTRUE(file.info(ssCache(path))$size > 0)
      } else {
        rep <- ssRead(path, refresh = refresh, covar = covar, forecast = forecast)
        ok <- !is.null(rep)
        rm(rep)
      }
      data.frame(
        id = id,
        path = path,
        cache = ssCache(path),
        had_cache = had,
        refreshed = refresh || !had,
        ok = ok,
        stringsAsFactors = FALSE
      )
    },
    parallel = parallel,
    workers = workers
  )
  out <- do.call(rbind, status)
  rownames(out) <- NULL
  out
}

#' Load \code{SS_output} objects for many runs
#'
#' With \code{lazy = TRUE}, returns \code{\link{ssLazyLoad}} so each run is read
#' from \code{ss_output.rds} only when accessed. With \code{lazy = FALSE}, loads
#' all runs into a named list (can use substantial memory).
#'
#' @param runs \code{ssRuns()} table.
#' @param lazy Return a lazy loader instead of loading all runs into memory.
#' @param cache If \code{TRUE}, require cached output (use after \code{SS_outputs()}).
#' @export
ssLoad <- function(
  runs,
  lazy = FALSE,
  cache = FALSE,
  covar = FALSE,
  forecast = FALSE,
  refresh = FALSE,
  parallel = TRUE,
  workers = NULL,
  writeCache = TRUE
) {
  .checkRuns(runs)
  if (isTRUE(lazy)) {
    return(ssLazyLoad(
      runs,
      cache = cache,
      covar = covar,
      forecast = forecast,
      refresh = refresh,
      writeCache = writeCache
    ))
  }
  reps <- .ssParallel(
    seq_len(nrow(runs)),
    function(i) {
      path <- runs$path[[i]]
      id <- runs$id[[i]]
      if (isTRUE(cache) && !refresh) {
        if (!file.exists(ssCache(path))) {
          stop("No cache in ", path, "; run SS_outputs() first.", call. = FALSE)
        }
        message("[ssLoad] ", id)
        return(readRDS(ssCache(path)))
      }
      message("[ssLoad] ", id)
      ssRead(path, refresh = refresh, covar = covar, forecast = forecast)
    },
    parallel = parallel,
    workers = workers
  )
  stats::setNames(reps, runs$id)
}

#' Extract one slot from an \code{SS_output} object
#'
#' @param rep \code{SS_output} list.
#' @param slot Slot name (case-insensitive), e.g. \code{"Kobe"}.
#' @export
ssSlot <- function(rep, slot) {
  if (is.null(slot) || !nzchar(slot)) {
    stop("Provide slot (e.g. Kobe, timeseries).", call. = FALSE)
  }
  parts <- strsplit(slot, ".", fixed = TRUE)[[1]]
  obj <- rep
  for (p in parts) {
    nms <- names(obj)
    if (is.null(nms)) {
      stop("Cannot descend into '", p, "'.", call. = FALSE)
    }
    hit <- nms[tolower(nms) == tolower(p)]
    if (!length(hit)) {
      stop("Slot '", p, "' not found.", call. = FALSE)
    }
    obj <- obj[[hit[[1]]]]
  }
  obj
}

.asTable <- function(x, id, slot) {
  if (is.data.frame(x)) {
    return(x)
  }
  if (is.matrix(x)) {
    return(as.data.frame(x, stringsAsFactors = FALSE))
  }
  stop("Slot '", slot, "' for '", id, "' is not a table.", call. = FALSE)
}

#' Bind one slot across \code{SS_output} objects
#'
#' @param reps Named list from \code{ssLoad()}.
#' @param slot Slot name, e.g. \code{"Kobe"}.
#' @param col Scenario id column name.
#' @export
ssBind <- function(reps, slot, col = "scenario") {
  if (is.null(names(reps)) || !length(names(reps))) {
    names(reps) <- seq_along(reps)
  }
  pieces <- lapply(names(reps), function(id) {
    chunk <- .asTable(ssSlot(reps[[id]], slot), id, slot)
    out <- cbind(
      stats::setNames(data.frame(id, stringsAsFactors = FALSE), col),
      chunk,
      stringsAsFactors = FALSE
    )
    rownames(out) <- NULL
    out
  })
  out <- do.call(rbind, pieces)
  rownames(out) <- NULL
  out
}

#' List bindable slots in \code{SS_output}
#' @param rep \code{SS_output} list.
#' @export
ssSlots <- function(rep) {
  nms <- names(rep)
  data.frame(
    slot = nms,
    type = vapply(rep, function(x) {
      if (is.data.frame(x)) "data.frame"
      else if (is.matrix(x)) "matrix"
      else if (is.list(x)) "list"
      else class(x)[1]
    }, character(1)),
    nrow = vapply(rep, function(x) {
      if (is.data.frame(x) || is.matrix(x)) NROW(x) else NA_integer_
    }, integer(1)),
    ncol = vapply(rep, function(x) {
      if (is.data.frame(x) || is.matrix(x)) NCOL(x) else NA_integer_
    }, integer(1)),
    stringsAsFactors = FALSE
  )
}

#' Load runs and bind one slot
#'
#' When \code{lazy = TRUE} (default if \code{cache = TRUE}), reads one cached run
#' at a time and discards it after extracting \code{slot}, avoiding a large in-memory
#' list of full \code{SS_output} objects.
#'
#' @inheritParams ssBind
#' @inheritParams ssLoad
#' @param lazy Stream runs one at a time when binding (default \code{NULL} = \code{cache}).
#' @export
ssBindRuns <- function(
  runs,
  slot,
  col = "scenario",
  cache = TRUE,
  lazy = NULL,
  covar = FALSE,
  forecast = FALSE,
  refresh = FALSE,
  parallel = TRUE,
  workers = NULL
) {
  if (is.null(lazy)) {
    lazy <- isTRUE(cache) && !isTRUE(refresh)
  }
  if (isTRUE(lazy)) {
    return(.ssBindRunsStream(
      runs,
      slot = slot,
      col = col,
      cache = cache,
      covar = covar,
      forecast = forecast,
      refresh = refresh,
      parallel = parallel,
      workers = workers
    ))
  }
  reps <- ssLoad(
    runs,
    lazy = FALSE,
    cache = cache,
    covar = covar,
    forecast = forecast,
    refresh = refresh,
    parallel = parallel,
    workers = workers
  )
  ssBind(reps, slot, col = col)
}

#' Read cached \code{SS_output} and bind one slot as a data frame
#'
#' Loads \code{ss_output.rds} from run folder(s) (run \code{SS_outputs()} first),
#' extracts \code{slot} via \code{ssSlot()}, and row-binds into one data frame with
#' a scenario column.
#'
#' @param x Assessment parent directory, single run directory, \code{ssRuns()} table,
#'   or named list of \code{SS_output} objects.
#' @param slot Slot name (case-insensitive), e.g. \code{"kobe"}, \code{"timeseries"}.
#' @param col Scenario id column name.
#' @inheritParams ssBindRuns
#' @export
getSS <- function(
  x,
  slot,
  col = "scenario",
  cache = TRUE,
  covar = FALSE,
  forecast = FALSE,
  refresh = FALSE,
  parallel = TRUE,
  workers = NULL
) {
  if (missing(slot) || is.null(slot) || !nzchar(slot)) {
    stop("Provide slot (e.g. kobe, timeseries).", call. = FALSE)
  }
  if (is.list(x) && !is.data.frame(x)) {
    return(ssBind(x, slot, col = col))
  }
  runs <- if (is.data.frame(x)) {
    x
  } else if (is.character(x) && length(x) == 1L && nzchar(x)) {
    path <- normalizePath(x, winslash = "/", mustWork = FALSE)
    if (file.exists(file.path(ssRunDir(path), "Report.sso"))) {
      data.frame(id = basename(path), path = path, stringsAsFactors = FALSE)
    } else {
      ssRuns(path)
    }
  } else {
    stop(
      "Provide an assessment directory, run directory, ssRuns() table, or SS_output list.",
      call. = FALSE
    )
  }
  ssBindRuns(
    runs,
    slot = slot,
    col = col,
    cache = cache,
    covar = covar,
    forecast = forecast,
    refresh = refresh,
    parallel = parallel,
    workers = workers
  )
}

#' Kobe trajectories across SS3 runs
#'
#' Row-binds the \code{Kobe} slot from cached \code{SS_output} in each run folder.
#' Renames \code{Yr}, \code{B.Bmsy}, and \code{F.Fmsy} to \code{year}, \code{stock},
#' and \code{harvest}. Run \code{SS_outputs()} first.
#'
#' @param x Assessment base directory, \code{ssRuns()} table, or named list of
#'   \code{SS_output} objects.
#' @param col Run id column name (default \code{"run"}).
#' @inheritParams ssBindRuns
#' @export
ssKobe <- function(
  x,
  col = "run",
  cache = TRUE,
  covar = FALSE,
  forecast = FALSE,
  refresh = FALSE,
  parallel = TRUE,
  workers = NULL
) {
  out <- getSS(
    x,
    slot = "Kobe",
    col = col,
    cache = cache,
    covar = covar,
    forecast = forecast,
    refresh = refresh,
    parallel = parallel,
    workers = workers
  )
  ren <- c(Yr = "year", "B.Bmsy" = "stock", "F.Fmsy" = "harvest")
  hit <- intersect(names(ren), names(out))
  if (length(hit)) {
    names(out)[match(hit, names(out))] <- unname(ren[hit])
  }
  out
}

#' Extract and bind one slot under an assessment base
#'
#' @param base Assessment parent directory.
#' @param ids Scenario ids relative to \code{base}.
#' @param slot Slot name.
#' @param runs Optional \code{ssRuns()} table.
#' @inheritParams ssBindRuns
#' @export
ssExtract <- function(
  base,
  ids,
  slot,
  col = "scenario",
  runs = NULL,
  cache = FALSE,
  covar = FALSE,
  forecast = FALSE,
  refresh = FALSE,
  parallel = TRUE,
  workers = NULL
) {
  paths <- ssPaths(base, ids, runs = runs)
  missing <- names(paths)[!dir.exists(paths)]
  if (length(missing)) {
    stop("Runs not found: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  if (is.null(runs) || !NROW(runs)) {
    runs <- data.frame(id = names(paths), path = unname(paths), stringsAsFactors = FALSE)
  }
  ssBindRuns(
    runs,
    slot,
    col = col,
    cache = cache,
    covar = covar,
    forecast = forecast,
    refresh = refresh,
    parallel = parallel,
    workers = workers
  )
}
