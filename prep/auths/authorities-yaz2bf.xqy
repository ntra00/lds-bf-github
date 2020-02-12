xquery version "1.0-ml";
(: expects a yaz converted rdf payload of work/etc :)
module namespace yaz2bf = "http://loc.gov/ndmso/authorities-yaz-2-bibframe";

import module namespace auth2bf = "http://loc.gov/ndmso/authorities-2-bibframe"   at "authorities2bf.xqy";


declare namespace 	rdf					= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace	rdfs   			    = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace 	madsrdf      		 = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mets       		 	= "http://www.loc.gov/METS/";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   mxe					= "http://www.loc.gov/mxe";
declare namespace 	bf					= "http://id.loc.gov/ontologies/bibframe/";
declare namespace	bflc				= "http://id.loc.gov/ontologies/bflc/";
declare namespace 	idx 				= "info:lc/xq-modules/lcindex";
declare namespace				lclocal				="http://id.loc.gov/ontologies/lclocal/";

declare variable $BASE-URI  as xs:string:="http://id.loc.gov/resources/works/";
(: 
	load a nametitle or title madsrdf doc (in mets wrapper) from id-main, rename the uri and OBJID from /authorities/names/n*.xml to /resources/works/lw*.xml
	also... add to collections?
this is run by load_names_daily, port 8203, relative to  /marklogic/id/natlibcat/ 
	need to reindex, new sem !!

 :)
 
