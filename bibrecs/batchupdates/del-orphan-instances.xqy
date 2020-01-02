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

(: doc uri is incoming; open it and get instanceof for work id:)
(: ------------------------------------------ Main Code ------------------------------------ :)
let $uri:=$URI
return
(: multiple instances guaranteed in the uris module :)
 (:if (fn:not(fn:ends-with($uri,"1.xml"))) then
 Further work: check the timestamps on other instances instead of the work??? using uri-match, lastmoddate
 also, cts:search the doc for instanceOF instead of sparql
 :)
 		try {
			 let $time-n-work:=for $d in doc($uri) return
			            (xs:dateTime($d/mets:mets/mets:metsHdr/@LASTMODDATE),fn:string($d//rdf:RDF/bf:Instance[1]/bf:instanceOf/@rdf:resource))
			 let $workid:=fn:tokenize($time-n-work[2],"/")[fn:last()]
			 let $token:=fn:replace($workid,".xml","")
			 let $dirtox := bibs2mets:chars-001($token)
	        let $destination-root := fn:concat("/lscoll/lcdb/works/")
	        let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
	        let $work-url := fn:concat($dir, $token,".xml")    
          
   
			let $worktime:=xs:dateTime(doc($work-url)/mets:mets/mets:metsHdr/@LASTMODDATE)
            let $instancetime:=$time-n-work[2]
            let $worknotmerged:=  if (xdmp:document-get-collections($work-url) = "/bibframe/consolidatedBibs/") then fn:false() else fn:true()
			let $age:= fn:days-from-duration($worktime - $instancetime)

  		return if (not($work-url) ) then
        		(
				xdmp:log(fn:concat("CORB delete orphan instance: ", $uri, " oktodel? no work uri ", $work-url),"info")
		      	
				(:,xdmp:document-delete($uri):)
      			
				)
			  else if ($age  < 2 ) then 
			  		()
			  	(:xdmp:log(fn:concat("CORB delete orphan instances : ", $uri, " no delete; work found, same age:", $work-uri),"info"):)
			   else if (  fn:not(fn:starts-with($token, "n")) and $worknotmerged) then
			   (			  		
					xdmp:log(fn:concat("CORB delete orphan instances : ", $uri, " oktodel?, first reload?; different age from work: ", $age,  $work-url, "|", $worknotmerged),"info")			  		
					)
					else ( (:work merged or instance  on nametitle :))
(:
else ( xdmp:log(fn:concat("CORB delete orphan instances : ", $uri, " oktodel? worksearch failed."),"info"))
:)

 
                   } catch ($e){
						xdmp:log(fn:concat("CORB delete orphan instances error catch ", $uri ),"info")
                   }
(: multiple instances guaranteed in the uris module :)

(:else():)(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)