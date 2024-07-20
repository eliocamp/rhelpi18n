#' create a .po file out of a Rd help topic
#'
#' @param topic the .Rd help topic
#'
#' @param package the package to find the Rd file in
#'
#' @export
#' @examples
#'  po_extract_topic("verbatim_logical", "yaml")
po_extract_topic <- function(topic, package) {
  stopifnot("`package` is mandatory, with no default" = !is.na(package))
  # create po/ folder if not exists
  fs::dir_create("po")
  utils:::.getHelpFile(utils:::index.search(topic, find.package(package))) |>
    rd_flatten_po() |>
    write_string(context = topic) |>
    writeLines(glue::glue("po/{topic}.pot"))

}

#' convert an help content into .po compatible line format
#'
#' @param Rd list of function help entries as a result of utils:::.getHelpFile(help(function))
#' @param untranslatable vector of untranslatable words, default to help page section titles.
#'
#' @return a list of po file entries to be parsed by write_string()
#' @noRd
#'
#' @examples
#' utils:::.getHelpFile(help("mean")) |>
#'   rd_flatten_po() |>
#'   write_string(context = "mean") |>
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
  context <- unname(vapply(names(strings), function(x) paste0(c(context, x), collapse = " "),
                           FUN.VALUE = character(1)))


  po <- vapply(seq_along(strings), function(i) {
    po <- write_string(strings[[i]],
                       context = context[[i]])
    paste0(po, collapse = "\n")
  }, FUN.VALUE = character(1)) |>
    paste0(collapse = "\n \n")

  return(po)
}


