xquery version "1.0-ml";
(: split marcxml collections  on daily batches of bibs :)
(:
Batch date will usually be today, but could be passed in manually
called by corb-bibs-daily.sh

:)

declare variable $BATCHDATE as xs:string external ; (: "2017-06-27" :)
declare variable $BIBTYPE as xs:string external ;   (: A for adds and edits, D for deletes :)
	let $batchdate:=if (fn:matches($BATCHDATE,"^20")) then  $BATCHDATE else ""
	let $bibtype:= if (fn:matches($BIBTYPE,"(A|D)")) then  $BIBTYPE else ""
	
	let $uris := cts:uri-match(fn:concat("/bibframe-process/chunks/",$BATCHDATE,"/",$BIBTYPE,"/*")) 	

	return (fn:count($uris) , $uris)
