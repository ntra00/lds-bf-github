xquery version "1.0-ml";

(:18mil to 20mil:)
let $uris := cts:uris('/lscoll/lcdb/holdings/9/9/7/3/1/4/7/9973147.xml', ('document', 'limit=2000000', 'item-order', 'concurrent'), cts:collection-query("/lscoll/lcdb/holdings/"))
let $last := $uris[last()]
let $save := xdmp:save("/tmp/corblast.txt", text { $last })
return (count($uris), $uris)
