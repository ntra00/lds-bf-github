xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";

declare namespace httplib = "xdmp:http";

if (contains($cfg:HOST-NAME, "marklogic3")) then
    xdmp:set-response-code(508, "Loop Detected")
else
    let $requri  := substring-after(xdmp:get-request-url(), "uri=")
    let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', "text/html"))
    let $duration := $cfg:HTTP_EXPIRES_CACHE
    let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
    let $reqheaders := xdmp:get-request-header-names()
    let $outheaders :=
        for $rh in $reqheaders
        return
            element {QName("xdmp:http", $rh)} {xdmp:get-request-header($rh)}
    let $staging-host := "http://marklogic3.loc.gov:8210"
    (: For this to work with lib-params, url percent encoding would have to be supported in Varnish :)
    (:let $reqxqy :=
        if (contains($requri, "?")) then
            substring-before($requri, "?")
        else
            $requri
    let $reqparams := 
        if (contains($requri, "?")) then
            concat("?", substring-after($requri, "?"))
        else
            "":)
    let $uri := concat($staging-host, $requri)
    let $opts := 
        <options xmlns="xdmp:http">
            <headers>
                {$outheaders}
                <X-LOC-Environment>Staging</X-LOC-Environment>
            </headers>
        </options>
    let $backend-response-headers := (xdmp:http-get($uri, $opts)[1])
    let $response-body := (xdmp:http-get($uri, $opts)[2])
    return
    (
        xdmp:set-response-code(data($backend-response-headers/httplib:code), string($backend-response-headers/httplib:message)),
        xdmp:add-response-header("Expires", resp:expires($duration)),
        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
        xdmp:add-response-header("Content-Type", string($backend-response-headers/httplib:headers/httplib:content-type)),
        (:commented out because this duplicates the doctype coming out of the ml3 backend:)
        (:$doctype,:)
        $response-body
    )