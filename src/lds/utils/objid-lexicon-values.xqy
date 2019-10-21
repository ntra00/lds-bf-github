xquery version "1.0-ml";

(: This module is used primarily for sitemap making.  It iterates through the @OBJID lexicon 50,000 values at a time, returning the last value.  That value gets fed in as the start value for the next 50,000, etc., until the end. :)
(: Use this to output a to an array, file, etc., for wget or curl to go fetch the values so as to store a generated sitemap for each 50,000 locally to disk via another XQuery. :)

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";

declare variable $term := "";
declare variable $cln as xs:string := lp:get-param-single($lp:CUR-PARAMS, "collection", "/catalog/");
declare variable $mode := lp:get-param-single($lp:CUR-PARAMS, "mode", "create-sitemap-urlset");

declare function local:last-uris($lexstart as xs:string, $max as xs:int) as xs:string* {
    let $vals := cts:element-attribute-values(xs:QName("mets:mets"), QName("", "OBJID"), $lexstart, (concat("limit=", $max), "collation=http://marklogic.com/collation/en/S1", "concurrent"), cts:collection-query($cln), (), ())
    let $lastval := $vals[last()]
    return
        if ($lastval instance of empty-sequence()) then
            ()
        else if ($mode eq "create-sitemap-urlset") then
            (xdmp:set($term, $lastval), concat("http://localhost:8201/nlc/utils/create-sitemap-urlset.xqy?term=", $term))
        else if ($mode eq "delete-lscoll-lcdb-bib") then
            (xdmp:set($term, $lastval), concat("http://localhost:8201/nlc/utils/delete-lscoll-lcdb-bib.xqy?term=", $term))
        else
            "Error, valid mode required"
};

let $maxvals := 
    if ($mode eq "create-sitemap-urlset") then
        50000
    else
        10000
let $est := 
    if ($cln eq "/lscoll/lcdb/bib/") then
        xdmp:estimate(collection("/lscoll/lcdb/bib/"))
    else
        xdmp:estimate(collection("/catalog/"))
let $sitemapcount := ceiling($est div $maxvals)

for $i in (1 to $sitemapcount)
return local:last-uris($term, $maxvals)