xquery version "1.0-ml";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace sc = "info:lc/xq-modules/search-config" at "/xq/modules/searchConfig.xqy";
(:import module namespace fac = "info:lc/xq-modules/facets" at "modules/facets.xqy";:)
(:import module namespace sr = "info:lc/xq-modules/searchresults-utils" at "modules/searchresults-utils.xqy";:)
(:import module namespace eadutils = "info:lc/xq-modules/ead-utils" at "modules/ead-utils.xqy";
import module namespace altoutils = "info:lc/xq-modules/alto-utils" at "modules/alto-utils.xqy";:)
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xqmodules/mime-utils.xqy";
import module namespace sru = "info:lc/xq-modules/sru" at "/xq/modules/sru.xqy";
import module namespace pg = "info:lc/xq-modules/pagination" at "/xq/modules/pagination.xqy";
(: import module namespace jsonutils = "info:lc/xq-modules/json-utils" at "modules/json-utils.xqy"; :)
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mxe2 = "http://www.loc.gov/mxe";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace alto = "http://schema.ccs-gmbh.com/ALTO";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace simpledc = "http://purl.org/dc/elements/1.1/";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace static = "info:lc/xq/static";

declare default collation "http://marklogic.com/collation/en/S1";

declare variable $query as xs:string := xdmp:get-request-field("q", "hello world");
declare variable $howMany as xs:string := xdmp:get-request-field("count", "10");
declare variable $page as xs:string := xdmp:get-request-field("page", "1");
declare variable $facets as xs:string := xdmp:get-request-field("facets", "true");
declare variable $collection as xs:string := xdmp:get-request-field("collection", "all");
declare variable $mime as xs:string := xdmp:get-request-field("mime", "application/xhtml+xml");
declare variable $look as xs:string := xdmp:get-request-field("look", "default");
declare variable $label as xs:string := xdmp:get-request-field("label", "Search Results");
declare variable $view as xs:string := xdmp:get-request-field("view", "text");
declare variable $sortOrder as xs:string := xdmp:get-request-field("sort", "score-desc");
declare variable $digitized as xs:string := xdmp:get-request-field("digitized", "false");
declare variable $global-request as xs:string := xdmp:get-request-url();

