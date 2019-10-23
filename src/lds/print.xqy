xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace md = "http://www.marklogic.com/ps/model/m-doc" at "/lds/model/m-doc.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace utils= "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

let $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "uri")
let $behavior as xs:string := lp:get-param-single($lp:CUR-PARAMS, "behavior", "bfview")
let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $hostname :=  $cfg:DISPLAY-SUBDOMAIN
let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $rsp := 
    if ($uri) then
		if  (matches($uri,("lcdb","africasets")  ))  then
        	md:lcrenderBib(document{utils:mets($uri)}, $uri)
		else
		(: nate added this to allow printing digital... not fully tested; render digital expects $result mets, not a string uri:)
			let $result:=document{utils:mets($uri)}
        	return md:renderDigital($result)
    else
        "You must provide a valid METS object ID in order to display content for printing."
return
    if ($rsp instance of element(div)) then
	(: for digital, ds-bibrecord is further down, so you need rsp//div instead of rsp/div :)
        let $record := $rsp//div[starts-with(@id,"ds-bibrecord")]
        let $title := $rsp//h1[@id='title-top']/string()
        let $dl-style :=
            if ($behavior eq 'default') then
                "print-default"
            else
                "print-marctags"
		let $bookmark:=
			if ($rsp/div[@id="ds-bibviews"]//span[@id="print-permalink"]) then
				$rsp/div[@id="ds-bibviews"]//span[@id="print-permalink"]
			else
					<span id="print-permalink" class="white-space">
					<a href="{concat($url-prefix,$uri)}">{$uri}</a>						
					</span>			

        let $html :=
            <html>
              <head>
                <title>{concat("Print view: ", $title)}</title>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <style media="screen,print" type="text/css">@import url("/static/lds/css/printFullRecord.css");</style>
              </head>
              <body onload="javascript:window.print();">
                <div>
                    <img src="/static/lds/images/lc-logo-forprint.jpg" class="logo" alt="The Library of Congress" />
                </div>				
                <div id="ds-bibrecord">{$record/*[local-name(.) ne 'img']}</div>
                <dl class="{$dl-style}">
                    <dt class="label">Bookmark URL:</dt>
                    <dd class="bibdata">{$bookmark}</dd>				
                </dl>
                <div id="printFooter">
                  <p>
                    Library of Congress<br/>
                    101 Independence Ave., SE<br/>
                    Washington, DC 20540
                    </p>
                  <p>Questions? Ask a Librarian:<br/><a href="http://www.loc.gov/rr/askalib/ask-digital.html">http://www.loc.gov/rr/askalib/ask-digital.html</a></p>
                </div>
              </body>
            </html>
        return
            (   xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
                xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                $doctype,
                $html
            )
    else
        (
            xdmp:set-response-code(400,"Bad Request"),
            <html>
                <head>
                    <title>Error</title>
                </head>
                <body>
                    <div>{$rsp}</div>
                </body>
            </html>
        )(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)