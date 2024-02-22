When the user calls `help("function")` ...

First relevant function is `help()`. [Its source code](https://github.com/r-devel/r-svn/blob/7443ac74ccaa5e780273b1eb308eaf4b7a7e89f4/src/library/utils/R/help.R#L19) can be found here. 

```r
help <- function (topic, 
		 package = NULL, 
		 lib.loc = NULL,
         verbose = getOption("verbose"),
         try.all.packages = getOption("help.try.all.packages"),
         help_type = getOption("help_type")) {
```

The main argument is `topic`. Another relevant argument is  `help_type`, which can be "text", "html" or "pdf". This will be important later. 

Next comes a few argument checking and defensive programming. Default to `help_type <- "text"` if it's missing and capture the name of the package using NSE. 
```r
types <- c("text", "html", "pdf")
    help_type <- if(!length(help_type)) "text"
		 else match.arg(tolower(help_type), types)
    if(!missing(package)) # Don't check for NULL; may be nonstandard eval
        if(is.name(y <- substitute(package)))
            package <- as.character(y)
```

The next chunk is quite complicated and it only runs hen `topic` is missing.
```r
## If no topic was given ...
    if(missing(topic)) {
        if(!is.null(package)) {	# "Help" on package.
            ## Carter Butts and others misuse 'help(package=)' in startup
            if (interactive() && help_type == "html") {
                port <- tools::startDynamicHelp(NA)
                if (port <= 0L) # fallback to text help
                    return(library(help = package, lib.loc = lib.loc,
                                   character.only = TRUE))
                browser <- if (.Platform$GUI == "AQUA") {
                    get("aqua.browser", envir = as.environment("tools:RGUI"))
                } else getOption("browser")
 		browseURL(paste0("http://127.0.0.1:", port,
                                 "/library/", package, "/html/00Index.html"),
                          browser)
                return(invisible())
            } else return(library(help = package, lib.loc = lib.loc,
                                  character.only = TRUE))
        }
        if(!is.null(lib.loc))           # text "Help" on library.
            return(library(lib.loc = lib.loc))
        ## ultimate default is to give help on help()
        topic <- "help"; package <- "utils"; lib.loc <- .Library
    }
```
 
 If `package` is supplied, it will return  index if `package` is supplied (e.g. `help(package = "ggplot2")`), it will try to start the help server (if `help_type = "html"`)  and open up the help index for the package (located at `"/library/{package}/html/00Index.html"`). Otherwise (e.g. `help()`), it will set`topic` to "help", thus defaulting to showing the `help`'  own documentation. It also seems to include a workaround and points fingers to some Carter Butts.

Then, another chunk to support using names as `topic` (`help(help)` will show open `help`'s documentation if `help` is not a variable in the environment. 

```r
    ischar <- tryCatch(is.character(topic) && length(topic) == 1L,
                       error = function(e) FALSE)
    ## if this was not a length-one character vector, try for the name.
    if(!ischar) {
        ## the reserved words that could be parsed as a help arg:
        reserved <-
            c("TRUE", "FALSE", "NULL", "Inf", "NaN", "NA", "NA_integer_",
              "NA_real_", "NA_complex_", "NA_character_")
        stopic <- deparse1(substitute(topic))
        if(!is.name(substitute(topic)) && ! stopic %in% reserved)
            stop("'topic' should be a name, length-one character vector or reserved word")
        topic <- stopic
    }
```

Now for the main event.

```r
    paths <- index.search(topic,
                          find.package(if (is.null(package)) loadedNamespaces() else package,
			               lib.loc, verbose = verbose))
```

The highly-nested line `base::find.package(if (is.null(package)) loadedNamespaces() else package, lib.loc, verbose = verbose)` will return the paths to the relevant packages; either the provided package (if `package` is `NULL`) or all the loaded packages as listed by `loadedNamespaces()`. [[`index.search()` annotated|index.search()]] will, then, search for the topic in the relevant paths. 

Then, a final relevant chunk. `help` might run `index.search` a second time if needed. 

```r
try.all.packages <- !length(paths) && is.logical(try.all.packages) &&
        !is.na(try.all.packages) && try.all.packages && is.null(package) && is.null(lib.loc)
    if(try.all.packages) {
        ## Try all the remaining packages.
        for(lib in .libPaths()) {
            packages <- .packages(TRUE, lib)
            packages <- packages[is.na(match(packages, .packages()))]
            paths <- c(paths, index.search(topic, file.path(lib, packages)))
        }
        paths <- paths[nzchar(paths)]
    }
```

This runs if
* `paths` is an empty character; this would mean that no help page was found for `topic` in the relevant packages,
*  `try.all.packages`is `TRUE` (I think `is.logical(try.all.packages) && !is.na(try.all.packages) && try.all.packages` could now be replaced by `isTRUE(try.all.packages)`), 
* the user didn't specify any package (`is.null(package)`), and
* the user didn't specify a particular library location to search (`is.null(lib.loc)`). 

In default and common use, `getOption(try.all.packages)` is `FALSE` so `help()` will usually not search again if it didn't find anything in loaded packages or in packages specified by the user. 

Finally, `help` returns the found paths wrapped in a structure of class `help_files_with_topic` which also has information on the topic searched for, help type and if all packages were searched. 

```r
    structure(unique(paths),
	      call = match.call(), 
	      topic = topic,
	      tried_all_packages = try.all.packages, 
	      type = help_type,
	      class = "help_files_with_topic")
}
```

For example,  calling `help(mean)` will return this:

``` r
str(help(mean))
#>  'help_files_with_topic' chr "/opt/R/4.3.2/lib/R/library/base/help/mean"
#>  - attr(*, "call")= language help(topic = mean)
#>  - attr(*, "topic")= chr "mean"
#>  - attr(*, "tried_all_packages")= logi FALSE
#>  - attr(*, "type")= chr "text"
```

Interestingly, `/opt/R/4.3.2/lib/R/library/base/help/mean` is not a valid file. The location for the documentation is `opt/R/4.3.2/lib/R/library/base/help` and `mean` is the alias of the topic, which is not necessarily the same: 

``` r
str(help("as.numeric"))
#>  'help_files_with_topic' chr "/opt/R/4.3.2/lib/R/library/base/help/numeric"
#>  - attr(*, "call")= language help(topic = "as.numeric")
#>  - attr(*, "topic")= chr "as.numeric"
#>  - attr(*, "tried_all_packages")= logi FALSE
#>  - attr(*, "type")= chr "text"
```

Now, when this object is returned to the console, it's printed by default, which then calls `utils:::print.help_files_with_topic()`. 