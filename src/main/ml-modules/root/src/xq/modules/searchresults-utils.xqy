xquery version "1.0-ml";

module namespace sr = "info:lc/xq-modules/searchresults-utils";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace fac = "info:lc/xq-modules/facets" at "facets.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "mime-utils.xqy";
import module namespace sru = "info:lc/xq-modules/sru" at "sru.xqy";
import module namespace metsutils = "info:lc/xq-modules/mets-utils" at "mets-utils.xqy";
import module namespace eadutils = "info:lc/xq-modules/ead-utils" at "ead-utils.xqy";
import module namespace altoutils = "info:lc/xq-modules/alto-utils" at "alto-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace diag = "http://www.loc.gov/zing/srw/diagnostic/";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace alto = "http://schema.ccs-gmbh.com/ALTO";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace kml2 = "http://www.opengis.net/kml/2.2";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace georss = "http://www.georss.org/georss";
declare namespace zr = "http://explain.z3950.org/dtd/2.1/";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare namespace mlhttp = "xdmp:http";

declare variable $sr:static := "/usr/local/lcdemo/marklogic/static/"; (: root for location of xml, html, css, image files:)

declare function sr:init($resulttype as xs:string, $content as element(search:response), $skin as xs:string, $mime as xs:string, $queryStr as xs:string, $labeling as xs:string, $thisstart as xs:string, $thiscount as xs:string, $thisview as xs:string, $qfield as xs:string, $mysort as xs:string, $gis-wkt as xs:string?) {
    (: should be "geo" or "text", but defaults to text :)
    (: USE LIKE SO... sr:init("text", $search, $skin, $requestedMime, $query, $label, $start, $howMany, $view, $qname, $sortOrder):)
    if ($resulttype eq "geo") then
        sr:geo-results($content, $skin, $queryStr, $labeling, $thisstart, $thiscount, $thisview, $mysort, $gis-wkt)
    else
        sr:text-results($content, $skin, $mime, $queryStr, $labeling, $thisstart, $thiscount, $thisview, $qfield, $mysort)
};

declare function sr:breadcrumb($text as xs:string, $type as xs:string) as element(div) {
    <div id="crumb_nav">
        <div id="crumb">
            <a href="http://www.loc.gov">Library of Congress</a> &gt; 
    		<a href="/">Library Services Collections</a> &gt; 
    		{
    		    if (matches($type, "text", "i")) then
    		        (<a href="/index.html">Search</a>, " &gt; ")
    		    else if (matches($type, "geo.*", "i")) then
    		        (<a href="/index.html#demo-tabs-2">Geographic Search</a>, " &gt; ")
    		    else if (matches($type, "(time.*|temporal)", "i")) then
    		        (<a href="/timeline.html">Temporal Search</a>, " &gt; ")
    		    else
    		        (<a href="/search.html">Search</a>, " &gt; ")
    		}
    		<span style="font-size: 100%; font-weight: normal;">Search Results for "{$text}"</span>
    	</div>
    </div>
};

