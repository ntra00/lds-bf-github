xquery version "1.0-ml";
(: 
==========================================================================================================

2018-03-01: new approach, merged instances, get their putative work, see if it is instanceOf or consolidates anything, if so, skip, if not, delete
			uses sparql
return (xdmp:log(fn:concat("QCONSOLE - deleting orphan work ",$d),"info"), connected to nametitles not c's



starting from merged instances is no longer useful;
now I start from what has never been reloaded.(works) and see if their instance 0001 links back to them or something else


=========================================================================================================

:)
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   owl                 = "http://www.w3.org/2002/07/owl#";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf             = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mxe					        = "http://www.loc.gov/mxe";
declare namespace   ri                  = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   bf              	= "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace   index               = "info:lc/xq-modules/lcindex";
declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace bibs2mets 			= "http://loc.gov/ndmso/bibs-2-mets" at "/admin/bfi/bibrecs/modules/module.bibs2mets.xqy";
(:count(collection("/bibframe/mergedInstances/")):)

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
let $DEBUG:=fn:false()

let $merged-instances:= 
if ($DEBUG) then
			 cts:uris(
		        '/lscoll/lcdb/instances/',
		        (),
		        cts:collection-query('/bibframe/mergedInstances/')    
		    )[1 to 5]
	else
			cts:uris(
		        '/lscoll/lcdb/instances/',
		        (),
		        cts:collection-query('/bibframe/mergedInstances/')    
		    )
let $uris:=   
	 for $d  in $merged-instances
    
    	return if (fn:not(fn:ends-with($d,"0001.xml"))) then
			     ()
		    	else
		       		let $id:=fn:tokenize($d,"/")[fn:last()]
    
			    	let $id:=fn:replace($id,"0001.xml","")
    
    
				    let $baseWork:=fn:replace($d,"instances","works") (: this is the work an unmerged instance would have gone to. :)
				    let $workdocid:=fn:replace($baseWork,"0001.xml",".xml")
        
				   return if (fn:not(doc-available($workdocid))) then
  									(:if you can't find the work, it's been deleted? :)
    							()
  							else (: check if the work is an instanceOf some instance..." :)
							 
							 let $work-uri:=fn:concat("http://id.loc.gov/resources/works/",$id)
							 let $query := <query><![CDATA[
										PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
										PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
										PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
										PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	            
										SELECT   ?instance  
										WHERE {
							  				    {  		
								  					?instance bf:instanceOf ?uri 
							          			}
							          	UNION	{
							              			?uri bflc:consolidates ?instance . 				
										    	}  
							          		}limit 10
								        ]]></query>
                          
 
							    let $q1:=cts:collection-query(  (    "/catalog/"     ))
    
								let $params := 
							        map:new((
							            map:entry("uri", sem:iri($work-uri)       )
							        ))
							    let $results := sem:query-results-serialize( 
							     sem:sparql($query, $params,(),  $q1 ))//sparql:results
     
							      return 
							          if(count($results//sparql:result) =0 ) then
									  	$workdocid
							      		(: results at all may mean, reload all these (and the rest of the nametitle set:)
							      		else 
											()

let $_:=xdmp:log(fn:concat("CORB  orphans delete: count of instances merged: ",count($merged-instances)),"info")      

return (count($uris), $uris)

(:================================================= OLD code =========================================:)

(:
let $res:= 
for $u in  cts:uris(
        '/lscoll/lcdb/works/',
        (),
        cts:not-query((
            cts:collection-query('/bibframe-process/reloads/2017-09-16/')            
        ))
    )
	
			let $workstub:=fn:tokenize($u,"/")[fn:last()]
            let $workid:=fn:replace($workstub,".xml", "")
            let $instanceuri:=fn:replace($u,"works", "instances")
            let $instanceuri:=fn:replace($instanceuri,".xml", "0001.xml")


  let $instance-of:= doc($instanceuri)/mets:mets/mets:dmdSec[@ID="bibframe"]/mets:mdWrap/mets:xmlData/rdf:RDF/bf:Instance//bf:instanceOf[1]/@rdf:resource


  let $match:=
      for $m in $instance-of
      return if (fn:starts-with(fn:tokenize($m,"/")[fn:last()],"n")) then
           					$u
			            else  if (fn:not(fn:tokenize($m,"/")[fn:last()]=fn:tokenize($workid,"/")[fn:last()])) then
            						$u				
				        else          					  
							  ()


return for $u in $match            
    let $uri:=if ($u  and doc-available($u)) then
              if (doc($u)//bflc:consolidates) then
                 xdmp:log(fn:concat("CORB - skipping deletion orphan work for consolidated: ",$workid,  fn:string(doc($u)//bflc:consolidates[1]/@rdf:resource) ),"info")
                else $u                   
              else ()
  return ($uri)

return (count($res), $res)


:)
