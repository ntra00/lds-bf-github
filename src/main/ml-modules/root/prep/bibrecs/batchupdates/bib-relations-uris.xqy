xquery version "1.0-ml";
declare namespace   index	        = 'info:lc/xq-modules/lcindex';
declare namespace   idx  			= 'info:lc/xq-modules/lcindex';
declare namespace   mxe	        = "http://www.loc.gov/mxe";
declare namespace   mets       		    = "http://www.loc.gov/METS/";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   owl                 = "http://www.w3.org/2002/07/owl#";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf             = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   ri                  = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   bf              	= "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace   mlerror	            = "http://marklogic.com/xdmp/error"; 
(:  query to redo bf4ts for subfields, 
 	can be id-main database , not lds

	collection batch is (NOT) /bibframe-process/2018-05-11c/"

To use this as a template, 
				copy and modify the batch and 
				the query variables
				modify the log text
				if its just a reload, type "reload" as param 2
				./corb-shell.sh blank-works reload > ../logs/blank-works-reload.txt

			set $debug to false and it will run the whole set
If the program fails, re-running it starts from where it left off because the query is "not in this batch" and the code
adds a record to the batch if the patch is successfully applied.
 :)

(: snippets :)
(: this is to get the marcxml uri; skip it :)
(:let $uris:=
       	for $i in $uris
	          let $bibid:=fn:replace(fn:tokenize($i,'/')[fn:last()],'^c0+','')
          return concat('/bibframe-process/records/',$bibid)
  
:)

(: ------------------------------------------------------------------------------ :)
let $debug:=fn:true()
let $debug:=fn:false()



let $batch:="/bibframe-process/2018-07-09a/"
let $comment:="this finds and reloads stubs from works not merged"
(: already did version $s :)
(: need l, h o, s :)

let $query:=
	 	
             		 cts:collection-query("/bibframe/stubworks/")
         
let $uris:=
         cts:uris((),(), 
		 	  cts:and-not-query( 
                                 $query,
                                 cts:collection-query($batch)
					   		)
                 )

let $uris:=if ($debug) then 
				$uris[1 to 10]
			else 
				$uris

let $uris:= for $d in $uris
			let $node1:=fn:tokenize($d,"/")[fn:last()]
			let $node:=fn:substring($node1, 1, 10)
			let $reload-node:=fn:concat("/bibframe-process/records/",fn:replace($node,"^c0+",""),".xml")
			let $main-work:=cts:uris((),(), 
								cts:and-query((
   												cts:collection-query("/resources/works/"),
												cts:element-value-query(xs:QName("idx:token"),$node)
											))
							)[1]
			return 
				if (index-of(xdmp:document-get-collections( $main-work),"/bibframe/notMerged/") ) then  
							$reload-node 
				else ()
(:let $bibids:=
        	for $i in $uris
	          let $bibid:=fn:replace(fn:tokenize($i,'/')[fn:last()],'^c0+','')
			  let $bibid:=if (fn:contains($i,"/instances/") or fn:contains($i,"/items/")) then
			  		fn:substring($bibid, 1, fn:string-length($bibid)-4)
				else $bibid

          return concat('/bibframe-process/records/',$bibid)
		  :)
          let $ct:=(count($uris))
					   
 	return (  xdmp:log(fn:concat('CORB bib stub unmatched reload ',$batch, ' ', $ct,' uris started'),'info'),
			  ($ct,$uris)

		)
 
