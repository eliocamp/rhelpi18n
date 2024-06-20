#' @exaples
#' utils:::.getHelpFile(help("mean")) |>
#'   rd_flatten_po() |>
#'   write_string() |>
#'   writeLines("text.pot")
rd_flatten_po <- function(Rd,
                       untranslatable = c(
                         "alias",
                         "name",
                         "keyword",
                         "concept",
                         "usage"
                       )) {
  # Convert every top-level element to text.
  list <- lapply(Rd, make_text_po, untranslatable = untranslatable)

  names(list) <- rd_tags(Rd)
  list <- Filter(function(x) !is.null(x), list)
  attr(list, "untranslatable") <- untranslatable

  class(list) <- rd_flat_class
  list
}

make_text_po <- function(x, untranslatable) {
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
    return(text)
  }
  text <- lapply(x, function(y) {
    tag <- attr(y, "Rd_tag")

    if (tag == "\\item") {
      description <- to_text(y[[2]])
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

write_string <- function(strings, context = NULL) {
  # Base case.
  # Write the context, msgid and msgstr
  if (is.character(strings)) {
    strings <- gsub("\n", "\"\n\"", strings, perl = TRUE)
    return(paste0(c(paste0("msgctxt \"", context, "\""),
                    paste0("msgid \"", strings, "\""),
                    "msgstr \"\""),
                  collapse = "\n"))
  }

  # Else, write each element, adding the context
  context <- unname(vapply(names(strings), function(x) paste0(c(context, x), collapse = "."),
                           FUN.VALUE = character(1)))


  po <- vapply(seq_along(strings), function(i) {
    po <- write_string(strings[[i]],
                       context = context[[i]])
    paste0(po, collapse = "\n")
  }, FUN.VALUE = character(1)) |>
    paste0(collapse = "\n \n")

  return(po)
}


