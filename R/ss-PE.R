#' Build SS3 time-series and equilibrium curve without FLR dependencies
#'
#' Reads an SS3 run directory, a saved \code{ss_output.rds}, or an in-memory
#' \code{SS_output} list (via \code{\link{ssReadOutput}}).
#' a list with \code{tseries} and \code{curve}, mirroring the pieces used by
#' \code{ssPe()} / \code{ssPeCompare()}.
#'
#' The returned \code{tseries} includes additional columns:
#' \code{sprod} (surplus production from total biomass, as in \code{r4ss::SSplotYield}
#' subplot 3/4), \code{sp_ssb} (surplus production from spawning biomass),
#' legacy aliases \code{P_obs}/\code{P_ssb}/\code{pf}, and process-error columns
#' \code{pe} (log), \code{pe2} (relative), and \code{pe_diff} (absolute).
#'
#' @param x SS3 run directory, \code{ss_output.rds} path, or \code{SS_output} list.
#' @param cache Read or write \code{ss_output.rds} when \code{x} is a directory.
#' @param maxY Multiplier for the upper yield corner of the MSY reference
#'   triangle, as in \code{FLRebuild::curveSS}: \code{signif(max(yield) * maxY, 1)}.
#' @param ... Passed to \code{ssRead()} when reading \code{Report.sso}.
#' @return List with elements \code{tseries}, \code{curve}, \code{refpts}, and
#'   \code{triangle} (an MSY reference polygon in \code{x}/\code{y} space).
#' @export
curveSS <- function(x, cache = TRUE, maxY = 1.5, ...) {
  rep <- .readSsOutput(x, cache = cache, ...)
  .curveSSFromRep(rep, maxY = maxY)
}

#' Read \code{SS_output} for curveSS (uses \code{ssReadOutput} when installed).
#' @noRd
.readSsOutput <- function(x, cache = TRUE, ...) {
  fn <- get0("ssReadOutput", envir = asNamespace("sstruth"), inherits = FALSE)
  if (is.function(fn)) {
    return(fn(x, cache = cache, ...))
  }
  if (is.list(x) && !is.data.frame(x)) {
    return(x)
  }
  if (!is.character(x) || length(x) != 1L || !nzchar(x)) {
    stop(
      "Provide an SS3 run directory, ss_output.rds path, or SS_output list.",
      call. = FALSE
    )
  }
  path <- normalizePath(x, winslash = "/", mustWork = FALSE)
  if (grepl("\\.rds$", path, ignore.case = TRUE) && file.exists(path)) {
    return(readRDS(path))
  }
  if (!dir.exists(path)) {
    stop("SS3 run directory not found: ", path, call. = FALSE)
  }
  out <- NULL
  if (isTRUE(cache) && file.exists(ssCache(path))) {
    out <- readRDS(ssCache(path))
  }
  if (is.null(out)) {
    out <- ssRead(path, writeCache = isTRUE(cache), ...)
  }
  if (is.null(out)) {
    stop("Could not read SS_output from ", path, call. = FALSE)
  }
  out
}

#' Validate process-error display mode
#' @param mode One of \code{"log"}, \code{"relative"} (\eqn{(y-x)/x}), or
#'   \code{"diff"} (\eqn{y-x}).
#' @export
processErrorMode <- function(mode = c("log", "relative", "diff")) {
  match.arg(mode)
}

#' @export
processErrorLabel <- function(mode = c("log", "relative", "diff")) {
  mode <- processErrorMode(mode)
  switch(
    mode,
    log = "Log process error",
    relative = "Process error (y - x) / x",
    diff = "Process error (y - x)"
  )
}

#' @noRd
.peTransform <- function(obs, pred, mode = c("log", "relative", "diff")) {
  mode <- match.arg(mode)
  obs <- as.numeric(obs)
  pred <- as.numeric(pred)
  out <- rep(NA_real_, length(obs))
  ok <- is.finite(obs) & is.finite(pred)
  if (mode == "log") {
    ok <- ok & obs > 0 & pred > 0
    out[ok] <- log(obs[ok]) - log(pred[ok])
  } else if (mode == "relative") {
    ok <- ok & pred != 0
    out[ok] <- (obs[ok] - pred[ok]) / pred[ok]
  } else {
    out[ok] <- obs[ok] - pred[ok]
  }
  out
}

#' Process-error column name in a \code{curveSS} time series
#' @param mode Process-error mode (\code{\link{processErrorMode}}).
#' @export
processErrorColumn <- function(mode = c("log", "relative", "diff")) {
  mode <- processErrorMode(mode)
  switch(mode, log = "pe", relative = "pe2", diff = "pe_diff")
}

