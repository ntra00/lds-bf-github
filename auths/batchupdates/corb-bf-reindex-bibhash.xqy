xquery version "1.0-ml";
(: 2015 09 23
 this re-runs the hashable code for bibs,
fixing 7xx $t inclusion, multiple name inclusion, work subclass inclusion (name/titles have none)
also changed mets timestamp ,workHash
:)


declare namespace mets          = "http://www.loc.gov/METS/";
declare namespace marcxml    	= "http://www.loc.gov/MARC21/slim";
declare namespace index         = "id_index#";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bf            = "http://bibframe.org/vocab/";
declare namespace bf2           = "http://bibframe.org/vocab2/";
declare namespace error	        = "http://marklogic.com/xdmp/error";
(:
1 call up all bfp records, get the marcxml
2 open the uri the converted record c*
3 recalculate hash (not in code, xdmp)
4 nodereplace
:)

import module  namespace mbshared  = 'info:lc/id-modules/mbib2bibframeshared#' at "marc2bibframe/modules/module.MBIB-2-BIBFRAME-Shared.xqy";
declare variable $URI external;
(:let $URI:="/bibframe-process/records/2558151.xml":)


(: main program  :)
let $start := xdmp:elapsed-time()
let $marcxml:= try {document($URI)
                    }
                catch ($e) {
                    $e
                   }
let $uri2:=fn:replace($URI,"/bibframe-process/records/","")
let $uri2:=fn:replace($uri2,"\.xml","")
let $len:=fn:string-length($uri2)
let $uri2:= fn:concat("/resources/works/c",fn:string-join(for $i in (1 to (9 - $len)) return "0",""),$uri2,".xml")
return  
	if (fn:doc-available($uri2)) then
	if (fn:not(fn:contains (fn:string-join(xdmp:document-get-collections($uri2),"") , "/bibframe/bibHashUpdated20150929/"))) then 
    let $mets:= try {
                document($uri2)
                } catch ($e) {
    				$e
    			}
    
    
    let $newhashable:=      try {
                                mbshared:generate-hashable($marcxml//marcxml:record, "Work",())                            
                                } catch ($e) {
    				$e
    			}
    return 
             if ($newhashable instance of element(error:error)) then
                xdmp:log( 
                fn:concat("generate-hashable error on ",$URI ," ",fn:string($newhashable//error:code[1]) )
                , "info" )
             else
			 	let $newhash:=xdmp:diacritic-less(fn:string($newhashable))
                let $newhash:=<index:WorkHash>{xdmp:md5($newhash)}</index:WorkHash>
                let $insert := if (fn:not( $mets instance of element(error:error) )) then
                			     try {
                				(
                				    xdmp:node-replace ($mets//mets:metsHdr , <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>),
                                    xdmp:node-replace ($mets//index:WorkHash,$newhash),
                                    xdmp:node-replace ($mets//bf:authorizedAccessPoint[@xml:lang="x-bf-hash"],$newhashable),
                                    xdmp:document-add-collections($uri2, "/bibframe/bibHashUpdated20150929/")
                                    
                				) 
                			} catch ($e) {
                				$e
                			}
                			else xdmp:log( fn:concat("doc open  error on ",$URI ," ",fn:string($mets//error:code[1]) ), "info" )
                		return
                			if ($insert instance of element(error:error)) then
                				xdmp:log( fn:concat("insert error on ",$URI ," ",fn:string($insert//error:code[1])) , "info")
                			else
                				xdmp:log(fn:concat("reindexed  ", $uri2, " in ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")
    	
    	else    				xdmp:log(fn:concat("skipped already done, bibHashUpdated20150929 ", $uri2, " in ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")
		else    				xdmp:log(fn:concat("doc not found: ", $uri2, " in ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")