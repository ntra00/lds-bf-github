xquery version "1.0-ml";

import module namespace utils = "info:lc/xq-modules/kml-utils" at "/xq/modules/kml-utils.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace mu = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare default element namespace "http://www.opengis.net/kml/2.2";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $objid as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "svcid");
declare variable $inmime := lp:get-param-single($lp:CUR-PARAMS, "mime", "application/vnd.google-earth.kml+xml");

let $mime := mime:safe-mime($inmime)
let $kml := utils:kml-from-mets($objid, $mime)
return
    if ($kml instance of element(error:error) and $kml/@code) then
        (xdmp:set-response-code(data($kml/@code), "Internal Server Error"), xdmp:set-response-content-type($mime), $kml)
    else if ($kml instance of element(error:error)) then
        (xdmp:set-response-code(404, "Not Found"), xdmp:set-response-content-type($mime), $kml)
    else
        (xdmp:set-response-content-type($mime), $kml)