#' Attach a unified \code{pe_resid} column for plotting
#' @param pe \code{curveSS} list or run directory.
#' @param pe_mode Process-error mode.
#' @export
peResidualTseries <- function(pe, pe_mode = c("log", "relative", "diff")) {
  if (is.character(pe) && length(pe) == 1L) {
    pe <- curveSS(pe)
  }
  if (is.null(pe$tseries) || !NROW(pe$tseries)) {
    stop("pe$tseries is empty.", call. = FALSE)
  }
  pe_mode <- processErrorMode(pe_mode)
  col <- processErrorColumn(pe_mode)
  ts <- pe$tseries
  if (!col %in% names(ts)) {
    stop("Column ", col, " not found in pe$tseries.", call. = FALSE)
  }
  ts$pe_resid <- ts[[col]]
  if (!"id" %in% names(ts) && "run" %in% names(ts)) {
    ts$id <- ts$run
  }
  if (!"sp" %in% names(ts)) {
    sp_col <- curveSsProductionCol(ts, type = "ssb") %||% "sp_ssb"
    if (sp_col %in% names(ts)) {
      ts$sp <- ts[[sp_col]]
    }
  }
  if (!"sp_ss3" %in% names(ts) && "sprod" %in% names(ts)) {
    ts$sp_ss3 <- ts$sprod
  }
  ts
}

#' @noRd
.pePlotLimits <- function(x, ylim = NULL, prob = 0.02) {
  if (!is.null(ylim) && length(ylim) == 2L) {
    return(ylim)
  }
  x <- x[is.finite(x)]
  if (!length(x)) {
    return(c(-1, 1))
  }
  if (length(x) < 5L) {
    pad <- max(0.05 * diff(range(x)), 1e-6)
    return(range(x) + c(-pad, pad))
  }
  qs <- stats::quantile(x, probs = c(prob, 1 - prob), na.rm = TRUE)
  pad <- 0.05 * diff(qs)
  if (!is.finite(pad) || pad <= 0) {
    pad <- max(0.05 * max(abs(qs)), 1e-6)
  }
  c(qs[1L] - pad, qs[2L] + pad)
}

#' @export
pePlotLimits <- function(x, ylim = NULL, prob = 0.02) {
  .pePlotLimits(x, ylim = ylim, prob = prob)
}

.sprodSeries <- function(state, catch) {
  n <- length(state)
  if (n < 2L) {
    return(rep(NA_real_, n))
  }
  c(state[-1] - state[-n] + catch[-n], NA_real_)
}

.curveSsCatchRows <- function(ts, catch_cols) {
  if (length(catch_cols) == 1L && !is.na(catch_cols)) {
    return(as.numeric(ts[[catch_cols]]))
  }
  if (length(catch_cols) > 1L) {
    return(rowSums(ts[, catch_cols, drop = FALSE], na.rm = TRUE))
  }
  rep(NA_real_, nrow(ts))
}

