#' Extract componet of a path
#'
#' @param path a vector of paths
#' @param depth positive integer indicating the component to extract.
#' 0 means the last component, 1 means its parent and so on.
path_component <- function(path, depth = 0) {
  if (depth == 0) {
    return(basename(path))
  } else {
    return(path_component(dirname(path), depth = depth - 1))
  }
}

