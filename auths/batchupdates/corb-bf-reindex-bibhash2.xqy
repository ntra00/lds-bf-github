xquery version "1.0-ml";
(: 2015 10 14
 this re-runs the hashable code for bibs or auths

only the bibs that have 130 or 240 are updated. Specs per sally's "conversion.docx"
all auths
uses bibframe2index function, not bibframe itself.

also changed mets timestamp ,workHash

fed by corb-bibframe-hash-work-nametitles-uris.xqy and 
store-bibs-uris.xqy (corb 1-14)
:)
(: temp location for qconsole: :)
import module  namespace bibframe2index  = 'info:lc/id-modules/bibframe2index#' at "modules/module.BIBFRAME-2-INDEX.xqy";


declare namespace mets          = "http://www.loc.gov/METS/";
declare namespace marcxml    	= "http://www.loc.gov/MARC21/slim";
declare namespace index         = "id_index#";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bf            = "http://bibframe.org/vocab/";
declare namespace bf2           = "http://bibframe.org/vocab2/";
declare namespace error	        = "http://marklogic.com/xdmp/error";
(:

1) if bib, calculate bfuri, open bf for 1 of 17million, test for 130/240
2) if bib and not 130, 240: delete remove all index:WorkHash, index:Workaap, quit
3) else:
4 call up all bf process records, get the marcxml
5 calculate the uri for the stored bibframe doc 
		auths come throuh as /resources/works

	(/authorities/names/n* becomes /resources/works/lw*)
	(/bibframe-process/records/* becomes /resources/works/c[0].+*)
6 calculate new hash
7 if workhash or workaap differs:
	remove all index:WorkHash, index:Workaap
	insert index:WorkHash, index:Workaap, index:workHashable


:)


declare variable $URI external; 



(:
 bib or auth: open and calc new and store
:)
declare function local:process-work-hashes($bfuri, $marcxml, $recordType){

let $bfdoc:=			
			try {
        			document($bfuri)
                } catch ($e) {
    			xdmp:log(     	fn:concat("Not found bf work doc  ",$bfuri ," skipping.")        , "info" )
    			}																		

let $updates:=  if ($bfdoc) then
					bibframe2index:update_aaps($marcxml , $recordType ) 
				else ()

return if ($bfdoc and $updates//index:Workaap) then
			 try {
                	(
        				    xdmp:node-replace ($bfdoc//mets:metsHdr , <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>),
                            xdmp:node-delete ($bfdoc//index:WorkHash),
							xdmp:node-delete ($bfdoc//index:WorkHashable),
							xdmp:node-delete ($bfdoc//index:Workaap),
							xdmp:node-delete ($bfdoc//bf:test),
							xdmp:node-delete ($bfdoc//wrap),
                            (:xdmp:document-add-collections($bfuri, "/bibframe/bibHashUpdated20151014/"),:)
							xdmp:log(  fn:concat("bf index updated for   ",$bfuri , " complete.")        , "info" ),
							for $node in $updates//index:*
								return (
										xdmp:log(  fn:concat("bf index updates for  ",$bfuri," node:",$node )        , "info" ),
										xdmp:node-insert-child($bfdoc//index:index, $node)								
									)
                            
        				) 
        		} catch ($e) {
        				($e,
						  xdmp:log(  fn:concat("bf index updates failed for   ",$bfuri )        , "info" )
						 )
       			}

		else	xdmp:log(  fn:concat("no updates...  for   ",$bfuri )        , "info" )
   
							
};


(:
 bib, no 130/240; just delete hashes
:)
declare function local:process-bfdelete-bib-work-hashes($bfuri){

let $bfdoc:=	(: either mets:mets or null :)									
							try {
		                			document($bfuri)
				                } catch ($e) {
				    			xdmp:log(     	fn:concat("Not found bib work doc  ",$bfuri ," skipping.")        , "info" )
		    			}									
			
									
return if ($bfdoc) then
			 try {
                	(
        				    xdmp:node-replace ($bfdoc//mets:metsHdr , <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>),
                            xdmp:node-delete ($bfdoc//index:WorkHash),
							xdmp:node-delete ($bfdoc//index:Workaap),
							xdmp:node-delete ($bfdoc//index:WorkHashable),
							xdmp:node-delete ($bfdoc//bf:test),
                            (:xdmp:document-add-collections($bfuri, "/bibframe/bibHashUpdated20151014/"),:)
                            xdmp:log(  fn:concat("bib 245 hash deleted  ",$bfuri )        , "info" )
        				) 
        		} catch ($e) {
        				$e
       			}

		else				()


};

(: open marcxml for bib or name/title
	if marxml not openable, error:error,
 	if bib and openable and 130/240, process as normal (return marcxml) 
	if bib w/o 130/240, delete old work hashes.
	if auth, return marcxml 
:)
declare function local:process-marcxml(  $marcxmluri, $recordType,  $bfuri)  {
	
	let $marcxml:=  if ($marcxmluri) then 
						try { 
							document($marcxmluri)}
	                	catch ($e) {
	                    	 xdmp:log( fn:concat("doc not found for ",$marcxmluri )        , "info" )
	                   }
				   else xdmp:log( fn:concat("not getting marcxml for ",$marcxmluri )        , "info" )
	
	return 
	(: debug:)
	(xdmp:log( fn:concat("in process-marcxml ",fn:string($marcxml//mets:mets/@OBJID) )        , "info" ),
	if ($marcxml instance of element(error:error)) then
				 xdmp:log(    		fn:concat("marcxml error on ",$marcxmluri ," ",fn:string($marcxml//error:code[1]) )
                , "info" )
			else if ($recordType="bib" and $marcxml//marcxml:datafield[@tag="130" or @tag="240"]) then
					($marcxml,
					 xdmp:log( fn:concat("has 240 ",$marcxmluri )        , "info" )
					 )
				 else if ($recordType="bib") then				 
				 	( xdmp:log( fn:concat("deleting work hashes ",$marcxmluri )        , "info" ),
					local:process-bfdelete-bib-work-hashes($bfuri)
					)
				 else if (fn:not($marcxml)) then
				 		() (: done :)
				 else $marcxml
				 )
					
};
(: main program  :)
(:
bib work with 240:
let $URI:="/bibframe-process/records/2558151.xml"


bib work  without 240/130
/bibframe-process/records/6865632.xml  c006865632
austen bib match
/bibframe-process/records/5933427 c005933427
austen nonmatch: (deletes workhash; no 240
/bibframe-process/records/17601072  c017601072
auth, nametitle (austen)
let $URI:="/resources/works/lw2002041181.xml"


let $URI:="/bibframe-process/records/17601072.xml"
:)
let $start := xdmp:elapsed-time()
let $recordType:=if (fn:matches($URI,"/bibframe-process")) then "bib" else "auth"

let $bfuri:= if ($recordType="bib") then
				let $x:= fn:replace($URI,"/bibframe-process/records/","")
				let $x:=fn:replace($x,"\.xml","")
				let $len:=fn:string-length($x)
				return fn:concat("/resources/works/c",fn:string-join(for $i in (1 to (9 - $len)) return "0",""),$x,".xml")
			else (: /resources/works:)
				$URI

let $done:=	if (fn:contains (fn:string-join(xdmp:document-get-collections($bfuri),"") , "/bibframe/bibHashUpdated20151014/")) then 
							(fn:true()
							,xdmp:log( fn:concat("bibHashUpdated20151014 done  on ",$URI ," skipping.")        , "info" )
							)
						else  
							fn:false()
						

let $marcxmluri:= if (fn:not($done) and $recordType="auth") then
						let $x:= fn:replace($URI,"/resources/works/lw","")				
						return fn:concat("/authorities/names/n",$x)
					else if (fn:not($done)) then (:  bib, so ....? /resources/works:)
				   		$URI
					else ()


let $marcxml:=	if (fn:not($done))  then 
					local:process-marcxml( $marcxmluri, $recordType,  $bfuri)
				else ()

					
(: at this point, for bibs, we  have the marcxml or nothing.  If bib had no 130/240, its nothing.
for name/titles, we have marcxml or nothing
if nothing, quit. if something, open bf and continue
:)
				
let $bfdoc:= if (fn:not($done))  then 
					local:process-work-hashes($bfuri,$marcxml, $recordType)
			else ()
return  
	(
 (: debug stuff :)
 <done>{$done}</done>,
 <bfuri>{$bfuri}</bfuri>,
 <cols>{xdmp:document-get-collections($bfuri)}</cols>,
 <marcxmluri>{$marcxmluri}</marcxmluri>,
 <rec>{$recordType}</rec>,
 
 (: debug stuff :)
xdmp:log(fn:concat("doc ",  $URI, " done in ", (xdmp:elapsed-time() - $start) cast as xs:string) , "info")
			)