#' Aggregate SS3 timeseries to yearly surplus-production inputs
#'
#' Matches \code{r4ss::SSplotYield()}: exclude \code{VIRG}/\code{FORE} eras, sum
#' \code{dead(B)} catch and \code{Bio_all}/\code{SpawnBio} across areas within
#' year-season, then mean biomass by year and sum catch by year.
#'
#' @param ts \code{timeseries} data frame from \code{SS_output()}.
#' @return Yearly data frame with \code{year}, \code{bio_all}, \code{ssb}, \code{yield}.
#' @noRd
.curveSsAggregateYears <- function(ts) {
  if ("Era" %in% names(ts)) {
    ts <- ts[!as.character(ts$Era) %in% c("VIRG", "FORE"), , drop = FALSE]
  }
  if (!nrow(ts)) {
    stop("No non-VIRG/FORE rows in SS_output() timeseries.", call. = FALSE)
  }

  yr_col <- resolveCol(ts, c("Yr", "Year", "year"))
  ssb_col <- resolveCol(ts, c("SpawnBio", "SSB", "ssb"))
  bio_all_col <- resolveCol(ts, c("Bio_all"))
  if (is.na(bio_all_col)) {
    bio_all_col <- resolveCol(ts, c("Bio_smry", "biomass", "stock"))
  }
  seas_col <- resolveCol(ts, c("Seas", "seas", "Season", "season"))
  if (any(is.na(c(yr_col, ssb_col, bio_all_col)))) {
    stop("timeseries must include year, SpawnBio/SSB, and Bio_all/biomass columns.", call. = FALSE)
  }

  catch_cols <- grep("^dead\\(B\\):", names(ts), value = TRUE)
  if (!length(catch_cols)) {
    catch_cols <- grep("^retain\\(B\\):", names(ts), value = TRUE)
  }
  if (!length(catch_cols)) {
    catch_cols <- resolveCol(ts, c("totcatch", "yield", "catch"))
  }

  ts$.__year__ <- as.integer(ts[[yr_col]])
  ts$.__seas__ <- if (is.na(seas_col)) 1L else as.integer(ts[[seas_col]])
  ts$.__bio_all__ <- as.numeric(ts[[bio_all_col]])
  ts$.__ssb__ <- as.numeric(ts[[ssb_col]])
  ts$.__catch__ <- .curveSsCatchRows(ts, catch_cols)

  ts <- ts[is.finite(ts$.__year__), , drop = FALSE]
  if (!nrow(ts)) {
    stop("No finite years in timeseries.", call. = FALSE)
  }

  season_key <- paste(ts$.__year__, ts$.__seas__, sep = ":")
  season_pieces <- lapply(split(seq_len(nrow(ts)), season_key), function(idx) {
    z <- ts[idx, , drop = FALSE]
    data.frame(
      year = z$.__year__[[1]],
      season = z$.__seas__[[1]],
      bio_all = sum(z$.__bio_all__, na.rm = TRUE),
      ssb = sum(z$.__ssb__, na.rm = TRUE),
      catch = sum(z$.__catch__, na.rm = TRUE),
      stringsAsFactors = FALSE
    )
  })
  season_df <- do.call(rbind, season_pieces)
  rownames(season_df) <- NULL

  year_pieces <- lapply(split(season_df, season_df$year), function(z) {
    data.frame(
      year = z$year[[1]],
      bio_all = mean(z$bio_all, na.rm = TRUE),
      ssb = mean(z$ssb, na.rm = TRUE),
      yield = sum(z$catch, na.rm = TRUE),
      stringsAsFactors = FALSE
    )
  })
  yearly <- do.call(rbind, year_pieces)
  rownames(yearly) <- NULL
  yearly <- yearly[order(yearly$year), , drop = FALSE]
  rownames(yearly) <- NULL
  yearly
}

.curveSSFromRep <- function(rep, maxY = 1.5) {
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Package 'r4ss' is required.", call. = FALSE)
  }
  ts <- tsDf(rep)
  if (!is.data.frame(ts) || nrow(ts) == 0L) {
    stop("Could not extract non-empty timeseries from SS_output().", call. = FALSE)
  }

  tseries <- .curveSsAggregateYears(ts)
  n <- nrow(tseries)
  if (n < 2L) {
    stop("Need at least 2 yearly rows in tseries.", call. = FALSE)
  }

  bio_all <- as.numeric(tseries$bio_all)
  ssb <- as.numeric(tseries$ssb)
  catch <- as.numeric(tseries$yield)

  sprod <- .sprodSeries(bio_all, catch)
  sp_ssb <- .sprodSeries(ssb, catch)
  pf <- sp_ssb

  pred <- rep(NA_real_, n)
  obs <- rep(NA_real_, n)
  if (n >= 2L) {
    pred[2:n] <- ssb[-n] - catch[-n] + pf[-n]
    obs[2:n] <- ssb[-1]
  }
  pe <- .peTransform(obs, pred, "log")
  pe2 <- .peTransform(obs, pred, "relative")
  pe_diff <- .peTransform(obs, pred, "diff")

  tseries$biomass <- bio_all
  tseries$sprod <- sprod
  tseries$sp_ssb <- sp_ssb
  tseries$P_obs <- sprod
  tseries$P_hat <- rep(NA_real_, n)
  tseries$B_df <- ssb
  tseries$B <- bio_all
  tseries$C_t <- catch
  tseries$P_ssb <- sp_ssb
  tseries$pf <- pf
  tseries$pe <- pe
  tseries$pe2 <- pe2
  tseries$pe_diff <- pe_diff

  eq <- rep$equil_yield %||% rep$equilibrium_yield %||% rep$Equil_yield
  if (!is.data.frame(eq) || nrow(eq) == 0L) {
    stop("Could not find non-empty equilibrium yield table in SS_output().", call. = FALSE)
  }
  eq_ssb <- resolveCol(eq, c("SSB", "ssb", "SpawnBio"))
  eq_yld <- resolveCol(eq, c("Tot_Catch", "tot_catch", "yield", "Catch"))
  if (any(is.na(c(eq_ssb, eq_yld)))) {
    stop("Equilibrium table must contain SSB and catch/yield columns.", call. = FALSE)
  }
  curve <- data.frame(
    ssb = as.numeric(eq[[eq_ssb]]),
    yield = as.numeric(eq[[eq_yld]]),
    stringsAsFactors = FALSE
  )
  eq_f <- resolveCol(eq, c("annF", "F", "F_report"))
  if (!is.na(eq_f)) {
    curve$F <- as.numeric(eq[[eq_f]])
  }
  keep <- is.finite(curve$ssb) & is.finite(curve$yield) & curve$ssb >= 0
  curve <- curve[keep, , drop = FALSE]
  if (!nrow(curve)) stop("No finite rows in equilibrium curve.", call. = FALSE)

  refpts <- .curveSSRefpts(curve, rep$derived_quants)

  triangle <- .curveSSTriangle(curve, refpts, tseries = tseries, maxY = maxY)

  list(tseries = tseries, curve = curve, refpts = refpts, triangle = triangle)
}

