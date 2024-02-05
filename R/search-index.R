# From utils
index.search <- function (topic, paths, firstOnly = FALSE)  {
  res <- character()
  for (p in paths) {
    if (file.exists(f <- file.path(p, "help", "aliases.rds")))
      al <- readRDS(f)
    else if (file.exists(f <- file.path(p, "help", "AnIndex"))) {
      foo <- scan(f, what = list(a = "", b = ""), sep = "\t",
                  quote = "", na.strings = "", quiet = TRUE)
      al <- structure(foo$b, names = foo$a)
    }
    else next
    f <- al[topic]
    if (is.na(f))
      next
    res <- c(res, file.path(p, "help", f))
    if (firstOnly)
      break
  }
  res
}
