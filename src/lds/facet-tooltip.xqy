xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config"		 at "/lds/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query"	 at "/lds/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param"	 at "/lds/lib/l-param.xqy";
import module namespace vb = "http://www.marklogic.com/ps/view/v-browse" at "/lds/view/v-browse.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/lds/view/v-search.xqy";
import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at /"lds/view/v-facets.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin"			 at "/xq/modules/natlibcat-skin.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" 			at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
declare namespace qm="http://marklogic.com/xdmp/query-meters";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mxe1 = "mxens";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $facetfield as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'facet')
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $config := $cfg:DISPLAY-ELEMENTS
let $facet := replace($facetfield, ".+(\d+)$", "$1")
let $facetint := $facet cast as xs:int
let $descr := string($config/*:elt[$facetint]/*:description)
let $longdesc := $config/*:elt[$facetint]/*:longdesc/div
let $select :=
    if (matches(string($config/*:elt[$facetint]/*:facet-operation), "or", "i")) then
        <strong>Select one or more values</strong>
    else if (matches(string($config/*:elt[$facetint]/*:facet-operation), "and", "i")) then
        <strong>Select one value</strong>
    else
        <strong>{$facet}</strong>
return
    (
        xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
        $longdesc
    )(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)