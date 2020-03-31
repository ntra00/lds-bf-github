xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";
 declare namespace marcxml="http://www.loc.gov/MARC21/slim";
declare namespace index="info:lc/xq-modules/lcindex";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace mets="http://www.loc.gov/METS/";
declare  namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare  namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare  namespace bf="http://id.loc.gov/ontologies/bibframe/";
declare  namespace bflc="http://id.loc.gov/ontologies/bflc/";
declare  namespace madsrdf="http://www.loc.gov/mads/rdf/v1#";
import module namespace sem                 = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";

declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
     import module namespace search = "http://marklogic.com/appservices/search"    at "/MarkLogic/appservices/search/search.xqy";
  

let $uris:=cts:uris((),(),
  cts:and-not-query(  
  cts:and-not-query(  
  cts:and-not-query(  
      
                          cts:and-query((
                              cts:collection-query("/resources/items/"),
                              cts:collection-query("/catalog/")
                               )),                                                        

                       cts:collection-query("/bibframe/editor/")
                       ),
                       cts:collection-query("/bibframe-process/item-not-orphan/")
                       )
                       ,
                       cts:collection-query("/bibframe-process/item-orphan/")
                       ))

return (count($uris), $uris)

(:for $uri in $uris

 
let $instance-docid:=fn:replace($uri, "items","instances")
let $instance-docid:=fn:replace($uri,"[0-9][0-9]\.xml$","01.xml")
let $item-loaded:=doc($uri)/mets:mets/mets:metsHdr/@LASTMODDATE
let  $item-loaded:=xs:dateTime($item-loaded)

let $instance-loaded:=doc( $instance-docid)/mets:mets/mets:metsHdr/@LASTMODDATE
let $instance-loaded:=xs:dateTime($instance-loaded)
let $age:=$instance-loaded - $item-loaded
return 
                       
if (days-from-duration($age) >2) then
  (fn:concat(count($uris),":",$uri,": ",days-from-duration($age), "||",$item-loaded,": ", $instance-loaded),
  xdmp:document-add-collections($uri,"/bibframe-process/item-orphan/")
  )
  else 
  (fn:concat($uri,": ",days-from-duration($age), "not bad"),
  xdmp:document-add-collections($uri,"/bibframe-process/item-not-orphan/")
  
  )
)
:)
