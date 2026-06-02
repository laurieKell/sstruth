#' Standard Stock Synthesis input file names
#' @export
ssInputFiles <- function() {
  c("control.ss", "data.ss", "starter.ss", "forecast.ss")
}

#' Copy SS3 input files into a destination directory
#' @param from_dir Source scenario directory.
#' @param to_dir Destination directory (created if needed).
#' @export
copySsInputs <- function(from_dir, to_dir) {
  files <- ssInputFiles()
  dir.create(to_dir, recursive = TRUE, showWarnings = FALSE)
  for (f in files) {
    src <- file.path(from_dir, f)
    if (file.exists(src)) {
      file.copy(src, file.path(to_dir, f), overwrite = TRUE)
    }
  }
  invisible(to_dir)
}

#' Read an SS3 report object from cache or Report.sso
#'
#' Loads \code{ss_output.rds}, \code{ss.RData}, or calls \code{r4ss::SS_output()}.
#'
#' @param run_dir SS3 run directory.
#' @param save_rds If \code{TRUE}, save \code{ss.RData} and \code{ss_output.rds}.
#' @param refresh Re-read \code{Report.sso} ignoring cache.
#' @param covar,forecast Passed to \code{r4ss::SS_output()}.
#' @export
readSs3Run <- function(
  run_dir,
  save_rds = FALSE,
  refresh = FALSE,
  covar = FALSE,
  forecast = FALSE
) {
  rep <- ssRead(
    run_dir,
    refresh = refresh,
    covar = covar,
    forecast = forecast,
    writeCache = FALSE
  )
  if (is.null(rep)) {
    return(NULL)
  }
  if (isTRUE(save_rds)) {
    ss <- rep
    save(ss, file = file.path(run_dir, "ss.RData"))
    saveRDS(rep, ssCache(run_dir))
  }
  rep
}

#' Run Stock Synthesis in a directory
#'
#' @param dir Run directory containing input files.
#' @param ss_exe SS executable name or path.
#' @param skip_finished Skip when \code{Report.sso} exists.
#' @param show_in_console Passed to \code{r4ss::run}.
#' @param save_output Cache \code{ss.RData} after successful run.
#' @return List with \code{ok}, \code{skipped}, and \code{dir}.
#' @export
runSs3Dir <- function(
  dir,
  ss_exe = "ss3",
  skip_finished = TRUE,
  show_in_console = FALSE,
  save_output = TRUE
) {
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Package 'r4ss' is required.", call. = FALSE)
  }
  if (isTRUE(skip_finished) && file.exists(file.path(dir, "Report.sso"))) {
    return(list(ok = TRUE, skipped = TRUE, dir = dir))
  }
  ok <- tryCatch({
    r4ss::run(
      dir,
      exe = ss_exe,
      skipfinished = isTRUE(skip_finished),
      show_in_console = isTRUE(show_in_console)
    )
    TRUE
  }, error = function(e) {
    message("SS3 run failed in ", dir, ": ", conditionMessage(e))
    FALSE
  })
  if (isTRUE(ok) && isTRUE(save_output)) {
    readSs3Run(dir, save_rds = TRUE)
  }
  list(ok = isTRUE(ok), skipped = FALSE, dir = dir)
}
