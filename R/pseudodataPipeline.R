# Preflight ---------------------------------------------------------------

#' Summarize SS model input structure
#'
#' @param ssDir SS3 model directory.
#' @param version SS version string.
#' @param verbose Logical flag.
#' @return List with `summary` and `notes` data frames.
#' @export
ssModelInfo<-function(ssDir, version = "3.30", verbose = TRUE) {
  ssDir=normalizePath(ssDir, winslash = "/", mustWork = TRUE)

  starterFile=file.path(ssDir, "starter.ss")
  forecastFile=file.path(ssDir, "forecast.ss")
  if (!file.exists(starterFile)) stop("starter.ss not found")
  if (!file.exists(forecastFile)) stop("forecast.ss not found")

  st=r4ss::SS_readstarter(starterFile, verbose = FALSE)
  datFile=file.path(ssDir, st$datfile %||% "data.ss")
  ctlFile=file.path(ssDir, st$ctlfile %||% "control.ss")

  if (!file.exists(datFile)) stop("Data file not found: ", datFile)
  if (!file.exists(ctlFile)) stop("Control file not found: ", ctlFile)

  dat=r4ss::SS_readdat(datFile, version = version, verbose = FALSE)
  ctl=r4ss::SS_readctl(file = ctlFile, datlist = dat, verbose = FALSE)

  cpue=dat$CPUE
  catch=dat$catch
  lencomp=dat$lencomp
  agecomp=dat$agecomp

  cpueFleetCol=resolveCol(cpue, c("fleet", "fltsvy"))
  catchFleetCol=resolveCol(catch, c("fleet", "fltsvy", "season", "seas"))
  lenFleetCol=resolveCol(lencomp, c("fleet", "fltsvy"))
  ageFleetCol=resolveCol(agecomp, c("fleet", "fltsvy"))

  cpueSeCol=resolveCol(cpue, c("se_log", "se", "stderr", "sd"))
  cpueObsCol=resolveCol(cpue, c("obs", "index", "cpue"))
  catchCol=resolveCol(catch, c("catch", "catch_season", "totcatch"))
  catchYearCol=resolveCol(catch, c("year", "yr"))
  lenNsampCol=resolveCol(lencomp, c("Nsamp", "nsamp"))
  ageNsampCol=resolveCol(agecomp, c("Nsamp", "nsamp"))

  info=list(
    ssDir = ssDir,
    starter_datfile = basename(datFile),
    starter_ctlfile = basename(ctlFile),
    bootstrap_option = st$N_bootstraps %||% NA,
    nfleets = dat$Nfleets %||% NA,
    nseas = dat$nseas %||% NA,
    nareas = dat$N_areas %||% NA,
    ncpue = safeNrow(cpue),
    ncatch = safeNrow(catch),
    nlencomp = safeNrow(lencomp),
    nagecomp = safeNrow(agecomp),
    fleets_cpue = if (!is.na(cpueFleetCol)) {
      paste(sort(unique(cpue[[cpueFleetCol]])), collapse = ",")
    } else NA,
    fleets_catch = if (!is.na(catchFleetCol)) {
      paste(sort(unique(catch[[catchFleetCol]])), collapse = ",")
    } else NA,
    fleets_lencomp = if (!is.na(lenFleetCol)) {
      paste(sort(unique(lencomp[[lenFleetCol]])), collapse = ",")
    } else NA,
    fleets_agecomp = if (!is.na(ageFleetCol)) {
      paste(sort(unique(agecomp[[ageFleetCol]])), collapse = ",")
    } else NA,
    SR_function = ctl$SR_function %||% NA,
    recruitment_autocorr_parameter_present = if (!is.null(ctl$SR_parms)) {
      any(grepl("autocorr", rownames(ctl$SR_parms), ignore.case = TRUE))
    } else NA,
    stringsAsFactors = FALSE
  )

  adjustments=character()
  flags=character()

  if (is.na(info$bootstrap_option) || info$bootstrap_option != 2) {
    adjustments=c(
      adjustments,
      "Set starter option N_bootstraps = 2 when generating expected-value data for the pseudo-data workflow."
    )
  }
  if (safeNrow(cpue) == 0) flags=c(flags, "No CPUE block detected.")
  if (safeNrow(cpue) > 0 && is.na(cpueObsCol)) {
    flags=c(flags, "Could not identify CPUE observation column in dat$CPUE.")
  }
  if (safeNrow(cpue) > 0 && is.na(cpueSeCol)) {
    adjustments=c(
      adjustments,
      "Check CPUE SE column names in the r4ss object before automated low-error replacement."
    )
  }
  if (safeNrow(lencomp) > 0 &&
      !is.na(lenNsampCol) &&
      mean(lencomp[[lenNsampCol]], na.rm = TRUE) < 100) {
    adjustments=c(
      adjustments,
      "Mean lencomp Nsamp is low; consider larger effective sample sizes for low-error pseudo-data."
    )
  }
  if (safeNrow(agecomp) > 0 &&
      !is.na(ageNsampCol) &&
      mean(agecomp[[ageNsampCol]], na.rm = TRUE) < 100) {
    adjustments=c(
      adjustments,
      "Mean agecomp Nsamp is low; consider larger effective sample sizes for low-error pseudo-data."
    )
  }
  if (safeNrow(catch) > 0 && (is.na(catchCol) || is.na(catchYearCol))) {
    adjustments=c(
      adjustments,
      "Inspect dat$catch column names before automated catch smoothing."
    )
  }
  if (!is.null(ctl$SR_parms) &&
      any(grepl("autocorr", rownames(ctl$SR_parms), ignore.case = TRUE))) {
    adjustments=c(
      adjustments,
      "A recruitment autocorrelation parameter appears present; confirm whether you want it estimated for low-autocorrelation pseudo-data."
    )
  }
  if (!is.null(ctl$timevary_parm_info) && nrow(ctl$timevary_parm_info) > 0) {
    adjustments=c(
      adjustments,
      "Time-varying parameters detected; pseudo-data based on fitted values may inherit those patterns."
    )
  }
  if (file.exists(file.path(ssDir, "wtatage.ss"))) {
    adjustments=c(
      adjustments,
      "Empirical weight-at-age file detected; make sure scenario folders include all auxiliary files."
    )
  }
  if (length(flags) == 0) flags=""

  outSummary=data.frame(
    item = names(info),
    value = unlist(info),
    stringsAsFactors = FALSE
  )
  outNotes=plyr::rbind.fill(
    data.frame(type = "flag", message = unique(flags), stringsAsFactors = FALSE),
    data.frame(type = "adjustment", message = unique(adjustments), stringsAsFactors = FALSE)
  )
  outNotes=outNotes[nzchar(outNotes$message), , drop = FALSE]
  if (nrow(outNotes) == 0) {
    outNotes=data.frame(
      type = "note",
      message = "No obvious structural issues detected by preflight.",
      stringsAsFactors = FALSE
    )
  }

  list(summary = outSummary, notes = outNotes)
}

