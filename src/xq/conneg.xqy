xquery version "1.0-ml";

import module namespace utils= "info:lc/xq-modules/mets-utils" at "modules/mets-utils.xqy";
declare variable $uri := xdmp:get-request-field("_uri", ());
declare variable $mime := xdmp:get-request-field("_mime", "text/html");
declare variable $lang := xdmp:get-request-field("_language", "en");
declare variable $charset := xdmp:get-request-field("_charset", "UTF-8");
declare variable $encoding := xdmp:get-request-field("_encoding", "*");

let $logic := utils:mets($uri)
return (xdmp:add-response-header("Vary", "Accept"), $logic)