declare function yaz2bf:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{

    let $auth2bfBase:="/prep/auths/auth2bibframe2/"
	let $set := map:get($content, "value")
	let $orig-uri := map:get($content, "uri")  
let $_:=xdmp:log(fn:concat("CORB auth yaz load starting: " ,$orig-uri) ,"info")

	return 
	for $the-doc in $set/rdf:RDF/rdf:Description/bf:Work| $set/rdf:RDF/bf:Work| $set/rdf:RDF/rdf:Description/lclocal:graph/bf:Work
let $_:=xdmp:log(fn:concat("CORB auth yaz load into $set: " ,fn:string($the-doc/@rdf:about) ) ,"info")
	(:let $lccn:= fn:normalize-space(fn:tokenize($orig-uri,"/")[fn:last()]):)
	let $lccn:=$the-doc/bf:identifiedBy/bf:Lccn[fn:not(bf:status) or fn:not(fn:string(bf:status/bf:Status/@rdf:about="http://id.loc.gov/vocabulary/mstatus/cancinv")) ]/rdf:value
	
	let $lccn:=fn:replace(fn:string($lccn)," ","")
return if (fn:not( $the-doc//bf:title/bf:Title) ) then
	xdmp:log( fn:concat("CORB auth : ",$lccn," skipped on  load: Not a BFWork"),"info")
else	

	let $new-uri:=fn:concat("loc.natlib.works.",$lccn)
	       (: dailies may not be nametitle or title records; also may have the 985 tag : skip them:)
	
	(: pilot and deprecated are testable? :)
	
let $already-in-pilot:=()
let $deprecated:= if ( (exists($the-doc/bf:adminMetadata[1]/bf:AdminMetadata/bf:status/bf:Status[fn:string(bf:code)="d"]  )) or
						fn:not($the-doc/bf:adminMetadata[1]/bf:AdminMetadata/bf:status/bf:Status)) then
							fn:true()
					else  fn:false()

    (:-------------------------from ingest-voyager-bib  -------------------------:)
    	let $recstatus := ()
    	let $resclean := fn:replace($lccn," ", "")
    	let $dirtox := auth2bf:chars-001($resclean)
    	let $dest := "/lscoll/lcdb/works/"
        let $destination-root := $dest
        let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
        let $destination-uri := fn:concat($dir, $resclean, '.xml')
        let $destination-collections := ($destination-root, "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/",
				"/bibframe/nametitle-work/","/bibframe-process/yazbfworks/", "/resources/works/",		
				"/bibframe-process/reloads/2018-12-14/","/bibframe/hubworks/")
    (:-------------------------from ingest-voyager-bib  -------------------------:)

	let $AUTHURI:= $resclean
	
	let $paddedID := $AUTHURI

return
		
	if ($deprecated and doc-available($destination-uri)) then
		(		
		xdmp:document-remove-collections($destination-uri,"/catalog/")
		,
			xdmp:log(fn:concat("CORB auth : document deprecated (removed from /catalog/): ", $destination-uri,"|",$resclean), "info")
		)
		
	else 
    
   let $doc-exists:=fn:doc-available($new-uri) 
    
	return	
		if (($doc-exists and   fn:not(fn:doc($new-uri)//bflc:consolidates) and   fn:not(fn:doc($new-uri)//lclocal:consolidates) ) 
	       or fn:not($doc-exists) )  then
	     	

        let $metsfHdr:= <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
        
        let $params:=map:map()
    	let $put:=map:put($params, "baseuri", "http://id.loc.gov/resources/works/")
    	let $put:=map:put($params, "idfield", "001")
  (: the-doc is rdf, not mets, so we need to add the expected idx stuff, starting with memberofURI :)
		let $expr:=
			for $t in $the-doc//bf:title/bf:Title/bflc:title00MarcKey|$the-doc//bf:title/bf:Title/bflc:title10MarcKey|$the-doc//bf:title/bf:Title/bflc:title11MarcKey
			return
		 		if ( fn:matches(fn:string($t),"\$l|\$o") ) then
			 		<idx:memberOfURI>http://id.loc.gov/authorities/names/collection_FRBRExpression</idx:memberOfURI>
				else
					()	

		let $madsrdf-idx:=<mets:mets><mets:dmdSec id="index"><mets:mdWrap><mets:xmlData>
		  {if ($the-doc//bflc:title30MatchKey) then
		  	 	 (<idx:memberOfURI>http://id.loc.gov/authorities/names/collection_NamesAuthorizedHeadings</idx:memberOfURI>,
				 <idx:memberOfURI>http://id.loc.gov/authorities/names/collection_LCNAF</idx:memberOfURI>,
				 <idx:rdftype>Title</idx:rdftype>,
				 <idx:rdftype>SimpleType</idx:rdftype>,
				 <idx:rdftype>Authority</idx:rdftype>
				 )
	 
			 else
			 (<idx:memberOfURI>http://id.loc.gov/authorities/names/collection_NamesAuthorizedHeadings</idx:memberOfURI>,
			  <idx:memberOfURI>http://id.loc.gov/authorities/names/collection_LCNAF</idx:memberOfURI>,			 
			 <idx:rdftype>Authority</idx:rdftype>,
			 <idx:rdftype>ComplexType</idx:rdftype>,
			 <idx:rdftype>NameTitle</idx:rdftype>
		  	 ),if ($expr) then $expr[1] 
			 else
			  <idx:memberOfURI>http://id.loc.gov/authorities/names/collection_FRBRWork</idx:memberOfURI>
			 }
		  </mets:xmlData></mets:mdWrap></mets:dmdSec></mets:mets>  
      	
    	let $bfwork:=(: set the node forlink-and-make-mets:)
		 <rdf:RDF 
					xmlns:xlink		= "http://www.w3.org/1999/xlink"  
				xmlns:idx 		= "info:lc/xq-modules/lcindex"							
				xmlns:index		= "info:lc/xq-modules/lcindex"
	        	xmlns:marcxml	= "http://www.loc.gov/MARC21/slim" 
	        	xmlns:mets		= "http://www.loc.gov/METS/" 
    			xmlns:mxe		= "http://www.loc.gov/mxe"
    	        xmlns:rdf		= "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    			xmlns:bf		= "http://id.loc.gov/ontologies/bibframe/"
    			xmlns:bflc		= "http://id.loc.gov/ontologies/bflc/"
    			xmlns:rdfs		= "http://www.w3.org/2000/01/rdf-schema#"
    			xmlns:skos		= "http://www.w3.org/2004/02/skos/core#"
    	        xmlns:madsrdf	= "http://www.loc.gov/mads/rdf/v1#"
    	        xmlns:ri		= "http://id.loc.gov/ontologies/RecordInfo#"	        							
    			xmlns:sem		= "http://marklogic.com/semantics">
						{ $the-doc}        
					</rdf:RDF>
    		
 
    	return 
    		
				let $new-doc:=
					 auth2bf:link-and-make-mets($bfwork, $orig-uri, $new-uri, $lccn, $AUTHURI,  $destination-uri, $madsrdf-idx) 
				

				let $colls:=map:get($context,"collections")

				
				let $collections:=if ($new-doc[2]) then
										($colls,$new-doc[2])							
					 				else 
										($colls,$destination-collections)									



					(: ================== this is the old load step ==================:)

				(:let $haslinks:=if ($new-doc[2]) then
										map:put($context,"collections",($colls,$new-doc[2]))							
					 				else 
										map:put($context,"collections",($colls,$destination-collections))
					

				return
						 try {
            				(
            			 		(  						
            					  map:put($content, "uri", $destination-uri  ),					
              					  map:put($content,"value", $new-doc[1]  	), 
            					  $content,
								  $context
            					),
            					xdmp:log( fn:concat("CORB auth : ",$lccn," loaded as ", $new-uri," at ", $destination-uri),"info")
				
            				)
             			} catch($e) {
             						($e, 
									xdmp:log( fn:concat("CORB auth : ", $lccn," not loaded as ", $new-uri),"info") 
									)
             			}	
						:)
             		(: ================== this is the load step ==================:)
    				    		
			(: from bibrecs: explicit load: :)
			return 
         			(try {
							(xdmp:lock-for-update($destination-uri),
					 			xdmp:document-insert(
						           			 $destination-uri, 
							                $new-doc[1]  ,
							                (
							                    xdmp:permission("id-user-role", "read"), 
							                    xdmp:permission("id-admin-role", "update"),
							                    xdmp:permission("id-admin-role", "insert")
							                ),
							        		$collections
			            				)
										, xdmp:log( fn:concat("CORB auth : ",$lccn," loaded as ", $new-uri," at ", $destination-uri),"info")
							)		         
			        }
			             catch ($e) {xdmp:log( fn:concat("CORB auth : ", $lccn," not loaded as ", $new-uri),"info") 
			        }
					)
			      (:  ,
						xdmp:log(fn:concat("CORB BFE/BIB editor load: loaded doc : ",$objectID, " to ",  fn:tokenize($filepath,"/")[fn:last()])   , "info")			
			        )    	   :)

    
    else 	(: not a frbr expression/work ie name title :)
            xdmp:log( fn:concat("CORB auth : ",$orig-uri," skipped on  load: Not a BFWork or has 985"),"info")

          
         };(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)