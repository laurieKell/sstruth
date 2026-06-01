#' Build a grid of M and steepness scenarios
#'
#' Rows are suitable for looping or parallel apply. \code{M} is a **multiplier** applied
#' to baseline natural mortality values in the control file (see \code{\link{patchCtlNatmMultiplier}}).
#'
#' @param M Numeric vector of natural-mortality multipliers (e.g. \code{seq(0.4, 1.2, 0.1)}).
#' @param h Numeric vector of steepness values (Beverton–Holt \code{BH_steep}, e.g.
#'   \code{c(0.8, 0.9, 0.999)}).
#' @return A \code{data.frame} with columns \code{M}, \code{h}, and \code{i} (row index).
#' @export
mhScenarioGrid <- function(M, h) {
  g <- expand.grid(M = as.numeric(M), h = as.numeric(h), stringsAsFactors = FALSE)
  g$i <- seq_len(nrow(g))
  g
}

#' Scale Stock Synthesis natural mortality lines in a control file
#'
#' Finds lines containing \code{# natm} (case-insensitive) and multiplies all numeric
#' tokens on the line before any \code{#} comment by \code{multiplier}. This matches the
#' pattern used in WKBSEABASS North M–h sensitivity analyses.
#'
#' @param ctlPath Full path to the \code{.ctl} file.
#' @param multiplier Positive value; baseline NatM is multiplied by this factor.
#' @param natmRegex Regex to identify lines to patch; default matches \code{# natm}.
#' @return Logical \code{TRUE} if at least one line was patched, else \code{FALSE}
#'   (with a warning).
#' @export
patchCtlNatmMultiplier <- function(ctlPath, multiplier, natmRegex = "#\\s*natm") {
  if (!file.exists(ctlPath)) {
    stop("Control file not found: ", ctlPath, call. = FALSE)
  }
  multiplier <- as.numeric(multiplier)[[1]]
  if (!is.finite(multiplier) || multiplier <= 0) {
    stop("multiplier must be positive and finite.", call. = FALSE)
  }
  lines <- readLines(ctlPath, warn = FALSE, encoding = "UTF-8")
  mRow <- grep(natmRegex, lines, ignore.case = TRUE)
  if (length(mRow) < 1L) {
    warning("No NatM line matched (", natmRegex, ") in ", ctlPath, "; M not patched.")
    return(invisible(FALSE))
  }
  for (ir in mRow) {
    ln <- lines[ir]
    hash <- regexpr("#", ln, fixed = TRUE)[[1]]
    head <- if (hash > 0L) {
      substr(ln, 1L, hash - 1L)
    } else {
      ln
    }
    tail <- if (hash > 0L) {
      substr(ln, hash, nchar(ln))
    } else {
      ""
    }
    mVec <- suppressWarnings(as.numeric(unlist(strsplit(trimws(head), "\\s+"))))
    mVec <- mVec[!is.na(mVec)] * multiplier
    newHead <- paste(mVec, collapse = " ")
    lines[ir] <- if (nzchar(trimws(tail))) {
      paste(newHead, tail, sep = " ")
    } else {
      newHead
    }
  }
  writeLines(lines, ctlPath, useBytes = FALSE)
  invisible(TRUE)
}

#' Set Beverton–Holt steepness (\code{BH_steep}) in a Stock Synthesis control file
#'
#' Uses \code{r4ss::SS_parlines} and \code{r4ss::SS_changepars} to set the first matching
#' \code{BH_steep} parameter row.
#'
#' @param dir Scenario directory containing \code{ctlfile}.
#' @param ctlfile Control file name.
#' @param steepness Steepness value (e.g. \code{0.8}).
#' @param labelPattern Pattern used to match \code{Label} in \code{SS_parlines} output;
#'   default \code{"BH_steep"}.
#' @export
patchCtlBhSteepness <- function(dir, ctlfile, steepness, labelPattern = "BH_steep") {
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Install r4ss.", call. = FALSE)
  }
  pl <- r4ss::SS_parlines(
    ctlfile = file.path(dir, ctlfile),
    dir = NULL,
    verbose = FALSE
  )
  if (is.null(pl) || !nrow(pl)) {
    stop("SS_parlines returned no rows for ", file.path(dir, ctlfile), call. = FALSE)
  }
  sln <- pl[grepl(labelPattern, pl[, "Label"], fixed = FALSE), "Linenum", drop = TRUE]
  if (length(sln) < 1L) {
    stop("No ", labelPattern, " row in ", ctlfile, call. = FALSE)
  }
  sln <- as.integer(sln[[1]])
  r4ss::SS_changepars(
    dir = dir,
    ctlfile = ctlfile,
    newctlfile = ctlfile,
    linenums = seq(sln, sln),
    newvals = as.numeric(steepness)[[1]],
    verbose = FALSE
  )
  invisible(TRUE)
}