#' Summarize existing SS run outputs
#'
#' @param ssDir SS3 model directory.
#' @param verbose Logical flag.
#' @return List with run summary and run notes.
#' @export
ssRunSummary<-function(ssDir, verbose = TRUE) {
  ssDir=normalizePath(ssDir, winslash = "/", mustWork = TRUE)
  repfile=file.path(ssDir, "Report.sso")
  warnfile=file.path(ssDir, "warning.sso")

  runSummary=data.frame(item = character(), value = character(), stringsAsFactors = FALSE)
  notes=data.frame(type = character(), message = character(), stringsAsFactors = FALSE)

  if (file.exists(repfile)) {
    rep=try(
      r4ss::SS_output(
        dir = ssDir,
        covar = FALSE,
        forecast = FALSE,
        warn = TRUE,
        verbose = FALSE,
        printstats = FALSE
      ),
      silent = TRUE
    )
    if (!inherits(rep, "try-error")) {
      runSummary=plyr::rbind.fill(
        runSummary,
        data.frame(item = "report_exists", value = TRUE),
        data.frame(item = "npars_est", value = rep$npars %||% NA),
        data.frame(item = "max_grad", value = rep$maximum_gradient %||% NA),
        data.frame(item = "N_warn", value = rep$N_warn %||% NA)
      )

      mg=suppressWarnings(as.numeric(rep$maximum_gradient %||% NA))
      if (is.finite(mg) && mg > 0.001) {
        notes=plyr::rbind.fill(
          notes,
          data.frame(
            type = "adjustment",
            message = paste0(
              "Maximum gradient is ",
              signif(mg, 3),
              "; consider resolving convergence before generating pseudo-data."
            )
          )
        )
      }

      nw=suppressWarnings(as.numeric(rep$N_warn %||% NA))
      if (is.finite(nw) && nw > 0) {
        notes=plyr::rbind.fill(
          notes,
          data.frame(
            type = "flag",
            message = paste0(
              "warning.sso reports ",
              nw,
              " warnings; inspect these before batch running."
            )
          )
        )
      }
    } else {
      notes=plyr::rbind.fill(
        notes,
        data.frame(
          type = "flag",
          message = "Report.sso exists but r4ss::SS_output could not parse it."
        )
      )
    }
  } else {
    notes=plyr::rbind.fill(
      notes,
      data.frame(
        type = "note",
        message = "No existing Report.sso found; only input structure was summarised."
      )
    )
  }

  wtxt=readWarns(warnfile)
  if (length(wtxt) > 0) {
    notes=plyr::rbind.fill(
      notes,
      data.frame(
        type = "warning_excerpt",
        message = head(wtxt, 10),
        stringsAsFactors = FALSE
      )
    )
  }

  list(run_summary = runSummary, run_notes = notes)
}

