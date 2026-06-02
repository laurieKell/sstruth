#' Resolve run / scenario column in combined \code{ssCurve} output
#' @param pe Combined list from \code{\link{ssCurve}}.
#' @param run_col Optional column name.
#' @noRd
.ssCurveRunCol <- function(pe, run_col = NULL) {
  if (!is.null(run_col) && nzchar(run_col)) {
    return(run_col)
  }
  for (nm in c("run", "id")) {
    if (nm %in% names(pe$curve) || nm %in% names(pe$tseries)) {
      return(nm)
    }
  }
  NULL
}

#' @noRd
.ssMergeRefpts <- function(df, refpts, run_col) {
  if (is.null(refpts) || !NROW(refpts)) {
    return(df)
  }
  by <- intersect(run_col, intersect(names(df), names(refpts)))
  if (length(by)) {
    out <- merge(df, refpts, by = by, suffixes = c("", ".ref"), all.x = TRUE)
    if ("bmsy.ref" %in% names(out) && !"bmsy" %in% names(out)) {
      out$bmsy <- out$bmsy.ref
    }
    if ("msy.ref" %in% names(out) && !"msy" %in% names(out)) {
      out$msy <- out$msy.ref
    }
    return(out)
  }
  if (NROW(refpts) == 1L) {
    return(cbind(df, refpts[rep(1L, NROW(df)), , drop = FALSE]))
  }
  df
}

