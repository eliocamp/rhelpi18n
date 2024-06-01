#' Reformats the Rd structure
#'
#' The Rd structure returned by `tools::parse_Rd` and `utils::.getHelpfile()`
#' can to nested and is not ideal for translation. `rd_flatten` "flattens"
#' that structure into a simpler list and `rd_unflatten` goes back to the original
#' structure.
#'
#' @param Rd a parsed Rd file returned by `tools::parse_Rd` or
#' `utils::.getHelpfile()`.
#' @param untranslatable character vector of fields that should not be translated.
#'
#' @keywords internal
rd_flatten <- function(Rd,
                       untranslatable = c(
                         "alias",
                         "name",
                         "keyword",
                         "concept",
                         "usage"
                       )) {
  # Convert every top-level element to text.
  list <- lapply(Rd, make_text, untranslatable = untranslatable)

  names(list) <- rd_tags(Rd)
  list <- Filter(function(x) !is.null(x), list)
  attr(list, "untranslatable") <- untranslatable

  class(list) <- rd_flat_class
  list
}

rd_flat_class <- "rhelpi18n_rd_flat"

make_text <- function(x, untranslatable) {
  tag <- attr(x, "Rd_tag")
  not_save <- c("COMMENT", "TEXT")
  if (tag %in% not_save) {
    return(NULL)
  }

  ## Here I treat the arguments section differently.
  ## Maybe a better way would be to correctly parse \item{}{}
  ## elements

  if (tag != "\\arguments") {
    text <- vapply(x, to_text, FUN.VALUE = character(1))
    text <- remove_newlines(paste(text, collapse = ""))
    if (tag %in% paste0("\\", untranslatable)) {
      return(text)
    }
    return(list(original = text,
                translation = NULL))
  }
  text <- lapply(x, function(y) {
    tag <- attr(y, "Rd_tag")

    if (tag == "\\item") {
      description <- list(original = to_text(y[[2]]),
                          translation = NULL)
      attr(description, "name") <- to_text(y[[1]])
      return(description)
    }
    return(NULL)
  })

  text <- text[!vapply(text, is.null, FUN.VALUE = logical(1))]

  names <- vapply(text, function(x) attr(x, "name"), FUN.VALUE = character(1))
  names(text) <- names
  return(text)
}



remove_newlines <- function(x) {
  gsub("^\\n", "", x)
}



## Creates text, including tags and options to each section.
## Should be applied to:
## 1. each section
## 2. each argument name
## 3. each description
to_text <- function(x) {
  tag <- attr(x, "Rd_tag")

  if (is.character(x) ||  !is.null(tag) && !startsWith(tag, "\\")) {
    return(x[[1]])
  }

  inner <- vapply(x, to_text, FUN.VALUE = character(1))

  if (!is.null(tag)) {

    option <- attr(x, "Rd_option")
    if (!is.null(option)) {
      option <- paste0("[", option, "]")
    }
    inner <- paste(inner, collapse = "}{")
    return(paste0(tag, option, "{", inner, "}"))
  }

  inner <- paste(inner, collapse = "")
  return(inner)
}

rd_tags <- function(help_db) {
  tags <- vapply(help_db, function(x) attr(x, "Rd_tag"), FUN.VALUE = character(1))
  gsub("\\\\", "", tags)
}
