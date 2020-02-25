xquery version "1.0-ml";
(: 
==========================================================================================================
delete instance docs that merged onto n42..., "untitled"; delete and reload


=========================================================================================================

:)
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   owl                 = "http://www.w3.org/2002/07/owl#";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf             = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mxe					        = "http://www.loc.gov/mxe";
declare namespace   ri                  = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   bf              	= "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace   index               = "info:lc/xq-modules/lcindex";
declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
import module namespace sem                 = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace bibs2mets 			= "http://loc.gov/ndmso/bibs-2-mets" at "/admin/bfi/bibrecs/modules/module.bibs2mets.xqy";
let $uri:="http://id.loc.gov/resources/works/n42025799"
 let $query := <query><![CDATA[
			
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
            PREFIX lcc: <http://id.loc.gov/ontologies/lcc#>
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            PREFIX  rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
         PREFIX bf:            <http://id.loc.gov/ontologies/bibframe>
         PREFIX bflc:    <http://id.loc.gov/ontologies/bflc>
         SELECT distinct  ?s
        WHERE {
                                                    ?s ?p ?uri
                                                FILTER (isURi(?s)).
                                              }  limit 10000


	        ]]></query>
                          
    
	let $params := 
        map:new((
            map:entry("uri", sem:iri($uri)       )
        ))
    let $results := sem:query-results-serialize( sem:sparql($query, $params) )/sparql:results	
    let $uris:=
    for $uri in $results//sparql:uri
  	  let $src:=fn:tokenize($uri,"/")[fn:last()]
    	let $srcid:=fn:concat("loc.natlib.instances.",$src)
      let $bibid:=fn:concat("/bibframe-process/records/",fn:substring-before(fn:replace($src,"^c0+",""),"0001"),".xml")
      let $instance-id:=fn:base-uri(cts:search(collection($cfg:DEFAULT-COLLECTION)/mets:mets, cts:element-attribute-value-query(xs:QName("mets:mets"), xs:QName("OBJID"), $srcid))[1])
      let $item-id:=fn:replace($instance-id,"instances","items")
        return $bibid


return (count($uris), $uris)
	