declare function sr:swan-nav-bar($content as element(search:response), $thisstart as xs:string, $thiscount as xs:string, $mysort as xs:string) as element(p) {
    let $hitsfound := $content/@total
    let $time := seconds-from-duration($content/search:metrics/search:total-time)
    let $mystart := xs:int($thisstart)
    let $mycount := xs:int($thiscount)
    let $begin := if (data($hitsfound) eq 0) then "0" else $thisstart
    let $endhit := if (($mycount+$mystart) gt data($hitsfound)) then data($hitsfound) else (($mycount+$mystart) - 1)
    let $request := xdmp:get-request-url()
    let $reqprev := 
        if (not(contains($request, '&amp;start='))) then
            "Previous"
        else
            if ($mystart - $mycount le 0) then
                let $p := replace($request, "&amp;start=\d+", "&amp;start=1")
                return <span><img height="11" width="11" alt="Arrow back" src="/marklogic/static/img/back_blue.gif" />&nbsp;<a href="{$p}">Previous</a></span>
            else
                let $diff := $mystart - $mycount
                let $p := replace($request, "&amp;start=\d+", concat("&amp;start=", $diff))
                return <span><img height="11" width="11" alt="Arrow back" src="/marklogic/static/img/back_blue.gif" />&nbsp;<a href="{$p}">Previous</a></span>
    let $reqnext := 
        if ($mystart + $mycount gt data($hitsfound)) then
            "Next"
        else
            if (not(contains($request, '&amp;start='))) then
                let $sum := $mycount + $mystart
                let $p := concat($request, '&amp;start=', $sum)
                return <span><a href="{$p}">Next</a>&nbsp;<img height="11" width="11" alt="Arrow forward" src="/marklogic/static/img/forward_green.gif" /></span>
            else
                let $sum := $mycount + $mystart
                let $p := replace($request, "&amp;start=\d+", concat("&amp;start=", $sum))  
                return <span><a href="{$p}">Next</a>&nbsp;<img height="11" width="11" alt="Arrow forward" src="/marklogic/static/img/forward_green.gif" /></span>
    return
        <p>
            <strong>{concat('Items ', $begin, ' to ', $endhit, ' of ', $hitsfound, ' hits')}</strong>        
            <span>{$reqprev} | {$reqnext}</span>
            <span style="margin-left: 40px;">
                <span>View: </span>
                <img height="11" width="10" alt="Icon for text" src="/marklogic/static/img/text.gif" />
                <span>&nbsp;<a href="#">Text</a>&nbsp;</span>
                <span> | </span>
                <span class="selected"><img height="13" width="13" alt="Gallery Icon" src="/marklogic/static/img/gallery_grey.gif" />&nbsp;<a href="#">Gallery</a>&nbsp;</span>
            </span>
            <span style="margin-left: 40px;">Sorted by: </span>
            <span style="margin-left: 3px;">
                <select name="sortorder" id="sort-order">
                    <option value="score-desc">
                        {if ($mysort eq "score-desc") then attribute selected {"selected"} else ()}
                        Score high-to-low
                    </option>
                    <option value="score-asc">
                        {if ($mysort eq "score-asc") then attribute selected {"selected"} else ()}
                        Score low-to-high
                    </option>
                    <option value="pubdate-asc">
                        {if ($mysort eq "pubdate-asc") then attribute selected {"selected"} else ()}
                        Publication date: newest-to-oldest
                    </option>
                    <option value="pubdate-desc">
                        {if ($mysort eq "pubdate-desc") then attribute selected {"selected"} else ()}
                        Publication date: oldest-to-newest
                    </option><option value="cre-asc">
                        {if ($mysort eq "cre-asc") then attribute selected {"selected"} else ()}
                        Author name A-Z
                    </option>
                    <option value="cre-desc">
                        {if ($mysort eq "cre-desc") then attribute selected {"selected"} else ()}
                        Author name Z-A
                    </option>
                </select>
            </span>
        </p>
};

declare function sr:text-head($skin as xs:string, $mime as xs:string, $thisstart as xs:string, $thiscount as xs:string, $queryStr as xs:string, $qfield as xs:string) as element(head) {
    let $mystart := xs:int($thisstart)
    let $mycount := xs:int($thiscount)
    let $myhead := sr:header($skin)
    return
        <head>
            {$myhead/head/child::*}
            <style type="text/css">
                @import url("/marklogic/static/css/default/fixedFacetsScroll.css");
            </style>
            <script type="text/javascript">
            {
                let $map := map:map()
                let $put := (
                    map:put($map, "search", encode-for-uri($queryStr)),
                    map:put($map, "start", $mystart),
                    map:put($map, "count", $mycount),
                    map:put($map, "field", encode-for-uri($qfield))
                )
                return concat("var facetsdata = ", xdmp:to-json(($map)), ";")
            }
            </script>
            <script type="text/javascript" src="/marklogic/static/js/default/default.js"> <!-- space --> </script> 
            <meta content="{concat($mime, '; charset=UTF-8')}" http-equiv="Content-Type" />
        </head>
};

