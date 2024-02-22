sudo_assignInNamespace <- function (x, value, ns, pos = -1, envir = as.environment(pos))  {
  nf <- sys.nframe()
  if (missing(ns)) {
    nm <- attr(envir, "name", exact = TRUE)
    if (is.null(nm) || substr(nm, 1L, 8L) != "package:")
      stop("environment specified is not a package")
    ns <- asNamespace(substring(nm, 9L))
  }
  else ns <- asNamespace(ns)
  ns_name <- getNamespaceName(ns)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # This bit of code was used in the original 'assignInNamespace' to stop
  # you from futzing with standard packages.
  # I am evil and going to ignore this limitation
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # if (nf > 1L) {
  #   if (ns_name %in% tools:::.get_standard_package_names()$base)
  #     stop("locked binding of ", sQuote(x), " cannot be changed",
  #          domain = NA)
  # }

  if (bindingIsLocked(x, ns)) {
    in_load <- Sys.getenv("_R_NS_LOAD_")
    if (nzchar(in_load)) {
      if (in_load != ns_name) {
        msg <- gettextf("changing locked binding for %s in %s whilst loading %s",
                        sQuote(x), sQuote(ns_name), sQuote(in_load))
        if (!in_load %in% c("Matrix", "SparseM"))
          warning(msg, call. = FALSE, domain = NA, immediate. = TRUE)
      }
    }
    else if (nzchar(Sys.getenv("_R_WARN_ON_LOCKED_BINDINGS_"))) {
      warning(gettextf("changing locked binding for %s in %s",
                       sQuote(x), sQuote(ns_name)), call. = FALSE, domain = NA,
              immediate. = TRUE)
    }
    unlockBinding(x, ns)
    assign(x, value, envir = ns, inherits = FALSE)
    w <- options("warn")
    on.exit(options(w))
    options(warn = -1)
    lockBinding(x, ns)
  }
  else {
    assign(x, value, envir = ns, inherits = FALSE)
  }
  if (!isBaseNamespace(ns)) {
    S3 <- .getNamespaceInfo(ns, "S3methods")
    if (!length(S3))
      return(invisible(NULL))
    S3names <- S3[, 3L]
    if (x %in% S3names) {
      i <- match(x, S3names)
      genfun <- get(S3[i, 1L], mode = "function", envir = parent.frame())
      if (.isMethodsDispatchOn() && methods::is(genfun,
                                                "genericFunction"))
        genfun <- methods::slot(genfun, "default")@methods$ANY
      defenv <- if (typeof(genfun) == "closure")
        environment(genfun)
      else .BaseNamespaceEnv
      S3Table <- get(".__S3MethodsTable__.", envir = defenv)
      remappedName <- paste(S3[i, 1L], S3[i, 2L], sep = ".")
      if (exists(remappedName, envir = S3Table, inherits = FALSE))
        assign(remappedName, value, S3Table)
    }
  }
  invisible(NULL)
}
