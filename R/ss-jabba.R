library(methods)
utils::globalVariables(c("year", "value", "series", "metric", "stock", "B_Bmsy", "group"))

#' Read SS3 truth object via ss3om
#'
#' @param x SS3 directory path.
#' @param ... Additional arguments passed to `ss3om::readFLSss3()`.
#' @return FLR-compatible truth object.
#' @export
setGeneric("readTruth", function(x, ...) standardGeneric("readTruth"))

#' @rdname readTruth
#' @export
setMethod("readTruth", signature(x = "character"), function(x, ...) {
  ss3om::readFLSss3(x, ...)
})

#' Convert SS object to standardized truth table
#'
#' @param x SS truth object.
#' @param ... Reserved for future method-specific options.
#' @return Data frame with `year`, `catch`, `stock`, and `ssb`.
#' @export
setGeneric("asTruth", function(x, ...) standardGeneric("asTruth"))

#' @rdname asTruth
#' @export
setMethod("asTruth", signature(x = "list"), function(x, ...) {
  ts=x$tseries %||% x$timeseries
  if (is.null(ts) || !is.data.frame(ts)) stop("Could not find time-series data in input object.")

  yearCol=resolveCol(ts, c("year", "yr"))
  catchCol=resolveCol(ts, c("yield", "catch", "totcatch"))
  stockCol=resolveCol(ts, c("biomass", "stock"))
  ssbCol=resolveCol(ts, c("ssb", "spawnbio"))

  req=c(yearCol, catchCol, stockCol, ssbCol)
  if (any(is.na(req))) stop("Missing required truth columns in time-series object.")

  out=data.frame(
    year = as.numeric(ts[[yearCol]]),
    catch = as.numeric(ts[[catchCol]]),
    stock = as.numeric(ts[[stockCol]]),
    ssb = as.numeric(ts[[ssbCol]]),
    stringsAsFactors = FALSE
  )
  out[is.finite(out$year), , drop = FALSE]
})

#' @rdname asTruth
#' @export
setMethod("asTruth", signature(x = "ANY"), function(x, ...) {
  flqYearSum<-function(z) {
    if (is.null(z)) return(NULL)
    arr=as.array(z)
    dm=dimnames(arr)
    yrs=dm$year %||% if (length(dm) >= 2) dm[[2]] else NULL
    if (is.null(yrs)) return(NULL)
    vals=apply(arr, 2, sum, na.rm = TRUE)
    data.frame(year = as.numeric(yrs), value = as.numeric(vals), stringsAsFactors = FALSE)
  }

  if (isS4(x) && methods::is(x, "FLStock")) {
    nms=methods::slotNames(x)
    catchObj=if ("catch" %in% nms) methods::slot(x, "catch") else NULL
    stockObj=if ("stock" %in% nms) methods::slot(x, "stock") else NULL
    ssbObj=NULL
    if ("mat" %in% nms && !is.null(stockObj)) {
      ssbObj=try(stockObj * methods::slot(x, "mat"), silent = TRUE)
      if (inherits(ssbObj, "try-error")) ssbObj=NULL
    }

    catchDf=flqYearSum(catchObj)
    stockDf=flqYearSum(stockObj)
    ssbDf=flqYearSum(ssbObj)

    if (is.null(catchDf) || is.null(stockDf)) {
      stop("Could not extract yearly catch/stock from FLStock object.")
    }
    out=merge(catchDf, stockDf, by = "year", all = TRUE, sort = TRUE)
    names(out)[2:3]=c("catch", "stock")
    if (!is.null(ssbDf)) {
      out=merge(out, ssbDf, by = "year", all = TRUE, sort = TRUE)
      names(out)[4]="ssb"
    } else {
      out$ssb=out$stock
    }
    return(out[is.finite(out$year), c("year", "catch", "stock", "ssb"), drop = FALSE])
  }

  ts=NULL
  if (isS4(x)) {
    nms=methods::slotNames(x)
    for (nm in c("tseries", "timeseries")) {
      if (nm %in% nms) {
        ts=methods::slot(x, nm)
        break
      }
    }
  }
  if (is.null(ts) && is.list(x)) ts=x$tseries %||% x$timeseries
  if (is.null(ts)) stop("Unsupported truth object type for asTruth().")
  asTruth(list(tseries = ts))
})

