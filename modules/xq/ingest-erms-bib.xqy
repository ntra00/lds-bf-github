xquery version "1.0-ml";

import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace split = "http://xmltwig.com/xml_split";
declare namespace error = "http://marklogic.com/xdmp/error";
(:ingest erms bib and resource records, copied from ingest-voyager-bib
:)
declare variable $body := xdmp:get-request-body("xml")/node();


declare function local:delete-empty-dirs($xmluri as xs:string) {
    let $uris := replace($xmluri, "/\d+\.xml", "/")
    let $contents := xdmp:directory-properties($uris, "1")
    let $c := string-length($uris) - 2
    let $parent := substring($uris, 1, $c)
    return
        if (count($contents) ge 1) then 
            xdmp:log(concat("Stopped deleting directories at ", $uris), "info")
        else if (count($contents) eq 0) then
            (xdmp:directory-delete($uris), xdmp:log(concat("Deleting directory ", $uris), "info"), local:delete-empty-dirs($parent))
        else
            ()
};

let $batch := 
    if ($body/processing-instruction('lcload')) then
        $body/processing-instruction('lcload')/string() (:"fullexport" or "ermsresources":)
    else
        "errorcleanup"
let $sub := xdmp:get-request-header("X-ERMS-Batch")

(:if (not(xdmp:directory-properties("/lscoll/erms/") )) then
let $permissions := (xdmp:permission("lc_read", "read"), xdmp:permission("lc_read", "execute"))
xdmp:directory-create("/lscoll/erms/",$permissions)
else ()
:)

for $mrc in $body/marc:record
	let $recstatus := substring($mrc/marc:leader, 6, 1)
	(:resclean is the "permalink" number, but 035a contains ".b[millenium id]" which we'll use for the uri
	 and in ermsto mets, for the objid
	let $resclean := normalize-space($mrc/marc:controlfield[@tag='001']/string())	
	:)
	let $id:=
		if ($batch="fullexport") then
			 if (starts-with($mrc/marc:datafield[@tag="035"][1]/marc:subfield[@code="a"]/string() ,".b")) then
    			substring-after($mrc/marc:datafield[@tag="035"][1]/marc:subfield[@code="a"]/string() ,'.b')
			else
				$mrc/marc:datafield[@tag="035"][1]/marc:subfield[@code="a"]/string()
		else (:ermsresource:)
			 if (contains($mrc/marc:controlfield[@tag="001"]/string(),"DLC")) then
			   substring-after($mrc/marc:controlfield[@tag="001"]/string(),"DLC/E)")
			else
				$mrc/marc:controlfield[@tag="001"]/string()

let $uri:= if ($batch="fullexport") then (:  "." is not in id :)
			concat("loc.natlib.erms.",data($id)) 
		else (:  "." IS in $id :)
			concat("loc.natlib.erms",data($id)) 

let $dest :=  if ($batch="fullexport") then
					"/lscoll/erms/bib/"
				else
					"/lscoll/erms/resources/"

let $permissions := (xdmp:permission("lc_read", "read"), xdmp:permission("lc_read", "execute"))
let $mets := 
    try {
       marcutil:ermsmarc-to-mets($mrc, $uri )
       
    } catch($e) {
        $e
    }
        
return  
	if ( not($id) or not(matches($id,"^.+\.c.+$"))  ) then
    	 if ($mets instance of element(mets:mets) ) then 
        	let $destination-root := $dest
          
	        let $destination-uri := concat($destination-root, $uri, '.xml')
    	    let $destination-collections := 
				if ($batch="fullexport") then
					($destination-root,"/lscoll/erms/bib/", "/lscoll/erms/", "/lscoll/" )
				else
					($destination-root,"/lscoll/erms/resources/", "/lscoll/erms/", "/lscoll/" )
        return 
            try {
                    (
                        xdmp:document-insert($destination-uri, $mets, $permissions, $destination-collections),
                        concat("Saving ", $destination-uri), 
                        if ($recstatus eq "n") then
                            xdmp:log(concat($batch, "-", $sub, " : ", "New record at: ", $destination-uri), "notice")
                        else if ($recstatus eq "c") then
                            xdmp:log(concat($batch, "-", $sub, " : ", "Changed record at: ", $destination-uri), "notice")
                        else if (matches($recstatus, "a|p")) then
                            xdmp:log(concat($batch, "-", $sub, " : ", "Increase in encoding level record at: ", $destination-uri), "notice")
                        else
                            xdmp:log(concat($batch, "-", $sub, " : ", "Unknown status record with code ", $recstatus, " at: ", $destination-uri), "notice")
                    )
            } catch($e) {
                xdmp:log($e, "error")
            }
    else if ($mets instance of element(error:error)) then
        let $era := concat("/errors", $dest, string-join($uri, ''), ".xml")
        return
            (
                xdmp:log($mets, "error"), 
                xdmp:log(concat($batch, "-", $sub, " : ", "Problem record at: ", $era), "notice"),                 
                xdmp:document-insert($era, <error xmlns="http://marklogic.com/xdmp/error"><mets:metsHdr LASTMODDATE="{current-dateTime()}"/>{$mrc}</error>, $permissions, concat("/errors", $dest)),
                concat("Problem record at: ", $era)
            )
else 
        let $era := concat("/errors", $dest, string-join($uri, ''), ".xml")
        return
            (
                xdmp:log($mets, "error"), 
                xdmp:log(concat($batch, "-", $sub, " : ", "URI Problem record at: ", $era), "notice"),                 
                xdmp:document-insert($era, <error xmlns="http://marklogic.com/xdmp/error"><mets:metsHdr LASTMODDATE="{current-dateTime()}"/>{$mrc}</error>, $permissions, concat("/errors", $dest)),
                concat("URI Problem record at: ", $era)
            )
    else
        "Uh oh, unknown error, not error:error or mets:mets or deleted record from LDR/06"
