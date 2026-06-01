#' Build an M x SR_surv_Beta profile grid
#' @param M Numeric vector of natural-mortality multipliers.
#' @param beta Numeric vector of \code{SR_surv_Beta} values.
#' @export
profileBetaGrid <- function(M, beta) {
  g <- expand.grid(
    M = as.numeric(M),
    beta = as.numeric(beta),
    stringsAsFactors = FALSE
  )
  g$i <- seq_len(nrow(g))
  g
}

#' Patch natural mortality age vectors in a control file
#'
#' Scales numeric tokens on lines following \code{#_NATMORT}.
#'
#' @param ctl_path Path to \code{control.ss}.
#' @param multiplier M multiplier applied to age-specific M values.
#' @export
patchCtlNatmAgeBlock <- function(ctl_path, multiplier) {
  if (!file.exists(ctl_path)) {
    return(invisible(FALSE))
  }
  lines <- readLines(ctl_path, warn = FALSE)
  natm_idx <- grep("#_NATMORT", lines)
  if (!length(natm_idx)) {
    return(invisible(FALSE))
  }
  growth_idx <- grep("^1 # GrowthModel:", lines)
  end_idx <- if (length(growth_idx)) growth_idx[[1]] - 1L else length(lines)
  for (i in seq(natm_idx[[1]] + 2L, end_idx)) {
    if (grepl("^[[:space:]]*[0-9.eE+-]", lines[[i]])) {
      nums <- suppressWarnings(as.numeric(unlist(strsplit(trimws(lines[[i]]), "\\s+"))))
      if (length(nums) && all(is.finite(nums))) {
        lines[[i]] <- paste(nums * multiplier, collapse = " ")
      }
    }
  }
  writeLines(lines, ctl_path, useBytes = FALSE)
  invisible(TRUE)
}

#' Set SR_surv_Beta in a Stock Synthesis control file
#' @param dir Scenario directory.
#' @param ctlfile Control file name.
#' @param beta SR_surv_Beta value.
#' @export
patchCtlSrSurvBeta <- function(dir, ctlfile, beta) {
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Package 'r4ss' is required.", call. = FALSE)
  }
  ctl_path <- file.path(dir, ctlfile)
  pl <- r4ss::SS_parlines(ctlfile = ctl_path, dir = NULL, verbose = FALSE)
  sln <- pl[grepl("SR_surv_Beta", pl[, "Label"], fixed = FALSE), "Linenum", drop = TRUE]
  if (!length(sln)) {
    stop("No SR_surv_Beta row in ", ctl_path, call. = FALSE)
  }
  r4ss::SS_changepars(
    dir = dir,
    ctlfile = ctlfile,
    newctlfile = ctlfile,
    linenums = seq(as.integer(sln[[1]]), as.integer(sln[[1]])),
    newvals = as.numeric(beta),
    verbose = FALSE
  )
  invisible(TRUE)
}

#' Copy and patch one M x beta profile scenario
#' @export
setupSs3ProfileScenario <- function(src_dir, dest_dir, M, beta, ctlfile = "control.ss") {
  copySsInputs(src_dir, dest_dir)
  patchCtlSrSurvBeta(dest_dir, ctlfile, beta)
  patchCtlNatmAgeBlock(file.path(dest_dir, ctlfile), M)
  invisible(dest_dir)
}

#' Import a pre-run M x beta profile grid from an external tree
#'
#' Expects layout \code{import_root/<M>/<beta>/} with SS3 outputs.
#'
#' @param import_root Root directory (e.g. ss-ll profile export).
#' @param dest_root Destination under appendix data (manifest CSV written here).
#' @export
importProfileGrid <- function(import_root, dest_root) {
  import_root <- normalizePath(import_root, winslash = "/", mustWork = TRUE)
  dir.create(dest_root, recursive = TRUE, showWarnings = FALSE)
  M_dirs <- list.dirs(import_root, recursive = FALSE, full.names = TRUE)
  M_vals <- suppressWarnings(as.numeric(basename(M_dirs)))
  M_dirs <- M_dirs[is.finite(M_vals)]
  rows <- list()
  manifest <- list()
  for (m_dir in M_dirs) {
    M <- as.numeric(basename(m_dir))
    b_dirs <- list.dirs(m_dir, recursive = FALSE, full.names = TRUE)
    b_vals <- suppressWarnings(as.numeric(basename(b_dirs)))
    b_dirs <- b_dirs[is.finite(b_vals)]
    for (b_dir in b_dirs) {
      beta <- as.numeric(basename(b_dir))
      ss_rep <- readSs3Run(b_dir)
      if (is.null(ss_rep)) {
        next
      }
      ll <- extractLikelihoodComponents(ss_rep)
      if (is.null(ll)) {
        next
      }
      ll$M <- M
      ll$beta <- beta
      ll$run_dir <- b_dir
      rows[[length(rows) + 1L]] <- ll
      manifest[[length(manifest) + 1L]] <- data.frame(
        M = M,
        beta = beta,
        dir = b_dir,
        total_ll = ll$log_likelihood[ll$component == "TOTAL"],
        ok = TRUE,
        stringsAsFactors = FALSE
      )
    }
  }
  if (!length(rows)) {
    stop("No SS3 outputs found under ", import_root, call. = FALSE)
  }
  comp <- do.call(rbind, rows)
  manifest_df <- do.call(rbind, manifest)
  scen <- unique(comp[, c("M", "beta", "run_dir")])
  names(scen)[3] <- "dir"
  scen$i <- seq_len(nrow(scen))
  utils::write.csv(scen, file.path(dest_root, "grid.csv"), row.names = FALSE)
  utils::write.csv(manifest_df, file.path(dest_root, "manifest.csv"), row.names = FALSE)
  utils::write.csv(comp, file.path(dest_root, "likelihood-by-component.csv"), row.names = FALSE)
  list(root = dest_root, manifest = manifest_df, components = comp)
}

