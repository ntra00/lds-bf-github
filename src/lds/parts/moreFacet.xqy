xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/lds/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at "/lds/view/v-facets.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/lds/view/v-search.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function local:output($msie as xs:boolean, $facets as element(div)+, $id as xs:string, $mime as xs:string) as element(html) {
    let $refer := xdmp:get-request-header("Referer")            
    let $searchterm as xs:string? :=  lp:get-param-single($lp:CUR-PARAMS, 'q')
    let $searchtitle := "Search results"
    let $atom := ()
    let $seo := ()
    let $title := $cfg:DISPLAY-ELEMENTS//*:elt[*:facet-id eq $id]/*:view-name/text()
    let $myq := concat("More ", $title)
    let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'id')
    let $new-params := lp:param-remove-all($new-params, 'view')
    let $new-params := lp:param-remove-all($new-params, 'mps')
    let $new-params := lp:param-remove-all($new-params, 'mpg')
	let $new-params := lp:param-remove-all($new-params, 'branding')
	 let $new-params := lp:param-replace-or-insert($new-params, 'behavior', 'bfview')
    let $crumbs := 
        (
            <span id="ds-searchresultcrumb"><a href="/lds/search.xqy?{lp:param-string($new-params)}">{$searchtitle}</a></span>,
            <span>{$myq}</span>
        )
    let $myhead := ssk:header($myq, $crumbs, $msie, $atom, $seo,"","")
	
    let $myfooter := ssk:footer()
    let $searchbar :=
        <div id="search-results">
            {vs:render()}
        </div>
    let $elt := $cfg:DISPLAY-ELEMENTS//*:elt[*:facet-id eq $id]
    let $name := $elt/*:view-name/text()
    return
        <html xmlns="http://www.w3.org/1999/xhtml">
            {$myhead/head}
            <body>
                {$myhead/body/div}
                <div id="ds-container">
                    <div id="ds-body">
                        {$searchbar}
                        <div id="facetmorediv">
                            <h1>More {concat($name, 's')}</h1>
                            <div id="ds-bibrecord-nav">
                                <ul class="bibrecord-nav">
                                    <li>
                                        <a id="backtoresults" class="back" href="/lds/search.xqy?{lp:param-string($new-params)}">Back to results</a>
                                    </li>
                                </ul>
                            <!-- end id:ds-bibrecord-nav -->
                            </div>
                            {$facets}
                        <!-- end id:facetmorediv -->
                        </div>
                    </div>                    
                <!-- end id:ds-container -->
                </div>
                {$myfooter/div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
};

let $params := $lp:CUR-PARAMS
let $id as xs:string? := lp:get-param-single($params, 'id')
let $view := lp:get-param-single($params, 'view', 'ajax')
let $params := lp:param-remove-all($params, 'id')
let $facets := 
    try { 
        vf:facet-data-more($params, $id)
    } catch ($e) {
        (xdmp:log($e, "error"), $e)
    }
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
return
    if ($facets instance of element(error:error)) then
        (xdmp:set-response-code(400, "Bad Request"), $facets)
    else
        (
            xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
            if ($view eq "ajax") then
                $facets
            else
                '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">', 
                local:output(false(), $facets, $id, $mime)
        )