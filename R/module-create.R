#' Creates a translation module
#'
#' Creates a translation module skeleton form a source package with the
#' translation templates with the original strings and the proper
#' functions to load translations.
#'
#' @param module_name Name of the translation module. It needs to be a valid
#' package name. If missing, it will be created as the name of the package.language.
#' @param package_path Path to the package that will be translated.
#' @param language Language of the translation module
#' @param path Path where the module will be created.
#' @param rstudio_project Logical indicating whether to create an .Rproj file.
#'
#' @export
i18n_module_create <- function(module_name = NULL, package_path, language, path,
                                   rstudio_project = TRUE) {

  package <- get_package_name(package_path)
  version <- get_package_version(package_path)

  if (is.null(module_name)) {
    module_name <- paste(package, language, sep = ".")
  }

  if (!valid_package_name(module_name)) {
    stop(module_name, " is not a valid package name")
  }

  module_path <- file.path(path, module_name)

  if (rstudio_project) {
    rstudio_project <- module_name
  } else {
    rstudio_project <- NULL
  }

  copy_pkg_template(module_path, rstudio_project = rstudio_project)

  modify_description(module_path, module_name = module_name, package = package,
                     version = version, language = language)

  rd_files <- list.files(file.path(package_path, "man"), pattern = "*.Rd", full.names = TRUE)

  i18n_translation_templates(rd_files, file.path(module_path, "po", paste0("R-", module_name, ".pot")))

  for (file in rd_files) {
    file.copy(file, file.path(module_path, "man_original", basename(file)))
  }

}

get_package_name <- function(package_path) {
  description_file <- file.path(package_path, "DESCRIPTION")
  read.dcf(description_file, fields = "Package")[[1]]
}

get_package_version <- function(package_path) {
  description_file <- file.path(package_path, "DESCRIPTION")
  read.dcf(description_file, fields = "Version")[[1]]
}

copy_pkg_template <- function(path, rstudio_project = TRUE) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  empty <- length(list.files(path)) == 0
  if (!empty) {
    stop("Path to module exists and it's not empty.")
  }

  skeleton <- system.file("extdata", "translation_skeleton.zip", package = "rhelpi18n")

  utils::unzip(skeleton, exdir = path)

  if (is.null(rstudio_project)) {
    file.remove(file.path(path, "skeleton.Rproj"))
  } else {
    file.rename(file.path(path, "skeleton.Rproj"),
                file.path(path, paste0(rstudio_project, ".Rproj")))
  }
  return(path)
}

modify_description <- function(path, module_name, package, version, language) {
  description_file <- file.path(path, "DESCRIPTION")
  description_template <- paste0(readLines(description_file), collapse = "\n")

  description_text <- whisker::whisker.render(description_template, data = list(
    module_name = module_name,
    package_version = paste0(package, " (== ", version, ")"),
    language = language
  ))
  writeLines(description_text, description_file)
}


# from usethis:::valid_package_name
valid_package_name <- function (x) {
  grepl("^[a-zA-Z][a-zA-Z0-9.]+$", x) && !grepl("\\.$", x)
}


