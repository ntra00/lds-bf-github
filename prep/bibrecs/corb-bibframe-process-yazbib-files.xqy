xquery version "1.0-ml";
(:
:   converts using yaz on the command line, curled from permalink marcxml via lccn
: now calls bibs2mets for all 
: MODIFIED from process-bib-files to expect rdf:RDF yaz output instead of marcxml
:
:   Module Version: 1.0
:
:   Date: 2017 May 11
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: cts, search, trgr, xdmp (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Process bibs into works, instances, and
:   items and adds to the database.
: 	
:
:)
   
(:~
:   Process bibs into works, instances, and
:   items and adds to the database.
:
:   @author NDMSO (ndmso@loc.gov)
:   @since July 24, 2015
:   @version 1.0

:   Originally kefo was doing a sorted search for bibs, assigning numbers before loading known items; 
: 	we don't know the ID, and we dont' have a auto number generator,
: 	so let's just use the bibid (padded to 9 digits) 
:
: CHANGES
: 	merge specs simplified: if there's a 130, match it. if there a 240, match on 100+240
:	2017081: added bf4ts semantics with try/catch (first error was bad 856 w/o http, https://lccn.loc.gov/2015015885/marcxml
:)

module namespace m2bfyaz ="http://loc.gov/ndmso/marc-2-bibframe-yaz/" ;
import module namespace 		mem 				= "http://xqdev.com/in-mem-update" 		 at '/MarkLogic/appservices/utils/in-mem-update.xqy';

(: Namespaces :)
declare namespace mets      	= "http://www.loc.gov/METS/";
declare namespace index     	= "info:lc/xq-modules/lcindex";
declare namespace idx   		= "info:lc/xq-modules/lcindex";
declare namespace xdmp    		= "http://marklogic.com/xdmp";
declare namespace dir     		= "http://marklogic.com/xdmp/directory";
declare namespace cts       	= "http://marklogic.com/cts";
declare namespace mxe       	= "http://www.loc.gov/mxe";
declare namespace rdf       	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bf	        = "http://id.loc.gov/ontologies/bibframe/";
declare namespace bflc 	        = "http://id.loc.gov/ontologies/bflc/";
declare namespace madsrdf       = "http://www.loc.gov/mads/rdf/v1#";
declare namespace marcxml       = "http://www.loc.gov/MARC21/slim";
declare namespace mlerror	    = "http://marklogic.com/xdmp/error"; 
declare namespace rdfs   	    = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace pmo  			= "http://performedmusicontology.org/ontology/";
declare namespace lclocal		= "http://id.loc.gov/ontologies/lclocal/";
(:
declare variable $body := xdmp:get-request-body("xml")/node();
:)


import module namespace bibs2mets 			= 		"http://loc.gov/ndmso/bibs-2-mets" 		at 	"modules/module.bibs2mets.xqy";
import module namespace marcutil			= 		"info:lc/xq-modules/marc-utils" 		at	"modules/module.marcutils.xqy";

import module namespace bibframe2index      =       "info:lc/id-modules/bibframe2index#" 	at "modules/module.BIBFRAME-2-INDEX.xqy";
import module namespace bf4ts   			=      "info:lc/xq-modules/bf4ts#"  			at "modules/module.BIBFRAME-4-Triplestore.xqy";



declare variable $quality := ();
declare variable $TODAY as xs:string:=fn:substring(fn:string(fn:current-date()),1,10);
(:fn:concat("/processing/load/bibs/",$TODAY,"/"):)

declare variable $XML-STRING as xs:string external;

(: if overwrite=repl then update=replace, unconditionally
declare variable $OVERWRITE as xs:string external ;
:)


(:
    Tokenize URI
    Generate work URI  
    Get Bib MARC/XML
    
    Transform MARCXML/BIB to BIBFRAME/RAW
    
    Works
        Check if exists
            if yes, then retrieve work record
                add subjects, all other info
            if no, then add to db as own work
			move adminMeta to instance
			is this a translation? link to it's original

    Instance
        for each instance
            associate with work
            generate URI, add to DB.

    Items
        for each item
            associate with instance             
            use instance URI, add to DB.
			ids are relative to the work, not the instance, or we'd get impossibly long ids.
:)

(: use bib id to find all docs and remove them from /catalog/; this is a delete bib :)
declare function m2bfyaz:remove-from-coll($bibid) {


let $id:=fn:concat("c",bibs2mets:padded-id($bibid))
let $collection:="/catalog/"


let $dirtox := bibs2mets:chars-001($id)
for $type in ("works", "instances", "items")
	let $dir := fn:concat("/lscoll/lcdb/",$type,"/", string-join($dirtox, '/'), '/*')
	
	for $uri in cts:uri-match($dir)
			return ( xdmp:document-add-collections($uri,"/deletes/"),
			         xdmp:document-remove-collections($uri,$collection),
				 	if ( $type = "works") then
					try { (: this should fail if it's a new record but succeed if it's an old one being edited :)
						xdmp:document-delete(fn:concat("/bibframe-process/records/",$bibid,".xml"))		
			        } catch ($e) {			           
			             (  
			                 xdmp:log(fn:concat("CORB BIBYAZ merge: deleting source /bibframe-process/records/ failed  for bibid  : ",$bibid )   , "info")
						 )
					} else ()
					,
					 xdmp:log(fn:concat("CORB BIBYAZ merge: deleting from catalog ",$type, ": ",fn:tokenize($uri,"/")[fn:last()]," for bibid  : ",$id )   , "info")          
					)   
};




(:==========================main program ====================:)
declare function m2bfyaz:transform(
  $content as map:map,
  $context as map:map
)(: as map:map?:)

{

	let $start := xdmp:elapsed-time()
	
	let $body := map:get($content, "value")
	let $orig-uri := map:get($content, "uri")  (: file name! :)
	
	let $_:=xdmp:log(fn:concat("CORB BIBYAZ uri starting: ",$orig-uri),"info")
	
return 

	for $set in $body/descendant-or-self::rdf:RDF
		(:let $_:=xdmp:log(fn:concat("CORB BIBYAZ uri starting2: ",fn:name($set) ),"info"):)
	
	
	 for $records in $set/rdf:Description/lclocal:graph
		(:let $_:=xdmp:log(fn:concat("CORB BIBYAZ uri starting3: ",fn:name($records) ),"info"):)
	
		for $work in $records/bf:Work[parent::lclocal:graph]
			(:let $_:=xdmp:log(fn:concat("CORB BIBYAZ uri starting4: ",fn:name($work) ),"info"):)

	(: 2019-01-17: leader 06 status new and changed generate a status; otherwise it's a delete:)
		return if ( fn:not($work/bf:adminMetadata/bf:AdminMetadata/bf:status) or
				 $work/bf:adminMetadata[1]/bf:AdminMetadata/bf:status/bf:Status[fn:string(bf:code)="d"] )
		 then
				let $bibid:= fn:replace(fn:string($work/@rdf:about), "^http://bibframe.example.org/([0-9]+)#Work$","$1")
				
				let $_:=xdmp:log(fn:concat("CORB BIBYAZ delete/hide: ", $bibid),"info")
					return
							m2bfyaz:remove-from-coll($bibid)
  			else
		
		let $already-in-pilot:=   
			for $batch in $work//lclocal:batch
	      		return if (fn:matches(fn:string($batch) ,"BibframePilot2","i")) then
	        			fn:true()
	       			else 
	        			()
		 return if ($already-in-pilot) then
						xdmp:log(fn:concat("CORB BIBYAZ merge: skip: ",$orig-uri , ", has 985." ), "info")
				else
					
							
					let $work-about:= fn:string($work/@rdf:about)
					let $instances:=$records/bf:Instance[fn:string(bf:instanceOf/@rdf:resource) = $work-about ]
					let $record:=<rdf:RDF>{$work, $instances}</rdf:RDF>

					let $cleanbf:=xdmp:quote($record)
					let $bf:= xdmp:unquote(
									fn:replace($cleanbf, "\[from old catalog\]","")
								)
					let $bf:=$bf/element()
					let $BIBURI:= fn:tokenize($work-about,"/")[fn:last()]
					let $BIBURI:=fn:substring-before($BIBURI,"#Work")
					let $BIBURI := bibs2mets:padded-id($BIBURI)

					(:	converted records are prefixed with "c" so they don't overwrite name/titles:)
					let $paddedID := fn:concat("c",$BIBURI)
					let $workURI := fn:concat("http://id.loc.gov/resources/works/" , $paddedID)
					let $workDBURI := fn:concat("loc.natlib.works.",$paddedID)
							(: fn:concat("/resources/works/" , $paddedID, ".xml"):)

				(:-------------------------from ingest-voyager-bib vvvv -------------------------:)
					let $resclean := $paddedID
					let $dirtox := bibs2mets:chars-001($resclean)
					let $dest := "/lscoll/lcdb/works/"
				    let $destination-root := $dest
				    let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
				    let $destination-uri := fn:concat($dir, $resclean, '.xml')
				    (: the collection 9/16 is so we know the reload happened , and there are semtriples; remove after all reloads done
					2018-08-29 added yaz reload:)
					let $destination-collections := ($destination-root, "/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/",
				    		"/catalog/lscoll/lcdb/bib/", "/bibframe-process/reloads/2017-09-16/","/bibframe-process/yaz-reload/",
							fn:concat("/processing/load/bibs/",$TODAY,"/"))
					
				(:-------------------------from ingest-voyager-bib ^^^^^^^-----------------------:)

					let $mxe:=<mxe:record><!--none--></mxe:record>					
	
					let $result:=						
							(
								bibs2mets:get-work($bf,$workDBURI,$paddedID, $BIBURI, $mxe,  $destination-collections,$destination-uri)
			  					,
							    xdmp:log(fn:concat("CORB BIBYAZ merge:  ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")
						    	)
				    
return ()
};
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)