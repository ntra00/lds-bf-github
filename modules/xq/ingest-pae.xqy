xquery version "1.0-ml";
(: cribbed from ingest-voyager-bib to load pae records 
/lscoll/pae/, using 3rd node: /lscoll/pae/3rd node/:)

import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace mem = "http://xqdev.com/in-mem-update" at "/xq/modules/in-mem-update.xqy";
declare namespace mxe = "http://www.loc.gov/mxe";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace split = "http://xmltwig.com/xml_split";
declare namespace error = "http://marklogic.com/xdmp/error";

declare variable $mets := xdmp:get-request-body("xml")/node();

let $batch:= "PAE update"
  (:for $mets in $body	:)	
		let $mods:=$mets//mods:mods
let $objid:=$mets//@OBJID/string()
		let $idx := 
			<mets:dmdSec ID="IDX1">
		        <mets:mdWrap MDTYPE="OTHER">
		            <mets:xmlData>
		                {marcutil:mods-to-idx($mods, <mxe:record/>,$objid)}
		            </mets:xmlData>
		        </mets:mdWrap>
		    </mets:dmdSec>    
		let $newmets := 
				mem:node-insert-after($mets/mets:dmdSec[last()], $idx)

		let $dest := "/lscoll/pae/"		
		let $permissions := (xdmp:permission("lc_read", "read"), xdmp:permission("lc_read", "execute"))		
(:		let $objid:=$newmets//@OBJID/string():)
		let $subcoll:=tokenize($objid,'\.')[3]
		
return 
 if ($newmets/element() instance of element(mets:mets)) then        
(:store all at root( of /lscoll/pae: not under their own collection, but add subcoll (node3) as a collection too:)
	 	let $destination-uri:=concat($dest,  $objid, '.xml')                       		
        let $destination-collections := ($dest, concat($dest,$subcoll,"/"),  "/lscoll/")

		return 
			($destination-uri, ":",$dest,
            try {
                    (
                        xdmp:document-insert($destination-uri, $newmets,   $permissions , $destination-collections),                            
							xdmp:log(concat($batch, " : ", "New PAE record at: ", $destination-uri) ,"notice")
                    )
            } catch($e) {
                xdmp:log($e, "error")
            }
			)
  else if ($mets instance of element(error:error)) then
       let $era := concat("/errors", $dest, $objid, ".xml")
        return
            (
                xdmp:log($mets, "error"), 
                xdmp:log(concat($batch,  " : ", "Problem record at: ", $era), "notice"),                 
                xdmp:document-insert($era, <error xmlns="http://marklogic.com/xdmp/error"><mets:metsHdr LASTMODDATE="{current-dateTime()}"/>{$mets}</error>, $permissions, concat("/errors", $dest)),
                concat("Problem record at: ", $era)
            )
    else concat($objid,
        ". Uh oh, unknown error, not(error:error or mets:mets) ??")
		
