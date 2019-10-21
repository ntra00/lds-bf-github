xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace kml = "http://earth.google.com/kml/2.0" at "/MarkLogic/geospatial/kml.xqy";
import module namespace georss = "http://www.georss.org/georss" at "/MarkLogic/geospatial/georss.xqy";
import module namespace utils = "info:lc/xq-modules/kml-utils" at "/xq/modules/kml-utils.xqy";
declare namespace georss11 = "http://www.georss.org/georss/11";
declare namespace kml22 = "http://www.opengis.net/kml/2.2";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

let $query as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "q")
let $points as xs:string := lp:get-param-single($lp:CUR-PARAMS, "latlng", "earth")
let $region :=
    if ($points eq "earth") then
        $cfg:DEFAULT-POLYGON-ROI
    else if ($points) then
        georss:polygon(<georss:polygon>{replace($points, "(, |\(|\))", " ")}</georss:polygon>)
    else
        $cfg:DEFAULT-POLYGON-ROI
let $js := utils:poly-roi-googlemaps($region)
let $gisq := cts:and-query((cts:word-query($query), cts:element-geospatial-query(xs:QName("georss11:point"), $region, ("boundaries-included", "cached"))))
(:let $gisqxml := <blah>{$gisq}</blah>/element():)
 
let $search := (cts:search(collection("/lscoll/africasets/")/mets:mets, $gisq))[1 to 10]
let $html :=
    <html>
        <head>
            <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
            <!-- <link href="http://code.google.com/apis/maps/documentation/javascript/examples/default.css" rel="stylesheet" type="text/css" /> -->
            <style type="text/css">
              /*html &#x007B; height: 100% &#x007D;
              body &#x007B; height: 100%; margin: 0px; padding: 0px &#x007D;
              #map_canvas &#x007B; height: 50% &#x007D;*/
            </style>
            <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
            <script type="text/javascript" src="http://marklogic3.loc.gov/static/natlibcat/js/jquery-1.4.4.min.js"></script>
            <script type="text/javascript" src="http://marklogic3.loc.gov/static/natlibcat/js/polygon.min.js"></script>
            <script type="text/javascript" src="http://marklogic3.loc.gov/static/natlibcat/js/geosearch.js"></script>
            <script type="text/javascript">var roipoly = {$js};</script>
        </head>
        <body>
            <form id="geoform-input" action="/nlc/geosearch.xqy" method="get">
                <p>
                    <input name="q" type="text" value="Enter query..." />
                    <input name="latlng" type="hidden" id="geo-coords" value="earth"/>
                    <input id="geoShowData" type="submit" value="Search"/>&nbsp;<input id="geoClearData" type="button" value="Clear polygon"/>
                </p>
            </form>
            <br/>        
            <div id="map_canvas" style="width:50%; height:50%"></div>
            <br/>
            {for $ss in $search return $ss/@OBJID/string() }
        </body>
    </html>
return
    $html