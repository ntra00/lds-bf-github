xquery version '1.0-ml';
		declare namespace mxe  = 'http://www.loc.gov/mxe';
		declare namespace idx  = 'info:lc/xq-modules/lcindex';
		declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
		declare namespace bflc = 'http://id.loc.gov/ontologies/bflc/';

let $batch:='/bibframe-process/2017-01-11-update/'

let $uris:=cts:uris(
        	'/lscoll/lcdb/works/',
        	(),
        	 cts:and-not-query(
                                        cts:and-query((
                                        cts:word-query('from old catalog'),
                                        cts:collection-query('/bibframe/notMerged/')
                                        ))
                                  ,
                                        cts:collection-query($batch)
                                ) 
			)


	let $uris:=
        	for $i in $uris
	          let $bibid:=fn:replace(fn:tokenize($i,'/')[fn:last()],'^c0+','')
          return concat('/bibframe-process/records/',$bibid)
          let $ct:=(count($uris))

 	return (xdmp:log(fn:concat('CORB fromoldcat ',$ct,' uris started'),'info'),
			  (count($uris),$uris)
		)
 