#' Run preflight checks and write audit files
#'
#' @param ssDir SS3 model directory.
#' @param version SS version string.
#' @param output_dir Output directory for audit csv files.
#' @param prefix File prefix for audit outputs.
#' @param verbose Logical flag.
#' @return Invisible list with input/run summary tables.
#' @export
ssPreflight<-function(
  ssDir,
  version = "3.30",
  output_dir = file.path(ssDir, "audit"),
  prefix = "preflight",
  verbose = TRUE
) {
  ssDir=normalizePath(ssDir, winslash = "/", mustWork = TRUE)
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  inp=ssModelInfo(ssDir = ssDir, version = version, verbose = verbose)
  out=ssRunSummary(ssDir = ssDir, verbose = verbose)

  utils::write.csv(
    inp$summary,
    file.path(output_dir, paste0(prefix, "_input_summary.csv")),
    row.names = FALSE
  )
  utils::write.csv(
    inp$notes,
    file.path(output_dir, paste0(prefix, "_input_notes.csv")),
    row.names = FALSE
  )
  if (nrow(out$run_summary) > 0) {
    utils::write.csv(
      out$run_summary,
      file.path(output_dir, paste0(prefix, "_run_summary.csv")),
      row.names = FALSE
    )
  }
  if (nrow(out$run_notes) > 0) {
    utils::write.csv(
      out$run_notes,
      file.path(output_dir, paste0(prefix, "_run_notes.csv")),
      row.names = FALSE
    )
  }

  invisible(list(
    ssDir = ssDir,
    output_dir = output_dir,
    input_summary = inp$summary,
    input_notes = inp$notes,
    run_summary = out$run_summary,
    run_notes = out$run_notes
  ))
}

# Pseudodata transforms ----------------------------------------------------

#' Apply low-error updates to CPUE/index data
#'
#' @param dat SS data list from `r4ss::SS_readdat()`.
#' @param index_cv CV used for index perturbation.
#' @param fleets_keep_exact Fleets excluded from perturbation.
#' @param fleets_drop Fleets excluded entirely from modification.
#' @param verbose Logical flag.
#' @return List with updated `dat` and `audit`.
#' @export
ssIndex<-function(
  dat,
  index_cv = 0.05,
  fleets_keep_exact = NULL,
  fleets_drop = NULL,
  verbose = TRUE
) {
  audit=list(summary = data.frame(), before = NULL, after = NULL)
  if (is.null(dat$CPUE) || !is.data.frame(dat$CPUE) || nrow(dat$CPUE) == 0) {
    return(list(dat = dat, audit = audit))
  }

  df=dat$CPUE
  before=df
  fleetCol=resolveCol(df, c("fleet", "fltsvy"))
  obsCol=resolveCol(df, c("obs", "index", "cpue"))
  seCol=resolveCol(df, c("se_log", "se", "stderr", "sd"))
  if (is.na(obsCol)) return(list(dat = dat, audit = audit))

  use=rep(TRUE, nrow(df))
  if (!is.na(fleetCol) && !is.null(fleets_keep_exact)) {
    use[df[[fleetCol]] %in% fleets_keep_exact]=FALSE
  }
  if (!is.na(fleetCol) && !is.null(fleets_drop)) {
    use[df[[fleetCol]] %in% fleets_drop]=FALSE
  }

  df[[obsCol]][use]=addLogn(df[[obsCol]][use], index_cv)
  if (!is.na(seCol)) df[[seCol]][use]=index_cv

  dat$CPUE=df
  audit$before=before
  audit$after=df
  audit$summary=data.frame(
    component = "CPUE",
    rows_total = nrow(df),
    rows_modified = sum(use),
    fleets_keep_exact = paste(fleets_keep_exact %||% NA, collapse = ","),
    fleets_drop = paste(fleets_drop %||% NA, collapse = ","),
    cv = index_cv,
    stringsAsFactors = FALSE
  )

  list(dat = dat, audit = audit)
}

#' Inflate composition sample sizes
#'
#' @param dat SS data list from `r4ss::SS_readdat()`.
#' @param min_comp_n Minimum effective sample size.
#' @param fleets_keep_exact Fleets excluded from inflation.
#' @param verbose Logical flag.
#' @return List with updated `dat` and audit table.
#' @export
ssComps<-function(dat, min_comp_n = 500, fleets_keep_exact = NULL, verbose = TRUE) {
  outAudit=data.frame()
  for (slot in c("lencomp", "agecomp")) {
    df=dat[[slot]]
    if (is.null(df) || !is.data.frame(df) || nrow(df) == 0) next

    nsampCol=resolveCol(df, c("Nsamp", "nsamp"))
    fleetCol=resolveCol(df, c("fleet", "fltsvy"))
    if (is.na(nsampCol)) next

    use=rep(TRUE, nrow(df))
    if (!is.na(fleetCol) && !is.null(fleets_keep_exact)) {
      use[df[[fleetCol]] %in% fleets_keep_exact]=FALSE
    }

    beforeN=df[[nsampCol]]
    df[[nsampCol]][use]=pmax(df[[nsampCol]][use], min_comp_n)
    dat[[slot]]=df

    outAudit=plyr::rbind.fill(
      outAudit,
      data.frame(
        component = slot,
        rows_total = nrow(df),
        rows_modified = sum(use & df[[nsampCol]] != beforeN, na.rm = TRUE),
        fleets_keep_exact = paste(fleets_keep_exact %||% NA, collapse = ","),
        min_comp_n = min_comp_n,
        stringsAsFactors = FALSE
      )
    )
  }

  list(dat = dat, audit = outAudit)
}

