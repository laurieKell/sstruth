#' Read SS3 truth object via ss3om
#'
#' @param x SS3 directory path.
#' @param ... Additional arguments passed to `ss3om::readFLSss3()`.
#' @return FLR-compatible truth object.
#' @export
setGeneric("ssReadTruth", function(x, ...) standardGeneric("ssReadTruth"))

#' @rdname ssReadTruth
#' @export
setMethod("ssReadTruth", signature(x = "character"), function(x, ...) {
  ss3om::readFLSss3(x, ...)
})

#' Convert SS object to standardized truth table
#'
#' @param x SS truth object.
#' @param ... Reserved for future method-specific options.
#' @return Data frame with `year`, `catch`, `stock`, and `ssb`.
#' @export
setGeneric("ssAsTruth", function(x, ...) standardGeneric("ssAsTruth"))

#' @rdname ssAsTruth
#' @export
setMethod("ssAsTruth", signature(x = "list"), function(x, ...) {
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

#' @rdname ssAsTruth
#' @export
setMethod("ssAsTruth", signature(x = "ANY"), function(x, ...) {
  ts=NULL
  if (methods::isS4(x)) {
    nms=methods::slotNames(x)
    for (nm in c("tseries", "timeseries")) {
      if (nm %in% nms) {
        ts=methods::slot(x, nm)
        break
      }
    }
  }
  if (is.null(ts) && is.list(x)) ts=x$tseries %||% x$timeseries
  if (is.null(ts)) stop("Unsupported truth object type for ssAsTruth().")
  ssAsTruth(list(tseries = ts))
})

#' Translate truth table to JABBA input list
#'
#' @param x Truth data frame from `ssAsTruth()`.
#' @param indexCol Optional column name to use as index (defaults to `ssb`).
#' @param cv Optional scalar CV used to construct index SE.
#' @param ... Reserved.
#' @return Named list with `catch`, `cpue`, `se`, and metadata.
#' @export
setGeneric("ssAsJabba", function(x, ...) standardGeneric("ssAsJabba"))

#' @rdname ssAsJabba
#' @export
setMethod("ssAsJabba", signature(x = "data.frame"), function(x, indexCol = "ssb", cv = 0.2, ...) {
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
#' @param x JABBA input list from `ssAsJabba()`.
#' @param run Logical; if `FALSE`, returns prepared fit spec only.
#' @param fitFun Optional exported JABBA function name.
#' @param ... Additional arguments passed to JABBA fit function.
#' @return Fit object (or fit specification when `run = FALSE`).
#' @export
setGeneric("ssFitJabba", function(x, ...) standardGeneric("ssFitJabba"))

#' @rdname ssFitJabba
#' @export
setMethod("ssFitJabba", signature(x = "list"), function(x, run = FALSE, fitFun = NULL, ...) {
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
setGeneric("ssJabbaSlice", function(x, ...) standardGeneric("ssJabbaSlice"))

#' @rdname ssJabbaSlice
#' @export
setMethod("ssJabbaSlice", signature(x = "character"), function(x, runFit = FALSE, cv = 0.2, ...) {
  truthObj=ssReadTruth(x)
  truthDf=ssAsTruth(truthObj)
  jabbaIn=ssAsJabba(truthDf, cv = cv)
  jabbaFit=ssFitJabba(jabbaIn, run = runFit, ...)
  list(truth = truthObj, truth_df = truthDf, jabba_input = jabbaIn, jabba_fit = jabbaFit)
})

