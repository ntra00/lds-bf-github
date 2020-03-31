xquery version '1.0-ml';
		declare namespace mxe  = 'http://www.loc.gov/mxe';
		declare namespace idx  = 'info:lc/xq-modules/lcindex';
		declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
		declare namespace bflc = 'http://id.loc.gov/ontologies/bflc/';

 	let $uris:=cts:uris((), (),  
 		cts:element-query(xs:QName( 'idx:language' ), 'yid' )

	let $uris:=
        	for $i in $uris
	          let $bibid:=fn:replace(fn:tokenize($i,'/')[fn:last()],'^c0+','')
			  let $bibid:=if (fn:contains($i,"/instances/") or fn:contains($i,"/items/")) then
			  		fn:substring($bibid, 1, fn:string-length($bibid)-4)
				else $bibid

          return concat('/bibframe-process/records/',$bibid)
          let $ct:=(count($uris))

 	return (xdmp:log(fn:concat('CORB find-reload ',$ct,' uris for ','idx:language','= ', 'yid'),'info'),
			  (count($uris),$uris)
		)
 
