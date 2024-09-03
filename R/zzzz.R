.onLoad <- function(libname, pkgname){
  # We need to explicitly set language, otherwise there is a problem in RStudio:
  # error in strsplit(target_language, ":")[[1]][[1]] : subscript out of bound
  # when running resolve_lang()
  if (is.na(Sys.getenv("LANGUAGE", NA)))
    Sys.setLanguage("en")

  library(utils) # Apparently required for R CMD check despite Depends: utils ?!
  utils <- asNamespace('utils')

  package_env <- as.environment('package:utils')
  sudo_assignInNamespace(".getHelpFile", .getHelpFile, ns = utils, envir = package_env)
}
