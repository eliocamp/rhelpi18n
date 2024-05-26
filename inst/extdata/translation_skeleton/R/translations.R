read_translations <- function() {
  files <- list.files("translations/", full.names = TRUE)
  translations <- lapply(files, rhelpi18n::rd_flat_read)
  names(translations) <- tools::file_path_sans_ext(basename(files))
  translations
}

#' @export
translations <- read_translations()