declare function sr:text-results($content as element(search:response), $skin as xs:string, $mime as xs:string, $queryStr as xs:string, $labeling as xs:string, $thisstart as xs:string, $thiscount as xs:string, $thisview as xs:string, $qfield as xs:string, $mysort as xs:string) as element(html) {
    let $mystart := xs:int($thisstart)
    let $mycount := xs:int($thiscount)
    let $myhead := sr:header($skin)
    let $myfooter := sr:footer($skin)
    let $hitsfound := $content/@total
    let $time := seconds-from-duration($content/search:metrics/search:total-time)
    let $searchnav := sr:swan-nav-bar($content, $thisstart, $thiscount, $mysort)
    let $html :=
        <html xmlns="http://www.w3.org/1999/xhtml">
            {sr:text-head($skin, $mime, $thisstart, $thiscount, $queryStr, $qfield)}
            <body>
                <div id="wow"/>
                <a href="#skip_menu" id="skip">skip navigation</a>
                <div id="container">
                    {$myhead/body/div}
                    {sr:breadcrumb($queryStr, "text")}
                    <div id="content">
                        <div id="page_head_search">
                            <span id="skip_menu" />
                            <h1>{$labeling}</h1>
                        </div>
                        <div id="main_menu_search">
                            <div id="main_body">
                                <div class="main_nav2_top">
                                    <form action="search.xqy" method="GET" accept-charset="UTF-8">
                                        <div class="ui-widget">
                                            <span class="results_num">{concat(string($hitsfound), ' results found in ', round-half-to-even($time, 2), ' seconds.')}</span>  				
                                            <span>You searched:  </span>
                                            <input id="q" value="{$queryStr}" size="75" type="text" alt="query" name="q" />
                                            <span>&nbsp;</span>
                                            <input value="GO" class="button" type="submit" alt="submitbutton" />
                                        </div>
                                        <input value="{$qfield}" type="hidden" alt="field" name="field" />
                                        <input value="score-desc" type="hidden" alt="sort" name="sort" />
                                    </form>
                                </div>
                                <div class="search_nav_top">
                                    {$searchnav}
                                </div>
                                <!-- search results start here -->
                                {sr:process-result-content($content, $thisstart, $thisview)}
                                <!-- search results end here -->
                                <div class="search_nav_bottom">
                                    {$searchnav}
                                </div>
                            </div>
                        </div>
                    </div>
                    {$myfooter/div}
                </div>
            </body>
        </html>
    return $html
};

declare function sr:process-result-content($content as element(search:response), $thisstart as xs:string, $thisview as xs:string) as element(div) {
    let $facets :=
            <div id="facets-space">
                <h2 id="facets-filter" style="line-height: 16px; text-align: center; color: #990000;">Filter results by:</h2>
                {fac:ajax()}
            </div>
    let $viewa :=
            if ($thisview eq "text") then
                <table style="width: 87%; margin-left: 12%;">
                    <tr>
                        <th style="text-align: center;">Hit</th>
                        <th style="text-align: center;">Confidence</th>
                        <th style="text-align: center;">Details</th>
                        <th style="text-align: center;">Sample Image</th>
                    </tr>
                    {sr:text-populate-table($content, $thisstart)}
                </table>
            else if ($thisview eq "geo") then
                <table style="width: 50%; position: absolute; margin: 0px 20px 0px 41%; float: right;">
                    <tr>
                        <th style="text-align: center;">Hit</th>
                        <th style="text-align: center;">Confidence</th>
                        <th style="text-align: center;">Details</th>
                    </tr>
                    {sr:geo-populate-table($content, $thisstart)}
                </table>
            else if ($thisview eq "gallery") then
                sr:gallery-results($content)
            else
                <table style="width: 87%; margin-left: 12%;">
                    {sr:text-populate-table($content, $thisstart)}
                </table>
    let $div :=
        <div id="ml_search_results">
        {
            if ($thisview eq "geo") then
                $viewa
            else
                ($facets, $viewa)
        }
        </div>
    return $div
};

