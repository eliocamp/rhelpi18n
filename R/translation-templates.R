#' Creates a po templates for translation
#'
#' Grabs .Rd files and creates a .pot file ready to translate.
#'
#' @param rd_files character vector of rd files.
#' @param pot_file full path of the PO template file to create. dirname of the
#' `pot_file` will be created if needed.
#'
#' @examples
#' rd_files <- system.file("extdata", "periodic.Rd", package = "rhelpi18n")
#' pot_file <- tempfile()
#' i18n_translation_templates(rd_files, pot_file)
#'
#' @export
i18n_translation_templates <- function(rd_files, pot_file) {
  invalid_files <- !file.exists(rd_files)

  if (any(invalid_files)) {
    stop("Some files don't exist")
  }

  dir.create(dirname(pot_file), showWarnings = FALSE, recursive = TRUE)

  pos <- vapply(rd_files, i18n_translation_template, FUN.VALUE = character(1))

  writeLines(pos, pot_file, sep = "\n \n")
}

i18n_translation_template <- function(rd_file) {
  context <- tools::file_path_sans_ext(basename(rd_file))
  rd_parsed <- tools::parse_Rd(rd_file)
  rd_flatten <- rd_flatten_po(rd_parsed)
  write_string(rd_flatten, context)
}

