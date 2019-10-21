xquery version "1.0-ml";

(: This module is used primarily for sitemap making.  A shell script that has known last values (the 50,000th value) from individual lexicon calls that return 50,000 values at a time.  That value gets fed in as the start value for the next 50,000, etc., until the end. :)
(: Use this to output a to an XML file...the sitemap itself. :)

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace mu = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
declare default element namespace "http://www.sitemaps.org/schemas/sitemap/0.9";

declare variable $maxvals := 50000;
declare variable $term := lp:get-param-single($lp:CUR-PARAMS, "term", "");

declare function local:sitemap($lexstart as xs:string) as empty-sequence() {
    let $vals := cts:element-attribute-values(xs:QName("mets:mets"), QName("", "OBJID"), $lexstart, (concat("limit=", $maxvals), "collation=http://marklogic.com/collation/en/S1", "concurrent"), cts:collection-query("/catalog/"), (), ())
    let $urls :=
        for $objid in $vals
        let $mets := mu:mets($objid)[1]
        return
            if ($mets instance of element(mets:mets)) then
                <url>
                    <loc>{concat("http://loccatalog.loc.gov/", $objid, ".html")}</loc>
                    <lastmod>{data($mets/mets:metsHdr/@LASTMODDATE)}</lastmod>
                    <changefreq>yearly</changefreq>
                    <priority>0.8</priority>
                </url>
            else
                ()
    return
        if (count($urls) gt 0) then
            let $lexfile :=
                if (string-length($lexstart) eq 0) then
                    "loc.natlib.lcdb.start"
                else
                    $lexstart
            return
                xdmp:save(concat("/marklogic/sitemaps/", $lexfile, ".xml"), text {'<?xml version="1.0" encoding="UTF-8"?>&#x000A;',xdmp:quote(<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">{$urls}</urlset>)})
        else
            ()
};

local:sitemap($term)