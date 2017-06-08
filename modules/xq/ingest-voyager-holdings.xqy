xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.indexdata.com/turbomarc";

declare variable $body := xdmp:get-request-body("xml")/node();

declare function local:chars-001($arg as xs:string?) as xs:string* {
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};

let $sub := xdmp:get-request-header("X-LOC-Batch")

for $mrc in $body/r
let $recstatus := substring($mrc/l, 6, 1)
let $resclean := normalize-space($mrc/c001/string())
let $dirtox := local:chars-001($resclean)
let $yazerror := 
    if ($mrc/comment()) then
        xdmp:log(concat("Yaz commented record at: ", $resclean), "notice")
    else
        ()
let $dest := "/lscoll/lcdb/holdings/"
let $permissions := (xdmp:permission("lc_read", "read"), xdmp:permission("lc_read", "execute"))
let $mets := <r dT="{current-dateTime()}">{$mrc/child::*}</r>
return (
    if ($recstatus eq "d") then
        let $del := "/deleted"
        let $destination-root := concat($del, $dest)
        (: let $dir := concat($destination-root, string-join($dirtox, '/'), '/') :)
        (: This now outputs without all the tokenized hierarchy, just the straight holdings number from 001 as the filename :)
        let $dir := $destination-root
        let $destination-uri := concat($dir, $resclean, '.xml')
        let $destination-collections := ($destination-root, "/deleted/lscoll/", "/deleted/", "/deleted/lscoll/lcdb/")
        let $origxml := substring-after($destination-uri, $del)
        return
            try {
                    (
                        xdmp:document-insert($destination-uri, $mets, $permissions, $destination-collections), 
                        xdmp:log(concat($sub, " : ", "Deleted record at: ", $destination-uri), "notice"), 
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
    else
        let $destination-root := $dest
        (: let $dir := concat($destination-root, string-join($dirtox, '/'), '/') :)
        (: This now outputs without all the tokenized hierarchy, just the straight holdings number from 001 as the filename :)
        let $dir := $destination-root
        let $destination-uri := concat($dir, $resclean, '.xml')
        let $destination-collections := ($destination-root, "/lscoll/lcdb/", "/lscoll/")
        return
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
            $yazerror
)