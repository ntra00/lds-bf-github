xquery version "1.0-ml";

declare namespace dir = "http://marklogic.com/xdmp/directory";
declare default element namespace "http://www.sitemaps.org/schemas/sitemap/0.9";

let $sitemap :=
    <sitemapindex xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd">
    {
        let $dirxml := xdmp:filesystem-directory("/marklogic/sitemaps/")
        for $file in $dirxml/dir:entry
        let $fn := $file/dir:filename/string()
        where matches($fn, "xml\.gz$")
        return
            <sitemap>
                <loc>{concat('http://loccatalog.loc.gov/sitemaps/', $fn)}</loc>
                <lastmod>{data($file/dir:last-modified)}</lastmod>
            </sitemap>
    }
    </sitemapindex>
return
    xdmp:save("/marklogic/sitemaps/sitemap.xml", text {'<?xml version="1.0" encoding="UTF-8"?>&#x000A;',xdmp:quote($sitemap)})