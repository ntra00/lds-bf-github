xquery version "1.0-ml";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace mets = "http://www.loc.gov/METS/";

declare variable $bibid := xdmp:get-request-field("bibid");

declare function local:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};


let $pre := "/catalog/lscoll/lcdb/bib/"
let $dirtox := local:chars-001($bibid)
let $path := concat($pre, string-join($dirtox, '/'), "/", $bibid, ".xml")
let $xml := doc($path)
return
    if (empty($xml)) then "No record" else $xml