#' Modify catch series with smoothing and noise
#'
#' @param dat SS data list.
#' @param catch_cv CV for catch perturbation.
#' @param smooth_method One of `"ma"`, `"loess"`, `"none"`.
#' @param loess_span Loess span.
#' @param ma_k Moving-average window size.
#' @param fleets_smooth Fleets eligible for smoothing.
#' @param fleets_keep_exact Fleets excluded from changes.
#' @param years_keep_exact Years excluded from changes.
#' @param verbose Logical flag.
#' @return List with updated `dat` and `audit`.
#' @export
ssCatch<-function(
  dat,
  catch_cv = 0.02,
  smooth_method = c("ma","loess", "none")[1],
  loess_span = 0.3,
  ma_k = 3,
  fleets_smooth = NULL,
  fleets_keep_exact = NULL,
  years_keep_exact = NULL,
  verbose = TRUE
) {
  smooth_method="ma"
  audit=list(summary = data.frame(), before = NULL, after = NULL)
  if (is.null(dat$catch) || !is.data.frame(dat$catch) || nrow(dat$catch) == 0) {
    return(list(dat = dat, audit = audit))
  }

  df=dat$catch
  before=df
  catchCol=resolveCol(df, c("catch", "catch_season", "totcatch"))
  yearCol=resolveCol(df, c("year", "yr"))
  fleetCol=resolveCol(df, c("fleet", "fltsvy", "season", "seas"))
  if (is.na(catchCol) || is.na(yearCol)) return(list(dat = dat, audit = audit))

  fleetGroups=if (is.na(fleetCol)) {
    list(all = seq_len(nrow(df)))
  } else {
    split(seq_len(nrow(df)), df[[fleetCol]])
  }

  modifiedRows=rep(FALSE, nrow(df))
  smoothedRows=rep(FALSE, nrow(df))

  for (nm in names(fleetGroups)) {
    ii=fleetGroups[[nm]]
    thisFleet=if (is.na(fleetCol)) NA else unique(df[ii, fleetCol])[1]
    mod=rep(TRUE, length(ii))

    if (!is.null(fleets_keep_exact) && !is.na(thisFleet) && thisFleet %in% fleets_keep_exact) {
      mod[]=FALSE
    }
    if (!is.null(years_keep_exact)) mod[df[ii, yearCol] %in% years_keep_exact]=FALSE

    doSmooth=TRUE
    if (!is.null(fleets_smooth) && !is.na(thisFleet)) doSmooth=thisFleet %in% fleets_smooth
    if (smooth_method == "none") doSmooth=FALSE

    vals=df[ii, catchCol]
    yrs=df[ii, yearCol]
    if (doSmooth) {
      sm=smoothSeries(yrs, vals, method = smooth_method, loess_span = loess_span, ma_k = ma_k)
      vals[mod]=sm[mod]
      smoothedRows[ii][mod]=TRUE
    }

    vals[mod]=addLogn(vals[mod], catch_cv)
    modifiedRows[ii][mod]=TRUE
    df[ii, catchCol]=vals
  }

  dat$catch=df
  audit$before=before
  audit$after=df
  audit$summary=data.frame(
    component = "catch",
    rows_total = nrow(df),
    rows_modified = sum(modifiedRows),
    rows_smoothed = sum(smoothedRows),
    fleets_smooth = paste(fleets_smooth %||% NA, collapse = ","),
    fleets_keep_exact = paste(fleets_keep_exact %||% NA, collapse = ","),
    years_keep_exact = paste(years_keep_exact %||% NA, collapse = ","),
    smooth_method = smooth_method,
    catch_cv = catch_cv,
    stringsAsFactors = FALSE
  )

  list(dat = dat, audit = audit)
}

# Run wrappers -------------------------------------------------------------

#' Run SS executable in a model directory
#'
#' @param dir SS3 model directory.
#' @param ss3_exe Executable name/path.
#' @param nohess Logical; run with `-nohess`.
#' @return Called for side effects; errors on non-zero exit.
#' @export
ssRun<-function(dir, ss3_exe = "ss3", nohess = TRUE) {
  old=getwd()
  on.exit(setwd(old), add = TRUE)
  setwd(dir)

  cmd=paste(shQuote(ss3_exe), if (nohess) "-nohess", "")
  status=system(cmd, intern = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)
  if (!identical(status, 0L)) stop("SS3 run failed in ", dir)
}

