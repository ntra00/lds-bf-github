xquery version "1.0-ml";

module namespace xslt="info:lc/xq-modules/xslt";
declare namespace mlhttp="xdmp:http";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace marcxml="http://www.loc.gov/MARC21/slim";
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mxe="mxens";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace map="http://marklogic.com/xdmp/map";
declare namespace error="http://marklogic.com/xdmp/error";

declare variable $xslt:exist := 'http://localhost:8675/exist/rest/db/xslt/xslt.xq';

(:

This module will send a HTTP POST to eXist (running locally on marklogic1) to achieve 
an XSLT transformation.  Users must supply a XML node, along with the name of an XSLT 
(stored in eXist), and any necessary parameters needed by the XSLT to produce a result.

Parameters:

Param 1: One XML node to be transformed.
Param 2: One XSL file name stored in eXist, relative to /db/xslt, that will perform the transformation
Param 3: One XML node for parameters to be processed, formatted as:
    
    <parameters>
        <param name="myparamname" value="myparamvalue"/>
    </parameters>

Before sending the POST and payload, parameters get mappped to HTTP request headers in the form of:

    <X-LOCParam-myparamname>myparamvalue</X-LOCParam-myparamname>
    
so as to not conflict with any reserved HTTP request headers from RFC 2616.  

This returns a HTTP response from eXist with one XML node.  The node contains response headers in XML that preecede the XML of interest from the XSLT transformation.

:)

declare function xslt:exist-transform($payload as element(), $xsl as xs:string, $params as element()) {
    let $error := <error>XSLT filename must be a HTTP URL reference or a full path for eXist's XSLT directory.  e.g.: http://blah.org/my.xsl or /db/xslt/filename.xsl .  Your path was: {$xsl}</error>
    let $lcparams := for $p in $params/param return element {fn:QName("xdmp:http", fn:concat('X-LOCXsltParam-', fn:string($p/@name)))} {fn:data($p/@value)}
    let $options := 
            <mlhttp:options>
                <mlhttp:authentication method="basic">
                    <mlhttp:username>{xdmp:quote("natliba")}</mlhttp:username>
                    <mlhttp:password>{xdmp:quote("natliba")}</mlhttp:password>
                </mlhttp:authentication>
                <mlhttp:headers>
                    <mlhttp:X-LOCXsltUri>{$xsl}</mlhttp:X-LOCXsltUri>
                    {$lcparams}
                </mlhttp:headers>
                <mlhttp:data>{xdmp:quote($payload)}</mlhttp:data>
             </mlhttp:options>
    return
        try {
            <httpresponse>{xdmp:http-post($xslt:exist, $options)}</httpresponse>
        } catch($e) {
            (xdmp:log($e, "error"), <error:error>{($e//error:format-string, $e//error:expr, $e//error:data)}</error:error>)
        }
};

declare function xslt:ml-transform($payload as element(), $xsl as xs:string, $params as element()) as element()* {
    let $xslt:= xdmp:document-get($xsl)/xsl:stylesheet
    let $param-map := 
        if (fn:exists($params/param)) then
            let $map := map:map()
            let $put := for $p in $params/param return map:put($map, fn:string($p/@name), fn:data($p/@value) cast as xs:string)
            return $map
        else
            map:map()
    return
        try {
            <httpresponse>{xdmp:xslt-eval($xslt, $payload, $param-map)}</httpresponse>
        } catch($e) {
            xdmp:log($e, "error")
        }
};

declare function xslt:transform($payload as element(), $xsl as xs:string, $params as element()) as element()* {
    xslt:ml-transform($payload, $xsl, $params)
};

declare function xslt:transform($payload as element(), $xsl as xs:string, $params as element(), $engine as xs:string?) {
    if (fn:matches($engine, "exist", "i")) then
        xslt:exist-transform($payload, $xsl, $params)
    else
        xslt:ml-transform($payload, $xsl, $params)
};
