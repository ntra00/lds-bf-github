xquery version "1.0-ml";

(:
let $uris := cts:uris((), ("ascending", "concurrent"), cts:collection-query("/bibframe-process/records/"))
:)


let $uris := 
	cts:uris('/bibframe-process/records/022.xml',
('ascending', 'concurrent', 'limit=1000000'), cts:collection-query('/bibframe-process/records/'))


(:(1,"/bibframe-process/records/7264627.xml"):)

return (fn:count($uris) , $uris)

