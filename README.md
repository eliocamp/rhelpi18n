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

### Initial experiment

Setting the LANGUAGE environmental variable to "es" will change your R language. 

```r
library(rhelpi18n)
Sys.setenv(LANGUAGE = "es")
```

Now `base::mean()`'s help page will be displayed in Spanish.

It will be the case for each and every packages if you have installed the relevant translation.

### Make it permanent 

If you love it, you don't want to remember to load the package name at every restart, 
so you can make it permanent through
```r
usethis::edit_r_profile()
```
and add the following line in your Rprofile (Work in progress)
```r
# added for {rhelp18n} to use local LANGUAGE for R help and and packages help
# library(rhelp18n)

```

<video style="max-height:640px; min-height: 200px" controls>
  <source src="https://github.com/eliocamp/rhelpi18n/assets/8617595/be3038dd-ac53-4fa7-a0bf-51a5de9a91bf" type="video/mp4">
</video>

This will work with the HTML documentation displayed by R GUIs like RStudio, as well as with text documentation displayed by R in the console. 

## For package developers

First get a copy of the package you want to translate. 

Choose your translation **language** by its [ISO 2-letter code](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) eventually with a regional option using underscore:

or example Spanish would be `language = "es"`, and Argentine Spanish would be `language = "es_AR"`.

Then use `rhelpi18n::i18n_module_create()` to create a **lang** translation **module** for that **package**


```r
rhelpi18n::i18n_module_create(module_name = "package.lang", 
                              language = "lang", 
                              module_path = "path/to/module", 
                              package_path = "path/to/package")
```

The package help strings to translate are saved into `/po` folder of the new {package.lang} module.

You can find them in a aggregated `.pot` file that compatible with most translation tools.

You can now distribute it to your package translators.

After translation, get back the compiled `.mo` file and save it in the {package.lang} `/inst/po/<lang>/__TBD__` direcotry.

Build the package and test. 

That's it.

## For package translators

Use your preferred translation tool, like Poedit to open the `.pot` file, 
and create a new translation in the desired language.

Translate all the lines and save the translation `.po` file. If available within the translation tool,
compile your translation into a `.mo` file, and send it back to 
the package translator.

**Problems**

1. It's not clear that the page is a translation and not the "official" one. 
2. It's not possible to access the original documentation without changing the LANGUAGE environmental variable and opening the help page again. 
3. There are some formatting issues, such as the `...` argument name. 
4. What to do with the `.mo` file ? 
  - locate it in {package.lang} `/inst/po/<lang>/` ?
  - how could gettext be hit when calling `help()` ?

