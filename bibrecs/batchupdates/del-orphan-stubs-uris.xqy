xquery version "1.0-ml";
(: 
==========================================================================================================
delete orphan stubs ; does not actually reload
=========================================================================================================

:)
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace searchts = 'info:lc/xq-modules/searchts#' at "../modules/module.SearchTS.xqy";
import module namespace bibs2mets = "http://loc.gov/ndmso/bibs-2-mets" at "../modules/module.bibs2mets.xqy";

import module namespace sem                 = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
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




let $stubs:=cts:uris((),(),
    cts:and-not-query(
		cts:and-query(
		(cts:collection-query("/bibframe/stubworks/"),cts:collection-query("/catalog/")))
		,
		cts:collection-query("/bibframe/editor/")
		)
)

   let $count:=count($stubs)
   return (	xdmp:log(fn:concat("CORB orphan stub deletions starting: ", $count),"info"),
   			$count, 
			$stubs
			)
  
  
  
  
   (:
  
  for $node in $stubs
  
    let $uri:=fn:tokenize($node,"/")[fn:last()]
    let $uri:=fn:substring-before($uri,".xml")
    let $uri:=fn:concat("http://id.loc.gov/resources/works/",$uri)
 
 
 let $query := <query><![CDATA[
			PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
			PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
			PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
			PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	            
			SELECT    ?parentwork 
			WHERE {  		

	  				?uri bf:relatedTo ?parentwork  .
									
			}  limit 120
	        ]]></query>
                          
    
    
	let $params := 
        map:new((
            map:entry("uri", sem:iri($uri)       )
        ))


let $results := sem:query-results-serialize( sem:sparql($query, $params))/sparql:results	

return  for $workid in $results//sparql:binding
            let $id:=fn:string($workid/sparql:uri)
            let $id:=fn:tokenize($id,"/")[fn:last()]
            let $dirtox := bibs2mets:chars-001($id)
            let $destination-root := "/lscoll/lcdb/works/"
            let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
            let $workurl:= fn:concat($dir,$id,".xml")
            return ( if (fn:doc-available($workurl) ) then ()
                  else
                    (xdmp:document-delete( $node),        

                      xdmp:log(fn:concat("QCONSOLE deleting orphan stub ", $node),"info")
                      )


                      )
                    



let $uris:=
    for $uri in $results//sparql:uri
  	  let $id:=fn:tokenize($uri,"/")[fn:last()]
        return fn:concat(" curl ",fn:string($uri), ".marcxml.xml > ", $id, ".xml")

return (count($uris), $uris)
:)(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)