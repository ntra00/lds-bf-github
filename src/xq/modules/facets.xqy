xquery version "1.0-ml";

module namespace fac = "info:lc/xq-modules/facets";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";

declare default collation "http://marklogic.com/collation/en/S1";

(: This function assumes the search has been done elsewhere, and that the search:facet elements are being passed in :)

declare function fac:hardwired($facets as element(search:facet)*, $qparam as xs:string, $fieldparam as xs:string) as element(div) {
    <div id="facets-accordion">
    {
        for $facet in $facets
        let $facetname := $facet/@name/string()
        let $idattr := concat('facet-', lower-case(replace($facetname, '\s+', '', 'mi')))
        let $list := 
            for $li in $facet/search:facet-value
            let $qencoded := concat("q=", encode-for-uri(concat($qparam, " ", $facetname, ":&quot;", $li/@name/string(), "&quot;")))
            let $fieldencoded := concat("field=", encode-for-uri($fieldparam))
            let $url := concat("/marklogic/search.xqy?", $qencoded, "&amp;", $fieldencoded)
            return
                <li>
                    <span>
                        <a href="{$url}">{string($li)}</a>&nbsp;
                    </span>
                    <span>{$li/@count/string()}</span>
                </li>
        return
            (
                <h3>
                    <a style="font-size: 12px; text-align: left; margin-left: -20px;" href="#">{$facetname}</a>
                </h3>, 
                <ul id="{$idattr}">{$list}</ul>
            )
    }
    </div>
};

declare function fac:ajax() as empty-sequence() {
    ()
};

(: This will do a search and only return the facets :)
declare function fac:get-facets($query as xs:string, $longstart as xs:unsignedLong, $longcount as xs:unsignedLong) {
    let $search_config := xdmp:document-get("/marklogic/lcdemo/marklogic/searchConfig.xml")
    let $search_options := $search_config/search:wrapper/search:facets-logic/search:options
    return search:search($query, $search_options, $longstart, $longcount)
};