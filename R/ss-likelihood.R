#' Likelihood components excluded from profile component plots
#' @export
profileLikelihoodExclude <- function() {
  c("InitEQ_Regime", "Crash_Pen", "Equil_catch", "Parm_devs", "TOTAL")
}

#' Extract log-likelihood components from an SS3 report object
#' @param ss_rep Object returned by \code{r4ss::SS_output()}.
#' @return Data frame with \code{component} and \code{log_likelihood}, or \code{NULL}.
#' @export
extractLikelihoodComponents <- function(ss_rep) {
  ll <- ss_rep$likelihoods_used
  if (is.null(ll) || !NROW(ll)) {
    return(NULL)
  }
  comps <- rownames(ll)
  vals <- as.numeric(ll[, "values", drop = TRUE])
  data.frame(
    component = comps,
    log_likelihood = vals,
    stringsAsFactors = FALSE
  )
}
