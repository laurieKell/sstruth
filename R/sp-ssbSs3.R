#' Helper to find the first matching column name
#'
#' @param x data.frame
#' @param candidates character vector of possible column names
#' @return column name or NA_character_
findCol <- function(x, candidates) {
  hit <- candidates[candidates %in% names(x)]
  if (length(hit) == 0) return(NA_character_)
  hit[1]
}

#' Helper to find the first matching object name in SS_output
#'
#' @param ss3 SS_output list
#' @param candidates character vector of possible object names
#' @return object name or NA_character_
findObj <- function(ss3, candidates) {
  hit <- candidates[candidates %in% names(ss3)]
  if (length(hit) == 0) return(NA_character_)
  hit[1]
}

#' Get spawning season from SS3 output
#'
#' @param ss3 List from \code{r4ss::SS_output()}.
#' @return integer spawning season
#' @export
getSpawnSeas <- function(ss3) {
  nm <- findObj(ss3, c("SpawnSeason", "spawnseas", "spawnSeas"))
  if (is.na(nm)) return(1)
  as.integer(ss3[[nm]][1])
}

#' Life history inputs from SS3 output
#'
#' @param ss3 List from \code{r4ss::SS_output()}.
#' @param sex Integer (1 = female, 2 = male).
#' @param spawnSeas Spawning season index.
#' @return List with ages, years, w, mat, M, F.
#' @export
ssLifeHistory <- function(ss3, sex = 1, spawnSeas = getSpawnSeas(ss3)) {
  natName <- findObj(ss3, c("natage", "natAge"))
  if (is.na(natName)) stop("No natage object found in ss3.")
  natage <- ss3[[natName]]

  sexCol  <- findCol(natage, c("Sex", "sex"))
  seasCol <- findCol(natage, c("Seas", "seas", "Season", "season"))
  yrCol   <- findCol(natage, c("Yr", "Year", "year"))
  ageCol  <- findCol(natage, c("Age", "age"))
  if (any(is.na(c(yrCol, ageCol)))) stop("natage must contain year and age columns.")

  natSub <- natage
  if (!is.na(sexCol))  natSub <- natSub[natSub[[sexCol]] == sex, , drop = FALSE]
  if (!is.na(seasCol)) natSub <- natSub[natSub[[seasCol]] == spawnSeas, , drop = FALSE]

  ages  <- sort(unique(as.numeric(natSub[[ageCol]])))
  years <- sort(unique(as.numeric(natSub[[yrCol]])))
  years <- years[is.finite(years) & years > 0]

  wtName <- findObj(ss3, c("wtatage", "wtAtAge"))
  if (is.na(wtName)) stop("No wtatage object found in ss3.")
  wtab <- ss3[[wtName]]
  wSexCol  <- findCol(wtab, c("Sex", "sex"))
  wSeasCol <- findCol(wtab, c("Seas", "seas", "Season", "season"))
  wAgeCol  <- findCol(wtab, c("Age", "age"))
  wWtCol   <- findCol(wtab, c("Wt", "wt", "Weight", "weight"))
  wYrCol   <- findCol(wtab, c("Yr", "Year", "year"))
  if (any(is.na(c(wAgeCol, wWtCol)))) stop("wtatage must contain age and weight columns.")

  wSub <- wtab
  if (!is.na(wSexCol))  wSub <- wSub[wSub[[wSexCol]] == sex, , drop = FALSE]
  if (!is.na(wSeasCol)) wSub <- wSub[wSub[[wSeasCol]] == spawnSeas, , drop = FALSE]
  if (!is.na(wYrCol) && nrow(wSub) > 0) {
    wAge <- aggregate(wSub[[wWtCol]], list(Age = wSub[[wAgeCol]]), mean, na.rm = TRUE)
  } else {
    wAge <- aggregate(wSub[[wWtCol]], list(Age = wSub[[wAgeCol]]), mean, na.rm = TRUE)
  }
  names(wAge)[2] <- "w"
  w <- wAge$w[match(ages, wAge$Age)]

  egName <- findObj(ss3, c("endgrowth", "endGrowth"))
  if (is.na(egName)) stop("No endgrowth object found in ss3.")
  eg <- ss3[[egName]]
  egSexCol <- findCol(eg, c("Sex", "sex"))
  egAgeCol <- findCol(eg, c("Age", "age", "Age_Beg", "int_Age"))
  matCol   <- findCol(eg, c("Mat_rate", "Mat*Fecund", "Mat", "maturity"))
  MCol     <- findCol(eg, c("M", "NatM", "natM"))
  if (is.na(egAgeCol)) stop("endgrowth must contain an age column.")

  egSub <- eg
  if (!is.na(egSexCol)) egSub <- egSub[egSub[[egSexCol]] == sex, , drop = FALSE]

  if (is.na(matCol)) {
    mat <- rep(1, length(ages))
  } else {
    matAge <- aggregate(egSub[[matCol]], list(Age = egSub[[egAgeCol]]), mean, na.rm = TRUE)
    names(matAge)[2] <- "mat"
    mat <- matAge$mat[match(ages, matAge$Age)]
  }

  if (is.na(MCol)) {
    M <- rep(NA_real_, length(ages))
  } else {
    MAge <- aggregate(egSub[[MCol]], list(Age = egSub[[egAgeCol]]), mean, na.rm = TRUE)
    names(MAge)[2] <- "M"
    M <- MAge$M[match(ages, MAge$Age)]
  }

  FCol <- findCol(natSub, c("F", "f"))
  ZCol <- findCol(natSub, c("Z", "z"))
  if (!is.na(FCol)) {
    Fmat <- with(natSub, tapply(natSub[[FCol]], list(natSub[[yrCol]], natSub[[ageCol]]), mean, na.rm = TRUE))
  } else if (!is.na(ZCol) && all(is.finite(M) | is.na(M))) {
    Zmat <- with(natSub, tapply(natSub[[ZCol]], list(natSub[[yrCol]], natSub[[ageCol]]), mean, na.rm = TRUE))
    Mvec <- M[match(colnames(Zmat), ages)]
    Mmat <- matrix(Mvec, nrow = nrow(Zmat), ncol = ncol(Zmat), byrow = TRUE)
    Fmat <- pmax(Zmat - Mmat, 0)
  } else {
    stop("Need either F or Z in natage plus M in endgrowth.")
  }

  Fmat <- Fmat[match(years, as.numeric(rownames(Fmat))), match(ages, as.numeric(colnames(Fmat))), drop = FALSE]

  list(ages = ages, years = years, w = w, mat = mat, M = M, F = Fmat)
}

