xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/lds/view/v-search.xqy";
import module namespace vd = "http://www.marklogic.com/ps/view/v-detail" at "/lds/view/v-detail.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";


declare namespace mets = "http://www.loc.gov/METS/";
declare namespace bf            	= "http://bibframe.org/vocab/";
declare namespace marc="http://www.loc.gov/MARC21/slim";
declare namespace mxe="http://www.loc.gov/mxe";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function local:output($msie as xs:boolean, $seo as element(meta)+, $maindiv as element(div),  $uri as xs:string?, $mime as xs:string) as element(html) {
    let $detailtitle := "Record View"
    let $htmltitle := if ($maindiv//h1/span[@property="bf:authorizedAccessPoint"])then
                        fn:string($maindiv//h1/span[@property="bf:authorizedAccessPoint"])
                        else
                        string-join($maindiv//h1[@id eq 'title-top']//text(), " ")
    let $objectType := ($maindiv//span[@id="objectType"]/string())[1]
    
    let $branding:=$cfg:MY-SITE/cfg:branding/string()
    let $collection:=$cfg:MY-SITE/cfg:collection/string()
    let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()

    let $searchtitle := "Search results"           
    let $crumbs := 
        (
            let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'index')
            let $new-params := lp:param-remove-all($new-params, 'uri')
            let $new-params := lp:param-remove-all($new-params, "branding")
            let $new-params := lp:param-remove-all($new-params, "collection")
    
            return
                <span><a href="{$url-prefix}search.xqy?{lp:param-string($new-params)}">{$searchtitle}</a></span>,
                <span class="ds-searchresultcrumb">{$detailtitle}</span>
        )
    let $atom := ()
    
     let $myhead :=             
			if (fn:matches($maindiv//span[@id="detailURL"],"(works|instances|items)")  ) then			
				ssk:header($htmltitle, $crumbs, $msie, $atom, $seo, $uri, "bibRecord")
            else
                ssk:header($htmltitle, $crumbs, $msie, $atom, $seo, $uri, $objectType)
    
	
	let $searchbar :=
        <div id="search-results">
            {vs:render()}
        </div>
	let $dev-div:=	
	if ( contains($cfg:DISPLAY-SUBDOMAIN,"mlvlp04") and (not( xdmp:get-request-header('X-LOC-Environment')) or  xdmp:get-request-header('X-LOC-Environment')!='Staging' )) then
						<div class="top" style="background-color:#e0ffff;color=white; width=100%;text-align:center;font-size:120%;"><strong>Development Site</strong></div>
					else
					()
				(:and xdmp:get-request-header('X-LOC-Environment')!='Staging':)
    return   
        <html xmlns="http://www.w3.org/1999/xhtml">
            {$myhead/child::*[1]}
			
            <body>{$dev-div} 
                {$myhead/body/div}                              
                <div id="ds-container">
                    <div id="ds-body">
                        {$searchbar}
                        <div id="dsresults">
                            {$maindiv}
                        </div>
                    </div>
                <!-- end id:ds-container -->
                </div>
                {if (matches( $objectType,("bibRecord","modsBibRecord"))) then                  
                        ssk:feedback-link(false() )                 
                 else ()
                }                
                {ssk:footer()/div}{$dev-div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
};

(: input parameters :)

let $page := "detail"
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))

(: 2019-11-22 nate copied permalink to allow adding mime  type to detail :)
let $result := vd:render('')
let $currentObject:=$result[3]
let $uri:=$result[4]
let $seo:=$result[1]

(:*************below is all from permalink *****************:)


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
        else if (matches($mime, "application/bf-2marc\+xml")) then			
			(
	            xdmp:set-response-content-type("application/rdf+xml; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	document{utils:rdf-2marc($uri,"rdfxml")} 
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
                (:local:output(false(), $detail-result, $uri, $mime, behavior)		:)
				local:output(false(),$seo, $detail-result, $uri, $mime)		
				
				
            )
		)	

(:*************above is all from permalink *****************:)
(:
this used to be detail .xqy html display:

let $detail-result := vd:render('')


let $seo:=<meta>{$detail-result//*:metatags}</meta>

let $maindiv := $detail-result[2] (: html div or error:error :)
let $uri as xs:string? := $maindiv//span[@id="detailURL"]/string()


return
    if ($maindiv instance of element(error:error) ) then    
    (
        xdmp:set-response-code(500, $maindiv//error:message[1]/string()),      
        $maindiv
    )
    else
    (
        xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),        
        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
        $doctype,               
        local:output(false(), $seo, $maindiv,  $uri, $mime)
    )
	:)(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" useresolver="no" url="" outputurl="" processortype="internal" tcpport="0" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" host="" port="0" user="" password="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)