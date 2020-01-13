xquery version "1.0-ml";
(:==================
bf4ts
==================:)
(:
:   Module Name: BIBFRAME For Triplestore
:
:   Module Version: 1.0
:
:   Date: 2011 Feb 14
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: none
:
:   Xquery Specification: January 2007
:
: 
:)
   
(:~
:   Primary purpose is to take a BIBFRAME
:   record and generate the a slimmed-down version of it
:   for ingest into a triplestore, for querying purposes.
: 	Adapted from madsrdf4triplestore 
:
:   @author Nate Trail (ntra@loc.gov)
:   @since May 23, 2017
:   @author Kevin Ford (kefo@loc.gov)
:   @since February 14, 2011
:   @version 2.0
:)
  
(:example execution:

			let $rdfxml:=xdmp:http-get("http://mlvlp04.loc.gov:8230/resources/items/c0186516830001.rdf")[2]/rdf:RDF
			let $doc:=utils:mets("loc.natlib.items.c0186516830001")
			let $sem:=bf4ts:bf4ts($rdfxml)
			let $sem-section:=
			 <mets:dmdSec ID="semtriples">
			    <mets:mdWrap MDTYPE="OTHER">
			      <mets:xmlData>{$sem}</mets:xmlData>
			    </mets:mdWrap>
			</mets:dmdSec>     
			let $_:=xdmp:node-replace($doc/mets:metsHdr,<mets:metsHdr LASTMODDATE="2017-08-30T22:19:03.464574-04:00"/>)
			return( $doc ,
			xdmp:node-insert-before($doc/mets:dmdSec[@ID="index"],$sem-section)
			)

:)


(: MODULES :)

module namespace 	bf4ts 			= "info:lc/xq-modules/bf4ts#"   ;

import module namespace sem 		= "http://marklogic.com/semantics"  at "/MarkLogic/semantics.xqy";

(: NAMESPACES :)

declare namespace   rdf             = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs            = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf         = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   lcc             = "http://id.loc.gov/ontologies/lcc#";
declare namespace   bf              = "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            = "http://id.loc.gov/ontologies/bflc/";
declare namespace   ri              = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   owl             = "http://www.w3.org/2002/07/owl#";
declare namespace 	mets 			= "http://www.loc.gov/METS/";
declare namespace 	idx 			= "info:lc/xq-modules/lcindex";
declare namespace 	pmo  			= "http://performedmusicontology.org/ontology/";
declare namespace	lclocal				="http://id.loc.gov/ontologies/lclocal/";

(: skip terms that are text or otherwise can be excluded :)
declare variable $skip-literals:=
<nodes>
<node>bf:acquisitionTerms</node>
<node>bf:ascensionAndDeclination</node>
<node>bf:awards</node>
<node>bf:changeDate</node>
<node>bf:classificationPortion</node>
<node>bf:coordinates</node>
<node>bf:copyrightDate</node>
<node>bf:count</node>
<node>bf:creationDate</node>
<node>bf:credits</node>
<node>bf:custodialHistory</node>
<node>bf:date</node>
<node>bf:degree</node>
<node>bf:derivedFrom</node>
<node>bf:dimensions</node>
<node>bf:duration</node>
<node>bf:edition</node>
<node>bf:editionEnumeration</node>
<node>bf:editionStatement</node>
<node>bf:ensembleType</node>
<node>bf:equinox</node>
<node>bf:exclusionGRing</node>
<node>bf:firstIssue</node>
<node>bf:generationDate</node>
<node>bf:hierarchicalLevel</node>
<node>bf:historyOfWork</node>
<node>bf:instrumentalType</node>
<node>bf:itemPortion</node>
<node>bf:lastIssue</node>
<node>bf:legalDate</node>
<node>bf:musicKey</node>
<node>bf:musicOpusNumber</node>
<node>bf:musicSerialNumber</node>
<node>bf:musicThematicNumber</node>
<node>bf:natureOfContent</node>
<node>bf:noteType</node>
<node>bf:note</node>
<node>bf:organization</node>
<node>bf:originDate</node>
<node>bf:outerGRing</node>
<node>bf:part</node>
<node>bf:partName</node>
<node>bf:partNumber</node>
<node>bf:pattern</node>
<node>bf:physicalLocation</node>
<node>bf:preferredCitation</node>
<node>bf:provisionActivityStatement</node>
<node>bf:qualifier</node>
<node>bf:responsibilityStatement</node>
<node>bf:schedulePart</node>
<node>bf:seriesEnumeration</node>
<node>bf:seriesStatement</node>
<node>bf:spanEnd</node>
<node>bf:subseriesEnumeration</node>
<node>bf:subseriesStatement</node>
<node>bf:subtitle</node>
<node>bf:table</node>
<node>bf:tableSeq</node>
<node>bf:temporalCoverage</node>
<node>bf:variantType</node>
<node>bf:version</node>
<node>bf:voiceType</node>
<node>bf:adminMetadata</node>

