##' Length-composition outputs from an SS3 model directory
##'
##' Extracts key length-composition components from \code{r4ss::SS_output()}.
##'
##' @param x Path to an SS3 run directory.
##' @param ... Additional arguments (currently unused).
##' @return A named list with elements \code{db}, \code{fit},
##' \code{controls}, and \code{summary}.
##' @export
setGeneric('ssLen',     function(x,...) methods::standardGeneric('ssLen'))

setMethod('ssLen', signature(x = 'character'), function(x, ...) {
  rep <- ssRead(x, writeCache = FALSE)
  if (is.null(rep)) {
    if (!requireNamespace("r4ss", quietly = TRUE)) {
      stop("Package 'r4ss' is required.", call. = FALSE)
    }
    rep <- r4ss::SS_output(
      x,
      forecast = FALSE,
      covar = FALSE,
      verbose = FALSE,
      printstats = FALSE,
      hidewarn = TRUE,
      NoCompOK = TRUE
    )
  }
  ssLenFromRep(rep)
})

setMethod('ssLen', signature(x = 'list'), function(x, ...) {
  ssLenFromRep(x)
})

.ssLenDb <- function(x, cache = TRUE, ...) {
  if (is.data.frame(x)) {
    return(x)
  }
  if (is.list(x)) {
    if (!is.null(x$db) && is.data.frame(x$db)) {
      return(x$db)
    }
    return(ssLenFromRep(x)$db)
  }
  if (is.character(x) && length(x) == 1L && nzchar(x)) {
    path <- normalizePath(x, winslash = "/", mustWork = FALSE)
    rep <- NULL
    if (isTRUE(cache) && file.exists(ssCache(path))) {
      rep <- readRDS(ssCache(path))
    }
    if (is.null(rep)) {
      rep <- ssRead(path, writeCache = isTRUE(cache), ...)
    }
    if (is.null(rep)) {
      stop("No SS_output for ", path, call. = FALSE)
    }
    return(ssLenFromRep(rep)$db)
  }
  stop(
    "Provide a run directory, SS_output list, lendbase data frame, or ssLen() result.",
    call. = FALSE
  )
}

.ssLenFleetLabels <- function(db) {
  nm_flt <- resolveCol(db, c("Fleet", "fleet", "FltSvy"))
  nm_name <- resolveCol(db, c("Fleet_Name", "FleetName", "name"))
  if (is.na(nm_flt) || is.na(nm_name)) {
    return(NULL)
  }
  flts <- sort(unique(as.integer(db[[nm_flt]])))
  labs <- vapply(flts, function(i) {
    as.character(db[[nm_name]][db[[nm_flt]] == i][1L])
  }, character(1L))
  stats::setNames(labs, flts)
}

.ssLenFlqFromDb <- function(db, fleetLabels = NULL) {
  if (is.null(db) || !is.data.frame(db) || !NROW(db)) {
    if (!requireNamespace("FLCore", quietly = TRUE)) {
      stop("Package 'FLCore' is required.", call. = FALSE)
    }
    return(FLCore::FLQuants())
  }
  if (!requireNamespace("FLCore", quietly = TRUE)) {
    stop("Package 'FLCore' is required.", call. = FALSE)
  }

  nm_yr <- resolveCol(db, c("Yr", "year", "yr"))
  nm_flt <- resolveCol(db, c("Fleet", "fleet", "FltSvy"))
  nm_obs <- resolveCol(db, c("Obs", "obs", "data"))
  nm_bin <- resolveCol(db, c("Bin", "bin", "len"))
  nm_sex <- resolveCol(db, c("sex", "Sex", "Gender", "unit"))
  nm_seas <- resolveCol(db, c("Seas", "season", "seas"))

  req <- c(nm_yr, nm_flt, nm_obs, nm_bin)
  if (any(is.na(req))) {
    stop("Length composition table needs year, fleet, Obs, and Bin columns.", call. = FALSE)
  }

  df <- data.frame(
    fleet = as.integer(db[[nm_flt]]),
    year = as.numeric(db[[nm_yr]]),
    len = as.numeric(db[[nm_bin]]),
    data = as.numeric(db[[nm_obs]]),
    stringsAsFactors = FALSE
  )
  if (!is.na(nm_sex)) {
    df$unit <- as.character(db[[nm_sex]])
  }
  if (!is.na(nm_seas)) {
    df$season <- as.numeric(db[[nm_seas]])
  }

  by_cols <- c("fleet", "year", "len")
  if ("unit" %in% names(df)) {
    by_cols <- c(by_cols, "unit")
  }
  if ("season" %in% names(df)) {
    by_cols <- c(by_cols, "season")
  }

  df <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by_cols))) |>
    dplyr::summarise(data = sum(data, na.rm = TRUE), .groups = "drop")
  df <- as.data.frame(df)

  flts <- sort(unique(df$fleet))
  if (is.null(fleetLabels)) {
    fleetLabels <- .ssLenFleetLabels(db)
  }
  flt_names <- if (!is.null(fleetLabels)) {
    unname(fleetLabels[as.character(flts)])
  } else {
    as.character(flts)
  }
  flt_names[is.na(flt_names) | !nzchar(flt_names)] <- as.character(flts)[is.na(flt_names) | !nzchar(flt_names)]

  pieces <- lapply(seq_along(flts), function(i) {
    f <- flts[[i]]
    sub <- df[df$fleet == f, , drop = FALSE]
    sub$fleet <- NULL
    cols <- intersect(c("len", "year", "unit", "season", "data"), names(sub))
    flq <- FLCore::as.FLQuant(sub[, cols, drop = FALSE])
    flq[is.na(flq)] <- 0
    tryCatch({ FLCore::units(flq) <- "NA" }, error = function(e) NULL)
    flq
  })
  stats::setNames(do.call(FLCore::FLQuants, pieces), flt_names)
}

