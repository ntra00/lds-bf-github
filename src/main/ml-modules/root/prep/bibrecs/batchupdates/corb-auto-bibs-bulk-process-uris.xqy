
xquery version '1.0-ml';
(:  process everything not in collection cts:collection-query(/bibframe-process/reloads/2017-09-16/)
:   started at 2017-10-17
:)
	let $uris := 
	 cts:uris(
        '/lscoll/lcdb/works/',
        (),
        cts:not-query((
            cts:collection-query('/bibframe-process/reloads/2017-09-16/')            
        ))
    )
    let $uris:=
        for $u in $uris
            let $uri:=fn:tokenize($u,'/')[fn:last()]
            let $uri:=fn:concat('/bibframe-process/records/', fn:replace($uri,'^c0+',''))
            return $uri
    
	return (fn:count($uris) , $uris)


