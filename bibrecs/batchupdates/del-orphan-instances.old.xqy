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
import module namespace 		bf4ts   		= "info:lc/xq-modules/bf4ts#"    	 at "../modules/module.BIBFRAME-4-Triplestore.xqy";
import module  namespace 		bibs2mets 		= "http://loc.gov/ndmso/bibs-2-mets" 		  at "../modules/module.bibs2mets.xqy";
import module namespace			auth2bf 		= "http://loc.gov/ndmso/authorities-2-bibframe" at "../../auths/authorities2bf.xqy";
import module namespace 		searchts 			= 'info:lc/xq-modules/searchts#' 		 at "../modules/module.SearchTS.xqy";
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

 :)

declare variable $uri as xs:string external;

declare variable $URI as xs:string external;  (: The value for this variable is passed in by CORB :)


(: ------------------------------------------ Main Code ------------------------------------ :)
let $uri:=$URI
return
(: multiple instances guaranteed in the uris module :)
 (:if (fn:not(fn:ends-with($uri,"1.xml"))) then
 Further work: check the timestamps on other instances instead of the work??? using uri-match, lastmoddate
 also, cts:search the doc for instanceOF instead of sparql
 :)
 		try {
                    
    let $idnode:=fn:tokenize($uri,"/")[fn:last()]
    let $id:=fn:replace($idnode,".xml","")
       
        let $instance-url:=fn:concat("http://id.loc.gov/resources/instances/",$id)
       
    	let $resclean := fn:normalize-space(fn:substring($id,1,10) )
    	let $dirtox := bibs2mets:chars-001($resclean)
    	
        let $destination-root := "/lscoll/lcdb/works/"
        let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
        let $work-url := fn:concat($dir, $resclean, '.xml')
       
       
 let $query := <query><![CDATA[
			PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
			PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
			PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
			PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	  	# find all if this instance is linked to it's work.
				SELECT   ?work
	      WHERE { 
                $uri  bf:instanceOf  ?work   .
              
							 }    limit 1
	        ]]></query>
          
    let $coll:=(      "/resources/instances/"     )
    
	  let $params := 
        map:new((
            map:entry("uri", sem:iri($instance-url)       )
        ))
    let $search :=  searchts:sparql($query, $params,$coll)
    
  return if ($search//sparql:result) then
  
          
            let $work-uri:=$search/sparql:result[1]/sparql:binding/sparql:uri[1]
		    let $idnode:=fn:tokenize($work-uri,"/")[fn:last()]    
	    	let $resclean := fn:normalize-space(fn:substring($idnode,1,10) )
	    	let $dirtox := bibs2mets:chars-001($resclean)    	
	        let $destination-root := "/lscoll/lcdb/works/"
	        let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
	        let $work-url := fn:concat($dir, $resclean, '.xml')
			let $worktime:=xs:dateTime(doc($work-url)/mets:mets/mets:metsHdr/@LASTMODDATE)
            let $instancetime:=xs:dateTime(doc($uri)/mets:mets/mets:metsHdr/@LASTMODDATE)
            let $worknotmerged:=  if (xdmp:document-get-collections($work-url) = "/bibframe/consolidatedBibs/") then fn:false() else fn:true()
			let $age:= fn:days-from-duration($worktime - $instancetime)

 let $_:=if ( fn:contains($work-url,"c000051479")) then
			xdmp:log(fn:concat("curb ", $uri, " |work uri ", $work-uri,"|", $worknotmerged),"info")
		else ()
  		return if (not($work-uri) ) then
        		(
				xdmp:log(fn:concat("CORB delete orphan instance: ", $uri, " oktodel? no work uri ", $work-uri),"info")
		      	
				(:,xdmp:document-delete($uri):)
      			
				)
			  else if ($age = 0 ) then 
			  		()
			  	(:xdmp:log(fn:concat("CORB delete orphan instances : ", $uri, " no delete; work found, same age:", $work-uri),"info"):)
			   else if (  fn:not(fn:starts-with($idnode, "n")) and $worknotmerged) then
			   (			  		
					xdmp:log(fn:concat("CORB delete orphan instances : ", $uri, " oktodel?, first reload?; different age from work: ", $age,  $work-uri, "|", $worknotmerged),"info")			  		
					)
					else ( (:work merged or instance  on nametitle :))

else ( xdmp:log(fn:concat("CORB delete orphan instances : ", $uri, " oktodel? worksearch failed."),"info")
(:,xdmp:document-delete($uri):)
)

 
                   } catch ($e){
						xdmp:log(fn:concat("CORB delete orphan instances error catch ", $uri ),"info")
                   }
(: multiple instances guaranteed in the uris module :)

(:else():)(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)