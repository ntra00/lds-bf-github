xquery version "1.0-ml";
(:uri list of instances that were merged, deduped, for reload after loading name/titles
call this like: 
    nohup ./corb-bibs-rematch.sh corb-bibs-reload-merged-uris.xqy ../logs/etc 

:)
let $set:= 
  for  $u in cts:uris(
(),(),
cts:and-not-query(	
			cts:collection-query(("/bibframe/mergedInstances/"))
			, cts:collection-query("/bibframe-process/reloads/2017-09-16/")
)
)

		let $bibid:=fn:tokenize($u,"/")[fn:last()]
		let $bibnum:=fn:replace(fn:substring($bibid,1,10),"^c0+","")
		let $uri:= fn:concat("/bibframe-process/records/",$bibnum,".xml")
		return $uri
let $real-set:=fn:distinct-values($set)

return (count($real-set), $real-set)

