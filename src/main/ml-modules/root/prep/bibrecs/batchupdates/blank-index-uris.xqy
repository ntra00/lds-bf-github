xquery version "1.0-ml";
(:  query to redo mxe for subfields, 


 	id-main database , not lds

	collection batch is "/idmain-process/12-29-17update/"

To use this as a template, copy and modify the batch and the query variables

 :)
declare namespace index	        = 'info:lc/xq-modules/lcindex';
declare namespace idx  			= 'info:lc/xq-modules/lcindex';
declare namespace mxe	        = "http://www.loc.gov/mxe";

(: ------------------------------------------------------------------------------ :)
let $batch:="/bibframe-process/2018-01-24/"

let $query:= cts:element-value-query(xs:QName('index:index'), '')

let $uris:=
         cts:uris((),(),   cts:and-not-query( 
                                            $query,
                                            cts:collection-query($batch))
                             )

let $uris:=
       	for $i in $uris
	          let $bibid:=fn:replace(fn:tokenize($i,'/')[fn:last()],'^c0+','')
          return concat('/bibframe-process/records/',$bibid)
          let $ct:=(count($uris))

 	return (xdmp:log(fn:concat('CORB blank index ',$ct,' uris started'),'info'),
			xdmp:log($uris,'info'),
			  (count($uris),$uris)
		)
 
