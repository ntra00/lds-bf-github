xquery version "1.0-ml";

(:begins 13000001:)
let $uris := cts:uris('/lscoll/lcdb/bib/7/9/7/1/9/2/4/7971924.xml', ('document', 'limit=2000000', 'item-order', 'concurrent'), cts:collection-query("/lscoll/lcdb/bib/"))
let $last := $uris[last()]
let $save := xdmp:save("/tmp/corblast.txt", text { $last })
return (count($uris), $uris)