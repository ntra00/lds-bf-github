xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: search specific :)
(:declare variable $query as xs:string := xdmp:get-request-field("q", "hello world");
declare variable $howMany as xs:string := xdmp:get-request-field("count", "10");
declare variable $page as xs:string := xdmp:get-request-field("page", "1");
declare variable $facets as xs:string := xdmp:get-request-field("facets", "true");
declare variable $collection as xs:string := xdmp:get-request-field("collection", "all");
declare variable $sortOrder as xs:string := xdmp:get-request-field("sort", "score-desc");
declare variable $digitized as xs:string := xdmp:get-request-field("digitized", "false");
declare variable $global-request as xs:string := xdmp:get-request-url();:)

(: page specific :)
(:declare variable $mime as xs:string := xdmp:get-request-field("mime", "application/xhtml+xml");
declare variable $look as xs:string := xdmp:get-request-field("look", "default");
declare variable $label as xs:string := xdmp:get-request-field("label", "Search Results");
declare variable $view as xs:string := xdmp:get-request-field("view", "text");:)

let $param-string := substring-after(xdmp:get-request-url(), "?")
let $redirect := 
    if($param-string) then
        concat("/xq/lscoll/app.xqy#", $param-string)
    else
        "/xq/lscoll/app.xqy#/page=search&amp;pg=1&amp;mime=text/html&amp;sort=score-desc&amp;collection=all&amp;count=10&amp;qname=keyword"
return
    xdmp:redirect-response($redirect)