declare function sr:text-populate-table($results as element(search:response), $mystart as xs:string) as element(tr)* {
    for $li at $i in $results/search:result
    let $docxpath := string($li/@path)
    let $dok := substring-before($docxpath, "/mets:mets")
    let $myuri := string($li/@uri)
    let $svcid := xdmp:unpath(concat($dok, "/mets:mets/@OBJID/string()"))
    let $metsThumb := string(doc($myuri)/mets:mets/mets:fileSec/mets:fileGrp[@USE='SERVICE']/mets:file[@MIMETYPE='image/jpeg'][1]/mets:FLocat/@xlink:href)
    let $illustrativeThumb :=
        if (string-length($metsThumb) gt 0) then
            if (matches($metsThumb,"/afcwip/|/pnp/")) then
                replace($metsThumb, "v\.jpg", "t.gif", "mi")
            else
                replace($metsThumb, "v\.jpg", "h.jpg", "mi")
        else
            "/marklogic/static/img/blank.jpg"
    let $oddOrEven :=
        if ($i mod 2 = 0) then
            ("evenrow", "background-color: #E4EDF0; line-height: 70px;")
        else
            ("oddrow", "background-color: #FFFFFF; line-height: 70px;")
    return
        <tr class="{$oddOrEven[1]}" style="{$oddOrEven[2]}">
            <td style="width: 5%;">
                <b>{data($li/@index)}</b>
            </td>
            <td style="width: 3%;">
                <b>{ let $pct := round-half-to-even(data($li/@confidence), 2) * 100 return concat($pct cast as xs:string, '%') }</b>
            </td>
            <td style="width: 82%;">
                <div style="margin-left: 10px;">
                    {sr:get-title($li)}                    
                    { for $snip in $li/search:snippet return sr:style($snip) }
                </div>
            </td>
            <td style="width: 10%; text-align: center;">
                <img style="border: 1px solid #555555; padding: 3px;" src="{$illustrativeThumb}"/>
            </td>
        </tr>
};

declare function sr:geo-populate-table($results as element(search:response), $mystart as xs:string) as element(tr)* {
    for $li at $i in $results/search:result
    let $docxpath := string($li/@path)
    let $myuri := string($li/@uri)
    let $frag := tokenize(substring-before($myuri, ".kml"), "/")[last()]
    let $metsurl := concat("loc.natlib.lcdb.", $frag)
    (:let $title := doc(concat($metsurl, ".xml"))/mets:mets//mods:mods/mods:titleInfo[not(@type)][1]:)
    let $placemark := xdmp:eval($docxpath)
    let $title := $placemark/kml2:name/string()
    let $geodefault := concat('/', $metsurl, '/geodefault.html')
    let $link := <a href="{$geodefault}">{string($title)}</a>
    let $parent := metsutils:mets($metsurl)//mods:mods/mods:titleInfo[not(@type)][1]/string()
    let $oddOrEven :=
        if ($i mod 2 = 0) then
            ("evenrow", "background-color: #E4EDF0; line-height: 70px; font-size: smaller;")
        else
            ("oddrow", "background-color: #FFFFFF; line-height: 70px; font-size: smaller;")
    return
        <tr class="{$oddOrEven[1]}" style="{$oddOrEven[2]}">
            <td style="width: 5%;">
                <b>{data($li/@index)}</b>
            </td>
            <td style="width: 3%;">
                <b>{ let $pct := round-half-to-even(data($li/@confidence), 2) * 100 return concat($pct cast as xs:string, '%') }</b>
            </td>
            <td style="width: 82%;">
                <div style="margin-left: 10px;">
                    {$link}
                    <p>Plate number {substring-after($docxpath, "kml2:Placemark")} within host item: <a href="{$geodefault}">{$parent}</a></p>
                    {(:for $snip in $li/search:snippet return sr:style($snip):)}
                </div>
            </td>
        </tr>
};

declare function sr:gallery-results($content) as element(table) {
    <table summary="thumbnails for each search result" id="search_result_gallery">
        {$content}
    </table>
};

declare function sr:style($snippet as element(search:snippet))  as element(ul) {
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
                        <!-- <span style="margin-left: 15px;">[<a href="{string($match/@path)}">View</a>]</span> -->
                    </li>
            }
            </ul>
        </li>
    </ul>
};

