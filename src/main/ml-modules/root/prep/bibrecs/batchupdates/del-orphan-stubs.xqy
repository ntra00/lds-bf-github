xquery version "1.0-ml";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace mets      = "http://www.loc.gov/METS/";
declare namespace xdmp      = "http://marklogic.com/xdmp";
declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace mxe	        = "http://www.loc.gov/mxe";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";
import module namespace sem                 = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";

import module  namespace 		bibs2mets 		= "http://loc.gov/ndmso/bibs-2-mets" 		  at "/modules/module.bibs2mets.xqy";


declare namespace sparql                = "http://www.w3.org/2005/sparql-results#";
(:  query to add translation links to nametitles
	collection batch is "/bibframe-process/2018-05-30d/"
	To use this code as  a template, 
	set the batch and the query in the uris file,
	use the same batch here,
	Modify the code in local:fix(), but keep the timestamp update.
	Decide if your fix means you have to recalculate the idx and/or the sem triples
	replace what's new
	The logging and adding to collections stays the same. If you have to run this more than once, it will exclude the stuff you've already fixed.
	


snippets:
let $marcxml:=$doc//marcxml:record

	let $new:=try {
					xdmp:node-delete($doc//bf:changeDate[fn:string(.)="0000-00-00T00:00:00"])

			 } catch ($e){
                              xdmp:log(fn:concat("CORB ", $batch, " failed for : ",$URI), "info")
                   }
	
               
                xdmp:node-replace($doc//mets:dmdSec[@ID="mxe"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/mxe:record,$new)
			xdmp:node-replace($doc//mets:dmdSec[@ID="semtriples"]//mets:xmlData/sem:triples, $new)
        	xdmp:node-replace($doc//mets:dmdSec[@ID="index"]//mets:xmlData/index:index, $work-bfindex )
		

 :)


declare variable $URI as xs:string external;  (: The value for this variable is passed in by CORB :)


(: ------------------------------------------ Main Code ------------------------------------ :)
let $uri:=$URI

 		     (:let $_:=xdmp:log(fn:concat("CORB delete orphan instances starting deletion for  ", $uri ),"info")               :)

    let $stub-uri:=fn:tokenize($uri,"/")[fn:last()]
    let $stub-uri:=fn:substring-before($stub-uri,".xml")
    let $stub-uri:=fn:concat("http://id.loc.gov/resources/works/",$stub-uri)
 
 
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
            map:entry("uri", sem:iri($stub-uri)       )
        ))


let $results := sem:query-results-serialize( sem:sparql($query, $params))/sparql:results	

return  for $workid in $results//sparql:binding
            let $id:=fn:string($workid/sparql:uri)
            let $id:=fn:tokenize($id,"/")[fn:last()]
            let $dirtox := bibs2mets:chars-001($id)
            let $destination-root := "/lscoll/lcdb/works/"
            let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
            let $workurl:= fn:concat($dir,$id,".xml")
            return (
			try { if (fn:doc-available($workurl) ) then ()
                  else
                    (xdmp:document-delete( $uri),  

                      xdmp:log(fn:concat("CORB deleting orphan stub ", $uri),"info")
                      )
                     
                   } catch ($e){
						xdmp:log(fn:concat("CORB error deleting orphan stub failed ", $uri ),"info")
                   }
				   )


(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)