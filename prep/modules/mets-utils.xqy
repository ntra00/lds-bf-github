xquery version "1.0-ml";

(: 
module for utility functions like mets and get and to render as html, json, atom
utils:mets(): get a full document
utils:get():   get a mets doc or any subset element
utils:hold($id) gets all holdings record based on the 004, bibid
utils:render() format any xml (from get() as html, json, atom, div....)
:)

module namespace utils = "info:lc/xq-modules/mets-utils";
import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";

import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";

import module namespace mem = "http://xqdev.com/in-mem-update" at "/xq/modules/in-mem-update.xqy";
import module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight" at "/lds/lib/l-highlight.xqy";
import module namespace xml2jsonml = "info:lc/id-modules/xml2jsonml#" at "/xq/modules/module.XML-2-JSONML.xqy";
import module namespace rdfxml2trix = "http://3windmills.com/rdfxq/modules/rdfxml2trix#" at "/xq/rdfxq/modules/module.RDFXML-2-TriX.xqy";
import module namespace rdfxml2json = "info:lc/id-modules/rdfxml2json#" at "/xq/modules/module.RDFXML-2-JSON.xqy";
import module namespace trix2jsonld-ml = "http://3windmills.com/rdfxq/modules/trix2jsonld-ml#" at "/xq/rdfxq/modules/module.TriX-2-JSONLD-MarkLogic.xqy";


declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace rights = "http://www.loc.gov/rights/";
declare namespace mxe="http://www.loc.gov/mxe";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace marc="http://www.loc.gov/MARC21/slim";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace ctry="info:lc/xmlns/codelist-v1";
declare namespace hld = "http://www.indexdata.com/turbomarc";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace l= "local";

declare variable $RDF-FORMATS as xs:string:="" ;
declare function utils:mets($id as xs:string) {
       
    (:  requires id parameter (METS/@OBJID as in "loc.natlib.works.5226")
   
    :)		
	let $mets:=
		    try {
		        cts:search(collection($cfg:DEFAULT-COLLECTION)/mets:mets, cts:element-attribute-value-query(xs:QName("mets:mets"), xs:QName("OBJID"), $id))[1]
		    } catch($e) {
		        ($e, xdmp:log(xdmp:quote($e)), ())
		    }
	return if (exists($mets) ) then	           
	            $mets
			else
				xdmp:set-response-code(404,"Item Not found")

};
(: from id-main, get the bibframe rdf dmdsec . if no ser specified, return rdfxml :)
declare function utils:rdf($uri as xs:string) {
	let $ser:="rdfxml"
	return 
		utils:rdf-ser($uri ,$ser)
	
};
(: serialize bf rdf as ser :)
declare function utils:rdf-ser($uri as xs:string, $ser as xs:string) {
	(: convert bibframe rdf is in a dmdsec :)
	let $mets:=document{utils:mets($uri)}
	let $mime:= if ($ser="n3") 			then "text/n3"
				else if ($ser="rdfxml") then "application/rdf+xml; charset=utf-8"
				else if ($ser="nt")		then "application/n-triples"
				else if ($ser="json")		then "application/json"
         		else if ($ser="ttl") 	then "text/turtle"
				else "text/plain"
   
   let $serialize:=if (fn:matches($ser,"(n3|ntriples|nt|rdf|json|rdfjson|nquad|ttl)" )) then
                       if ($ser="rdfxml") then "rdfxml"
                     	 else if ($ser="json") then "rdfjson"
						 else if ($ser="rdfjson") then "rdfjson"
                      	 else if ($ser="ttl") then "turtle"
                         else $ser
                   else "rdfxml"
   
   let $bfrdf:=$mets/mets:mets/mets:dmdSec[@ID="bibframe"]/mets:mdWrap/mets:xmlData/rdf:RDF	
   (:let $_:=        xdmp:log( sem:rdf-serialize(sem:rdf-parse($bfrdf/node(),"rdfxml"),$serialize),"info"):)
   let $resp:= if ($serialize="rdfxml" )then 
   						$bfrdf
   				else try{
							sem:rdf-serialize(sem:rdf-parse($bfrdf/node(),"rdfxml"),$serialize)
						}
					 catch($e) { ( (),
					 	xdmp:log(fn:concat("DISPLAY: RDF conversion error for ",$uri),"info")					 	
					 	)
					 }
   	return 
		if (not(empty($bfrdf) )) then		 		
			(
			        xdmp:set-response-content-type($mime), 		            
					xdmp:add-response-header("Access-Control-Allow-Origin", "*") ,
					$resp
					)
		else
			xdmp:set-response-code(404,"Item Not found")

};

     



