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
#' po_file <- tempfile()
#' i18n_translation_templates(rd_files, po_file)
#'
#' @export
i18n_translation_templates <- function(rd_files, po_file) {
  invalid_files <- !file.exists(rd_files)

  if (any(invalid_files)) {
    stop("Some files don't exist")
  }

  dir.create(dirname(po_file), showWarnings = FALSE, recursive = TRUE)

  pos <- vapply(rd_files, i18n_translation_template, FUN.VALUE = character(1))

  writeLines(pos, po_file, sep = "\n \n")
}

i18n_translation_template <- function(rd_file) {
  context <- tools::file_path_sans_ext(basename(rd_file))
  rd_parsed <- tools::parse_Rd(rd_file)
  rd_flatten <- rd_flatten_po(rd_parsed)
  write_string(rd_flatten, context)
}