#' Translate truth table to JABBA input list
#'
#' @param x Truth data frame from `asTruth()`.
#' @param indexCol Optional column name to use as index (defaults to `ssb`).
#' @param cv Optional scalar CV used to construct index SE.
#' @param ... Reserved.
#' @return Named list with `catch`, `cpue`, `se`, and metadata.
#' @export
setGeneric("asJabba", function(x, ...) standardGeneric("asJabba"))

#' @rdname asJabba
#' @export
setMethod("asJabba", signature(x = "data.frame"), function(x, indexCol = "ssb", cv = 0.2, ...) {
  if (!all(c("year", "catch") %in% names(x))) stop("Truth data must contain year and catch.")
  if (!indexCol %in% names(x)) stop("indexCol not found in truth data.")

  keep=is.finite(x$year) & is.finite(x$catch) & is.finite(x[[indexCol]])
  xx=x[keep, , drop = FALSE]

  list(
    catch = as.numeric(xx$catch),
    cpue = as.numeric(xx[[indexCol]]),
    se = rep(as.numeric(cv), nrow(xx)),
    yrs = as.integer(xx$year),
    model = "JABBA",
    source = "sstruth"
  )
})

#' Fit JABBA model from translated input
#'
#' @param x JABBA input list from `asJabba()`.
#' @param run Logical; if `FALSE`, returns prepared fit spec only.
#' @param fitFun Optional exported JABBA function name.
#' @param ... Additional arguments passed to JABBA fit function.
#' @return Fit object (or fit specification when `run = FALSE`).
#' @export
setGeneric("fitJabba", function(x, ...) standardGeneric("fitJabba"))

#' @rdname fitJabba
#' @export
setMethod("fitJabba", signature(x = "list"), function(x, run = FALSE, fitFun = NULL, ...) {
  spec=list(model = "JABBA", input = x, args = list(...))
  if (!isTRUE(run)) return(spec)

  if (!requireNamespace("JABBA", quietly = TRUE)) {
    stop("Package 'JABBA' is required for run=TRUE.")
  }

  exports=getNamespaceExports("JABBA")
  candidates=c("fit_jabba", "fitJABBA", "fit.jabba")
  fitName=fitFun %||% candidates[candidates %in% exports][1]
  if (is.null(fitName) || !nzchar(fitName)) {
    stop("Could not find a known JABBA fitting function. Supply fitFun explicitly.")
  }

  fitFn=getExportedValue("JABBA", fitName)

  if (identical(fitName, "fit_jabba")) {
    jbinput=x
    if (is.null(jbinput$settings)) {
      hasCore=all(c("catch", "cpue", "se") %in% names(x))
      if (!hasCore) stop("For fit_jabba, input must be a jbinput or contain catch/cpue/se.")

      yrs=as.integer(x$yrs %||% seq_along(x$catch))
      catchDf=data.frame(year = yrs, catch = as.numeric(x$catch), stringsAsFactors = FALSE)
      cpueDf=data.frame(year = yrs, cpue = as.numeric(x$cpue), stringsAsFactors = FALSE)
      seDf=data.frame(year = yrs, se = as.numeric(x$se), stringsAsFactors = FALSE)

      jbinput=JABBA::build_jabba(
        catch = catchDf,
        cpue = cpueDf,
        se = seDf,
        projection = FALSE,
        verbose = FALSE
      )
    }
    return(do.call(fitFn, c(list(jbinput = jbinput), list(...))))
  }

  do.call(fitFn, c(list(x), list(...)))
})

#' Run minimal JABBA vertical slice for sma-natl Scenario-1
#'
#' @param x SS3 directory path.
#' @param runFit Logical; if `TRUE`, attempts to run JABBA fit.
#' @param cv Index CV used in JABBA translation.
#' @param ... Additional args passed to fit function.
#' @return List with truth object, truth table, JABBA input, and fit/spec.
#' @export
setGeneric("sliceJabba", function(x, ...) standardGeneric("sliceJabba"))

#' @rdname sliceJabba
#' @export
setMethod("sliceJabba", signature(x = "character"), function(x, runFit = FALSE, cv = 0.2, ...) {
  truthObj=readTruth(x)
  truthDf=asTruth(truthObj)
  jabbaIn=asJabba(truthDf, cv = cv)
  jabbaFit=fitJabba(jabbaIn, run = runFit, ...)
  list(truth = truthObj, truth_df = truthDf, jabba_input = jabbaIn, jabba_fit = jabbaFit)
})