(: NOT from id-main, get the bibframe rdf dmdsec,  convert to nt :)
declare function utils:nt($uri as xs:string) {
	(: convert bibframe rdf is in a dmdsec :)
	(:let $mets:=document{utils:mets($uri)}:)
let $bfrdf:=utils:rdf($uri)
	return 
		if (not(empty($bfrdf) )) then						
			     (
			        xdmp:set-response-content-type("application/n-triples; charset=utf-8"),
					sem:rdf-parse($bfrdf,"ntriples")
					
				 )
		else
			xdmp:set-response-code(404,"Item Not found")
};
(: from id-main, get the bibframe rdf dmdsec,  convert to json:)

declare function utils:json($uri as xs:string, $ser as xs:string) {
	
	let $mets:=document{utils:mets($uri)}

	return 
		if (not(empty($mets) )) then
			let $bfrdf:=$mets/mets:mets/mets:dmdSec[@ID="bibframe"]/mets:mdWrap/mets:xmlData/rdf:RDF
			
			let $response:= 
					if ($ser="jsonld") then
						let $bftrix:=rdfxml2trix:rdfxml2trix($bfrdf)					
						return trix2jsonld-ml:trix2jsonld($bftrix)

					else
						try{
						xml2jsonml:xml2jsonml($bfrdf)
						}
						 catch($e) { ( (),
					 	xdmp:log(fn:concat("DISPLAY: json conversion error for ",$uri),"info")					 	
					 	)
					 }
			            
			return
			     (
			        xdmp:set-response-content-type("application/json; charset=utf-8"), 		            
					$response
				  
				)
		else
			xdmp:set-response-code(404,"Item Not found")

};
declare function utils:export-mets($uri as xs:string) {
	(: convert mxe to marcslim, remove mxe, remove IDX, convert xme to mods keep bibframe if present (madsrdf?) :)
	let $mets:=document{utils:mets($uri)}
	return 
		if (not(empty($mets) )) then		 		
			(
			        xdmp:set-response-content-type("text/xml; charset=utf-8"), 		            
					element mets:mets { 
							$mets//mets:mets/@*,
							$mets//mets:metsHdr,
							$mets//mets:dmdSec[mets:mdWrap/@MDTYPE="MODS"],
							<mets:dmdSec ID="dmd2">
						  		<mets:mdWrap MDTYPE="MARC">
								     <mets:xmlData>
								     	{element marc:record {marcutil:mxe2-to-marcslim($mets//mxe:record)/*} 			}
								     </mets:xmlData>
						   		</mets:mdWrap>				
							</mets:dmdSec>,
							$mets//mets:dmdSec[@ID="bibframe"],
							$mets//mets:amdSec,
							$mets//mets:fileSec,
							$mets//mets:structMap
							}
					)
		else
			xdmp:set-response-code(404,"Item Not found")

};

declare function utils:export-mets-new($uri as xs:string) {
(: convert mxe to marcslim, remove mxe, remove IDX, convert xme to mods:)

	
(: lcdb mets contains mxe, idx; 
* replace mxe with marcslim, 
* drop idx
* rebuild structmap:
 <mets:div TYPE="bib:bibRecord" DMDID="dmd1 IDX1"/> (replace idx1 with dmd2 (mods, marcslim)

:)

let $mets:=document{utils:mets($uri)}
(: drop these :
          let $marcslim:=xdmp:http-get("http://loccatalog.loc.gov/loc.natlib.lcdb.5885704.marcxml.xml")[2]
          let $mets:=local:marcslim-to-metsNATE($marcslim/element())
 drop these :)
	     		(: {utils:export-marcslim($mets//mxe:record)} 			:)
let $marc-dmdsec:= 
	<mets:dmdSec ID="dmd2">
		<mets:mdWrap MDTYPE="MARC">
		     <mets:xmlData>
				{marcutil:mxe2-to-marcslim($mets//mxe:record)}
			</mets:xmlData>
		</mets:mdWrap>				
	</mets:dmdSec>
					

let $mods-dmdsec:=
	<mets:dmdSec ID="dmd1">
		<mets:mdWrap MDTYPE="MODS">
	     	<mets:xmlData>
				{utils:export-mods($marc-dmdsec//marc:record)}
 			</mets:xmlData>
		</mets:mdWrap>
	</mets:dmdSec>

let $newdmdid:=attribute DMDID {"dmd1 dmd2"}

(:dmd1 is mods, dmd2 is mxe, IDX1 is idx:)

let $mets:=mem:node-replace($mets//mets:dmdSec[@ID="dmd1"],$mods-dmdsec)
let $mets:=mem:node-delete($mets//mets:dmdSec[@ID="dmd2"])
let $mets:=mem:node-replace($mets//mets:dmdSec[@ID="IDX1"],$marc-dmdsec)

let $mets:=if (matches($mets//@OBJID/string(),"lcdb")) then
              	mem:node-replace($mets//mets:structMap/mets:div/@DMDID ,$newdmdid)
		else $mets
return if (exists($mets)) then	
		(
			        xdmp:set-response-content-type("text/xml; charset=utf-8"), $mets)
					else
			xdmp:set-response-code(404,"Item Not found")

(:return 
		if (exists($mets)) then		 		
			(
			        xdmp:set-response-content-type("text/xml; charset=utf-8"), 		            
					element mets:mets { 
							$mets//mets:mets/@*,
							$mets//mets:metsHdr,
							$mods,
							$marc-dmdsec,
							$mets//mets:amdSec,
							$mets//mets:fileSec,
							if (matches($mets//@OBJID/string(),"lcdb")) then
								<mets:structMap><mets:div TYPE="bib:bibRecord" DMDID="dmd1 dmd2"/></mets:structMap>
							else					
								$mets//mets:structMap							
							}
					)
		else
			xdmp:set-response-code(404,"Item Not found")
:)
};

declare function utils:hold-bib($bibid as xs:integer, $set as xs:string)  {
(: given a bibid, get all holdings
   returns <collection><hld:r/><hld:r/></collection> or <error:error/> or ()
   $set is either erms or lcdb
:)
let $collection:=if ($set="lcdb") then "/lscoll/lcdb/holdings/" else"/lscoll/erms/holdings/"
let $holdings:=
	 try {
		cts:search(/hld:r, cts:and-query((cts:collection-query($collection), 
			cts:element-range-query(xs:QName("hld:c004"), "=", $bibid))))

	} 	catch($e) {
        	(xdmp:log(xdmp:quote($e)), ())
    }
return if ($holdings instance of element(error:error)) then
  		($holdings, xdmp:set-response-code(500, $holdings//error:message/string() ) )
  else 
  <collection  xmlns="http://www.indexdata.com/turbomarc">{$holdings}</collection>
};

declare function utils:hold-mfhd($mfhd as xs:integer)  {
(: given a mfhdid, get that record
   returns <hld:r/>or <error:error/> or ()
:)

  try {

		cts:search(/hld:r, cts:and-query((cts:collection-query("/lscoll/lcdb/holdings/"), 
			cts:element-range-query(xs:QName("hld:c001"), "=", $mfhd ))))
	} catch($e) {
        (xdmp:log(xdmp:quote($e)), ())
    }

};
declare  function utils:thumb($mets as element(), $uri as xs:string) as element() {
(: called by mets-files, requires having $mets in hand :)

		let $thumbkey := (:skips monoSecment div:) 
		  	if ($mets/mets:structMap//mets:div[mets:fptr][@LABEL = "thumb"]) then
			 	(: from database:) 
			 	$mets/mets:structMap//mets:div[mets:fptr][@LABEL = "thumb"]/mets:fptr[2]/@FILEID/string()
		    else if ($mets//mets:div[matches(@TYPE, "illustration")]/mets:div[matches(@TYPE, "image")]) then 
					(: from file system illustration/image dir :) 
					$mets//mets:div[matches(@TYPE, "illustration")]/mets:div[matches(@TYPE, "image")]/mets:fptr[2]/@FILEID/string()
		         else 
				 	(: defaults to first image ; test if this really grabs #1 (skips pm:image if found) :)
				 	$mets/mets:structMap//mets:div[matches(@TYPE, "(page|version|card)") ][not(matches(@LABEL, "target"))][1]//mets:fptr[2]/@FILEID/string()

	  let $url := $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $thumbkey]/mets:FLocat/@xlink:href/string()
	  return 
	  		<l:thumb>
				<l:caption>{$mets//idx:titleSort/string()}</l:caption>
	            <l:url>{ $url }</l:url>
		    </l:thumb>
};
declare  function utils:illustrative($mets as node(), $uri as xs:string) as xs:string? {
(: called by mets-files, requires having $mets in hand :)

		let $thumbkey :=  
		  	if ($mets/mets:structMap//mets:div[mets:fptr][@LABEL = "thumb"]) then			 	
				(:from database :)
			 	$mets/mets:structMap//mets:div[mets:fptr][@LABEL = "thumb"]/mets:fptr[2]/@FILEID/string()
		    else if ($mets//mets:div[matches(@TYPE, "illustration")]/mets:div[matches(@TYPE, "image")]) then 
					(: from file system illustration/image dir :) 
					$mets//mets:div[matches(@TYPE, "illustration")]/mets:div[matches(@TYPE, "image")]/mets:fptr[2]/@FILEID/string()
		         else 
				 	(: defaults to first image ; test if this really grabs #1 (skips pm:image if found) :)
				 	$mets/mets:structMap//mets:div[matches(@TYPE, "(page|version|card)")][not(matches(@LABEL, "target"))][1]//mets:fptr[2]/@FILEID/string()

	  return  $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $thumbkey]/mets:FLocat/@xlink:href/string()

};
declare function utils:mets-thumb( $uri as xs:string ) {
(: external call; needs only uri, :)
	let $mets := utils:mets($uri)
	let $thumbkey := (:skips monoSecment div:) 
		  	if ($mets/mets:structMap//mets:div[mets:fptr][@LABEL = "thumb"]) then
			 	(: from database:) 
			 	$mets/mets:structMap//mets:div[mets:fptr][@LABEL = "thumb"]/mets:fptr[2]/@FILEID/string()
		    else if ($mets//mets:div[matches(@TYPE, "illustration")]/mets:div[matches(@TYPE, "image")]) then 
					(: from file system illustration/image dir :) 
					$mets//mets:div[matches(@TYPE, "illustration")]/mets:div[matches(@TYPE, "image")]/mets:fptr[2]/@FILEID/string()
		         else 
				 	(: defaults to first image ; test if this really grabs #1 (skips pm:image if found) :)
				 	$mets/mets:structMap//mets:div[matches(@TYPE, ("page", "version"))][not(matches(@LABEL, "target"))][1]//mets:fptr[2]/@FILEID/string()

	  let $url := $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $thumbkey]/mets:FLocat/@xlink:href/string()	  
	  return 
	  		<l:thumb>
				<l:caption>{$mets//idx:titleSort/string()}</l:caption>
	            <l:url>{ $url }</l:url>
		    </l:thumb>
};
declare function utils:export-mods($marcslim as element(marc:record))  {
(: given the converted mxe to marcslim record, produce mods for export:)

let $trymods:=  try {                     
                      xdmp:xslt-invoke("/xslt/MARC21slim2MODS3-4.xsl",document{$marcslim})
                    } catch ($exception) {
                         $exception
                    }
return
 	if ($trymods instance of element(error) ) then 
		(
			<mods:mods xmlns:mods="http://www.loc.gov/mods/v3"/>,
		 	xdmp:log(concat("MARC21slim2MODS3-4.xsl error  at ", $marcslim//marc:controlfield[tag="001"]/string()), "error")
		 ) 
	else $trymods
};


declare function utils:mets-files($uri as xs:string, $format as xs:string, $set as xs:string) {
  (:  
  	required:
		$uri = objid parameter, 
		$format = json or xml
		$set= "all" or "thumb" (thumb  gets <thumb> node  only, all gets all but thumb)

	Example:utils:mets-files("loc.natlib.gottlieb.03361", "xml", "thumb")
 
:)
  let $mets := utils:mets($uri)
	return if ($format='json' and $mets//idx:files[@format='json']) then
		$mets//idx:files[@format='json']/string()
		else    
  let $data:= utils:mets-files-data($mets,$set,$uri)
 	

 return (if ($format="xml") then 
 			$data 
		else
 			utils:json-files($data),
		if (empty($data)) then xdmp:set-response-code(404,"Item Not found") else ()
		)
};

declare function utils:mets-files2($mets as element(mets:mets), $format as xs:string, $set as xs:string) {
  (:  test this in md:maincontent between 13 and 14??

  	required:
		$mets = mets file
		$format = json or xml
		$set= "all" or "thumb" (thumb  gets <thumb> node  only, all gets all but thumb)

	Example:utils:mets-files("loc.natlib.gottlieb.03361", "xml", "thumb")
 
:)

  (:let $mets := utils:mets($uri):)
  let $uri:=$mets/@OBJID/string()
  
  (:<mets:FLocat LOCTYPE="URL" xlink:href="/media/loc.pnp.ggbain.35613/ver01/0001.tif"/>
  /data/service/gottlieb/0000_00/0000002341:)  
  let $data:= utils:mets-files-data($mets,$set,$uri)

 return (if ($format="xml") then 
 			$data 
		else
 			utils:json-files($data),
		if (empty($data)) then xdmp:set-response-code(404,"Item Not found") else ()			
		)
};

declare function utils:mets-files-data($mets as element(), $set as xs:string, $uri as xs:string) {
    let $data:=
        if (exists($mets)) then                       
          let $imageList :=           
                if ($set = "all") then (: only list all page images if requested:)
                     (: sequence of <page> elements :)
                        utils:image-list($mets, $uri)
                else (:set= thumb only:)
                    utils:thumb($mets, $uri)
           
           let $avList:= if ($set = "all") then 
                            utils:av-list($mets)                
                         else ()
           return (:do files exist? :)
                if (exists($imageList) or exists($avList)) then
                    <l:pages xmlns:l="local">{ if (not(empty($imageList/*))) then $imageList else () }{ $avList }</l:pages> 
                else (:mets not found :)
                    <l:pages xmlns:l="local"/> 
        else (:mets doesn't exist :)
            <l:pages xmlns:l="local"/>
            
    return $data
};

declare function utils:image-list($mets as element(), $uri as xs:string) {
    let $volumes := distinct-values($mets//mets:file/@GROUPID/string())
    for $volume in $volumes
    return
        <l:volume>{
          for $page at $x in $mets//mets:div[matches(@TYPE, ("page", "version","card"))][not(matches(@LABEL, "target"))]
                 let $key := 
                    if ($page//mets:fptr[2]/@FILEID/string()) then 
                        $page//mets:fptr[2]/@FILEID/string()
                    else
                        $page//mets:fptr[1]/@FILEID/string()
                 let $masterkey := 
                    if ($page//mets:fptr[2]/@FILEID/string()) then 
                        $page//mets:fptr[1]/@FILEID/string()
                    else ""
                 return
                    (: for multi-volumes, check that the current $volume matches the structmap volume id so we
                       only process the pages for the current $volume.
                       also true if the parent of $page is not of type volume (so all non-ia objects) :)
                     if (($page[parent::*[not(matches(@TYPE,"volume"))]]) or ($page/../@ID = $volume)) then
                         let $pageurl := concat($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key and @GROUPID = $volume]/mets:FLocat/@xlink:href/string())
                         let $masterurl := 
                            if ($masterkey) then
                            $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $masterkey and @GROUPID = $volume]/mets:FLocat/@xlink:href/string()
                            else ""
                		 let $metalink := $page/@DMDID/string()
                         let $externallink := 
                		  	if ($page/@DMDID) then		                    
                                for $relateditem in $mets//mods:relatedItem[@ID = $metalink]
                                    let $link := 
                						if (contains($relateditem/mods:identifier[@type = "url"], "extent:")) then 
                								substring-before($relateditem/mods:identifier[@type = "url"], "extent:")
                                            else 
                								$relateditem/mods:identifier[@type = "url"]
                                    return
                                       if (exists($link)) then 
                					   		<l:href caption="{string-join($relateditem/mods:titleInfo/*,' ')}">{ string-join($relateditem/mods:titleInfo/*,' ') }</l:href>
                                       else ()
                            else (:no external links :)
                					()
                			
                                  (: law google hearings?? :)
                         let $ocrText := 
                			for $ocrlink in $page/mets:div[matches(@TYPE, ("text", "ocrText"))]
                                let $key := $ocrlink//mets:fptr/@FILEID/string()
                                return 
                					<l:ocrText>{ $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string() }</l:ocrText>
                         return (:$imageList, for page in mets has some content :)
                                <l:page>
                					<l:caption>{
                                        if ($mets//mods:mods[@ID = $metalink]/mods:titleInfo ) then 
                                            string-join($mets//mods:mods[@ID = $metalink]/mods:titleInfo[not(@type)]/*," ") 
                                        else if ($mets//mods:relatedItem[@ID = $metalink]/mods:titleInfo ) then 
                                            string-join($mets//mods:relatedItem[@ID = $metalink]/mods:titleInfo[not(@type)]/*," ") 
                                        else if  ($mets//mods:relatedItem[@ID = $metalink]/mods:note[@type="version"]) then
                                                $mets//mods:relatedItem[@ID = $metalink]/mods:note[@type="version"]/string() 
                                        else if (fn:contains($uri, ".ia.")) then
                                             ""
                                        else format-number($x,"0000") }
                                  </l:caption>
                    			  <l:url>{if (starts-with($pageurl,"/diglib")) then substring-after($pageurl,"/diglib") else $pageurl}</l:url>
                    			  {if ($masterkey) then
                    			     (<l:master>{$masterurl}</l:master>)
                    			  else ""}
                    			  <l:gid>{$volume}</l:gid>
                                  { $ocrText }
                                  { $externallink }
                                </l:page>
                     else ()  (: don't do anything - this is a volume mismatch and should be ignored :)
        }</l:volume>
};
declare  function utils:av-list($mets as element()) {
(: private function to transform mets into list of audio files  with titles, dates, artists
{
            url: 'http://derivative2.loc.gov:8200/media/loc.natlib.tohap.H0008/seg01/audio/0001.mp3/audio',
			provider:"http",
            artists: "Rashmi",
            date: '1915-08-05',
            title: 'Rashmi test of TOHAP mp3',
            autoPlay: false
        },
:) 
  for $audio at $x in $mets//mets:div[matches(@TYPE, ("audio"))]
		let $key := $audio//mets:fptr[2]/@FILEID/string()		             
		let $metalink := $audio/../@DMDID/string()
		(:let $pageurl := concat('http://', $cfg:DISPLAY-SUBDOMAIN, $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string(),"/audio"):)
		let $pageurl := concat( $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string(),"/audio")
		let $trackdata:=
			if (exists($metalink)) then		
				for $relateditem in $mets//mods:relatedItem[@ID = $metalink]					
			        	let $link := (: not used by jukebox player 
										  external links to related book pages or other, a la coptic :)			
							if (contains($relateditem/mods:identifier[@type = "url"], "extent:")) then 
								substring-before($relateditem/mods:identifier[@type = "url"], "extent:")
			                else if ($relateditem/mods:identifier[@type = "url"]) then
								$relateditem/mods:identifier[@type = "url"]
							else if ($relateditem/mods:location/mods:url) then
								$relateditem/mods:location/mods:url
							else ()
				        let $externallink := 
				           if (exists($link)) then 
						   		<l:href caption="{string-join($relateditem/mods:titleInfo/*,' ')}">{ string-join($relateditem/mods:titleInfo/*,' ') }</l:href>
				           else ()
					let $date:= if(exists($relateditem/mods:originInfo/*[matches(local-name(),'date')])) then
									<l:date>$relateditem/mods:originInfo/*[matches(local-name(),'date')][1]</l:date>
								else ()
								(: some tohap stuff has tibetan translations; suppress!:)
					let $artists:= if (exists($relateditem/mods:name)) then
										for $name in $relateditem/mods:name
					 						return 
												<n>{ if (contains($name/mods:namePart[1],'[tib.')) then
														substring-before(string-join($name/mods:namePart[not(@type='date')][not(@type='role')],' '),'[tib.')
													else
														string-join($name/mods:namePart[not(@type='date')][not(@type='role')],' ')
													}</n>
									else ()

					let $title:=if ($relateditem/mods:titleInfo ) then 
									string-join($relateditem/mods:titleInfo/*," ") 
			  					else if ($relateditem/mods:note[@type='caption'] ) then 
									$relateditem/mods:note[@type='caption']/string()					
								else $metalink

					return <l:track>
								<l:title>{$title}</l:title>
								{if (exists($artists) ) then <l:artists>{string-join($artists,'; ')}</l:artists> else () }
								<l:size>{$mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/@SIZE/string()}</l:size>
								{$date}
								{$externallink}
								</l:track>
			else (:no metalink:)
					()				
		
		let $ocrText :=  (:not used by jukebox player :)
			for $ocrlink in $audio/mets:div[matches(@TYPE, ("text", "ocrText"))]
		        let $key := $ocrlink//mets:fptr/@FILEID/string()
		        return 
						<l:ocrText>{ $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string() }</l:ocrText>
       
	   return (:$avList, for page in mets has some content :)
	        <l:audio>		                      
			  <l:url>{$pageurl}</l:url>
			  {$trackdata/*}
		      { $ocrText }	          
	       </l:audio>
};
declare function utils:tei-files($mets as element()) as element(l:tei) {
  <l:tei>{
         for $page at $x in $mets//mets:div[matches(@TYPE, ("text"))]
	         let $key := $page/mets:fptr/@FILEID/string()
	         let $masterkey := $page//mets:fptr[1]/@FILEID/string()
	         let $pageurl := concat("http://", $cfg:DISPLAY-SUBDOMAIN, $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string())
	         let $tei := 
			 	if ($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FContent/mets:xmlData/tei:TEI) then
					$mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FContent/mets:xmlData/tei:TEI
				else 
					if ($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat) then
  					    let $external:=
					        xdmp:http-get($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string())
					    return
							if ($external/response[@xmlns="xdmp:http"]/code[@xmlns="xdmp:http"]!="404") then
							  $external[2]
							else ()
					else ()
	         
	         let $metalink := $page/../@DMDID/string()
         	 return <l:part>{
                           for $relateditem in $mets//mods:relatedItem[@ID = $metalink]
                     	      let $title := 
							  		if($relateditem/mods:titleInfo) then 
										string-join($relateditem/mods:titleInfo/*, " ")
                        	        else
                                        if($relateditem/mods:note[@type = "caption"]) then 
											$relateditem/mods:note[@type = "caption"]/string()
                                        else $metalink

                          	 let $names := if(exists($relateditem/mods:name)) then
                                          	 for $name in $relateditem/mods:name
                                           			return
		                                             	<n>{
		                                                  if(contains($name/mods:namePart, "[tib.")) then substring-before(string-join($name/mods:namePart[not(@type = "date")][not(@type = "role")], " "), "[tib.")
		                                                  else string-join($name/mods:namePart[not(@type = "date")][not(@type = "role")], " ")
		                                                }</n>
                                         	else ()
                           	return <l:meta><l:key>{ $key }</l:key>
									<l:title>{ $title }</l:title>
									{if (exists($names) ) then <l:names>{string-join($names,'; ')}</l:names> else () }
									{if (exists($names and $tei//tei:speaker) ) then <l:role>speaker</l:role> else () }
									<l:abstract>{ $relateditem//mods:abstract/string() }</l:abstract>
									</l:meta>
                         }{ if (not (empty($tei)) ) then lh:tei-highlight($tei ) else ()  }</l:part>    
       }</l:tei>
};
declare function utils:tei-meta($mets as element()) as element(l:tei) {
(: gets metadata only for each tei part , for us in tei-snips.xqy and...  :)
  <l:tei>{
         for $page at $x in $mets//mets:div[matches(@TYPE, ("text"))]
	         let $key := $page/mets:fptr/@FILEID/string()
	         let $masterkey := $page//mets:fptr[1]/@FILEID/string()
	         let $pageurl := concat("http://", $cfg:DISPLAY-SUBDOMAIN, $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string())
	         let $tei := 
			 	if ($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FContent/mets:xmlData/tei:TEI) then
					$mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FContent/mets:xmlData/tei:TEI
				else 
					if ($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat) then
  					    let $external:=
					        xdmp:http-get($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string())
					    return
							if ($external/response[@xmlns="xdmp:http"]/code[@xmlns="xdmp:http"]!="404") then
							  $external[2]
							else ()
					else ()
	         
	         let $metalink := $page/../@DMDID/string()
         	 return <l:part>{
                           for $relateditem in $mets//mods:relatedItem[@ID = $metalink]
                     	      let $title := 
							  		if($relateditem/mods:titleInfo) then 
										string-join($relateditem/mods:titleInfo/*, " ")
                        	        else
                                        if($relateditem/mods:note[@type = "caption"]) then 
											$relateditem/mods:note[@type = "caption"]/string()
                                        else $metalink

                          	 let $names := if(exists($relateditem/mods:name)) then
                                          	 for $name in $relateditem/mods:name
                                           			return
		                                             	<n>{
		                                                  if(contains($name/mods:namePart, "[tib.")) then substring-before(string-join($name/mods:namePart[not(@type = "date")][not(@type = "role")], " "), "[tib.")
		                                                  else string-join($name/mods:namePart[not(@type = "date")][not(@type = "role")], " ")
		                                                }</n>
                                         	else ()
                           	return <l:meta><l:key>{ $key }</l:key>
									<l:title>{ $title }</l:title>
									{if (exists($names) ) then <l:names>{string-join($names,'; ')}</l:names> else () }
									{if (exists($names and $tei//tei:speaker) ) then <l:role>speaker</l:role> else () }
									<l:abstract>{ $relateditem//mods:abstract/string() }</l:abstract>
									</l:meta>
                         }
						
						 </l:part>    
       }</l:tei>
};

declare function utils:tei-file($mets as element(), $itemID as xs:string ) as element(l:tei) {
(:single tei file based on itemID:)
  <l:tei>{
         for $page at $x in $mets//mets:div[matches(@TYPE, ("text"))][mets:fptr[@FILEID=$itemID]]
	         let $key := $page/mets:fptr/@FILEID/string()
	         let $masterkey := $page//mets:fptr[1]/@FILEID/string()
	         let $pageurl := concat("http://", $cfg:DISPLAY-SUBDOMAIN, $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string())
	         let $tei := 
			 	if ($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FContent/mets:xmlData/tei:TEI) then
					$mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FContent/mets:xmlData/tei:TEI
				else 
					if ($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat) then
  					    let $external:=
					        xdmp:http-get($mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $key]/mets:FLocat/@xlink:href/string())
					    return
							if ($external/response[@xmlns="xdmp:http"]/code[@xmlns="xdmp:http"]!="404") then
							  $external[2]
							else ()
					else ()
	         
	         let $metalink := $page/../@DMDID/string()
         	 return <l:part>{
                           for $relateditem in $mets//mods:relatedItem[@ID = $metalink]
                     	      let $title := 
							  		if($relateditem/mods:titleInfo) then 
										string-join($relateditem/mods:titleInfo/*, " ")
                        	        else
                                        if($relateditem/mods:note[@type = "caption"]) then 
											$relateditem/mods:note[@type = "caption"]/string()
                                        else $metalink

                          	 let $names := if(exists($relateditem/mods:name)) then
                                          	 for $name in $relateditem/mods:name
                                           			return
		                                             	<n>{
		                                                  if(contains($name/mods:namePart, "[tib.")) then substring-before(string-join($name/mods:namePart[not(@type = "date")][not(@type = "role")], " "), "[tib.")
		                                                  else string-join($name/mods:namePart[not(@type = "date")][not(@type = "role")], " ")
		                                                }</n>
                                         	else ()
                           	return <l:meta><l:key>{ $key }</l:key>
									<l:title>{ $title }</l:title>
									{if (exists($names) ) then <l:names>{string-join($names,'; ')}</l:names> else () }
									{if (exists($names and $tei//tei:speaker) ) then <l:role>speaker</l:role> else () }
									<l:abstract>{ $relateditem//mods:abstract/string() }</l:abstract>
									</l:meta>
                         }{ if (not (empty($tei)) ) then lh:tei-highlight($tei ) else ()  }</l:part>    
       }</l:tei>
};
declare function utils:json-files($pages as element()) {
(: currently, null elements don't work! :)
(	concat("["),
    (
    if (exists($pages/l:volume)) then
        for $v in $pages/*
                return 
                (
                concat("["),
                utils:json-child($v,fn:false() ),
                "]",
                if ($v/../child::*[. >> $v])  then "," else ()
                )
    else
        utils:json-child($pages,fn:false() )
         ),
    "]"
)
};
declare private function utils:json-child($element as node(), $showname ) {

	for $item at $i in $element/*
		let $escaped-string:=replace($item/text(),"'","&#8217;")
		return
        (
            if ($showname ) then 
                    concat( '"', local-name($item),'":') 
                else    "{",

            utils:json-child($item, fn:true()),             
            if (exists($item/text()) ) then concat('"',$escaped-string,'"') else (), 
            
            if ($item/text() != $item/../child::*[last()]/text() ) then "," else (),                    
            
            if ($showname) then 
                () 
            else
                ("}",if ($item/../child::*[. >> $item])  then "," else () )
            )       	
};
declare function utils:get($id as xs:string, $element as xs:string? ) as node()  {

    (: Get the xml fragment for a given $id optional $element subelement name in mets:mets.
       If no element parameter, returns mets:mets.  Multiple hits are wrapped in <results/>.
       Example:
         -- http://marklogic1.loctest.gov:8021/marklogic/render.xqy?id=loc.natlib.lcdb.12037148&element=mods:mods
         -- utils:get("loc.natlib.lcdb.12037148","mods:place")    
    :)

    try {
        let $doc:= utils:mets($id)
        let $nodename := if ($element) then $element else "mets:mets"
        return      
            if (count($doc/descendant-or-self::*[name()=$nodename ] ) >1 ) then
               <results>{$doc/descendant-or-self::*[name()=$nodename]}</results>
            else
               $doc/descendant-or-self::*[local-name()=$nodename ] 
    } catch($e) {
        (xdmp:log(xdmp:quote($e)), ())
    }
};


declare function utils:format-number($number as xs:decimal, $format as xs:string) as xs:string
{
	let $strNumber := string(
						if (ends-with($format, "%")) then $number*100 else $number
					)
	let $decimalPart := codepoints-to-string(
							utils:format-number-decimal(
								string-to-codepoints( substring-after($strNumber, ".") ),
								string-to-codepoints( substring-after($format, ".") )
							)
						)
	let $integerPart := codepoints-to-string(
							utils:format-number-integer(
								reverse(
									string-to-codepoints(
										if(starts-with($strNumber, "0.")) then
											""
										else
											if( contains($strNumber, ".") ) then substring-before($strNumber, ".") else $strNumber
									)
								),
								reverse(
									string-to-codepoints(
										if( contains($format, ".") ) then substring-before($format, ".") else $format
									)
								),
								0, -1
							)
						)
	return
		if (string-length($decimalPart) > 0) then
			concat($integerPart, ".", $decimalPart) 
		else
			$integerPart
};





declare function utils:format-number-decimal($number as xs:integer*, $format as xs:integer*) as xs:integer*
{
	if ($format[1] = 35 or $format[1] = 48) then
		if (count($number) > 0) then
			($number[1], utils:format-number-decimal(subsequence($number, 2), subsequence($format, 2)))
		else
			if ($format[1] = 35) then () else ($format[1], utils:format-number-decimal((), subsequence($format, 2)))
	else
		if (count($format) > 0) then
			($format[1], utils:format-number-decimal($number, subsequence($format, 2)))
		else
			()
};

declare function utils:format-number-integer($number as xs:integer*, $format as xs:integer*, $thousandsCur as xs:integer, $thousandsPos as xs:integer) as xs:integer*
{
	if( $thousandsPos > 0 and $thousandsPos = $thousandsCur and count($number) > 0) then
		(utils:format-number-integer($number, $format, 0, $thousandsCur), 44)
	else
		if ($format[1] = 35 or $format[1] = 48) then
			if (count($number) > 0) then
				(utils:format-number-integer(subsequence($number, 2), subsequence($format, 2), $thousandsCur+1, $thousandsPos), $number[1])
			else
				if ($format[1] = 35) then () else (utils:format-number-integer((), subsequence($format, 2), $thousandsCur+1, $thousandsPos), $format[1])
		else
			if (count($format) > 0) then
				if ($format[1] = 44) then
					(utils:format-number-integer($number, subsequence($format, 2), 0, $thousandsCur), $format[1])
				else
					(utils:format-number-integer($number, subsequence($format, 2), $thousandsCur+1, $thousandsPos), $format[1])
			else
				if (count($number) > 0) then
					(utils:format-number-integer(subsequence($number, 2), $format, $thousandsCur+1, $thousandsPos), $number[1])
				else
					()
};
declare function utils:rights-display($uri as xs:string ) as element(xhtml:div)* {

(: display holdings based on each 852; seems weird to base it on hte 852 instead of the whole record, but 852 is repeatable 
$erms: "erms" or "no" for lcdb 
:)
let $rights:=utils:mets($uri)//mets:amdSec

return 
    if (not($rights//mets:rightsMD)) then		
		<div class="holdings" xmlns="http://www.w3.org/1999/xhtml">
        	<dt class="label">Huh?</dt>
            <dd class="bibdata" >
            	<span class="noholdings">Permissions not expressed.</span>
			</dd>
		</div>
    else
		<div class="holdings" xmlns="http://www.w3.org/1999/xhtml">
			{for $item in $rights//mets:rightsMD
				return (<dt class="label">{$item/@label/string()}</dt>,
						<dd class="bibdata">{$item//rights:ConstraintDescription}</dd>)
			}
        </div>	
};