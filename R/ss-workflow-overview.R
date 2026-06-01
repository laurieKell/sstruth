#' Stock Synthesis workflow overview (\pkg{sstruth} + \pkg{ss3diags})
#'
#' @description
#' **sstruth** implements a **sequential toolkit** for SS3 case studies and batch
#' pipelines. **ss3diags** ([GitHub](https://github.com/jabbamodel/ss3diags)) provides
#' diagnostic plots and tests; install it separately. Workflow **mode**
#' (\code{\link{workflowMode}}) distinguishes rapid **prototype** iteration on a few
#' stocks from stricter **production** runs across contrasting scenarios.
#'
#' @section Typical sequence (sstruth):
#' \enumerate{
#'   \item \code{\link{ssPreflight}}
#'   \item \code{\link{runRetros}} / \code{\link{retroBacktestData}}
#'   \item \code{\link{runFlevelProjectionsPeels}}
#'   \item \code{\link{retroForecastScenarioSummary}} (optional lookups)
#'   \item \code{\link{runSs3MhGrid}} / \code{\link{collectMhGridSsB}} (optional grids)
#'   \item \code{\link{ensembleWeightedSpawnBio}} (optional ensembles)
#' }
#'
#' @section Then (ss3diags):
#' Run tests and plots on \code{r4ss::SS_output()} — e.g. \code{SSplotRunstest},
#' \code{SSplotJABBAres}, \code{SSmase}, \code{SSplotEnsemble}.
#'
#' @references
#' [ss3diags README](https://github.com/jabbamodel/ss3diags/blob/master/README.md)
#'
#' @seealso \code{\link{workflowMode}}, \code{\link{loadSstruth}},
#'   \code{vignette("ss3-retro-projections", package = "sstruth")}
#' @name ss3Workflow
#' @aliases ss3-workflow ss3workflow
NULL
