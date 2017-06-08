xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/lds/view/v-search.xqy";
import module namespace vd = "http://www.marklogic.com/ps/view/v-detail" at "/lds/view/v-detail.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
declare namespace bf            	= "http://bibframe.org/vocab/";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function local:output($msie as xs:boolean, $seo as element(meta)+, $maindiv as element(div),  $uri as xs:string?, $mime as xs:string) as element(html) {
    let $detailtitle := "Record View"
    let $htmltitle := if ($maindiv//h1/span[@property="bf:authorizedAccessPoint"])then
                        fn:string($maindiv//h1/span[@property="bf:authorizedAccessPoint"])
                        else
                        string-join($maindiv//h1[@id eq 'title-top']//text(), " ")
    let $objectType := ($maindiv//span[@id="objectType"]/string())[1]
    
    let $branding:=$cfg:MY-SITE/cfg:branding/string()
    let $collection:=$cfg:MY-SITE/cfg:collection/string()
    let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()

    let $searchtitle := "Search results"           
    let $crumbs := 
        (
            let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'index')
            let $new-params := lp:param-remove-all($new-params, 'uri')
            let $new-params := lp:param-remove-all($new-params, "branding")
            let $new-params := lp:param-remove-all($new-params, "collection")
    
            return
                <span><a href="{$url-prefix}search.xqy?{lp:param-string($new-params)}">{$searchtitle}</a></span>,
                <span class="ds-searchresultcrumb">{$detailtitle}</span>
        )
    let $atom := ()
    
     let $myhead := 
            (:if ($maindiv//h1/span[@property="bf:authorizedAccessPoint"]) then bibframe! :)
			if ($maindiv//h1/span[contains(@property,'authoritativeLabel')]) then
			
                 <header>{ssk:default-header($htmltitle,$uri, $htmltitle,$url-prefix)}</header>         
            else
                ssk:header($htmltitle, $crumbs, $msie, $atom, $seo, $uri, $objectType)
    let $searchbar :=
        <div id="search-results">
            {vs:render()}
        </div>
	let $dev-div:=	if ( contains($cfg:DISPLAY-SUBDOMAIN,"mlvlp04") and (not( xdmp:get-request-header('X-LOC-Environment')) or  xdmp:get-request-header('X-LOC-Environment')!='Staging' )) then
						<div class="top" style="background-color:#e0ffff;color=white; width=100%;text-align:center;font-size:120%;"><strong>Development Site</strong></div>
					else
					()
				(:and xdmp:get-request-header('X-LOC-Environment')!='Staging':)
    return   
        <html xmlns="http://www.w3.org/1999/xhtml">
            {$myhead/child::*[1]}
            <body>{$dev-div} 
                {$myhead/body/div}                              
                <div id="ds-container">
                    <div id="ds-body">
                        {$searchbar}
                        <div id="dsresults">
                            {$maindiv}
                        </div>
                    </div>
                <!-- end id:ds-container -->
                </div>
                {if (matches( $objectType,("bibRecord","modsBibRecord"))) then                  
                        ssk:feedback-link(false() )                 
                 else ()
                }                
                {ssk:footer()/div}{$dev-div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
};

(: input parameters :)

let $page := "detail"
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
(:let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q'):)

let $detail-result := vd:render('')

(:let $seo := $detail-result[1]:)
let $seo:=<meta>{$detail-result//*:metatags}</meta>

let $maindiv := $detail-result[2] (: html div or error:error :)
(: this has not been reliably the right uri , so start using the hidden span tag in the main div 
let $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'uri'):)
let $uri as xs:string? := $maindiv//span[@id="detailURL"]/string()


return
    if ($maindiv instance of element(error:error) ) then    
    (
        xdmp:set-response-code(500, $maindiv//error:message[1]/string()),      
        $maindiv
    )
    else
    (
        xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),        
        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
        $doctype,               
        local:output(false(), $seo, $maindiv,  $uri, $mime)
    )