xquery version "1.0-ml";

(:
:   Module Name: Get Uris
:
:   Module Version: 1.0
:
:   Date: 2012 September 27
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: cts (Marklogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Generates a list of uris based on
:       some parameter. Having an index on URIs is mandatory.
:  Note: switched to using the name authority lccn , with the n switched to "w" for repeatability during first loads. 2015-06-12
:
:)
   
(:~
:   Generates a list of uris based on
:       some parameter. Having an index on URIs is mandatory.
:
:   @author Nate Trail (ntra@loc.gov)
:   @author Kevin Ford (kefo@loc.gov)
: 	@since June 12, 2015
:   @since September 27, 2012
:   @version 1.0
:)

(: Namespaces :)

declare namespace cts       = "http://marklogic.com/cts";

declare variable $directory as xs:string := "/authorities/names/";
declare variable $start as xs:integer := 1;
(:
declare variable $count as xs:integer := 2000000;
declare variable $count as xs:integer := 20;
:)

declare variable $count as xs:integer := 20;
(:let $uris := ("1","2"):)


let $uris := 
    cts:uris(
        $directory,
        (),
        cts:or-query((
            cts:element-range-query(fn:QName("id_index#", "rdftype"), "=", "Title", 'collation=http://marklogic.com/collation/'),
            cts:element-range-query(fn:QName("id_index#", "rdftype"), "=", "NameTitle", 'collation=http://marklogic.com/collation/')
        ))
    )[$start to ($start + $count)]



 
(:
 	ids include n4###-n9###, n20###, nb# no###, ns###, but the new numbering is n20###, so that has to be at the end; hence ny###(
	n23### becomes na###
	some subjects are works, but let's skip them!
	sh2011002214
	Decided to keep the lccn as source, but rename as w*, so that we know it's different. Too hard to maintain one-ups; maybe new bf data should be "wl" for LC works"


	2015 07.08: trying lccn again: names/n*** or change to works/w
 :)
let $uris := 
    for $u  in $uris[fn:not(fn:contains(.,"/subjects/"))]

		let $workuri:= fn:replace($u,"authorities/names/n","resources/works/lw")				
(:
		let $unormal:= fn:replace($u,"n23","na23")
		let $unormal:= fn:replace($unormal,"n20","nz20")
		let $unormal:= fn:replace($unormal,"n4","nz194")
		let $unormal:= fn:replace($unormal,"n5","nz195")
		let $unormal:= fn:replace($unormal,"n6","nz196")
		let $unormal:= fn:replace($unormal,"n7","nz197")
		let $unormal:= fn:replace($unormal,"n8","nz198")
		let $unormal:= fn:replace($unormal,"n9","nz199")
		let $unormal:= fn:replace($unormal,"n0","nz200")
		let $unormal:= fn:replace($unormal,"nb9","nb199")
		let $unormal:= fn:replace($unormal,"nb0","nb200")					
		let $unormal:= fn:replace($unormal,"no9","no199")		
		let $unormal:= fn:replace($unormal,"no0","no200")
		let $unormal:= fn:replace($unormal,"ns9","ns199")
		let $unormal:= fn:replace($unormal,"ns0","ns200")
		let $unormal:= fn:replace($unormal,"nr0","nr200")		
        let $unormal:= fn:replace($unormal,"nr9","nr199")		
  :)      
		return fn:concat($u,"--",$workuri)
		(:
			fn:concat(fn:replace($unormal,"/authorities/names/","") ,"|", $u)
:)
			

	

(: twain, mark, huck finn .latvian

return (
1,
"/authorities/names/no2004054683.xml--/resources/works/lwo2004054683.xml"
)

:)


return 		(fn:count($uris) , $uris)  






