xquery version "1.0-ml";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace mets      = "http://www.loc.gov/METS/";
declare namespace xdmp      = "http://marklogic.com/xdmp";
declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace mxe	        = "http://www.loc.gov/mxe";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";

import module namespace 		bf4ts   			= "info:lc/xq-modules/bf4ts#"   		 at "../modules/module.BIBFRAME-4-Triplestore.xqy";

(:  query to redo bf4ts
	collection batch is "/bibframe-process/2018-05-11c/"
	To use this code as  a template, 
	set the batch and the query in the uris file,
	use the same batch here,
	Modify the code in local:fix(), but keep the timestamp update.
	Decide if your fix means you have to recalculate the idx and/or the sem triples
	replace what's new
	The logging and adding to collections stays the same. If you have to run this more than once, it will exclude the stuff you've already fixed.
	
	



snippets:
let $marcxml:=$doc//marcxml:record

	let $new:=try {
					xdmp:node-delete($doc//bf:changeDate[fn:string(.)="0000-00-00T00:00:00"])

			 } catch ($e){
                              xdmp:log(fn:concat("CORB ", $batch, " failed for : ",$URI), "info")
                   }
	
               
                xdmp:node-replace($doc//mets:dmdSec[@ID="mxe"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/mxe:record,$new)
			xdmp:node-replace($doc//mets:dmdSec[@ID="semtriples"]//mets:xmlData/sem:triples, $new)
        	xdmp:node-replace($doc//mets:dmdSec[@ID="index"]//mets:xmlData/index:index, $work-bfindex )
		

 :)

declare variable $URI as xs:string external;

declare  function local:fix($d,$batch) {

	let $doc :=doc($d)
       
	let $time:=attribute LASTMODDATE {fn:current-dateTime()}
          
           	let $work:=$doc/mets:mets/mets:dmdSec[@ID="bibframe"]//rdf:RDF
          	let $work-sem := bf4ts:bf4ts(  $work  ) (: logged, null if failed:)
								
          		
return
	  if ($work-sem) then
           
			let $_:=xdmp:node-replace($doc//mets:metsHdr/@LASTMODDATE,$time)			
			let $_:=xdmp:node-replace($doc/mets:mets/mets:dmdSec[@ID="semtriples"]/mets:mdWrap/mets:xmlData/sem:triples, $work-sem[1])

			return 
				(xdmp:log(fn:concat("CORB ", $batch, " updated : ",$URI), "info"))
            
			else 
					xdmp:log(fn:concat("CORB ", $batch, " failed for : ",$URI), "info")
 
 
};
(: ------------------------------------------ Main Code ------------------------------------ :)
let $batch:="/bibframe-process/2018-05-11c/"

return 		try {
                        (	local:fix($URI, $batch),
							
							xdmp:document-add-collections($URI,$batch)							
							
						)

                   } catch ($e){
						()
                   }


