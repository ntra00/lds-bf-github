xquery version "1.0-ml";

import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace split = "http://xmltwig.com/xml_split";
declare namespace error = "http://marklogic.com/xdmp/error";

declare variable $mrc as element(marc:record) external;
declare variable $batch as xs:string external;
declare variable $sub as xs:string* external;

declare function local:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};

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