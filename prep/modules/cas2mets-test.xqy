xquery version "1.0-ml";

(:production bf2mets.xqy

	this is  the editor processor, calls some of the functions in the converter processor
	module namespace bf2mets = "http://loc.gov/ndmso/authorities-2-bibframe";

the transform function is called on ingest from the bfe editor director bfe-mlcp.sh?s
If you are posting directly, you call bibrecs/bfe-post2database.xqy, which calls these functions, working on $body, not map:map

2 root nodes (work , instance, item) possible if they are linked

IBC note:  ibc records are this instance, it's work, and any items for this instance.
It is not safe to rename the work of an ibc to it's lccn, so the work record should stay the same.
Items and Instance can be updated to e[lccn].
:)
	module namespace cas2mets = "http://loc.gov/ndmso/cas-2-mets";

declare copy-namespaces no-preserve, inherit;
declare namespace   mets       		    = "http://www.loc.gov/METS/";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   owl                 = "http://www.w3.org/2002/07/owl#";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf             = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mads	            = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mxe					= "http://www.loc.gov/mxe";
declare namespace   ri                  = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   bf              	= "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace   index               = "info:lc/xq-modules/lcindex";
declare namespace   idx               	= "info:lc/xq-modules/lcindex";
declare namespace   mlerror	            = "http://marklogic.com/xdmp/error"; 
declare namespace 	pmo  				= "http://performedmusicontology.org/ontology/";
declare namespace   rel                 = "http://id.loc.gov/vocabulary/relators/";	
declare namespace   share                 = "http://share-vde.org/sharevde/rdfBibframe2/";
import module namespace sem 				= "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace	bf4ts   			= "info:lc/xq-modules/bf4ts#"   		 at "module.BIBFRAME-4-Triplestore.xqy";
import module namespace bibframe2index      = "info:lc/id-modules/bibframe2index#" at "module.BIBFRAME-2-INDEX.xqy";
import module namespace mem = "http://xqdev.com/in-mem-update" at '/MarkLogic/appservices/utils/in-mem-update.xqy';

