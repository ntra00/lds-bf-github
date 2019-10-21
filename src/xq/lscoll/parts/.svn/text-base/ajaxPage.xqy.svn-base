xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace vr = "http://www.marklogic.com/ps/view/v-result" at "/xq/lscoll/view/v-result.xqy";
import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at "/xq/lscoll/view/v-facets.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/xq/lscoll/view/v-search.xqy";
import module namespace vd = "http://www.marklogic.com/ps/view/v-detail" at "/xq/lscoll/view/v-detail.xqy";
import module namespace vb = "http://www.marklogic.com/ps/view/v-browse" at "/xq/lscoll/view/v-browse.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
declare namespace qm="http://marklogic.com/xdmp/query-meters";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mxe1 = "mxens";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare variable $e-ns := "http://marklogic.com/entity";

let $page_size :=
    if (exists(lp:get-param-single($lp:CUR-PARAMS,'count'))) then
        lp:get-param-single($lp:CUR-PARAMS,'count') cast as xs:int
    else
        $cfg:RESULTS-PER-PAGE

let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime'))
let $page as xs:string? := lp:get-param-single($lp:CUR-PARAMS, '/page')
let $mycount := $page_size
let $mypage := lp:get-param-integer($lp:CUR-PARAMS, 'pg', 1)
let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q')
let $browsefield as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'browse')
let $browsedirection as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'browse-order')
let $sortorder as xs:string? := 
    if (lp:get-param-single($lp:CUR-PARAMS, 'sort')) then
        lp:get-param-single($lp:CUR-PARAMS, 'sort')
    else
        "score-desc"
let $cln as xs:string? := 
    if (lp:get-param-single($lp:CUR-PARAMS, 'collection')) then
        if (lp:get-param-single($lp:CUR-PARAMS, 'collection') eq "all") then
            $cfg:DEFAULT-COLLECTION
         else
            lp:get-param-single($lp:CUR-PARAMS, 'collection')
    else
        $cfg:DEFAULT-COLLECTION
let $uri := lp:get-param-single($lp:CUR-PARAMS, 'uri')
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
let $query := lq:query-from-params($lp:CUR-PARAMS)    (: lq:store-query(lq:query-from-params($lp:CUR-PARAMS)) :)
let $_ := xdmp:log(concat("query: ", xdmp:describe($query)),'debug')
let $results := 
    if( $page eq 'detail' or $page eq 'search') then
        ()
    else if ($page eq 'browse') then
        lq:browse-lexicons($term, $browsefield, $browsedirection)
    else
        if ($sortorder eq "score-desc") then
            (
                for $result in cts:search(collection($cln), $query,"unfiltered")
                order by cts:score($result) descending, $result//idx:title ascending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "score-asc") then
            (
                for $result in cts:search(collection($cln), $query,"unfiltered")
                order by cts:score($result) ascending, $result//idx:title ascending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "pubdate-asc") then
            (
                for $result in cts:search(collection($cln), $query,"unfiltered")
                order by $result//idx:pubdateSort descending collation "http://marklogic.com/collation/codepoint", $result//idx:title ascending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "pubdate-desc") then
            (
                for $result in cts:search(collection($cln), $query,"unfiltered")
                order by $result//idx:pubdateSort ascending collation "http://marklogic.com/collation/codepoint", $result//idx:title ascending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "cre-asc") then
            (
                for $result in cts:search(collection($cln), $query,"unfiltered")
                order by $result//idx:nameSort ascending collation "http://marklogic.com/collation/codepoint", $result//idx:title ascending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "cre-desc") then
            (
                for $result in cts:search(collection($cln), $query,"unfiltered")
                order by $result//idx:nameSort descending collation "http://marklogic.com/collation/codepoint", $result//idx:title ascending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else
            (for $result in cts:search(collection($cln), $query,"unfiltered") return $result)[$start to $end]
let $outdiv :=
    <div id="ajaxPage">
    {
        (
            <div id="search-results">
                {vs:render()}
            </div>,    
            <div id="results">
            {
                (
                    if ($page eq 'results') then
                        let $elapsed := round-half-to-even(seconds-from-duration(xdmp:elapsed-time() cast as xs:duration), 3)
                        return
                            vr:render($results, $start, $elapsed, $longstart, $longcount)
                    else if ($page eq 'detail') then
                        vd:render()
                    else if ($page eq 'browse') then
                        vb:render($results, $browsefield, $browsedirection)
                    else
                        ()                        
                )                    
            }
            </div>,
            if (exists($cfg:DISPLAY-ELEMENTS//*:elt/*:page[text() = $page])) then
                <div id="facet-results">
                    {
                    vf:facets($page)
                    (: 
                        vf:facets-concurrent($page) 
                    :)
                    } 
                    
                </div>
            else
                ()
        )
    }
    </div>

let $duration := $cfg:HTTP_EXPIRES_CACHE

return
    (
        xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
        xdmp:add-response-header("Expires", resp:expires($duration)),       
        $outdiv,
		xdmp:log( 
			text{"AJAX-PAGE-PERFORMANCE",xdmp:elapsed-time()  div xs:dayTimeDuration("PT0.001S"), xdmp:get-request-header("X-Forwarded-For"), 
				fn:concat( xdmp:get-request-url(  ),"?", 
					fn:string-join((   
                		for $text at $x in $lp:CUR-PARAMS//text()  
                		return
                		if ($x mod 2 eq 0) then ($text,"&amp;") else ($text,"=")
                		),""
                		))}  ,"notice")
        )