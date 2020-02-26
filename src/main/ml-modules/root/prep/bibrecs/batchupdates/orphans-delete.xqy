xquery version "1.0-ml";

declare default element namespace "http://www.loc.gov/MARC21/slim";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";
(: find orphan works in orphans-delete-uris.xqy  :)
                 
declare variable $URI as xs:string external;
declare variable $delete-marcxml-collections := fn:false();

if (fn:doc-available($URI)) then
	(
	try { xdmp:document-delete($URI)
	}
	catch($e) {xdmp:log(fn:concat("CORB orphan work deletion failed : ",$URI ), "info")
	}
	, 
	 xdmp:log(fn:concat("CORB orphan work deleted : ",$URI ), "info")
	)

else
xdmp:log(fn:concat("CORB  orphan work deletion , doc not found for : ",$URI ), "info")
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)