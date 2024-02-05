Called from [[`help()` annotated|help()]]
```
## used with firstOnly = TRUE for example()
## used with firstOnly = FALSE in help()
index.search <- function(topic, paths, firstOnly = FALSE) {
    res <- character()
## -- paths is, essentially, the list of packages. 
## Will include, e.g. "/home/elio/R/x86_64-pc-linux-gnu-library/4.3/dummy"

    for (p in paths) {
        if(file.exists(f <- file.path(p, "help", "aliases.rds")))
            al <- readRDS(f)  ## list of aliases in the package. 
        else if(file.exists(f <- file.path(p, "help", "AnIndex"))) {
            ## aliases.rds was introduced before 2.10.0, as can phase this out
            foo <- scan(f, what = list(a="", b=""), sep = "\t", quote = "",
                        na.strings = "", quiet = TRUE)
            al <- structure(foo$b, names = foo$a)
        } else next
        f <- al[topic]
        if(is.na(f)) next
        res <- c(res, file.path(p, "help", f))
        if(firstOnly) break
    }
    res
## To make this return also translations, res should record the package of each result and then search for packages that translate them and do the search again inside those. 
}
```