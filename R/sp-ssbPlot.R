#' Plot surplus production vs SSB
#'
#' @param spDf Data.frame from \code{spSsbFromSs3()}.
#' @param addSmooth Logical; if TRUE, add a smooth curve.
#' @param showYears Logical; if TRUE, label points by year.
#' @return A ggplot object.
#' @export
plotSpSsb <- function(spDf,
                      addSmooth = TRUE,
                      showYears = FALSE) {
  stopifnot(all(c("year", "ssb", "spSsb") %in% names(spDf)))
  p <- ggplot2::ggplot(spDf, ggplot2::aes(x = ssb, y = spSsb)) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::geom_point() +
    ggplot2::xlab("Spawning stock biomass") +
    ggplot2::ylab("Empirical surplus production (SSB units)") +
    ggplot2::theme_bw()
  if (addSmooth) {
    p <- p + ggplot2::geom_smooth(se = FALSE, method = "loess", colour = "blue")
  }
  if (showYears) {
    p <- p + ggplot2::geom_text(ggplot2::aes(label = year),
                                hjust = -0.1, vjust = 0.5, size = 3)
  }
  p
}

#' Plot naive vs SSB-based surplus production
#'
#' @param spDf Data.frame with year, ssb, spSsb, and spNaive.
#' @return A ggplot object.
#' @export
plotSpCompare <- function(spDf) {
  stopifnot(all(c("year", "ssb", "spSsb", "spNaive") %in% names(spDf)))
  longDf <- tidyr::pivot_longer(
    spDf,
    cols = c("spSsb", "spNaive"),
    names_to = "type",
    values_to = "sp"
  )
  longDf$type <- factor(longDf$type,
                        levels = c("spNaive", "spSsb"),
                        labels = c("Naive (B, raw C)", "SSB-based"))
  ggplot2::ggplot(longDf, ggplot2::aes(x = ssb, y = sp, colour = type)) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::geom_point() +
    ggplot2::geom_smooth(se = FALSE, method = "loess") +
    ggplot2::xlab("Spawning stock biomass") +
    ggplot2::ylab("Empirical surplus production") +
    ggplot2::scale_colour_brewer(palette = "Set1", name = "SP type") +
    ggplot2::theme_bw()
}

#' Plot sex-specific SP vs SSB
#'
#' @param spSex List from \code{spSsbBySexFromSs3()}.
#' @param addSmooth Logical; if TRUE, add smooth curves.
#' @return A ggplot object with panels for each sex.
#' @export
plotSpSex <- function(spSex, addSmooth = TRUE) {
  stopifnot(all(c("female", "male") %in% names(spSex)))

  fem  <- spSex$female
  male <- spSex$male
  fem$sex  <- "Female"
  male$sex <- "Male"
  df <- rbind(fem, male)

  stopifnot(all(c("year", "ssb", "spSsb", "sex") %in% names(df)))

  p <- ggplot2::ggplot(df, ggplot2::aes(x = ssb, y = spSsb)) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::geom_point(alpha = 0.7) +
    ggplot2::facet_wrap(~ sex, scales = "free_y") +
    ggplot2::xlab("Spawning stock biomass") +
    ggplot2::ylab("Empirical surplus production (SSB units)") +
    ggplot2::theme_bw()

  if (addSmooth) {
    p <- p + ggplot2::geom_smooth(se = FALSE,
                                  method = "loess",
                                  colour = "blue")
  }
  p
}

#' Plot sex-specific SSB-equivalent catch over time
#'
#' @param spSex List from \code{spSsbBySexFromSs3()}.
#' @return A ggplot object showing female vs male catchSsb by year.
#' @export
plotCatchSex <- function(spSex) {
  fem  <- spSex$female
  male <- spSex$male
  fem$sex  <- "Female"
  male$sex <- "Male"
  df <- rbind(fem, male)

  stopifnot(all(c("year", "catchSsb", "sex") %in% names(df)))

  ggplot2::ggplot(df, ggplot2::aes(x = year, y = catchSsb, colour = sex)) +
    ggplot2::geom_line() +
    ggplot2::xlab("Year") +
    ggplot2::ylab("SSB-equivalent catch") +
    ggplot2::scale_colour_brewer(palette = "Set1", name = "Sex") +
    ggplot2::theme_bw()
}
