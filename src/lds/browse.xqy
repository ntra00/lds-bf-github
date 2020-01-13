xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" 		at "/lds/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" 	at "/lds/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" 	at "/lds/lib/l-param.xqy";
import module namespace vb = "http://www.marklogic.com/ps/view/v-browse" at "/lds/view/v-browse.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/lds/view/v-search.xqy";
import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at "/lds/view/v-facets.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" 			 at "/xq/modules/natlibcat-skin.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" 			 at "/xq/modules/mime-utils.xqy";
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

declare function local:output($msie as xs:boolean, $res as element(div), $facets as element(div)?, $searchterm as xs:string?, $uri as xs:string?, $browseterm as xs:string?, $brfield as xs:string, $qname as xs:string, $dtitle as xs:string?) {

let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()

    let $mime := "application/xhtml+xml"    
    let $browsetitle :=
        if (matches($brfield, "author", "i")) then
            "Browse Name Headings"
        else if (matches($brfield, "subject", "i")) then
            "Browse Subject Headings"
        else if (matches($brfield, "nameTitle", "i")) then
            "Browse Name/Title"
		else if (matches($brfield, "title", "i")) then
            "Browse Title Headings"
        else if (matches($brfield, "class", "i")) then
            "Browse LC Classification"
		else if (matches($brfield, "loaddate", "i")) then
            "Browse Date Ingested"
		else if (matches($brfield, "date", "i")) then
            "Browse Date Modified"
		else if (matches($brfield, "lccn", "i")) then
            "Browse LCCN"
       
        else if ($dtitle) then
            $dtitle
        else
            ("Browse ", $brfield)
    let $atom := ()
    let $seo := ()
    let $crumbs := 
    (
        let $searchtitle := 
            if ($searchterm) then
                "Search Results"
            else
                "Search"
        return
            if ($searchterm or $qname) then
                let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'index')
                let $new-params := lp:param-remove-all($new-params, 'uri')
                let $new-params := lp:param-remove-all($new-params, 'bq')
                let $new-params := lp:param-remove-all($new-params, 'browse-order')
                let $new-params := lp:param-remove-all($new-params, 'browse')
                return
                    <span>
                        <a href="{$url-prefix}search.xqy?{lp:param-string($new-params)}">{$searchtitle}</a>
                    </span>
            else 
                () (: No search terms means we came here from home page :),        
            if ($uri) then
                let $title := "Record View"
                let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'bq')
                let $new-params := lp:param-remove-all($new-params, 'browse-order')
                let $new-params := lp:param-remove-all($new-params, 'browse')
				let $new-params := lp:param-remove-all($new-params, 'category')
                let $new-params := lp:param-remove-all($new-params, 'dtitle')
                return
                    <span>
                        <a href="{$url-prefix}detail.xqy?{lp:param-string($new-params)}">{$title}</a>
                    </span>
            else
                (),            
            <span class="ds-searchresultcrumb">{$browsetitle}</span>
			
    )
	(:last 2 parms are uri and objectype:)
    let $myhead := ssk:header($browsetitle, $crumbs, $msie, $atom, $seo,"","browse")
    let $myfooter := ssk:footer()
    let $leftcol :=
        if ($facets instance of empty-sequence()) then
            $facets
        else
            <div id="ds-leftcol">
                <div id="ds-facets">
                    {$facets}
                    <!-- end id:ds-facets -->
                </div>
                <!-- end id:ds-leftcol -->
            </div>
    let $searchbar :=
        <div id="search-results">
            {vs:render()}
        </div>
    return
        <html xmlns="http://www.w3.org/1999/xhtml">
            {$myhead/head}
            <body>
                {$myhead/body/div}
                <div id="ds-container">
                    <div id="ds-body">
                        {$searchbar}
                        {$res}
                    </div>
                    {$leftcol}
                <!-- end id:ds-container -->
                </div>
                {$myfooter/div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
};

let $page := "browse"
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $collection := $cfg:MY-SITE/cfg:collection/string()
let $browsefield as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'browse', 'subject')
let $browsedirection as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'browse-order', 'descending')
let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q', ())
(: bf mergedworks, etc:)
let $category as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'category', ())
let $detail-uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'uri', ())
let $filter as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'filter', "works")
let $browseterm as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'bq', 'A')
let $qname := lp:get-param-single($lp:CUR-PARAMS, 'qname', "keyword")
let $dtitle := lp:get-param-single($lp:CUR-PARAMS, 'dtitle', $detail-uri)
let $query := lq:query-from-params($lp:CUR-PARAMS) 
(:let $_ := xdmp:log(concat("query: ", xdmp:describe($query)),'info'):)

let $results := lq:browse-lexicons($browseterm, $browsefield, $browsedirection, $collection, $filter)

let $facets :=
    if (exists($cfg:DISPLAY-ELEMENTS//*:elt/*:page[text() = $page])) then
        <div id="facet-results">{vf:facets($page)}</div>
    else
        ()

let $browses := <div id="results">{vb:render($results, $browsefield, $browsedirection)}</div>
(:'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">', :)
return
    (
        xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
        '<!DOCTYPE html>',
        local:output(false(), $browses, $facets, $term, $detail-uri, $browseterm, $browsefield, $qname, $dtitle)
    )(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)