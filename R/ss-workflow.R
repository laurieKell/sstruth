#' Load the \strong{sstruth} package (development tree or installed)
#'
#' If \code{SSTRUTH_ROOT} points at a package source tree (contains
#' \code{DESCRIPTION}), uses \code{pkgload::load_all()} when available; otherwise
#' \code{library(sstruth)}. Use this in R Markdown and case-study scripts so paths
#' stay configurable while generic workflow code lives in the package.
#'
#' @param sstruthRoot Path to the \strong{sstruth} source directory. Default:
#'   \code{Sys.getenv("SSTRUTH_ROOT", unset = "")}.
#' @param quiet Passed to \code{pkgload::load_all()} when used.
#' @param requireFn Optional length-one character: a name that must exist as a
#'   function after load (e.g. \code{"runRetros"}). If missing, stops with a clear error.
#' @return Invisibly: \code{character(1)} — the root path used, or \code{""} when
#'   the installed package was loaded from the library.
#' @export
loadSstruth <- function(sstruthRoot = Sys.getenv("SSTRUTH_ROOT", unset = ""),
                        quiet = TRUE,
                        requireFn = NULL) {
  hasRoot <- nzchar(sstruthRoot) && file.exists(file.path(sstruthRoot, "DESCRIPTION"))
  if (hasRoot && requireNamespace("pkgload", quietly = TRUE)) {
    pkgload::load_all(sstruthRoot, quiet = quiet)
  } else {
    library(sstruth, character.only = TRUE)
  }
  if (length(requireFn) == 1L && nzchar(requireFn)) {
    fn <- requireFn[[1]]
    if (!exists(fn, mode = "function", inherits = TRUE)) {
      stop(
        "sstruth must export ", fn, "(). Set SSTRUTH_ROOT to the package source, ",
        "install sstruth, or run pkgload::load_all('.../sstruth').",
        call. = FALSE
      )
    }
  }
  invisible(if (hasRoot) sstruthRoot else "")
}

#' Environment variable as logical (true / false / 1 / yes)
#'
#' Typical use: \code{SKIP_EXISTING_FORECAST_RUNS}, \code{CI}, etc.
#'
#' @param name Environment variable name.
#' @param unset Default when unset (passed to \code{Sys.getenv}).
#' @return Logical.
#' @export
envAsLogical <- function(name, unset = "false") {
  v <- tolower(trimws(Sys.getenv(name, unset = unset)))
  v %in% c("1", "true", "yes")
}