#' Copy a base SS3 folder and patch M (multiplier) and steepness for one scenario
#'
#' Typical layout: \code{baseFilesDir} is \code{file.path(root, "files")} with a full
#' model tree; output goes to e.g. \code{file.path(root, M, h)}.
#'
#' @param baseFilesDir Directory to copy from (see \code{\link{ssCopyTree}}).
#' @param destDir Destination scenario directory (created or overwritten per
#'   \code{overwrite}).
#' @param ctlfile Name of the control file inside the scenario (e.g. \code{"control.ss"}).
#' @param M_multiplier Natural mortality multiplier applied to \code{# natm} lines.
#' @param steepness Steepness (\code{BH_steep}) passed to \code{\link{patchCtlBhSteepness}}.
#' @param overwrite If \code{TRUE}, replace an existing \code{destDir}.
#' @param natmRegex Passed to \code{\link{patchCtlNatmMultiplier}}.
#' @return Invisibly, normalized \code{destDir}.
#' @export
setupSs3MhScenario <- function(baseFilesDir,
                               destDir,
                               ctlfile,
                               M_multiplier,
                               steepness,
                               overwrite = TRUE,
                               natmRegex = "#\\s*natm") {
  baseFilesDir <- normalizePath(baseFilesDir, winslash = "/", mustWork = TRUE)
  ssCopyTree(baseFilesDir, destDir, overwrite = overwrite)
  patchCtlBhSteepness(destDir, ctlfile, steepness)
  ctlPath <- file.path(destDir, ctlfile)
  patchCtlNatmMultiplier(ctlPath, M_multiplier, natmRegex = natmRegex)
  invisible(normalizePath(destDir, winslash = "/", mustWork = TRUE))
}

#' Run an M × steepness grid of Stock Synthesis models
#'
#' For each combination in \code{\link{mhScenarioGrid}(M, h)}, copies
#' \code{file.path(root, filesSubdir)} to \code{file.path(root, M, h)}, patches the
#' control file, and optionally runs SS3. Parallel runs use \code{future.apply} when
#' \code{parallel = TRUE} and \code{future} is available.
#'
#' @param root Path containing the \code{filesSubdir} template tree.
#' @param filesSubdir Subdirectory of \code{root} with inputs (default \code{"files"}).
#' @param ctlfile Control file name.
#' @param M Numeric vector of M multipliers.
#' @param h Numeric vector of steepness values.
#' @param ssExe Passed to \code{r4ss::run}.
#' @param runSs3 If \code{FALSE}, only set up directories and control files.
#' @param overwrite Passed to \code{\link{setupSs3MhScenario}}.
#' @param parallel If \code{TRUE}, run scenarios in parallel (one worker per scenario
#'   up to \code{workers}).
#' @param workers Max parallel workers; \code{NULL} uses \code{parallelly::availableCores(omit = 1)}.
#' @param natmRegex Passed to \code{\link{patchCtlNatmMultiplier}}.
#' @param showInConsole Passed to \code{r4ss::run}.
#' @return Invisibly, a \code{data.frame} with columns \code{M}, \code{h}, \code{dir},
#'   and \code{ok} (logical or \code{NA} if SS not run).
#' @export
runSs3MhGrid <- function(root,
                         filesSubdir = "files",
                         ctlfile,
                         M,
                         h,
                         ssExe = "ss3",
                         runSs3 = TRUE,
                         overwrite = TRUE,
                         parallel = FALSE,
                         workers = NULL,
                         natmRegex = "#\\s*natm",
                         showInConsole = FALSE) {
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Install r4ss.", call. = FALSE)
  }
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  baseFilesDir <- file.path(root, filesSubdir)
  if (!dir.exists(baseFilesDir)) {
    stop("Base files directory not found: ", baseFilesDir, call. = FALSE)
  }

  scen <- mhScenarioGrid(M, h)
  n <- nrow(scen)

  runOne <- function(row) {
    mm <- scen[row, "M"]
    hh <- scen[row, "h"]
    dest <- file.path(root, as.character(mm), as.character(hh))
    setupSs3MhScenario(
      baseFilesDir,
      dest,
      ctlfile = ctlfile,
      M_multiplier = mm,
      steepness = hh,
      overwrite = overwrite,
      natmRegex = natmRegex
    )
    ok <- NA
    if (isTRUE(runSs3)) {
      r4ss::run(dest, exe = ssExe, skipfinished = FALSE, show_in_console = isTRUE(showInConsole))
      ok <- TRUE
    }
    data.frame(M = mm, h = hh, dir = dest, ok = ok, stringsAsFactors = FALSE)
  }

  if (n < 1L) {
    stop("Empty M/h grid.", call. = FALSE)
  }

  if (isTRUE(parallel) && n > 1L) {
    if (!requireNamespace("future.apply", quietly = TRUE) ||
      !requireNamespace("future", quietly = TRUE) ||
      !requireNamespace("parallelly", quietly = TRUE)) {
      stop("Install future, future.apply, and parallelly for parallel = TRUE.", call. = FALSE)
    }
    nw <- if (is.null(workers)) {
      max(1L, parallelly::availableCores(omit = 1L))
    } else {
      max(1L, as.integer(workers))
    }
    nw <- min(nw, n)
    oldPlan <- future::plan(future::multisession, workers = nw)
    out <- tryCatch(
      future.apply::future_lapply(seq_len(n), runOne),
      finally = {
        future::plan(oldPlan)
      }
    )
    rows <- do.call(rbind, out)
  } else {
    rows <- do.call(rbind, lapply(seq_len(n), runOne))
  }

  invisible(rows)
}
