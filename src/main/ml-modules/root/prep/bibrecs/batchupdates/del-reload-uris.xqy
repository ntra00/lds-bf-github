xquery version "1.0-ml";
(: !!! works if there is a nametitle auth to merge onto; otherwise, you need a seed doc to attach to. :)
(: this takes a seed doc,  (or a seed nametitle)
does a search for it's name title (OR nonsortnametitle)
and finds  all works.
then it does a sparql for bflc:consolidates or instanceOf me, to list all the c numbers associated with all the works.
(skips any n numbers
dedups, deletes works, instances, items for them
filters down to bib id, creates 'reprocess-bib' bash script line for each.
run each one at a time to see them merge onto the N number.
the OR stuff will only merge if I add the OR code to the merging match.

===================== Might try taking a list of seed name/titles, find them all, delete them all, make a list of all , with anchors labelled.
then a separate process filters ont he anchors and reloads them and filters out the anchors , counts and loads them.

:)
import module namespace mem 		= "http://xqdev.com/in-mem-update" at "/xq/modules/in-mem-update.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
declare namespace marcxml="http://www.loc.gov/MARC21/slim";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace   bf              	= "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";

declare variable $NAMETITLE-OFFSET as xs:string external;
 

declare function local:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};
declare function local:makedocid($bibid)			{

let $dirtox := local:chars-001($bibid)
			(:let $destination-root := "/lscoll/lcdb/instances/":)
		    let $dir := fn:concat(string-join($dirtox, '/'), '/')
        
        return $dir
        };
   
(:~
:)
(: ============================================= start here =============================================:)
(:
		let $uri:=()
		let $doc:=if ($uri) then doc($uri)/mets:mets/mets:dmdSec[@ID="bibframe"] else ()
		let $paddedID:=fn:replace(fn:tokenize($uri,"/")[fn:last()], ".xml", "")

		let $name:=$doc//rdf:RDF/bf:Work/bf:contribution[1]//bflc:name00MatchKey[1]
		let $title:=$doc//rdf:RDF/bf:Work/bf:title/bf:Title[1]
		let $title1:=fn:string($title/bf:mainTitle)
		let $nonsortTitle:=fn:string($title/bflc:titleSortKey)
		let $nameTitle:=fn:concat(fn:string($name), " ", $title1)

		let $nonsortnameTitle:=if ($title1 !=  $nonsortTitle ) then
		      fn:concat(fn:string($name), " ",$nonsortTitle)
		      else ()
:)

let $debug:=fn:false()
let $debug:=fn:true()
(:music:)

let $terms:= if ($NAMETITLE-OFFSET="0") then
			<terms><term>Shakespeare, William, 1564-1616. Hamlet</term></terms>
		else 
			let $f:=xdmp:filesystem-file("/marklogic/backups/del-reload.xml")
				return xdmp:unquote($f)

let $offset:= if ($NAMETITLE-OFFSET="0") then
					 1
				else
					 fn:number($NAMETITLE-OFFSET)

(:----------------- direct input of search ------------------:)

let $nonsortnameTitle:=	""
let $nameTitle:=	fn:string($terms//*:term[$offset])
let $_:= xdmp:log(fn:concat("CORB term :",$NAMETITLE-OFFSET, ": ",$nameTitle), "info")

	(:"Twain, Mark, 1835-1910. The Adventures of Huckleberry Finn":)
(:----------------- direct input of search ------------------:)

return if ($nameTitle="") then
		()
		else
let $searchcode:= if ($nonsortnameTitle!="") then									
						cts:and-not-query(
		                            cts:and-query(( 
		                                cts:collection-query("/resources/works/"),
										                 cts:collection-query("/catalog/"),
		            		                 cts:or-query((
                               cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nonsortnameTitle),
                                   ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) ,
                               cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), 
                                 ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)
                            ))
                            
		            		        ))
                   			 ,
    		        	cts:collection-query("/bibframe/stubworks/")
    		       		)
else
						cts:and-not-query(
		                            cts:and-query(( 
		                                cts:collection-query("/resources/works/"),
										 cts:collection-query("/catalog/"),
		            		            cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), 
										("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)            		            
		            		        )),
		            		        cts:collection-query("/bibframe/stubworks/")
		            		        )
									
								
let $found:=cts:uris((),(),$searchcode)

let $set:= for $d in $found
  let $id:=fn:tokenize($d,"/")[fn:last()]
  let $id:=fn:replace($id, ".xml","")
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
          UNION {
              ?uri bflc:consolidates ?instance . 				
			    }  
          }limit 1000
	        ]]></query>
                          

 
    let $q1:=cts:collection-query(  (    "/catalog/"     ))
    
	let $params := 
        map:new((
            map:entry("uri", sem:iri($work-uri)       )
        ))
    let $results := sem:query-results-serialize( 
                 sem:sparql($query, $params,(),  $q1 ))//sparql:results
     
      return 
            
   (:   mem:node-insert-child($results/sparql:results,<sparql:result><sparql:uri>{$id}</sparql:uri></sparql:result>):)
   $results
      