</nodes>;
(: make a sequence for comparison:)
declare variable $skip-nodes:=( for $n in $skip-literals/* return fn:string($n));


(:~
:   This is the main function.  It converts BIBFRAME to 
:   an abbreviated version for relationship-querying
:   purposes in a triplestore.
:   It takes the BIBFRAME RDF/XML as the only argument.
:   It removes, for example, literals, but leaves in a lot of blank nodes in case they can be better queried via sparql or end up being public
:
:   @param  $rdf        node() is the rdf:rdf with bf:Work/Instance/Item as a child. 
:   @return rdf:RDF node
:)
declare function bf4ts:bf4ts($rdfxml as element() ) as node()*  {
if ($rdfxml/@rdf:about="") then
 	xdmp:log("CORB bf4ts error: No work/about " ,"info")
	else
		let $out-format:="triplexml"			

		let $sem:=	try{ sem:rdf-serialize( 
					sem:rdf-parse(bf4ts:filter($rdfxml)),  $out-format 
					)

				}			
			catch($e){
					(xdmp:log(fn:concat("CORB bf4ts error: ",fn:string($rdfxml/*[1]/@rdf:about),"... ",xdmp:quote($e//error:format-string)),"info")
						(:xdmp:log(fn:concat("CORB bf4ts error: ", fn:string($rdfxml/*[1]/@rdf:about) ),"info"):)
						
						
					)
			}

	return $sem
};

declare function bf4ts:filter($rdfxml as element() ) as node()* {

let $bf:= $rdfxml/child::node()[fn:name()][1]
return
	<rdf:RDF
	xmlns:rdf             = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs            = "http://www.w3.org/2000/01/rdf-schema#"
	xmlns:madsrdf         = "http://www.loc.gov/mads/rdf/v1#"
	xmlns:lcc             = "http://id.loc.gov/ontologies/lcc#"
	xmlns:bf              = "http://id.loc.gov/ontologies/bibframe/"
	xmlns:bflc            = "http://id.loc.gov/ontologies/bflc/"
	xmlns:ri              = "http://id.loc.gov/ontologies/RecordInfo#"  
	>
  {bf4ts:process($rdfxml/child::*[1])}
	
	</rdf:RDF>

};

declare function bf4ts:process($node) {
 
 for $n in $node
 return
   typeswitch($n)
   
        case attribute()  	return $n
		case text()         return fn:replace($n, " \[from old catalog\]","")
		case comment() 		return ()
        case element() 		return 
								 (: doesnt' do much ?? :)
								 if ($n/@rdf:about or $n/@rdf:resource  ) then
                                         bf4ts:cleanup($n)																
								  else if ($n/*/@rdf:about or $n/@rdf:resource ) then
                                         bf4ts:cleanup($n)
                                   else if ($n instance of element (bflc:derivedFrom))   then
                                         bf4ts:cleanup($n)                                       
								   else if ($n instance of element (bflc:relationship))   then
                                         bf4ts:cleanup($n)	 
									else if ($n instance of element (bflc:Relationship))   then
                                         bf4ts:cleanup($n)	 
                                   else if ($n instance of element (bf:itemOf))   then
                                         bf4ts:cleanup($n)                                       
                                   else if ($n instance of element (bflc:applicableInstitution) )  then
                                         bf4ts:cleanup($n)  
                                   else if (fn:index-of($skip-nodes,fn:name($n))) then 
                                         () 
                                   (: stop skipping bflc 2019 09 12:)
								   (:else if (fn:starts-with(fn:name($n),'bflc')) then
                                         ():)
                                   else bf4ts:cleanup($n) 
       	
        default 		     return bf4ts:process($n)
};



declare function bf4ts:cleanup($node) {
(: need to stop indexing (relatedto/Work/about ) stuff with id uris in about, resource :)
if ($node/child::*[1]/@rdf:about and fn:contains($node/child::*[1]/@rdf:about,"#Work880-") or fn:matches($node/child::*[1]/@rdf:about,"#Work7[0-9]{2}-[0-9]{2}") or fn:matches($node/child::*[1]/@rdf:about,"#Work2[0-9]{2}-[0-9]{2}")) then
()(: skip links to embedded 880 works :)
else
element {xs:QName(fn:name($node))} {
		(		        
		if ($node/@rdf:resource and fn:starts-with(fn:string($node/@rdf:resource),"www.") ) then
            (attribute rdf:resource {fn:concat("//",fn:string($node/@rdf:resource))}                
                )
		else if ($node/@rdf:about) then 
				$node/@rdf:about
		else if ($node/@rdf:resource and fn:not(fn:matches(fn:string($node/@rdf:resource),"^.+//.+$") ) ) then
				element rdfs:label {fn:string($node/@rdf:resource)}

        else  $node/@*
		,       
		        (: found that related Works were being skipped 2019-03-04:)
		
		 	bf4ts:process($node/node() )
		
		)
		
}



};

(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)