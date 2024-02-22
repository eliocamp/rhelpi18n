`print.help_files_with_topic()`  eventually will start the dynamic help server and browse a particular directory. 

It's hard to know which functions are called, but one of them is `tools:::httpd()` which does a lot of stuff. Another important function is `tools::Rd2HTML()`, which takes a parsed Rd file and converts it to an HTML file. 

`tools:::httpd()` takes the path in the URL (e.g. `/library/NULL/help/filter`) and returns a list with either a file or a "payload" element with hand-crafted HTML. 

`tools:::httpd()` will call `tools::Rd2HTML()` to convert an Rd file into HTML: 

```r
Rd2HTML(utils:::.getHelpFile(file.path(path, helpdoc)),
                out = outfile, package = dirpath,
                dynamic = TRUE, outputEncoding = "UTF-8")
```

This will be run when the helpfile is shown (so, for example, it's not called when showing the disambiguation page). 

`utils:::.getHelpFile()` is the function that returns the parsed Rd file: 

```r
.getHelpFile <- function(file)
{
    path <- dirname(file)
    dirpath <- dirname(path)
    if(!file.exists(dirpath))
        stop(gettextf("invalid %s argument", sQuote("file")), domain = NA)
    pkgname <- basename(dirpath)
    RdDB <- file.path(path, pkgname)
    if(!file.exists(paste0(RdDB, ".rdx")))
        stop(gettextf("package %s exists but was not installed under R >= 2.10.0 so help cannot be accessed", sQuote(pkgname)), domain = NA)
    tools:::fetchRdDB(RdDB, basename(file))
}
```

Well, actually, `utils:::.getHelpFile()` calls  `tools:::fetchRdDB()`. 

```r
fetchRdDB <-
function(filebase, key = NULL)
{
    fun <- function(db) {
        vals <- db$vals
        vars <- db$vars
        datafile <- db$datafile
        compressed <- db$compressed
        envhook <- db$envhook

        fetch <- function(key)
            lazyLoadDBfetch(vals[key][[1L]], datafile, compressed, envhook)

        if(length(key)) {
            if(key %notin% vars)
                stop(gettextf("No help on %s found in RdDB %s",
                              sQuote(key), sQuote(filebase)),
                     domain = NA)
            fetch(key)
        } else {
            res <- lapply(vars, fetch)
            names(res) <- vars
            res
        }
    }
    res <- lazyLoadDBexec(filebase, fun)
    if (length(key))
        res
    else
        invisible(res)
}
```

I think a good place to do the translation could be right before `Rd2HTML()`. This 