setMethod("asJabba", signature(x = "character"),
          function(x, indexCol = "ssb", cv = 0.2, ...) {
            truthObj <- readTruth(x, ...)
            truthDf  <- asTruth(truthObj)
            asJabba(truthDf, indexCol = indexCol, cv = cv)
          }
)


# Internal helpers ---------------------------------------------------------

.colOrNA<-function(df, candidates) {
  nm=resolveCol(df, candidates)
  if (is.na(nm)) return(rep(NA_real_, nrow(df)))
  as.numeric(df[[nm]])
}

.safeDiv<-function(x, y) {
  out=rep(NA_real_, max(length(x), length(y)))
  xx=as.numeric(x)
  yy=as.numeric(y)
  ok=is.finite(xx) & is.finite(yy) & yy != 0
  out[ok]=xx[ok] / yy[ok]
  out
}

.fitSchaefer<-function(year, biomass, catch) {
  yy=as.numeric(year)
  bb=as.numeric(biomass)
  cc=as.numeric(catch)
  ok=is.finite(yy) & is.finite(bb) & is.finite(cc) & bb > 0
  if (sum(ok) < 5) {
    return(list(r = NA_real_, K = NA_real_, Bmsy = NA_real_, Fmsy = NA_real_))
  }

  yy=yy[ok]
  bb=bb[ok]
  cc=cc[ok]
  ord=order(yy)
  yy=yy[ord]
  bb=bb[ord]
  cc=cc[ord]

  if (length(bb) < 3) {
    return(list(r = NA_real_, K = NA_real_, Bmsy = NA_real_, Fmsy = NA_real_))
  }

  dB=bb[-1] - bb[-length(bb)]
  C_t=cc[-length(cc)]
  B_t=bb[-length(bb)]
  y=(dB + C_t) / pmax(B_t, 1e-12)
  x=B_t
  keep=is.finite(y) & is.finite(x) & x > 0
  if (sum(keep) < 3) {
    return(list(r = NA_real_, K = NA_real_, Bmsy = NA_real_, Fmsy = NA_real_))
  }

  fit=stats::lm(y[keep] ~ x[keep])
  cf=stats::coef(fit)
  r=as.numeric(cf[1])
  slope=as.numeric(cf[2])
  if (!is.finite(r) || !is.finite(slope) || slope >= 0 || r <= 0) {
    return(list(r = NA_real_, K = NA_real_, Bmsy = NA_real_, Fmsy = NA_real_))
  }
  K=-r / slope
  if (!is.finite(K) || K <= 0) {
    return(list(r = NA_real_, K = NA_real_, Bmsy = NA_real_, Fmsy = NA_real_))
  }

  list(
    r = r,
    K = K,
    Bmsy = 0.5 * K,
    Fmsy = 0.5 * r
  )
}

