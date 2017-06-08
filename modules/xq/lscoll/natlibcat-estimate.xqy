xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";

let $count := xdmp:estimate(cts:search(collection($cfg:DEFAULT-COLLECTION), ()))
return
    concat("&nbsp;(&nbsp;", format-number($count, "##,###,###"), " records&nbsp;)")