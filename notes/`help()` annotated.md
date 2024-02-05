```
help <- function(topic, package = NULL, lib.loc = NULL,
         verbose = getOption("verbose"),
         try.all.packages = getOption("help.try.all.packages"),
         help_type = getOption("help_type")) {
    
    types <- c("text", "html", "pdf")
    help_type <- if(!length(help_type)) "text"
		 else match.arg(tolower(help_type), types)
    if(!missing(package)) # Don't check for NULL; may be nonstandard eval
        if(is.name(y <- substitute(package)))
            package <- as.character(y)
            
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

## -- Here help() searches for the topic using utils:::index.search(). 

    paths <- index.search(topic,
                          find.package(if (is.null(package)) loadedNamespaces() else package,
			               lib.loc, verbose = verbose))
    try.all.packages <- !length(paths) && is.logical(try.all.packages) &&
        !is.na(try.all.packages) && try.all.packages && is.null(package) && is.null(lib.loc)
    if(try.all.packages) {
        ## Try all the remaining packages.

## -- This should not search all translations; only relevant (as per the language argument)

        for(lib in .libPaths()) {
            packages <- .packages(TRUE, lib)
            packages <- packages[is.na(match(packages, .packages()))]
            paths <- c(paths, index.search(topic, file.path(lib, packages)))
        }
        paths <- paths[nzchar(paths)]
    }
    
## Idea1: modify utils:::index.search() to also return hits in translated packages. 
	* Probably this would need a new argument to index.search() as to not change other functions that use it and might expect a single result. 

## Idea2: for each result in paths, get the package, search for installed translations that match the language and then do the search again. This should be done here, after the try.all.packages pass. 

## Idea3: change the list of paths to search to include translations of loadedNamespaces(). 

## In any case, the code here should be modified to not include translations in 


    structure(unique(paths),
	      call = match.call(), topic = topic,
	      tried_all_packages = try.all.packages, type = help_type,
	      class = "help_files_with_topic")
}
```