#' Length compositions as \code{FLQuants} by fleet
#'
#' Reads observed length compositions (\code{lendbase} from cached \code{SS_output},
#' or \code{lencomp} from \code{data.ss}) and returns one \code{FLQuant} per fleet.
#' Length bins map to the quant dimension; year, unit (sex), and season are kept
#' when present.
#'
#' @param x SS3 run directory, \code{SS_output} list, \code{lendbase} data frame,
#'   or result of \code{ssLen()}.
#' @param cache Read cached \code{ss_output.rds} when \code{x} is a directory.
#' @param source \code{"lendbase"} from \code{SS_output} (default), or
#'   \code{"dat"} from \code{data.ss} via \code{ss3om::buildLCss330()}.
#' @param ... Passed to \code{ssRead()} when reading \code{Report.sso}.
#' @return An \code{FLQuants} object named by fleet.
#' @export
ssLenFlq <- function(
  x,
  cache = TRUE,
  source = c("lendbase", "dat"),
  ...
) {
  source <- match.arg(source)
  if (identical(source, "dat")) {
    if (!is.character(x) || length(x) != 1L || !nzchar(x)) {
      stop("source = 'dat' requires an SS3 run directory.", call. = FALSE)
    }
    if (!requireNamespace("ss3om", quietly = TRUE)) {
      stop("Package 'ss3om' is required for source = 'dat'.", call. = FALSE)
    }
    path <- ssRunDir(x)
    dat_file <- file.path(path, "data.ss")
    if (!file.exists(dat_file)) {
      dat_file <- file.path(path, paste0(basename(path), ".dat"))
    }
    if (!file.exists(dat_file)) {
      stop("No data.ss found under ", path, call. = FALSE)
    }
    dat <- r4ss::SS_readdat(dat_file)
    return(ss3om::buildLCss330(dat))
  }
  .ssLenFlqFromDb(.ssLenDb(x, cache = cache, ...))
}

.ssLenIndNames <- function() {
  c(
    "lbar", "lmean", "lmode", "lc50", "l95", "l25", "lmax5", "lmaxy",
    "pmega", "bheqz", "mlc"
  )
}

