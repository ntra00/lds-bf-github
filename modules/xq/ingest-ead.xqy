xquery version "1.0-ml";

import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace split = "http://xmltwig.com/xml_split";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace mxe = "http://www.loc.gov/mxe";

declare variable $body := xdmp:get-request-body("xml")/mets:mets (:xdmp:get-request-body("text"):);

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
            (:<dir loc="{$uris}">{$contents}</dir>:)
        else if (count($contents) eq 0) then
            (xdmp:directory-delete($uris), xdmp:log(concat("Deleting directory ", $uris), "info"), local:delete-empty-dirs($parent))
        else
            ()
};

let $mets := $body (:xdmp:unquote($body, "", ("repair-full")):)
(:let $batch := $body/processing-instruction('lcload')/string() :)
let $readingroomyearfileURI := replace(xdmp:get-request-header("X-LOC-URIPrefix"), "/marklogic/opt/ead", "")

(:for $mets in $body:)
(:let $recstatus := substring($mrc/marc:leader, 6, 1)
let $resclean := normalize-space($mrc/marc:controlfield[@tag='001']/string())
let $dirtox := local:chars-001($resclean):)
let $mrc := $mets/mets:dmdSec[@ID="marc"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/marc:record/marc:controlfield[@tag='001']/string()
let $dest := "/catalog/lscoll/ead/"
let $permissions := xdmp:default-permissions()
let $destination-root := $dest
let $rryf := tokenize($readingroomyearfileURI, "/")
let $rr := concat($rryf[2], "/")
let $rryrcoll := replace($readingroomyearfileURI, "(.+)/.+\.xml", "$1/")
let $destination-uri := concat(replace($destination-root, "/$", ""), $readingroomyearfileURI)
let $destination-collections := ("/catalog/", "/catalog/lscoll/", $destination-root, concat($dest, $rr), concat(replace($destination-root, "/$", ""), $rryrcoll))
return
    try {
            (
                xdmp:document-insert($destination-uri, $mets, $permissions, $destination-collections),
                concat("Saving ", $destination-uri)
                (:, 
                if ($recstatus eq "n") then
                    xdmp:log(concat($batch, "-", $sub, " : ", "New record at: ", $destination-uri), "notice")
                else if ($recstatus eq "c") then
                    xdmp:log(concat($batch, "-", $sub, " : ", "Changed record at: ", $destination-uri), "notice")
                else if (matches($recstatus, "a|p")) then
                    xdmp:log(concat($batch, "-", $sub, " : ", "Increase in encoding level record at: ", $destination-uri), "notice")
                else
                    xdmp:log(concat($batch, "-", $sub, " : ", "Unknown status record with code ", $recstatus, " at: ", $destination-uri), "notice") :)
            )
    } catch($e) {
        xdmp:log($e, "error")
    } 