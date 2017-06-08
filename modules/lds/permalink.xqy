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
import module namespace rdfaxhtml = "info:lc/id-modules/rdfaxhtml#" at "/xq/id-main/modules/module.RDF-2-RDFaXHTML.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace marc="http://www.loc.gov/MARC21/slim";

declare namespace mxe="http://www.loc.gov/mxe";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function local:output($msie as xs:boolean, $detail-result as element(div)*, $uri as xs:string, $mime as xs:string, $behavior as xs:string) as element(html) {
    let $htmltitle := 
        if ($uri) then
            let $title := fn:string-join( $detail-result//h1[@id eq 'title-top' or not(@id)]//text(), " ")
            return
            if ($title) then $title else "Record Detail"
        else
            "Record Detail"
			
	let $objectType as xs:string? := $detail-result//span[@id="objectType"]/string()
	let $objectType := if (not($objectType) ) then "workRecord" else $objectType

	
	(:let $objectType as xs:string? := "modsBibRecord":)
    let $crumbs := <span class="ds-searchresultcrumb">Record Detail</span>
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
                                <img alt="Close" src="/static/natlibcat/images/close.jpg"/>
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
let $behavior := lp:get-param-single($lp:CUR-PARAMS, 'behavior','default')
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $duration := $cfg:HTTP_EXPIRES_CACHE
return
    if (matches($mime, "application/mets\+xml")) then				
			if (exists(utils:export-mets($uri))) then
			 (
		            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
		            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
		            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),	            
					document{utils:export-mets($uri)}
	        		)				
			else
				xdmp:set-response-code(404,"Item Not found")
		else if (matches($mime, "application/rdf\+xml")) then			
			(
	            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:rdf($uri))) then
	            	document{utils:rdf($uri)} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
        	else if (matches($mime, "application/n-triples")) then			
			(
	            xdmp:set-response-content-type("text/plain; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:nt($uri))) then
	            	document{utils:nt($uri)} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
        	else if (matches($mime, "application/json")) then			
			(
	            xdmp:set-response-content-type("text/plain; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:json($uri))) then
	            	document{utils:json($uri)} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
		else if (matches($mime, "application/mldoc\+xml")) then			
			(
	            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				if (exists(utils:mets($uri))) then
	            	document{utils:mets($uri)} 
				else
					xdmp:set-response-code(404,"Item Not found")
        	)
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
			
			return
			(
            	xdmp:set-response-content-type("text/xml; charset=utf-8"), 
            	xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            	xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				<index:index xmlns:index="info:lc/xq-modules/lcindex">{$mets/mets:dmdSec[fn:contains(@ID,"index")]/mets:mdWrap/mets:xmlData/index:index/*}</index:index>
			(:index:mods-to-idx($mets//mods:mods, $mets//mxe:record, $uri) :)
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
    else (: HTML, XHTML, etc. :)	   
		let $detail-result := 
				if ($behavior="bfview") then						
						if (exists(utils:mets($uri))) then
								let $mets:=   utils:mets($uri)
								let $bf:= $mets/mets:dmdSec[@ID="bibframe"]/mets:mdWrap/mets:xmlData/rdf:RDF
								return 
							 		<div id="ds-bibrecord">{rdfaxhtml:rdf2rdfaxhtml($bf)}</div>
						else xdmp:set-response-code(404,"Item Not found")            
				else
						vd:render($uri)[2]
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
                '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">',
                local:output(false(), $detail-result, $uri, $mime, $behavior)
		
            )
		)	