.ssLenIndOne <- function(lcs, indicators, params = list(), fleet = NULL, run = NULL, col = "run") {
  if (!inherits(lcs, "FLQuants")) {
    stop("lcs must be an FLQuants object.", call. = FALSE)
  }
  fleets <- names(lcs)
  if (is.null(fleets) || !length(fleets)) {
    fleets <- seq_along(lcs)
  }
  pieces <- lapply(seq_along(lcs), function(i) {
    flt <- fleets[[i]]
    lfq <- lcs[[i]]
    lapply(indicators, function(ind) {
      fn <- tryCatch(
        get(ind, envir = asNamespace("FLCore"), mode = "function"),
        error = function(e) NULL
      )
      if (is.null(fn)) {
        stop("Length indicator not found in FLCore: ", ind, call. = FALSE)
      }
      pars <- params[names(params) %in% names(formals(fn))]
      pars <- pars[!names(pars) %in% "x"]
      val <- tryCatch(
        do.call(fn, c(list(x = lfq), pars)),
        error = function(e) {
          stop("Indicator ", ind, " (fleet ", flt, "): ", conditionMessage(e), call. = FALSE)
        }
      )
      mf <- FLCore::model.frame(val)
      out <- data.frame(
        fleet = flt,
        indicator = ind,
        value = mf[["data"]],
        stringsAsFactors = FALSE
      )
      for (nm in c("year", "unit", "season", "area", "iter")) {
        if (nm %in% names(mf)) {
          out[[nm]] <- mf[[nm]]
        }
      }
      if (!is.null(run)) {
        out[[col]] <- run
      }
      out
    })
  })
  out <- do.call(rbind, unlist(pieces, recursive = FALSE))
  rownames(out) <- NULL
  ord <- c(col, "fleet", "year", "unit", "season", "area", "iter", "indicator", "value")
  ord <- intersect(ord, names(out))
  out <- out[, ord, drop = FALSE]
  if ("year" %in% names(out)) {
    sort_cols <- intersect(c(col, "fleet", "year", "indicator"), names(out))
    out <- out[do.call(order, out[sort_cols]), , drop = FALSE]
    rownames(out) <- NULL
  }
  out
}

#' Length-based indicators from SS3 length compositions
#'
#' Converts length compositions to \code{FLQuants} (\code{\link{ssLenFlq}}) and
#' computes ICES-style length indicators using \code{FLCore} (\code{lmean},
#' \code{lbar}, \code{l95}, etc.).
#'
#' @param x Assessment parent directory, \code{ssRuns()} table, SS3 run directory,
#'   \code{lendbase} input accepted by \code{ssLenFlq()}, or an \code{FLQuants}
#'   object.
#' @param indicators Character vector of \code{FLCore} indicator names (default:
#'   \code{lbar}, \code{lmean}, \code{l95}, \code{l25}, \code{lc50}, \code{lmax5}).
#' @param cache Read cached \code{ss_output.rds} when building \code{FLQuants}.
#' @param col Run id column name when \code{x} spans multiple scenarios.
#' @param parallel,workers Parallel over runs when \code{x} is an assessment base.
#' @param ... Extra arguments passed to indicators (\code{linf}, \code{k},
#'   \code{lenwt}, etc.) and to \code{ssLenFlq()}.
#' @return Data frame with \code{run} (if multiple scenarios), \code{fleet},
#'   \code{year}, optional \code{unit}/\code{season}, \code{indicator}, and
#'   \code{value}.
#' @export
ssLenInd <- function(
  x,
  indicators = c("lbar", "lmean", "l95", "l25", "lc50", "lmax5"),
  cache = TRUE,
  col = "run",
  parallel = TRUE,
  workers = NULL,
  ...
) {
  if (!requireNamespace("FLCore", quietly = TRUE)) {
    stop("Package 'FLCore' is required.", call. = FALSE)
  }
  indicators <- intersect(indicators, .ssLenIndNames())
  if (!length(indicators)) {
    stop(
      "No valid indicators. Choose from: ",
      paste(.ssLenIndNames(), collapse = ", "),
      call. = FALSE
    )
  }
  params <- list(...)

  if (inherits(x, "FLQuants")) {
    return(.ssLenIndOne(x, indicators, params = params))
  }

  runs <- .ssCurveRuns(x)
  if (nrow(runs) == 1L) {
    lcs <- ssLenFlq(runs$path[[1L]], cache = cache, ...)
    return(.ssLenIndOne(lcs, indicators, params = params, run = runs$id[[1L]], col = col))
  }

  if (isTRUE(parallel) && nrow(runs) > 1L) {
    nw <- workers %||% max(1L, parallel::detectCores(logical = TRUE) - 2L)
    message("[ssLenInd] workers: ", min(as.integer(nw), nrow(runs)))
  }

  pieces <- .ssParallel(
    seq_len(nrow(runs)),
    function(i) {
      id <- runs$id[[i]]
      path <- runs$path[[i]]
      message("[ssLenInd] ", id)
      lcs <- tryCatch(
        ssLenFlq(path, cache = cache, ...),
        error = function(e) {
          message("[ssLenInd] ", id, ": ", conditionMessage(e))
          NULL
        }
      )
      if (is.null(lcs)) {
        return(NULL)
      }
      .ssLenIndOne(lcs, indicators, params = params, run = id, col = col)
    },
    parallel = parallel,
    workers = workers
  )
  pieces <- pieces[!vapply(pieces, is.null, logical(1))]
  if (!length(pieces)) {
    return(data.frame())
  }
  out <- do.call(rbind, pieces)
  rownames(out) <- NULL
  out
}
