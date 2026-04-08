##' CPUE residual diagnostics from an SS3 model directory
##'
##' Returns CPUE residual diagnostics with additional summary metrics
##' computed by \code{diags::diagsFn()}.
##'
##' @param x Path to an SS3 run directory.
##' @param ... Additional arguments (currently unused).
##' @return A data.frame with fleet, year, season, observed and expected CPUE,
##' residuals, and diagnostics fields.
##' @export
setGeneric('ssU',     function(x,...) standardGeneric('ssU'))

setMethod('ssU',    signature(x='character'), function(x,...){
  res=subset(r4ss::SS_output(x, 
                       forecast  =FALSE, 
                       covar     =FALSE,
                       verbose   =FALSE, 
                       printstats=FALSE, 
                       hidewarn  =TRUE, 
                       NoCompOK  =TRUE)$cpue, !is.na(Dev),select=c(Fleet_name,Yr,Seas,Obs,Exp,Dev,SE))
  
  
  names(res)=c("name","year","season","obs","hat","residual","se")
  
  res=subset(plyr::ddply(res,.(name,season),diags::diagsFn),!is.na(residual))
  
  res})
