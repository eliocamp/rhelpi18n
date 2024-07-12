#' Translates an Rd object
#'
#' Takes an object returned by `[tools::parse_Rd]` and `utils::.getHelpfile()`
#' and translates the strings.
#'
#' @param Rd Rd object
#' @param translation a flattened rd object returned by `[rd_flatten]` or,
#' more likely, by `[rd_flat_read]`.
#'
#' @returns an Rd object with translated strings.
#' @keywords internal
rd_translate <- function(Rd, translation) {
  Rd <- rd_flatten(Rd)

  translated <- translate(Rd, translation)

  rd_unflatten(translated)
}



translate <- function(original, translation) {
  sections <- names(translation)
  for (section in sections)  {

    if (is.character(original[[section]]$original)) {
      version_matches <- original[[section]]$original == translation[[section]]$original
      translation_exists <- !is.null(translation[[section]]$translation)

      if (version_matches && translation_exists) {
        if (section %in% c("examples", "title")) {
          original[[section]] <- paste0(
            translation[[section]]$translation,
            "\\if{html}{\\out{<details style='display:inline'> <summary>} 🌐 \\out{</summary>} ",
            original[[section]]$original,
            "\\out{</details>}}")
        } else {
          original[[section]] <- translation[[section]]$translation
        }

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