#' Catch biomass at age from SS3 output
#'
#' @param ss3 List from \code{r4ss::SS_output()}.
#' @param sex Integer (1 = female, 2 = male).
#' @param spawnSeas Spawning season index.
#' @return List with years, ages, catch matrix (year x age).
#' @export
ssCatchAge <- function(ss3, sex = 1, spawnSeas = getSpawnSeas(ss3)) {
  natName <- findObj(ss3, c("natage", "natAge"))
  wtName  <- findObj(ss3, c("wtatage", "wtAtAge"))
  if (is.na(natName) || is.na(wtName)) stop("Need natage and wtatage in ss3.")

  natage <- ss3[[natName]]
  wtab   <- ss3[[wtName]]

  sexCol  <- findCol(natage, c("Sex", "sex"))
  seasCol <- findCol(natage, c("Seas", "seas", "Season", "season"))
  yrCol   <- findCol(natage, c("Yr", "Year", "year"))
  ageCol  <- findCol(natage, c("Age", "age"))
  deadCol <- findCol(natage, c("Dead", "dead", "Dead_total"))
  if (any(is.na(c(yrCol, ageCol, deadCol)))) stop("natage must contain year, age, and Dead columns.")

  natSub <- natage
  if (!is.na(sexCol))  natSub <- natSub[natSub[[sexCol]] == sex, , drop = FALSE]
  if (!is.na(seasCol)) natSub <- natSub[natSub[[seasCol]] == spawnSeas, , drop = FALSE]

  wSexCol  <- findCol(wtab, c("Sex", "sex"))
  wSeasCol <- findCol(wtab, c("Seas", "seas", "Season", "season"))
  wYrCol   <- findCol(wtab, c("Yr", "Year", "year"))
  wAgeCol  <- findCol(wtab, c("Age", "age"))
  wWtCol   <- findCol(wtab, c("Wt", "wt", "Weight", "weight"))
  if (any(is.na(c(wAgeCol, wWtCol)))) stop("wtatage must contain age and weight columns.")

  wSub <- wtab
  if (!is.na(wSexCol))  wSub <- wSub[wSub[[wSexCol]] == sex, , drop = FALSE]
  if (!is.na(wSeasCol)) wSub <- wSub[wSub[[wSeasCol]] == spawnSeas, , drop = FALSE]

  joinNat <- data.frame(Yr = natSub[[yrCol]], Age = natSub[[ageCol]], Dead = natSub[[deadCol]])
  if (!is.na(wYrCol)) {
    joinWt <- data.frame(Yr = wSub[[wYrCol]], Age = wSub[[wAgeCol]], Wt = wSub[[wWtCol]])
    df <- merge(joinNat, joinWt, by = c("Yr", "Age"))
  } else {
    wAge <- aggregate(wSub[[wWtCol]], list(Age = wSub[[wAgeCol]]), mean, na.rm = TRUE)
    names(wAge)[2] <- "Wt"
    df <- merge(joinNat, wAge, by = "Age")
  }

  df$catchBio <- df$Dead * df$Wt
  Caa <- with(df, tapply(catchBio, list(Yr, Age), sum, na.rm = TRUE))
  Caa[is.na(Caa)] <- 0

  list(years = as.numeric(rownames(Caa)), ages = as.numeric(colnames(Caa)), catch = Caa)
}

