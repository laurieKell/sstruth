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

