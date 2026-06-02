.scenarioNum <- function(id) {
  m <- regexpr("Scenario[_-]?([0-9]+)", id, ignore.case = TRUE, perl = TRUE)
  if (m < 0L) {
    return(NA_character_)
  }
  sub("Scenario[_-]?", "", regmatches(id, m)[[1L]], ignore.case = TRUE)
}

.runLeaf <- function(id) {
  parts <- strsplit(id, "/", fixed = TRUE)[[1L]]
  parts[[length(parts)]]
}

.sensToken <- function(leaf) {
  m <- regexpr("Sens[A-Z]", leaf, ignore.case = FALSE, perl = TRUE)
  if (m < 0L) {
    return(NA_character_)
  }
  regmatches(leaf, m)[[1L]]
}

.sensOption <- function(leaf) {
  tok <- .sensToken(leaf)
  if (is.na(tok)) {
    return(NA_character_)
  }
  opt <- sub(paste0("^.*?", tok, "_?"), "", leaf, perl = TRUE)
  if (!nzchar(opt)) {
    return(NA_character_)
  }
  opt
}

#' Infer base vs sensitivity from a run id
#'
#' Uses an optional study register when supplied; otherwise heuristics on folder names.
#'
#' @param id Run id relative to assessment base (e.g. \code{Scenario_1/Sc1_Base}).
#' @param register List with optional \code{base} and \code{sensitivity} data frames
#'   (columns \code{id}), or \code{study_spec()$scenarios}.
#' @export
ssRole <- function(id, register = NULL) {
  reg <- .normalizeRegister(register)
  if (!is.null(reg$base) && id %in% reg$base$id) {
    return("base")
  }
  if (!is.null(reg$sensitivity) && id %in% reg$sensitivity$id) {
    return("sensitivity")
  }
  leaf <- .runLeaf(id)
  if (grepl("sens", leaf, ignore.case = TRUE)) {
    return("sensitivity")
  }
  if (grepl("base", leaf, ignore.case = TRUE)) {
    return("base")
  }
  "other"
}

#' Standardized short id for a run
#'
#' Examples: \code{S1_base}, \code{S2_sensA_initF_0p05}.
#'
#' @inheritParams ssRole
#' @export
ssStdId <- function(id, register = NULL) {
  sn <- .scenarioNum(id)
  leaf <- .runLeaf(id)
  role <- ssRole(id, register = register)
  if (is.na(sn)) {
    return(gsub("[/\\\\]", "_", id))
  }
  if (identical(role, "base")) {
    return(paste0("S", sn, "_base"))
  }
  if (identical(role, "sensitivity")) {
    tok <- tolower(.sensToken(leaf))
    opt <- .sensOption(leaf)
    if (is.na(tok)) {
      tok <- gsub("[^A-Za-z0-9]+", "_", leaf)
      tok <- sub("^_+|_+$", "", tok)
    }
    if (!is.na(opt) && nzchar(opt)) {
      return(paste0("S", sn, "_", tok, "_", opt))
    }
    return(paste0("S", sn, "_", tok))
  }
  paste0("S", sn, "_", gsub("[^A-Za-z0-9]+", "_", leaf))
}

.normalizeRegister <- function(register) {
  if (is.null(register)) {
    return(list(base = NULL, sensitivity = NULL))
  }
  if (is.list(register) && !is.data.frame(register)) {
    if (!is.null(register$register) || !is.null(register$sensitivity_register)) {
      return(list(
        base = register$register,
        sensitivity = register$sensitivity_register
      ))
    }
    if (!is.null(register$base) || !is.null(register$sensitivity)) {
      return(list(base = register$base, sensitivity = register$sensitivity))
    }
  }
  if (is.data.frame(register) && all(c("id", "role") %in% names(register))) {
    return(list(
      base = register[register$role == "base", , drop = FALSE],
      sensitivity = register[register$role == "sensitivity", , drop = FALSE]
    ))
  }
  list(base = NULL, sensitivity = NULL)
}

.registerRow <- function(id, register) {
  reg <- .normalizeRegister(register)
  if (!is.null(reg$base) && id %in% reg$base$id) {
    hit <- reg$base[reg$base$id == id, , drop = FALSE][1L, , drop = FALSE]
    return(list(
      scenario = paste0("Scenario ", .scenarioNum(id)),
      label = hit$label[[1L]] %||% id,
      purpose = if ("purpose" %in% names(hit)) hit$purpose[[1L]] else NA_character_
    ))
  }
  if (!is.null(reg$sensitivity) && id %in% reg$sensitivity$id) {
    hit <- reg$sensitivity[reg$sensitivity$id == id, , drop = FALSE][1L, , drop = FALSE]
    return(list(
      scenario = if ("scenario" %in% names(hit)) hit$scenario[[1L]] else paste0("Scenario ", .scenarioNum(id)),
      label = hit$label[[1L]] %||% id,
      purpose = if ("purpose" %in% names(hit)) hit$purpose[[1L]] else NA_character_
    ))
  }
  list(
    scenario = paste0("Scenario ", .scenarioNum(id)),
    label = .runLeaf(id),
    purpose = NA_character_
  )
}

#' Catalog of SS3 runs with standardized ids
#'
#' Discovers runs under \code{base} (when \code{runs} is \code{NULL}) and enriches with
#' role, standardized id, and optional study-register labels.
#'
#' @param base Assessment parent directory.
#' @param runs Optional \code{ssRuns()} table.
#' @param register Study register (\code{study_spec()$scenarios} or list with
#'   \code{register} + \code{sensitivity_register}).
#' @export
ssCatalog <- function(base = NULL, runs = NULL, register = NULL) {
  if (is.null(runs)) {
    if (is.null(base) || !nzchar(base)) {
      stop("Provide base or runs.", call. = FALSE)
    }
    runs <- ssRuns(base)
  }
  if (!NROW(runs)) {
    return(data.frame(
      id = character(0),
      path = character(0),
      stdId = character(0),
      role = character(0),
      scenario = character(0),
      sens = character(0),
      option = character(0),
      label = character(0),
      purpose = character(0),
      stringsAsFactors = FALSE
    ))
  }
  leaf <- vapply(runs$id, .runLeaf, character(1L))
  meta <- lapply(runs$id, .registerRow, register = register)
  data.frame(
    id = runs$id,
    path = runs$path,
    stdId = vapply(runs$id, ssStdId, character(1L), register = register),
    role = vapply(runs$id, ssRole, character(1L), register = register),
    scenario = vapply(meta, `[[`, character(1L), "scenario"),
    sens = vapply(leaf, .sensToken, character(1L)),
    option = vapply(leaf, .sensOption, character(1L)),
    label = vapply(meta, `[[`, character(1L), "label"),
    purpose = vapply(meta, `[[`, character(1L), "purpose"),
    stringsAsFactors = FALSE
  )
}