#' Kobe phase plot from \code{\link{ssKobe}} trajectories
#'
#' Facets by run / scenario when multiple stocks are bound.
#'
#' @param kobe Data frame from \code{\link{ssKobe}} (\code{year}, \code{stock},
#'   \code{harvest}, plus run id column).
#' @param run_col Run id column (default \code{"run"}).
#' @param xlim,ylim Axis limits in B/BMSY and F/FMSY space.
#' @param title Plot title.
#' @param show_equilibrium Overlay equilibrium \eqn{F/F_\mathrm{MSY}}{F/FMSY} vs
#'   \eqn{B/B_\mathrm{MSY}}{B/BMSY} locus from \code{ssCurve} when \code{pe} is supplied.
#' @param pe Optional combined \code{\link{ssCurve}} object for equilibrium curve.
#' @param equilibrium_colour Line colour for the equilibrium locus.
#' @param equilibrium_linewidth Line width for the equilibrium locus.
#' @param equilibrium_linetype Line type for the equilibrium locus.
#' @param show_msy Mark \eqn{F/F_\mathrm{MSY} = B/B_\mathrm{MSY} = 1}{MSY} on the plot.
#' @param ... Passed to \code{kobe::kobePhase()}.
#' @return A \code{ggplot} object.
#' @export
plotSsKobePhase <- function(
  kobe,
  run_col = "run",
  xlim = c(0, 2),
  ylim = c(0, 2),
  title = "Kobe phase plot",
  show_equilibrium = TRUE,
  pe = NULL,
  equilibrium_colour = "steelblue",
  equilibrium_linewidth = 0.9,
  equilibrium_linetype = "solid",
  show_msy = TRUE,
  ...
) {
  if (!is.data.frame(kobe) || !NROW(kobe)) {
    stop("kobe must be a non-empty data frame.", call. = FALSE)
  }
  if (!all(c("year", "stock", "harvest") %in% names(kobe))) {
    stop("kobe must contain year, stock, and harvest columns.", call. = FALSE)
  }
  if (!requireNamespace("kobe", quietly = TRUE)) {
    stop("Package 'kobe' is required for plotSsKobePhase().", call. = FALSE)
  }
  traj <- kobe[
    is.finite(kobe$stock) & is.finite(kobe$harvest) & is.finite(kobe$year),
    ,
    drop = FALSE
  ]
  if (!NROW(traj)) {
    stop("No finite Kobe trajectories to plot.", call. = FALSE)
  }
  if (!run_col %in% names(traj)) {
    run_col <- intersect(c("run", "id", "scenario"), names(traj))[1]
  }
  facet <- if (!is.null(run_col) && run_col %in% names(traj) &&
      length(unique(traj[[run_col]])) > 1L) {
    run_col
  } else {
    NULL
  }
  phase_args <- list(object = traj[, c("stock", "harvest", "year"), drop = FALSE])
  if (!is.null(xlim) && length(xlim) == 2L) {
    phase_args$xlim <- xlim
  }
  if (!is.null(ylim) && length(ylim) == 2L) {
    phase_args$ylim <- ylim
  }
  p <- do.call(kobe::kobePhase, c(phase_args, list(...)))

  if (!is.null(facet)) {
    p <- p + ggplot2::facet_wrap(
      stats::as.formula(paste("~", facet)),
      scales = "fixed",
      ncol = min(3L, length(unique(traj[[facet]])))
    )
  }

  traj$.group <- if (!is.null(facet)) traj[[facet]] else seq_len(NROW(traj))
  p <- p +
    ggplot2::geom_path(
      data = traj,
      ggplot2::aes(x = stock, y = harvest, group = .group),
      colour = "grey25",
      linewidth = 0.8,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_point(
      data = traj,
      ggplot2::aes(x = stock, y = harvest, colour = year),
      size = 1.5,
      inherit.aes = FALSE
    ) +
    ggplot2::scale_color_viridis_c(name = "Year", option = "C")

  if (isTRUE(show_equilibrium) && !is.null(pe)) {
    eq <- ssKobeEquilibrium(pe, run_col = run_col %||% .ssCurveRunCol(pe))
    if (!is.null(eq) && NROW(eq)) {
      if (!is.null(facet) && facet %in% names(eq)) {
        eq$.eq_group <- eq[[facet]]
      } else {
        eq$.eq_group <- "."
      }
      eq$locus <- "Equilibrium"
      p <- p + ggplot2::geom_path(
        data = eq,
        ggplot2::aes(
          x = stock,
          y = harvest,
          group = .eq_group,
          linetype = locus
        ),
        colour = equilibrium_colour,
        linewidth = equilibrium_linewidth,
        inherit.aes = FALSE
      ) +
        ggplot2::scale_linetype_manual(
          name = NULL,
          values = c(Equilibrium = equilibrium_linetype),
          breaks = "Equilibrium"
        )
      if (isTRUE(show_msy)) {
        msy_pt <- .ssKobeMsyPoints(pe, run_col = run_col, facet = facet)
        if (!is.null(msy_pt) && NROW(msy_pt)) {
          p <- p + ggplot2::geom_point(
            data = msy_pt,
            ggplot2::aes(x = stock, y = harvest),
            shape = 21,
            fill = "white",
            colour = equilibrium_colour,
            size = 2.8,
            inherit.aes = FALSE
          )
        }
      }
    }
  }

  if (!is.null(title) && nzchar(title)) {
    p <- p + ggplot2::labs(title = title)
  }
  p
}

#' @noRd
.ssKobeEquilibriumHarvest <- function(df) {
  if ("ffmsy" %in% names(df) && any(is.finite(df$ffmsy))) {
    return(df$ffmsy)
  }
  if (all(c("F", "fmsy") %in% names(df)) && any(is.finite(df$fmsy) & df$fmsy > 0)) {
    h <- df$F / df$fmsy
    if (any(is.finite(h))) {
      return(h)
    }
  }
  df$yield / df$ssb / (df$msy / df$bmsy)
}

#' @noRd
.ssKobeFillRefpts <- function(df, split_cols = character(0)) {
  fill_one <- function(x) {
    msy <- x$msy[1L]
    bmsy <- x$bmsy[1L]
    if (!is.finite(msy) || msy <= 0) {
      ok <- is.finite(x$yield) & is.finite(x$ssb)
      if (any(ok)) {
        ix <- which.max(x$yield[ok])
        idx <- which(ok)[ix]
        msy <- x$yield[idx]
        if (!is.finite(bmsy) || bmsy <= 0) {
          bmsy <- x$ssb[idx]
        }
      }
    }
    if (!is.finite(bmsy) || bmsy <= 0) {
      ok <- is.finite(x$ssb) & x$ssb > 0
      if (any(ok)) {
        bmsy <- max(x$ssb[ok], na.rm = TRUE)
      }
    }
    x$msy <- msy
    x$bmsy <- bmsy
    x
  }
  split_cols <- intersect(split_cols, names(df))
  if (length(split_cols)) {
    parts <- split(df, interaction(df[split_cols], drop = TRUE), drop = TRUE)
    df <- do.call(rbind, lapply(parts, fill_one))
    rownames(df) <- NULL
  } else {
    df <- fill_one(df)
  }
  df
}

#' @noRd
.ssKobeMsyPoints <- function(pe, run_col = NULL, facet = NULL) {
  rf <- pe$refpts
  if (is.null(rf) || !NROW(rf)) {
    return(NULL)
  }
  facet <- facet %||% run_col
  if (!is.null(facet) && facet %in% names(rf)) {
    msy_pt <- unique(rf[, facet, drop = FALSE])
  } else {
    msy_pt <- data.frame(row = 1L)
  }
  msy_pt$stock <- 1
  msy_pt$harvest <- 1
  msy_pt
}

#' Equilibrium locus in Kobe space (\eqn{F/F_\mathrm{MSY}}{F/FMSY} vs \eqn{B/B_\mathrm{MSY}}{B/BMSY})
#'
#' Maps the SS3 equilibrium yield curve (\code{pe$curve}) into Kobe coordinates using
#' reference points (\code{pe$refpts}).
#'
#' @param pe Combined \code{\link{ssCurve}} / \code{\link{curveSS}} object.
#' @param run_col Run / scenario column for grouping (default from \code{pe}).
#' @return Data frame with \code{stock}, \code{harvest}, and grouping columns; \code{NULL} if unavailable.
#' @export
ssKobeEquilibrium <- function(pe, run_col = NULL) {
  .ssKobeEquilibriumDf(pe, run_col = run_col)
}

#' @noRd
.ssKobeEquilibriumDf <- function(pe, run_col = NULL) {
  run_col <- .ssCurveRunCol(pe, run_col)
  crv <- pe$curve
  rf <- pe$refpts
  if (is.null(crv) || !NROW(crv) || is.null(rf) || !NROW(rf)) {
    return(NULL)
  }
  if (!all(c("ssb", "yield") %in% names(crv))) {
    return(NULL)
  }
  df <- .ssMergeRefpts(crv, rf, run_col)
  split_cols <- if (!is.null(run_col) && run_col %in% names(df)) {
    run_col
  } else {
    character(0)
  }
  df <- .ssKobeFillRefpts(df, split_cols = split_cols)
  if (!all(c("bmsy", "msy") %in% names(df))) {
    return(NULL)
  }
  ok <- is.finite(df$ssb) & df$ssb > 0 & is.finite(df$yield) &
    is.finite(df$bmsy) & df$bmsy > 0 & is.finite(df$msy) & df$msy > 0
  df <- df[ok, , drop = FALSE]
  if (!NROW(df)) {
    return(NULL)
  }
  df$stock <- df$ssb / df$bmsy
  df$harvest <- .ssKobeEquilibriumHarvest(df)
  if (!is.null(run_col) && run_col %in% names(df)) {
    df$.eq_group <- df[[run_col]]
    ord <- c(run_col, "stock")
  } else {
    df$.eq_group <- "."
    ord <- "stock"
  }
  df <- df[is.finite(df$stock) & is.finite(df$harvest), , drop = FALSE]
  if (!NROW(df)) {
    return(NULL)
  }
  df[do.call(order, df[ord]), , drop = FALSE]
}

#' Equilibrium production function (yield vs SSB) from \code{\link{ssCurve}}
#'
#' @param pe Combined list from \code{\link{ssCurve}}.
#' @param run_col Run / scenario id column. When present and \code{facet = FALSE}
#'   (default), scenarios are distinguished by \code{colour}; when \code{facet = TRUE},
#'   one panel per scenario.
#' @param title Plot title.
#' @param facet If \code{TRUE}, facet by \code{run_col}; if \code{FALSE}, overlay
#'   scenarios in one panel with \code{colour = run_col}.
#' @param colour_label Legend title for scenario colour (default: \code{run_col}).
#' @return A \code{ggplot} object.
#' @export
plotSsCurveProduction <- function(
  pe,
  run_col = NULL,
  title = "Production function (equilibrium yield vs SSB)",
  facet = FALSE,
  colour_label = NULL
) {
  if (is.null(pe$curve) || !NROW(pe$curve)) {
    stop("pe$curve is empty.", call. = FALSE)
  }
  run_col <- .ssCurveRunCol(pe, run_col)
  crv <- pe$curve
  rf <- pe$refpts
  has_run <- !is.null(run_col) && run_col %in% names(crv)
  use_facet <- isTRUE(facet) && has_run
  use_colour <- !use_facet && has_run

  if (use_colour) {
    p <- ggplot2::ggplot(
      crv,
      ggplot2::aes(
        x = ssb,
        y = yield,
        colour = .data[[run_col]],
        group = .data[[run_col]]
      )
    ) +
      ggplot2::geom_line(linewidth = 0.8)
  } else {
    p <- ggplot2::ggplot(crv, ggplot2::aes(x = ssb, y = yield)) +
      ggplot2::geom_line(linewidth = 0.8, colour = "steelblue")
    if (use_facet) {
      p <- p + ggplot2::facet_wrap(
        stats::as.formula(paste("~", run_col)),
        scales = "free"
      )
    }
  }

  if (!is.null(rf) && NROW(rf) && all(c("bmsy", "msy") %in% names(rf))) {
    msy_pts <- rf[is.finite(rf$bmsy) & is.finite(rf$msy), , drop = FALSE]
    if (NROW(msy_pts)) {
      if (use_colour && run_col %in% names(msy_pts)) {
        p <- p + ggplot2::geom_point(
          data = msy_pts,
          ggplot2::aes(
            x = bmsy,
            y = msy,
            colour = .data[[run_col]]
          ),
          shape = 21,
          fill = "white",
          size = 2.5,
          inherit.aes = FALSE
        )
      } else {
        p <- p + ggplot2::geom_point(
          ggplot2::aes(x = bmsy, y = msy),
          data = msy_pts,
          shape = 21,
          fill = "white",
          size = 2.5,
          inherit.aes = FALSE
        )
      }
    }
  }

  if (use_colour) {
    p <- p + ggplot2::labs(colour = colour_label %||% run_col)
  }
  p +
    ggplot2::labs(title = title, x = "SSB", y = "Equilibrium yield") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(legend.position = "bottom")
}

#' Observed yield vs SSB trajectories on the equilibrium curve
#'
#' @inheritParams plotSsCurveProduction
#' @export
plotSsCurveYieldTrajectory <- function(
  pe,
  run_col = NULL,
  title = "Yield vs SSB trajectory on production function"
) {
  if (is.null(pe$tseries) || !NROW(pe$tseries)) {
    stop("pe$tseries is empty.", call. = FALSE)
  }
  run_col <- .ssCurveRunCol(pe, run_col)
  traj <- pe$tseries
  req <- c("year", "ssb", "yield")
  if (!all(req %in% names(traj))) {
    stop("pe$tseries must contain year, ssb, and yield.", call. = FALSE)
  }
  traj <- traj[
    is.finite(traj$ssb) & is.finite(traj$yield) & is.finite(traj$year),
    ,
    drop = FALSE
  ]
  p <- plotSsCurveProduction(pe, run_col = run_col, title = title, facet = TRUE)
  grp <- if (!is.null(run_col) && run_col %in% names(traj)) {
    traj[[run_col]]
  } else {
    seq_len(NROW(traj))
  }
  p +
    ggplot2::geom_path(
      data = traj,
      ggplot2::aes(x = ssb, y = yield, group = grp, colour = year),
      linewidth = 0.5,
      alpha = 0.85,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_point(
      data = traj,
      ggplot2::aes(x = ssb, y = yield, colour = year),
      size = 1.6,
      alpha = 0.75,
      inherit.aes = FALSE
    ) +
    ggplot2::scale_color_viridis_c(name = "Year", option = "C") +
    ggplot2::theme(legend.position = "bottom")
}

#' Empirical surplus production vs SSB from \code{\link{ssCurve}} time series
#'
#' Uses \code{sp_ssb} by default (spawning-biomass surplus production). Pass
#' \code{sp_col = "sprod"} to match \code{r4ss::SSplotYield()} subplot 4
#' (\code{yield4_surplus_production.png}): total-biomass surplus production
#' plotted against spawning biomass.
#'
#' @inheritParams plotSsCurveProduction
#' @param sp_col Surplus-production column (\code{"sp_ssb"} or \code{"sprod"}).
#' @param show_production Overlay equilibrium yield vs SSB from \code{pe$curve}.
#' @export
plotSsCurveSpSsb <- function(
  pe,
  run_col = NULL,
  sp_col = NULL,
  title = NULL,
  facet = FALSE,
  show_production = TRUE,
  colour_label = NULL
) {
  if (is.null(pe$tseries) || !NROW(pe$tseries)) {
    stop("pe$tseries is empty.", call. = FALSE)
  }
  run_col <- .ssCurveRunCol(pe, run_col)
  ts <- pe$tseries
  sp_col <- sp_col %||% curveSsProductionCol(ts, type = "ssb") %||% "sp_ssb"
  if (is.null(title)) {
    title <- if (identical(sp_col, "sprod") || identical(sp_col, "P_obs")) {
      "Surplus production vs SSB (SS3 total-biomass SP)"
    } else {
      "Surplus production vs SSB (SSB-based SP)"
    }
  }
  if (!sp_col %in% names(ts)) {
    stop("Column ", sp_col, " not found in pe$tseries.", call. = FALSE)
  }
  df <- ts[
    is.finite(ts$ssb) & is.finite(ts[[sp_col]]) & is.finite(ts$year),
    ,
    drop = FALSE
  ]
  if (!NROW(df)) {
    stop("No finite surplus-production rows.", call. = FALSE)
  }
  has_run <- !is.null(run_col) && run_col %in% names(df)
  use_facet <- isTRUE(facet) && has_run
  use_colour <- !use_facet && has_run

  if (use_colour) {
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = ssb,
        y = .data[[sp_col]],
        colour = .data[[run_col]],
        group = .data[[run_col]]
      )
    )
  } else {
    p <- ggplot2::ggplot(df, ggplot2::aes(x = ssb, y = .data[[sp_col]]))
  }

  p <- p + ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50")

  if (use_colour) {
    p <- p +
      ggplot2::geom_path(linewidth = 0.4, alpha = 0.7) +
      ggplot2::geom_point(size = 1.8, alpha = 0.75)
  } else {
    p <- p +
      ggplot2::geom_path(linewidth = 0.4, alpha = 0.7) +
      ggplot2::geom_point(ggplot2::aes(colour = year), size = 1.8, alpha = 0.75) +
      ggplot2::scale_color_viridis_c(name = "Year", option = "C")
  }

  if (isTRUE(show_production) && !is.null(pe$curve) && NROW(pe$curve)) {
    crv <- pe$curve[
      is.finite(pe$curve$ssb) &
        is.finite(pe$curve$yield) &
        pe$curve$yield > 0,
      ,
      drop = FALSE
    ]
    if (NROW(crv)) {
      if (use_colour && run_col %in% names(crv)) {
        p <- p +
          ggplot2::geom_line(
            data = crv,
            ggplot2::aes(
              x = ssb,
              y = yield,
              colour = .data[[run_col]],
              group = .data[[run_col]]
            ),
            linewidth = 0.9,
            inherit.aes = FALSE
          )
      } else {
        p <- p +
          ggplot2::geom_line(
            data = crv,
            ggplot2::aes(x = ssb, y = yield),
            colour = "steelblue",
            linewidth = 0.9,
            inherit.aes = FALSE
          )
      }
    }
  }

  if (use_facet) {
    p <- p + ggplot2::facet_wrap(
      stats::as.formula(paste("~", run_col)),
      scales = "free"
    )
  }
  if (use_colour) {
    p <- p + ggplot2::labs(colour = colour_label %||% run_col)
  }
  p +
    ggplot2::labs(title = title, x = "SSB", y = "Surplus production") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(legend.position = "bottom")
}