declare function sr:get-title($hit as element(search:result)) as element()+ {
    let $docxpath := string($hit/@path)
    let $myuri := string($hit/@uri)
    return
        if (starts-with($myuri, "/alto/")) then
            let $altottl := altoutils:get-alto-title($myuri)
            return ($altottl, <span style="margin-left: 5px; font-size:smaller;">(Chronicling America ALTO Page)</span>)
        else if (starts-with($myuri, "/authorities/")) then "MARCXML"
        else        
            let $svcid := xdmp:unpath(concat($docxpath, "/mets:mets/@OBJID/string()"))
            return
                if (starts-with($myuri, "/ead/")) then
                    let $ead := xdmp:eval(concat($docxpath, '//ead:ead/ead:eadheader//ead:titlestmt/ead:titleproper'))
                    let $eadhref := eadutils:get-href($svcid)
                    return (<a class="hitResult ead-result" href="{$eadhref}">{string($ead)}</a>, <span style="margin-left: 5px; font-size:smaller;">(EAD Finding Aid)</span>)
                else
                    let $mods := xdmp:eval(concat($docxpath, '//mods:mods/mods:titleInfo[not(@type)][1]'))
                    return <a class="hitResult mods-result" href="{concat("/", $svcid,"/default.html")}">{string($mods)}</a>
};

declare function sr:get-creator($myuri as xs:string, $svcid as xs:string, $xpath as xs:string) as element(p)  {
    <p>
    {
        let $doc := replace($xpath, "(doc\(.+\))/.+", "$1")
        let $ead := xdmp:eval(concat($doc, '//ead:ead/ead:archdesc/ead:did/ead:origination'))
        let $mods := xdmp:eval(concat($doc, '//mods:mods/mods:name/mods:namePart'))
        let $auth := 
            if (exists($ead)) then
                string-join($ead, "; ")
            else if (exists($mods)) then
                string-join($mods, "; ")
            else
                ""
        return $auth
    }
    </p>
};

declare function sr:header($skin as xs:string) {
    let $thisskin := if (string-length($skin) eq 0) then "default" else $skin
    return xdmp:document-get(concat($sr:static, "html/", $thisskin, "/header.xml"))/header
};

declare function sr:footer($skin as xs:string) {
    let $thisskin := if (string-length($skin) eq 0) then "default" else $skin
    return xdmp:document-get(concat($sr:static, "html/", $thisskin, "/footer.xml"))/footer
};

declare function sr:leftnav($skin as xs:string) {
    let $thisskin := if (string-length($skin) eq 0) then "default" else $skin
    return xdmp:document-get(concat($sr:static, "html/", $thisskin, "/leftnav.xml"))/leftnav
};

