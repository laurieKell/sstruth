.flstockName <- function() "flstock.rds"

.flstockCache <- function(runDir) {
  file.path(ssRunDir(runDir), .flstockName())
}

.readFLSss3One <- function(runDir, writeCache = TRUE, ...) {
  if (!requireNamespace("ss3om", quietly = TRUE)) {
    stop("Package 'ss3om' is required.", call. = FALSE)
  }
  runDir <- ssRunDir(runDir)
  if (!file.exists(file.path(runDir, "Report.sso"))) {
    return(NULL)
  }
  fls <- ss3om::readFLSss3(runDir, ...)
  if (isTRUE(writeCache) && !is.null(fls)) {
    saveRDS(fls, .flstockCache(runDir))
  }
  fls
}

.flstockStatusRow <- function(id, path, hadCache, fls) {
  data.frame(
    id = id,
    path = path,
    cache = .flstockCache(path),
    had_cache = hadCache,
    ok = !is.null(fls),
    stringsAsFactors = FALSE
  )
}

#' Read \code{FLStock} objects from SS3 run folder(s)
#'
#' Like \code{ss3om::readFLSss3()}, but when \code{x} is an assessment parent
#' directory scans all nested \code{Report.sso} runs (via \code{ssRuns()}) and
#' writes \code{flstock.rds} into each run folder.
#'
#' @param x SS3 run directory, assessment base to scan, or \code{ssRuns()} table.
#' @param writeCache Save \code{flstock.rds} in each run folder.
#' @param returnObjects If \code{FALSE}, return a per-run status data frame
#'   instead of \code{FLStock} object(s).
#' @param parallel,workers Parallel reads when multiple runs.
#' @param ... Passed to \code{ss3om::readFLSss3()}.
#' @return For one run with \code{returnObjects = TRUE}, an \code{FLStock}.
#'   For many runs with \code{returnObjects = TRUE}, a named list of
#'   \code{FLStock} objects (names = run ids). With \code{returnObjects = FALSE},
#'   a status data frame (\code{id}, \code{path}, \code{cache}, \code{ok}, ...).
#' @export
readFLSss3 <- function(
  x,
  writeCache = TRUE,
  returnObjects = TRUE,
  parallel = TRUE,
  workers = NULL,
  ...
) {
  if (is.data.frame(x)) {
    runs <- x
  } else if (is.character(x) && length(x) == 1L && nzchar(x)) {
    path <- normalizePath(x, winslash = "/", mustWork = FALSE)
    if (file.exists(file.path(ssRunDir(path), "Report.sso"))) {
      had <- file.exists(.flstockCache(path))
      fls <- .readFLSss3One(path, writeCache = writeCache, ...)
      if (!isTRUE(returnObjects)) {
        return(.flstockStatusRow(basename(path), path, had, fls))
      }
      return(fls)
    }
    runs <- ssRuns(path)
  } else {
    stop("Provide a run directory, assessment base, or ssRuns() table.", call. = FALSE)
  }

  .checkRuns(runs)
  if (nrow(runs) == 1L) {
    path <- runs$path[[1L]]
    had <- file.exists(.flstockCache(path))
    fls <- .readFLSss3One(path, writeCache = writeCache, ...)
    if (!isTRUE(returnObjects)) {
      return(.flstockStatusRow(runs$id[[1L]], path, had, fls))
    }
    return(fls)
  }

  if (isTRUE(parallel) && nrow(runs) > 1L) {
    nw <- workers %||% max(1L, parallel::detectCores(logical = TRUE) - 2L)
    message("[readFLSss3] workers: ", min(as.integer(nw), nrow(runs)))
  }

  pieces <- .ssParallel(
    seq_len(nrow(runs)),
    function(i) {
      id <- runs$id[[i]]
      path <- runs$path[[i]]
      had <- file.exists(.flstockCache(path))
      message("[readFLSss3] ", id)
      fls <- tryCatch(
        .readFLSss3One(path, writeCache = writeCache, ...),
        error = function(e) {
          message("[readFLSss3] ", id, ": ", conditionMessage(e))
          NULL
        }
      )
      if (isTRUE(returnObjects)) {
        list(id = id, fls = fls)
      } else {
        list(status = .flstockStatusRow(id, path, had, fls))
      }
    },
    parallel = parallel,
    workers = workers
  )

  if (!isTRUE(returnObjects)) {
    out <- do.call(rbind, lapply(pieces, `[[`, "status"))
    rownames(out) <- NULL
    return(out)
  }

  fls <- lapply(pieces, `[[`, "fls")
  names(fls) <- vapply(pieces, `[[`, character(1L), "id")
  fls[!vapply(fls, is.null, logical(1L))]
}
