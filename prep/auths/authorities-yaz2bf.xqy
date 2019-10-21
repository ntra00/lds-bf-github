xquery version "1.0-ml";
(: expects a yaz converted rdf payload of work/etc :)
module namespace yaz2bf = "http://loc.gov/ndmso/authorities-yaz-2-bibframe";

import module namespace auth2bf = "http://loc.gov/ndmso/authorities-2-bibframe"   at "authorities2bf.xqy";

import module namespace bibs2mets 		  = "http://loc.gov/ndmso/bibs-2-mets" 	at 	"modules/module.bibs2mets.xqy";

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
    let $auth2bfBase:="/admin/bfi/auths/auth2bibframe2/"
	let $the-doc := map:get($content, "value")
	let $orig-uri := map:get($content, "uri")  
	return if ($the-doc/rdf:RDF/bf:Work or  $the-doc/rdf:RDF/bf:Instance or $the-doc/rdf:RDF/bf:Item                )						
						then


	let $lccn:= fn:normalize-space(fn:tokenize($orig-uri,"/")[fn:last()])
	let $lccn:=fn:replace($lccn,".rdf","")
	let $new-uri:=fn:concat("loc.natlib.works.",fn:replace($lccn,".rdf",""))
	       (: dailies may not be nametitle or title records; also may have the 985 tag : skip them:)
	
	(: pilot and deprecated are testable? :)
let $already-in-pilot:=()
let $deprecated:= if ($the-doc/rdf:RDF/bf:Work[1]/bf:adminMetadata[1]/bf:AdminMetadata/bf:status/bf:Status[fn:string(bf:code)="d"] or
						fn:not($the-doc/rdf:RDF/bf:Work[1]/bf:adminMetadata[1]/bf:AdminMetadata/bf:status/bf:Status)) then
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
        let $destination-collections := ($destination-root, "/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/",
				"/bibframe/nametitle-work/","/bibframe-process/yazbfworks/", "/resources/works/",		
				"/bibframe-process/reloads/2018-12-14/","/bibframe/hubworks/")
    (:-------------------------from ingest-voyager-bib  -------------------------:)

	let $AUTHURI:= $resclean
	
	let $paddedID := $AUTHURI

return
		(:,
			xdmp:log(fn:concat("CORB auth : auth2bibframe document deprecated : ", $resclean), "info")
		:)
		
	if ($deprecated and doc-available($destination-uri)) then
		(		
		xdmp:document-remove-collections($destination-uri,"/catalog/")
		,
			xdmp:log(fn:concat("CORB auth : auth2bibframe document deprecated (removed from /catalog/): ", $resclean), "info")
		)
		
	else 
    
   let $doc-exists:=fn:doc-available($new-uri) 
    
	return	if (($doc-exists and   fn:not(fn:doc($new-uri)//bflc:consolidates) and   fn:not(fn:doc($new-uri)//lclocal:consolidates) ) 
	       or fn:not($doc-exists) )  then
	     	

        let $metsHdr:= <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
        
        let $params:=map:map()
    	let $put:=map:put($params, "baseuri", "http://id.loc.gov/resources/works/")
    	let $put:=map:put($params, "idfield", "001")
  (: the-doc is rdf, not mets, so we need to add the expected idx stuff, staring wtih memberofURI :)
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
      	
    	let $bfwork:=   $the-doc        
    		
 
    	return
    		if ($bfwork/rdf:RDF) then
			 			(: ok to store :)
				let $new-doc:=
					 auth2bf:link-and-make-mets($bfwork, $orig-uri, $new-uri, $lccn, $AUTHURI,  $destination-uri, $madsrdf-idx) 
				

				let $colls:=map:get($context,"collections")

				let $haslinks:=if ($new-doc[2]) then
										map:put($context,"collections",($colls,$new-doc[2]))							
					 				else 
										map:put($context,"collections",($colls,$destination-collections))
												
					(: ================== this is the load step ==================:)
				return
						 try {
            				(
            			 		(  						
            					  map:put($content, "uri", $destination-uri  ),					
              					  map:put($content,"value", $new-doc[1]  	), 
            					  $content,
								  $context
            					),
            					xdmp:log( fn:concat("CORB auth : ",$orig-uri," loaded as ", $new-uri," at ", $destination-uri),"info")
            				)
             			} catch($e) {
             						($e, 
									xdmp:log( fn:concat("CORB auth : ", $orig-uri," not loaded as ", $new-uri),"info") 
									)
             			}	
             		(: ================== this is the load step ==================:)
    				    		
    	   else xdmp:log( fn:concat("CORB auth : ",$orig-uri," skipped on load: BFWork already there, consolidated"),"info")
    
    else 	(: not a frbr expression/work ie name title :)
            xdmp:log( fn:concat("CORB auth : ",$orig-uri," skipped on  load: Not a BFWork or has 985"),"info")
else
 ()
 
         
         };