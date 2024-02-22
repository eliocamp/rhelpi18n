.onLoad <- function(libname, pkgname){
  utils <- asNamespace('utils')

  package_env <- as.environment('package:utils')
  sudo_assignInNamespace(".getHelpFile", .getHelpFile, ns = utils, envir = package_env)
}
