help_i18n <- function (topic, package = NULL, lib.loc = NULL, verbose = getOption("verbose"),
          try.all.packages = getOption("help.try.all.packages"), help_type = getOption("help_type")) {
  types <- c("text", "html", "pdf")
  help_type <- if (!length(help_type))
    "text"
  else match.arg(tolower(help_type), types)
  if (!missing(package))
    if (is.name(y <- substitute(package)))
      package <- as.character(y)
  if (missing(topic)) {
    if (!is.null(package)) {
      if (interactive() && help_type == "html") {
        port <- tools::startDynamicHelp(NA)
        if (port <= 0L)
          return(library(help = package, lib.loc = lib.loc,
                         character.only = TRUE))
        browser <- if (.Platform$GUI == "AQUA") {
          get("aqua.browser", envir = as.environment("tools:RGUI"))
        }
        else getOption("browser")
        browseURL(paste0("http://127.0.0.1:", port,
                         "/library/", package, "/html/00Index.html"),
                  browser)
        return(invisible())
      }
      else return(library(help = package, lib.loc = lib.loc,
                          character.only = TRUE))
    }
    if (!is.null(lib.loc))
      return(library(lib.loc = lib.loc))
    topic <- "help"
    package <- "utils"
    lib.loc <- .Library
  }
  ischar <- tryCatch(is.character(topic) && length(topic) ==
                       1L, error = function(e) FALSE)
  if (!ischar) {
    reserved <- c("TRUE", "FALSE", "NULL", "Inf", "NaN",
                  "NA", "NA_integer_", "NA_real_", "NA_complex_",
                  "NA_character_")
    stopic <- deparse1(substitute(topic))
    if (!is.name(substitute(topic)) && !stopic %in% reserved)
      stop("'topic' should be a name, length-one character vector or reserved word")
    topic <- stopic
  }
  paths <- utils:::index.search(topic, find.package(if (is.null(package))
    loadedNamespaces()
    else package, lib.loc, verbose = verbose))
  try.all.packages <- !length(paths) && is.logical(try.all.packages) &&
    !is.na(try.all.packages) && try.all.packages && is.null(package) &&
    is.null(lib.loc)
  if (try.all.packages) {
    for (lib in .libPaths()) {
      packages <- .packages(TRUE, lib)
      packages <- packages[is.na(match(packages, .packages()))]
      paths <- c(paths, utils:::index.search(topic, file.path(lib,
                                                      packages)))
    }
    paths <- paths[nzchar(paths)]
  }
  structure(unique(paths), call = match.call(), topic = topic,
            tried_all_packages = try.all.packages, type = help_type,
            class = "help_files_with_topic")
}
