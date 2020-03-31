xquery version "1.0-ml";
(: 
=============================================================================================================
	Delete orphan stubs : get uris that have not been edited ; does not actually delete; called by corb shell 
	and assumes you  run del-orphan-stub.xqy to delete
=============================================================================================================

:)



declare namespace mets = "http://www.loc.gov/METS/";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   owl                 = "http://www.w3.org/2002/07/owl#";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf             = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mxe					        = "http://www.loc.gov/mxe";
declare namespace   ri                  = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   bf              	= "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace   index               = "info:lc/xq-modules/lcindex";

declare namespace sparql = "http://www.w3.org/2005/sparql-results#";




let $stubs:=cts:uris((),(),
    cts:and-not-query(
		cts:and-query(
		(cts:collection-query("/bibframe/stubworks/"),cts:collection-query("/catalog/")))
		,
		cts:collection-query("/bibframe/editor/")
		)
)

   let $count:=count($stubs)
   return (	xdmp:log(fn:concat("CORB orphan stub deletions starting: ", $count),"info"),
   			$count, 
			$stubs
			)
  
  
  (: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)