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

declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace mxe	        = "http://www.loc.gov/mxe";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";
import module namespace marcxml2mxe  = "info:lc/id-modules/mxe" at "module.MARCXML-2-MXE.xqy";
declare variable $URI as xs:string external;

declare  function local:fix($d) {
	let $doc :=doc($d)
	let $marcxml:=$doc//marcxml:record
	let $new:=marcxml2mxe:marcxml2mxe($marcxml)
          
	let $time:=attribute LASTMODDATE {fn:current-dateTime()}
          
          (: 	let $work:=$doc//rdf:RDF
          		let $work-sem := bf4ts:bf4ts(  $work  )
          		let $work-bfindex :=  bibframe2index:bibframe2index($work, <mxe:record></mxe:record>)
		  :)
          
          
          return
                (xdmp:node-replace($doc//mets:metsHdr/@LASTMODDATE,$time),                
                xdmp:node-replace($doc//mets:dmdSec[@ID="mxe"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/mxe:record,$new)
                )
 
        (:	xdmp:node-replace($doc//mets:dmdSec[@ID="semtriples"]//mets:xmlData/sem:triples, $new)
        	xdmp:node-replace($doc//mets:dmdSec[@ID="index"]//mets:xmlData/index:index, $work-bfindex )
		:)
 
};
(: ------------------------------------------------------------------------------ :)
let $batch:="/idmain-process/12-29-17update/"



  let $fix:= 	try {
                        (	local:fix($URI),
							
							xdmp:document-add-collections($d,$batch),
							
							xdmp:log(fn:concat("CORB ", $batch," done for : ",$URI), "info")
						)

                   } catch ($e){
                              xdmp:log(fn:concat("CORB ", $batch, " failed for : ",$URI), "info")
                   }

  return (
 		
  			
)




 for $d  in doc($URI) 
                (:return $d//mets:dmdSec[@ID="bibframe"]//bf:hasItem:)
		let $fixed:= ($d//mets:dmdSec[@ID="bibframe"]//bf:hasItem[@rdf:about])                
              return 
               (for $has in $d//mets:dmdSec[@ID="bibframe"]//bf:hasItem[@rdf:about]
                    return if ($has/@rdf:about) then
			                        let $item:=fn:tokenize(fn:string($d/mets:mets/@OBJID),"\.")[fn:last()]
			                          return 
			                                    (
			                                     try {
			                                        xdmp:node-replace($has,<bf:hasItem rdf:resource="http://id.loc.gov/resources/items/{$item}"/>)                                  
                                        
			                                       } catch ($e){
			                                                  xdmp:log(fn:concat("CORB fix hasItem  rdfabout failed for : ",$URI), "info")
			                                       }
			                                    )   
                           else
                           	 xdmp:log(fn:concat("CORB fix hasItem  skipped rdfabout not found for : ",$URI), "info")
                        ,
                          if ($fixed) then
                           try{
                                         xdmp:node-replace($d/mets:mets/mets:metsHdr,  <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>)
                                         }
                                         catch($e){$e}                                                                    
                           else ()
                         ,xdmp:log(fn:concat("CORB fix hasItem  rdfabout for : ",$URI), "info")
                         )