#' Compare SS3 and SSB surplus-production plots side by side
#'
#' Left panel matches \code{r4ss::SSplotYield()} subplot 4
#' (\code{sprod} vs SSB). Right panel uses SSB-based surplus production
#' (\code{sp_ssb} vs SSB).
#'
#' @inheritParams plotSsCurveSpSsb
#' @return A \pkg{patchwork} object when available, otherwise a list of ggplot objects.
#' @export
plotSsCurveSpCompare <- function(
  pe,
  run_col = NULL,
  facet = FALSE,
  show_production = TRUE,
  colour_label = NULL
) {
  p_ss3 <- plotSsCurveSpSsb(
    pe,
    run_col = run_col,
    sp_col = "sprod",
    title = "SS3 total-biomass SP vs SSB",
    facet = facet,
    show_production = show_production,
    colour_label = colour_label
  )
  p_ssb <- plotSsCurveSpSsb(
    pe,
    run_col = run_col,
    sp_col = "sp_ssb",
    title = "SSB-based SP vs SSB",
    facet = facet,
    show_production = show_production,
    colour_label = colour_label
  )
  if (requireNamespace("patchwork", quietly = TRUE)) {
    return(p_ss3 | p_ssb)
  }
  list(ss3 = p_ss3, ssb = p_ssb)
}

