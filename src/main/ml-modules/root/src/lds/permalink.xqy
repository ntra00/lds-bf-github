xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/lds/view/v-search.xqy";
import module namespace vd = "http://www.marklogic.com/ps/view/v-detail" at "/lds/view/v-detail.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace index= "info:lc/xq-modules/index-utils" at "/xq/modules/index-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";




declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace marc="http://www.loc.gov/MARC21/slim";

declare namespace mxe="http://www.loc.gov/mxe";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
(: from bibs2mets :)
declare function local:padded-id($id as xs:string) 
{

    let $idLen := fn:string-length( $id )
    let $paddedID := 
        if ( $idLen eq 1 ) then
            fn:concat("00000000" , $id)
        else if ( $idLen eq 2 ) then
            fn:concat("0000000" , $id)
        else if ( $idLen eq 3 ) then
            fn:concat("000000" , $id)
        else if ( $idLen eq 4 ) then
            fn:concat("00000" , $id)
        else if ( $idLen eq 5 ) then
            fn:concat("0000" , $id)
        else if ( $idLen eq 6 ) then
            fn:concat("000" , $id)
        else if ( $idLen eq 7 ) then
            fn:concat("00" , $id)
        else if ( $idLen eq 8 ) then
            fn:concat("0" , $id)
        else 
            $id
    return $paddedID
    
};
declare function local:output($msie as xs:boolean, $detail-result as element(div)*, $uri as xs:string, $mime as xs:string, $behavior as xs:string) as element(html) {
    let $title:=fn:string-join($detail-result//h1[@id eq 'title-top' or not (@id)]//text(), " ")
	
	let $crumb:=
				 if (contains($uri, "work")) then  "Work Description"
					else if  (contains($uri,"instance")) then "Instance Description"
					else if  (contains($uri,"item" )) then "Item Description"
					else "Description Detail"
        
	let $htmltitle:=if ($title) then $title
						else if ($uri) then fn:concat($uri," ", $crumb)
						else $crumb

					
	let $objectType as xs:string? := $detail-result//span[@id="objectType"]/string()
	let $objectType := if (not($objectType) ) then "workRecord" else $objectType

	
	(:let $objectType as xs:string? := "modsBibRecord":)
    let $crumbs := <span class="ds-searchresultcrumb">{$crumb}</span>
    let $atom := ()
    let $seo := <meta>{$detail-result//*:metatags}</meta>
    
    let $myhead := 
        	ssk:header($htmltitle, $crumbs, $msie, $atom, $seo, $uri, $objectType)       
    let $searchbar :=
        <div id="search-results">
            {vs:render()}
        </div>
	
    return 
        <html>
            {$myhead/head}
            <body>
                <div id="msgblock">
                    <div id="msgbox">
                        <div class="fright">
                            <a id="msgclose">
                                <img alt="Close" src="/static/lds/images/close.jpg"/>
                            </a>
                        </div>
                        <br class="break"/>
                        <div id="msgcontainer">
                            <div id="msgcontent">&nbsp;</div>
                        </div>
                    </div>
                </div>
                {$myhead/body/div}
                <div id="ds-container">
					<abbr class="unapi-id" title="{normalize-space($uri)}"/>
                    <div id="ds-body">
                        {$searchbar}
                        <div id="dsresults">
						  {$detail-result}                    
                        </div>
                    </div>

                <!-- end id:ds-container -->
                </div>
				{if (matches( $objectType,("bibRecord","modsBibRecord", "workRecord","instanceRecord", "itemRecord" ))) then 					
						ssk:feedback-link(false() )					   
				 else ()
				}
				{ssk:footer()/div}				
            </body>
        </html>
};

(: input parameters :)

let $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "uri")
(: pad token with c0+ if it's not  got it, so we can lookup works/c000005226  or works/5226 :)
let $token:=fn:tokenize($uri,"\.")[fn:last()]
(:account for  longer instance/item tokens:)
let $token:=if(fn:contains($uri,"works")) then
				$token
			else	
				fn:substring($token, 1,fn:string-length($token)-4)
(:let $uri:=if (fn:starts-with($token,"c0")) then
		 $uri
			else fn:replace($uri,$token, fn:concat("c",local:padded-id($token))):)

let $behavior := lp:get-param-single($lp:CUR-PARAMS, 'behavior','bfview')
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $dmdsec := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'subset', '')) (:semtriples:)
let $duration := $cfg:HTTP_EXPIRES_CACHE

