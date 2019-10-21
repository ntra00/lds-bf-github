xquery version "1.0-ml";

import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace vp = "http://www.marklogic.com/ps/view/v-page" at "/xq/lscoll/view/v-page.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

let $mymime as xs:string? := lp:get-param-single($lp:CUR-PARAMS,'mime')
let $page-name as xs:string? := lp:get-param-single($lp:CUR-PARAMS, '/page')
let $requestedMime := mime:safe-mime($mymime)

let $mainblock := 
    <div id="ds-body">
        <!-- main body -->
    </div>

let $facetblock :=
    <div id="ds-leftcol">
        <div id="ds-facets">
            <!-- end id:ds-facets -->
        </div>
    <!-- end id:ds-leftcol -->
    </div>

return
    (
        xdmp:set-response-content-type("text/html; charset=utf-8"), 
        xdmp:add-response-header("X-LOC-MLNode", replace(xdmp:host-name(xdmp:host()), "[^\d]", "")),
        xdmp:add-response-header("Cache-Control", "public, max-age=600"), 
        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">', 
        vp:output(vp:three-area($mainblock, $facetblock))
    )