xquery version "1.0-ml";

import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace split = "http://xmltwig.com/xml_split";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace ss = "http://marklogic.com/xdmp/status/server";

declare variable $body := xdmp:get-request-body("xml")/node();

declare function local:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};

let $batch := 
    if ($body/processing-instruction('lcload')) then
        $body/processing-instruction('lcload')/string()
    else
        "errorcleanup"

let $sub := xdmp:get-request-header("X-LOC-Batch")
(:let $taskServerId as xs:unsignedLong := xdmp:host-status(xdmp:host())//hs:task-server-id
let $queue-allowed := data(xdmp:server-status(xdmp:host(), $taskServerId)/ss:queue-limit)
let $queue-now := data(xdmp:server-status(xdmp:host(), $taskServerId)/ss:queue-size):)
(:return
    if (($queue-now + 10000) lt $queue-allowed ) then:)

for $mrc in $body/marc:record
return
    xdmp:spawn("/xq/ingest-voyager-bib-spawn-insert.xqy", (xs:QName("mrc"), $mrc, xs:QName("batch"), $batch, xs:QName("sub"), $sub))