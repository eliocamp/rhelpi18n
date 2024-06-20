#' Read translations from a directory
#'
#' @export
read_translations <- function() {
  files <- list.files("translations/", full.names = TRUE)
  translations <- lapply(files, rd_flat_read)
  names(translations) <- tools::file_path_sans_ext(basename(files))
  translations
}