#' Build and optionally run pseudo-data workflow for one model
#'
#' @inheritParams ssCatch
#' @param ssDir SS3 model directory.
#' @param ss3_exe Executable name/path.
#' @param version SS version string.
#' @param index_cv CV for index perturbation.
#' @param min_comp_n Minimum composition sample size.
#' @param seed RNG seed.
#' @param fleets_keep_exact Kept exact for index/comps.
#' @param fleets_drop_indices Fleets excluded in index updates.
#' @param fleets_smooth_catch Fleets eligible for catch smoothing.
#' @param fleets_keep_exact_catch Fleets kept exact for catch.
#' @param years_keep_exact_catch Years kept exact for catch.
#' @param final_dat_name Final data file name.
#' @param audit_prefix Audit file prefix.
#' @param run_base,run_expval,run_final Logical run stages.
#' @param final_nohess Logical; final run with `-nohess`.
#' @return Invisible list describing outputs.
#' @export
ssAudit<-function(
  ssDir,
  ss3_exe = "ss3",
  version = "3.30",
  index_cv = 0.05,
  catch_cv = 0.02,
  min_comp_n = 500,
  catch_smooth = c("ma","loess", "none")[1],
  loess_span = 0.3,
  ma_k = 3,
  seed = 1,
  fleets_keep_exact = NULL,
  fleets_drop_indices = NULL,
  fleets_smooth_catch = NULL,
  fleets_keep_exact_catch = NULL,
  years_keep_exact_catch = NULL,
  final_dat_name = "data_pseudodata.ss",
  audit_prefix = "pseudodata_audit",
  run_base = TRUE,
  run_expval = TRUE,
  run_final = TRUE,
  final_nohess = FALSE,
  verbose = TRUE
) {
  catch_smooth="ma"
  ssDir=normalizePath(ssDir, winslash = "/", mustWork = TRUE)
  set.seed(seed)

  st=r4ss::SS_readstarter(file.path(ssDir, "starter.ss"), verbose = FALSE)
  origDatfile=st$datfile %||% "data.ss"

  if (run_base) {
    st0=st
    st0$N_bootstraps=0
    r4ss::SS_writestarter(st0, dir = ssDir, overwrite = TRUE, verbose = FALSE)
    ssRun(ssDir, ss3_exe = ss3_exe, nohess = TRUE)
  }
  if (run_expval) {
    st1=st
    st1$N_bootstraps=2
    r4ss::SS_writestarter(st1, dir = ssDir, overwrite = TRUE, verbose = FALSE)
    ssRun(ssDir, ss3_exe = ss3_exe, nohess = TRUE)
  }

  expvalFile=file.path(ssDir, "data_expval.ss")
  if (!file.exists(expvalFile)) {
    alt=file.path(ssDir, "data.ss_new")
    if (file.exists(alt)) expvalFile=alt
  }
  if (!file.exists(expvalFile)) stop("Could not find expected-value data output from SS3.")

  dat=r4ss::SS_readdat(expvalFile, version = version, verbose = FALSE)

  idxRes=ssIndex(dat, index_cv = index_cv, fleets_keep_exact = fleets_keep_exact, fleets_drop = fleets_drop_indices, verbose = verbose)
  dat=idxRes$dat
  compRes=ssComps(dat, min_comp_n = min_comp_n, fleets_keep_exact = fleets_keep_exact, verbose = verbose)
  dat=compRes$dat
  catchRes=ssCatch(dat, catch_cv = catch_cv, smooth_method = catch_smooth, loess_span = loess_span, ma_k = ma_k, fleets_smooth = fleets_smooth_catch, fleets_keep_exact = fleets_keep_exact_catch, years_keep_exact = years_keep_exact_catch, verbose = verbose)
  dat=catchRes$dat

  outDat=file.path(ssDir, final_dat_name)
  r4ss::SS_writedat(
    datlist = dat,
    outfile = outDat,
    version = version,
    overwrite = TRUE,
    verbose = FALSE
  )

  st2=st
  st2$datfile=basename(outDat)
  st2$N_bootstraps=0
  r4ss::SS_writestarter(st2, dir = ssDir, overwrite = TRUE, verbose = FALSE)
  if (run_final) ssRun(ssDir, ss3_exe = ss3_exe, nohess = final_nohess)

  auditDir=file.path(ssDir, "audit")
  if (!dir.exists(auditDir)) dir.create(auditDir, recursive = TRUE)

  audMain=plyr::rbind.fill(
    data.frame(component = "run", item = "original_datfile", value = origDatfile),
    data.frame(component = "run", item = "expval_file", value = basename(expvalFile)),
    data.frame(component = "run", item = "final_datfile", value = basename(outDat)),
    data.frame(component = "run", item = "index_cv", value = index_cv),
    data.frame(component = "run", item = "catch_cv", value = catch_cv),
    data.frame(component = "run", item = "min_comp_n", value = min_comp_n),
    data.frame(component = "run", item = "catch_smooth", value = catch_smooth),
    data.frame(component = "run", item = "seed", value = seed)
  )
  utils::write.csv(
    audMain,
    file.path(auditDir, paste0(audit_prefix, "_run_settings.csv")),
    row.names = FALSE
  )

  audSummary=do.call(
    plyr::rbind.fill,
    Filter(
      function(x) !is.null(x) && nrow(x) > 0,
      list(idxRes$audit$summary, compRes$audit, catchRes$audit$summary)
    )
  )
  if (!is.null(audSummary) && nrow(audSummary) > 0) {
    utils::write.csv(
      audSummary,
      file.path(auditDir, paste0(audit_prefix, "_summary.csv")),
      row.names = FALSE
    )
  }
  if (!is.null(idxRes$audit$before)) {
    utils::write.csv(
      idxRes$audit$before,
      file.path(auditDir, paste0(audit_prefix, "_cpue_before.csv")),
      row.names = FALSE
    )
    utils::write.csv(
      idxRes$audit$after,
      file.path(auditDir, paste0(audit_prefix, "_cpue_after.csv")),
      row.names = FALSE
    )
  }
  if (!is.null(catchRes$audit$before)) {
    utils::write.csv(
      catchRes$audit$before,
      file.path(auditDir, paste0(audit_prefix, "_catch_before.csv")),
      row.names = FALSE
    )
    utils::write.csv(
      catchRes$audit$after,
      file.path(auditDir, paste0(audit_prefix, "_catch_after.csv")),
      row.names = FALSE
    )
  }

  invisible(list(
    ssDir = ssDir,
    original_datfile = origDatfile,
    expval_file = basename(expvalFile),
    final_datfile = basename(outDat),
    audit_dir = auditDir,
    audit_prefix = audit_prefix
  ))
}

