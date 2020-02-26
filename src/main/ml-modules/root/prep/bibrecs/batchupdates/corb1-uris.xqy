xquery version "1.0-ml";

(:
let $uris := cts:uris((), ("ascending", "concurrent"), cts:collection-query("/bibframe-process/records/"))
:)

let $uris := 
cts:uris('/bibframe-process/records/10934965.xml',
('ascending', 'concurrent', 'limit=1000000'), cts:collection-query('/bibframe-process/records/'))

return (fn:count($uris) , $uris)
