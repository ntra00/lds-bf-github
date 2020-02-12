xquery version "1.0-ml";

import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace json-utils = "info:lc/xq-modules/json-utils" at "/xq/modules/json-utils.xqy";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace http = "xdmp:http";
declare namespace json = "http://json.org/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace mets = "http://www.loc.gov/METS/";

declare default collation "http://marklogic.com/collation/en/S1";

declare variable $query as xs:string := xdmp:get-request-field("q", "Apples");
declare variable $howMany as xs:string := xdmp:get-request-field("count", "25");
declare variable $direction as xs:string := xdmp:get-request-field("order", "ascending");
declare variable $mime as xs:string := xdmp:get-request-field("mime", "application/xhtml+xml");

declare function local:lexicon-entries-xml($terms as xs:string+) as element(html) {
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>Lexicons entries</title>
        </head>
        <body>
            <dl>
            {
                for $term in $terms
                let $tmpxml := <wrap>{cts:search(/mets:mets/mets:dmdSec[@ID='IDX1']/mets:mdWrap/mets:xmlData/idx:indexTerms/idx:display, cts:element-value-query(xs:QName("idx:mainCreator"), $term))}</wrap>
                let $freq := count($tmpxml/idx:display)
                let $uri := "#"
                return (
                    <dt>{$term}</dt>,
                    <dd>
                        <ul>
                            <li id="search-uri">{$uri}</li>
                            <li id="frequency">{$freq}</li>
                        </ul>
                    </dd>
                )
            }
            </dl>
        </body>
    </html>
};

declare function local:make-hits($terms as xs:string*) as element(ul) {
    <ul>
    {
            for $term in $terms
            let $tmpxml := <wrap>{cts:search(/mets:mets/mets:dmdSec[@ID='IDX1']/mets:mdWrap/mets:xmlData/idx:indexTerms/idx:display, cts:element-value-query(xs:QName("idx:mainCreator"), $term))}</wrap>
            let $freq := count($tmpxml/idx:display)
            let $uri := "#"
            let $val := distinct-values($tmpxml/idx:display/idx:mainCreator[text() ne ""])[1]
            return
                if ($freq gt 0) then
                    <li>
                        <a href="{$uri}">{$val}</a>
                        <span style="margin-left: 5px;">[{$freq}]</span>
                    </li>
                else
                    ()
    }
    </ul>
};

declare function local:browse-nav($first as xs:string, $last as xs:string) as element(div) {
    <div>
    {
        let $join := " | "
        let $prev := <a href="{concat('/xq/prefLabelBrowse.xqy?q=', $first, '&amp;order=descending')}">Previous</a>
        let $next := <a href="{concat('/xq/prefLabelBrowse.xqy?q=', $last, '&amp;order=ascending')}">Next</a>
        return <span>{$prev, $join, $next}</span>
    }
    </div>
};

let $limit := concat("limit=", $howMany)
let $checked := "checked"
let $order := $direction
let $opts := ($limit, $checked, $order)
let $seq := cts:element-values(xs:QName("idx:mainCreator"), $query, $opts)
let $values :=
    if ($order eq "descending") then
        reverse($seq)
    else
        $seq

let $requestedMime := mime:safe-mime($mime)
return
    if (matches($requestedMime, "(application/xhtml\+xml|text/html)")) then
        let $hits := local:make-hits($values)
        let $first := $hits/li[1]/a/text()
        let $last := $hits/li[last()]/a/text()
        let $nav := local:browse-nav($first, $last)
        return <div>{($nav, $hits, $nav)}</div>
    else if ($requestedMime eq "application/json") then
        (:json-utils:xml-to-json(local:uris-from-lexicon-entries($values)):)
         "json"
    else if (matches($requestedMime, "(application/x-lcsearchresults\+xml|text/xml|application/xml)")) then
        local:lexicon-entries-xml($values)
    else if (matches($requestedMime, "text/plain")) then
        $values
    else
        "You must specify a mime-type for serialization"(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)