#' SSB-equivalent factors for one year
#'
#' @param lh Life-history list from \code{ssLifeHistory()}.
#' @param yearIndex Integer index into lh$years.
#' @return List with ages, surv, phi, SBPR, Z and F.
#' @export
ssPhiYear <- function(lh, yearIndex) {
  ages <- lh$ages
  w    <- lh$w
  mat  <- lh$mat
  M    <- lh$M
  Fvec <- as.numeric(lh$F[yearIndex, ])

  keep <- is.finite(ages) & is.finite(w) & is.finite(mat) & is.finite(M) & is.finite(Fvec)
  ages <- ages[keep]
  w <- w[keep]
  mat <- mat[keep]
  M <- M[keep]
  Fvec <- Fvec[keep]

  Z <- M + Fvec
  surv <- numeric(length(ages))
  surv[1] <- 1
  if (length(ages) > 1) {
    for (i in 2:length(ages)) surv[i] <- surv[i - 1] * exp(-Z[i - 1])
  }

  sbpr <- sum(surv * mat * w, na.rm = TRUE)
  sbprFuture <- numeric(length(ages))
  for (i in seq_along(ages)) {
    sbprFuture[i] <- sum((surv[i:length(ages)] / surv[i]) * mat[i:length(ages)] * w[i:length(ages)], na.rm = TRUE)
  }
  phi <- sbprFuture / w

  list(ages = ages, surv = surv, sbpr = sbpr, sbprFuture = sbprFuture, phi = phi, Z = Z, F = Fvec)
}

#' SSB-based surplus production time series from SS3
#'
#' @param ss3 List from \code{r4ss::SS_output()}.
#' @param sex Integer (1 = female, 2 = male).
#' @param spawnSeas Spawning season index.
#' @return data.frame with year, ssb, catchSsb, spSsb.
#' @export
spSsbFromSs3 <- function(ss3, sex = 1, spawnSeas = getSpawnSeas(ss3)) {
  lh  <- ssLifeHistory(ss3, sex = sex, spawnSeas = spawnSeas)
  caa <- ssCatchAge(ss3, sex = sex, spawnSeas = spawnSeas)

  years <- intersect(lh$years, caa$years)
  ages  <- intersect(lh$ages, caa$ages)
  if (length(years) == 0 || length(ages) == 0) stop("No overlapping years/ages between life history and catch.")

  iyLh <- match(years, lh$years)
  iyCa <- match(years, caa$years)
  iaLh <- match(ages, lh$ages)
  iaCa <- match(ages, caa$ages)

  lh$F    <- lh$F[iyLh, iaLh, drop = FALSE]
  lh$ages <- ages
  lh$w    <- lh$w[iaLh]
  lh$mat  <- lh$mat[iaLh]
  lh$M    <- lh$M[iaLh]
  Caa     <- caa$catch[iyCa, iaCa, drop = FALSE]

  tsName <- findObj(ss3, c("timeseries", "timeSeries"))
  if (is.na(tsName)) stop("No timeseries object found in ss3.")
  ts <- ss3[[tsName]]
  yrCol <- findCol(ts, c("Yr", "Year", "year"))
  ssbCol <- findCol(ts, c("SpawnBio", "SSB", "spawnBio"))
  if (any(is.na(c(yrCol, ssbCol)))) stop("timeseries must contain year and SpawnBio/SSB.")
  tsSub <- ts[ts[[yrCol]] %in% years, , drop = FALSE]
  SSB <- tsSub[[ssbCol]][match(years, tsSub[[yrCol]])]

  ny <- length(years)
  catchSsb <- numeric(ny)
  spSsb <- rep(NA_real_, ny)

  for (i in seq_len(ny)) {
    phiInfo <- ssPhiYear(lh, yearIndex = i)
    phiVec <- phiInfo$phi
    ageKeep <- match(phiInfo$ages, ages)
    catchSsb[i] <- sum(Caa[i, ageKeep] * phiVec, na.rm = TRUE)
  }

  if (ny > 1) spSsb[1:(ny - 1)] <- SSB[2:ny] - SSB[1:(ny - 1)] + catchSsb[1:(ny - 1)]
  data.frame(year = years, ssb = SSB, catchSsb = catchSsb, spSsb = spSsb)
}

#' Sex-specific SSB-based surplus production from SS3
#'
#' @param ss3 List from \code{r4ss::SS_output()}.
#' @param spawnSeas Spawning season index.
#' @return List with female and male data.frames.
#' @export
spSsbBySexFromSs3 <- function(ss3, spawnSeas = getSpawnSeas(ss3)) {
  spFem  <- spSsbFromSs3(ss3, sex = 1, spawnSeas = spawnSeas)
  spMale <- spSsbFromSs3(ss3, sex = 2, spawnSeas = spawnSeas)
  years <- intersect(spFem$year, spMale$year)
  list(
    female = spFem[spFem$year %in% years, , drop = FALSE],
    male   = spMale[spMale$year %in% years, , drop = FALSE]
  )
}