#' Reference points for curveSS (aligned with FLRebuild::curveSS).
#' MSY from \code{Dead_Catch_MSY} / equilibrium-curve peak; SSB from \code{SSB_MSY}.
#' @noRd
.curveSSRefpts <- function(curve, derived_quants = NULL) {
  get_dq <- function(keys) {
    if (!is.data.frame(derived_quants) ||
        !all(c("Label", "Value") %in% names(derived_quants))) {
      return(NA_real_)
    }
    labels <- tolower(as.character(derived_quants$Label))
    keys <- tolower(keys)
    idx <- match(keys, labels)
    idx <- idx[!is.na(idx)]
    if (!length(idx)) {
      return(NA_real_)
    }
    as.numeric(derived_quants$Value[idx[1]])
  }

  bmsy <- get_dq(c("SSB_MSY", "SSB_Btgt", "Btgt_MSY"))
  msy <- get_dq(c("Dead_Catch_MSY", "Ret_Catch_MSY", "MSY"))
  fmsy <- get_dq(c("annF_MSY", "F_MSY", "F_at_MSY"))

  ok <- is.finite(curve$yield) & curve$yield > 0 & is.finite(curve$ssb)
  if (any(ok)) {
    ix <- which.max(curve$yield[ok])
    idx <- which(ok)[ix]
    if (!is.finite(msy) || msy <= 0) {
      msy <- as.numeric(curve$yield[idx])
    }
    if (!is.finite(bmsy) || bmsy <= 0) {
      bmsy <- as.numeric(curve$ssb[idx])
    }
  }

  data.frame(
    bmsy = bmsy,
    msy = msy,
    fmsy = fmsy,
    stringsAsFactors = FALSE
  )
}

#' MSY reference triangle (same geometry as \code{FLRebuild::curveSS}).
#' @noRd
.curveSSTriangle <- function(curve, refpts, tseries = NULL, maxY = 1.5) {
  if (is.null(curve) || !NROW(curve) || is.null(refpts) || !NROW(refpts)) {
    return(NULL)
  }
  if (!all(c("bmsy", "msy") %in% names(refpts))) {
    return(NULL)
  }
  bmsy <- as.numeric(refpts$bmsy[1L])
  msy <- as.numeric(refpts$msy[1L])
  if (!is.finite(msy) || msy <= 0) {
    idx <- which.max(curve$yield)
    if (length(idx) && is.finite(curve$yield[idx])) {
      msy <- as.numeric(curve$yield[idx])
    }
  }
  if (!is.finite(bmsy) || bmsy <= 0) {
    idx <- which.max(curve$yield)
    if (length(idx) && is.finite(curve$ssb[idx])) {
      bmsy <- as.numeric(curve$ssb[idx])
    }
  }
  if (!is.finite(bmsy) || !is.finite(msy) || bmsy <= 0 || msy <= 0) {
    return(NULL)
  }
  if (!is.finite(maxY) || maxY <= 0) {
    maxY <- 1.5
  }
  yields <- c(curve$yield, msy)
  if (!is.null(tseries) && is.data.frame(tseries) && "yield" %in% names(tseries)) {
    yields <- c(yields, tseries$yield)
  }
  y_top <- signif(suppressWarnings(max(yields, na.rm = TRUE)) * maxY, 1)
  if (!is.finite(y_top) || y_top <= msy) {
    y_top <- signif(msy * maxY, 1)
  }
  x_top <- bmsy * y_top / msy
  data.frame(
    x = c(bmsy, bmsy, x_top, bmsy),
    y = c(msy, y_top, y_top, msy),
    stringsAsFactors = FALSE
  )
}

