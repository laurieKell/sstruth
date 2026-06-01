#' Workflow mode: prototyping vs production-scale pipelines
#'
#' Set \code{SSTRUTH_WORKFLOW_MODE} to \code{prototype} (default) or \code{production}.
#' Use **prototype** while iterating on a few case studies and checking functionality.
#' Use **production** when applying the same methods across contrasting stocks with
#' stricter validation and batch-oriented scripts (see your project’s
#' \code{config-defaults.R} / \code{run-all-scenarios.R}).
#'
#' @details
#' These helpers are intentionally lightweight so CI, drivers, and reports can branch
#' on mode without a heavy dependency. Diagnostics still use \pkg{r4ss} and optionally
#' \href{https://github.com/jabbamodel/ss3diags}{ss3diags}; scenario lists live in
#' project config, not here.
#'
#' @seealso \code{\link{ss3Workflow}} for the full sequential map (\pkg{sstruth} +
#'   optional \pkg{ss3diags}).
#'
#' @return For \code{workflowMode}, a single string \code{"prototype"} or
#'   \code{"production"}.
#' @name ss3WorkflowMode
#' @export
workflowMode <- function() {
  m <- tolower(trimws(Sys.getenv("SSTRUTH_WORKFLOW_MODE", unset = "prototype")))
  if (!m %in% c("prototype", "production")) {
    warning("Invalid SSTRUTH_WORKFLOW_MODE='", m, "'; using 'prototype'.", call. = FALSE)
    m <- "prototype"
  }
  m
}

#' @rdname ss3WorkflowMode
#' @export
isPrototypeWorkflow <- function() {
  identical(workflowMode(), "prototype")
}

#' @rdname ss3WorkflowMode
#' @export
isProductionWorkflow <- function() {
  identical(workflowMode(), "production")
}
