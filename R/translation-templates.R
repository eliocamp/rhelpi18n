#' Creates templates for translation
#'
#' Grabs .Rd files and creates yaml templates to then translate.
#'
#' @param rd_files character vector of rd files.
#' @param folder folder where to save the templates. Will be created if it
#' doesn't exist.
#'
#' @examples
#' rd_files <- system.file("extdata", "periodic.Rd", package = "rhelpi18n")
#' template_folder <- tempdir()
#' i18n_translation_templates(rd_files, template_folder)
#'
#' @export
i18n_translation_templates <- function(rd_files, folder) {
  invalid_files <- !file.exists(rd_files)

  if (any(invalid_files)) {
    stop("Some files don't exist")
  }

  dir.create(folder, showWarnings = FALSE, recursive = TRUE)

  base_names <- tools::file_path_sans_ext(basename(rd_files))
  template_files <- file.path(folder, paste0(base_names, ".yaml"))

  mapply(i18n_translation_template, rd_files,  template_files)
}

i18n_translation_template <- function(rd_file, template_file) {
  rd_parsed <- tools::parse_Rd(rd_file)
  rd_flatten <- rd_flatten(rd_parsed)
  rd_flat_write(rd_flatten, template_file)
  template_file
}

