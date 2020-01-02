xquery version "1.0-ml";

(:


	this is  the editor processor, modules/bfe2mets and calls some of the functions in the converter processor modules/bibs2mets

	module namespace bf2mets = "http://loc.gov/ndmso/authorities-2-bibframe";
	module namespace bfe2mets = "http://loc.gov/ndmso/bfe-2-mets";
:)
	

declare copy-namespaces no-preserve, inherit;
declare namespace   mets       		    = "http://www.loc.gov/METS/";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   owl                 = "http://www.w3.org/2002/07/owl#";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf             = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mads	            = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mxe					= "http://www.loc.gov/mxe";
declare namespace   ri                  = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   bf              	= "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace   index               = "info:lc/xq-modules/lcindex";
declare namespace   mlerror	            = "http://marklogic.com/xdmp/error"; 
declare namespace 	pmo  				= "http://performedmusicontology.org/ontology/";
import module namespace bfe2mets = "http://loc.gov/ndmso/bfe-2-mets" at "../modules/bfe2mets.xqy";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace 		bf4ts   			= "info:lc/xq-modules/bf4ts#"   		 at "../modules/module.BIBFRAME-4-Triplestore.xqy";

import module namespace bibframe2index      = "info:lc/id-modules/bibframe2index#" at "../modules/module.BIBFRAME-2-INDEX.xqy";

(: ==============================================================================================================
:	ALERT: using test version of bibs2mets: (drop .new to revert to production version
:   =============================================================================================================:)
import module namespace bibs2mets = "http://loc.gov/ndmso/bibs-2-mets" at "../modules/module.bibs2mets.xqy";

declare variable $quality := ();    
declare variable $forests:=();
declare variable $BASE_COLLECTIONS:= ("/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/", "/catalog/lscoll/lcdb/bib/" );
	

(:======================main logic ======================

	Expectations: POSTED data will consist of a whole package, work, instance(s) , item(s) or an individual node with references to nodes in the db.
	if the work is null, process the instance by itself, (calculate Ids based on it as well.)
	Some works are embedded in instance; try to pull it out.
	also try to get lccn from instance
  ======================main logic ======================
:)

		let $body:= xdmp:get-request-body("xml")/node()
		let $root-node:=$body/*[self::* instance of element (bf:Work) or self::* instance of element (bf:Instance) or self::* instance of element (bf:Item) ][1]
		let $id:= fn:concat(fn:string($root-node/@rdf:about), fn:string($root-node/@rdf:nodeID))
		let $_x:= xdmp:log(fn:concat("CORB BFE editor load: starting " , $id  )   , "info")
		let $lccn:= fn:string($body/bf:Instance/bf:identifiedBy/bf:Lccn[1]/rdf:value)
		let $lccn:= if ($lccn) then $lccn else  fn:string($body/bf:Work/bf:hasInstance/bf:Instance/bf:identifiedBy/bf:Lccn[1]/rdf:value)
		(: Consider just storing bibframe.rdf in the database, no need for HTTP overhead :)

		(: Can load the bibframe.rdf as Semantics sem:triples, and infer or property path the subclasses too :)
		(: editor stores the root node as subclasses; database needs bf:Work :)

		let $bfonto:= xdmp:http-get("http://id.loc.gov/ontologies/bibframe.rdf")[2]
		let $worktypes:=
		    for $subc in $bfonto//owl:Class[rdfs:subClassOf[@rdf:resource="http://id.loc.gov/ontologies/bibframe/Work"]]
		    return (fn:substring-after($subc/@rdf:about,"bibframe/"))

		(:nodes that can be embedded into works etc:)
		let $linkables:= $body/*[fn:not(fn:matches(fn:local-name(),("Work", "Instance", "Item", $worktypes)))]

		(: convert to bf:Work from bf:Text :)
		let $workraw1:= 
		    if ($body/bf:Work) then
						$body/bf:Work[1]
				else if ($body/bf:Instance/bf:instanceOf/bf:Work) then
					$body/bf:Instance/bf:instanceOf/bf:Work
				else 
					for $type in $worktypes
						return
						   for $w in $body/*[local-name()=$type]
					       return $w
 
		
		(:if $workraw1 is null, process instances , items   only   :)

		let $result:= if ($workraw1) then
							bfe2mets:full-package-insert($workraw1,$body, $linkables, $lccn)
					   else
					   		(: process instances, items :)
							bfe2mets:partial-package-insert($body, $linkables, $lccn)	
  return ( 	xdmp:set-response-code(200 ,"OK"),
				$result,			           
					   xdmp:add-response-header("Access-Control-Allow-Origin", "*")
					   )(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)