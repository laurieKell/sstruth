#' Collect spawning biomass time series from one SS3 run directory
#'
#' Loads \code{ss.RData} if present (expects object \code{ss}), otherwise
#' \code{r4ss::SS_output()}. Extracts \code{SpawnBio} from the timeseries table and
#' optional \code{SSB_<year>} standard errors from \code{derived_quants}, matching the
#' pattern used in ensemble examples (e.g. M × steepness grids).
#'
#' @param runDir Path to a converged SS3 folder.
#' @param model_id Optional label for the \code{model_id} column (default: basename of
#'   \code{runDir}).
#' @return A \code{tibble} with \code{year}, \code{spawn_bio}, \code{spawn_bio_sd}
#'   (may be \code{NA}), \code{model_id}.
#' @export
collectSs3ScenarioSsB <- function(runDir, model_id = NULL) {
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Install r4ss.", call. = FALSE)
  }
  runDir <- normalizePath(runDir, winslash = "/", mustWork = TRUE)
  if (is.null(model_id)) {
    model_id <- basename(runDir)
  }
  rd <- file.path(runDir, "ss.RData")
  if (file.exists(rd)) {
    e <- new.env(parent = emptyenv())
    load(rd, envir = e)
    if (!exists("ss", envir = e, inherits = FALSE)) {
      stop("ss.RData in ", runDir, " does not contain object 'ss'.", call. = FALSE)
    }
    ss <- e$ss
  } else {
    ss <- r4ss::SS_output(runDir, verbose = FALSE, printstats = FALSE, covar = FALSE)
  }
  ts <- tsDf(ss)
  if (!"Yr" %in% names(ts) || !"SpawnBio" %in% names(ts)) {
    stop("Timeseries missing Yr or SpawnBio in ", runDir, call. = FALSE)
  }
  sub <- ts[["Area"]] == 1L & ts[["Era"]] %in% c("TIME", "FORE")
  if ("Seas" %in% names(ts) && length(ss[["spawnseas"]]) > 0) {
    sub <- sub & ts[["Seas"]] %in% ss[["spawnseas"]]
  }
  x <- ts[sub, , drop = FALSE]
  yrs <- sort(unique(as.integer(x[["Yr"]])))
  spawn <- vapply(yrs, function(y) {
    w <- which(as.integer(x[["Yr"]]) == y)
    if (!length(w)) {
      return(NA_real_)
    }
    sum(as.numeric(x[w, "SpawnBio", drop = TRUE]), na.rm = TRUE)
  }, numeric(1))

  dq <- ss[["derived_quants"]]
  sdvec <- rep(NA_real_, length(yrs))
  if (is.data.frame(dq) && nrow(dq) && "Label" %in% names(dq) && "StdDev" %in% names(dq)) {
    for (j in seq_along(yrs)) {
      y <- yrs[j]
      lab <- paste0("SSB_", y)
      hit <- dq[["Label"]] == lab
      if (any(hit)) {
        sdvec[j] <- suppressWarnings(as.numeric(dq[hit, "StdDev"][[1]]))
      }
    }
  }

  tibble::tibble(
    year = yrs,
    spawn_bio = spawn,
    spawn_bio_sd = sdvec,
    model_id = model_id
  )
}

#' Collect SSB time series for an M × steepness directory grid
#'
#' Expects folders \code{file.path(root, M[i], h[i])} for each row in
#' \code{\link{mhScenarioGrid}(M, h)} (same layout as \code{\link{runSs3MhGrid}}).
#'
#' @param root Root path containing subfolders \code{M/h/}.
#' @param M Numeric vector of M multipliers (same length as \code{h} or use
#'   \code{expand.grid} via \code{scen}).
#' @param h Numeric vector of steepness values.
#' @param scen Optional \code{data.frame} from \code{\link{mhScenarioGrid}}; if supplied,
#'   \code{M} and \code{h} are ignored.
#' @return A single \code{tibble} with columns \code{M}, \code{h}, \code{year},
#'   \code{spawn_bio}, \code{spawn_bio_sd}, \code{model_id}.
#' @export
collectMhGridSsB <- function(root, M, h, scen = NULL) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (is.null(scen)) {
    scen <- mhScenarioGrid(M, h)
  }
  out <- vector("list", nrow(scen))
  for (i in seq_len(nrow(scen))) {
    mm <- scen[["M"]][i]
    hh <- scen[["h"]][i]
    d <- file.path(root, as.character(mm), as.character(hh))
    mid <- paste0("M", mm, "_h", hh)
    out[[i]] <- dplyr::mutate(
      collectSs3ScenarioSsB(d, model_id = mid),
      M = mm,
      h = hh,
      .before = 1
    )
  }
  dplyr::bind_rows(out)
}

#' Equal weights for \code{n} ensemble members
#'
#' @param n Number of models.
#' @return Numeric vector of length \code{n} summing to 1.
#' @export
ensembleWeightsEqual <- function(n) {
  n <- as.integer(n[[1]])
  if (n < 1L) {
    stop("n must be positive.", call. = FALSE)
  }
  rep(1 / n, n)
}

#' Softmax-style weights from negative log-likelihoods or AIC-like scores
#'
#' Computes \eqn{w_k \propto \exp(-0.5 \cdot x_k)} and normalizes. Lower \code{x} implies
#' higher weight (e.g. \code{x} = AIC or \code{x} = -2 log L for comparable models).
#'
#' @param x Numeric vector (one value per model).
#' @return Numeric vector of weights summing to 1.
#' @export
ensembleWeightsSoftmaxNeg2 <- function(x) {
  x <- as.numeric(x)
  if (any(!is.finite(x))) {
    stop("Non-finite scores in x.", call. = FALSE)
  }
  w <- exp(-0.5 * (x - min(x)))
  w / sum(w)
}

#' Weighted mean spawning biomass by year
#'
#' @param data Output from \code{\link{collectSs3ScenarioSsB}} stacked for multiple
#'   models, or \code{\link{collectMhGridSsB}}, with a \code{model_id} column.
#' @param weights Named vector (\code{names} = \code{model_id}) or unnamed vector in the
#'   same row order as unique \code{model_id} levels.
#' @param valueCol Name of biomass column (default \code{spawn_bio}).
#' @return \code{tibble} with \code{year}, \code{spawn_bio_ensemble}.
#' @export
ensembleWeightedSpawnBio <- function(data, weights, valueCol = "spawn_bio") {
  if (!"model_id" %in% names(data) || !valueCol %in% names(data)) {
    stop("data must contain model_id and ", valueCol, call. = FALSE)
  }
  mids <- unique(as.character(data$model_id))
  if (is.null(names(weights))) {
    if (length(weights) != length(mids)) {
      stop("length(weights) must match number of distinct model_id.", call. = FALSE)
    }
    names(weights) <- mids
  }
  wn <- weights[mids]
  if (anyNA(wn)) {
    stop("weights missing for some model_id.", call. = FALSE)
  }
  wn <- wn / sum(wn)
  names(wn) <- mids
  data$w_model <- wn[as.character(data$model_id)]
  dplyr::summarize(
    dplyr::group_by(data, .data$year),
    spawn_bio_ensemble = sum(.data[[valueCol]] * .data$w_model, na.rm = TRUE),
    .groups = "drop"
  )
}
