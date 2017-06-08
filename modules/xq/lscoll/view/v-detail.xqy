xquery version "1.0-ml";

module namespace vd = "http://www.marklogic.com/ps/view/v-detail";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace md = "http://www.marklogic.com/ps/model/m-doc" at "/xq/lscoll/model/m-doc.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace lcvar="info:lc/xq-invoke-variable";

declare function vd:render() as element(div) {
    let $browseback := xdmp:set-session-field("browseback", lp:param-string($lp:CUR-PARAMS))
    let $viewindex := lp:get-param-integer($lp:CUR-PARAMS, 'index', 1)
    let $sortorder as xs:string? := 
        if (lp:get-param-single($lp:CUR-PARAMS, 'sort')) then
            lp:get-param-single($lp:CUR-PARAMS, 'sort')
        else
            "score-desc"
    let $prevint := $viewindex - 1
    let $nextint := $viewindex + 1
    let $query := lq:query-from-params($lp:CUR-PARAMS) 
    let $est := xdmp:estimate(cts:search(collection($cfg:DEFAULT-COLLECTION), $query)) (:cts:remainder($results[1]):)
    let $start :=
        if ($viewindex eq 1 or ($viewindex - $prevint) le 1) then
            1
        else
            ($viewindex - $prevint)     
    let $end :=
        if ($viewindex eq $est or ($viewindex + $nextint) gt $est) then
            $est
        else
            ($viewindex + $nextint) 
    let $results := 
        if ($sortorder eq "score-desc") then
            (
                for $result in cts:search(collection($cfg:DEFAULT-COLLECTION), $query,"unfiltered")
                order by cts:score($result) descending
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "score-asc") then
            (
                for $result in cts:search(collection($cfg:DEFAULT-COLLECTION), $query,"unfiltered")
                order by cts:score($result) ascending
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "pubdate-asc") then
            (
                for $result in cts:search(collection($cfg:DEFAULT-COLLECTION), $query,"unfiltered")
                order by $result//idx:pubdateSort ascending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "pubdate-desc") then
            (
                for $result in cts:search(collection($cfg:DEFAULT-COLLECTION), $query,"unfiltered")
                order by $result//idx:pubdateSort descending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "cre-asc") then
            (
                for $result in cts:search(collection($cfg:DEFAULT-COLLECTION), $query,"unfiltered")
                order by $result//idx:nameSort ascending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else if ($sortorder eq "cre-desc") then
            (
                for $result in cts:search(collection($cfg:DEFAULT-COLLECTION), $query,"unfiltered")
                order by $result//idx:nameSort descending collation "http://marklogic.com/collation/codepoint"
                return
                    $result
            )[$start to $end]
        else
            (for $result in cts:search(collection($cfg:DEFAULT-COLLECTION), $query,"unfiltered") return $result)[$start to $end]
            
    let $uri := string($results[$viewindex]/mets:mets/@OBJID)
    let $uriprev := string($results[$prevint]/mets:mets/@OBJID)
    let $urinext := string($results[$nextint]/mets:mets/@OBJID)
    let $map := map:map()
    let $put := map:put($map, "ajax", concat('/xq/lscoll/parts/ajax-MARC.xqy?objid=', $uri))
    let $ajaxjson := xdmp:to-json($map)
    let $backparams := lp:param-replace-or-insert($lp:CUR-PARAMS, "/page", "results")
    let $backparams := lp:param-remove($backparams, "index", $viewindex cast as xs:string)
    let $backparams := lp:param-remove($backparams, "uri", $uri)
    let $back := concat("/xq/lscoll/app.xqy#", lp:param-string($backparams))
    let $nextparams := lp:param-replace-or-insert($lp:CUR-PARAMS, "index", $nextint)
    let $nextparams := lp:param-replace-or-insert($nextparams, "uri", $urinext)
    let $prevparams := lp:param-replace-or-insert($lp:CUR-PARAMS, "index", $prevint)
    let $prevparams := lp:param-replace-or-insert($prevparams, "uri", $uriprev)
    let $prevdoc := lp:param-string($prevparams)
    let $nextdoc := lp:param-string($nextparams)
    let $prev := 
        if ($viewindex gt 1) then
            <li><a class="previous" href="/xq/lscoll/app.xqy#{$prevdoc}">Previous</a></li>
        else
            <li><span class="prev_off">Previous</span></li>
    let $next := 
        if ($viewindex lt $est) then
            <li><a class="next" href="/xq/lscoll/app.xqy#{$nextdoc}">Next</a></li>
        else
            <li><span class="next_off">Next</span></li>
    return
        <div id="content-results">
            <div id="ds-bibrecord-nav">
                <ul class="bibrecord-nav">
                    <li><a id="backtoresults" class="back" href="{$back}">Back to results</a></li>
                    {$prev}
                    <li><span class="count">[<strong>{$viewindex}</strong> of {format-number($est, "#,###")}]</span></li>
                    {$next}
                    <li><a class="marc" title="View MARC Tags" href='javascript:jQuery.facybox({$ajaxjson});'>Librarian's view</a></li>
                    <li><a class="print" href="javascript:window.print();" title="Print this item">Print this item</a></li>
                </ul>
            <!-- end id:ds-bibrecord-nav -->
            </div>
            { 
                md:convertEntities(
                    cts:highlight( 
                        md:lcrender($uri), 
                        lq:get-highlight-query(),
                        <span class="highlt">{$cts:text}</span>
                    )
                )
            }
            <span id="detailURL" style="visibility: hidden;">{$uri}</span>
        </div>
};