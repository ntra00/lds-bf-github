xquery version "1.0-ml";
(:urls  for name titles that never got reloaded :)

import module namespace searchml = "info:lc/id-modules/searchml#" at "modules/module.SearchML.xqy";
import module namespace transmit = "info:lc/id-modules/transmit#" at "modules/module.Transmit.xqy";
import module namespace constants   = "info:lc/id-modules/constants#" at "constants.xqy";
import module namespace search              = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
(: Serializations :)
import module namespace search2atom = "info:lc/id-modules/search2atom#" at "modules/module.Search2Atom.xqy";
import module namespace xml2jsonml = "info:lc/id-modules/xml2jsonml#" at "modules/module.XML-2-JSONML.xqy";
import module namespace xhtml-funcs = "info:lc/id-modules/xhtml-funcs#" at "modules/module.XHTML.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace index = "id_index#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bf = "http://bibframe.org/vocab/";
declare namespace bf2 = "http://bibframe.org/vocab2/";

(:~
:   This variable is for the query

let  $q := "nasturtiums"
 return cts:search(collection("/bibframe/transformedTitles")//index:generation ,
   cts:word-query( "DLC authorities transform-tool:2015-07-08-T11:00:00"), (),()
    
    )
    cts:search(fn:collection(), 
cts:and-query(cts:word-query("process:DLC authorities transform-tool:2015-07-08-T11:00:00", ("lang=en"), 1)))


let $directory:="/resources/works/"
 let $list:=
 cts:uris(
        $directory,
        (),
        
           cts:element-value-query(fn:QName("id_index#", "generation"),  "DLC authorities transform-tool:2015-07-08-T11:00:00")
               
        )



let $list := cts:uri-match("/resources/works/lw*", ("ascending", "concurrent"))
:)
let $list:=
cts:uris((),(),cts:and-not-query( cts:collection-query("/bibframe/transformedTitles"),
           cts:collection-query("/bibframe/2015-10-23reload")
 )
 )

 
let $uris:=
	for $uri in $list
		return fn:concat(fn:replace($uri,"/resources/works/lw","/authorities/names/n"),"--",$uri)

	return (fn:count($uris) , $uris)

