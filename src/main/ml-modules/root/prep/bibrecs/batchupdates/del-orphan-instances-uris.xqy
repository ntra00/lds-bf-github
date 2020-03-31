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
     
  
  
  import module namespace bibs2mets = "http://loc.gov/ndmso/bibs-2-mets" at "/modules/module.bibs2mets.xqy";

(: finding orphan instances like

xdmp:document-get-collections("/lscoll/lcdb/instances/c/0/0/0/0/0/0/4/7/1/c0000004710002.xml")
,
"/bibframe/mergedtoAuthWork/","/bibframe/mergedInstances/")
	                            else if ($found-mets) then 
									($instance-collections, ("/bibframe/mergedInstances/","/bibframe/mergedtoBibWork/"))
:)

(: instances in collection not edited, not merged

:)

(:
let $uris:=cts:uris((),(),
	    cts:and-not-query(  
	  cts:and-not-query(  
          
                          cts:and-query((
                              cts:collection-query("/resources/instances/"),
                              cts:collection-query("/catalog/")
                               ))
							 
                      ,
                       cts:collection-query("/bibframe/editor/")
                       )
					   ,
					   cts:or-query( (cts:collection-query("/bibframe/mergedInstances/"),
					   cts:collection-query("/bibframe/mergedtoBibWork/"),
					   cts:collection-query("/bibframe/mergedtoAuthWork/")
					   ))
                       )
					   )[18000000 to 20000000]

 let $count:=count($uris)
 let $multiple-instances:=
 	 for $i  in $uri
  		return if (count(cts:uri-match(fn:concat(fn:substring($i,1,43),"*")))  > 1)  then $i else ()
let $count:=count($multiple-instances)

return if count($multiple-instances) >1 ) then
	return  (
			xdmp:log(fn:concat("CORB delete orphan instances starting : ct= ",$count),"info"),
			$count, 
			$multiple-instances
		)
:)

let $uris:=cts:uris((),(),
	    cts:and-not-query(  
      	  cts:and-not-query(  
          
                          cts:and-query((
                              cts:collection-query("/resources/instances/"),
                              cts:collection-query("/catalog/")
                               ))
							 
                      ,
                       cts:collection-query("/bibframe/editor/")
                       )
					   ,
					   cts:or-query( (cts:collection-query("/bibframe/mergedInstances/"),
					   cts:collection-query("/bibframe/mergedtoBibWork/"),
					   cts:collection-query("/bibframe/mergedtoAuthWork/")
					   ))
                       )
					   )[5000000 to 6000000]

 
(:individual ids :)
let $tokens:=for $i in $uris
             
                let $token:=fn:replace($i,".xml","")
                let $token:=fn:tokenize($token,"/")[fn:last()]
                let $token:=fn:substring($token,1,10)
                         return $token
                      (:
                      let $token:=fn:replace($token,"^c0+","")
                      let $type:=fn:tokenize($i,"/")[4 ]
                      let $count:= count(cts:uri-match(fn:concat(fn:substring($i,1,43),"*")))
                        return  (   $token):)
           
 (:get unique individual ids, find out if they have multiple siblings:)
 let $multiple-instances:=
 	 for $token  in distinct-values($tokens)
   
        let $dirtox := bibs2mets:chars-001($token)
        let $destination-root := fn:concat("/lscoll/lcdb/instances/")
        let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
        let $baseuri := fn:concat($dir, "*")    
  		    return if (count(cts:uri-match($baseuri))  > 1)  then fn:concat($dir,$token,"0001.xml") else ()
          
let $count:=count($multiple-instances)
(: if any results:)
return if ($count >1 ) then
	  (
			
			$count, 
			xdmp:log(fn:concat("CORB delete orphan instances starting : ct= ",$count),"info"),
      $multiple-instances
     	
		)
    else ()

(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)