#' Process-error diagnostic panel for one \code{curveSS} object
#'
#' Wrapper around \code{\link{ssPeCompare}} returning the SSB surplus-production
#' and process-error ggplot panels (no printing).
#'
#' @param pe \code{curveSS} list or run directory.
#' @param shapePt Pella-Tomlinson \eqn{B_{MSY}/K}{Bmsy/K} shape (default 0.5).
#' @param pe_mode Process-error scale: \code{"log"}, \code{"relative"} \eqn{(y-x)/x},
#'   or \code{"diff"} \eqn{y-x}.
#' @param ... Passed to \code{\link{ssPeCompare}}.
#' @return List with \code{ssb}, \code{pe}, \code{time}, \code{fit}, \code{acf},
#'   \code{hist} ggplot objects (when available), plus \code{diagnostics}.
#' @export
plotSsPeDiagnostic <- function(
  pe,
  shapePt = 0.5,
  pe_mode = c("relative", "diff", "log"),
  ...
) {
  if (is.character(pe) && length(pe) == 1L) {
    pe <- curveSS(pe)
  }
  if (is.null(pe$tseries) || is.null(pe$curve)) {
    stop("pe must contain tseries and curve.", call. = FALSE)
  }
  pe_mode <- processErrorMode(pe_mode)
  res <- ssPeCompare(
    tseries = pe$tseries,
    eqlYield = pe$curve,
    shapePt = shapePt,
    pe_mode = pe_mode,
    makePlots = FALSE,
    ...
  )
  obs <- res$ssb$observed
  crv_eq <- data.frame(ssb = pe$curve$ssb, yield = pe$curve$yield)
  crv_pt <- res$ssb$curve
  p_ssb <- ggplot2::ggplot(obs, ggplot2::aes(x = ssb, y = sp)) +
    ggplot2::geom_point(colour = "grey40") +
    ggplot2::geom_path(linewidth = 0.25, colour = "grey40") +
    ggplot2::geom_line(
      data = crv_eq,
      ggplot2::aes(x = ssb, y = yield),
      colour = "orange",
      linewidth = 0.9
    ) +
    ggplot2::geom_line(
      data = crv_pt,
      ggplot2::aes(x = ssb, y = pt),
      colour = "red",
      linewidth = 0.9
    ) +
    ggplot2::geom_hline(yintercept = 0, linetype = 3) +
    ggplot2::labs(
      title = "SSB surplus production vs PT fit",
      x = "SSB",
      y = "Surplus production"
    ) +
    ggplot2::theme_minimal()
  pe_long <- rbind(
    data.frame(year = res$pe$year, series = "Reference PE", value = res$pe$pe_ref),
    data.frame(year = res$pe$year, series = "SSB PT PE", value = res$pe$pe_SSB_PT)
  )
  pe_long$series <- factor(pe_long$series, levels = c("Reference PE", "SSB PT PE"))
  ylim_pe <- .pePlotLimits(pe_long$value)
  p_pe <- ggplot2::ggplot(pe_long, ggplot2::aes(x = year, y = value, colour = series)) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2) +
    ggplot2::coord_cartesian(ylim = ylim_pe) +
    ggplot2::scale_color_manual(values = c("Reference PE" = "orange", "SSB PT PE" = "red")) +
    ggplot2::labs(
      title = "Process error",
      x = "Year",
      y = processErrorLabel(pe_mode),
      colour = NULL
    ) +
    ggplot2::theme_minimal()
  four <- plotSsPeFourPanel(pe, pe_mode = pe_mode, ylim = ylim_pe)
  list(
    ssb = p_ssb,
    pe = p_pe,
    diagnostics = res$diagnostics,
    time = four$time,
    fit = four$fit,
    acf = four$acf,
    hist = four$hist,
    panel = four$panel
  )
}

