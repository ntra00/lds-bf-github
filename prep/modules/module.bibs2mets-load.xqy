xquery version "1.0-ml";
(: 
	this is for loading to ID without merges
:)
module namespace b2mload = "http://loc.gov/ndmso/bibs-2-mets-load";


import module namespace 		bibframe2index   	= "info:lc/id-modules/bibframe2index#"   at "module.BIBFRAME-2-INDEX.xqy"; 
import module namespace 		bf4ts   			= "info:lc/xq-modules/bf4ts#"   		 at "module.BIBFRAME-4-Triplestore.xqy";
import module namespace 		mem 				= "http://xqdev.com/in-mem-update" 		 at "/MarkLogic/appservices/utils/in-mem-update.xqy";


declare namespace sparql                = "http://www.w3.org/2005/sparql-results#";
declare namespace 				rdf					= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace  				rdfs   			    = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   			mets       		 	= "http://www.loc.gov/METS/";
declare namespace  				marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace 				madsrdf   		    = "http://www.loc.gov/mads/rdf/v1#";
declare namespace  				mxe					= "http://www.loc.gov/mxe";
declare namespace 				bf					= "http://id.loc.gov/ontologies/bibframe/";
declare namespace				bflc				= "http://id.loc.gov/ontologies/bflc/";
declare namespace 				index 				= "info:lc/xq-modules/lcindex";
declare namespace 				idx 				= "info:lc/xq-modules/lcindex";
declare namespace   			mlerror	            = "http://marklogic.com/xdmp/error"; 
declare namespace				pmo 	 			= "http://performedmusicontology.org/ontology/";
declare namespace				lclocal				="http://id.loc.gov/ontologies/lclocal/";

declare variable $BASE_COLLECTIONS:= ("/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/",
	 "/catalog/lscoll/lcdb/bib/","/bibframe-process/reloads/2017-09-16/" );
declare variable $BASE-URI  as xs:string:="http://id.loc.gov/resources/works/";
(: 
	functions to format either bf raw output of conversion or
	bfe output to 3 mets docs for loading. (bfe does not merge, just stores)
	
 :)
 
(:
    Unique URI strategy
    
    c+ zero padded bibid +
    4-digit number, beginning 0001

:)
(:
    Tokenize URI
    Generate work URI  
    Get Bib MARC/XML
    
    Works
  
  		add to db 
			copy adminMeta to instance IF IT doesn't have one!

    Instance
        for each instance
            associate with work
            generate URI, add to DB.

    Items
        for each item
            associate with instance             
            use instance URI offset, add to DB.
			item ids are relative to the instance now c0001230001-2 eg.
:)
(:
    $pos is the offset position of an instance or item
    paddedid is the c00[bibid]
:)

declare function b2mload:get-padded-subnode($pos, $paddedID) as xs:string {

let $iNumStr := xs:string($pos)
  let $iNumLen := fn:string-length($iNumStr)
  let $iID := 
      if ( $iNumLen eq 1 ) then
          fn:concat( $paddedID, "000", $iNumStr )
      else if ( $iNumLen eq 2 ) then
          fn:concat( $paddedID, "00", $iNumStr )
      else if ( $iNumLen eq 3 ) then
          fn:concat( $paddedID, "0", $iNumStr )
      else
          fn:concat( $paddedID, $iNumStr )
          return $iID
   };
declare function b2mload:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};
(: padded to 9 if less :)
declare function b2mload:padded-id($id as xs:string) 
{

    let $idLen := fn:string-length( $id )
    let $paddedID := 
        if ( $idLen eq 1 ) then
            fn:concat("00000000" , $id)
        else if ( $idLen eq 2 ) then
            fn:concat("0000000" , $id)
        else if ( $idLen eq 3 ) then
            fn:concat("000000" , $id)
        else if ( $idLen eq 4 ) then
            fn:concat("00000" , $id)
        else if ( $idLen eq 5 ) then
            fn:concat("0000" , $id)
        else if ( $idLen eq 6 ) then
            fn:concat("000" , $id)
        else if ( $idLen eq 7 ) then
            fn:concat("00" , $id)
        else if ( $idLen eq 8 ) then
            fn:concat("0" , $id)
        else 
            $id
    return $paddedID
    
};

