
xquery version '1.0-ml';

	let $uris := cts:uris((),(),cts:collection-query('/bibframe-process/load_splitmarcxml/2019-07-26/'))
	return (fn:count($uris) , $uris)


