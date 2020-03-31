xquery version "1.0-ml";
(:  query to redo mxe for subfields
collection batch is "/idmain-process/12-29-17update/"

	To use this code as  a template, 
	set the batch and the query in the uris file,
	use the same batch here,
	Modify the code in local:fix(), but keep the timestamp update.
	Decide if your fix means you have to recalculate the idx and/or the sem triples
	replace what's new
	The logging and adding to collections stays the same. If you have to run this more than once, it will exclude the stuff you've already fixed.
	Figure out how to run it for id-main.



 :)
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace mets      = "http://www.loc.gov/METS/";
declare namespace xdmp      = "http://marklogic.com/xdmp";
declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace mxe	        = "http://www.loc.gov/mxe";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";

declare variable $URI as xs:string external;

declare  function local:fix($d,$batch) {
	let $doc :=doc($d)

	(:let $marcxml:=$doc//marcxml:record:)

	let $new:=try {
	xdmp:node-delete($doc//bf:changeDate[fn:string(.)="0000-00-00T00:00:00"])

	 } catch ($e){
                              xdmp:log(fn:concat("CORB ", $batch, " failed for : ",$URI), "info")
                   }

          
	let $time:=attribute LASTMODDATE {fn:current-dateTime()}
          
          (: 	let $work:=$doc//rdf:RDF
          		let $work-sem := bf4ts:bf4ts(  $work  )
          		let $work-bfindex :=  bibframe2index:bibframe2index($work, <mxe:record></mxe:record>)
		  :)
          
          
          return
                (
				xdmp:node-replace($doc//mets:metsHdr/@LASTMODDATE,$time)
                )
 
        (:,                
                xdmp:node-replace($doc//mets:dmdSec[@ID="mxe"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/mxe:record,$new)
			xdmp:node-replace($doc//mets:dmdSec[@ID="semtriples"]//mets:xmlData/sem:triples, $new)
        	xdmp:node-replace($doc//mets:dmdSec[@ID="index"]//mets:xmlData/index:index, $work-bfindex )
		:)
 
};
(: ------------------------------------------------------------------------------ :)
let $batch:="/bibframe/2018-02-07/"



  let $fix:= 	try {
                        (	local:fix($URI, $batch),
							
							xdmp:document-add-collections($URI,$batch),
							
							xdmp:log(fn:concat("CORB ", $batch," done for : ",$URI), "info")
						)

                   } catch ($e){
                              xdmp:log(fn:concat("CORB ", $batch, " failed for : ",$URI), "info")
                   }

  return (
 		$fix
  			
)