(: ==============================================================================================================
:	ALERT: using test version of bibs2mets: (drop .new to revert to production version
:   =============================================================================================================:)
import module namespace bibs2mets = "http://loc.gov/ndmso/bibs-2-mets" at "module.bibs2mets.xqy";

declare variable $quality := ();    
declare variable $forests:=();
(: these recs all go into test/editor: :)
declare variable $BASE_COLLECTIONS:= ("/test/casalini/","/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/", "/catalog/lscoll/lcdb/bib/" );
	
(: 
	load an rdf description from the bf editor and save as $bfraw like the corb-bibframe-process-bib-files.xqy likes
	
	also... add to collections?

 :)

(: 	this assumes work, instance, item, inserts all
	lccn will be populated if the instance has it

	Note: if the record is an ibc, it will have an lccn and the about will be the c-number

 :)
declare function cas2mets:full-package-insert($workraw, $body, $linkables, $lccn){
(: lccn is in $linkables but not embedded hierarchically yet:)
	let $worktype := fn:local-name($workraw)

	let $rdftype:= fn:concat("http://id.loc.gov/ontologies/bibframe/", $worktype)

	let $work-about:= fn:string($workraw/@rdf:about)

	(:
	http://share-vde.org/sharevde/rdfBibframe2/Lccn/12e1fb44-0fad-3031-9516-17276e69da0a
	new editor about:"http://id.loc.gov/resources/works/JWY1497005544"
	new editor about:"http://id.loc.gov/resources/works/eJWY1497005544"
	converted bib about="http://bibframe.example.org/5226#Work
	ibc about= http://id.loc.gov/resources/works/c0005226
	:)
	let $_:=xdmp:log(fn:concat("work-about:",$work-about),"info")
	let $ibc:=for $n at $x in  $workraw//bf:AdminMetadata[fn:string(bflc:procInfo) = "ibc update"]
					 return $x 
	let $ibc:=if ($ibc) then "yes" else "no"
	let $_:=xdmp:log(fn:concat("CORBT ibc:",$ibc),"info")
	
	
	let $instances-reformatted := 
	    for $instance in $body/bf:Instance	    			
			return  cas2mets:process($instance, $linkables)
			
		
	(: try to get sharevde lccn from instances-reformatted:)		
	let $lccn:=if (fn:contains($work-about , "http://share-vde.org/sharevde") ) then
	  	(for $i in $instances-reformatted
			return if ( $i/bf:identifiedBy/bf:Lccn[1][fn:not(bf:status)]/rdf:value) then
      				 fn:string($i/bf:identifiedBy/bf:Lccn[1][fn:not(bf:status)]/rdf:value)
      			 else ()
			)[1]

	   else   $lccn 

	
	let $BIBURI:=
		if ($lccn and fn:matches($work-about,$lccn)) then (: editing an existing edited name/title from db ?:)
				$lccn
		else if ($lccn and fn:contains($work-about,"http://share-vde.org")) then (: editing an existing edited name/title from db ?:)
				fn:concat("e",$lccn)
		
		else if ($lccn and $ibc!="yes") then
				(: this excludes ibcs; they can't get a new number in case they have other instances not in this package :)
				fn:concat("e",$lccn)
		else if (fn:starts-with ($work-about, "http://id.loc.gov/resources/works/")) then
				fn:substring-after($work-about, "/works/")
	    else if (fn:contains($work-about, "example.org")) then
				fn:substring-before(fn:tokenize($work-about, "/")[fn:last()], "#Work")
		else if (fn:contains($work-about, ".works.")) then
				fn:substring-after($work-about, "works.")
		else if ($work-about) then
		 	$work-about (:rdf:about="http://bibframe.example.org/5226#Work:)
		else if ($workraw/@rdf:nodeID ) then (: rdf:nodeid? :)
			 fn:string($workraw/@rdf:nodeID)
		else if ($workraw//bf:Lccn) then				
				fn:concat("e",fn:replace(fn:string($workraw//bf:Lccn[1]/rdf:value)," ",""))
		else "NoWorkID"
		
		
		
		
	let $BIBURI := bibs2mets:padded-id($BIBURI)	
	let $paddedID := 
	    if (fn:contains($work-about, "example.org")) then
		   fn:concat("c", $BIBURI) (: match existing record in database or follow the pattern fora new one:)
		else
	        $BIBURI

	let $workURI := fn:concat("http://id.loc.gov/resources/works/" , $paddedID)
	let $workDBURI := fn:concat("loc.natlib.works.", $paddedID)			

	let $attribs:= 
		if ($lccn) then 
			attribute rdf:about {$workURI}
	    else if (fn:contains($workraw/@rdf:about,"example.org")) then 
		   ($workraw/@*[fn:not(. instance of attribute(rdf:about))], attribute rdf:about {$workDBURI})
		else if ($workraw/@rdf:nodeID ) then 
			attribute rdf:about {$workURI}
		 else
		   ($workraw/@*)
	
	
	let $workraw2 :=
	    <bf:Work>
	        {$attribs}
	        {if ($rdftype) then <rdf:type rdf:resource="{$rdftype}"/> else ()}
	        {$workraw/*}
			
	    </bf:Work>

	let $work:= cas2mets:process($workraw2, $linkables)
(: instances -reformatted was here :)
	

	(: item is either the main body or in a work/instance or in an instance:
		was too broad:
			for $item in $body/bf:*/bf:hasItem/bf:Item
	    		return cas2mets:process($item, $linkables),				
	:)
	
	let $items-reformatted := 
	    	(
			for $item in $body/bf:Item
	    		return cas2mets:process($item, $linkables),			
			for $item in $body/child::*/bf:hasInstance/child::*/bf:hasItem/bf:Item
	    		return cas2mets:process($item, $linkables),			
			for $item in $body/child::*/bf:hasItem/bf:Item
	    		return cas2mets:process($item, $linkables)
			)
		
	
	let $bfraw:=
		<rdf:RDF xmlns="http://id.loc.gov/ontologies/bibframe/"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
				xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
				xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
		 		xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
				xmlns:share="http://share-vde.org/sharevde/rdfBibframe2/"
		  		xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"> {
		  		   ($work, $instances-reformatted, $items-reformatted)
		}
		</rdf:RDF>

	(:-------------------------from ingest-voyager-bib  -------------------------:)
	let $resclean := $paddedID
	let $dirtox := bibs2mets:chars-001($resclean)	
	let $destination-root := "/lscoll/lcdb/works/"
	let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
	let $destination-uri := fn:concat($dir, $resclean, '.xml')
	(:-------------------------from ingest-voyager-bib  -------------------------:)
	

let $_:= xdmp:log(fn:concat("CORBT $BIBURI ",$BIBURI),"info")
let $_:= xdmp:log(fn:concat("CORBT $paddedID ",$paddedID),"info")
let $_:= xdmp:log(fn:concat("CORBT $workURI ",$workURI),"info")
let $_:= xdmp:log(fn:concat("CORBT $workDBURI ",$workDBURI),"info")
let $_:= xdmp:log(fn:concat("CORBT $destination-uri ",$destination-uri),"info")
	

	(: formats work, inserts it, inserts instances and items :)
	let $work-id := cas2mets:get-work($bfraw, $workDBURI, $paddedID, $BIBURI,  $destination-uri,$ibc, $lccn)
	
	(:
		let $work-remove:=
				if ($ibc="yes") then
					cas2mets:hide-doc($work-about,"works")
					
		else
			()
	:)
	
	
	return 

	    if ($work-id instance of empty-sequence()) then
	        ( ()
	            (:xdmp:set-response-code(400, "Bad Request"),
	            xdmp:set-response-content-type("application/xml"),
	            
	          <response xmlns="response" element-type="bfraw">{$bfraw}</response>:)
	        )
	    else
	        ((:
	            xdmp:set-response-code(200, "OK"), 
	            xdmp:set-response-content-type("text/plain"),:)
	            $work-id
	        )
 
 };
(: posts only instances and/or items (or ibc with instance as main doc)   :)
declare function cas2mets:partial-package-insert($body, $linkables, $lccn)	{
	
(:somehow 	first node not instance?? :)
	let $root-node:=$body/*[self::* instance of element (bf:Instance) or self::* instance of element (bf:Item) ]
	let $instancetype := fn:local-name($root-node)
	
	let $rdftype:= fn:concat("http://id.loc.gov/ontologies/bibframe/", $instancetype)

	let $instance-about:= if ($instancetype="Instance") then 
						fn:string($root-node/@rdf:about)
					else 	
						fn:string($body/*[1]/@rdf:about)
	(:
	new editor about:"http://id.loc.gov/resources/instances/eJWY1497005544"
	converted bib about:rdf:about="http://bibframe.example.org/5226#Work
	:)
	
	let $BIBURI:=
		if ($lccn and fn:contains($instance-about,$lccn)) then (: editing an existing edited name/title from db ?:)
				fn:concat($lccn,fn:substring($instance-about,fn:string-length($instance-about)-4))
		else if ($lccn) then 
			fn:concat("e",$lccn)
		else if (fn:starts-with ($instance-about, "http://id.loc.gov/resources/instances/")) then
				fn:substring-after($instance-about, "/instances/")
	    else if (fn:contains($instance-about, "example.org")) then
				fn:substring-before(fn:tokenize($instance-about, "/")[fn:last()], "#Instance")
		else if (fn:contains($instance-about, ".instances.")) then
				fn:substring-after($instance-about, "instances.")
		else if ($instance-about) then
		 	$instance-about (:rdf:about="http://bibframe.example.org/5226#Work:)
		else if ($body/child::*/@rdf:nodeID ) then (: rdf:nodeid? :)
			 fn:replace(fn:string($body/child::*/@rdf:nodeID),"^bnode","e")
		
		else "NoInstanceID"
			
	let $BIBURI := bibs2mets:padded-id($BIBURI)	
	let $paddedID := 
	    if (fn:contains($instance-about, "example.org")) then
		   fn:concat("c", $BIBURI) (: match existing record in database or follow the pattern fora new one:)
		else
	        $BIBURI

	let $instanceURI := fn:concat("http://id.loc.gov/resources/instances/" , $paddedID)
   let $_:=xdmp:log(fn:concat("CORBT partial package $instanceURI:", $instanceURI),"info")
    let $instanceDBURI := fn:concat("loc.natlib.instances.", $paddedID)			
	let $instances-reformatted := 
		  (for $instance in $body//bf:Instance	    
			return  cas2mets:process($instance, $linkables),
			for $instance in $body/child::*[1]/bf:hasInstance/bf:Instance	    
				return  cas2mets:process($instance, $linkables)
				(: is this needed?? instance may be bf:Electronic? :)
					,
					for $instance in $body/*[fn:not(self::* instance of element (bf:Instance))][bf:instanceOf]
						return cas2mets:process($instance, $linkables)			
			)

	let $ibc:=if (contains($instance-about,"instances/c0") and $lccn!="") then
					"yes" else "no"
		
	let $insert-instances := cas2mets:insert-instances(<rdf:RDF>{$instances-reformatted}</rdf:RDF>, $instanceDBURI,$paddedID,<mxe:empty-record/>,(), $ibc,$lccn )
		
	let $items-reformatted := 
		    (for $item in $body/bf:Item
		    	return cas2mets:process($item, $linkables)	
				,
				for $item in $root-node/bf:hasItem/bf:Item
		    		return cas2mets:process($item, $linkables)	
					)
		
	let $insert-items:=cas2mets:insert-items(<rdf:RDF>{$items-reformatted} </rdf:RDF>,"",() ) 

return (
	            (:xdmp:set-response-code(200, "OK"), 
	            xdmp:set-response-content-type("text/plain"),:)
	             $instanceDBURI 
	        )

};

declare function cas2mets:insert-instances($bfraw, $workDBURI, $paddedID, $mxe, $adminMeta, $ibc, $lccn) {
	
	(: 
		convert instances to mets:
			send empty workdburi and paddedid, since Instances are already correctly formatted and have links to work
			bf:Instance rdf:about="http://id.loc.gov/resources/instances/fd11ebcaabb1">
			and there is no $mxe or work admin metadata	

	:)	
	let $_:=xdmp:log(fn:concat("workdburi: ",$workDBURI, " paddedid: ", $paddedID,", lccn:", $lccn),"info")
	
	let $instances-mets := bibs2mets:get-instances($bfraw,$workDBURI, $paddedID, $mxe, $adminMeta[1], $lccn, $ibc)

	let $instance-collections := (($BASE_COLLECTIONS),"/resources/instances/","/bibframe/","/bibframe/editor/", "/lscoll/lcdb/instances/")     	
  
    let $insert-instances :=
        for $i in $instances-mets 			

			(: instances is now one or more mets object			:)
			(:-------------------------from ingest-voyager-bib  -------------------------:)
			let $bibid := fn:tokenize( xs:string($i/@OBJID), "\.")[fn:last()]
					(: create subdirectories from first 10 alphas :)
			let $resclean 			:= fn:substring($bibid,1,10)
			let $dirtox 			:= bibs2mets:chars-001($resclean)
			let $destination-root 	:= "/lscoll/lcdb/instances/"
		    let $dir 				:= 	fn:concat($destination-root, string-join($dirtox, '/'), '/')
		    let $destination-uri 	:= fn:concat($dir, $bibid,'.xml')    

			(:-------------------------from ingest-voyager-bib  -------------------------:)
			(:================ IBC: change instance reference, and remove c* instance from /catalog/ ================
				 ibc use e[lccn] instead of c[bibid] for ibc updates, remove c's from /catalog/ 
				 but not on the work
			
			================================================================:)
			let $orig-work-link:= if  ($ibc="yes") then
										if ($i//rdf:RDF/bf:Instance/bf:instanceOf/@rdf:resource) then
											fn:string($i//rdf:RDF/bf:Instance/bf:instanceOf/@rdf:resource)
										else if ($i//rdf:RDF/bf:Instance/bf:instanceOf/child::*[1]/@rdf:about) then
											fn:string($i//rdf:RDF/bf:Instance/bf:instanceOf/child::*[1]/@rdf:about)
											else ()
									else ()
			
			let $orig-instance-id:=fn:tokenize($orig-work-link,"/")[fn:last()]
			let $orig-instance-link:=fn:concat($orig-work-link,fn:substring($bibid, fn:string-length($bibid)-3,4))
			let $orig-instance-link:=fn:replace($orig-instance-link,"works","instances")

			let $new-lccn-based-work-id:=fn:tokenize($workDBURI,"\.")[fn:last()]
			let $change-work-link:= if ($orig-work-link) then
										fn:replace($orig-work-link, fn:tokenize($orig-work-link, "/")[fn:last()],$new-lccn-based-work-id)
									else
										""

			let $_:=xdmp:log(fn:concat("bibid is instance-id? to be  for hiding? ", $bibid), "info")
			let $_:=xdmp:log(fn:concat("to be replaced: ", $orig-work-link, " with : ",fn:string($change-work-link), " instance to be hidden:", $orig-instance-link), "info")
			let $_:=if ($change-work-link != "" ) then
							(							
							xdmp:log(fn:concat("hidden instance: ", $orig-instance-link ), "info")
							)
						else ()
			let $_:=if ($ibc="yes") then
							xdmp:log(fn:concat("CORBT ibc instance? workdbu: ", $workDBURI," : instance uri", $destination-uri ," orig work: ",$orig-work-link, " newlink : ", $change-work-link),"info")
				else ()


	        return	  
				if ($i instance of element (mets:mets) )       then 
					try{	(
					 			xdmp:document-insert(
		         				   $destination-uri, 
		            				$i,
						            (
						                xdmp:permission("id-user-role", "read"), 
						                xdmp:permission("id-admin-role", "update"),
						                xdmp:permission("id-admin-role", "insert")
						            ),
									$instance-collections, $quality, $forests			
		        				)
								,
								xdmp:log(fn:concat("CORBT BFE editor load: loaded instance doc : ", xs:string($i/@OBJID),  " to : ",$destination-uri )   , "info")
								,
								if ($ibc="yes") then
									(xdmp:log(fn:concat("CORBT BFE instanceuri hiding:" , $orig-instance-link), "info"),
									 cas2mets:hide-doc($orig-instance-link,"instances")
									 )
								else ()
							)
						}
					catch ($e) { (xdmp:log(fn:concat("CORBT BFE editor load: failed to load instance doc : ", xs:string($i/@OBJID),  " to : "	,$destination-uri )   , "info"),
					 xdmp:log($e   , "info")
					 )
						}			
				 else 
				 	xdmp:log(fn:concat("CORBT BFE editor load: failed to convert to mets instance doc : ", xs:string($i/@OBJID), " to : ",$destination-uri )   , "info")

return fn:true()

};	
(: convert id rdf:about /rdf:resource to doc id, remove from catalog) :)

declare function cas2mets:hide-doc($uri, $type) {
        let $docid:=fn:tokenize($uri, "/")[fn:last()]
        let $dirtox 			:= bibs2mets:chars-001(fn:substring($docid,1,10))
        let $destination-root 	:= fn:concat("/lscoll/lcdb/",$type, "/")
        let $dir 				:= 	fn:concat($destination-root, string-join($dirtox, '/'), '/')
        let $destination-uri 	:= fn:concat($dir, $docid,'.xml')    

return if (fn:doc-available($destination-uri)) then
        (xdmp:document-remove-collections($destination-uri,"/catalog/")
        , xdmp:log(fn:concat("CORBT BFE hiding ", $destination-uri), "info")
        )
        else xdmp:log(fn:concat("CORBT BFE doc ", $destination-uri ," already hidden or not found"), "info")
};
declare function cas2mets:insert-items($bfraw as element(rdf:RDF),  $paddedID,  $adminMeta) {
(: this is currently in use for full 

	NOT called only by the partial???  need to worry about workdburi, padded id etc.!!!!
	only bfraw has anything if there is no work in the package
	workdburi is not used.

	items from the editor are not nested, so the bibs2mets code can't be used without major overhaul; 
		copied here and simplifed at cas2mets:get-items (except
		workdburi and paddedid may be empty.
:)	
	
	
	let $items-mets := (: bibs2mets:get-items($bfraw, "",() ,$paddedID, <mxe:record/>)			:)
		 
		 			cas2mets:get-items($bfraw, $paddedID)			
		
	let $item-collections := ($BASE_COLLECTIONS, "/resources/items/"  , "/bibframe","/bibframe/editor/",  "/lscoll/lcdb/items/")      	
    
	let $insert-items :=
        for $i in $items-mets
			(:-------------------------from ingest-voyager-bib  -------------------------:)
			let $bibid := fn:tokenize( xs:string($i/@OBJID), "\.")[fn:last()]				
			let $resclean := fn:substring($bibid,1,10)			
			let $dirtox := bibs2mets:chars-001($resclean)
			let $destination-root := "/lscoll/lcdb/items/"
		    let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
		    let $destination-uri := fn:concat($dir, $bibid, '.xml')
   			(:-------------------------from ingest-voyager-bib  -------------------------:)

        return
			if ($i instance of element(mets:mets) ) then
		           ( try {
				    xdmp:document-insert(
					           	$destination-uri ,
					            $i,
					            (
					                xdmp:permission("id-user-role", "read"), 
					                xdmp:permission("id-admin-role", "update"),
					                xdmp:permission("id-admin-role", "insert")
					            ),
								$item-collections, $quality, $forests			
		        		),
						xdmp:log(fn:concat("CORBT BFE editor load: loaded item doc : ", xs:string($i/@OBJID),  " to : " ,$destination-uri  )   , "info")
					}
						catch ($e) {xdmp:log(fn:concat("CORBT BFE editor load: error. failed to load item doc : ", xs:string($i/@OBJID), " to : " ,$destination-uri, fn:string($e)  )   , "info")
								}
					)
			else
				xdmp:log(fn:concat("CORBT BFE editor load: error. failed to convert to mets item doc : ", xs:string($i/@OBJID), $destination-uri  )   , "info")

return fn:true()

};

declare function cas2mets:get-items(
        $bfraw as element(rdf:RDF),         
        $paddedID as xs:string				
    )
{
      
    (: Go through items, create new id, create mets
	each instance may have one or more items.
	items get id's relative to position in the whole doc
	 :)    
     
let $items := 
      	
	  		for $item at $itempos in $bfraw/bf:Item (: for each item [@rdf:about  or @rdf:nodeID]:)
				let $this-item-about:=($item/@rdf:about||$item/@rdf:nodeID)[1]          													
	
		        let $iID:=bibs2mets:get-padded-subnode($itempos, $paddedID)
                	
					(: this may get hairy if the uri is good and not a transform from raw data entry!!:)
					
					let $instanceID:=fn:concat( $paddedID,"0001")
        
	                let $itemDBURI := fn:concat("loc.natlib.items." , $iID )
	                let $itemURI := fn:concat("http://id.loc.gov/resources/items/", $iID)
	          		let $derivedbib:= fn:replace($paddedID,"^c","")
	          		let $derivedbib:= fn:replace($derivedbib,"^0+","")
	          		 let $itemOf := 
					 	(:editor has no itemof? :)
	          	        		element bf:itemOf {          		           
	          				    	attribute rdf:resource { fn:concat("http://id.loc.gov/resources/instances/", $instanceID ) }
	                  }
					
		             let $item-modified := 
		                 element bf:Item {
		                     attribute rdf:about {$itemURI},					
		                     $item/*[fn:local-name() ne "itemOf" and fn:local-name() ne "derivedFrom" ],
		     				element bflc:derivedFrom {attribute rdf:resource {fn:concat("http://id.loc.gov/resources/bibs/",$derivedbib,".marcxml.xml")} },			
		                        $itemOf
		                 }
        
			        let $item-index := bibframe2index:bibframe2index( element rdf:RDF { $item-modified }, <mxe:empty-record/> )
		 			let $item-sem :=  
					
					 try {
			   					bf4ts:bf4ts(  element rdf:RDF {$item-modified} )
						} catch($e){
						       xdmp:log(fn:concat("CORBT BFE sem conversion error for ", $itemURI), "info")
						   }
			        let $item-mets := 
			            <mets:mets 
			                PROFILE="itemRecord" 
			                OBJID="{$itemDBURI}" 
			                xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
			                xmlns:mets	="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
			             	xmlns:rdf	="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
							xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"						
							xmlns:bf	= "http://id.loc.gov/ontologies/bibframe/" 
							xmlns:bflc	= "http://id.loc.gov/ontologies/bflc/" 
			                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
			                xmlns:xsi	= "http://www.w3.org/2001/XMLSchema-instance" 
			                xmlns:index	="info:lc/xq-modules/lcindex"
							xmlns:idx	="info:lc/xq-modules/lcindex">
			                <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
			                <mets:dmdSec ID="bibframe">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                            <rdf:RDF>
			                                {$item-modified}
			                            </rdf:RDF>
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
			                <mets:dmdSec ID="index">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                            {$item-index}
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
							 <mets:dmdSec ID="semtriples">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                            {$item-sem}
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
			                <mets:structMap>
			                    <mets:div TYPE="itemRecord" DMDID="bibframe index semtriples"/>
			                </mets:structMap>
			            </mets:mets>
            
        return $item-mets
            
    return $items
    
};
(: put the stub in with "relatedTo" or calculate all the inverses
	work comes in as rdf:rdf/bf:Work/bf:relatedto/bf:Work 
	now call bibs2mets
:)
declare function cas2mets:old-insert-work-stubs($work,$workDBURI, $paddedID, $BIBURI, $destination-uri)
{

let $inverse-relation:=if ($work instance of element(bf:hasExpression) ) then "bf:expressionOf"
						else "bf:relatedTo"

for $related at $workpos in $work/bf:Work/*

	let $inverse-relation:= if ($related instance of element (bf:hasExpression)) then "bf:expressionOf"
							else if ($related instance of element (bf:expressionOf)) then "bf:hasExpression"
							else if ($related instance of element (bf:otherEdition)) then "bf:otherEdition"
							else "bf:relatedTo"
		
	
	let $wID:=bibs2mets:get-padded-subnode($workpos, $paddedID)

    let $stub-destination-uri:=fn:concat(fn:replace($destination-uri,".xml",format-number($workpos,"0000")),".xml")
					
						 
    let $relWorkDBURI := fn:concat("loc.natlib.works." , $wID )
    let $relworkURI := fn:concat("http://id.loc.gov/resources/works/", $wID)
		
		 let $relatedTo := 			 	
	        		element {xs:QName($inverse-relation)} {
								attribute  rdf:resource {
												fn:concat('http://id.loc.gov/resources/works/', $paddedID ) 
												 	}
												 }
      
	  let $stub-work:= <rdf:RDF>
			  <bf:Work rdf:about="{$relworkURI}">
					{$related/bf:Work/*}
					{$relatedTo}
			</bf:Work>	</rdf:RDF>

    let $stub-collections := ("/lscoll/lcdb/works/","/resources/works/","/bibframe/","/bibframe/editor/","/bibframe/stubworks/" ,$BASE_COLLECTIONS)

	let $insert-stub-mets:= bibs2mets:insert-any-mets($stub-work  ,$relWorkDBURI ,  $stub-destination-uri, $stub-collections )

	return 
        (         
            $relWorkDBURI            
        )

};
 (: ibc is yes/no is this a change from c012346 to e2017... 
 added work-about as old work uri for ibc edits
 
 if ibc=yes then dont' change the work to the lccn
 
 :)
declare function cas2mets:get-work($bfraw, $workDBURI, $paddedID, $BIBURI, $destination-uri, $ibc, $lccn) 
{

	let $bfraw-work := if ($bfraw/rdf:RDF ) then $bfraw/rdf:RDF/bf:Work
						else if ($bfraw/bf:Work ) then 
							$bfraw/bf:Work
						else $bfraw

    let $hasRelatedWorks:= if  ($bfraw/bf:Work/*[fn:not(self::* instance of element (bf:subject))]/bf:Work) then
                           	 for $relation at $x in $bfraw/bf:Work/*[fn:not(self::* instance of element (bf:subject))][bf:Work]
								return
										element {fn:concat("bf:",fn:local-name($relation))} {attribute rdf:resource {
											fn:concat("http://id.loc.gov/resources/works/",$paddedID,format-number($x,"0000"))
										}
										}
								else ()
	
	let $relateds:=if  ($bfraw/bf:Work/*[fn:not(self::* instance of element (bf:subject))]/bf:Work) then
						
						let $rels:=			
							<rdf:RDF><bf:Work>{
								$bfraw/bf:Work/*[fn:not(self::* instance of element (bf:subject))][child::* instance of  element(bf:Work)]	
	    					}</bf:Work></rdf:RDF>
							return (	bibs2mets:insert-work-stubs($rels,$workDBURI, $paddedID, $BIBURI, $destination-uri))
                            
					else  ()

	let $hasInstances:= for $hasInstance at $x in $bfraw-work/*[self::node() instance of element(bf:hasInstance )]
						return
							if (fn:contains($hasInstance/@rdf:resource,"example.org") or $hasInstance/bf:Instance/@rdf:nodeID ) then
										element bf:hasInstance {attribute rdf:resource {
											fn:concat("http://id.loc.gov/resources/instances/",$paddedID,format-number($x,"0000"))
										}
										}
								else 	$hasInstance
	
	let $bfwork:= <bf:Work>	{$bfraw-work/@*}
							{$bfraw-work/*[fn:local-name()!="hasInstance"]}
							{$hasRelatedWorks}							
							{$hasInstances}							
					</bf:Work>	
	
(:was indexing bfraw work, and semmming!! :)
	let $work-bfindex :=
	   try {
	       bibframe2index:bibframe2index(<rdf:RDF>{$bfwork}</rdf:RDF>, <mxe:empty-record/> )
	   } catch($e){
	       $e
	   }
	let $work-sem :=  try {
			   					bf4ts:bf4ts( <rdf:RDF>{ $bfwork }</rdf:RDF> )
						} catch($e){
						       xdmp:log(fn:concat("CORBT BFE sem conversion error for ", $BIBURI), "info")
						   }
	

    let $work-mets := 
        <mets:mets 
            PROFILE="workRecord" 
            OBJID="{$workDBURI}" 
            xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
            xmlns:mets	="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
            xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"			
			xmlns:rdf   = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:bf	="http://id.loc.gov/ontologies/bibframe/" 
			xmlns:bflc	="http://id.loc.gov/ontologies/bflc/" 
        	xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
			xmlns:relators      = "http://id.loc.gov/vocabulary/relators/"            
            xmlns:index="info:lc/xq-modules/lcindex"
			xmlns:idx="info:lc/xq-modules/lcindex">
            <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
            <mets:dmdSec ID="bibframe">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        <rdf:RDF> {$bfwork }</rdf:RDF>
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>			
			<mets:dmdSec ID="mxe"><mets:mdWrap MDTYPE="OTHER"><mets:xmlData><mxe:empty-record/></mets:xmlData></mets:mdWrap></mets:dmdSec>
            <mets:dmdSec ID="index">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        {$work-bfindex}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
			<mets:dmdSec ID="semtriples">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        {$work-sem}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
            <mets:structMap>
                <mets:div TYPE="workRecord" DMDID="bibframe mxe index semtriples"/>
            </mets:structMap>
        </mets:mets>
	
    let $work-collections := ("/lscoll/lcdb/works/","/resources/works/","/bibframe/","/bibframe/editor/", $BASE_COLLECTIONS)

    let $work-lock:=xdmp:log(xdmp:document-locks($destination-uri),"info")
 
 let $_:=xdmp:log(fn:concat("CORBT BFE editor load: about to try doc insert on : ",$workDBURI, " from bib doc : ",$BIBURI  ," to ",  $destination-uri)   , "info")

	let $insert-work := 
         
		 		xdmp:document-insert(
                 $destination-uri, 
                $work-mets,
                (
                    xdmp:permission("id-user-role", "read"), 
                    xdmp:permission("id-admin-role", "update"),
                    xdmp:permission("id-admin-role", "insert")
                ),
        		$work-collections, $quality, $forests
            )
		
        
        
	 
		(: if ibc=yes, find $c number doc and remove it from /catalog/:)



	let $adminMeta:=$bfraw-work/bf:adminMetadata[1]
	
	let $insert-instances:=cas2mets:insert-instances(<rdf:RDF>{$bfraw/bf:Instance}</rdf:RDF>, $workDBURI, $paddedID, <mxe:empty-record/>,$bfraw-work/bf:adminMetadata, $ibc,  $lccn)

	let $insert-items :=cas2mets:insert-items(<rdf:RDF>{$bfraw/bf:Item}</rdf:RDF>, $paddedID, $adminMeta)		

	return 
        (         
            $workDBURI            
        )
    
};
(: embed related nodes :)
declare function cas2mets:process($nodes, $linkables ) as item()* {
 
 for $node in $nodes
    return 
      typeswitch($node)
        case text() 		return $node
        case attribute()  	return $node         
        case element() 		return cas2mets:decide($node,$linkables)     
       default return $node
};


declare  function cas2mets:decide($node,$linkables )  
{
(:resolves rdf:nodeIDs
:)
for $n in $node 

return
 
 if ($n/@rdf:nodeID) then 
     	cas2mets:resolve-bnode($n, $linkables) 
	 else if ($n instance of element(rdf:rest) and $n/@rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#nil") then () 
	 else if ($n instance of element(bf:instanceOf) and fn:starts-with(fn:string($n/@rdf:resource),"http://id")) then $node
	   (: casalini keep, don't resolve  the instanceOf  for circularity:)
	 else if ($n instance of element(bf:instanceOf) and fn:starts-with(fn:string($n/@rdf:resource),"http://share-vde.org/")) then $node
	 else if ($n instance of element(bf:itemOf) and fn:starts-with(fn:string($n/@rdf:resource),"http://share-vde.org/")) then $node
	 else if ($n/@rdf:resource) then 
     			cas2mets:resolve-bnode($n, $linkables) 	
	 else if ($n instance of element (bf:hasItem))  then $node  
	 else if ($n instance of element(bf:itemOf)) then $node  
	 else if ($n instance of element(bf:hasInstance)) then $node  	 
	 else if ($n instance of element(bf:instanceOf) ) then $node  	 	 
	 else if ($n instance of attribute (rdf:resource)) then $node  
	 else if ($n instance of element(rdf:first)) then  cas2mets:resolve-bnode($n,$linkables) 
	 else  if ($n instance of element(rdf:type)) then
	 	
     	  let $type:= fn:tokenize($n/@rdf:resource,"/")[fn:last()]
     	  (: CLAY QUESTION suppreses duplicative rdf types (bf:Agent rdftype rdf:resource=agent)  :)
       		return 
       		   if ($type = fn:local-name($n/parent::*)) then ()
               else $node
  
	 else if ($n/@rdf:resource) then $node  
(: this is not working :)
	 
	else
    			let $name:= cas2mets:getnamewithprefix($n)                 
   				return
     				element {$name} {$n/@*,       
           				cas2mets:process($n/node(),$linkables)
 }
        
};
declare function cas2mets:getnamewithprefix($node) {

let $node-name:=fn:name($node)
     return if (fn:matches($node-name,"label")) then "rdfs:label"
                 else if (fn:matches($node-name,"value")) then "rdf:value"                                  
				 else if (fn:matches($node-name,"rdf:Description") and fn:contains(fn:string($node/@rdf:about), "/sharevde/")) then 
                   	fn:concat("bf:",fn:tokenize(fn:string($node/@rdf:about),"/")[6])
                 else if (fn:contains(fn:namespace-uri($node),"/bibframe") ) then fn:concat("bf:", fn:local-name($node))
                 else if (fn:contains(fn:namespace-uri($node),"/bflc") ) then fn:concat("bflc:", fn:local-name($node))
                 else if (fn:contains(fn:namespace-uri($node),"/mads") ) then fn:concat("madsrdf:", fn:local-name($node))
				 else if (fn:contains($node-name,":")) then $node-name
				 else if (fn:matches($node-name,"Extent")) then "bf:Extent"				 
                 else $node-name
                 
    };
declare function cas2mets:resolve-bnode($node,$bf) {
    (:let $bf:= <rdf:RDF>{$linkables}</rdf:RDF>:)
    let $bnode:=
        if ($node/@rdf:nodeID ) then 
            fn:string($node/@rdf:nodeID )
        else if ($node/@rdf:resource) then 
            fn:string($node/@rdf:resource)
        else
            ()

    let $node-name:= fn:name($node)
	
    let $name:= cas2mets:getnamewithprefix($node) 
       
    let $result:= 
        <wrap> {
            cas2mets:process($node/node(),$bf),
            for $n in $bf/child::*[fn:local-name($node)!=fn:local-name()][@rdf:nodeID=$bnode or @rdf:about=$bnode]  
               return cas2mets:decide($n,$bf)
        }
        </wrap>
		

	  return
        if (fn:not(fn:matches(fn:name($node),"(rdf:first|rdf:rest)")))  then
              element {$name} {(: $node/@rdf:nodeID,:)
			  		if ($node/@rdf:resource and $result/child::*[1]/@rdf:about) then	
			  			 ()					
			  		else 
						$node/@rdf:resource,
                  if (fn:local-name($node)="componentList") then attribute rdf:parseType {"Collection" } else (),
                  	$result/*     
				  } 
        else $result/*
    
};

declare function cas2mets:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{


(:====================== main logic ======================

	Expectations: POSTED data will consist of a whole package, work, instance(s) , item(s) or an individual node with references to nodes in the db.
	if the work is null, process the instance by itself, (calculate Ids based on it as well.)
	Some works are embedded in instance; try to pull it out.
	also try to get lccn from instance

NEW workflow: ibc record ingested from database, (instance and it's work and items)
main node is instance/instanceof
  ====================== main logic ======================
:)

		
		let $orig-uri := map:get($content, 'uri')  

		let $_x:= xdmp:log(fn:concat("CORBT BFE editor load: orig uri " , $orig-uri  )   , "info")
		
		let $rdfbody := map:get($content, 'value')/rdf:RDF		
		
		(: multiples: if more than one Work, then chunk it :)
		return for $workpackage in $rdfbody/bf:Work[fn:starts-with(@rdf:about,"http://share-vde.org/sharevde/rdfBibframe2/Work/")][fn:not(fn:contains(fn:tokenize(@rdf:about,"/")[fn:last()],"-"))][1]
					
					let $w:=$workpackage
					let $wabout:=fn:string($w/@rdf:about)
					let $instances:=$rdfbody/bf:Instance/bf:instanceOf[@rdf:resource=$wabout]/parent::bf:Instance
					let $items :=for $inst in $instances
									for $it in $inst
										let $itabout:=fn:string($inst/bf:hasItem/@rdf:resource)
										return $rdfbody/bf:Item[@rdf:about=$itabout]
			
					let $body:=<rdf:RDF>{$w,
										$instances,
									$items
								}</rdf:RDF>

		(:$body/*[fn:name()][1] = rdf:RDF from editor :)
		let $root-node:=$body/*[self::* instance of element (bf:Work) or self::* instance of element (bf:Instance) or self::* instance of element (bf:Item) ]
		let $root-node:=$root-node[1]
		
		(:return if (count($root-node) !=1 ) then
	
			    xdmp:log(fn:concat("CORBT BFE: error loading, too many root nodes in: ",$orig-uri),"info")
			else
:)		
				
				(: share lccn is not available yet
				let $lccn:=  fn:string($body/rdf:RDF/bf:Instance[1]/bf:identifiedBy/bf:Lccn[1][fn:not(bf:status)]/rdf:value)

				let $lccn:= if ($lccn) then $lccn else  fn:string($body/bf:Work/bf:hasInstance/bf:Instance/bf:identifiedBy/bf:Lccn[1][fn:not(bf:status)]/rdf:value)
				
				
				let $lccn:= if ($lccn) then $lccn else  fn:string($body/bf:Work/bf:identifiedBy/bf:Lccn[1][fn:not(bf:status)]/rdf:value)
				let $lccn:= fn:replace($lccn," ","")
				:)
				 let $lccn:=()
				(: Can load the bibframe.rdf as Semantics sem:triples, and infer or property path the subclasses too :)
				(: editor stores the root node as subclasses; database needs bf:Work :)

				let $bfonto:= xdmp:http-get("http://id.loc.gov/ontologies/bibframe.rdf")[2]
				(:let $worktypes:=
				    for $subc in $bfonto//owl:Class[rdfs:subClassOf[@rdf:resource="http://id.loc.gov/ontologies/bibframe/Work"]]
					    return (fn:substring-after($subc/@rdf:about,"bibframe/"))
						
				let $instanceTypes:=
				    for $subc in $bfonto//owl:Class[rdfs:subClassOf[@rdf:resource="http://id.loc.gov/ontologies/bibframe/Instance"]]
					    return (fn:substring-after($subc/@rdf:about,"bibframe/"))
:)
				(:nodes that can be embedded into works etc :)
				let $linkables:= $rdfbody
				(:[fn:not(fn:matches(fn:local-name(),("Work", "Instance", "Item", $worktypes)))]:)

				(: convert to bf:Work from bf:Text :)
				let $workraw1:= 
				    if ($body/bf:Work and $root-node instance of element(bf:Work) ) then (: if first root is instance, the root Work is in instance-of:)
								$body/bf:Work[1]
						else if ($body/bf:Instance/bf:instanceOf/bf:Work) then
						(: this is the ibc payload :)
							$body/bf:Instance/bf:instanceOf/bf:Work
						
						else  if ($body/bf:Instance/bf:instanceOf/child::*[1]/rdf:type[@rdf:resource="http://id.loc.gov/ontologies/bibframe/Work"]) then									   
							$body/bf:Instance/bf:instanceOf/child::*[1]
						(: ibc with non-Instance root node, non-Work instanceOf :)
						else if ($body/child::*[1]/bf:instanceOf/*) then
							let $wtype:=fn:concat("http://id.loc.gov/ontologies/bibframe/",fn:local-name($body/child::*[1]/bf:instanceOf/*))
							return
								<bf:Work>
									<rdf:type rdf:resource="{$wtype}"/>
									{	$body/child::*[1]/bf:instanceOf/child::*[1]/@*,
										$body/child::*[1]/bf:instanceOf/child::*[1]/*
									}
								</bf:Work>
						else 
							(:for $type in $worktypes
								return
								   for $w in $body/*[fn:local-name()=$type]
							       return $w
						:)
		
				(:if $workraw1 is null, process instances , items   only   :)
				
				let $result:= if ($workraw1  ) then

						( xdmp:log(
										fn:concat("CORBT BFE editor load: full package " , 
													$lccn
										  			)
									   , "info")
							,																	 
										cas2mets:full-package-insert($workraw1,$body, $linkables, $lccn)
									)
							   else
							   		(: process instances, items :)
									
									let $_ := xdmp:log(fn:concat("CORBT BFE editor load: partial package " , $lccn  )   , "info") 
									return 
										cas2mets:partial-package-insert($body, $linkables, $lccn)

return xdmp:log(fn:concat("CORBT BFE editor load done: orig uri " , $orig-uri , " lccn: ", $lccn )   , "info")			
				
};
