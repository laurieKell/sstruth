.ssReadOpts <- function(refresh, covar, forecast, writeCache, cache = TRUE) {
  list(
    refresh = refresh,
    covar = covar,
    forecast = forecast,
    writeCache = writeCache,
    cache = cache
  )
}

.ssLazyRep <- function(path, opts) {
  structure(
    list(path = path, opts = opts, loaded = FALSE, rep = NULL),
    class = "ssLazyRep"
  )
}

.ssLazyRepLoad <- function(x) {
  if (isTRUE(x$loaded) && !is.null(x$rep)) {
    return(x$rep)
  }
  opts <- x$opts
  rep <- if (isTRUE(opts$cache) && !isTRUE(opts$refresh)) {
    ssRead(
      x$path,
      cacheOnly = TRUE,
      refresh = FALSE,
      covar = opts$covar,
      forecast = opts$forecast,
      writeCache = opts$writeCache
    )
  } else {
    ssRead(
      x$path,
      refresh = opts$refresh,
      covar = opts$covar,
      forecast = opts$forecast,
      writeCache = opts$writeCache
    )
  }
  x$loaded <- TRUE
  x$rep <- rep
  rep
}

#' @export
`[[.ssLazyRep` <- function(x, i, exact = TRUE) {
  if (!identical(i, 1L)) {
    stop("ssLazyRep holds one SS_output; use [[1]].", call. = FALSE)
  }
  .ssLazyRepLoad(x)
}

#' @export
print.ssLazyRep <- function(x, ...) {
  cache <- ssCache(x$path)
  cat(
    "ssLazyRep\n  path: ", x$path,
    "\n  cache: ", cache,
    if (file.exists(cache)) " (on disk)" else " (missing)",
    if (isTRUE(x$loaded)) " [loaded]" else " [not loaded]",
    "\n",
    sep = ""
  )
  invisible(x)
}

#' Lazy \code{SS_output} loader backed by disk cache
#'
#' Returns a list-like object that reads \code{ss_output.rds} from disk only
#' when a run is accessed. Use after \code{SS_outputs()} to avoid holding all
#' runs in memory at once.
#'
#' @param runs \code{ssRuns()} table with columns \code{id} and \code{path}.
#' @inheritParams ssLoad
#' @return Object of class \code{ssLazyLoad} indexed by run id.
#' @export
ssLazyLoad <- function(
  runs,
  cache = TRUE,
  covar = FALSE,
  forecast = FALSE,
  refresh = FALSE,
  writeCache = TRUE
) {
  .checkRuns(runs)
  opts <- .ssReadOpts(refresh, covar, forecast, writeCache, cache = cache)
  reps <- lapply(runs$path, function(path) {
    .ssLazyRep(path = path, opts = opts)
  })
  stats::setNames(reps, runs$id)
  structure(reps, class = "ssLazyLoad")
}

#' @export
`[[.ssLazyLoad` <- function(x, i, exact = TRUE) {
  el <- unclass(x)[[i, exact = exact]]
  if (inherits(el, "ssLazyRep")) {
    return(.ssLazyRepLoad(el))
  }
  el
}

#' @export
length.ssLazyLoad <- function(x) length(unclass(x))

#' @export
names.ssLazyLoad <- function(x) names(unclass(x))

#' @export
print.ssLazyLoad <- function(x, ...) {
  ids <- names(x)
  n_cached <- sum(vapply(
    unclass(x),
    function(el) file.exists(ssCache(el$path)),
    logical(1)
  ))
  n_loaded <- sum(vapply(
    unclass(x),
    function(el) isTRUE(el$loaded),
    logical(1)
  ))
  cat(
    "ssLazyLoad [", length(x), " runs, ",
    n_cached, " cached, ", n_loaded, " loaded in memory]\n",
    sep = ""
  )
  invisible(x)
}

#' Cache status for \code{SS_output} runs
#'
#' @param runs \code{ssRuns()} table or assessment directory to scan.
#' @return Data frame with \code{id}, \code{path}, \code{cache}, \code{exists},
#'   \code{bytes}, and \code{mtime}.
#' @export
ssCacheStatus <- function(runs) {
  if (is.character(runs) && length(runs) == 1L && nzchar(runs)) {
    runs <- ssRuns(runs)
  }
  .checkRuns(runs)
  cache_paths <- vapply(runs$path, ssCache, character(1))
  out <- data.frame(
    id = runs$id,
    path = runs$path,
    cache = cache_paths,
    exists = file.exists(cache_paths),
    bytes = NA_real_,
    mtime = as.POSIXct(NA),
    stringsAsFactors = FALSE
  )
  hit <- which(out$exists)
  if (length(hit)) {
    fi <- file.info(out$cache[hit], extra_cols = FALSE)
    out$bytes[hit] <- fi$size
    out$mtime[hit] <- fi$mtime
  }
  out
}

.ssBindRunsStream <- function(
  runs,
  slot,
  col,
  cache,
  covar,
  forecast,
  refresh,
  parallel,
  workers
) {
  pieces <- .ssParallel(
    seq_len(nrow(runs)),
    function(i) {
      id <- runs$id[[i]]
      path <- runs$path[[i]]
      if (isTRUE(cache) && !isTRUE(refresh)) {
        cache_path <- ssCache(path)
        if (!file.exists(cache_path)) {
          stop("No cache in ", path, "; run SS_outputs() first.", call. = FALSE)
        }
        rep <- readRDS(cache_path)
      } else {
        rep <- ssRead(
          path,
          refresh = refresh,
          covar = covar,
          forecast = forecast
        )
      }
      chunk <- .asTable(ssSlot(rep, slot), id, slot)
      rm(rep)
      out <- cbind(
        stats::setNames(data.frame(id, stringsAsFactors = FALSE), col),
        chunk,
        stringsAsFactors = FALSE
      )
      rownames(out) <- NULL
      out
    },
    parallel = parallel,
    workers = workers
  )
  out <- do.call(rbind, pieces)
  rownames(out) <- NULL
  out
}
