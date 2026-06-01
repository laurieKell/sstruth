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
#' Loads \code{ss.RData} when present; otherwise calls \code{r4ss::SS_output()}.
#'
#' @param run_dir SS3 run directory.
#' @param save_rds If \code{TRUE} and SS3 is run, save \code{ss.RData} after read.
#' @export
readSs3Run <- function(run_dir, save_rds = FALSE) {
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Package 'r4ss' is required.", call. = FALSE)
  }
  rdata <- file.path(run_dir, "ss.RData")
  if (file.exists(rdata)) {
    env <- new.env(parent = emptyenv())
    load(rdata, envir = env)
    if (exists("ss", envir = env, inherits = FALSE)) {
      return(get("ss", envir = env))
    }
  }
  if (!file.exists(file.path(run_dir, "Report.sso"))) {
    return(NULL)
  }
  rep <- r4ss::SS_output(
    run_dir,
    verbose = FALSE,
    printstats = FALSE,
    covar = FALSE,
    hidewarn = TRUE,
    NoCompOK = TRUE
  )
  if (isTRUE(save_rds) && !is.null(rep)) {
    ss <- rep
    save(ss, file = rdata)
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
