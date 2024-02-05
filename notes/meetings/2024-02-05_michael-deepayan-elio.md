
1 file per package.  parse_rd() Creates the file. 
everything done with perl scripts. 

Use cases:
* one package has several languages
* extra packages provide translations
	* How to pass rdcheck?
	* one module translates just one package. 

rd needs a setting to add language

Duplicated aliases -> disambiguation
* problem = namespace needs to be loaded
* need to click the preferred one every time -> how to streamline that?

rd_db() -> gives the serialises obejct of the help. This should be hacked.
* load both the package and the translations


What would the system have to know to know that? 
	* new DESCRIPTION field: "Translates: dplyr (=1.3.0)" 
	* prefer new DESCRIPTION fields over reinterpretation of old ones. 

Versions? 
* annotate which version is being translated.


1. Announce that work is getting started in R-devel
1. Create sample dummy package with translation
2. work!

https://cran.r-project.org/doc/manuals/R-exts.html#Package-types
The DESCRIPTION file has an optional field `Type` which if missing is assumed to be ‘Package’, the sort of extension discussed so far in this chapter. Currently one other type is recognized; there used also to be a ‘Translation’ type.