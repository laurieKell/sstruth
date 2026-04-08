#' Add low lognormal noise
#'
#' @param x Numeric vector.
#' @param sdlog Log-scale standard deviation.
#' @return Numeric vector with multiplicative noise.
#' @export
addLognormalNoise<-function(x, sdlog = 0.02) {
	x * exp(rnorm(length(x), mean = -0.5 * sdlog^2, sd = sdlog))}

#' Rescale composition vector to sum to one
#'
#' @param x Numeric composition vector.
#' @return Rescaled vector (unchanged when sum is not positive).
#' @export
rescaleComp<-function(x) {
	s=sum(x, na.rm = TRUE)
	if (is.na(s) || s <= 0) return(x)
	x / s}

