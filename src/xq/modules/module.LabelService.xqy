xquery version "1.0";

(:
:   Module Name: Known-label service
:
:   Module Version: 1.0
:
:   Date: 2011 July 20
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp (MarkLogic), cts (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Attempts to locate the label in 
:       a given scheme.  If found, the user is redirected.
:       If not found, the user gets a 404.  If multiples are found,
:       user taken to the first one.
:
:)
   
(:~
:   Attempts to locate the label in 
:   a given scheme.  If found, the user is redirected.
:   If not found, the user gets a 404.  If multiples are found,
:   user taken to the first one.
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since July 20, 2011
:   @version 1.0
:)

module namespace labelservice = 'info:lc/id-modules/labelservice#';

declare namespace xdmp      = "http://marklogic.com/xdmp";
declare namespace cts       = "http://marklogic.com/cts";
declare namespace index     = "info:lc/xq-modules/lcindex";

(: Imported Modules :)
import module namespace constants   = "info:lc/id-modules/constants#" at "../../constants.xqy";
import module namespace redirect    = "info:lc/id-modules/redirect#" at "../../helpers/module.Redirect.xqy";
import module namespace searchml     = "info:lc/id-modules/searchml#" at "../module.SearchML.xqy";
(:~
:   Get nametitle for a work
:
:   @param  $scheme         is the scheme requested
:   @param  $label          is the label to be found
:   @return element         as atom:feed element
:)
declare function labelservice:get-label(
    $scheme as xs:string,
    $label as xs:string,
    $serialize as xs:string
    )
{

    let $schemeURI := "/resources/works/"
    
	let $label:=fn:normalize-space($label)

    let $directory := 
      
            "/lscoll/lcdb/works/"
      
            
    (: Loosened up search, case-insensitive, diacritic-sensitive, and puncuation sensitive :)            
    let $uri := label-search-wiggly($label , $directory)             
    
 (: Codepoint search for a matching idx:nameTitle :)
    let $uri := 
        if ($uri[1] ne "") then
            $uri
        
      	
            	label-search($label , $directory , xs:QName("index:nameTitle"))
      
    	
     
    let $response := 
        if ($uri[1] ne "" and $serialize ne "") then
            redirect:found( fn:concat( $uri[1] , $serialize) , $uri[1] )
        else if ($uri[1] ne "") then
            redirect:found( $uri[1] )
        else
            redirect:four0four()
    
    return fn:concat("No matching term found - authoritative, variant, or deprecated - for " , $label)


};

(:~
:   Get Label
:
:   @param  $scheme         is the scheme requested
:   @param  $label          is the label to be found
:   @return element         as atom:feed element
:)
declare function labelservice:get-label(
    $scheme as xs:string,
    $label as xs:string,
    $serialize as xs:string
    )
{

    let $schemeEl := $constants:SCHEMES/scheme[@abbrev eq $scheme]|$constants:PRESERVATION_SCHEMES/scheme[@abbrev eq $scheme]|$constants:BIBFRAME_SCHEMES/scheme[@abbrev eq $scheme]
    let $schemeName := xs:string($schemeEl[1]/@fullName)
    let $schemeURI := xs:string($schemeEl[1]/@relativeURI)
	let $label:=fn:normalize-space($label)

    let $directory := 
        if ($scheme eq "all") then
            "/authorities/"
        else
            fn:concat($schemeURI , "/")

    
 (: Codepoint search for a matching authoritativeLabel :)
    let $uri := 
        if ($uri[1] ne "") then
            $uri
        
      	else if (	
				  (: ( 	fn:contains($directory, "/authorities/names/") or
	  				fn:contains($directory, "/authorities/subjects/") or 
				 	fn:contains( $directory, "/authorities/genreForms/") or 
					fn:contains( $directory, "/vocabulary/graphicMaterials/") or
				 	fn:contains( $directory, "/vocabulary/relators/") 
					 ) :)
				
					(fn:matches($directory, "(names|subjects|genreForms|graphicMaterials|relators)") 
				  		and fn:matches($label,".+(\.|,)$")
					)
			 	)   then  
				label-search-chop-period($label , $directory , xs:QName("index:aLabel") )	
	  else
            	label-search($label , $directory , xs:QName("index:aLabel"))
      
    (: Codepoint search for a matching variantLabel :)
    let $uri := 
        if ($uri[1] ne "") then
            $uri
        
        (:else if ((fn:contains( $directory, "/authorities/names/") or fn:contains($directory, "/authorities/subjects/") or fn:contains( $directory, "/authorities/genreForms/") or fn:contains( $directory, "/vocabulary/relators/")) and fn:matches($label,".+(\.|,)$") )  then:)
		else if (					
					(fn:matches($directory, "(names|subjects|genreForms|graphicMaterials|relators)") 
				  		and fn:matches($label,".+(\.|,)$")
					)
			 	)   then  
		            label-search-chop-period($label , $directory , xs:QName("index:vLabel") )						
		else
            label-search($label , $directory , xs:QName("index:vLabel"))
     
    let $response := 
        if ($uri[1] ne "" and $serialize ne "") then
            redirect:found( fn:concat( $uri[1] , $serialize) , $uri[1] )
        else if ($uri[1] ne "") then
            redirect:found( $uri[1] )
        else
            redirect:four0four()
    
    return fn:concat("No matching term found - authoritative, variant, or deprecated - for " , $label)


};

(:~
:   Label search
:
:   @param  $scheme         is the scheme requested
:   @param  $label          is the label to be found
:   @return element         as atom:feed element
:)
declare function labelservice:label-search(
    $label as xs:string,
    $directory as xs:string,
    $element as xs:QName
    ) as xs:string*
{
    cts:uris(
        '', 
        (), 
        cts:and-query((
            cts:element-range-query(
                $element, 
                "=",
                $label,
                ("collation=http://marklogic.com/collation/codepoint")
            ),
            cts:directory-query(
                ($directory),
                "infinity"
            )
            )
        ))
    )
};

(:~
:   Label search, wiggly
:   The elaborate or-query has been lifted from searchml:search-refinement
:
:   @param  $label          is the label to be found
:   @param  $directory      is the directory to search
:   @return element         is the vlabel or alabel element
:)
declare function labelservice:label-search-wiggly(
    $label as xs:string,
    $directory as xs:string
    ) as xs:string*
{

    searchml:search-label-wiggly(fn:concat('"' , $label , '"'), $directory)
        
};