# Batch / scenarios --------------------------------------------------------

#' Run one batch task
#'
#' @param task Task list with stock/scenario/ssDir and args.
#' @param task_id Task index.
#' @param default_args Default args merged with task args.
#' @param pipeline_fun Function used to execute each task.
#' @param preflight Logical; run preflight.
#' @param skip_on_preflight_flags Logical; skip flagged tasks.
#' @return List with `summary` and optional `result`.
#' @export
ssBatchOne<-function(
  task,
  task_id,
  default_args,
  pipeline_fun = ssAudit,
  preflight = TRUE,
  skip_on_preflight_flags = FALSE
) {
  stock=task$stock %||% paste0("stock", task_id)
  scenario=task$scenario %||% paste0("scenario", task_id)
  ssDir=normalizePath(task$ssDir, winslash = "/", mustWork = TRUE)

  task_args=mergeLists(default_args, task$args %||% list())
  task_args$ssDir=ssDir
  if (is.null(task_args$audit_prefix) || identical(task_args$audit_prefix, "pseudodata_audit")) {
    task_args$audit_prefix=paste0(
      "audit_",
      gsub("[^A-Za-z0-9]+", "_", stock),
      "_",
      gsub("[^A-Za-z0-9]+", "_", scenario)
    )
  }

  started=Sys.time()
  pf_status="not_run"
  pf_message=NA_character_

  if (preflight) {
    pf=try(
      ssPreflight(
        ssDir = ssDir,
        version = task_args$version %||% "3.30",
        output_dir = file.path(ssDir, "audit"),
        prefix = paste0(task_args$audit_prefix, "_preflight"),
        verbose = FALSE
      ),
      silent = TRUE
    )

    if (inherits(pf, "try-error")) {
      pf_status="error"
      pf_message=as.character(pf)
    } else {
      pf_status="ok"
      if (skip_on_preflight_flags && any(pf$input_notes$type == "flag")) {
        ended=Sys.time()
        return(list(
          summary = data.frame(
            task_id = task_id,
            stock = stock,
            scenario = scenario,
            ssDir = ssDir,
            preflight = pf_status,
            status = "skipped_preflight_flag",
            message = "Skipped because preflight produced flags.",
            start_time = as.character(started),
            end_time = as.character(ended),
            elapsed_sec = as.numeric(difftime(ended, started, units = "secs")),
            audit_dir = file.path(ssDir, "audit"),
            stringsAsFactors = FALSE
          ),
          result = NULL
        ))
      }
    }
  }

  out=try(do.call(pipeline_fun, task_args), silent = TRUE)
  ended=Sys.time()
  if (inherits(out, "try-error")) {
    return(list(
      summary = data.frame(
        task_id = task_id,
        stock = stock,
        scenario = scenario,
        ssDir = ssDir,
        preflight = pf_status,
        status = "error",
        message = as.character(out),
        start_time = as.character(started),
        end_time = as.character(ended),
        elapsed_sec = as.numeric(difftime(ended, started, units = "secs")),
        audit_dir = NA_character_,
        stringsAsFactors = FALSE
      ),
      result = NULL
    ))
  }

  list(
    summary = data.frame(
      task_id = task_id,
      stock = stock,
      scenario = scenario,
      ssDir = ssDir,
      preflight = pf_status,
      status = "ok",
      message = pf_message,
      start_time = as.character(started),
      end_time = as.character(ended),
      elapsed_sec = as.numeric(difftime(ended, started, units = "secs")),
      audit_dir = out$audit_dir %||% NA_character_,
      stringsAsFactors = FALSE
    ),
    result = out
  )
}