#' Compare SS production-function signal against PT fits
#'
#' Fits Pella-Tomlinson (PT) production curves in biomass and SSB space, compares
#' them to SS-derived production-function behavior, computes process-error series,
#' and optionally generates ggplot diagnostics.
#'
#' @param tseries Data frame containing at least `year`, `biomass`, `ssb`,
#'   `yield`, and `pf`. If `pe` is missing, reference process error is
#'   recomputed from `pf`.
#' @param eqlYield Data frame containing SS equilibrium curve columns `ssb` and
#'   `yield`.
#' @param shapePt Numeric scalar in `(0, 1)`, interpreted as `Bmsy/K` for the
#'   PT mapping.
#' @param bmsySsb Optional positive scalar. If provided, constrains the SSB PT
#'   fit via `K = bmsySsb / shapePt`.
#' @param makePlots Logical; if `TRUE`, produces three ggplot panels (biomass
#'   SP, SSB SP, and process error).
#' @param pointCol Point and path color for observed clouds.
#' @param eqCol Reserved equilibrium color argument for compatibility.
#' @param ptColB PT-curve color for biomass-space fits.
#' @param ptColSsb PT-curve color for SSB-space fits.
#'
#' @return An (invisible) list with elements:
#' \describe{
#'   \item{pars}{Parameter summary table for biomass and SSB PT fits.}
#'   \item{pe}{Year-wise process-error series (reference and PT-based).}
#'   \item{diagnostics}{Curve and PE similarity metrics including
#'   `curve_cor`, `curve_rel_rmse`, `pe_cor_ssb`, and a
#'   `likely_misspecified` flag.}
#'   \item{biomass}{Fit object, observed points, and fitted curve in biomass space.}
#'   \item{ssb}{Fit object, observed points, and fitted curve in SSB space.}
#' }
#' @export
ssPeCompare<-function(tseries,
                                eqlYield,
                                shapePt,
                                bmsySsb = NULL,
                                pe_mode = c("log", "relative", "diff"),
                                makePlots = TRUE,
                                pointCol = "grey40",
                                eqCol = "black",
                                ptColB = "blue",
                                ptColSsb = "red") {
  if (!all(c("year", "biomass", "ssb", "yield") %in% names(tseries))) {
    stop("tseries must contain: year, biomass, ssb, yield")
  }
  if (!all(c("ssb", "yield") %in% names(eqlYield))) {
    stop("eqlYield must contain: ssb, yield")
  }
  if (!is.numeric(shapePt) || length(shapePt) != 1L || shapePt <= 0 || shapePt >= 1) {
    stop("shapePt must be a single Bmsy/K value in (0,1)")
  }
  if (!is.null(bmsySsb) && (!is.numeric(bmsySsb) || length(bmsySsb) != 1L || bmsySsb <= 0)) {
    stop("bmsySsb must be NULL or a single positive number")
  }
  if (is.null(tseries$pf)) stop("tseries must contain column 'pf'")
  pe_mode <- processErrorMode(pe_mode)

  calcSurplusProduction<-function(biomassT, biomassT1, catchT) biomassT1 - biomassT + catchT
  shape2p<-function(shape) {
    fn=function(x, y) (y - (1 / (1 + x))^(1 / x))^2
    if (shape < 0.3678794) {
      optimise(fn, c(-0.9999, -1e-20), y = shape)$minimum
    } else {
      optimise(fn, c(1e-20, 10), y = shape)$minimum
    }
  }
  ptProdRKp<-function(B, r, K, p) {
    out=(r / p) * B * (1 - (B / K)^p)
    out[!is.finite(out)]=NA_real_
    out
  }
  fitPt<-function(biomassT, surplusProd, shape, Bmsy_input = NULL, weights = NULL, control = list()) {
    ok=is.finite(biomassT) & is.finite(surplusProd) & biomassT > 0 & surplusProd > 0
    biomassT=biomassT[ok]
    surplusProd=surplusProd[ok]
    if (length(biomassT) < 3L) stop("Not enough positive SP data to fit PT")
    if (is.null(weights)) weights=rep(1, length(surplusProd)) else weights=weights[ok]
    p=shape2p(shape)
    spLog=log(surplusProd)
    control=modifyList(list(maxit = 1000), control)

    if (is.null(Bmsy_input)) {
      parStart=c(
        logR = log(max(surplusProd, na.rm = TRUE) / max(biomassT, na.rm = TRUE)),
        logK = log(max(biomassT, na.rm = TRUE) * 1.2)
      )
      negLogLik=function(par) {
        r=exp(par[1]); K=exp(par[2])
        spHat=ptProdRKp(biomassT, r = r, K = K, p = p)
        if (any(!is.finite(spHat))) return(1e12)
        spHat[spHat <= 0]=.Machine$double.eps
        res=spLog - log(spHat)
        sigma2=sum(weights * res^2) / sum(weights)
        if (!is.finite(sigma2) || sigma2 <= 0) return(1e12)
        Kref=max(biomassT, na.rm = TRUE)
        penalty=if (K > 5 * Kref) 5 * (log(K / (5 * Kref)))^2 else 0
        0.5 * sum(weights * (log(2 * pi * sigma2) + res^2 / sigma2)) + penalty
      }
      fit=optim(par = parStart, fn = negLogLik, method = "Nelder-Mead", control = control, hessian = TRUE)
      rHat=exp(fit$par[1]); KHat=exp(fit$par[2])
    } else {
      KHat=Bmsy_input / shape
      parStart=c(logR = log(max(surplusProd, na.rm = TRUE) / max(biomassT, na.rm = TRUE)))
      negLogLik=function(par) {
        r=exp(par[1])
        spHat=ptProdRKp(biomassT, r = r, K = KHat, p = p)
        if (any(!is.finite(spHat))) return(1e12)
        spHat[spHat <= 0]=.Machine$double.eps
        res=spLog - log(spHat)
        sigma2=sum(weights * res^2) / sum(weights)
        if (!is.finite(sigma2) || sigma2 <= 0) return(1e12)
        0.5 * sum(weights * (log(2 * pi * sigma2) + res^2 / sigma2))
      }
      fit=optim(par = parStart, fn = negLogLik, method = "Nelder-Mead", control = control, hessian = TRUE)
      rHat=exp(fit$par[1])
    }

    Bmsy=shape * KHat
    MSY=ptProdRKp(Bmsy, rHat, KHat, p)
    list(
      estimates = list(r = rHat, k = KHat, p = p, shape = shape, bmsy = Bmsy, msy = MSY),
      convergence = fit$convergence,
      logLik = -fit$value,
      hessian = fit$hessian
    )
  }
  predictPtBiomass<-function(biomassT, catchT, r, K, p) biomassT + ptProdRKp(biomassT, r, K, p) - catchT

  year=tseries$year
  B=tseries$biomass
  SSB=tseries$ssb
  C=tseries$yield
  eq_SSB=eqlYield$ssb
  eq_SP=eqlYield$yield

  yr_t=year[-length(year)]
  B_t=B[-length(B)]
  B_t1=B[-1]
  SSB_t=SSB[-length(SSB)]
  SSB_t1=SSB[-1]
  C_t=C[-length(C)]
  SP_B=calcSurplusProduction(B_t, B_t1, C_t)
  SP_SSB=calcSurplusProduction(SSB_t, SSB_t1, C_t)

  fit_B=fitPt(B_t, SP_B, shape = shapePt)
  fit_SSB=fitPt(SSB_t, SP_SSB, shape = shapePt, Bmsy_input = bmsySsb)
  est_B=fit_B$estimates
  est_SSB=fit_SSB$estimates

  B_grid=seq(0, est_B$k, length.out = 400)
  SSB_grid=seq(0, est_SSB$k, length.out = 400)
  PT_B_grid=ptProdRKp(B_grid, est_B$r, est_B$k, est_B$p)
  PT_SSB_grid=ptProdRKp(SSB_grid, est_SSB$r, est_SSB$k, est_SSB$p)
  PT_B_grid_plot=pmax(PT_B_grid, 0)
  PT_SSB_grid_plot=pmax(PT_SSB_grid, 0)
  eq_keep=is.finite(eq_SSB) & is.finite(eq_SP) & eq_SP >= 0

  Bpred_PT=predictPtBiomass(B_t, C_t, est_B$r, est_B$k, est_B$p)
  SSBpred_PT=predictPtBiomass(SSB_t, C_t, est_SSB$r, est_SSB$k, est_SSB$p)
  eps_B_PT=.peTransform(B_t1, Bpred_PT, pe_mode)
  eps_SSB_PT=.peTransform(SSB_t1, SSBpred_PT, pe_mode)

  pf_t=tseries$pf[-length(tseries$pf)]
  SSB_t0=tseries$ssb[-length(tseries$ssb)]
  SSB_t1_0=tseries$ssb[-1]
  C_t0=tseries$yield[-length(tseries$yield)]
  pe_from_pf <- .peTransform(
    SSB_t1_0,
    SSB_t0 - C_t0 + pf_t,
    pe_mode
  )
  pe_col <- processErrorColumn(pe_mode)
  pe_ref <- if (pe_col %in% names(tseries)) {
    tail(tseries[[pe_col]], -1)
  } else {
    pe_from_pf
  }

  interp_pt_on_eq=stats::approx(x = SSB_grid, y = PT_SSB_grid, xout = eq_SSB[eq_keep], rule = 1)$y
  ok_cmp=is.finite(interp_pt_on_eq) & is.finite(eq_SP[eq_keep])
  curve_rmse=if (any(ok_cmp)) sqrt(mean((interp_pt_on_eq[ok_cmp] - eq_SP[eq_keep][ok_cmp])^2)) else NA_real_
  curve_rel_rmse=if (is.finite(curve_rmse)) {
    denom=max(eq_SP[eq_keep], na.rm = TRUE)
    if (is.finite(denom) && denom > 0) curve_rmse / denom else NA_real_
  } else NA_real_
  curve_cor=if (sum(ok_cmp) > 2) suppressWarnings(stats::cor(interp_pt_on_eq[ok_cmp], eq_SP[eq_keep][ok_cmp])) else NA_real_
  pe_cor_ssb=if (sum(is.finite(pe_ref) & is.finite(eps_SSB_PT)) > 2) suppressWarnings(stats::cor(pe_ref, eps_SSB_PT, use = "complete.obs")) else NA_real_
  pe_cor_bio=if (sum(is.finite(pe_ref) & is.finite(eps_B_PT)) > 2) suppressWarnings(stats::cor(pe_ref, eps_B_PT, use = "complete.obs")) else NA_real_
  pe_rmse_ssb=sqrt(mean((pe_ref - eps_SSB_PT)^2, na.rm = TRUE))
  pe_rmse_bio=sqrt(mean((pe_ref - eps_B_PT)^2, na.rm = TRUE))
  misspec_flag=isTRUE((is.finite(curve_rel_rmse) && curve_rel_rmse > 0.20) || (is.finite(pe_cor_ssb) && pe_cor_ssb < 0.60))

  if (isTRUE(makePlots)) {
    ylim_B=c(0, max(c(SP_B[SP_B >= 0], PT_B_grid_plot), na.rm = TRUE) * 1.05)
    ylim_SSB=c(0, max(c(SP_SSB[SP_SSB >= 0], eq_SP[eq_keep], PT_SSB_grid_plot), na.rm = TRUE) * 1.05)
    ylim_PE=.pePlotLimits(c(eps_B_PT, eps_SSB_PT, pe_ref))

    sp_b_df=data.frame(biomass = B_t, sp = SP_B)
    sp_b_curve_df=data.frame(biomass = B_grid, pt = PT_B_grid_plot)
    sp_ssb_df=data.frame(ssb = SSB_t, sp = SP_SSB)
    sp_ssb_eq_df=data.frame(ssb = eq_SSB[eq_keep], yield = eq_SP[eq_keep])
    sp_ssb_curve_df=data.frame(ssb = SSB_grid, pt = PT_SSB_grid_plot)
    pe_long=rbind(
      data.frame(year = yr_t, series = "Reference PE (pf)", value = pe_ref),
      data.frame(year = yr_t, series = "Biomass PT PE", value = eps_B_PT),
      data.frame(year = yr_t, series = "SSB PT PE", value = eps_SSB_PT)
    )
    pe_long$series=factor(pe_long$series, levels = c("Reference PE (pf)", "Biomass PT PE", "SSB PT PE"))

    p_bio=ggplot2::ggplot(sp_b_df, ggplot2::aes(x = biomass, y = sp)) +
      ggplot2::geom_point(color = pointCol) +
      ggplot2::geom_path(linewidth = 0.25, color = pointCol) +
      ggplot2::geom_line(data = sp_b_curve_df, ggplot2::aes(x = biomass, y = pt), linewidth = 1.1, color = ptColB) +
      ggplot2::geom_hline(yintercept = 0, linetype = 3) +
      ggplot2::coord_cartesian(xlim = c(0, est_B$k), ylim = ylim_B) +
      ggplot2::theme_minimal() +
      ggplot2::labs(title = paste0("Biomass SP; Bmsy/K=", round(est_B$shape, 2)), x = "Biomass", y = "Surplus production")

    p_ssb=ggplot2::ggplot(sp_ssb_df, ggplot2::aes(x = ssb, y = sp)) +
      ggplot2::geom_point(color = pointCol) +
      ggplot2::geom_path(linewidth = 0.25, color = pointCol) +
      ggplot2::geom_line(data = sp_ssb_eq_df, ggplot2::aes(x = ssb, y = yield), linewidth = 1.1, color = "orange") +
      ggplot2::geom_line(data = sp_ssb_curve_df, ggplot2::aes(x = ssb, y = pt), linewidth = 1.1, color = ptColSsb) +
      ggplot2::geom_hline(yintercept = 0, linetype = 3) +
      ggplot2::coord_cartesian(xlim = c(0, est_SSB$k), ylim = ylim_SSB) +
      ggplot2::theme_minimal() +
      ggplot2::labs(title = paste0("SSB SP; Bmsy/K=", round(est_SSB$shape, 2)), x = "SSB", y = "Surplus production")

    p_pe=ggplot2::ggplot(pe_long, ggplot2::aes(x = year, y = value, color = series)) +
      ggplot2::geom_line(linewidth = 1.1) +
      ggplot2::geom_hline(yintercept = 0, linetype = 2) +
      ggplot2::coord_cartesian(ylim = ylim_PE) +
      ggplot2::theme_minimal() +
      ggplot2::scale_color_manual(values = c("Reference PE (pf)" = "orange", "Biomass PT PE" = ptColB, "SSB PT PE" = ptColSsb)) +
      ggplot2::labs(
        title = "Process error (reference vs PT)",
        x = "Year",
        y = processErrorLabel(pe_mode),
        color = NULL
      )

    if (requireNamespace("patchwork", quietly = TRUE)) {
      print((p_bio | p_ssb) / p_pe)
    } else {
      print(p_bio); print(p_ssb); print(p_pe)
    }
  }

  pars_df=data.frame(
    space = c("biomass", "ssb"),
    r = c(est_B$r, est_SSB$r),
    K = c(est_B$k, est_SSB$k),
    p = c(est_B$p, est_SSB$p),
    Bmsy = c(est_B$bmsy, est_SSB$bmsy),
    MSY = c(est_B$msy, est_SSB$msy),
    BmsyK = c(est_B$shape, est_SSB$shape),
    stringsAsFactors = FALSE
  )
  pe_df=data.frame(year = yr_t, pe_ref = pe_ref, pe_from_pf = pe_from_pf, pe_B_PT = eps_B_PT, pe_SSB_PT = eps_SSB_PT)

  invisible(list(
    pars = pars_df,
    pe = pe_df,
    diagnostics = list(
      curve_cor = curve_cor,
      curve_rmse = curve_rmse,
      curve_rel_rmse = curve_rel_rmse,
      pe_cor_ssb = pe_cor_ssb,
      pe_cor_biomass = pe_cor_bio,
      pe_rmse_ssb = pe_rmse_ssb,
      pe_rmse_biomass = pe_rmse_bio,
      likely_misspecified = misspec_flag
    ),
    biomass = list(fit = fit_B, observed = data.frame(year = yr_t, biomass = B_t, sp = SP_B, pe_pt = eps_B_PT), curve = data.frame(biomass = B_grid, pt = PT_B_grid)),
    ssb = list(fit = fit_SSB, observed = data.frame(year = yr_t, ssb = SSB_t, sp = SP_SSB, pe_pt = eps_SSB_PT), curve = data.frame(ssb = SSB_grid, pt = PT_SSB_grid))
  ))
}

