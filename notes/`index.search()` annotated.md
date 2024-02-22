`index.search()` is called from [[`help()` annotated|help()]] with the topic and the paths to the relevant packages. It's source code can be found here: https://github.com/r-devel/r-svn/blob/7443ac74ccaa5e780273b1eb308eaf4b7a7e89f4/src/library/utils/R/indices.R#L201

```r
## used with firstOnly = TRUE for example()
## used with firstOnly = FALSE in help()
index.search <- function(topic, paths, firstOnly = FALSE) {
```

`firstOnly` is a flag to indicate it to return the first result. As the comments indicate, `help()` uses the default `FALSE`. `paths` are the location of the relevant packages. 

The actual code is relatively simple

```r
 res <- character()
    for (p in paths) {
        if(file.exists(f <- file.path(p, "help", "aliases.rds")))
            al <- readRDS(f)
        else if(file.exists(f <- file.path(p, "help", "AnIndex"))) {
            ## aliases.rds was introduced before 2.10.0, as can phase this out
            foo <- scan(f, what = list(a="", b=""), sep = "\t", quote = "",
                        na.strings = "", quiet = TRUE)
            al <- structure(foo$b, names = foo$a)
        } else next
        f <- al[topic]
        if(is.na(f)) next
        res <- c(res, file.path(p, "help", f))
        if(firstOnly) break
    }
    res
}
```

It goes through every package and reads the `/help/aliases.rds` file. This rds object is just a named character vector listing all the aliases defined in the package documentation. For example:

``` r
readRDS(file.path(find.package("glue"), "help", "aliases.rds"))
#>                as_glue               backtick           double_quote 
#>              "as_glue"              "quoting"              "quoting" 
#>                   glue        glue-deprecated               glue_col 
#>                 "glue"      "glue-deprecated"             "glue_col" 
#>          glue_collapse              glue_data          glue_data_col 
#>        "glue_collapse"                 "glue"             "glue_col" 
#>         glue_data_safe          glue_data_sql              glue_safe 
#>            "glue_safe"             "glue_sql"            "glue_safe" 
#>               glue_sql      glue_sql_collapse   identity_transformer 
#>             "glue_sql"        "glue_collapse" "identity_transformer" 
#>                quoting           single_quote                   trim 
#>              "quoting"              "quoting"                 "trim"
```

A small detail is that apparently this file might not exist, in which case `index.search()` will fallback to an `AnIndex` file. This is a plain-text version of aliases.rds. 

``` r
readLines(file.path(find.package("glue"), "help", "AnIndex"))
#>  [1] "as_glue\tas_glue"                          
#>  [2] "backtick\tquoting"                         
#>  [3] "double_quote\tquoting"                     
#>  [4] "glue\tglue"                                
#>  [5] "glue-deprecated\tglue-deprecated"          
#>  [6] "glue_col\tglue_col"                        
#>  [7] "glue_collapse\tglue_collapse"              
#>  [8] "glue_data\tglue"                           
#>  [9] "glue_data_col\tglue_col"                   
#> [10] "glue_data_safe\tglue_safe"                 
#> [11] "glue_data_sql\tglue_sql"                   
#> [12] "glue_safe\tglue_safe"                      
#> [13] "glue_sql\tglue_sql"                        
#> [14] "glue_sql_collapse\tglue_collapse"          
#> [15] "identity_transformer\tidentity_transformer"
#> [16] "quoting\tquoting"                          
#> [17] "single_quote\tquoting"                     
#> [18] "trim\ttrim"
```

Finally, if the alias with the topic name exists, the result is appended with the path of the documentation folder of the package and the alias of the topic. 