declare function sr:geo-results($content as element(search:response), $skin as xs:string, $queryStr as xs:string, $labeling as xs:string, $thisstart as xs:string, $thiscount as xs:string, $thisview as xs:string, $mysort as xs:string, $gis-wkt as xs:string) as element(html) {
    let $mystart := xs:int($thisstart)
    let $mycount := xs:int($thiscount)
    let $myhead := sr:header($skin)
    let $myfooter := sr:footer($skin)
    let $hitsfound := $content/@total
    let $time := seconds-from-duration($content/search:metrics/search:total-time)
    let $searchnav := sr:swan-nav-bar($content, $thisstart, $thiscount, $mysort)
    let $kmlURL := sr:makeGeoXML($content, "kml", $queryStr)
    let $georssURL := sr:makeGeoXML($content, "georss", $queryStr)
    (:let $kmlGeoJSON := sr:makeGeoJSON($content):)
    return
        <html xmlns="http://www.w3.org/1999/xhtml">
        	<head>
        		<title>Datastore: Library Services Digital Content</title>
        		<meta name="robots" content="noindex"/>
        		<meta http-equiv="Content-Language" content="en-us"/>
        		<link href="/marklogic/static/css/pae/results.css" type="text/css" rel="stylesheet"/>
        		<link rel="stylesheet" type="text/css" href="/marklogic/static/css/default/results.css"/>
        		<link rel="stylesheet" type="text/css" href="/marklogic/static/js/jquery-ui/css/cupertino/jquery-ui-1.8rc3.custom.css"/>
        		<link rel="alternate" href="{$georssURL}" type="application/atom+xml" title="Geographic search results" />
        		<script type="text/javascript" src="/marklogic/static/js/OpenLayers/OpenLayers.js"> <!-- space --> </script>
        		<script type="text/javascript" src="/marklogic/static/js/jquery-ui/js/jquery-1.4.2.min.js"> <!-- space --> </script>
        		<script type="text/javascript" src="/marklogic/static/js/jquery-ui/js/jquery-ui-1.8rc3.custom.min.js"> <!-- space --> </script>
        		<script type="text/javascript" src="/marklogic/static/js/jquery.url.packed.js"> <!-- space --> </script>
        		<script type="text/javascript" src="/marklogic/static/js/default/demo.js"></script>
        		<script type="text/javascript">var geoxml = "{$kmlURL}"; var bbox = "{$gis-wkt}";</script>
        		<script type="text/javascript">var gopts;</script>
        	</head>
        	<body style="min-height: 400px;" onload="javascript:resultsinit(geoxml, bbox);">
        	<!-- <body style="min-height: 400px;" onload="javascript:resultsinit2(gopts);"> -->
        	    <div id="wow"/>
                <a href="#skip_menu" id="skip">skip navigation</a>
                <div id="container">
                    {$myhead/body/div}
                    {sr:breadcrumb($queryStr, "geo")}
                    <div id="page_head_search">
                        <span id="skip_menu" />
                        <h1>{$labeling}</h1>
                    </div>
                </div>
        	    <div class="search_nav_top">
                    {$searchnav}
                </div>
    			<div>
    			    {sr:process-result-content($content, $thisstart, $thisview)}
        			<p>
        			    <div id="demo-map" style="vertical-align: bottom; width: 40%; height: 900px; border: 1px solid #ccc;"></div>
        			</p>
        			
        			<p style="font-weight: bold; padding: 3px; border: 2px dashed #EE9A02; background-color: #F1C98D; width: 40%; text-align: center;">
        			    <span>
        			        <img style="vertical-align: bottom;" src="/marklogic/static/img/google_earth_link.gif" alt="Download KML for Google Earth" />
        			    </span>
        			    <span style="font-size: larger; margin: 1px 3px 1px 15px;"><a href="{$kmlURL}">Download KML</a> of results</span>
        			</p>
        			<div style="position: relative; margin-top: 20px;" class="search_nav_top">
                        {$searchnav}
                    </div>
                </div>
        	</body>
    	</html>
};

