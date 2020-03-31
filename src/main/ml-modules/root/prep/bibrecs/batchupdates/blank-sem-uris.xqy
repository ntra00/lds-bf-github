xquery version "1.0-ml";
(:  query to redo mxe for subfields, 


 		collection batch is "/idmain-process/12-29-17update/"

To use this as a template, copy and modify the batch and the query variables

 :)
declare namespace index	        = 'info:lc/xq-modules/lcindex';
declare namespace idx  			= 'info:lc/xq-modules/lcindex';
declare namespace mxe	        = "http://www.loc.gov/mxe";

(: ------------------------------------------------------------------------------ :)
let $batch:="/bibframe-process/2018-04-05/"

let $query:= cts:element-value-query(xs:QName('sem:triples'), '')

let $uri-set:=
         cts:uris((),(),   
			 cts:and-query(( cts:collection-query("/catalog/"),                        
		 					cts:and-not-query( 
                                            $query,
                                            cts:collection-query($batch))
                            
						 ))
 		)
let $uris:=
       	for $i in $uri-set[1]
			
	          let $bibid1:=fn:replace(fn:tokenize($i,'/')[fn:last()],'^c0+','')
			  let $bibid:=if (fn:contains($i,"instances") or fn:contains($i,"items")) then
			  		fn:concat(fn:substring($bibid1, 1, fn:string-length($bibid1)-8),".xml")
				else 
					$bibid1

(:			let $_:=xdmp:log(fn:concat("xxx:", $i),"info")
			let $_:=xdmp:log(fn:concat("yyy:", $bibid1),"info")
			let $_:=xdmp:log(fn:concat("zzz:", $bibid),"info")
:)
          return concat('/bibframe-process/records/',$bibid)
let $ct:=count($uris)

 	return (xdmp:log(fn:concat('CORB blank index ',$ct,' uris started'),'info'),			
			
			  (count($uris),$uris)
		)
 
