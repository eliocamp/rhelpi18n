Only return the language asked, if exists. 
https://cran.r-project.org/doc/manuals/R-exts.html#Documenting-functions

Still, need to link to the documentation. 

keywords? 
	They are part of an rd file. 
	How do they work? Translate or not?

concepts?
	Does anyone use it?

news file?

check rd files 
	tools::checkRdContents

Test the translation:
	At the moment of writing the translation for a particular version of a pkg, save the examples as tests. Then, if there's an update, run the (old) examples with the new version and check for failed examples. 
	Also consider using tests. 

Working group:
email Joe Richter: executive director of R Consortium director@r-consortium.org