let $set:=
   
  for $res in $set//sparql:result
  let $uri:=fn:tokenize(fn:string($res//sparql:uri),"/")[fn:last()]
  
  order by $uri
  return  if (fn:string-length($uri) > 10) then fn:substring($uri,1,10)
          else if (fn:starts-with($uri, "c") ) then $uri 
          else   if (fn:starts-with($uri, "n") ) then () (: don't delete any auths :)
          else if (fn:string-length($uri) > 10) then fn:substring($uri,1,10)
          else if (fn:string-length($uri) < 10)  then local:makedocid($uri) 
		  else fn:concat("c",$uri)
         
  let $bibs:=<nodes>
        {
        for $d in distinct-values($set)
          return
            <node><bibid>{$d}</bibid><lccn> </lccn></node>
        }</nodes>
 
      (:let $x:=if ($paddedID) then
               let $path:=local:makedocid($paddedID)
                (:let $_:=xdmp:document-delete(cts:uri-match(fn:concat("/lscoll/lcdb/instances/",$path,"*")))
                let $_:=xdmp:document-delete(cts:uri-match(fn:concat("/lscoll/lcdb/works/",$path,"*")))
                let $_:=xdmp:document-delete(cts:uri-match(fn:concat("/lscoll/lcdb/items/",$path,"*")))  :)
                return xdmp:log(fn:concat("CORB deleting all docs for reload  ", fn:string($paddedID)), "info")
            else ():)
(:pass to deletereload  query:)

let $auto:=<auto>{
  for $n in $bibs/node
  let $path:=local:makedocid($n/bibid)
  let $bibdoc-uri:=fn:concat("/bibframe-process/records/",fn:replace($n/bibid, "^c0+",""),".xml")
    return  
     if (fn:doc-available($bibdoc-uri )) then
	 	let $d:=fn:string(fn:doc($bibdoc-uri)//marcxml:datafield[@tag="260"]/marcxml:subfield[@code="c"][1])
	 	let $numberdate:=fn:replace($d,"[^0-9]","")
        
		return  <reload><date>{$numberdate}</date><uri>{$bibdoc-uri}</uri></reload>
         else (fn:concat("bib not found:",fn:string($n/bibid)),"&#10;")
    }
    </auto>
       let $_:= xdmp:log(fn:concat("CORB deleting all docs to reload: ",$NAMETITLE-OFFSET," : " ,$nameTitle), "info")     
let $dels:=
	for $n in $bibs/node
	  return if ($debug=fn:false() ) then
		  		let $path:=local:makedocid($n/bibid)
  
			    let $_:=xdmp:document-delete(cts:uri-match(fn:concat("/lscoll/lcdb/instances/",$path,"*")))
			    let $_:=xdmp:document-delete(cts:uri-match(fn:concat("/lscoll/lcdb/works/",$path,"*")))
			    let $_:=xdmp:document-delete(cts:uri-match(fn:concat("/lscoll/lcdb/items/",$path,"*")))
			    return xdmp:log(fn:concat("CORB deleting this doc for reload batch ", $NAMETITLE-OFFSET,":",  fn:string($path)), "info")
				else
					 xdmp:log(fn:concat("CORB listing all docs for delete/reload (not deleted):", fn:string($n/bibid)), "info")

let $list:=for $t at $x in $auto//reload
			order by $t/date ascending
			 return (if ( $x = 1 ) then
			 			(xdmp:log(fn:concat("CORB reload anchor for ",  $NAMETITLE-OFFSET," :", fn:string($t/uri)), "info")
						 ,
						 fn:concat(" anchor: '", fn:string($t/uri)  ,"'&#10;" )
						 )
						 else 							 
							fn:concat("'",fn:string($t/uri)  ,"'&#10;" )
						)
(:
fn:concat("('" , (count($auto//reload/uri) -1 ),  fn:string-join($list,","),")"  ) works for 2
:)
return(
xdmp:save("/marklogic/backups/reloaddocs.nate" ,
	<reloadme>&#10;
	{

	$auto

	}&#10;
	</reloadme>)
    
	,
	(: count excludes the anchor now, and first comma:)
xdmp:save("/marklogic/backups/reloaddocs.txt" ,    
	<reloadme>&#10;
	{
	fn:concat("('" , (count($auto//reload/uri) -1 ),"'&#10;, ",  fn:string-join($list,","),")"  ) 

	}&#10;
	</reloadme>)
	, (: this means do no loading yet, just save the files :)
	( 0,""	 )
)

	(:count($auto//reload/uri),$auto//reload/uri/text()):)
