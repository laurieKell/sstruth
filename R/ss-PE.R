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
  eps_B_PT=log(pmax(B_t1, .Machine$double.eps)) - log(pmax(Bpred_PT, .Machine$double.eps))
  eps_SSB_PT=log(pmax(SSB_t1, .Machine$double.eps)) - log(pmax(SSBpred_PT, .Machine$double.eps))

  pf_t=tseries$pf[-length(tseries$pf)]
  SSB_t0=tseries$ssb[-length(tseries$ssb)]
  SSB_t1_0=tseries$ssb[-1]
  C_t0=tseries$yield[-length(tseries$yield)]
  pe_from_pf=log(pmax(SSB_t1_0, .Machine$double.eps)) - log(pmax(SSB_t0 - C_t0 + pf_t, .Machine$double.eps))
  pe_ref=if (!is.null(tseries$pe)) tail(tseries$pe, -1) else pe_from_pf

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
    if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Package 'ggplot2' is required when makePlots = TRUE")
    ylim_B=c(0, max(c(SP_B[SP_B >= 0], PT_B_grid_plot), na.rm = TRUE) * 1.05)
    ylim_SSB=c(0, max(c(SP_SSB[SP_SSB >= 0], eq_SP[eq_keep], PT_SSB_grid_plot), na.rm = TRUE) * 1.05)
    ylim_PE=range(c(eps_B_PT, eps_SSB_PT, pe_ref), na.rm = TRUE)
    if (!all(is.finite(ylim_PE))) ylim_PE=c(-1, 1)

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
      ggplot2::labs(title = "Process error (reference vs PT)", x = "Year", y = "Log process error", color = NULL)

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
setGeneric("ssPe", function(x, ...) standardGeneric("ssPe"))

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
setGeneric("ssPeDiagnose", function(x, ...) standardGeneric("ssPeDiagnose"))

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

