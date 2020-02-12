xquery version "1.0-ml";

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
declare namespace r = "http://www.indexdata.com/turbomarc";

let $begintime as xs:string := lp:get-param-single($lp:CUR-PARAMS, "begin", "2011-05-11T00:00:00")
let $beginxsdt := xs:dateTime($begintime)
let $endxsdt := fn:current-dateTime()

for $x in cts:search(/r:r, cts:and-query((cts:collection-query(("/lscoll/lcdb/holdings/")), cts:element-attribute-range-query(xs:QName("r:r"), xs:QName("dT"), ">", $beginxsdt), cts:element-attribute-range-query(xs:QName("r:r"), xs:QName("dT"), "<", $endxsdt))))
return xdmp:node-uri($x)