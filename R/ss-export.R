.ssInputsName <- function() "ss_inputs.rds"
.ssFitsName <- function() "ss_fits.rds"

.ssLenSlots <- function(rep) {
  keys <- c(
    "lendbase",
    "len_comp_fit_table",
    "Length_comp_error_controls",
    "Length_Comp_Fit_Summary"
  )
  out <- rep[keys]
  names(out) <- c("db", "fit", "controls", "summary")
  out
}

#' CPUE input series from \code{SS_output}
#' @param rep \code{SS_output} list.
#' @export
ssCpueInput <- function(rep) {
  cpue <- rep$cpue
  if (is.null(cpue) || !is.data.frame(cpue) || !NROW(cpue)) {
    return(data.frame())
  }
  nm_name <- resolveCol(cpue, c("Fleet_name", "FleetName", "Fleet"))
  nm_year <- resolveCol(cpue, c("Yr", "year"))
  nm_season <- resolveCol(cpue, c("Seas", "season"))
  nm_obs <- resolveCol(cpue, c("Obs", "obs"))
  if (any(is.na(c(nm_name, nm_year, nm_obs)))) {
    return(data.frame())
  }
  out <- data.frame(
    fleet = as.character(cpue[[nm_name]]),
    year = as.numeric(cpue[[nm_year]]),
    season = if (!is.na(nm_season)) as.numeric(cpue[[nm_season]]) else NA_real_,
    obs = as.numeric(cpue[[nm_obs]]),
    stringsAsFactors = FALSE
  )
  out[is.finite(out$year) & is.finite(out$obs), , drop = FALSE]
}

#' CPUE fits and residuals from \code{SS_output}
#' @param rep \code{SS_output} list.
#' @export
ssCpueFit <- function(rep) {
  cpue <- rep$cpue
  if (is.null(cpue) || !is.data.frame(cpue) || !NROW(cpue)) {
    return(data.frame())
  }
  nm_name <- resolveCol(cpue, c("Fleet_name", "FleetName", "Fleet"))
  nm_year <- resolveCol(cpue, c("Yr", "year"))
  nm_season <- resolveCol(cpue, c("Seas", "season"))
  nm_obs <- resolveCol(cpue, c("Obs", "obs"))
  nm_hat <- resolveCol(cpue, c("Exp", "Exp_hat", "hat"))
  nm_res <- resolveCol(cpue, c("Dev", "residual", "resid"))
  nm_se <- resolveCol(cpue, c("SE", "se", "se_log"))
  req <- c(nm_name, nm_year, nm_obs, nm_hat, nm_res)
  if (any(is.na(req))) {
    return(data.frame())
  }
  out <- data.frame(
    fleet = as.character(cpue[[nm_name]]),
    year = as.numeric(cpue[[nm_year]]),
    season = if (!is.na(nm_season)) as.numeric(cpue[[nm_season]]) else NA_real_,
    obs = as.numeric(cpue[[nm_obs]]),
    hat = as.numeric(cpue[[nm_hat]]),
    residual = as.numeric(cpue[[nm_res]]),
    se = if (!is.na(nm_se)) as.numeric(cpue[[nm_se]]) else NA_real_,
    stringsAsFactors = FALSE
  )
  out <- out[is.finite(out$residual), , drop = FALSE]
  if (!NROW(out)) {
    return(out)
  }
  diagStandard(out, group_cols = c("fleet", "season"))
}

#' Length-composition slots from \code{SS_output}
#' @param rep \code{SS_output} list.
#' @export
ssLenFromRep <- function(rep) {
  .ssLenSlots(rep)
}

#' Export cached artifacts for one SS3 run
#'
#' Writes \code{ss_output.rds}, optional \code{flstock.rds}, and role-specific
#' composition files (\code{ss_inputs.rds} for base runs; \code{ss_fits.rds} for
#' sensitivities).
#'
#' @param runDir SS3 run directory.
#' @param role \code{base}, \code{sensitivity}, or \code{auto}.
#' @param id Run id (required when \code{role = "auto"}).
#' @param register Passed to \code{ssRole()}.
#' @param refresh Re-read \code{Report.sso}.
#' @param flr If \code{TRUE}, save \code{flstock.rds} via \code{readFLSss3()}.
#' @export
ssExportRun <- function(
  runDir,
  role = c("auto", "base", "sensitivity", "other"),
  id = NULL,
  register = NULL,
  refresh = FALSE,
  flr = TRUE
) {
  role <- match.arg(role)
  runDir <- ssRunDir(runDir)
  if (role == "auto") {
    if (is.null(id) || !nzchar(id)) {
      stop("Provide id when role = 'auto'.", call. = FALSE)
    }
    role <- ssRole(id, register = register)
  }
  rep <- ssRead(runDir, refresh = refresh)
  ok <- !is.null(rep)
  flr_ok <- FALSE
  inputs_ok <- FALSE
  fits_ok <- FALSE

  if (isTRUE(ok) && isTRUE(flr)) {
    fls <- tryCatch(
      readFLSss3(runDir, writeCache = TRUE),
      error = function(e) {
        message("[ssExport] FLStock: ", conditionMessage(e))
        NULL
      }
    )
    flr_ok <- !is.null(fls)
  }

  if (isTRUE(ok)) {
    lens <- ssLenFromRep(rep)
    if (identical(role, "base")) {
      payload <- list(
        cpue = ssCpueInput(rep),
        lencomp = lens$db
      )
      saveRDS(payload, file.path(runDir, .ssInputsName()))
      inputs_ok <- TRUE
    } else if (identical(role, "sensitivity")) {
      payload <- list(
        cpue = ssCpueFit(rep),
        lencomp = lens$fit,
        lencomp_summary = lens$summary
      )
      saveRDS(payload, file.path(runDir, .ssFitsName()))
      fits_ok <- TRUE
    }
  }

  data.frame(
    path = runDir,
    role = role,
    ss_output = ok,
    flstock = flr_ok,
    inputs = inputs_ok,
    fits = fits_ok,
    stringsAsFactors = FALSE
  )
}

#' Export artifacts for many runs
#'
#' @param runs \code{ssRuns()} or \code{ssCatalog()} table.
#' @param catalog Optional catalog with \code{id}, \code{path}, \code{role}.
#' @inheritParams ssExportRun
#' @export
ssExportRuns <- function(
  runs,
  catalog = NULL,
  register = NULL,
  refresh = FALSE,
  flr = TRUE,
  parallel = TRUE,
  workers = NULL
) {
  .checkRuns(runs)
  if (is.null(catalog)) {
    catalog <- data.frame(
      id = runs$id,
      path = runs$path,
      role = vapply(runs$id, ssRole, character(1L), register = register),
      stringsAsFactors = FALSE
    )
  }
  if (isTRUE(parallel) && nrow(catalog) > 1L) {
    nw <- workers %||% max(1L, parallel::detectCores(logical = TRUE) - 2L)
    message("[ssExport] workers: ", min(as.integer(nw), nrow(catalog)))
  }
  pieces <- .ssParallel(
    seq_len(nrow(catalog)),
    function(i) {
      row <- catalog[i, , drop = FALSE]
      message("[ssExport] ", row$id[[1L]], " (", row$role[[1L]], ")")
      out <- ssExportRun(
        row$path[[1L]],
        role = row$role[[1L]],
        register = register,
        refresh = refresh,
        flr = flr
      )
      cbind(id = row$id[[1L]], out, stringsAsFactors = FALSE)
    },
    parallel = parallel,
    workers = workers
  )
  out <- do.call(rbind, pieces)
  rownames(out) <- NULL
  out
}
