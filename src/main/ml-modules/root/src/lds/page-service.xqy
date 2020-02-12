xquery version "1.0";

(:
:   Module Name: Negotiate service request
:
:   Module Version: 1.0
:
:   Date: 2011 July 19
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:     Evaluates the service requested, fulfills the
:       request, delivers the response. 
:)

(:~
:   Evaluates the service requested, fulfills the
:   request, delivers the response.
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since July 19, 2011
:   @version 1.0
:)


(: MODULES :)
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace searchml = 'info:lc/id-modules/searchml#' at "/xq/modules/module.SearchML.xqy";
(:
import module namespace transmit    = "info:lc/id-modules/transmit#" at "../xq/modules/module.Transmit.xqy";
:)
import module namespace atompub    = "info:lc/xq-modules/atom#" at "/xq/modules/module.AtomPub.xqy";

import module namespace feed = "info:lc/xq-modules/atom-utils"at "/xq/modules/atom-utils.xqy";

(: NAMESPACES :)
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace xdmp = "http://marklogic.com/xdmp";

(:
declare option xdmp:output "indent=yes" ;
declare option xdmp:output "indent-untyped=yes" ;
:)

(:

Services:
    ATOM feed, for updates
        Determine relevant scheme
        Get updated uris in date descending
        deliver as atom+xml
        
    Label service
        Determine relevant scheme
        Test for explicity accept-type parameter in querystring
        Find label value
        Redirect based on accept-type 

:)

(:~
:   This variable is for the type of service
:)
declare variable $service as xs:string := xdmp:get-request-field("service", "");

(:~
:   This variable is for the scheme. 
:)
declare variable $scheme as xs:string := xdmp:get-request-field("scheme", "");
(:~
:   This variable is for the field to search. 
:)
declare variable $field as xs:string := xdmp:get-request-field("field", "");

(:~
:   This variable is for the value to find. 
:)
declare variable $value as xs:string := xdmp:get-request-field("value", "");

(:~
:   This variable is for the accept. 
:)
declare variable $accept as xs:string := xdmp:get-request-field("accept", "");

(:~
:   This variable is for the mimetype. 
:)
declare variable $mimetype as xs:string := xdmp:get-request-field("mimetype", "")[1];

(:~
:   This variable is for the requested serialization. 
:)
declare variable $serialize as xs:string := xdmp:get-request-field("ser", "");

(:~
:   This variable is for the label. 
:)
declare variable $label as xs:string := xdmp:get-request-field("token", "");

(:~
:   This variable is for the query. 
:)
declare variable $q as xs:string := xdmp:get-request-field("label", "");

(:~
:   This variable is for the rdftype. 
:)
declare variable $rdftype := xdmp:get-request-field("rdftype", "");

(:~
:   This variable is for the AtomPub page. 
:)
declare variable $page as xs:string := xdmp:get-request-field("page", "1");


(: LOGIC :)

let $duration := $cfg:HTTP_EXPIRES_CACHE

let $response :=
  (:if ($field!="" and $value!="" and $service eq "feed") then
        let $page := 
            if ($page eq "") then
                "1"
            else
                $page
        return atompub:get-atom-feed-query($scheme, $page,$field,$value)
        
  else :)  
  if ($service eq "feed") then
        let $page := 
            if ($page eq "") then
                "1"
            else
                $page
        return atompub:get-feed-results($scheme, $page,$field,$value)
   else if ($service eq "label") then
   searchml:get-label($label, "rdf")
    else ()

return
 (
 	
    if ($service eq "feed") then

(:        let $response := transmit:formatXML($response,0)
        let $response := transmit:removeNSPrefix($response , "atom")
        return transmit:sendATOMXML($response):)
		
	 	(xdmp:set-response-content-type("application/atom+xml; charset=utf-8"), 
       xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
       xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),	
	   $response
	   )
        
    else if ($service eq "label") then
        (: figure out the accept issue :)
        $response
    else if ($service eq "didyoumean" or $service eq "alsosee") then
        (: figure out the accept issue :)
        (:let $response := transmit:formatXML($response, 0)
        
		return transmit:sendXML($response):)
		$response
    else 
        $response
)(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)