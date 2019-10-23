xquery version "1.0-ml";

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" 	at "../lib/l-param.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "../view/v-search.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" 		at "../config.xqy";
import module namespace metsutils = "info:lc/xq-modules/mets-utils" 	at "../../xq/modules/mets-utils.xqy";
import module namespace marcutils = "info:lc/xq-modules/marc-utils" 	at "../../xq/modules/marc-utils.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" 			at "../../xq/modules/natlibcat-skin.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "../../xq/modules/http-response-utils.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" 			at "../../xq/modules/mime-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace mxe2 = "http://www.loc.gov/mxe";

declare variable $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "objid");
declare variable $view as xs:string := lp:get-param-single($lp:CUR-PARAMS, "view", "ajax");

declare function local:output($msie as xs:boolean, $marc as element()+, $mime as xs:string) as element(html) {
    let $title := string($marc[1])
    let $refer := xdmp:get-request-header("Referer")
    let $isNLC := 
        if (contains($refer, "/nlc/detail.xqy")) then
            <a href="{$refer}">{$title}</a>
        else
            ()
    let $atom := ()
    let $searchterm :=  lp:get-param-single($lp:CUR-PARAMS, 'q')
    let $searchtitle := 
        if ($searchterm) then
            concat("Search results for: ", $searchterm)
        else
            "Search"
            
            
    let $myq := concat("Librarian View: ", $title)
    let $seo := ()
    let $crumbs := 
        (
            let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'id')
            let $new-params := lp:param-remove-all($new-params, 'view')
            let $new-params := lp:param-remove-all($new-params, 'uri')
            let $new-params := lp:param-remove-all($new-params, 'objid')
            let $new-params := lp:param-remove-all($new-params, 'index')
            return
            <span id="ds-searchresultcrumb"><a href="/nlc/search.xqy?{lp:param-string($new-params)}">{$searchtitle}</a></span>,
            <span>{$myq}</span>
        )
    let $myhead := ssk:header($myq, $crumbs, $msie, $atom, $seo)
    let $myfooter := ssk:footer()
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
                        <div style="margin-left: 15px;">{$marc[1]}</div>
                        <div style="margin-left: 15px; width: 80%;">{$marc[2]}</div>
                    </div>                    
                <!-- end id:ds-container -->
                </div>
                {$myfooter/div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
};

let $params := map:map()
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $put := map:put($params, "view", "marctags")
let $displayXsl := "/xslt/displayLcdb.xsl"
let $mets := metsutils:mets($uri)
let $mxe := $mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record
let $marcxml := marcutils:mxe2-to-marcslim($mxe)
let $lcdbDisplay :=
    try { 
        xdmp:xslt-invoke($displayXsl, document{$marcxml}, $params)
    } catch ($e) {
        (xdmp:log($e, "error"), $e)
    }
let $displaySeq := ($lcdbDisplay//h1[@id='title-top'], $lcdbDisplay//div[@id='marc-view'])
return 
    if ($lcdbDisplay instance of element(error:error)) then
        $lcdbDisplay
    else
        (
            xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),  
            if ($view eq "ajax") then
                <div id="render-marctags">
                    {$displaySeq}
                </div>
            else
                '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">', 
                local:output(false(), $displaySeq, $mime)
        )(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)