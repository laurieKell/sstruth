
#' Null-coalescing helper
#'
#' Returns `y` when `x` is `NULL`, empty, or all `NA`; otherwise returns `x`.
#'
#' @param x Primary value.
#' @param y Fallback value.
#' @return `x` when available, otherwise `y`.
#' @export
`%||%`<-function(x, y) if (is.null(x) || length(x) == 0 || all(is.na(x))) y else x

#' Resolve a column name from candidate names
#'
#' @param df Data frame to inspect.
#' @param candidates Candidate column names (case-insensitive).
#' @return First matching column name or `NA_character_`.
#' @export
resolveCol<-function(df, candidates) {
  if (is.null(df) || !is.data.frame(df)) return(NA_character_)
  nms=names(df)
  if (is.null(nms)) return(NA_character_)
  low=tolower(nms)
  cand_low=tolower(candidates)
  hit=match(cand_low, low)
  hit=hit[!is.na(hit)]
  if (length(hit) == 0) return(NA_character_)
  nms[hit[1]]}

#' Safe row counter
#'
#' @param x Object to check.
#' @return Number of rows for data frames, otherwise `0`.
#' @export
safeNrow<-function(x) if (is.null(x) || !is.data.frame(x)) 0 else nrow(x)

#' Read non-empty warning lines from file
#'
#' @param path Path to text file.
#' @return Character vector of non-empty lines.
#' @export
readWarns<-function(path) {
  if (!file.exists(path)) return(character())
  txt=try(readLines(path, warn = FALSE), silent = TRUE)
  if (inherits(txt, "try-error")) return(character())
  txt[nzchar(trimws(txt))]
}

#' Apply lognormal observation error
#'
#' @param x Numeric vector.
#' @param cv Coefficient of variation.
#' @return Perturbed numeric vector.
#' @export
addLogn<-function(x, cv) {
  x=as.numeric(x)
  out=x
  pos=is.finite(x) & x > 0
  if (any(pos) && is.finite(cv) && cv > 0) {
    sdlog=sqrt(log(1 + cv^2))
    out[pos]=x[pos] * exp(rnorm(sum(pos), mean = -0.5 * sdlog^2, sd = sdlog))
  }
  out}

#' Smooth a numeric time series
#'
#' @param year Numeric year/index vector.
#' @param value Numeric values.
#' @param method Smoothing method (`"ma"`, `"loess"`, `"none"`).
#' @param loess_span Loess span.
#' @param ma_k Moving-average window size.
#' @return Smoothed numeric vector.
#' @export
smoothSeries<-function(year, value, method = c("ma","loess", "none")[1], loess_span = 0.3, ma_k = 3) {
  method="ma" #match.arg(method)
  out=as.numeric(value)
  if (method == "none") return(out)
  ok=is.finite(year) & is.finite(value)
  if (sum(ok) < 3) return(out)
  if (method == "loess") {
    fit=stats::loess(log(pmax(value[ok], 1e-12)) ~ year[ok], span = loess_span, degree = 1)
    pred=try(stats::predict(fit, newdata = data.frame(`year[ok]` = year[ok])), silent = TRUE)
    if (inherits(pred, "try-error") || all(is.na(pred))) pred=stats::predict(fit, newdata = data.frame(year = year[ok]))
    out[ok]=exp(as.numeric(pred))
  }
  if (method == "ma") {
    lv=log(pmax(value[ok], 1e-12))
    k=max(1, as.integer(ma_k))
    filt=stats::filter(lv, rep(1 / k, k), sides = 2)
    na_idx=is.na(filt)
    filt[na_idx]=lv[na_idx]
    out[ok]=exp(as.numeric(filt))
  }
  out}

#' Merge two named lists
#'
#' @param x Base list.
#' @param y List with overriding values.
#' @return Merged list.
#' @export
mergeLists<-function(x, y) {
  z=x
  if (length(y) == 0) return(z)
  for (nm in names(y)) z[[nm]]=y[[nm]]
  z}
