## The Problem

R's help system is one of the great features of the language.
Usage, description and examples are available right there in the console.
It is important that this documentation is correct and useful both in the core packages and in the general contributed packages ecosystem.
To that aim, CRAN enforces a suite of policies on documentation, such as all exported object having documentation, all arguments being documented, etc.

Besides meeting those technical requirements, documentation needs to also be accessible to end users to be useful.
This involves clear and consise language, consistent style, useful examples and many other characteristics not tested by CRAN.
Not trivially, it also requires being written in a language the user actually understands.

English is currently the de-facto international language and this is reflected in R function and variable names, like how the `mean()` function is not called `promedio()` or `Mittelwert()` and documentation language.
And while contributed packages have a "Language" field and can be documented in other languages, the vast majority of contributed packages are documented in English.

There is [a small number of packages documented in other languages](https://cderv.rbind.io/2018/03/11/non-english-pkg-in-cran/), presumably in accordance to their target audience.
For example, [labstatR](https://cran.r-project.org/web/packages/labstatR/index.html) is a companion package for the italian book Laboratorio Di Statistica Con R and is documented in Italian.
The [chilemapas](https://cran.r-project.org/web/packages/chilemapas/chilemapas.pdf) package provides various simplified maps for Chile and it's documentation and function names are in Spanish.

Packages documented in non-English languages can be more accessible for their intended populations, but they are much less accessible to the wider community.
Useful functions/algorithms implemented in those packages would be hard to use for the rest of the community.
So package authors are faced with the decision of making their package inaccessible to their target demographic or isolated from the wider ecosystem.

Real cases of this issue exists.
For example, the [utilsIPEA](https://cran.r-project.org/web/packages/utilsIPEA/index.html) package is a package for the Brazilian Instituto de Pesquisa Economica Aplicada is documented in English and it's functions are a mix of English and Portuguese.
The author publicly expressed [his need for bilingual documentation](https://stackoverflow.com/questions/37288823/bilingual-english-and-portuguese-documentation-in-an-r-package):

> I am writing a package to facilitate importing Brazilian socio-economic microdata sets (Census, PNAD, etc).
> I foresee two distinct groups of users of the package:
>
> -   Users in Brazil, who may feel more at ease with the documentation in Portuguese.
>     The probably can understand English to some extent, but a foreign language would probably make the package feel less "ergonomic".
>
> -   The broader international users community, from whom English documentation may be a necessary condition.
>
> Is it possible to write a package in a way that the documentation is "bilingual" (English and Portuguese), and that the language shown to the user will depend on their country/language settings?

Moreover, CRAN hosts at least two packages that have a secondary package version with documentation in another language.
The [ExpDes](https://cran.r-project.org/web/packages/ExpDes/index.html) package has the companion package [ExpDes.pt](https://cran.r-project.org/web/packages/ExpDes.pt/index.html) with documentation in Portuguese.
Similarly, the [orloca](https://cran.r-project.org/web/packages/orloca/index.html) package is documented in Spanish in the [orloca.es](https://cran.r-project.org/web/packages/orloca.es/index.html) package.

Needless to say, this method of bilingual documentation is not recommended, as it's very hard to maintain and doesn't scale to other languages.
A better alternative would be for R to allow packages to have multilingual ocumentation.

## The solution

We propose to extend the R help system to allow for multiple help pages for the same function in different languages.
By default, `help(function)` would show the documentation in the preferred language of the user or fall-back to the canonical documentation otherwise (most likely, in English).
It would also include a link to the canonical documentation and warnings if translations are out of date.

A possible implementation would be as follows:

-   Original packages have their "canonical" help pages written in the original languages.
    (e.g. `mein_paket` is documented in German).

-   Translations are hosted in translation modules that the user can install to get the documentation in that language.
    (e.g. `mein_paket.en` would provide English documentation for `mein_paket`).
    These modules are R packages that use the PackageType field to indicate that they are a translation module (e.g. `PackageType: translation`).
    The Depends field is used to indicate the package being translated and the minimum version supported.

-   Translation modules would store .po files with the translated strings.

-   When a translation module is installed, the .Rd files of the original package are parsed and translated using `gettext()` and the .po files in the translation module and serialised into binary help pages (like regular packages have).

-   When loading a package, R will also search for installed translations and load them too.

-   `help()` gains an new "language" argument which defaults to `Sys.getenv("LANGUAGE")`.

-   `help()` searches for the loaded topics.
    If any translation is available, then it would use the `language` argument to disambiguate.

-   Help pages should include a link to the original (canonical) documentation.

More details can be found in [the rhelpi18n repository](https://github.com/eliocamp/rhelpi18n).

## The Team

-   Elio Campitelli: Maintainer of several packages published on CRAN.
    Spanish translator of rOpenSci Packages: Development, Maintenance, and Peer Review.

-   Maëlle Salmon:

-   ??

## Project Milestones

This project aims to implement parts of the system in a package as a testing ground with the idea of incorporating the functionality into R once the project matures.
The outcome, then, would be a new package that users can install to add support for multilingual documentation.

1.  Implement translation of .Rd files using .po files and `gettext()`. This first step is necessary for the whole system to work. If this fails, then we'd need to rethink the system.
    1.  Revise and possibly improve the Rd parser
    2.  Create valid .po files
    3.  use `gettext()` to replace strings
    4.  serialise the output
2.  Implement translation module installation.
3.  Modify `help()` to show help pages in the selected language.
4.  Modify the rendering of help pages to add links to the canonical documentation if needed.

At completion, users of the package will be able to install translation modules and browse documentation in different languages.

> Outline the milestones for development and how much funding will be required for each stage (as payments will be tied to project milestone completion).
> Each milestone should specify the work to be done and the expected outcomes, providing enough detail for the ISC to understand the scope of the project work and assess the likelihood of success.

## How Can The ISC Help

> Please describe how you think the ISC can help.
> If you are looking for a cash grant include a detailed itemized budget and spending plan.
> We expect that most of the budget will be allocated for labor costs.
> We do not cover indirect costs.
> The ISC grants cannot cover such things as travel, lodging, food, journal publication fees, or personal hardware.
> Cloud services may be covered if they are specific to the project and the project period.
> The ISC reserves the right to vet how funds are used for each project separately.
> If in doubt, please reach out to us.
> If you are seeking to start an ISC working group, then please describe the goals of the group and provide the name of the individual who will be committed to leading and managing the group's activities.
> Also, describe how you think the ISC can help promote your project.

## Dissemination

The results of the work will be made available as an R package with GPL3 licence (??).
All development will be done in a public GitHub repository and we will encourage contributions and discussions from the community.
We will also blog about the process in the rOpenSci blog (??).

Events

Communities of practice

> How will you ensure that your work is available to the widest number of people?
> Please specify the open source or creative commons license(s) you will use, how you will host your code so that others can contribute, and how you will publicize your work.
> We encourage you to plan content to be shared quarterly on the R Consortium blog.