(: this links to 7xx works that have lccn's (identifier with source DLC)
using cts, not triples :)




(:
: bfraw is a whole package (work+instances, starting at rdf:RDF
: this is for merging a new record's instance onto another work, so you can't include work stubs 
: also exclude photos??
:
:)

declare function b2mload:get-work($bfraw, $workDBURI, $paddedID, $BIBURI, $mxe, $collections, $destination-uri)
{

    let $bfraw-work := $bfraw/bf:Work
    	(: only match if there's a 240/130 matchable node :)
					
	let $rdftype:=fn:string($bfraw-work/rdf:type[1]/@rdf:resource)


let $work := $bfraw-work
 (: work as converted by bib xslt conversion, rdf:RDF is top! :)

	 let $adminMeta-for-instance:= $bfraw-work/bf:adminMetadata[1]
     						
	
	let $lccn:="" (: in normal b2mload, don't change the uri to the lccn number . IBC is also for  the editor only
	this may be why items are not changing to e numbers?
	:)
	let $ibc:=""
	(: 2019-01-03: now contains get-items-new :)
    let $instances := b2mload:get-instances($bfraw,$workDBURI,$paddedID, <mxe:record/>, $adminMeta-for-instance, $lccn, $ibc)
	
	
	let $resclean:=fn:substring-after($workDBURI,"works/")
	let $resclean:=fn:replace($resclean,".xml","")
	let $rdfabout:=attribute rdf:about {fn:concat($BASE-URI, $resclean)}
	
let $_:=xdmp:log(fn:concat("$rdfabout,",$rdfabout),"info")
    let $work := 
        element {fn:name($work)} { $rdfabout,
            $work/@*[fn:not(fn:name()='rdf:about')],
           	$work/*[fn:not(self::* instance of element(bf:hasInstance))]   
			
        }
    
    let $work :=  element rdf:RDF { $work } 
            
	
	let $work-sem := bf4ts:bf4ts(  $work   )
	
	let $mxe:= 	 <mxe:empty-record/>

	
	let $work-bfindex :=  
					   try {
					       			bibframe2index:bibframe2index( $work ,$mxe )
									

					   } catch($e){
					             (<index:index/>,
								 	( 	$e, "info"),
								 	xdmp:log(fn:concat("CORB BFE/BIB indexing error  for ",fn:tokenize($destination-uri,"/")[fn:last()]), "info")
								 )
					   }
    let $work-mets := 
        <mets:mets 
            PROFILE="workRecord" 
            OBJID="{$workDBURI}" 
            xsi:schemaLocation ="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
            xmlns:mets		="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
            xmlns:rdfs  	= "http://www.w3.org/2000/01/rdf-schema#"			
			xmlns:rdf   	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:bf		= "http://id.loc.gov/ontologies/bibframe/" 
			xmlns:bflc		= "http://id.loc.gov/ontologies/bflc/" 
			xmlns:lclocal 	= "http://id.loc.gov/ontologies/lclocal/"
        	xmlns:madsrdf  	= "http://www.loc.gov/mads/rdf/v1#" 
			xmlns:relators 	= "http://id.loc.gov/vocabulary/relators/"            			
            xmlns:index="info:lc/xq-modules/lcindex">
            <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
            <mets:dmdSec ID="bibframe">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        {$work}
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
            <mets:dmdSec ID="index">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                       { $work-bfindex  	}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
            <mets:structMap>
                <mets:div TYPE="workRecord" DMDID="bibframe semtriples index"/>
            </mets:structMap>
        </mets:mets>
		
   	
    let $work-collections :=		
          		("/resources/works/","/bibframe/","/bibframe/convertedBibs/","/bibframe/notMerged/")

	let $work-collections:= if  ($bfraw-work/*[fn:not(self::* instance of element (bf:subject))]/bf:Work) then
									($work-collections,"/bibframe/had7xx/", "/bibframe/relatedTo/") (: used to find bad instances? 2018-07-26:)
								else 
									$work-collections
    
	let $work-collections:= ($work-collections,$collections)
    let $quality :=()

    let $forests:=()
	let $insert-work := 
		 if (fn:doc-available($destination-uri)  and xdmp:document-get-collections($destination-uri)="/bibframe/editor/")  then
				xdmp:log(fn:concat("BIB load: skipping loading work doc - edited  : ",$workDBURI, " from bib doc : ",$BIBURI )   , "info")
			else
       
		 (
		 	try {
			(	
					xdmp:lock-for-update($destination-uri),
					xdmp:document-insert(
                						 $destination-uri, (: not $workdburi:)
                 						 $work-mets,
						                (
						                    xdmp:permission("id-user-role", "read"), 
						                    xdmp:permission("id-admin-role", "update"),
						                    xdmp:permission("id-admin-role", "insert")
						                ),
						        		$work-collections, $quality, $forests
						            )		
				)         
        }
             catch ($e) { xdmp:log(fn:concat("BIB load: work not loaded error on : ", $workDBURI, "; $paddedID for instances merged= ",$paddedID,". ","destination:",fn:tokenize($destination-uri,"/")[fn:last()],  fn:string( $e/mlerror:code))    , "info")
        }
        , if (fn:contains($workDBURI,$BIBURI)) then 				
				xdmp:log(fn:concat("BIB load: loaded bib work doc : ",$workDBURI, " from bib doc : ",$BIBURI," to : ",$destination-uri )   , "info")
			else			
				xdmp:log(fn:concat("BIB load: merged onto work doc : ",$workDBURI, " from bib doc : ",$BIBURI )  , "info")
        )

	
    let $instance-collections := ($BASE_COLLECTIONS,"/resources/instances/","/bibframe/","/bibframe/convertedBibs/", "/lscoll/lcdb/instances/")     
	let $instance-collections:= 
									($instance-collections,("/bibframe/notMerged/"))

	let $instance-collections:=($instance-collections, $collections)
  (: this generates 58 hasitem links! http://localhost/resources/instances/c0112880890003 :)
    (: :???? nate continue here ??? :)
	let $insert-instances :=
        for $i in $instances (: instances are mets:mets nodes:)
			
			let $bibid := fn:tokenize( xs:string($i/@OBJID), "/")[fn:last()]
						
			let $destination-root := "/resources/instances/"
		    
		    let $destination-uri := xs:string($i/@OBJID)  

	        return
	          if (fn:doc-available($destination-uri)  and xdmp:document-get-collections($destination-uri)="/bibframe/editor/" ) then				
					xdmp:log(fn:concat("BIB load: skipping loading instance doc - edited : ", $bibid, " from bib doc : ",$BIBURI , " to : ",fn:tokenize($destination-uri,"/")[fn:last()]  )   , "info")
			else
				
				try{	(xdmp:lock-for-update($destination-uri),
				 		xdmp:document-insert(
	         				   $destination-uri ,
	            				$i,
					            (
					                xdmp:permission("id-user-role", "read"), 
					                xdmp:permission("id-admin-role", "update"),
					                xdmp:permission("id-admin-role", "insert")
					            ),
								$instance-collections, $quality, $forests			
	        				)
							,
							xdmp:log(fn:concat("BIB load: loaded instance doc : ", $bibid , " from bib doc : ",$BIBURI , " to : ",fn:tokenize($destination-uri,"/")[fn:last()]  )   , "info")
						)
					}
				catch ($e) {xdmp:log(fn:concat("BIB load: failed to load instance doc : ", $bibid, " from bib doc : ",$BIBURI , " to : "
				 				,fn:tokenize($destination-uri,"/")[fn:last()] )   , "info")
				 }				
    
	return 
        (   $workDBURI    )
    
};

 (: every subject/work may be a resource; go link to it... not started!!!! :)
 declare function b2mload:link-subject-works($subjects) {
()
 };
(: return instance mets docs for each bf:Instance in $bfraw:)

declare function b2mload:get-instances(
        $bfraw as element(rdf:RDF), 
        $workDBURI as xs:string, 
        $paddedID as xs:string,
		$mxe as element(),
		$adminMeta as element()?	,
		$lccn	,
		$ibc
    )
{
(: INSTANCES 
if workdburi and paddedID are null then the payload did not include a work, and instanceOf is already correct
adminmeta will be null bf:adminMetadata/
:)    
(:
if paddedid (work node) is not the same as lccn, maybe use lccn for the instance paddedid. 
if ibc=yes, then the intent is to update this instance with the lccn, so use it.
if ibc is no, leave it all
:)
	let $workuri-4-instance:=  
			if ($workDBURI!="") then								
				 fn:concat("http://id.loc.gov", fn:replace($workDBURI, ".xml", ""))
				
			else ()	

let $_:=xdmp:log(fn:concat("BIB load: workdburi for ", $workuri-4-instance," ", $ibc), "info")									


	let $adminMeta:=if ($adminMeta/*) then $adminMeta else ()

    (: Go through instances, create new id, create mets :)    
    let $instances := 
		(: some instances are in parts of a different work , skip :)
		(: this is way too inclusive: rdf/work/hasinstance/instance or rdf/instance only? :)
	
		for $i at $pos in $bfraw/self::rdf:RDF/bf:Instance | 
						  $bfraw/self::rdf:RDF/child::bf:Work[1]/bf:hasInstance/bf:Instance									 
			return 
				if ($i/parent::* instance of element(bf:hasSeries) ) then
					()
				else
					let $paddedID:= if ($paddedID="") then 
									fn:tokenize(fn:string($i/@rdf:about),"/")[fn:last()]
								else
									$paddedID
				
			    let $iID:=b2mload:get-padded-subnode($pos, $paddedID)
	       
		        let $instanceDBURI := fn:concat("/resources/instances/", $iID, ".xml" )
			    
		        let $instanceURI := fn:concat("http://id.loc.gov/resources/instances/", $iID)

	  	        let $instanceOf := 
						if  ($i/bf:instanceOf) then 
							if ($i/bf:instanceOf/bf:Work/@rdf:about) then
								element bf:instanceOf {
									attribute rdf:resource {
										fn:string($i/bf:instanceOf/bf:Work/@rdf:about) }
									}
							else if ($i/bf:instanceOf/child::*[1][fn:not(self::* instance of element(bf:Work))]/@rdf:about) then
								element bf:instanceOf {
									attribute rdf:resource {
										fn:string($i/bf:instanceOf/child::*[1]/@rdf:about) }
									}
							else if (fn:contains(fn:string($i/bf:instanceOf/@rdf:resource),"#Work")) then
								element bf:instanceOf {
						            attribute rdf:resource { $workuri-4-instance }
						        }
							else								 
								$i/bf:instanceOf
						else if ($workuri-4-instance) then
							        element bf:instanceOf {
							            attribute rdf:resource { $workuri-4-instance }
							        }
							else 
							()						
(:$i/bf:instanceOf may be a blank node work that needs to be replaced by the workuri-4-instance, see lccn 2018377860:)
let $instanceOf:=if ($instanceOf/@rdf:resource)  then
						$instanceOf
				else
						element bf:instanceOf {
						          attribute rdf:resource { $workuri-4-instance }
						  }

 
				let $itemURI := fn:concat("http://id.loc.gov/resources/items/", $iID)
		        (:

					for each hasItem, the number is relative to the Work!!!
					
					2019: since the items are now instanceid-[offset], I am also stopping putting on hasItems; 
							links go up to instance, not down from instance!

				:) 
				(: only items with abouts ie not 010066190 :)
				
	       		(: build mets for each item, calls insert-any mets to store :)
				
				let $items := b2mload:get-items-new($i,$workDBURI,  $paddedID,$pos )		
				
				(: suppress adminmeta if there already is one (from editor, for example :)
				
				let $instance-modified := 
	            	element bf:Instance {
	                	attribute rdf:about {$instanceURI},
	                
						$i/*[fn:local-name() ne "instanceOf" and fn:local-name()!="hasItem"],					
		                	$instanceOf,						
						if ($i/bf:adminMetadata) then 
							()
						 else
							$adminMeta
	           	 }
				 (: consider "insert-any-mets" here :)
				 
				let $instance-sem :=  
							try {
								bf4ts:bf4ts( element rdf:RDF { $instance-modified } )
							  }
							  catch($e){
			  							( 	<sem:triples/>,$e,
							 			xdmp:log(fn:concat("CORB BFE/BIB sem error  for ", $instanceURI), "info")									
							 		)
							  }
		        let $instance-index :=
				 	try {
	     				bibframe2index:bibframe2index( element rdf:RDF { $instance-modified }, $mxe )
					   } catch($e){
					             ( 	<index:index/>,
								 	xdmp:log(fn:concat("CORB BFE/BIB indexing error  for ", $instanceURI), "info")
								 )
					   }
		
		        let $instance-mets := 
	           	 <mets:mets 
	                PROFILE="instanceRecord" 
	                OBJID="{$instanceDBURI}" 
	                xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
	                xmlns:mets	="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
	                xmlns:rdf	="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
					xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"						
					xmlns:bf	= "http://id.loc.gov/ontologies/bibframe/" 
					xmlns:bflc	= "http://id.loc.gov/ontologies/bflc/" 
					xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"
	                xmlns:madsrdf= "http://www.loc.gov/mads/rdf/v1#" 
	                xmlns:xsi	= "http://www.w3.org/2001/XMLSchema-instance" 					
	                xmlns:index = "info:lc/xq-modules/lcindex" >
	                <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
	                <mets:dmdSec ID="bibframe">
	                    <mets:mdWrap MDTYPE="OTHER">
	                        <mets:xmlData>
	                            <rdf:RDF>
	                                {$instance-modified}
	                            </rdf:RDF>
	                        </mets:xmlData>
	                    </mets:mdWrap>
	                </mets:dmdSec>
					<mets:dmdSec ID="semtriples">
	                    <mets:mdWrap MDTYPE="OTHER">
	                        <mets:xmlData>
	                                    { $instance-sem}
	                        </mets:xmlData>
	                    </mets:mdWrap>
	                </mets:dmdSec>
	                <mets:dmdSec ID="index"><mets:mdWrap MDTYPE="OTHER">
	                        <mets:xmlData>{$instance-index}</mets:xmlData>
	                    </mets:mdWrap>
	                </mets:dmdSec>
	                <mets:structMap>
	                    <mets:div TYPE="instanceRecord" DMDID="bibframe semtriples index"/>
	                </mets:structMap>
	            </mets:mets>
            
        	return $instance-mets (:to $instances:)
            
    return $instances
    
};
(: only bfraw and padded id are used
: this version looked top down for items; new one looks only for embedded items in instances
:)
declare function b2mload:get-items-new(
        $instance as element(bf:Instance), 
        $workDBURI as xs:string, 		
        $paddedID as xs:string,
		$instance-pos	
    )
{
      
    (: Go through items, create new id, create mets
	each instance may have one or more items.
	items get id's relative to position in the whole doc
	 :)    
       (: nate continue here on renaming items with elccn number:)
	let $_:=xdmp:log(fn:concat("get-items new:", $paddedID, "|", $workDBURI),"info")

let $item-collections := ($BASE_COLLECTIONS, "/resources/items/"  , "/bibframe/","/bibframe/convertedBibs/",  "/lscoll/lcdb/items/")      
	
let $items :=       	  	
	  		for $item  at $item-pos in $instance//bf:hasItem/bf:Item[@rdf:about or @rdf:nodeID] (: for each item  :)
				let $this-item-about:=($item/@rdf:about||$item/@rdf:nodeID)[1]
		
				(: get the item position relative to the RDF:RDF, not the instance :)
				
				 					   
		                	(:let $iID:=b2mload:get-padded-subnode($my-pos[1], $paddedID):)
		                	
							let $instanceID:=b2mload:get-padded-subnode($instance-pos, $paddedID)
                			let $iID:=fn:concat($instanceID,"-",$item-pos)
			                
							let $itemDBURI := fn:concat("/resources/items/", $iID, ".xml" )
			                let $itemURI := fn:concat("http://id.loc.gov/resources/items/", $iID)
							
							let $resclean := fn:substring($iID,1,10)			
							let $dirtox := b2mload:chars-001($resclean)
							let $destination-root := "/resources/items/"
		    				
		    				let $item-destination-uri := $itemDBURI
							
			          	
							let $derivedbib:= fn:replace($paddedID,"^c","")
			          		let $derivedbib:= fn:replace($derivedbib,"^0+","")
			          		 let $itemOf := 
			          	        element bflc:itemOf {          		           
			          				    attribute rdf:resource { fn:concat("http://id.loc.gov/resources/instances/", $instanceID ) }
			                  }
					
		             let $item-modified := 
		                 element bf:Item {
		                     attribute rdf:about {$itemURI},				
		                     $item/*[fn:local-name() ne "itemOf" and fn:local-name() ne "derivedFrom" ],
		     				element bflc:derivedFrom {attribute rdf:resource {fn:concat("http://id.loc.gov/resources/bibs/",$derivedbib)} },			
		                        $itemOf		            
					     }
					
					return b2mload:insert-any-mets(element rdf:RDF { $item-modified } ,$itemDBURI, $item-destination-uri, $item-collections , "itemRecord")

    return $items
    
};

(:
 needs  rdf (work, instance, Item) objectId, file path, collections

:)

declare function b2mload:insert-any-mets($rdf as element (rdf:RDF) ,$objectID,$filepath, $collections , $metsprofile){

let $node-name:=fn:name($rdf/*[1])
let $node:=$rdf/*[1]
let $node-name:=fn:name($node)
	
	let $bfindex :=
	   try {
	       			bibframe2index:bibframe2index($rdf, <mxe:empty-record/> )
	   } catch($e){
	             ( 	<index:index/>, 
				 	xdmp:log(fn:concat("BIB load: indexing error  for ", $objectID), "info")
				 )
	   }
	let $sem :=  try {
			   			 bf4ts:bf4ts( $rdf )
						 
					 
					 } catch($e){(<sem:triples/>,					 
					     		xdmp:log(fn:concat("BIB load:  conversion error for ", $objectID), "info")
)
					 }
    let $mets := 
        <mets:mets 
            PROFILE="{$metsprofile}" 
            OBJID="{$objectID}" 
            xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
            xmlns:mets		="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
            xmlns:rdfs  	= "http://www.w3.org/2000/01/rdf-schema#"			
			xmlns:rdf   	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:bf		="http://id.loc.gov/ontologies/bibframe/" 
			xmlns:bflc		="http://id.loc.gov/ontologies/bflc/" 
			xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"
        	xmlns:madsrdf	="http://www.loc.gov/mads/rdf/v1#" 
			xmlns:relators  = "http://id.loc.gov/vocabulary/relators/"            
            xmlns:index		="info:lc/xq-modules/lcindex"			
			xmlns:mxe		= "http://www.loc.gov/mxe"	            	        
			xmlns:skos		= "http://www.w3.org/2004/02/skos/core#"	            	        
	        xmlns:ri		= "http://id.loc.gov/ontologies/RecordInfo#"	        							
			xmlns:sem		= "http://marklogic.com/semantics">
            <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
            <mets:dmdSec ID="bibframe">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        <rdf:RDF> {$node }</rdf:RDF>
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>						
            <mets:dmdSec ID="index">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                     { $bfindex }
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
			<mets:dmdSec ID="semtriples">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                         { $sem }
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
            <mets:structMap>
                <mets:div TYPE="{$metsprofile}" DMDID="bibframe index semtriples"/>
            </mets:structMap>
        </mets:mets>
 let $quality :=()
 let $forests	:=()	
   	  
 let $insert-node := 
         (try {(xdmp:lock-for-update($filepath),
		 		xdmp:document-insert(
			           			 $filepath, 
				                $mets,
				                (
				                    xdmp:permission("id-user-role", "read"), 
				                    xdmp:permission("id-admin-role", "update"),
				                    xdmp:permission("id-admin-role", "insert")
				                ),
				        		$collections, $quality, $forests
            				)
				)		         
        }
             catch ($e) { xdmp:log(fn:concat("BIB load : not loaded error on : ", $objectID,  fn:string( $e/mlerror:message))    , "error")
        }
        ,
			xdmp:log(fn:concat("BIB load: loaded doc : ",$objectID, " to ",  fn:tokenize($filepath,"/")[fn:last()])   , "info")			
        )
	
    
	return 
        (         
            $objectID          
        )
    
};

