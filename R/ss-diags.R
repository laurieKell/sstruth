utils::globalVariables(c("qqnorm"))

#' Build QQ reference line coefficients
#'
#' @param x Numeric x values.
#' @param y Numeric y values.
#' @return Named numeric vector with `a` and `b`.
#' @export
ssQqLine<-function(x, y) {
  qtlx=stats::quantile(x, prob = c(0.25, 0.75), na.rm = TRUE)
  qtly=stats::quantile(y, prob = c(0.25, 0.75), na.rm = TRUE)
  a=(qtly[1] - qtly[2]) / (qtlx[1] - qtlx[2])
  b=qtly[1] - qtlx[1] * a
  out=c(a = as.numeric(a), b = as.numeric(b))
  out
}

#' Add standardized residual diagnostics to a table
#'
#' @param x Data frame containing residual information.
#' @param group_cols Grouping columns used for lag and QQ diagnostics.
#' @param residual_col Residual column name.
#' @param se_col Optional standard error column name.
#' @return Data frame with standard diagnostics columns appended.
#' @export
ssDiagStandard<-function(
  x,
  group_cols = c("method", "name", "season"),
  residual_col = "residual",
  se_col = "se"
) {
  if (!is.data.frame(x)) stop("x must be a data frame.")
  if (!residual_col %in% names(x)) stop("residual_col not found in x.")

  out=x
  out$residual=as.numeric(out[[residual_col]])

  if (se_col %in% names(out)) {
    out$std_residual=.safeDiv(out$residual, as.numeric(out[[se_col]]))
  } else {
    sd_res=stats::sd(out$residual, na.rm = TRUE)
    out$std_residual=.safeDiv(out$residual, sd_res)
  }

  grp=group_cols[group_cols %in% names(out)]
  if (length(grp) == 0) {
    idx=order(out$year %||% seq_len(nrow(out)))
    rr=out$residual[idx]
    out$residual_lag[idx]=c(rr[-1], NA_real_)
    qq=stats::qqnorm(rr, plot.it = FALSE)
    out$qqx[idx]=qq$x
    out$qqy[idx]=qq$y
    ab=ssQqLine(qq$x, qq$y)
    out$qq_hat[idx]=ab["a"] * out$qqx[idx] + ab["b"]
    return(out)
  }

  key=interaction(out[, grp, drop = FALSE], drop = TRUE, lex.order = TRUE)
  out$residual_lag=NA_real_
  out$qqx=NA_real_
  out$qqy=NA_real_
  out$qq_hat=NA_real_

  for (lev in levels(key)) {
    ii=which(key == lev)
    if (length(ii) == 0) next
    ord=ii
    if ("year" %in% names(out)) ord=ii[order(out$year[ii], na.last = TRUE)]
    rr=out$residual[ord]
    out$residual_lag[ord]=c(rr[-1], NA_real_)
    if (sum(is.finite(rr)) >= 3) {
      qq=stats::qqnorm(rr, plot.it = FALSE)
      out$qqx[ord]=qq$x
      out$qqy[ord]=qq$y
      ab=ssQqLine(qq$x, qq$y)
      out$qq_hat[ord]=ab["a"] * out$qqx[ord] + ab["b"]
    }
  }

  out
}

#' Extract standardized diagnostics from Stock Synthesis output
#'
#' @param x SS3 model directory.
#' @param ... Reserved.
#' @return Standardized residual diagnostics data frame.
#' @export
ssDiagSS<-function(x, ...) {
  cpue=r4ss::SS_output(
    dir = x,
    forecast = FALSE,
    covar = FALSE,
    verbose = FALSE,
    printstats = FALSE,
    hidewarn = TRUE,
    NoCompOK = TRUE
  )$cpue
  if (is.null(cpue) || !is.data.frame(cpue) || nrow(cpue) == 0) return(data.frame())

  nm_name=resolveCol(cpue, c("Fleet_name", "FleetName", "Fleet"))
  nm_year=resolveCol(cpue, c("Yr", "year"))
  nm_season=resolveCol(cpue, c("Seas", "season"))
  nm_obs=resolveCol(cpue, c("Obs", "obs"))
  nm_hat=resolveCol(cpue, c("Exp", "Exp_hat", "hat"))
  nm_res=resolveCol(cpue, c("Dev", "residual", "resid"))
  nm_se=resolveCol(cpue, c("SE", "se", "se_log"))
  req=c(nm_name, nm_year, nm_obs, nm_hat, nm_res)
  if (any(is.na(req))) return(data.frame())

  out=data.frame(
    method = "ss",
    name = as.character(cpue[[nm_name]]),
    year = as.numeric(cpue[[nm_year]]),
    season = if (!is.na(nm_season)) as.numeric(cpue[[nm_season]]) else NA_real_,
    obs = as.numeric(cpue[[nm_obs]]),
    hat = as.numeric(cpue[[nm_hat]]),
    residual = as.numeric(cpue[[nm_res]]),
    se = if (!is.na(nm_se)) as.numeric(cpue[[nm_se]]) else NA_real_,
    stringsAsFactors = FALSE
  )
  out=out[is.finite(out$residual), , drop = FALSE]
  ssDiagStandard(out)
}

