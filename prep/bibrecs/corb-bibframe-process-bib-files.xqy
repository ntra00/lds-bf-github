xquery version "1.0-ml";
(:
: this is it.
:
: Grab Bib FROM uris in "/bibframe-process/records/", automatically process it upon ingest usi
:
: now calls bibs2mets for all but get-work()
: 2017-12-15 moved get-work there as well
:
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
: 	called by bib-work.bash???
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
: 	so let's just use the bibid (padded to 9 digits) in
:
: CHANGES
: 	merge specs simplified: if there's a 130, match it. if there a 240, match on 100+240
:	2017081: added bf4ts semantics with try/catch (first error was bad 856 w/o http, https://lccn.loc.gov/2015015885/marcxml
:)

(: Namespaces :)
declare namespace mets      = "http://www.loc.gov/METS/";
declare namespace index     = "info:lc/xq-modules/lcindex";
declare namespace idx     = "info:lc/xq-modules/lcindex";
declare namespace xdmp      = "http://marklogic.com/xdmp";
declare namespace dir       = "http://marklogic.com/xdmp/directory";
declare namespace cts       = "http://marklogic.com/cts";
declare namespace mxe       = "http://www.loc.gov/mxe";
declare namespace rdf       = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace bf	        = "http://id.loc.gov/ontologies/bibframe/";
declare namespace bflc 	        = "http://id.loc.gov/ontologies/bflc/";
declare namespace madsrdf       = "http://www.loc.gov/mads/rdf/v1#";
declare namespace marcxml       = "http://www.loc.gov/MARC21/slim";
declare namespace mlerror	    = "http://marklogic.com/xdmp/error"; 
declare namespace rdfs 	        = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace pmo  			=	"http://performedmusicontology.org/ontology/";

import module namespace mem 				= 		"http://xqdev.com/in-mem-update" 		at "/MarkLogic/appservices/utils/in-mem-update.xqy";
import module namespace bibs2mets 			= 		"http://loc.gov/ndmso/bibs-2-mets" 		at 	"modules/module.bibs2mets.xqy";
import module namespace marcutil			= 		"info:lc/xq-modules/marc-utils" 		at	"modules/module.marcutils.xqy";


import module namespace bf4ts   			=      "info:lc/xq-modules/bf4ts#"  			at "modules/module.BIBFRAME-4-Triplestore.xqy";


declare variable $URI as xs:string external;
(:
declare variable $forests := for $f in xdmp:database-forests(xdmp:database("natlibcat")) where fn:matches(xdmp:forest-name($f), "natlibcat\-.+") return $f;
:)
declare variable $quality := ();
(:declare variable $body := xdmp:get-request-body("xml")/node();:)
(:declare variable $fileLocation as xs:string external;:)
declare variable $XML-STRING as xs:string external;
(: if overwrite=repl then update=replace, unconditionally:)


declare variable $TODAY as xs:string:=fn:substring(fn:string(fn:current-date()),1,10);
(:fn:concat("/processing/load/bibs/",$TODAY,"/"):)


    
(:
    Unique URI strategy
    
    c+ zero padded bibid +
    4-digit number, beginning 0001

:)
(:
    Tokenize URI
    Generate work URI  
    Get Bib MARC/XML
    
    Transform: MARCXML/BIB to BIBFRAME/RAW
    
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
declare function local:remove-from-coll($bibid) {
	let $id:=fn:concat("c",bibs2mets:padded-id($bibid))

	let $collection:="/catalog/"

	let $dirtox := bibs2mets:chars-001($id)

return
	for $type in ("works", "instances", "items")
		let $dir := fn:concat("/lscoll/lcdb/",$type,"/", string-join($dirtox, '/'), '/*')
		
		for $uri in cts:uri-match($dir)
			
				return ( try {( xdmp:document-add-collections($uri,"/deletes/")
								,xdmp:log(fn:concat("success adding delete coll to ", $uri),"info")
													
								)
								}catch($e){ ()
								}
							,
				        try { (
							 xdmp:document-remove-collections($uri,$collection)
							,xdmp:log(fn:concat("CORB bib merge success removing ", $uri, " from  ",$collection),"info"))
							}catch($e){
								xdmp:log(fn:concat("CORB bib merge failed to remove ",$uri, " from ",$collection),"info")}
							,
					 	try {(
							xdmp:document-delete(fn:concat("/bibframe-process/records/",$bibid,".xml"))		
							,xdmp:log(fn:concat("success deleting marc record for ", $uri),"info"))
				        } catch ($e) {			           
				             (   
				                 xdmp:log(fn:concat("CORB BIB merge: deleting source /bibframe-process/records/ failed  for bibid  : ",$id )   , "info")
							 )
						},
						 xdmp:log(fn:concat("CORB BIB merge: done deleting from catalog ",$type, ": ",$uri," for bibid  : ",$id )   , "info")          
						)   
};




(:==========================main program ====================:)
let $start := xdmp:elapsed-time()
let $OVERWRITE:=""

return 
 if ( fn:not( try {
 					fn:doc-available($URI)
					}
					 catch ($e){
					 			fn:false()	   								
				}
				)
	) then
   			xdmp:log(fn:concat("CORB BIB merge: skip: ",$URI , " marc doc not found error " ), "info")
	else
	let $body := try { fn:doc($URI)
					}catch($e){()}
					   			
	return if (fn:not($body)) then
				()
			else 
	for $record in $body/descendant-or-self::marcxml:record
		let $already-in-pilot:=   
			for $tag in $record/marcxml:datafield[@tag="985"]/marcxml:subfield[@code="a"]
      			return if (fn:matches(fn:string($tag) ,"BibframePilot2","i")) then
        			fn:true()
       			else 
        			()
  return if ($already-in-pilot) then
				xdmp:log(fn:concat("CORB BIB merge: skip: ",fn:string($record/marcxml:controlfield[@tag="001"]) , ", has 985." ), "info")
				else

  			if (fn:substring($record/marcxml:leader,6,1)="d") then
	
					(
						local:remove-from-coll(fn:string($record/marcxml:controlfield[@tag="001"]))
						,	xdmp:log(fn:concat("CORB BIB stop after deletion for ",$URI), "info")
					)
			else
	
				let $marcxml := <marcxml:collection xmlns:marcxml="http://www.loc.gov/MARC21/slim">{$record}</marcxml:collection>
	
	
				let $cleanmarc:=xdmp:quote($marcxml)
				let $marcxml:= xdmp:unquote(fn:replace($cleanmarc,"\[from old catalog\]",""	))
	
				let $BIBURI:= fn:replace(fn:string($record/marcxml:controlfield[@tag="001"]),"\D+","")
				let $BIBURI := bibs2mets:padded-id($BIBURI)

				(:	converted records are prefixed with "c" so they don't overwrite name/titles:)
				let $paddedID := fn:concat("c",$BIBURI)
				let $workURI := fn:concat("http://id.loc.gov/resources/works/" , $paddedID)
				let $workDBURI := fn:concat("loc.natlib.works.",$paddedID)
						(: fn:concat("/resources/works/" , $paddedID, ".xml"):)

			(:-------------------------from ingest-voyager-bib  -------------------------:)
				let $resclean := $paddedID
				let $dirtox := bibs2mets:chars-001($resclean)
				let $dest := "/lscoll/lcdb/works/"
			    let $destination-root := $dest
			    let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
			    let $destination-uri := fn:concat($dir, $resclean, '.xml')
			    let $destination-collections := ($destination-root,  "/catalog/", 
				    		"/catalog/lscoll/lcdb/bib/", "/bibframe-process/reloads/2017-09-16/","/bibframe-process/yaz-reload/",
							fn:concat("/processing/load/bibs/",$TODAY,"/"))
				
				let $destination-collections:=
					 if ($marcxml//marcxml:datafield[@tag="906"]/marcxml:subfield[@code="a"]="0") then
			 			($destination-collections ,"/bibframe-process/not-distributed/")
			 		else
			 			$destination-collections
			(:-------------------------from ingest-voyager-bib  -------------------------:)


			(:check if doc is already there;  or it was merged onto a work; the instance will be there, so skip 
						I only needed this on retrying bulk loads
				let $probable-instance-uri:= fn:replace($destination-uri,"/works/","/instances/")
				let $probable-instance-uri:= fn:replace($probable-instance-uri,".xml","0001.xml")
			:)


			return 
				

			 (: reprocessing: don't check for already there:
			 	if ( 
			  			fn:not(fn:doc-available($probable-instance-uri))
				  ) then

				:)		
							let $mxe:= marcutil:marcslim-to-mxe2($marcxml/marcxml:record )	   
				
							let $params:=map:map()
							let $put:=map:put($params, "baseuri", "http://id.loc.gov/resources/works/")
							let $put:=map:put($params, "idfield", "001")
	
							return
							    if ($marcxml/descendant-or-self::marcxml:record/marcxml:leader) then
							        let $bfraw := 
										try{					
											xdmp:xslt-invoke("/admin/bfi/bibrecs/xsl/marc2bibframe2.xsl",document{$marcxml},$params)			
										}
									 	catch ($e) {
											($e,					 
											 xdmp:log(fn:concat("CORB BIB merge: error: ",$workDBURI , " not loaded. ", fn:string($e/mlerror:message[1]) ), "info")
											)
						                }
					(: not working!  fix bad urls in abouts, resources
					need to do this in the conversion instead :)
					(:let $_:=for $n  in  $bfraw//@rdf:about[fn:contains(., " ")]
			                    let $b:=attribute rdf:about{fn:replace(fn:string($n)," ", "")}
					
												return ( mem:node-replace($n, $b))
        
					 let $_:=for $n  in  $bfraw//@rdf:resource[fn:contains(., " ")]
			                    let $b:=attribute rdf:resource{fn:replace(fn:string($n)," ", "")}
													return  mem:node-replace($n, $b)
			        	:)			
								    return (
									    	if ($bfraw instance of element(error:error)) then 
													$bfraw 
											else 						
												bibs2mets:get-work($bfraw/rdf:RDF,$workDBURI,$paddedID, $BIBURI, $mxe,  $destination-collections,$destination-uri, $OVERWRITE)
									
											,
									    	xdmp:log(fn:concat("CORB BIB merge:  ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")
								    	)
							    else
							       (: fn:error():)
								   xdmp:log(fn:concat("CORB BIB merge: skip: ",$workDBURI , " MARC error " ), "info")

(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)