#' Surplus-production and PE comparison from SS3 model output
#'
#' S4 generic wrapper around [ssPeCompare()]. For `character` input,
#' `x` is interpreted as an SS3 directory and `curveSS()` is used to build the
#' required time-series and equilibrium objects.
#'
#' @param x Either an SS3 directory (`character`) or a `list` with elements
#'   `tseries` and `curve`.
#' @param ... Additional arguments passed to [ssPeCompare()].
#' @return The same list returned by [ssPeCompare()].
#' @export
setGeneric("ssPe", function(x, ...) methods::standardGeneric("ssPe"))

#' @rdname ssPe
#' @export
setMethod("ssPe", signature(x = "character"), function(x, ...) {
  cs=curveSS(x)
  ssPeCompare(tseries = cs$tseries, eqlYield = cs$curve, ...)
})

#' @rdname ssPe
#' @export
setMethod("ssPe", signature(x = "list"), function(x, ...) {
  if (is.null(x$tseries) || is.null(x$curve)) stop("list input must contain 'tseries' and 'curve'")
  ssPeCompare(tseries = x$tseries, eqlYield = x$curve, ...)
})

#' Fast diagnostics-only SS PE generic
#'
#' Returns only the `diagnostics` component from [ssPe()].
#'
#' @param x Either an SS3 directory (`character`) or a `list` with `tseries`
#'   and `curve`.
#' @param ... Additional arguments passed to [ssPe()].
#' @return Named list of diagnostics metrics.
#' @export
setGeneric("ssPeDiagnose", function(x, ...) methods::standardGeneric("ssPeDiagnose"))

#' @rdname ssPeDiagnose
#' @export
setMethod("ssPeDiagnose", signature(x = "character"), function(x, ...) {
  ssPe(x, ...)$diagnostics
})

#' @rdname ssPeDiagnose
#' @export
setMethod("ssPeDiagnose", signature(x = "list"), function(x, ...) {
  ssPe(x, ...)$diagnostics
})


