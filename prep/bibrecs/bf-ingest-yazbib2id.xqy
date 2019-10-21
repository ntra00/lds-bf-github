xquery version "1.0-ml";
(:
:  expects bf rdf in lclocal:graph chunks, loading to id-main without merge code
: MODIFIED from corb-bibframe-process-yazbib-files to expect rdf:RDF yaz output instead of marcxml
: Changes: 
	1)  natlibcat OBJID = "loc.natlib.works.c011268993"
		ID-main pattern = "/resources/works/c011268993.xml"
	2) file names natlibcat:  "/lscoll/lcdb/works/c/0/1/1/2/6/8/9/9/3/c011268993.xml"
					id-main:  "/resources/works/c011268993.xml"
					lookups not expected (before this ingest) 
	3)and no merging!
:
:   Module Version: 1.0
:
:   Date: 2019 April 17
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: cts, search,  xdmp (MarkLogic)
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
 
module namespace bfingest  = "info:lc/xq-modules/bf-ingest#"   ;


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


import module namespace b2mload 			= 		"http://loc.gov/ndmso/bibs-2-mets-load"	at 	"module.bibs2mets-load.xqy";


import module namespace bibframe2index      =       "info:lc/id-modules/bibframe2index#" 	at "module.BIBFRAME-2-INDEX.xqy";




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
declare function bfingest:remove-from-coll($bibid) {


let $id:=fn:concat("c",b2mload:padded-id($bibid))
let $collection:="/catalog/"


let $dirtox := b2mload:chars-001($id)
for $type in ("works", "instances", "items")
	let $dir := fn:concat("/lscoll/lcdb/",$type,"/", string-join($dirtox, '/'), '/*')
	
	for $uri in cts:uri-match($dir)
			return ( xdmp:document-add-collections($uri,"/deletes/"),
			         xdmp:document-remove-collections($uri,$collection)
				 	,
					 xdmp:log(fn:concat("BFIN ingest: deleting from catalog ",$type, ": ",fn:tokenize($uri,"/")[fn:last()]," for bibid  : ",$id )   , "info")          
					)   
};




(:==========================main program ====================:)
declare function bfingest:transform(
  $content as map:map,
  $context as map:map
)(: as map:map?:)

{

	let $start := xdmp:elapsed-time()
	
	let $body := map:get($content, "value")
	let $orig-uri := map:get($content, "uri")  (: file name! :)
	
	let $_:=xdmp:log(fn:concat("BFIN: bfingest  uri starting: ",$orig-uri),"info")
	
return 

	for $set in $body/descendant-or-self::rdf:RDF
	
	 for $records in $set/rdf:Description/lclocal:graph
		
	
		for $work in $records/bf:Work[parent::lclocal:graph]
	

	(: 2019-01-17: leader 06 status new and changed generate a status; otherwise it's a delete:)
		return if ( fn:not($work/bf:adminMetadata/bf:AdminMetadata/bf:status) or
				 $work/bf:adminMetadata[1]/bf:AdminMetadata/bf:status/bf:Status[fn:string(bf:code)="d"] )
		 then
				let $bibid:= fn:replace(fn:string($work/@rdf:about), "^http://example.org/([0-9]+)#Work$","$1")
				let $_:=xdmp:log($bibid,"info")
				let $_:=xdmp:log("delete/hide","info")
					return
							bfingest:remove-from-coll($bibid)
  			else
		(: not sure this makes sense or does anything :)
		let $already-in-pilot:=   
			for $batch in $work/bf:adminMetadata/bf:AdminMetadata/lclocal:batch
	      		return if (fn:matches(fn:string($batch) ,"BibframePilot2","i")) then
	        			fn:true()
	       			else 
	        			()
		 return if ($already-in-pilot) then
						xdmp:log(fn:concat("BFIN ingest: skip: ",$orig-uri , ", has 985." ), "info")
				else
					
							
					let $work-about:= fn:string($work/@rdf:about)
					let $instances:=$records/bf:Instance[fn:string(bf:instanceOf/@rdf:resource) = $work-about ]
					let $record:=<rdf:RDF>{$work, $instances}</rdf:RDF>
					
					(:let $bf:=$record/element():)
					let $bf:=$record
					let $BIBURI:= fn:tokenize($work-about,"/")[fn:last()]
					let $BIBURI:=fn:substring-before($BIBURI,"#Work")
					let $BIBURI := b2mload:padded-id($BIBURI)

					(:	converted records are prefixed with "c" so they don't overwrite name/titles:)
					let $paddedID := fn:concat("c",$BIBURI)
					let $workURI := fn:concat("http://id.loc.gov/resources/works/" , $paddedID)
					
					let $workDBURI := 
							 fn:concat("/resources/works/" , $paddedID, ".xml")

				
				    let $destination-uri := $workDBURI
				    
					let $destination-collections := ("/resources/works/", "/catalog/", 
				    		 "/bibframe-process/loads/2017-04-17/","/bibframe-process/yaz-reload/",
							fn:concat("/processing/load/bibs/",$TODAY,"/"))
					let $_:=   xdmp:log(fn:concat("BFIN ingest:  $BIBURI ", $BIBURI), "info")
				(:-------------------------from ingest-voyager-bib ^^^^^^^-----------------------:)

					let $mxe:=<mxe:record><!--none--></mxe:record>					
	
					let $result:=						
							(
								b2mload:get-work($bf,$workDBURI,$paddedID, $BIBURI, $mxe,  $destination-collections,$destination-uri)
			  					,
							    xdmp:log(fn:concat("BFIN ingest:  ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")
						    	)
				    
return ()
};
