xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/nlc/view/v-search.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
(: This could be merged back into v-detail if the timelines become true digital objects.
For now, this is just to see how simile works in marklogic because the JS is hardcoded to load a specific file. :)
declare function local:html() {
    let $htmltitle := "Timeline"
    let $crumbs := <span class="ds-searchresultcrumb">Timeline View</span>
    let $head := ssk:header($htmltitle, $crumbs, false(), (), (), '', 'timeline')
    let $maindiv := (<div style="margin: 10px"><h2>Song of America Timeline</h2></div>,
                    <div id="my-timeline" style="height: 650px; border: 1px solid #aaa; margin: 10px"></div>,
                    <noscript>Please enable Javascript.</noscript>)
    
    return 
    <html xmlns="http://www.w3.org/1999/xhtml">
            {$head/head}
            <body onload="onLoad();" onresize="onResize();">
                {$head/body/div}                              
                <div id="ds-container">
                    <div id="ds-body">
                        <div id="search-results">
                            {vs:render()}
                        </div>
                        <div id="dsresults">
                            {$maindiv}
                        </div>
                    </div>
                <!-- end id:ds-container -->
                </div>            
                {ssk:footer()/div}
            </body>
        </html>
};

let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $duration := $cfg:HTTP_EXPIRES_CACHE
return
        (
            xdmp:set-response-content-type("text/html; charset=utf-8"), 
            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
            xdmp:add-response-header("Expires", resp:expires($duration)),
            $doctype, 
            local:html()
        )