.projectSchaefer<-function(year0, B0, pars, nyears = 10, F = 0) {
  if (!is.finite(B0) || !is.finite(pars$r) || !is.finite(pars$K)) {
    return(data.frame(
      year = integer(),
      stock = numeric(),
      catch = numeric(),
      F = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  yrs=seq.int(as.integer(year0) + 1L, by = 1L, length.out = as.integer(nyears))
  B=rep(NA_real_, length(yrs))
  C=rep(NA_real_, length(yrs))
  Bt=as.numeric(B0)

  for (i in seq_along(yrs)) {
    Ct=F * Bt
    Bt1=Bt + pars$r * Bt * (1 - Bt / pars$K) - Ct
    Bt1=max(Bt1, 1e-10)
    B[i]=Bt1
    C[i]=Ct
    Bt=Bt1
  }

  data.frame(
    year = yrs,
    stock = B,
    catch = C,
    F = rep(F, length(yrs)),
    stringsAsFactors = FALSE
  )
}

.fromJabbaFit<-function(fit, jabba_input = NULL) {
  out=data.frame(year = numeric(), catch = numeric(), stock = numeric(), stringsAsFactors = FALSE)
  if (is.null(fit)) {
    if (!is.null(jabba_input)) {
      return(data.frame(
        year = as.numeric(jabba_input$yrs %||% seq_along(jabba_input$cpue)),
        catch = as.numeric(jabba_input$catch),
        stock = as.numeric(jabba_input$cpue),
        stringsAsFactors = FALSE
      ))
    }
    return(out)
  }

  .extractTsArray<-function(arr, years = NULL, catch = NULL) {
    if (is.null(arr) || is.null(dim(arr))) return(NULL)
    dn=dimnames(arr)
    d=dim(arr)
    stock=NULL

    if (length(d) == 3) {
      i2=if (!is.null(dn[[2]]) && "mu" %in% dn[[2]]) match("mu", dn[[2]]) else 1L
      i3=if (!is.null(dn[[3]]) && "B" %in% dn[[3]]) match("B", dn[[3]]) else 1L
      stock=as.numeric(arr[, i2, i3])
    } else if (length(d) == 2) {
      i2=if (!is.null(dn[[2]]) && "B" %in% dn[[2]]) match("B", dn[[2]]) else 1L
      stock=as.numeric(arr[, i2])
    } else {
      return(NULL)
    }

    yy=as.numeric(years %||% dn[[1]] %||% seq_along(stock))
    cc=as.numeric(catch %||% rep(NA_real_, length(stock)))
    keep=is.finite(yy) & is.finite(stock)
    if (sum(keep) == 0) return(NULL)
    data.frame(year = yy[keep], catch = cc[keep], stock = stock[keep], stringsAsFactors = FALSE)
  }

  arrCandidates=list(
    if (is.list(fit$timeseries)) fit$timeseries$timeseries else NULL,
    fit$timeseries,
    fit$output$timeseries
  )
  for (aa in arrCandidates) {
    arrOut=.extractTsArray(aa, years = fit$yr %||% jabba_input$yrs, catch = fit$catch %||% jabba_input$catch)
    if (!is.null(arrOut) && nrow(arrOut) > 0) return(arrOut)
  }

  candidates=list(
    fit$timeseries,
    fit$tseries,
    fit$ts,
    fit$output$timeseries,
    fit$output$tseries,
    fit$estimates$timeseries
  )
  ts=NULL
  for (cc in candidates) {
    if (is.data.frame(cc) && nrow(cc) > 0) {
      ts=cc
      break
    }
  }

  if (!is.null(ts)) {
    year=.colOrNA(ts, c("year", "yr"))
    catch=.colOrNA(ts, c("catch", "yield", "C", "ct"))
    stock=.colOrNA(ts, c("biomass", "B", "stock", "Bmed", "Bmean", "cpue", "index"))
    keep=is.finite(year) & is.finite(catch) & is.finite(stock)
    out=data.frame(year = year[keep], catch = catch[keep], stock = stock[keep], stringsAsFactors = FALSE)
    if (nrow(out) > 0) return(out)
  }

  if (!is.null(jabba_input)) {
    out=data.frame(
      year = as.numeric(jabba_input$yrs %||% seq_along(jabba_input$cpue)),
      catch = as.numeric(jabba_input$catch),
      stock = as.numeric(jabba_input$cpue),
      stringsAsFactors = FALSE
    )
  }
  out
}

# Main run wrapper ---------------------------------------------------------

#' End-to-end SS3 to JABBA workflow and comparisons
#'
#' @param x SS3 directory path.
#' @param runFit Logical; run JABBA fit when `TRUE`.
#' @param indexCol Truth column used as index/biomass proxy for JABBA input.
#' @param cv Index CV for JABBA input.
#' @param fitFun Optional exported JABBA fitting function.
#' @param proj_years Number of projection years.
#' @param ... Additional args passed to `fitJabba()`.
#' @return List with truth data, JABBA inputs/fit, and comparison tables.
#' @export
workflow<-function(
  x,
  runFit = FALSE,
  indexCol = "ssb",
  cv = 0.2,
  fitFun = NULL,
  proj_years = 10,
  ...
) {
  truthObj=readTruth(x)
  truthDf=asTruth(truthObj)
  jabbaIn=asJabba(truthDf, indexCol = indexCol, cv = cv)
  jabbaFit=fitJabba(jabbaIn, run = runFit, fitFun = fitFun, ...)
  cmp=compareAll(truthDf, jabbaFit, jabbaIn, proj_years = proj_years)
  out=list(
    truth = truthObj,
    truth_df = truthDf,
    jabba_input = jabbaIn,
    jabba_fit = jabbaFit,
    comparisons = cmp
  )
  out
}

# Comparisons --------------------------------------------------------------

#' Compare SS truth and JABBA historical trajectories
#'
#' @param truthDf Data frame from `asTruth()`.
#' @param jabbaFit JABBA fit object or fit specification.
#' @param jabbaInput JABBA input list.
#' @return Data frame comparing observed trajectories and relative scales.
#' @export
compareHistorical<-function(truthDf, jabbaFit = NULL, jabbaInput = NULL) {
  req=c("year", "catch", "stock")
  if (!all(req %in% names(truthDf))) stop("truthDf must contain year, catch, and stock.")
  jdf=.fromJabbaFit(jabbaFit, jabbaInput)
  tdf=data.frame(
    year = as.numeric(truthDf$year),
    truth_catch = as.numeric(truthDf$catch),
    truth_stock = as.numeric(truthDf$stock),
    truth_ssb = as.numeric(truthDf$ssb %||% NA_real_),
    stringsAsFactors = FALSE
  )

  out=merge(
    tdf,
    stats::setNames(jdf, c("year", "jabba_catch", "jabba_stock")),
    by = "year",
    all = TRUE,
    sort = TRUE
  )
  out$truth_stock_rel=.safeDiv(out$truth_stock, max(out$truth_stock, na.rm = TRUE))
  out$jabba_stock_rel=.safeDiv(out$jabba_stock, max(out$jabba_stock, na.rm = TRUE))
  out$truth_catch_rel=.safeDiv(out$truth_catch, max(out$truth_catch, na.rm = TRUE))
  out$jabba_catch_rel=.safeDiv(out$jabba_catch, max(out$jabba_catch, na.rm = TRUE))
  out
}

#' Compare SS truth and JABBA current state in terminal year
#'
#' @param truthDf Data frame from `asTruth()`.
#' @param jabbaFit JABBA fit object or fit specification.
#' @param jabbaInput JABBA input list.
#' @return One-row data frame with terminal status metrics.
#' @export
compareCurrent<-function(truthDf, jabbaFit = NULL, jabbaInput = NULL) {
  hist=compareHistorical(truthDf, jabbaFit = jabbaFit, jabbaInput = jabbaInput)
  yy=max(hist$year[is.finite(hist$year)], na.rm = TRUE)
  cur=hist[hist$year == yy, , drop = FALSE]
  if (nrow(cur) == 0) return(data.frame())

  tPars=.fitSchaefer(hist$year, hist$truth_stock, hist$truth_catch)
  jPars=.fitSchaefer(hist$year, hist$jabba_stock, hist$jabba_catch)
  tF=.safeDiv(cur$truth_catch, cur$truth_stock)
  jF=.safeDiv(cur$jabba_catch, cur$jabba_stock)

  data.frame(
    year = yy,
    truth_stock = cur$truth_stock,
    jabba_stock = cur$jabba_stock,
    truth_B_Bmsy = .safeDiv(cur$truth_stock, tPars$Bmsy),
    jabba_B_Bmsy = .safeDiv(cur$jabba_stock, jPars$Bmsy),
    truth_F_Fmsy = .safeDiv(tF, tPars$Fmsy),
    jabba_F_Fmsy = .safeDiv(jF, jPars$Fmsy),
    stringsAsFactors = FALSE
  )
}

#' Compare SS truth and JABBA production functions
#'
#' @param truthDf Data frame from `asTruth()`.
#' @param jabbaFit JABBA fit object or fit specification.
#' @param jabbaInput JABBA input list.
#' @param n Number of biomass grid points.
#' @return Data frame with production curves for both sources.
#' @export
compareProduction<-function(truthDf, jabbaFit = NULL, jabbaInput = NULL, n = 50) {
  hist=compareHistorical(truthDf, jabbaFit = jabbaFit, jabbaInput = jabbaInput)
  tPars=.fitSchaefer(hist$year, hist$truth_stock, hist$truth_catch)
  jPars=.fitSchaefer(hist$year, hist$jabba_stock, hist$jabba_catch)

  tGrid=if (is.finite(tPars$K)) seq(0, tPars$K, length.out = as.integer(n)) else numeric()
  jGrid=if (is.finite(jPars$K)) seq(0, jPars$K, length.out = as.integer(n)) else numeric()

  outT=data.frame(
    source = "truth",
    stock = tGrid,
    production = tPars$r * tGrid * (1 - tGrid / tPars$K),
    r = tPars$r,
    K = tPars$K,
    Bmsy = tPars$Bmsy,
    Fmsy = tPars$Fmsy,
    stringsAsFactors = FALSE
  )
  outJ=data.frame(
    source = "jabba",
    stock = jGrid,
    production = jPars$r * jGrid * (1 - jGrid / jPars$K),
    r = jPars$r,
    K = jPars$K,
    Bmsy = jPars$Bmsy,
    Fmsy = jPars$Fmsy,
    stringsAsFactors = FALSE
  )
  rbind(outT, outJ)
}

#' Compare SS truth and JABBA projections under F=0 and F=FMSY
#'
#' @param truthDf Data frame from `asTruth()`.
#' @param jabbaFit JABBA fit object or fit specification.
#' @param jabbaInput JABBA input list.
#' @param years Number of projection years.
#' @return Projection data frame for both models and both F scenarios.
#' @export
compareProjection<-function(truthDf, jabbaFit = NULL, jabbaInput = NULL, years = 10) {
  hist=compareHistorical(truthDf, jabbaFit = jabbaFit, jabbaInput = jabbaInput)
  yy=max(hist$year[is.finite(hist$year)], na.rm = TRUE)
  cur=hist[hist$year == yy, , drop = FALSE]
  if (nrow(cur) == 0) return(data.frame())

  tPars=.fitSchaefer(hist$year, hist$truth_stock, hist$truth_catch)
  jPars=.fitSchaefer(hist$year, hist$jabba_stock, hist$jabba_catch)

  tF0=.projectSchaefer(yy, cur$truth_stock[1], tPars, nyears = years, F = 0)
  tFmsy=.projectSchaefer(yy, cur$truth_stock[1], tPars, nyears = years, F = tPars$Fmsy)
  jF0=.projectSchaefer(yy, cur$jabba_stock[1], jPars, nyears = years, F = 0)
  jFmsy=.projectSchaefer(yy, cur$jabba_stock[1], jPars, nyears = years, F = jPars$Fmsy)

  if (nrow(tF0) > 0) {
    tF0$source="truth"
    tF0$scenario="F0"
  }
  if (nrow(tFmsy) > 0) {
    tFmsy$source="truth"
    tFmsy$scenario="FFMSY"
  }
  if (nrow(jF0) > 0) {
    jF0$source="jabba"
    jF0$scenario="F0"
  }
  if (nrow(jFmsy) > 0) {
    jFmsy$source="jabba"
    jFmsy$scenario="FFMSY"
  }

  out=do.call(rbind, Filter(function(x) is.data.frame(x) && nrow(x) > 0, list(tF0, tFmsy, jF0, jFmsy)))
  if (!is.null(out) && nrow(out) > 0) {
    out$B_Bmsy=NA_real_
    out$F_Fmsy=NA_real_
    out$B_Bmsy[out$source == "truth"]=.safeDiv(out$stock[out$source == "truth"], tPars$Bmsy)
    out$F_Fmsy[out$source == "truth"]=.safeDiv(out$F[out$source == "truth"], tPars$Fmsy)
    out$B_Bmsy[out$source == "jabba"]=.safeDiv(out$stock[out$source == "jabba"], jPars$Bmsy)
    out$F_Fmsy[out$source == "jabba"]=.safeDiv(out$F[out$source == "jabba"], jPars$Fmsy)
  }
  out
}

#' Build all four SS-vs-JABBA comparison outputs
#'
#' @param truthDf Data frame from `asTruth()`.
#' @param jabbaFit JABBA fit object or fit specification.
#' @param jabbaInput JABBA input list.
#' @param proj_years Number of projection years.
#' @return Named list with historical, current, production, and projections.
#' @export
compareAll<-function(truthDf, jabbaFit = NULL, jabbaInput = NULL, proj_years = 10) {
  list(
    historical    = compareHistorical(truthDf, jabbaFit = jabbaFit, jabbaInput = jabbaInput),
    current_state = compareCurrent(truthDf, jabbaFit = jabbaFit, jabbaInput = jabbaInput),
    production = compareProduction(truthDf, jabbaFit = jabbaFit, jabbaInput = jabbaInput),
    projections = compareProjection(truthDf, jabbaFit = jabbaFit, jabbaInput = jabbaInput, years = proj_years)
  )
}

# Plot helpers -------------------------------------------------------------

#' Plot historical trend comparison using ggplot2
#'
#' @param historical Historical table from `compareHistorical()`.
#' @return ggplot object.
#' @export
plotHistorical<-function(historical) {
  if (!is.data.frame(historical) || nrow(historical) == 0) stop("historical must be a non-empty data frame.")

  yr=historical$year
  dat=data.frame(
    year = c(yr, yr, yr, yr),
    value = c(historical$truth_stock_rel, historical$jabba_stock_rel, historical$truth_catch_rel, historical$jabba_catch_rel),
    series = c(
      rep("Truth stock (rel)", nrow(historical)),
      rep("JABBA stock (rel)", nrow(historical)),
      rep("Truth catch (rel)", nrow(historical)),
      rep("JABBA catch (rel)", nrow(historical))
    ),
    stringsAsFactors = FALSE
  )
  dat=dat[is.finite(dat$year) & is.finite(dat$value), , drop = FALSE]

  ggplot2::ggplot(dat, ggplot2::aes_string(x = "year", y = "value", color = "series")) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Historical trend: SS truth vs JABBA",
      x = "Year",
      y = "Relative value",
      color = NULL
    )
}

#' Plot current-state comparison using ggplot2
#'
#' @param current_state Current-state table from `compareCurrent()`.
#' @return ggplot object.
#' @export
plotCurrent<-function(current_state) {
  if (!is.data.frame(current_state) || nrow(current_state) == 0) stop("current_state must be a non-empty data frame.")

  cs=current_state[1, , drop = FALSE]
  dat=data.frame(
    metric = c("B/BMSY", "B/BMSY", "F/FMSY", "F/FMSY"),
    source = c("Truth", "JABBA", "Truth", "JABBA"),
    value = c(cs$truth_B_Bmsy, cs$jabba_B_Bmsy, cs$truth_F_Fmsy, cs$jabba_F_Fmsy),
    stringsAsFactors = FALSE
  )
  dat=dat[is.finite(dat$value), , drop = FALSE]

  ggplot2::ggplot(dat, ggplot2::aes_string(x = "metric", y = "value", fill = "source")) +
    ggplot2::geom_col(position = "dodge") +
    ggplot2::geom_hline(yintercept = 1, linetype = 2) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = paste0("Current state in ", as.integer(cs$year[1])),
      x = NULL,
      y = "Ratio to MSY reference",
      fill = NULL
    )
}

#' Plot production function comparison using ggplot2
#'
#' @param production Production table from `compareProduction()`.
#' @return ggplot object.
#' @export
plotProduction<-function(production) {
  if (!is.data.frame(production) || nrow(production) == 0) stop("production must be a non-empty data frame.")

  dat=production[is.finite(production$stock) & is.finite(production$production), , drop = FALSE]
  ggplot2::ggplot(dat, ggplot2::aes_string(x = "stock", y = "production", color = "source")) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_hline(yintercept = 0, linetype = 3) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Production functions: SS truth vs JABBA",
      x = "Biomass",
      y = "Surplus production",
      color = NULL
    )
}

