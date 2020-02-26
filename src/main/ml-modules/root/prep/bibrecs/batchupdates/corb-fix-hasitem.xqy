xquery version "1.0-ml";

declare default element namespace "http://www.loc.gov/MARC21/slim";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";

declare namespace mets      = "http://www.loc.gov/METS/";
declare namespace xdmp      = "http://marklogic.com/xdmp";

declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace bf	        = "http://id.loc.gov/ontologies/bibframe/";
(:
instances have bf:hasItem with rdf:about instead of  rdf:resource; replace that node 

:)
(: corb will pass in a URI of a MARCXML collection document from the /bibframe-process/ collection :)
declare variable $URI as xs:string external;
declare variable $delete-marcxml-collections := fn:false();

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