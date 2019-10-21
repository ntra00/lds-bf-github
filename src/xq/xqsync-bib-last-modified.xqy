xquery version "1.0-ml";

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
declare namespace mets = "http://www.loc.gov/METS/";

let $begintime as xs:string := lp:get-param-single($lp:CUR-PARAMS, "begin", "2011-05-11T00:00:00")
let $beginxsdt := xs:dateTime($begintime)
let $endxsdt := fn:current-dateTime()

for $x in cts:search(/mets:mets, cts:and-query((cts:collection-query(("/catalog/", "/deleted/")), 
cts:element-attribute-range-query(xs:QName("mets:metsHdr"),
xs:QName("LASTMODDATE"), ">", $beginxsdt), cts:element-attribute-range-query(xs:QName("mets:metsHdr"), xs:QName("LASTMODDATE"), "<", $endxsdt))))
return xdmp:node-uri($x)