#' Four-panel process-error diagnostics from \code{curveSS}
#'
#' Time series, residual vs SSB, ACF, and histogram of process residuals.
#'
#' @param pe Combined \code{curveSS} object or run directory.
#' @param pe_mode Process-error scale (\code{\link{processErrorMode}}).
#' @param ylim Optional shared y/x limits for residual panels.
#' @param run_col Scenario column when \code{pe} contains multiple runs.
#' @return A \code{patchwork} object when available; otherwise a list of ggplots.
#' @export
plotSsPeFourPanel <- function(
  pe,
  pe_mode = c("relative", "diff", "log"),
  ylim = NULL,
  run_col = NULL
) {
  if (is.character(pe) && length(pe) == 1L) {
    pe <- curveSS(pe)
  }
  if (is.null(pe$tseries) || !NROW(pe$tseries)) {
    stop("pe$tseries is empty.", call. = FALSE)
  }
  pe_mode <- processErrorMode(pe_mode)
  ts <- peResidualTseries(pe, pe_mode)
  ylab <- processErrorLabel(pe_mode)
  ylim <- .pePlotLimits(ts$pe_resid, ylim = ylim)
  has_id <- "id" %in% names(ts) && length(unique(ts$id)) > 1L
  facet_id <- if (has_id) ggplot2::facet_grid(. ~ id, scales = "free") else NULL

  p_time <- ggplot2::ggplot(ts, ggplot2::aes(x = year, y = pe_resid)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey60") +
    ggplot2::geom_line(colour = "steelblue", linewidth = 0.7) +
    ggplot2::geom_point(colour = "steelblue", size = 1.2) +
    ggplot2::coord_cartesian(ylim = ylim) +
    ggplot2::labs(x = "Year", y = ylab, title = "Process error through time") +
    ggplot2::theme_minimal()
  if (!is.null(facet_id)) {
    p_time <- p_time + facet_id
  }

  p_fit <- ggplot2::ggplot(ts, ggplot2::aes(x = ssb, y = pe_resid)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey60") +
    ggplot2::geom_point(alpha = 0.6, colour = "steelblue", size = 1.4) +
    ggplot2::geom_smooth(se = FALSE, colour = "darkorange", linewidth = 0.8) +
    ggplot2::coord_cartesian(ylim = ylim) +
    ggplot2::labs(x = "SSB", y = ylab, title = "Process error vs SSB") +
    ggplot2::theme_minimal()
  if (!is.null(pe$refpts) && NROW(pe$refpts) && "bmsy" %in% names(pe$refpts)) {
    p_fit <- p_fit +
      ggplot2::geom_vline(
        data = pe$refpts,
        ggplot2::aes(xintercept = bmsy),
        colour = "red",
        linetype = 2,
        inherit.aes = FALSE
      )
  }
  if (!is.null(facet_id)) {
    p_fit <- p_fit + facet_id
  }

  ts_f <- ts[is.finite(ts$pe_resid), , drop = FALSE]
  if (has_id) {
    acf_df <- do.call(
      rbind,
      lapply(split(ts_f, ts_f$id, drop = TRUE), function(z) {
        if (sum(is.finite(z$pe_resid)) < 5L) {
          return(NULL)
        }
        ac <- stats::acf(z$pe_resid, lag.max = min(25L, NROW(z) - 1L), plot = FALSE)
        data.frame(
          id = z$id[1L],
          lag = as.integer(ac$lag[, 1, 1]),
          acf = as.numeric(ac$acf[, 1, 1]),
          stringsAsFactors = FALSE
        )
      })
    )
  } else {
    ac <- stats::acf(
      ts_f$pe_resid,
      lag.max = min(25L, NROW(ts_f) - 1L),
      plot = FALSE
    )
    acf_df <- data.frame(
      lag = as.integer(ac$lag[, 1, 1]),
      acf = as.numeric(ac$acf[, 1, 1]),
      stringsAsFactors = FALSE
    )
  }
  p_acf <- ggplot2::ggplot(acf_df, ggplot2::aes(x = lag, y = acf)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey60") +
    ggplot2::geom_col(fill = "steelblue") +
    ggplot2::labs(x = "Lag", y = "ACF", title = "Residual ACF") +
    ggplot2::theme_minimal()
  if (has_id && "id" %in% names(acf_df)) {
    p_acf <- p_acf + ggplot2::facet_grid(. ~ id, scales = "free")
  }

  p_hist <- ggplot2::ggplot(ts_f, ggplot2::aes(x = pe_resid)) +
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(density)),
      bins = 30L,
      fill = "steelblue",
      colour = "white",
      alpha = 0.7
    ) +
    ggplot2::geom_vline(xintercept = 0, colour = "red", linetype = 2) +
    ggplot2::labs(x = ylab, y = "Density", title = "Residual distribution") +
    ggplot2::theme_minimal() +
    ggplot2::coord_cartesian(xlim = ylim)
  if (has_id) {
    p_hist <- p_hist + ggplot2::facet_grid(. ~ id, scales = "free")
  }

  out <- list(time = p_time, fit = p_fit, acf = p_acf, hist = p_hist)
  if (requireNamespace("patchwork", quietly = TRUE)) {
    out$panel <- out$time / out$fit / out$acf / out$hist +
      patchwork::plot_layout(heights = c(1.2, 1.2, 0.9, 0.9))
  } else {
    out$panel <- out$time
  }
  out
}