#' Plot projections (F=0 and F=FMSY) using ggplot2
#'
#' @param projections Projection table from `compareProjection()`.
#' @return ggplot object.
#' @export
plotProjection<-function(projections) {
  if (!is.data.frame(projections) || nrow(projections) == 0) stop("projections must be a non-empty data frame.")

  dat=projections[is.finite(projections$year) & is.finite(projections$B_Bmsy), , drop = FALSE]
  dat$group=paste(dat$source, dat$scenario, sep = " - ")

  ggplot2::ggplot(dat, ggplot2::aes_string(x = "year", y = "B_Bmsy", color = "group")) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_hline(yintercept = 1, linetype = 2) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Projected biomass trajectories under F=0 and F=FMSY",
      x = "Year",
      y = "B/BMSY",
      color = NULL
    )
}

#' Build all SS-vs-JABBA comparison plots using ggplot2
#'
#' @param comparisons Named list from `compareAll()` or `workflow()$comparisons`.
#' @return Named list of ggplot objects.
#' @export
plotAll<-function(comparisons) {
  if (!is.list(comparisons)) stop("comparisons must be a named list.")
  list(
    historical = plotHistorical(comparisons$historical),
    current_state = plotCurrent(comparisons$current_state),
    production = plotProduction(comparisons$production),
    projections = plotProjection(comparisons$projections)
  )
}


