xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.indexdata.com/turbomarc";
import module namespace mem = "http://xqdev.com/in-mem-update" at "/xq/modules/in-mem-update.xqy";
declare variable $body := xdmp:get-request-body("xml")/node();

let $sub := xdmp:get-request-header("X-ERMS-Batch")
for $mrc in $body//r
	let $recstatus := substring($mrc/l, 6, 1)
	let $resclean := substring-after(normalize-space($mrc/c001/string()),'.c')
	let $c001:=<c001 holdtype=".c_hold">{$resclean}</c001>
	let $c004:=<c004 bibtype=".b_bib">{substring-after(normalize-space($mrc/c004/string()),'.b')}</c004>
	
	(:let $dirtox := local:chars-001($resclean):)
	let $yazerror := 
	    if ($mrc/comment()) then
	        xdmp:log(concat("Yaz commented record at: ", $resclean), "notice")
	    else
	        ()
	let $destination-root := "/lscoll/erms/holdings/"
	let $permissions := (xdmp:permission("lc_read", "read"), xdmp:permission("lc_read", "execute"))
	let $mets := <r dT="{current-dateTime()}">{$mrc/child::*}</r>
	 let $mets:=mem:node-replace($mets//*:c001, $c001)
	 let $mets:=mem:node-replace($mets//*:c004, $c004)
	let $destination-uri := concat($destination-root, $resclean, '.xml')
	let $destination-collections := ($destination-root, "/lscoll/erms/", "/lscoll/")
    return 
        (
            try {
                    (
                        xdmp:document-insert($destination-uri, $mets, $permissions, $destination-collections),
                        concat("Saving ", $destination-uri), 
                        if ($recstatus eq "n") then
                            xdmp:log(concat($sub, " : ", "New record at: ", $destination-uri), "notice")
                        else if ($recstatus eq "c") then
                            xdmp:log(concat($sub, " : ", "Changed record at: ", $destination-uri), "notice")
                        else if (matches($recstatus, "a|p")) then
                            xdmp:log(concat($sub, " : ", "Increase in encoding level record at: ", $destination-uri), "notice")
                        else
                            xdmp:log(concat($sub, " : ", "Unknown status record with code ", $recstatus, " at: ", $destination-uri), "notice")
                    )
            } catch($e) {
                xdmp:log($e, "error")
            },
            $yazerror)