return
   	if ($dmdsec="semtriples" ) then
					(: not finished :)
			if (exists(utils:mets($uri))) then
				let $doc:=utils:get-mets-dmdSec("semtriples",$uri )/*
				return sem:rdf-serialize(sem:rdf-parse($doc/node(),"rdfxml"),"ntriple")
				(:sem:rdf-serialize(sem:rdf-parse($doc/node(),"rdfxml"),"turtle"):)
				
			else 
				xdmp:set-response-code(404,"Item Not found")

	else    if (matches($mime, "application/mets\+xml")) then				
			if (exists(utils:export-mets($uri))) then
			 (
		            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
		            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
		            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),	            
					document{utils:export-mets($uri)}
	        		)				
			else
				xdmp:set-response-code(404,"Item Not found")
	else  if (matches($mime, "application/bf-simple\+xml")) then			
			let $rdf:= document{utils:get-mets-dmdSec("bibframe",$uri )}
 			let $stylesheetBase :="/xslt/"
		    let $stylesheet := concat( $stylesheetBase ,"bf-simplifier.xsl")    		
			let $simple-bf:=try {
					               xdmp:xslt-invoke($stylesheet,document{$rdf/rdf:RDF})
			        			} catch ($e ) {(
												$e
								 				
												)
								 }
			        			
			return if (exists($simple-bf)) then
			         (
		            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
		            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
		            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),	            
					document{$simple-bf}
	        		)				
			     else
	       			xdmp:set-response-code(404,"Item Not found")
		
		else if ($dmdsec="semtriples" and matches($mime, "text/turtle")) then			
			(
	            xdmp:set-response-content-type("text/turtle; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	let $doc:=document{utils:get-mets-dmdSec("semtriples",$uri )}
    				return 
	
   					 try{
							sem:rdf-serialize(sem:rdf-parse($doc/node(),"rdfxml"),"turtle")
						}
					 catch($e) { ( (),
					 	xdmp:log(fn:concat("DISPLAY: RDF conversion error for ",$uri),"info")					 	
					 	)
					 }
   
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
		else if (matches($mime, "application/bf-edit\+json")) then			
			(
	            xdmp:set-response-content-type("application/ld+json; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	document{utils:rdf-export($uri,"jsonld")} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
        else if (matches($mime, "application/bf-2marc\+xml")) then			
			(
	            xdmp:set-response-content-type("application/rdf+xml; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	document{utils:rdf-export($uri,"rdfxml")} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
		else if (matches($mime, "application/rdf\+xml")) then			
			(
	            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	document{utils:rdf-ser($uri,"rdfxml")} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
			else if (matches($mime, "text/turtle")) then			
			(
	            xdmp:set-response-content-type("text/turtle; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	document{utils:rdf-ser($uri,"ttl")} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
        	else if (matches($mime, "text/n3")) then			
			(
	            xdmp:set-response-content-type("text/n3; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	document{utils:rdf-ser($uri,"n3")} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
			else if (matches($mime, "application/n-triples")) then			
			(
	            xdmp:set-response-content-type("application/n-triples; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	document{utils:rdf-ser($uri, "nt")} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
			
        	else if (matches($mime, "application/json")) then			
			(
	            xdmp:set-response-content-type("application/json; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	         
					document{utils:json($uri,"json")}
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
			else if (matches($mime, "application/ld\+json")) then			
			(
	            xdmp:set-response-content-type("application/ld+jsonld; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then	            	
					document{utils:json($uri,"jsonld")}
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
		else if (matches($mime, "application/mldoc\+xml")) then			
			(
	            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
					utils:mets($uri)
(:				if (exists(utils:mets($uri))) then
	            	document{utils:mets($uri)} 
				else
					xdmp:set-response-code(404,"Item Not found"):)
        	)
			(: nametitle authority marc :)
	   else if (matches($mime, "application/marcxml\+xml") and contains($uri,"resources/bibs/n")) then					
	   		let $objid:=fn:concat("loc.natlib.works.",fn:replace($uri,"/resources/bibs/",""))
	   		return try {( document{utils:export-mets($objid)},
							xdmp:set-response-content-type("text/xml; charset=utf-8"), 
				            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
				            xdmp:add-response-header("Cache-Control", resp:cache-control($duration))
							)
						}
					catch($e) {
						xdmp:set-response-code(404,"Item Not found")
					}
		   else if (matches($mime, "application/marcxml\+xml") and contains($uri,"resources/bibs")) then					
	   			let $bibid:=fn:tokenize($uri,"/")[fn:last()]				
				let  $bibid:=fn:replace( $bibid,".xml","")
				let $paddedID:=fn:concat("c",utils:padded-id($token))
				let $objid:=fn:concat("loc.natlib.works.",$paddedID)
				let $mets:= try { document{utils:mets($objid) } }
							 catch($e) { xdmp:log( $e ,"info") }
				let $mxe:= if ( $mets ) then $mets//mxe:record else ()
				
				let $marcxml:= if ($mxe ) then  try 	 { marcutil:mxe2-to-marcslim($mxe) } 
												catch($e){ () } 
								else ()
				
				
				return if ( $marcxml ) then
					(
		            		xdmp:set-response-content-type("text/xml; charset=utf-8"), 
				            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
				            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				            $marcxml
        			)			
				 	else 	if (doc-available(fn:concat("/bibframe-process/records/",fn:replace($uri,"/resources/bibs/",""),".xml"))) then					
					(
		            		xdmp:set-response-content-type("text/xml; charset=utf-8"), 
				            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
				            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				            document(fn:concat("/bibframe-process/records/",fn:replace($uri,"/resources/bibs/",""),".xml"))//marc:record
        			)					
			else xdmp:set-response-code(404,"Item Not found")



		else if (matches($mime, "application/marcxml\+xml")) then						
				if (exists(utils:export-mets($uri))) then					
					(
		            		xdmp:set-response-content-type("text/xml; charset=utf-8"), 
				            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
				            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				            document{utils:export-mets($uri)}//marc:record
        			)					
				else xdmp:set-response-code(404,"Item Not found")
      	else  if (matches($mime, "application/holdings\+xml")) then
		        	(
			            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
			            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
			            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
						if (exists(utils:mets($uri))) then
								let $bibid:=tokenize($uri,"\.")[last()]
				        		(:document{utils:hold-bib(xs:integer(substring-after($uri,'.lcdb.')))}:)
								return document{utils:hold-bib(xs:integer($bibid),"lcdb")}
							else
								xdmp:set-response-code(404,"Item Not found")            
			        )
		else  if (matches($mime, "application/mods\+xml")) then
	        (
            	xdmp:set-response-content-type("text/xml; charset=utf-8"), 
            	xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            	xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	        		document{utils:mets($uri)}//mods:mods
				else
					xdmp:set-response-code(404,"Item Not found")            
        	)
	 else  if (matches($mime, "application/index\+xml")) then
	 		let $mets:=utils:mets($uri) 
			let $baseuri:= fn:base-uri($mets)
			return
			(
            	xdmp:set-response-content-type("text/xml; charset=utf-8"), 
            	xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            	xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				<index:index xmlns:index="info:lc/xq-modules/lcindex">{
				$mets/mets:dmdSec[@ID="ldsindex" or @ID="index"]/mets:mdWrap/mets:xmlData/index:index/*
				}
				<index:mlcollections>{for $c in xdmp:document-get-collections($baseuri) 
							return <index:mlcollection>{$c}</index:mlcollection>
							}
				</index:mlcollections>
				<index:madsrdfindexes>{$mets/mets:dmdSec[@id="index"]/mets:mdWrap/mets:xmlData/*}</index:madsrdfindexes>
				</index:index>
			
			)
			   
      else  if (matches($mime, "application/srwdc\+xml")) then
			   	if (exists(utils:mets($uri))) then												
			           		let $dc:=
								if (matches($uri, "(lcdb)") ) then
									 try 	{                                          
					           	 			xdmp:xslt-invoke("/xslt/MARC21slim2SRWDC.xsl" ,document{utils:export-mets($uri)//marc:record})
							       	 	} catch ($exception) {
							           		<error>{$exception}</error>
							        	}    		                             
								else		 try 	{                                          
					           	 			xdmp:xslt-invoke("/xslt/MODS3-22simpleDC.xsl",document{utils:mets($uri)//mods:mods})
							       	 	} catch ($exception) {
							           		<error>{$exception}</error>
							        	}    		                             
			          		return
							  if ($dc instance of element(error:error)) then							  
									xdmp:set-response-code(500,$dc//error:message[1]/string())
								else
			                   (
				                   xdmp:set-response-content-type("text/xml; charset=utf-8"), 
				                   xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
				                   xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),								   
				        		   document{$dc} 
			               		)
				else 	xdmp:set-response-code(404,"Item Not found") 
	
	else  if (matches($mime, "text/simple-html")) then
		   	if (exists(utils:mets($uri))) then					
				let $detail-result := vd:render($uri,"simple")[2]
				let $mime:="text/html"
				return (
					  if ($detail-result instance of element(error:error) ) then
						  (
						  	xdmp:set-response-code(500, $detail-result//error:message[1]/string()),      
							$detail-result
							
						)
						else if (not(exists($detail-result)) ) then
						   xdmp:set-response-code(404,"Item Not found")
						  (:in production, this will go to a visual error page as well:)		
						else
			              (
			                xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
			                xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
			                xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
			                '<!DOCTYPE html>',							
			                local:output(false(), $detail-result, $uri, $mime, $behavior)
		
			            )
				)
				else 	xdmp:set-response-code(404,"Item Not found") 

		
    else (: HTML, XHTML, etc. :)	   
		let $detail-result := vd:render($uri)[2] 	

(:		let $_:=xdmp:log(vd:render($uri)[2],"info")							:)
        
		return (
		  if ($detail-result instance of element(error:error) ) then
			  (
			  	xdmp:set-response-code(500, $detail-result//error:message[1]/string()),      
				$detail-result
			)
			else if (not(exists($detail-result)) ) then
			   xdmp:set-response-code(404,"Item Not found")
			  (:in production, this will go to a visual error page as well:)		
			else
              (
                xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
                xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                '<!DOCTYPE html>',				
                local:output(false(), $detail-result, $uri, $mime, $behavior)		
            )
		)	
		
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)