declare function sr:makeGeoXML($content as element(search:response), $xmltype as xs:string, $queryStr as xs:string) as xs:string {
    let $dateTime := current-dateTime()
    let $md5name := xdmp:md5($dateTime cast as xs:string)
    let $file := concat("/marklogic/static/js/tmp-geo/", $md5name)
    let $geoxml :=
        if (matches($xmltype, "kml", "i")) then
            <kml2:kml xsi:schemaLocation="http://www.opengis.net/kml/2.2 http://schemas.opengis.net/kml/2.2.0/ogckml22.xsd">
            {
                for $pt in $content/search:result
                let $placemark := xdmp:eval($pt/@path/string())
                let $descr := $placemark/kml2:description/string()
                let $newdescr := <kml2:description>{replace($descr, 'href="http://lccn\.loc\.gov/(.+)"&gt;', 'href="/loc.natlib.lcdb.$1/geodefault.html"&gt;', "mi")}</kml2:description>
                let $plname := $placemark/kml2:name
                let $style := ($placemark/kml2:styleUrl, $placemark/kml2:Style)
                (:let $point := $placemark//kml2:Point:)
                let $poly := $placemark//kml2:Polygon
                (:let $multi := $placemark//kml2:MultiGeometry:)
                return
                    <kml2:Placemark>
                        {$plname}
                        {$newdescr}
                        {$style}
                        {$poly}
                    </kml2:Placemark>
            }
            </kml2:kml>
        else if (matches($xmltype, "georss", "i")) then
            <atom:feed xmlns:georss="http://www.georss.org/georss" xmlns="http://www.w3.org/1999/xhtml" xmlns:atom="http://www.w3.org/2005/Atom">
                <atom:title>My Search Results for: "{$queryStr}"</atom:title>
                <atom:updated>{$dateTime}</atom:updated>
                <atom:author>
                    <atom:name>Library of Congress</atom:name>
                    <atom:email>info@loc.gov</atom:email>
                </atom:author>
                {
                    for $pt in $content/search:result
                    let $placemark := xdmp:eval($pt/@path/string())
                    let $plname := <atom:title>{$placemark/kml2:name/string()}</atom:title>
                    let $poly := $placemark//kml2:Polygon
                    let $coordtox := tokenize($poly//kml2:coordinates, " ")
                    let $descr := <div>{xdmp:unquote($placemark/kml2:description/string(), "http://www.w3.org/1999/xhtml", ("repair-full", "format-xml"))}</div>
                    let $prelink := $descr/a/@href/string()
                    (:let $link := replace($prelink, "(http://)lccn\.loc\.gov/(.+)", "$1marklogic1.loctest.gov/$2"):)
                    let $link := replace($prelink, "(http://)lccn\.loc\.gov/(.+)", "/$2")
                    let $id := concat("info:lc/", replace($link, "http://.+/(map.+)", "$1", "m"))
                    let $html :=
                        <div>
                            <table>{$descr/table/child::*}</table>
                            <hr/>
                            <a href="{$link}">View record</a>
                        </div>
                    return
                        <atom:entry>
                            {$plname}
                            <atom:updated>{$dateTime}</atom:updated>
                            <atom:summary>{$html}</atom:summary>
                            <atom:link href="{$link}"/>
                            <atom:id>{$id}</atom:id>
                            <georss:polygon> {
                                for $coord in $coordtox
                                let $toxx := tokenize($coord, ",")
                                return concat($toxx[1], " ", $toxx[2])
                            }
                            </georss:polygon>
                        </atom:entry>
                }
            </atom:feed>
        else 
            ()
    let $xmlfile := 
        if (matches($xmltype, "kml", "i")) then
            concat($file, ".kml.xml")
        else if (matches($xmltype, "georss", "i")) then
            concat($file, ".atom.xml")
        else
            concat($file, ".xml")
    return (xdmp:save(concat("/usr/local/lcdemo", $xmlfile), $geoxml), $xmlfile)            
};

declare function sr:makeGeoJSON($content) as empty-sequence() {
    ()
    (:'{"type": "GeometryCollection", "geometries": [{"type": "Point", "coordinates": [4.0, 6.0]}, {"type": "LineString", "coordinates": [[4.0, 6.0], [7.0, 10.0]]}]}':)
    (:'{ "type": "FeatureCollection",
  "features": [
    { "type": "Feature",
      "geometry": {"type": "Point", "coordinates": [102.0, 0.5]},
      "properties": {"prop0": "value0"}
      },
    { "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]
          ]
        },
      "properties": {
        "prop0": "value0",
        "prop1": 0.0
        }
      },
    { "type": "Feature",
       "geometry": {
         "type": "Polygon",
         "coordinates": [
           [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
             [100.0, 1.0], [100.0, 0.0] ]
           ]
       },
       "properties": {
         "prop0": "value0",
         "prop1": {"this": "that"}
         }
       }
     ]
   }':)
(:   '{ "type": "FeatureCollection",
  "features": [
    { "type": "Feature",
      "geometry": {"type": "Point", "coordinates": [102.0, 0.5]},
      "properties": {"prop0": "value0"}
      },
    { "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]
          ]
        },
      "properties": {
        "prop0": "value0",
        "prop1": 0.0
        }
      },
    { "type": "Feature",
       "geometry": {
         "type": "Polygon",
         "coordinates": [
           [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
             [100.0, 1.0], [100.0, 0.0] ]
           ]
       },
       "properties": {
         "prop0": "value0",
         "prop1": "Test" //{"this": "that"}
         }
       }
     ]
   }
':)
};