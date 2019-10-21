xquery version "1.0-ml";

module namespace vf = "http://www.marklogic.com/ps/view/v-facets";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/xq/lscoll/view/v-search.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
import module namespace ld = "http://www.marklogic.com/ps/lib/l-date" at "/xq/lscoll/lib/l-date.xqy";
import module namespace lfc = "http://www.marklogic.com/ps/lib/l-facet-cache" at "/xq/lscoll/lib/l-facet-cache.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default collation "http://marklogic.com/collation/en/S1";

(: Primary function for rendering facets div :)
declare function vf:facets($page-name as xs:string) as element()* {
    <h2 id="section-title">Refine Results</h2>,    
    for $elt at $fx in $cfg:DISPLAY-ELEMENTS//*:elt[*:page = $page-name]
    let $view-name := $elt/*:view-name/text()
    let $id := concat("facet-",$fx)
    let $isHidden := ($elt/*:starts-hidden/text() eq "true")
    let $display := if($isHidden) then 'none' else 'block'
    let $char := if($isHidden) then "+" else "-"
    return             
        <div class="facet-box">
           <div class="title">
                <span class="title-name">{$view-name}</span>
                <span class="title-toggle">
                    <a id="{$id}" class="hidden">{$char}</a>
                </span>
                <br class="break"/>
            </div>
            <div class="content" id="{$id}" style="display:{$display}">
            {
                xdmp:apply(xdmp:function(xs:QName($elt/*:data-function/text())), ($elt/*:facet-param/text(), $elt/*:facet-id/text()))
            }
            </div>
        </div>
};

(:  ################# FACET FUNCITON POINTER TARGETS ################### :)

declare function vf:facet-data($params as xs:string*) {
    let $ns := $params[1]
    let $ln := $params[2]
    let $id := $params[3]
    let $_ := xdmp:log(text{"Entering facet-data: ",$ln},'fine')
    let $cur-params := $lp:CUR-PARAMS
    let $query-id-long := cts:register( lq:query-from-params($cur-params) )
    let $query-id-string := fn:concat($ln,"-",$id,"-",xs:string($query-id-long))
    
    let $facet-values := lfc:get-facet-cache( $query-id-string )
    let $facet-values := if($facet-values) then $facet-values else


        let $result := vf:facet-values($ns,$ln,$id,$query-id-long,$cur-params, 
                        ("frequency-order",
                         "concurrent",
                         "limit=10",
                         "collation=http://marklogic.com/collation/codepoint"))
        let $_ := if($cfg:CACHE-FACETS) then        
                let $query-id-string := fn:concat($ln,"-",$id,"-",xs:string($query-id-long))
                return 
                lfc:insert-cache( $query-id-string, $result )
            else
                ()
        return 
        $result
        
        
    return
    
     <ul>
        {

            let $count := 
                xs:int($facet-values/vf:count/text())
    
            return
                if($count gt 0) then (
                    for $value in $facet-values/vf:facet-value
                    let $val := $value/vf:val/text()
                    let $freq := xs:int($value/vf:freq/text())
                    return
                        if( lp:param-value-contains($cur-params,$id,$val) ) then
                            vf:facet-link-remove($ns, $ln, $id, $cur-params, $val, $freq)
                        else
                            vf:facet-link-add($ns, $ln, $id, $cur-params, $val, $freq),
                            
                    if($cfg:FACETS-PER-BOX eq $count) then
                    let $href := fn:concat( 
                        'javascript:jQuery.facybox(&#123;"ajax":"\/xq\/lscoll\/parts\/moreFacet.xqy?',
                        lp:param-string($cur-params),
                        '&amp;id=',
                        $id,
                        '"&#125;);'
                    
                    )
                    return
                    (
                        <li class="fright">
                            <!--a id="{lp:param-string($cur-params)}&amp;id={$id}" class="facet-more small">more ...</a-->
                            <a 
                                class="facet-more small" 
                                href='{$href}'
                                >more ...</a>
                        </li>,
                        <br class="break"/>
                    )
                    else 
                        ()
                            
                            
                ) else
                    <span class="noresults">No results.</span>
        }
        </ul>
        
};

declare function vf:facet-two-tier($params as xs:string*) {
    let $ns1 := $params[1]
    let $ln1 := $params[2]
    let $ns2 := $params[3]
    let $ln2 := $params[4]
    let $id := $params[5]
    let $cur-params := $lp:CUR-PARAMS
    
    let $useId1 := fn:concat($id,"a")
    let $useId2 := fn:concat($id,"b")
    
    let $query := lq:query-from-params($cur-params)
    let $query-id-long := cts:register( lq:query-from-params($cur-params) )
    let $query-id-string := fn:concat($ln1,"-",$useId1,"-",xs:string($query-id-long))
    
    let $facet-values := lfc:get-facet-cache( $query-id-string )
    let $facet-values := if($facet-values) then $facet-values else

        let $result := vf:facet-values($ns1,$ln1,$useId1,$query-id-long,$cur-params, 
                        ("item-order",
                         "collation=http://marklogic.com/collation/codepoint"))
        let $_ :=   if($cfg:CACHE-FACETS) then        
                        lfc:insert-cache( $query-id-string, $result )
                    else
                        ()
        return 
        $result
    
     let $count := 
                xs:int($facet-values/vf:count/text())   
     return
        <ul>
        {
            if($count gt 0) then (
        
            for $value in $facet-values/vf:facet-value
            let $val1 := $value/vf:val/text()
            let $freq := xs:int($value/vf:freq/text())
            return
                if( lp:param-value-contains($cur-params,$useId1,$val1) ) then
                    vf:facet-link-remove-two-tier($ns1, $ln1, $useId1, $ns2, $ln2, $useId2, $cur-params, $query-id-long, $val1, $freq)
                else
                    vf:facet-link-add($ns1, $ln1, $useId1, $cur-params, $val1, $freq)
            ) else
            <span class="noresults">No results.</span>
        }
        </ul>
};


(:  ################# CACHING UTILS ################### :)

declare function vf:facet-values($ns,$ln,$id,$query-id-long,$cur-params,$options) {
    let $query := cts:registered-query($query-id-long, "unfiltered")
    let $_ := xdmp:log(text{"Computing facet results: ",$ln,"-",$id,"-",$query-id-long},"fine")
    return
    
    element vf:facet-values {
    
        let $values := cts:element-values( QName($ns,$ln), (), 
                        ($options), 
                         cts:and-query((cts:collection-query($cfg:DEFAULT-COLLECTION),$query)) )
                         
        let $count := fn:count($values)   
        
        return (
        
            element vf:count { $count },
        
            for $val in $values
            let $freq  := cts:frequency($val)
            return
                if($val) then
                element vf:facet-value {
                    element vf:val {$val},
                    element vf:freq {$freq}
                }
                else ()
        )
    }

};

(: for nightly cron, populates cache for a facet :)
declare function vf:facet-data-cache($params as xs:string*) {
    
    let $ns := $params[1]
    let $ln := $params[2]
    let $id := $params[3]
    let $_ := xdmp:log(text{"Entering facet-data-cache: ",$ln},'fine')
    let $cur-params := $lp:CUR-PARAMS
    let $query-id-long := cts:register( lq:query-from-params($cur-params) )
    let $query-id-string := fn:concat($ln,"-",$id,"-",xs:string($query-id-long))
    let $result := vf:facet-values($ns,$ln,$id,$query-id-long,$cur-params,("frequency-order",
                         "concurrent",
                         "limit=10",
                         "collation=http://marklogic.com/collation/codepoint"))
    
    return
    
    lfc:insert-cache( $query-id-string, $result )
    
    
};


(:  ################# LINK RENDERERS ################### :)


declare function vf:facet-link-remove-two-tier($ns1, $ln1, $id1, $ns2, $ln2, $id2, $cur-params, $query-id-long, $val1, $freq) {
    let $new-params := lp:param-apply-facet-page-control($cur-params)
    let $new-params := lp:param-replace-or-insert($new-params, 'pg', '1')
    let $new-params := lp:param-remove-all($new-params, 'uri')
    let $new-params := lp:param-remove($new-params, $id1, $val1)
    let $new-params := lp:param-remove-all($new-params, $id2)
    let $new-params-str := lp:param-string($new-params)
    return
    <li>
        <span class="remove-facet">
            <a href="/xq/lscoll/app.xqy?{$new-params-str}" 
               rel="{$new-params-str}">
                X
            </a> {$val1} [{format-number($freq, "#,###") }]
        </span>
        <ul style="margin-left:15px;">
        {
        
            let $query-id-string := fn:concat($ln2,"-",$id2,"-",xs:string($query-id-long))
            let $facet-values := lfc:get-facet-cache( $query-id-string )
            let $facet-values := if($facet-values) then $facet-values else
                let $result := vf:facet-values($ns2,$ln2,$id2,$query-id-long,$cur-params, 
                                ("item-order",
                                 "collation=http://marklogic.com/collation/codepoint"))
                let $_ :=   if($cfg:CACHE-FACETS) then        
                                lfc:insert-cache( $query-id-string, $result )
                            else
                                ()
                return 
                $result
            let $count := 
                xs:int($facet-values/vf:count/text())   
            return
        
                for $value in $facet-values/vf:facet-value
                let $val2 := $value/vf:val/text()
                let $freq := xs:int($value/vf:freq/text())
                return
                
                    if( lp:param-value-contains($cur-params,$id2,$val2) ) then
                        vf:facet-link-remove($ns2, $ln2, $id2, $cur-params, $val2, $freq)
                    else
                        vf:facet-link-add($ns2, $ln2, $id2, $cur-params, $val2, $freq)
            
        }
        </ul>
    </li>
};

declare function vf:facet-link-remove($ns, $ln, $id, $cur-params, $val, $freq) {
    let $new-params := lp:param-apply-facet-page-control($cur-params)
    let $new-params := lp:param-replace-or-insert($new-params, 'pg', '1')
    let $new-params := lp:param-remove-all($new-params, 'uri')
    let $new-params := lp:param-remove($new-params, $id, $val)
    let $new-params-str := lp:param-string($new-params)
    return
    
    <li>
        <span class="remove-facet">
            <a href="/xq/lscoll/app.xqy?{$new-params-str}" 
               rel="{$new-params-str}">
                X
            </a> {$val} [{format-number($freq, "#,###") }]
        </span>
    </li>
};

declare function vf:facet-link-remove-all($ns, $ln, $ids, $cur-params, $freq, $text) {
    let $new-params := lp:param-apply-facet-page-control($cur-params)
    let $new-params := lp:param-replace-or-insert($new-params, 'pg', '1')
    let $new-params := lp:param-remove-all($new-params, 'uri')
    let $_ := 
        for $id in $ids 
        return
        xdmp:set($new-params, lp:param-remove-all($new-params, $id))
    let $new-params-str := lp:param-string($new-params)
    return
    
    <li>
        <span class="remove-facet">
            <a href="/xq/lscoll/app.xqy?{$new-params-str}" 
               rel="{$new-params-str}">
                X
            </a> {$text} [{format-number($freq, "#,###") }]
        </span>
    </li>
};

declare function vf:facet-link-add($ns, $ln, $id, $cur-params, $val, $freq) {
    let $new-params := lp:param-apply-facet-page-control($cur-params)
    let $new-params := lp:param-replace-or-insert($new-params, 'pg', '1')
    let $new-params := lp:param-remove-all($new-params, 'uri')
    let $new-params := lp:param-insert($new-params, $id, $val)
    let $new-params-str := lp:param-string($new-params)
    let $_ := xdmp:log($new-params-str,"debug")
    return
    if($cfg:SHOW-ZERO-COUNT-FACETS or ($freq gt 0)) then
        <li>
            <a href="/xq/lscoll/app.xqy?{$new-params-str}" 
               rel="{$new-params-str}">
                {$val}
            </a> [{format-number($freq, "#,###") }]
        </li>
    else 
        ()
};

declare function vf:facet-link-add-multiple($ns, $ln, $ids, $cur-params, $vals,  $text) {
    let $new-params := lp:param-apply-facet-page-control($cur-params)
    let $new-params := lp:param-replace-or-insert($new-params, 'pg', '1')
    let $new-params := lp:param-remove-all($new-params, 'uri')    
    let $_ := for $id at $x in $ids return xdmp:set($new-params, lp:param-replace-or-insert($new-params, $id, $vals[$x]))
    let $new-params-str := lp:param-string($new-params)
    let $query := lq:query-from-params($new-params)
    let $freq := xdmp:estimate(cts:search( collection("docs"), $query))    
    return
    if($cfg:SHOW-ZERO-COUNT-FACETS or ($freq gt 0)) then
        <li>
            <a href="/xq/lscoll/app.xqy?{$new-params-str}" 
               rel="{$new-params-str}">
                {$text}
            </a> [{format-number($freq, "#,###") }]
        </li>
    else
        ()
};

(:  ################# MORE LINK ################### :)

(: render function for the more link facets :)
declare function vf:facet-data-more($params,  $id) {
    
    let $morepage := lp:get-param-integer($params, "mpg", 1)
    let $moresort := lp:get-param-single($params, "mps")
    let $moresort := if($moresort) then $moresort else "frequency-order"

    let $max-columns := 3
    let $column-size := $cfg:FACETS-PER-BOX
    let $page-size := ($column-size * $max-columns)
    let $start := (($morepage - 1) * $page-size) + 1
    let $end := ($morepage * $page-size)
    
    let $query := cts:registered-query(cts:register( lq:query-from-params($params) ), "unfiltered")
    let $elt := $cfg:DISPLAY-ELEMENTS//*:elt[*:facet-id eq $id]
    let $ns := ($elt/*:facet-param)[1]/text()
    let $ln := ($elt/*:facet-param)[2]/text()
    let $name := $elt/*:view-name/text()    
    let $sort-type := $moresort

    let $values := 
        cts:element-values(
            QName($ns,$ln), (), 
            (
                $sort-type, 
                "fragment-frequency",
                "collation=http://marklogic.com/collation/codepoint"
            ),
            cts:and-query((cts:collection-query($cfg:DEFAULT-COLLECTION), $query))
        )[$start to ($end + 1)]
        
    
    let $count := count($values)
    
    let $hasprev := $start gt 1
    let $hasnext := $values[($page-size +1)]
    
    let $values := $values[1 to $page-size]

    let $count := count($values)
    let $column-count := ceiling($count div $column-size) 
                    
    return
    
    <div id="facetmorediv" style="width:{ $column-count * 265 }px;">
        <h3>{$name}</h3>
        
        {
        
            let $title := "Sort by Frequency"
            let $alt-param := lp:param-replace-or-insert($params, "mpg", 1)
            let $alt-param := lp:param-replace-or-insert($alt-param, "mps", 
                    if($moresort eq "frequency-order") then 
                        (xdmp:set($title,"Sort by Alphabet"), "item-order") 
                    else 
                        "frequency-order"
                )
            let $link := fn:concat(
                "/xq/lscoll/parts/moreFacet.xqy?",
                lp:param-string($alt-param),
                "&amp;id=",$id
            )
            return
                
                <div style="float:right;">
                    <a id="morepaging" rel="{$link}">{$title}</a>
                </div>,
                <div class="break"/>,
            
        
            if($hasprev) then (
           
                let $link := fn:concat(
                    "/xq/lscoll/parts/moreFacet.xqy?",
                    lp:param-string(lp:param-replace-or-insert($params, "mpg", $morepage - 1)),
                    "&amp;id=",$id
                )
                return
            
                <div style="width:100%;text-align:center;">
                    <a id="morepaging" rel="{$link}">Previous Values</a>
                </div>,
                <div class="break"/>
            ) else (),
            
            for $x in ( 1 to $column-count)
            return
                <div style="float:left;width:250px;margin:5px;"> 
                    <ul class="facetmoreul">
                    {
                        for $val in $values[ ( (($x - 1) * $column-size) + 1) to ($x * $column-size) ]
                        let $freq := cts:frequency($val)
                        return
                            if( lp:param-value-contains($params,$id,$val) ) then
                                vf:facet-link-remove($ns, $ln, $id, $params, $val, $freq)
                            else
                                vf:facet-link-add($ns, $ln, $id, $params, $val, $freq)
                    }
                    </ul>
                </div>,
            <div class="break"/>,
            
            if($hasnext) then
                let $link := fn:concat(
                    "/xq/lscoll/parts/moreFacet.xqy?",
                    lp:param-string(lp:param-replace-or-insert($params, "mpg", $morepage + 1)),
                    "&amp;id=",$id
                )
                return
                <div style="width:100%;text-align:center;">
                    <a id="morepaging" rel="{$link}">More Values</a>
                </div>
            else (),
            
            <script type="text/javascript">
            <!--
            $('a',".facetmoreul").click(function(e) {
                var rel = $(this).attr('rel');
                if( rel != null && rel != '') {
                    e.preventDefault();
                    $(document).trigger('close.facybox');
                    $.address.value(rel);
                }
            });
            
            $('a#morepaging','.content').click(function(e) {
            
                e.preventDefault();
                var rel = $(this).attr('rel');
                moreNav(rel);
                
            
            });
            
            
            -->
            
            </script>
        }
    </div>


};

(:  ################# UNUSED ################### :)


(: not currently used in LOC app :)
declare function vf:facet-data-date($params as xs:string*) {
    let $ns := $params[1]
    let $ln := $params[2]
    let $id := $params[3]
    
    let $cur-params := $lp:CUR-PARAMS
    
    let $afterId := concat($id,1)
    let $beforeId := concat($id,2)
    let $ids := ($afterId,$beforeId)
    
    let $afterStr := lp:get-param-single( $cur-params, $afterId )
    let $beforeStr := lp:get-param-single( $cur-params, $beforeId )
    
    let $query := cts:registered-query(cts:register( lq:query-from-params($cur-params)), "unfiltered")
    
    return
    <div>
    
        <div style="width:100%;">
            <table class="fleft">
                <tr>
                    <td>After:</td>
                    <td><div id="dateafter"><input class="datepicker" value="{$afterStr}"/></div></td>
                    <td></td>
                </tr>
                <tr>
                    <td>Before: </td>
                    <td><div id="datebefore"><input class="datepicker" value="{$beforeStr}"/></div></td>
                    <td></td>
                </tr>
            </table>
            <div class="fright" id="button">
            {
                let $new-params := lp:param-apply-facet-page-control($cur-params)
                let $new-params := lp:param-replace-or-insert($new-params, 'pg', '1')
                let $new-params := lp:param-remove-all($new-params, $afterId)
                let $new-params := lp:param-remove-all($new-params, $beforeId)
                let $new-params := lp:param-remove-all($new-params, 'uri')
                let $new-params-str := lp:param-string($new-params)
                return
                <button class="facet-date-submit" id="{$id}" rel="{$new-params-str}" >Select</button>
            }
            </div>
            <br class="break"/>
        </div>
        <hr/>
        <ul>
        {
            if($beforeStr or $afterStr) then
                let $freq := xdmp:estimate ( 
                    cts:search(collection("docs"), cts:and-query((cts:collection-query("docs"),$query))   )
                )
                let $text :=
                    "Current date filter"
                return
                vf:facet-link-remove-all($ns, $ln, $ids, $cur-params, $freq, $text)
            else
                let $current := current-date()
                return
                (
                
                    vf:facet-link-add-multiple($ns, $ln, $afterId, $cur-params, 
                        ld:convert-date-to-picker($current - xs:dayTimeDuration('P1D') ), 
                        "Yesterday"),
                    vf:facet-link-add-multiple($ns, $ln, $afterId, $cur-params, 
                        ld:convert-date-to-picker($current - xs:dayTimeDuration('P7D') ), 
                        "Last Week"),
                    vf:facet-link-add-multiple($ns, $ln, $afterId, $cur-params, 
                        ld:convert-date-to-picker($current - functx:yearMonthDuration(0,1) ), 
                        "Last Month"),
                    
                    let $yearLinks :=    
                        let $year := year-from-date($current)
                        for $y in (  ($year - $cfg:FACET-YEARS-BACK) to $year )   
                        return 
                            vf:facet-link-add-multiple($ns, $ln, ($afterId,$beforeId), $cur-params, 
                                
                                (
                                   concat("01/01/",$y),
                                   concat("12/31/",$y)
                                ), 
                                
                                $y)
                            
                            
                    return
                        reverse($yearLinks)
                )
        }
        </ul>
    </div>
    

};

(: not currently used in LOC app :)
declare function vf:facet-data-multi($params as xs:string*) {
    let $ns := $params[1]
    let $ln := $params[2]
    let $id := $params[3]
    let $cur-params := $lp:CUR-PARAMS
    let $query := lq:get-last-query-without-me($ns,$ln)
    return
        
            let $values := 
                cts:element-values( QName($ns,$ln), (), 
                    ("frequency-order",
                     "fragment-frequency"), 
                     cts:and-query((cts:collection-query($cfg:DEFAULT-COLLECTION),$query)) )
            return
                if(count($values) gt 0) then (
                <ul id="{$id}">
                {
                    for $val in $values
                    let $freq := cts:frequency($val)
                    return
                        <li>
                        {
                            if( lp:param-value-contains($cur-params,$id,$val) ) then
                                <input checked="checked" type="checkbox" value="{$val}" name="{$id}"/>
                            else
                                <input type="checkbox" value="{$val}" name="{$id}"/>,
                            
                            <span>{$val} [{vs:recursiveFormat($freq cast as xs:string)}]</span>
                        }
                        </li>

                }
                </ul>,
                
                
                let $new-params := lp:param-apply-facet-page-control($cur-params)
                let $new-params := lp:param-replace-or-insert($new-params, 'pg', '1')
                let $new-params := lp:param-remove-all($new-params, $id)
                let $new-params := lp:param-remove-all($new-params, 'uri')
                let $new-params-str := lp:param-string($new-params)
                return
                <div style="width:100%;">
                    <div class="fright" id="button">
                        <button class="facet-multi-submit" id="{$id}" rel="{$new-params-str}" >Select</button>
                    </div>
                    <br class="break"/>
                </div>
                    
                
                ) else
                    <span class="noresults">No results.</span>
        
};

(: experiment currently unused to compute facet values concurrently :)
declare function vf:facets-concurrent($page-name as xs:string) {
    <h2 id="section-title">Refine Results</h2>,    
    
    let $facet-elts := $cfg:DISPLAY-ELEMENTS//*:elt[*:page = $page-name]
    let $query := cts:and-query((
                    cts:collection-query($cfg:DEFAULT-COLLECTION),
                    cts:registered-query(cts:register( lq:query-from-params($lp:CUR-PARAMS) ),"unfiltered")
                  ))
    let $facet-map := map:map()
    
    let $_ := vf:facet-data-concurrent($facet-map, $facet-elts,$query)
    
    return
    
    for $key at $fx in fn:reverse(map:keys($facet-map))
    let $elt := $facet-elts[*:facet-id = $key]
    let $view-name := $elt/*:view-name/text()
    let $id := concat("facet-",$fx)
    let $isHidden := ($elt/*:starts-hidden/text() eq "true")
    let $display := if($isHidden) then 'none' else 'block'
    let $char := if($isHidden) then "+" else "-"
    return
       <div class="facet-box">
           <div class="title">
                <span class="title-name">{$view-name}</span>
                <span class="title-toggle">
                    <a id="{$id}" class="hidden">{$char}</a>
                </span>
                <br class="break"/>
            </div>
            <div class="content" id="{$id}" style="display:{$display}">
            {
                        let $facet-values := map:get($facet-map,$key)
                        let $count := fn:count($facet-values)
                        return
                            if($count gt 0) then (
                                for $val in $facet-values
                                let $freq := cts:frequency($val)
                                return
                                    if( lp:param-value-contains($lp:CUR-PARAMS,$id,$val) ) then
                                        vf:facet-link-remove($elt/*:facet-param[1],$elt/*:facet-param[2], $id, $lp:CUR-PARAMS, $val, $freq)
                                    else
                                        vf:facet-link-add($elt/*:facet-param[1],$elt/*:facet-param[2], $id, $lp:CUR-PARAMS, $val, $freq),
                                        
                                if($cfg:FACETS-PER-BOX eq $count) then
                                let $href := fn:concat( 
                                    'javascript:jQuery.facybox(&#123;"ajax":"\/xq\/lscoll\/parts\/moreFacet.xqy?',
                                    lp:param-string($lp:CUR-PARAMS),
                                    '&amp;id=',
                                    $id,
                                    '"&#125;);'
                                
                                )
                                return
                                (
                                    <li class="fright">
                                        <!--a id="{lp:param-string($cur-params)}&amp;id={$id}" class="facet-more small">more ...</a-->
                                        <a 
                                            class="facet-more small" 
                                            href='{$href}'
                                            >more ...</a>
                                    </li>,
                                    <br class="break"/>
                                )
                                else 
                                    ()
                                        
                                        
                            ) else
                                <span class="noresults">No results.</span>
                            
                        }
                        </div>
                    </div>
};

(: experiment currently unused to compute facet values concurrently :)
declare function vf:facet-data-concurrent($facet-map, $facet-elts, $query) {

    let $facet := $facet-elts[1]
    return
            let $key := xs:string($facet/*:facet-id)
            let $num-facets := fn:count($facet-elts)
            let $values := cts:element-values(fn:QName($facet/*:facet-param[1],$facet/*:facet-param[2]),(), 
                                (
                                 "frequency-order",
                                 "descending",
                                 if($num-facets > 1) then "concurrent" else (),
                                 "limit=10",
                                 "collation=http://marklogic.com/collation/codepoint"
                                 ), 
                                 $query
                           )
            return
                (
                    if($num-facets > 1) then vf:facet-data-concurrent($facet-map,fn:subsequence($facet-elts,2),$query) else (),
                    map:put($facet-map,$key,$values)
                )

};