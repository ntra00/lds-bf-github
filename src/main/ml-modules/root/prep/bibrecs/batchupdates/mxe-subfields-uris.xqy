xquery version "1.0-ml";
(:  query to redo mxe for subfields, 


 	id-main database , not lds

	collection batch is "/idmain-process/12-29-17update/"

To use this as a template, copy and modify the batch and the query variables

 :)

declare namespace mxe	        = "http://www.loc.gov/mxe";

(: ------------------------------------------------------------------------------ :)
let $batch:="/idmain-process/12-29-17update/"

let $query:= cts:element-query( xs:QName("mxe:subfield_a"), cts:and-query(() ) )  

let $uris:=
         cts:uris((),(),   cts:and-not-query( 
                                            $query,
                                            cts:collection-query($batch))
                             )[1 to 5]

let $count:= count($uris)
                             
return ($count,$uris)
