<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

# Internationalisation of R help pages

This repository documents a proposal to support internationalisation of R help pages.

This project started at the 2023 R Project Sprint.
More [in this issue](https://github.com/r-devel/r-project-sprint-2023/issues/35).

## For users

Install this package:

``` r
pak::pak("eliocamp/rhelpi18n")
```

Next install a translation module. 
The [base.es](https://github.com/eliocamp/base.es) package hosts translations for `base::mean()` as an example, install it with

``` r
pak::pak("eliocamp/base.es")
```

Setting the LANGAUGE environmental variable to "es" will change your R language. 

```r
library(rhelpi18n)
Sys.setenv(LANGUAGE = "es")
```

Now `base::mean()`'s help page will be displayed in Spanish.

https://github.com/eliocamp/rhelpi18n/assets/8617595/be3038dd-ac53-4fa7-a0bf-51a5de9a91bf

This will work with the HTML documentation displayed by R GUIs like RStudio, as well as with text documentation displayed by R in the console. 

## For developers

First get a copy of the package you want to translate. 
Then use `rhelpi18n::i18n_module_create()` to create a translation module for that package


```r
rhelpi18n::i18n_module_create(module_name = "package.lang", 
                              language = "lang", 
                              module_path = "path/to/module", 
                              package_path = "path/to/package")
```

The translation string are saved as yaml files in "path/to/module/translations" with this format:

```yaml
title:
  original: Title in the original language
  translation: ~
```

add your translation to the `translation` field. 
Build the package and test. 

That's it.


**Problems**

1. It's not clear that the page is a translation and not the "official" one. 
2. It's not possible to access the original documentation without changing the LANGUAGE environmental variable and opening the help page again. 
3. There are some formatting issues, such as the `...` argument name. 

