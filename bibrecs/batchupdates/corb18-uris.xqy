xquery version "1.0-ml";


let $uris := 
	cts:uris('/bibframe-process/records/9999999.xml',
		('ascending', 'concurrent', 'limit=1000000'), cts:collection-query('/bibframe-process/records/'))

return (fn:count($uris) , $uris)
