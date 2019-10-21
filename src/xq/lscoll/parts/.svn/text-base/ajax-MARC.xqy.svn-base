xquery version "1.0-ml";

import module namespace metsutils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutils = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace mxe2 = "http://www.loc.gov/mxe";

declare variable $uri as xs:string := xdmp:get-request-field("objid", "");

let $params := map:map()
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
let $marctags := 
    if ($lcdbDisplay instance of element(error:error)) then
        $lcdbDisplay
    else
        ($lcdbDisplay//h1[@id='title-top'], $lcdbDisplay//div[@id='marc-view'])
return
    <div id="render-marctags">
        {$marctags}
    </div>