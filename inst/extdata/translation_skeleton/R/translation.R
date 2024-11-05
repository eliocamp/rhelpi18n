rd_flat_read <- function(file) {
  rd_flat <- yaml::read_yaml(file)
  attr(rd_flat, "untranslatable") <- rd_flat[["untranslatable"]]
  rd_flat[["untranslatable"]] <- NULL
  rd_flat
}


#' @export
translations <- (function() {
  files <- list.files("translations/", full.names = TRUE)
  translations <- lapply(files, rd_flat_read)
  names(translations) <- tools::file_path_sans_ext(basename(files))
  translations
})()
