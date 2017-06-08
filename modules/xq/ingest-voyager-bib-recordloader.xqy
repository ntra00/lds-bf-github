xquery version "1.0-ml";

import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace split = "http://xmltwig.com/xml_split";
declare namespace error = "http://marklogic.com/xdmp/error";

declare variable $URI as xs:string external;
declare variable $XML-STRING as xs:string external;
declare variable $NAMESPACE as xs:string external;
declare variable $LANGUAGE as xs:string external;
declare variable $ROLES-EXECUTE as xs:string external;
declare variable $ROLES-INSERT as xs:string external;
declare variable $ROLES-READ as xs:string external;
declare variable $ROLES-UPDATE as xs:string external;
declare variable $COLLECTIONS as xs:string external;
declare variable $SKIP-EXISTING as xs:boolean external;
declare variable $ERROR-EXISTING as xs:boolean external;
declare variable $FORESTS as xs:string external;
(:declare variable $body := xdmp:get-request-body("xml")/node();:)
(:declare variable $sub := xdmp:get-request-header("X-LOC-Batch") :)

declare function local:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};

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

let $body := xdmp:unquote($XML-STRING)
let $batch := 
    if ($body/processing-instruction('lcload')) then
        $body/processing-instruction('lcload')/string()
    else
        "errorcleanup"
let $batchheader := xdmp:get-request-header("X-LOC-Batch")
let $sub := 
    if ($batchheader) then
        $batchheader
    else
        "fullexport"
for $mrc in $body/marc:record
let $recstatus := substring($mrc/marc:leader, 6, 1)
let $resclean := normalize-space($mrc/marc:controlfield[@tag='001']/string())
let $dirtox := local:chars-001($resclean)
let $dest := "/lscoll/lcdb/bib/"
let $permissions := (xdmp:permission("lc_read", "read"), xdmp:permission("lc_read", "execute"))
let $mets := 
    try {
        marcutil:marcslim-to-mets($mrc)
    } catch($e) {
        $e
    }
return
    if ($recstatus eq "d") then
        let $del := "/deleted"
        let $destination-root := concat($del, $dest)
        let $dir := concat($destination-root, string-join($dirtox, '/'), '/')
        let $destination-uri := concat($dir, $resclean, '.xml')
        let $destination-collections := ($destination-root, "/deleted/lscoll/", "/deleted/", "/deleted/lscoll/lcdb/")
        let $origxml := substring-after($destination-uri, $del)
        return
            try {
                    (
                        xdmp:document-insert($destination-uri, $mets, $permissions, $destination-collections), 
                        xdmp:log(concat($batch, "-", $sub, " : ", "Deleted record at: ", $destination-uri), "notice"), 
                        if (exists(doc($origxml))) then
                            (
                                xdmp:document-delete(substring-after($destination-uri, $del)), 
                                xdmp:log(concat("Deleting ", $destination-uri), "notice")
                            )
                        else
                            xdmp:log(concat("No record to delete at ", $origxml), "notice")
                    )
            } catch($e) {
                xdmp:log($e, "error")
            }
    else if ($mets instance of element(mets:mets)) then
        let $destination-root := $dest
        let $dir := concat($destination-root, string-join($dirtox, '/'), '/')
        let $destination-uri := concat($dir, $resclean, '.xml')
        let $destination-collections := ($destination-root, "/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/", "/catalog/lscoll/lcdb/bib/")
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
        let $era := concat("/errors", $dest, string-join($dirtox, ''), ".xml")
        return
            (
                xdmp:log($mets, "error"), 
                xdmp:log(concat($batch, "-", $sub, " : ", "Problem record at: ", $era), "notice"), 
                xdmp:document-insert($era, <error xmlns="http://marklogic.com/xdmp/error"><mets:metsHdr LASTMODDATE="{current-dateTime()}"/>{$mrc}</error>, $permissions, concat("/errors", $dest)),
                concat("Problem record at: ", $era)
            )
    else
        "Uh oh, unknown error, not error:error or mets:mets or deleted record from LDR/06"