# Internationalisation of R help pages

This repository documents a proposal to support internationalisation of R help pages.

This project started at the 2023 R Project Sprint.
More [in this issue](https://github.com/r-devel/r-project-sprint-2023/issues/35).

## Working prototype

Translations are hosted in "translation modules", which are regular packages. 
For now, these are in an exported object called `translations`. 

The [dummy.es](https://github.com/eliocamp/ri18n-dummy.es) package hosts translations for `base::mean()`. 

Install both packages and this one with

``` r
pak::pak(c("eliocamp/rhelpi18n", "eliocamp/ri18n-dummy.es"))
```

Loading rhelpi18n will modify the internal R function that retrieves help pages to enable translation.
Setting the LANGAUGE environmental variable to "es" will change your R language. 

```r
library(rhelpi18n)
Sys.setenv(LANGUAGE = "es")
```

Now `base::mean()`'s help page will be displayed in Spanish.

![Video of RStudio GUI. The help("mean") displays help's documentation in Enslihg. Then, after running library(rhelpi18n9 and Sys.setenv(LANGUAGE = "es"), help("mean") shows the documentation in Spanish.](images/ayuda-2024-02-22_19.10.05.mp4)

This will work with the HTML documentation displayed by R GUIs like RStudio, as well as with text documentation displayed by R in the console. 

**Problems**

1. It's not clear that the page is a translation and not the "official" one. 
2. It's not possible to access the original documentation without changing the LANGUAGE environmental variable and opening the help page again. 
3. There are some formatting issues, such as the `...` argument name. 

