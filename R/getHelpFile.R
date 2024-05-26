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

