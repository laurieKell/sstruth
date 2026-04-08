##' Length-composition outputs from an SS3 model directory
##'
##' Extracts key length-composition components from \code{r4ss::SS_output()}.
##'
##' @param x Path to an SS3 run directory.
##' @param ... Additional arguments (currently unused).
##' @return A named list with elements \code{db}, \code{fit},
##' \code{controls}, and \code{summary}.
##' @export
setGeneric('ssLen',     function(x,...) methods::standardGeneric('ssLen'))

setMethod('ssLen',    signature(x='character'), function(x,...){
  lns=r4ss::SS_output(x,forecast  =FALSE, 
                  covar     =FALSE,
                  verbose   =FALSE, 
                  printstats=FALSE, 
                  hidewarn  =TRUE, 
                  NoCompOK  =TRUE)
  
   lns=lns[c("lendbase",
             "len_comp_fit_table",
             "Length_comp_error_controls",
             "Length_Comp_Fit_Summary")]
    names(lns)=c("db","fit","controls","summary")
  
    lns})

