xquery version "1.0-ml";
(: 
 2011/11/03
 	This is the holdings display extracted from displayLcdb.xsl, 
    so we can call it independently in ajaxy functions, or from the std display.
    display of the browse to lcclass based on holdings will be converted to idx:lcclass, so we
    don't need to open holdings for that.
    The holdings-utils module function hold:display($uri) can be called by xslt (displayLcdb.xsl, for example)
    

:)
declare namespace marc="http://www.loc.gov/MARC21/slim" ;
declare namespace mets="http://www.loc.gov/METS/";

import module namespace hold = "info:lc/xq-modules/holdings-utils" at "../../xq/modules/holdings-utils.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "../config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "../lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "../../xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "../../xq/modules/http-response-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
    
let $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "uri")
let $bibid:=tokenize($uri,"\.")[last()]
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, "mime", "text/html"))
let $status as xs:string :=lp:get-param-single($lp:CUR-PARAMS, "status", "no" )

let $duration := $cfg:HTTP_EXPIRES_CACHE

return
 	(
                xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
                xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                if (matches($mime, "text/html")) then 
				'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
					else ()
				,
                 hold:display($uri, $status)
                 			
            )  
            
           (: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)