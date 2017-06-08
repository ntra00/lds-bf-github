xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";   
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace feed = "info:lc/xq-modules/atom-utils" at "/xq/modules/atom-utils.xqy";

let $page_size := lp:get-param-integer($lp:CUR-PARAMS, 'count', 10)
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'application/atom+xml'))
let $mycount := $page_size
let $mypage := lp:get-param-integer($lp:CUR-PARAMS, 'pg', 1)
let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q')
let $collection := lp:get-param-single($lp:CUR-PARAMS, 'collection', 'all')
let $cln as xs:string? := if(fn:not($collection) or ($collection eq "all")) then 
        $cfg:DEFAULT-COLLECTION 
    else 
        $collection
let $sortorder as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'sort', "score-desc")
let $longcount :=
        if ($mycount eq 10) then
            10
        else if ($mycount eq 25) then
            25
        else
            10
let $longstart := (($mypage * $longcount) + 1) - $longcount
let $start := $longstart
let $end := ($start - 1 + $page_size)
let $query := lq:store-query(lq:query-from-params($lp:CUR-PARAMS))
let $_ := xdmp:log(concat("query: ", xdmp:describe($query)),'debug')
let $ctselem := <blah>{lq:query-from-params($lp:CUR-PARAMS)}</blah>/element()
let $searchxml := lq:search-resolve($ctselem, $start, $longcount, $sortorder, $cln)
let $results := feed:search-api-to-Atom($searchxml, $term)
return
    (
        xdmp:set-response-content-type("application/atom+xml; charset=utf-8"), 
        xdmp:add-response-header("Cache-Control", "public, max-age=600"),        
        $results
    )