#' Run a batch of pseudo-data tasks
#'
#' @param tasks List of task definitions.
#' @param workers Number of parallel workers.
#' @param parallel Logical; use parallel execution.
#' @param future_seed Seed behavior passed to `future_lapply`.
#' @param plan_strategy Future plan strategy.
#' @param batch_audit_dir Output directory for batch audit tables.
#' @param pipeline_fun Function to run each task.
#' @param default_args Default arguments for `pipeline_fun`.
#' @param preflight Logical; run preflight.
#' @param skip_on_preflight_flags Logical; skip flagged tasks.
#' @return Invisible list with tasks, summary, and results.
#' @export
ssBatch<-function(
  tasks,
  workers = NULL,
  parallel = TRUE,
  future_seed = TRUE,
  plan_strategy = "multisession",
  batch_audit_dir = "batch_audit",
  pipeline_fun = ssAudit,
  default_args = list(
    ss3_exe = "ss3",
    version = "3.30",
    index_cv = 0.05,
    catch_cv = 0.02,
    min_comp_n = 500,
    catch_smooth = "ma",
    loess_span = 0.3,
    ma_k = 3,
    seed = 1,
    fleets_keep_exact = NULL,
    fleets_drop_indices = NULL,
    fleets_smooth_catch = NULL,
    fleets_keep_exact_catch = NULL,
    years_keep_exact_catch = NULL,
    final_dat_name = "data_pseudodata.ss",
    audit_prefix = "pseudodata_audit",
    run_base = TRUE,
    run_expval = TRUE,
    run_final = TRUE,
    final_nohess = FALSE,
    verbose = TRUE
  ),
  preflight = TRUE,
  skip_on_preflight_flags = FALSE
) {
  if (!dir.exists(batch_audit_dir)) dir.create(batch_audit_dir, recursive = TRUE)

  task_df=do.call(plyr::rbind.fill, lapply(seq_along(tasks), function(i) {
    tt=tasks[[i]]
    data.frame(
      task_id = i,
      stock = tt$stock %||% paste0("stock", i),
      scenario = tt$scenario %||% paste0("scenario", i),
      ssDir = tt$ssDir %||% NA_character_,
      stringsAsFactors = FALSE
    )
  }))
  utils::write.csv(task_df, file.path(batch_audit_dir, "batch_tasks.csv"), row.names = FALSE)

  old_plan=future::plan()
  on.exit(future::plan(old_plan), add = TRUE)

  if (parallel) {
    if (is.null(workers)) workers=future::availableCores()
    if (identical(plan_strategy, "multisession")) future::plan(future::multisession, workers = workers)
    if (identical(plan_strategy, "sequential")) future::plan(future::sequential)
  } else {
    future::plan(future::sequential)
  }

  idx=seq_along(tasks)
  res=future.apply::future_lapply(
    idx,
    function(i) {
      ssBatchOne(
        tasks[[i]],
        i,
        default_args = default_args,
        pipeline_fun = pipeline_fun,
        preflight = preflight,
        skip_on_preflight_flags = skip_on_preflight_flags
      )
    },
    future.seed = future_seed
  )

  batch_summary=do.call(plyr::rbind.fill, lapply(res, `[[`, "summary"))
  utils::write.csv(batch_summary, file.path(batch_audit_dir, "batch_summary.csv"), row.names = FALSE)

  audit_rows=lapply(res, function(x) {
    rr=x$result
    if (is.null(rr) || is.null(rr$audit_dir) || !dir.exists(rr$audit_dir)) return(NULL)

    stock=x$summary$stock[1]
    scenario=x$summary$scenario[1]
    sumfile=list.files(rr$audit_dir, pattern = "_summary\\.csv$", full.names = TRUE)
    if (length(sumfile) == 0) return(NULL)

    df=try(utils::read.csv(sumfile[1], stringsAsFactors = FALSE), silent = TRUE)
    if (inherits(df, "try-error")) return(NULL)

    df$stock=stock
    df$scenario=scenario
    df
  })
  audit_rows=Filter(Negate(is.null), audit_rows)
  if (length(audit_rows) > 0) {
    utils::write.csv(
      do.call(plyr::rbind.fill, audit_rows),
      file.path(batch_audit_dir, "batch_component_summary.csv"),
      row.names = FALSE
    )
  }

  invisible(list(
    tasks = task_df,
    batch_summary = batch_summary,
    results = res,
    batch_audit_dir = normalizePath(batch_audit_dir, winslash = "/", mustWork = TRUE)
  ))
}

#' Expand stock/scenario definitions into task list
#'
#' @param stocks List of stock specifications.
#' @return List of task entries.
#' @export
ssScenarios<-function(stocks) {
  out=list()
  k=1
  for (st in stocks) {
    stock_name=st$stock %||% paste0("stock", k)
    ssDir=st$ssDir %||% stop("Each stock needs ssDir")
    scenarios=st$scenarios %||% list(list(name = "default", args = list()))
    for (sc in scenarios) {
      out[[k]]=list(
        stock = stock_name,
        scenario = sc$name %||% paste0("scenario", k),
        ssDir = ssDir,
        args = sc$args %||% list()
      )
      k=k + 1
    }
  }
  out
}

#' Copy a full model directory tree
#'
#' @param src_dir Source directory.
#' @param dst_dir Destination directory.
#' @param overwrite Logical; overwrite destination if it exists.
#' @return Normalized destination path.
#' @export
ssCopyTree<-function(src_dir, dst_dir, overwrite = FALSE) {
  src_dir=normalizePath(src_dir, winslash = "/", mustWork = TRUE)
  if (dir.exists(dst_dir)) {
    if (!overwrite) stop("Destination exists: ", dst_dir)
    unlink(dst_dir, recursive = TRUE, force = TRUE)
  }
  dir.create(dst_dir, recursive = TRUE, showWarnings = FALSE)

  files=list.files(
    src_dir,
    recursive = TRUE,
    all.files = TRUE,
    no.. = TRUE,
    full.names = TRUE
  )
  dirs=files[file.info(files)$isdir]
  if (length(dirs) > 0) {
    rel_dirs=substring(dirs, nchar(src_dir) + 2)
    for (dd in rel_dirs) {
      dir.create(file.path(dst_dir, dd), recursive = TRUE, showWarnings = FALSE)
    }
  }

  file_paths=files[!file.info(files)$isdir]
  if (length(file_paths) > 0) {
    rel_files=substring(file_paths, nchar(src_dir) + 2)
    ok=file.copy(
      from = file_paths,
      to = file.path(dst_dir, rel_files),
      overwrite = overwrite,
      recursive = FALSE
    )
    if (!all(ok)) warning("Some files were not copied from ", src_dir, " to ", dst_dir)
  }

  normalizePath(dst_dir, winslash = "/", mustWork = TRUE)
}

