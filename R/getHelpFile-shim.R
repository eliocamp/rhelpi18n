.getHelpFile <- function(file, language = Sys.getenv("LANGUAGE")) {
  path <- dirname(file)
  dirpath <- dirname(path)
  if(!file.exists(dirpath))
    stop(gettextf("invalid %s argument", sQuote("file")), domain = NA)
  pkgname <- basename(dirpath)
  RdDB <- file.path(path, pkgname)
  if(!file.exists(paste0(RdDB, ".rdx")))
    stop(gettextf("package %s exists but was not installed under R >= 2.10.0 so help cannot be accessed", sQuote(pkgname)), domain = NA)

  rd <- tools:::fetchRdDB(RdDB, basename(file))
  if (is.null(language)) {
    return(rd)
  }
  name <- basename(file)
  translation_modules <- get_translation_modules(pkgname, language = language)
  if (length(translation_modules) == 0) {
    return(rd)
  }

  translations <- get("translations", envir = asNamespace(translation_modules[1]))[[name]]

  if (is.null(translations)) {
    return(rd)
  }

  rd <- rd_translate(rd, translations)

  return(rd)
}

rd_translate <- function(Rd, translation) {
  untranslatable <- attr(translation, "untranslatable")
  Rd <- rd_flatten(Rd)

  translation <- translation[!(names(translation) %in% untranslatable)]

  translated <- translate(Rd, translation)

  rd_unflatten(translated)
}


get_translation_modules <- function(packages, language) {
  stopifnot(!missing(packages))
  stopifnot(length(language) == 1)   # TODO: eventually relax this

  # Get all translation modules
  installed <- utils::installed.packages(fields = c("Translates", "Language"))
  translations <- installed[!is.na(installed[, "Translates"]), , drop = FALSE]

  # Filter for the language
  translations <- translations[resolve_lang(translations[, "Language"], language), , drop = FALSE]

  # Filter for the package
  modules <- character(0)
  for (i in seq_len(nrow(translations))) {
    translates <- pkgload::parse_deps(translations[i, "Translates"])[["name"]]
    if (translates %in% packages) {
      modules <- c(modules, translations[i, "Package"])
    }
  }

  return(modules)
}

## TODO: needs to take into account the ISO hierarchy.
## i.e.: if target_language is "es-AR", then "es" is good, but "es-AR" is better.
## if target language is "es", then "es-AR" is also good.
## Issue: https://github.com/eliocamp/rhelpi18n/issues/9
resolve_lang <- function(languages, target_language) {
  languages == target_language
}