#' Extract standardized diagnostics from SS-vs-JABBA comparison
#'
#' @param x Workflow result list from `ssJabbaWorkflow()`, or a list containing `historical`.
#' @param ... Reserved.
#' @return Standardized residual diagnostics data frame.
#' @export
ssDiagJabba<-function(x, ...) {
  hist=NULL
  if (is.list(x) && is.list(x$comparisons) && is.data.frame(x$comparisons$historical)) {
    hist=x$comparisons$historical
  } else if (is.list(x) && is.data.frame(x$historical)) {
    hist=x$historical
  } else if (is.list(x) && all(c("truth_df", "jabba_fit", "jabba_input") %in% names(x))) {
    hist=ssCompareHistorical(x$truth_df, jabbaFit = x$jabba_fit, jabbaInput = x$jabba_input)
  }
  if (is.null(hist) || !is.data.frame(hist) || nrow(hist) == 0) return(data.frame())

  mk<-function(obs, hat, nm) {
    keep=is.finite(hist$year) & is.finite(obs) & is.finite(hat) & obs > 0 & hat > 0
    data.frame(
      method = "jabba",
      name = nm,
      year = as.numeric(hist$year[keep]),
      season = NA_real_,
      obs = as.numeric(obs[keep]),
      hat = as.numeric(hat[keep]),
      residual = log(as.numeric(obs[keep]) / as.numeric(hat[keep])),
      se = NA_real_,
      stringsAsFactors = FALSE
    )
  }
  out=rbind(
    mk(hist$truth_stock, hist$jabba_stock, "stock"),
    mk(hist$truth_catch, hist$jabba_catch, "catch")
  )
  ssDiagStandard(out)
}

#' Unified diagnostics extractor (inspired by diags package methods)
#'
#' @param object Input object; commonly SS3 directory (`character`) or workflow list.
#' @param method Method name (e.g. `"ss"`, `"jabba"`).
#' @param ... Additional arguments passed to method-specific extractors.
#' @return Standardized residual diagnostics data frame.
#' @export
setGeneric("ssDiags", function(object, method, ...) standardGeneric("ssDiags"))

#' @rdname ssDiags
#' @export
setMethod("ssDiags", signature(object = "character", method = "character"),
          function(object, method, ...) {
            m=tolower(method[1])
            if (startsWith(m, "ss")) return(ssDiagSS(object, ...))
            stop("Unsupported character input method: ", method)
          })

#' @rdname ssDiags
#' @export
setMethod("ssDiags", signature(object = "list", method = "character"),
          function(object, method, ...) {
            m=tolower(method[1])
            if (startsWith(m, "ja")) return(ssDiagJabba(object, ...))
            if (startsWith(m, "ss")) {
              ssdir=object$ssDir %||% object$path %||% NA_character_
              if (is.na(ssdir)) stop("For method='ss', list input must contain `ssDir` or `path`.")
              return(ssDiagSS(ssdir, ...))
            }
            stop("Unsupported list input method: ", method)
          })

#' @rdname ssDiags
#' @export
setMethod("ssDiags", signature(object = "data.frame", method = "character"),
          function(object, method, residual_col = "residual", se_col = "se", ...) {
            m=tolower(method[1])
            if (!startsWith(m, "st")) stop("For data.frame, use method='standard'.")
            ssDiagStandard(object, residual_col = residual_col, se_col = se_col)
          })

