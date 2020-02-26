xquery version "1.0-ml";
(:  query to redo mxe for subfields, 

from old cat reload

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

let $batch:="/bibframe-process/2018-02-21/"
(: is a work, AND has a blank bf:Work, and is not merged:)
let $query:= cts:and-not-query( 
                       cts:and-query((
                                         cts:collection-query("/resources/works/"),
                                          cts:collection-query("/catalog/"),
                              
                              cts:word-query("from old catalog")
                              ))
                                                        ,
                           cts:collection-query("/bibframe/consolidatedBibs/")
                           )
  
  
        
let $uris:=
         cts:uris((),(),   cts:and-not-query( 
                                            $query,
                                            cts:collection-query($batch))
                             )

let $uris:=
       	for $i in $uris
	          let $bibid:=fn:replace(fn:tokenize($i,'/')[fn:last()],'^c0+','')
          return concat('/bibframe-process/records/',$bibid)
         
let $ct:=count($uris)

	return (xdmp:log(fn:concat('CORB from old catalog reload ',$batch, ' ', $ct,' uris started'),'info'),
			  ($ct,$uris)
		)
 
