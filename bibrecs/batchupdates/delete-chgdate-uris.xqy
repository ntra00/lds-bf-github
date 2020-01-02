xquery version "1.0-ml";
(:  query to redo mxe for subfields, 


 	can be id-main database , not lds

	collection batch is "/idmain-process/12-29-17update/"

To use this as a template, 
				copy and modify the batch and 
				the query variables
				modify the log text
				if its just a reload, type "reload" as param 2
				./corb-shell.sh blank-works reload > ../logs/blank-works-reload.txt
 :)
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

(: ------------------------------------------------------------------------------ :)

let $batch:="/bibframe-process/2018-02-07/"
let $comment:="this is voyager 0000 system date/time removal "
let $node:="bf:changeDate"

let $query:= cts:and-not-query(
                       cts:and-query(( cts:collection-query("/resources/instances/"),
                                           cts:element-query(xs:QName($node),"0000-00-00T00:00:00")
                                         )),
                              cts:collection-query("/bibframe/mergedInstances/")
                      )    

let $uris:=
         cts:uris((),(),   cts:and-not-query( 
                                            $query,
                                            cts:collection-query($batch))
                             )
(: this is to get the marcxml uri; skip it :)
(:let $uris:=
       	for $i in $uris
	          let $bibid:=fn:replace(fn:tokenize($i,'/')[fn:last()],'^c0+','')
          return concat('/bibframe-process/records/',$bibid)
  
:)

        let $ct:=(count($uris))

 	return (xdmp:log(fn:concat('CORB blank works reload ',$batch, ' ', $ct,' uris started'),'info'),
			  (count($uris),$uris)
		)
 
