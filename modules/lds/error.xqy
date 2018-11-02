xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/lds/view/v-search.xqy";
import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at "/lds/view/v-facets.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
declare namespace qm = "http://marklogic.com/xdmp/query-meters";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare variable $error:errors as node()* external;

declare function local:output($facets as element(div)?) as element(html) {
    let $mime := "application/xhtml+xml"
    let $response-code := xdmp:get-response-code()
    let $errortitle := concat("Error: ", string-join(($response-code[1] cast as xs:string, $response-code[2]), " "))
    let $atom := ()
    let $seo := ()
    let $crumbs := <span>{$errortitle}</span> 
    let $myhead := ssk:header($errortitle, $crumbs, false(), $atom, $seo,"","error")
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
    let $myerror :=
        if ($error:errors instance of element(error:error)) then
            <pre>{$error:errors}</pre>
        else
            ()
    return
        <html xmlns="http://www.w3.org/1999/xhtml">
            {$myhead/head}
            <body>
                {$myhead/body/div}
                <div id="ds-container">
                    <div id="ds-body">
                        {$searchbar}
                        <div style="margin-left: 20px;">
                            <h1>{$errortitle}</h1>
                            <p>Please contact a system administrator at <a href="{concat("mailto:", $cfg:ADMIN-EMAIL)}">{$cfg:ADMIN-EMAIL}</a> if the problem persists.</p>
                            {$myerror}
                        </div>
                    </div>
                    {$leftcol}
                <!-- end id:ds-container -->
                </div>
                {$myfooter/div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
};

let $page := "error"

let $facets :=
    if (exists($cfg:DISPLAY-ELEMENTS//*:elt/*:page[text() = $page])) then
        <div id="facet-results">{vf:facets($page)}</div>
    else
        ()
 
return
    (
        xdmp:set-response-content-type("text/html; charset=utf-8"), 
        xdmp:add-response-header("X-LOC-MLNode", replace(xdmp:host-name(xdmp:host()), "[^\d]", "")),
        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">', 
        local:output($facets)
    )