
.pkgenv <- new.env(parent=emptyenv())

.onAttach <- function(libname, pkgname) {

    ## default to "" for both
    perf <- ""

    packageStartupMessage("Loading rvwCpp.")

    if ("" != (res <- unname(Sys.which("perf")))) {
        perf <- res
        packageStartupMessage("Good: seeing 'perf' in '", perf, "'.")
    } else {
        packageStartupMessage("Not so good: no (optional) 'perf' in your path.")
    }
}

