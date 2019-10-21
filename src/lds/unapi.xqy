xquery version "1.0-ml";
(: unapi server; supports "id" and "format" params; 

  This is a combination of functionality in urlrewrite.xqy and nlc/permalink.xqy

  If user doesn't enter any params, all the formats available are listed 
  If user specifies an id but no format, all the formats for that item are listed
  If user enters both, then they get back mets, mods, dc, marcxml for that id


:)
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/nlc/view/v-search.xqy";
import module namespace vd = "http://www.marklogic.com/ps/view/v-detail" at "/nlc/view/v-detail.xqy";
import module namespace vr = "http://www.marklogic.com/ps/view/v-result" at "/nlc/view/v-result.xqy";
import module namespace md = "http://www.marklogic.com/ps/model/m-doc" at "/nlc/model/m-doc.xqy";

import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
declare namespace marc="http://www.loc.gov/MARC21/slim";
declare namespace mxe="http://www.loc.gov/mxe";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";



(: input parameters :)

let $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "id","")
let $format := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, "format", ""))
let $duration := $cfg:HTTP_EXPIRES_CACHE
return 


	 if ($uri="") then	 
		<formats>
			<format name="marcxml" type="application/marcxml+xml" docs="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"/>
			<format name="mods" type="application/mods+xml" docs="http://www.loc.gov/standards/mods/mods.xsd"/>
			<format name="mets" type="application/xml" docs="http://www.loc.gov/standards/mets/mets.xsd"/>
			<format name="dc" type="application/srwdc.xml" docs="http://www.loc.gov/standards/sru/resources/dc-schema.xsd"/>
		</formats>
	else if ($format="") then 
		<formats uri="{$uri}">
			<format name="marcxml" type="application/marcxml+xml" docs="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"/>
			<format name="mods" type="application/mods+xml" docs="http://www.loc.gov/standards/mods/mods.xsd"/>
			<format name="mets" type="application/xml" docs="http://www.loc.gov/standards/mets/mets.xsd"/>
			<format name="dc" type="application/srwdc+xml" docs="http://www.loc.gov/standards/sru/resources/dc-schema.xsd"/>
		</formats>
	else if (matches($format, "mets")) then		
		 (
	            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
	            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
	            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
	            document{utils:export-mets($uri)}				
        		)		
				
		else if ($format="marcxml") then
			
        		(
		            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
		            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
		            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
		            utils:export-mets($uri)//marc:record
        		)
		else if (matches($format, "doc")) then
				(
		            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
		            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
		            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),					
		            utils:mets($uri)
        		)
      	else  if (matches($format, "mods")) then
        (
            xdmp:set-response-content-type("text/xml; charset=utf-8"), 
            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
            document{utils:mets($uri)}//mods:mods
        )
      else  if (matches($format, "dc")) then
        	   let $srwStyle:= "/xslt/MARC21slim2SRWDC.xsl"         
		   	   let $mets:=document{utils:export-mets($uri)}
			   let $marcxml:=document{utils:export-mets($uri)}//marc:record
				    (:element marc:record {marcutil:mxe2-to-marcslim($mets//mxe:record)/*} 							:)
           	   let $dc:=
					 try 	{                                          
		           	 			xdmp:xslt-invoke($srwStyle,document{$marcxml})
				       	 	} catch ($exception) {
				           		<error>{$exception}</error>
				        	}    		                             
          return
                (
                   xdmp:set-response-content-type("text/xml; charset=utf-8"), 
                   xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                   xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),
				   if ($dc  instance of element(error:error)) then
				    (
			  			xdmp:set-response-code(500, $dc//error:message[1]/string()),      
						$dc
					)
					else
     			   		document{$dc} 
               )
    else ()	
