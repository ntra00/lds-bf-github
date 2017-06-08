xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";   
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace feed = "info:lc/xq-modules/atom-utils" at "/xq/modules/atom-utils.xqy";

let $page_size :=
    if (exists(lp:get-param-single($lp:CUR-PARAMS,'count'))) then
        lp:get-param-single($lp:CUR-PARAMS,'count') cast as xs:int
    else
        $cfg:RESULTS-PER-PAGE

let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime'))
let $mycount := $page_size
let $mypage := lp:get-param-integer($lp:CUR-PARAMS, 'pg', 1)
let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q')
let $sortorder as xs:string? := 
    if (lp:get-param-single($lp:CUR-PARAMS, 'sort')) then
        lp:get-param-single($lp:CUR-PARAMS, 'sort')
    else
        "score-desc"
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
let $results := feed:search-api-to-Atom(lq:search-resolve($ctselem, $start, $longcount), lp:get-param-single($lp:CUR-PARAMS, 'q'))
return
    if ($results instance of element(error:error)) then
        xdmp:set-response-code(400, "Bad Request")
    else
        (
            xdmp:set-response-content-type("application/atom+xml; charset=utf-8"), 
            xdmp:add-response-header("Cache-Control", "public, max-age=600"),        
            $results
        )