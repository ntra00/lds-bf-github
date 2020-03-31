xquery version "1.0-ml";
(: code to export based on uri (/resources/works/[id], /resource/instances/id, /resources/items/id
the NT version of the doc :)
import module namespace utils			= 		"info:lc/xq-modules/mets-utils" 		at	"modules/mets-utils.xqy";


declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
      
declare variable $URI as xs:string external;  (: The value for this variable is passed in by CORB :)


let $rdfnt:= 
				( 	utils:rdf-ser($URI, "nt"),
					xdmp:log(fn:concat("CORB BFEXPORT exported  : ",$URI), "info")
				 )
			
	return 
		$rdfnt
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)