#' Collect likelihood-profile results from a profile root directory
#' @param root Directory containing \code{grid.csv} or cached CSVs.
#' @export
collectProfileLikelihoods <- function(root) {
  root <- normalizePath(root, winslash = "/", mustWork = FALSE)
  manifest_path <- file.path(root, "manifest.csv")
  comp_path <- file.path(root, "likelihood-by-component.csv")
  if (file.exists(comp_path)) {
    comp <- utils::read.csv(comp_path, stringsAsFactors = FALSE)
    manifest <- if (file.exists(manifest_path)) {
      utils::read.csv(manifest_path, stringsAsFactors = FALSE)
    } else {
      NULL
    }
    return(list(root = root, manifest = manifest, components = comp))
  }
  scen_path <- file.path(root, "grid.csv")
  if (!file.exists(scen_path)) {
    return(NULL)
  }
  scen <- utils::read.csv(scen_path, stringsAsFactors = FALSE)
  rows <- list()
  manifest <- list()
  for (i in seq_len(nrow(scen))) {
    run_dir <- scen$dir[i]
    if (!dir.exists(run_dir)) {
      next
    }
    ss_rep <- readSs3Run(run_dir)
    if (is.null(ss_rep)) {
      next
    }
    ll <- extractLikelihoodComponents(ss_rep)
    if (is.null(ll)) {
      next
    }
    ll$M <- scen$M[i]
    ll$beta <- scen$beta[i]
    ll$run_dir <- run_dir
    rows[[length(rows) + 1L]] <- ll
    manifest[[length(manifest) + 1L]] <- data.frame(
      M = scen$M[i],
      beta = scen$beta[i],
      dir = run_dir,
      total_ll = ll$log_likelihood[ll$component == "TOTAL"],
      ok = TRUE,
      stringsAsFactors = FALSE
    )
  }
  if (!length(rows)) {
    return(NULL)
  }
  comp <- do.call(rbind, rows)
  manifest_df <- do.call(rbind, manifest)
  dir.create(root, recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(manifest_df, manifest_path, row.names = FALSE)
  utils::write.csv(comp, comp_path, row.names = FALSE)
  list(root = root, manifest = manifest_df, components = comp)
}

#' Set up and optionally run an M x SR_surv_Beta profile grid
#'
#' @inheritParams runSs3MhGrid
#' @param beta Numeric vector of SR_surv_Beta values (instead of steepness).
#' @export
runSs3ProfileGrid <- function(
  root,
  files_subdir = "files",
  ctlfile = "control.ss",
  M,
  beta,
  ss_exe = "ss3",
  run_ss3 = TRUE,
  skip_finished = TRUE,
  overwrite = TRUE,
  parallel = FALSE,
  workers = NULL,
  show_in_console = FALSE
) {
  if (!requireNamespace("r4ss", quietly = TRUE)) {
    stop("Package 'r4ss' is required.", call. = FALSE)
  }
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  base_files <- file.path(root, files_subdir)
  if (!dir.exists(base_files)) {
    stop("Base files directory not found: ", base_files, call. = FALSE)
  }
  scen <- profileBetaGrid(M, beta)
  scen$dir <- file.path(root, as.character(scen$M), as.character(scen$beta))
  utils::write.csv(scen[, c("i", "M", "beta", "dir")], file.path(root, "grid.csv"), row.names = FALSE)

  run_one <- function(i) {
    dest <- scen$dir[i]
    if (isTRUE(overwrite) || !dir.exists(dest)) {
      setupSs3ProfileScenario(base_files, dest, scen$M[i], scen$beta[i], ctlfile)
    }
    ok <- NA
    if (isTRUE(run_ss3)) {
      res <- runSs3Dir(
        dest,
        ss_exe = ss_exe,
        skip_finished = skip_finished,
        show_in_console = show_in_console
      )
      ok <- isTRUE(res$ok)
    }
    data.frame(M = scen$M[i], beta = scen$beta[i], dir = dest, ok = ok, stringsAsFactors = FALSE)
  }

  n <- nrow(scen)
  if (isTRUE(parallel) && n > 1L &&
      requireNamespace("future.apply", quietly = TRUE) &&
      requireNamespace("future", quietly = TRUE)) {
    nw <- workers
    if (is.null(nw)) {
      nw <- max(1L, parallel::detectCores(logical = TRUE) - 2L)
    }
    nw <- min(as.integer(nw), n)
    old <- future::plan(future::multisession, workers = nw)
    on.exit(future::plan(old), add = TRUE)
    rows <- future.apply::future_lapply(seq_len(n), run_one)
  } else {
    rows <- lapply(seq_len(n), run_one)
  }
  invisible(do.call(rbind, rows))
}