declare function local:makeHTML($content as element(search:response), $skin as xs:string, $mime as xs:string, $queryStr as xs:string, $labeling as xs:string, $thispage as xs:string, $thiscount as xs:integer, $thisview as xs:string, $thiscollection as xs:string, $mysort as xs:string) as element(html) {
    let $mypage := xs:int($thispage)
    let $mycount := $thiscount
    let $myhead := xdmp:invoke(("/static/html/search-skin.xqy"), (xs:QName("static:static"), "header"))
    let $myfooter := xdmp:invoke(("/static/html/search-skin.xqy"), (xs:QName("static:static"), "footer"))
    let $hitsfound := data($content/@total) cast as xs:integer
    let $totalresultspages := ceiling($hitsfound div $mycount)
    let $currentresultspage := $mypage
    let $time := seconds-from-duration($content/search:metrics/search:total-time)
    let $request := $global-request
    let $searchstr := $content/search:qtext/string()
    let $beginhit := data($content/search:result[1]/@index)
    let $endhit := data($content/search:result[last()]/@index)
    let $mypaginator :=
        if ($hitsfound gt 0) then
            (
                <div class="right">
                  <ul id="pagination-clean">
                    {pg:search-results-paginator($currentresultspage, $totalresultspages, $request)}
                  </ul>
                </div>,
                <!-- end class:right -->
            )
        else
            ()
    let $resultcountsdisp :=
        if ($hitsfound eq 0) then
            <span><strong>No results</strong></span>
        else
            <span>Results <strong>{concat($beginhit, ' - ', $endhit)}</strong> of about {$hitsfound} found in {round-half-to-even($time, 2)} seconds</span>
    let $html :=
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta content="{concat($mime, '; charset=UTF-8')}" http-equiv="Content-Type" />
                <title>Search Results for {$searchstr} (National Library Collections, Library of Congress)</title>
                {$myhead/head/link}
                <!-- <style type="text/css">
                    @import url("/marklogic/static/css/default/fixedFacetsScroll.css");
                </style> -->
                <meta name="Keywords" content="search results national library collections library congress {$queryStr}" />
                <meta name="Description" content="Search Results for {$searchstr}. National Library Collections, Library of Congress" />
                {$myhead/head/script}
                <script type="text/javascript">
                {
                    let $map := map:map()
                    let $put := (
                        map:put($map, "search", encode-for-uri($queryStr)),
                        map:put($map, "page", $mypage),
                        map:put($map, "count", $mycount),
                        map:put($map, "field", encode-for-uri($thiscollection))
                    )
                    return concat("var facetsdata = ", xdmp:to-json(($map)), ";")
                }
                </script>             
            </head>
            <body>
                <div id="ds-container">
                    {$myhead/body/div}
                </div>
                <div id="ds-body">
                    <div id="ds-search">
                        <div id="ds-quicksearch">
                            <form id="quick-search" name="quick-search" method="get" action="/xq/search.xqy">
                                <input value="{$searchstr}" type="text" alt="q" name="q" size="75" maxlength="200" class="txt" id="quick-search-box" />
                                <input value="{$thiscollection}" type="hidden" alt="collection" name="collection" />
                                <input value="score-desc" type="hidden" alt="sort" name="sort" />
                                <span>&nbsp;<button value="submit">Search</button>&nbsp;<label style="margin-left: 4px;" class="norm"><a href="advanced.html">Advanced Search</a></label></span>
                            </form>
                            <span class="searchhelp">
                                <a href="help.html">Search Tips</a>
                            </span>
                        </div>
                        <!-- end id:ds-quicksearch -->
                        <div id="ds-facetvalues">
                            <span class="your-search">Search results for <strong>{$searchstr}</strong></span>
                            <span class="facet">&nbsp;<img src="http://www.loc.gov/images/arrow.gif" alt="" class="facet-arrow" />facet one <span class="cssnav"><a href="#" title="Remove Facet: [facet name]"><img src="/static/natlibcat/images/facet-on.gif" alt="Remove Facet" /></a></span></span>
                            <span class="facet">&nbsp;<img src="http://www.loc.gov/images/arrow.gif" alt="" class="facet-arrow" />facet two <span class="cssnav"><a href="#" title="Remove Facet: [facet name]"><img src="/static/natlibcat/images/facet-on.gif" alt="Remove Facet" /></a></span></span>
                        </div>
                        <!-- end id:ds-facetvalues -->
                    </div>
                    <!-- end id:ds-search -->
                    <div id="ds-results">
                        <div id="ds-leftcol">
                            <div id="ds-facets">
                              <h2>Refine Results</h2>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                              <p>FACETS </p>
                            </div>
                            <!-- end id:ds-facets -->
                          </div>
                          <!-- end id:ds-leftcol -->
                          <div id="ds-mainright">
                              <div id="ds-controls">
                                  <div class="ds-paging">
                                    <div class="left">
                                        {$resultcountsdisp}
                                    </div>
                                    <!-- end class:left -->
                                    {$mypaginator}
                                  </div>
                                  <!-- end class:ds-paging -->
                                  <div class="ds-views">
                                    <div class="left">
                                      <form class="resort" id="resort" name="resort" method="get" action="resort">
                                        <label for="sortorder" class="norm">Sort by</label>                                   
                                            <select name="sortorder" size="1" id="sort-order">
                                                <option value="score-desc">
                                                    {if ($mysort eq "score-desc") then attribute selected {"selected"} else ()}
                                                    Relevance (high-to-low)
                                                </option>
                                                <option value="score-asc">
                                                    {if ($mysort eq "score-asc") then attribute selected {"selected"} else ()}
                                                    Relevance (low-to-high)
                                                </option>
                                                <option value="pubdate-asc">
                                                    {if ($mysort eq "pubdate-asc") then attribute selected {"selected"} else ()}
                                                    Publication date (newest-to-oldest)
                                                </option>
                                                <option value="pubdate-desc">
                                                    {if ($mysort eq "pubdate-desc") then attribute selected {"selected"} else ()}
                                                    Publication date (oldest-to-newest)
                                                </option><option value="cre-asc">
                                                    {if ($mysort eq "cre-asc") then attribute selected {"selected"} else ()}
                                                    Author/creator name (A-Z)
                                                </option>
                                                <option value="cre-desc">
                                                    {if ($mysort eq "cre-desc") then attribute selected {"selected"} else ()}
                                                    Author/creator name (Z-A)
                                                </option>
                                            </select>
                                            <button class="btn-sm" value="submit">Go</button>                                       
                                      </form>
                                    </div>
                                    <!-- end class:left -->
                                    <div class="right">
                                      <form class="numhits" id="number_hits" method="get" action="number_hits">
                                        <select class="sel" name="number_hits_sel" id="number_hits_sel">
                                          <option value="hits10">
                                              {if ($mycount eq 10) then attribute selected {"selected"} else ()}
                                              10
                                          </option>
                                          <option value="hits25">
                                              {if ($mycount eq 25) then attribute selected {"selected"} else ()}
                                              25
                                          </option>
                                        </select>&nbsp;<label class="norm" for="number_hits">per page</label>
                                      </form>
                                    </div>
                                    <!-- end class:right -->
                                  </div>
                                  <!-- end class:ds-views -->
                              </div>
                              <!-- end id:ds-controls -->
                              <div id="ds-hitlist">
                                  <ul>
                                      {
                                        for $li at $i in $content/search:result
                                        let $docxpath := string($li/@path)
                                        let $myuri := string($li/@uri)
                                        let $pct := concat(round-half-to-even(data($li/@confidence), 2) * 100, '%') 
                                        (:let $svcid := doc($myuri)/mets:mets/@OBJID/string():)
                                        (:let $mods := doc($myuri)/mets:mets//mods:mods/mods:titleInfo[not(@type)][1]:)
                                        (:let $imageid :=
                                            if ($svcid ne '') then
                                                $svcid
                                            else
                                                $myuri:)
                                        let $oddOrEven :=
                                            if ($i mod 2 = 0) then
                                                "evenrow"
                                            else
                                                "oddrow"
                                        return
                                            <li class="{$oddOrEven}">
                                                <span class="hit">{data($li/@index)}.&nbsp;</span>
                                                {local:get-bib-data($docxpath, $myuri, $pct)}
                                                <!--{for $snip in $li/search:snippet return local:style($snip)}-->
                                                <!-- <img style="padding: 3px;" src="{concat('/marklogic/getImage.xqy?id=', $imageid)}"/> -->
                                            </li>
                                      }
                                  </ul>
                                </div>
                                <!-- end id:ds-hitlist -->
                          </div>
                          <!-- end id:ds-mainright -->
                    </div>
                    <!-- end id:ds-results -->
                    {$myfooter/div}
                </div>
            </body>
        </html>
    return $html
};

declare function local:get-bib-data($docxpath as xs:string, $myuri as xs:string, $pct as xs:string) as element()+ {
    let $mets := doc($myuri)/mets:mets
    let $svcid := $mets/@OBJID/string()
    return
        if (starts-with($myuri, "/catalog/lscoll/ead/")) then
            let $ead := $mets/mets:dmdSec[@ID='ead']/mets:mdWrap/mets:xmlData/ead:ead
            let $eadtitle := string($ead/ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper)
            let $eadextents := string-join($ead/ead:archdesc/ead:did/ead:physdesc/ead:extent, " ; ")
            let $eadpub := string($ead/ead:eadheader/ead:filedesc/ead:publicationstmt/ead:publisher)
            let $eadaddr := string-join($ead/ead:eadheader/ead:filedesc/ead:publicationstmt/ead:address/ead:addressline, " ")
            let $eadabstract := string($ead/ead:archdesc/ead:did/ead:abstract)
            let $eadabsfmt :=
                if (string-length($eadabstract) gt 250) then
                    concat(substring($eadabstract, 1, 250), "...")
                else
                    $eadabstract
            return (
                <a class="hitResult ead-result" href="{concat("/xq/conneg.xqy?_uri=", $svcid, "&amp;_mime=text/xml")}">{$eadtitle}</a>,
                <span>&nbsp;<b>({$pct})</b></span>,
                <br />,
                <span class="findaid-ext">{concat($eadextents, " -- ", $eadpub, ", ", $eadaddr)}</span>,
                <br />,
                <span class="format"><span>Format:</span> Finding Aid</span>,
                <br />,
                <span class="location"><span>Location:</span> Available Online</span>,
                <br/>,
                <p><a href="{concat("/", $svcid,"/default.html")}">Bib view</a></p>,
                <div class="findaid-summary">
                    <span>Summary: </span>
                    {$eadabsfmt}
                </div>
            )
        else
            let $mods := $mets/mets:dmdSec[@ID='dmd1']/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods
            let $idx := $mets/mets:dmdSec[@ID='IDX1']/mets:mdWrap[@MDTYPE='OTHER']/mets:xmlData/idx:indexTerms
            let $titlehref := (: concat("/", $svcid,"/default.html") :) concat("/xq/conneg.xqy?_uri=", $svcid, "&amp;_mime=text/xml")
            let $marctitle := $mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record/mxe2:datafield_245/child::*
            let $title := 
                (
                    <a class="hitResult mods-result" href="{$titlehref}">
                        {
                            if (exists($marctitle)) then
                                string-join($marctitle, " ")
                            else
                                normalize-space($mods/mods:titleInfo[not(@type)][1])
                        }
                    </a>,
                    <span>&nbsp;<b>({$pct})</b></span>
                )
            let $creator := <span class="author">[Main Creator] {string-join($idx/idx:creator, "; ")}</span>
            let $publisher := <span class="publisher">[Publisher] {string-join($mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record/mxe2:datafield_260/child::*, " ")}</span>
            let $format :=
                <span class="format">
                    <span>[Format/Genre]</span> {
                        if (exists($mods/mods:genre)) then
                            concat('Genre: ', $mods/mods:genre[1]/string())
                        else if (exists($mods/mods:physicalDescription[mods:form]/mods:form[1])) then
                            concat('Format: ', $mods/mods:physicalDescription[mods:form][1]/mods:form[1]/string())
                        else if (exists($mods/mods:typeOfResource)) then
                            concat('Format: ', $mods/mods:typeOfResource/string())
                        else
                            ()
                    }
                </span>
            let $location :=
                (<span class="location">[Location] <span>Location:</span> ::location label OR "available online"::</span>, <br />)
            return ($title, <br />, $creator, <br />, $publisher, <br/>, $format, <br />, $location)
};

declare function local:style($snippet as element(search:snippet))  as element(ul) {
    <ul>
        <li>
            <strong class="font-weight: bold;">Details</strong>
            <ul class="snippets">
            {
                for $match in $snippet/search:match
                return 
                    <li>
                        <span>
                        {
                          for $node in $match/node()
                          return 
                            typeswitch($node)
                              case element(search:highlight) 
                                return <span class="highlight">{data($node)}</span> 
                              case text() 
                                return $node 
                              default return xs:string($node)
                        }
                        </span>
                        <span style="margin-left: 15px;">
                        
                            <a href="{string($match/@path)}">[View]</a>
                        
                        </span>
                    </li>
            }
            </ul>
        </li>
    </ul>
};

let $search_config := sc:global-search-config($collection)
let $results_config := $search_config/search:results-logic/search:options
let $facets_config := $search_config/search:facets-logic/search:options

let $search_options := $results_config

let $longcount :=
    if ($howMany eq "10") then
        10
    else if ($howMany eq "25") then
        25
    else
        10

let $longstart := ((xs:int($page) * $longcount) + 1) - $longcount

let $search := 
    if (matches($digitized, '(true|1|yes|on)', 'i')) then
        search:search(concat($query, ' digitized:"true"'), $search_options, $longstart, $longcount)
    else
        search:search($query, $search_options, $longstart, $longcount)

let $skin := 
    if ($look !='pae' and $look !='default') then
         "default"
    else
        $look
let $requestedMime := mime:safe-mime($mime)
return
    if (matches($requestedMime, "(application/xhtml\+xml|text/html)")) then
        if (contains($global-request, '&amp;page=')) then
            local:makeHTML($search, $skin, $requestedMime, $query, $label, $page, $longcount, $view, $collection, $sortOrder)
        else
            xdmp:redirect-response(concat($global-request, "&amp;page=1"))
    else if ($requestedMime eq "application/json") then
        $search (:jsonutils:serialize($search/*[not(search:metrics)]):)
    else if (matches($requestedMime, "(application/x-lcsearchresults\+xml|text/xml|application/xml)")) then
        $search
    else
        "You must specify a mime-type for serialization"(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)