#' Build scenario directories for all stocks/scenarios
#'
#' @param stocks List of stock specifications.
#' @param root_dir Root output directory.
#' @param overwrite Logical; overwrite existing scenario dirs.
#' @return List with task table, mapping table, and root path.
#' @export
ssBuildScenarios<-function(stocks, root_dir = "scenario_runs", overwrite = FALSE) {
  if (!dir.exists(root_dir)) dir.create(root_dir, recursive = TRUE)

  out=list()
  k=1
  rows=list()

  for (st in stocks) {
    stock_name=st$stock %||% paste0("stock", k)
    base_ssDir=normalizePath(st$ssDir, winslash = "/", mustWork = TRUE)
    scenarios=st$scenarios %||% list(list(name = "default", args = list()))
    stock_root=file.path(root_dir, gsub("[^A-Za-z0-9]+", "_", stock_name))
    dir.create(stock_root, recursive = TRUE, showWarnings = FALSE)

    for (sc in scenarios) {
      sc_name=sc$name %||% paste0("scenario", k)
      run_dir=file.path(stock_root, gsub("[^A-Za-z0-9]+", "_", sc_name))
      ssCopyTree(base_ssDir, run_dir, overwrite = overwrite)

      out[[k]]=list(
        stock = stock_name,
        scenario = sc_name,
        ssDir = normalizePath(run_dir, winslash = "/", mustWork = TRUE),
        args = sc$args %||% list()
      )
      rows[[k]]=data.frame(
        stock = stock_name,
        scenario = sc_name,
        base_ssDir = base_ssDir,
        run_dir = normalizePath(run_dir, winslash = "/", mustWork = TRUE),
        stringsAsFactors = FALSE
      )
      k=k + 1
    }
  }

  map=do.call(plyr::rbind.fill, rows)
  utils::write.csv(map, file.path(root_dir, "scenario_folder_map.csv"), row.names = FALSE)

  list(
    tasks = out,
    map = map,
    root_dir = normalizePath(root_dir, winslash = "/", mustWork = TRUE)
  )
}

#' End-to-end scenario build and batch run
#'
#' @param stocks List of stock specifications.
#' @param scenario_root_dir Root directory for built scenarios.
#' @param overwrite Logical; overwrite existing scenario directories.
#' @param workers Number of workers.
#' @param parallel Logical; run in parallel.
#' @param future_seed Seed behavior for future apply.
#' @param plan_strategy Future plan strategy.
#' @param batch_audit_dir Batch audit output directory.
#' @param preflight Logical; run preflight.
#' @param skip_on_preflight_flags Logical; skip flagged tasks.
#' @param default_args Default args passed to `ssAudit`.
#' @return Invisible list with build and batch outputs.
#' @export
ssCampaign<-function(
  stocks,
  scenario_root_dir = "scenario_runs",
  overwrite = FALSE,
  workers = NULL,
  parallel = TRUE,
  future_seed = TRUE,
  plan_strategy = "multisession",
  batch_audit_dir = "batch_audit",
  preflight = TRUE,
  skip_on_preflight_flags = FALSE,
  default_args = list(
    ss3_exe = "ss3",
    version = "3.30",
    index_cv = 0.05,
    catch_cv = 0.02,
    min_comp_n = 500,
    catch_smooth = c("ma","loess", "none")[1],
    loess_span = 0.3,
    ma_k = 3,
    seed = 1,
    fleets_keep_exact = NULL,
    fleets_drop_indices = NULL,
    fleets_smooth_catch = NULL,
    fleets_keep_exact_catch = NULL,
    years_keep_exact_catch = NULL,
    final_dat_name = "data_pseudodata.ss",
    audit_prefix = "pseudodata_audit",
    run_base = TRUE,
    run_expval = TRUE,
    run_final = TRUE,
    final_nohess = FALSE,
    verbose = TRUE
  )
) {
  built=ssBuildScenarios(
    stocks = stocks,
    root_dir = scenario_root_dir,
    overwrite = overwrite
  )

  batch=ssBatch(
    tasks = built$tasks,
    workers = workers,
    parallel = parallel,
    future_seed = future_seed,
    plan_strategy = plan_strategy,
    batch_audit_dir = batch_audit_dir,
    default_args = default_args,
    preflight = preflight,
    skip_on_preflight_flags = skip_on_preflight_flags
  )

  invisible(list(built = built, batch = batch))
}


