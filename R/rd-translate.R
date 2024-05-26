#' Read a translated file
#'
#' Reads a yaml file with translations into a list. This list will then be used
#' to translate the strings at runtime.
#'
#' @param file Yaml file with translations
#'
#' @export
rd_flat_read <- function(file) {
  rd_flat <- yaml::read_yaml(file)
  attr(rd_flat, "untranslatable") <- rd_flat[["untranslatable"]]
  rd_flat[["untranslatable"]] <- NULL
  class(rd_flat) <- "Rd_flat"
  rd_flat
}


section2char <- function(x) {
  if (is.character(x)) {
    return(x)
  }

  paste(paste0("\\item{", names(x), "}{", unlist(x), "}"),
        collapse = "\n")
}

list2rdtext <- function(x) {
  texts <- vapply(x, section2char, FUN.VALUE = character(1))

  paste(paste0("\\", names(x), "{", texts, "}"),
        collapse = "\n")
}

rd_unflatten <- function(rd_flat) {
  text <- list2rdtext(rd_flat)
  file <- tempfile()
  writeLines(text, file)
  tools::parse_Rd(file)
}


translate <- function(original, translation) {
  sections <- names(translation)
  for (section in sections)  {

    if (is.character(original[[section]]$original)) {
      version_matches <- original[[section]]$original == translation[[section]]$original
      translation_exists <- !is.null(translation[[section]]$translation)

      if (version_matches && translation_exists) {
        original[[section]] <- translation[[section]]$translation
      } else {
        # If the translation is out of date?
        # For now, keep the original
        original[[section]] <- original[[section]]$original
      }
    }

    if (is.list(original[[section]])) {
      original[[section]] <- translate(original[[section]], translation[[section]])

    }

  }
  return(original)
}

