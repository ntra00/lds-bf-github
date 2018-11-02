xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/lds/lib/l-query.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace myapp = "http://www.marklogic.com/myapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace idx = "info:lc/xq-modules/lcindex";

declare default collation "http://marklogic.com/collation/en/S1";

let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "term", "Dharma")
let $qname as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "qname", "idx:titleLexicon")
let $inmime as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "mime", "text/html")
let $mime := mime:safe-mime($inmime)
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $num-suggestions := 10
let $matches := 
    if($term eq "") then 
        () 
    else
        let $_ := xdmp:log(concat("suggestions for: ", $term), 'debug')
        return
            cts:element-value-match(xs:QName($qname), concat(normalize-space($term), "*"), ("case-insensitive", "diacritic-insensitive", "ascending", "collation=http://marklogic.com/collation/en/S1"))[1 to $num-suggestions]
let $content :=
    if (matches($mime, 'application/json')) then
        let $maps :=
            for $match in $matches
            let $map := map:map()
            let $put := map:put($map, "label", normalize-space($match))
            return
                (xdmp:to-json($map), map:clear($map))
        return
            text{"[", string-join($maps, ", "), "]"}
    else if (matches($mime, "text/plain")) then
        for $match in $matches return normalize-space($match)
    else
        <ul>{for $match in $matches return <li>{normalize-space($match)}</li>}</ul>
return
    (
        xdmp:set-response-content-type($mime), 
        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
        xdmp:add-response-header("Expires", resp:expires($duration)), xdmp:set-response-encoding("UTF-8"), 
        $content
    )