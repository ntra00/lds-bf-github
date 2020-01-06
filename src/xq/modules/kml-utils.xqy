xquery version "1.0-ml";

module namespace utils = "info:lc/xq-modules/kml-utils";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace mu = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare default element namespace "http://www.opengis.net/kml/2.2";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $objid as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "svcid");
declare variable $inmime := lp:get-param-single($lp:CUR-PARAMS, "mime", "application/vnd.google-earth.kml+xml");

declare function utils:kml-from-mets($objid as xs:string, $mime as xs:string) as element() {
    let $mets := mu:mets($objid)
    return
        if ($mets instance of element(mets:mets)) then
            if ($mets//Placemark) then
                let $descr := <description>Heya!</description>
                let $name := $mets//mods:mods/mods:titleInfo[not(attribute::*)]/mods:title/string()
                return
                    <kml>
                        <Document>
                            {$descr}
                            <name>{$name}</name>
                            <Style id="GreenPoly">
                                <PolyStyle>
                                    <color>7f00ff00</color>
                                </PolyStyle>
                            </Style>
                            {
                                for $pl in $mets//mods:relatedItem/mods:extension/kml/Document/Placemark
                                let $plname :=
                                    if ($pl/ancestor::mods:relatedItem/mods:titleInfo/mods:title) then
                                        <name>{$pl/ancestor::mods:relatedItem/mods:titleInfo/mods:title/string()}</name>
                                    else
                                        ()
                                let $pldesc :=
                                    if ($pl/ancestor::mods:relatedItem/mods:*) then
                                        <description>{string-join($pl/ancestor::mods:relatedItem/mods:*, "; ")}</description>
                                    else
                                        ()
                                return
                                    <Placemark>
                                        {$plname}
                                        {$pldesc}
                                        <styleUrl>#GreenPoly</styleUrl>
                                        {$pl/child::*}
                                    </Placemark>
                            }
                        </Document>
                    </kml>
                else
                    <error:error code="500">No KML Placemarks found in document</error:error>
        else if ($mets instance of element(error:error)) then
            $mets
        else
            <error:error/>
};

declare function utils:poly-roi-googlemaps($region as cts:polygon) as xs:string* {
    let $arraypre := 
        for $v in cts:polygon-vertices($region)
        let $lat := cts:point-latitude($v) cast as xs:string
        let $lon := cts:point-longitude($v) cast as xs:string
        return concat("new google.maps.LatLng(", $lat, ",", $lon, ")")
    return concat("[", string-join($arraypre, ", "), "]")
};