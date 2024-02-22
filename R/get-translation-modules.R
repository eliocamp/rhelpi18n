add_and_load_translations <- function(packages, language) {
  if (!is.null(language)) {
    translations <- get_translation_modules(packages, language)
    for (t in translations) loadNamespace(t)   ## Need to load the namespace
    packages <- c(packages, translations)
  }

  return(packages)
}

#' @export
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
resolve_lang <- function(languages, target_language) {
  languages == target_language
}
