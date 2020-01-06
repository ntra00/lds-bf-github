xquery version "1.0-ml";
(:
:   Module Name: Search ML copied from the searchTs in ID-main
:
:   Module Version: 2.0
:
:   Date: 2017 June 22
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:     Application specific functions to
:       query a SPARQL endpoint.
:
:)

(:~
:   Application specific functions to
:   query a SPARQL endpoint.
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since June 22, 2011
:   @version 1.0
:)

module namespace searchts = 'info:lc/xq-modules/searchts#';

(: Imported modules :)
import module namespace sem                 = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace search              = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace cfg 				= "http://www.marklogic.com/ps/config" at "/src/lds/config.xqy";

(: Namespaces :)
declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace xdmphttp = "xdmp:http";
declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
declare namespace rdf       = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(:~
:   Search database for this item's instance title, since items don't have titles
:
:
:   @param  $uri 		string : instance uri: http:.../resources/instance/c0*
:   
:   @return element( sparql:results) 
:)
declare function searchts:return-related-title($uri as xs:string, $related-graph) as element(sparql:results) 
{
       
    let $query := <query><![CDATA[
			PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
			PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
			PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
			PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	            
			SELECT  distinct ?label ?relateduri  
			WHERE {
  			  	OPTIONAL {		?uri 	bf:title 		?tnode .
							?tnode 			rdfs:label		?label }.  		  	
	  			BIND ( ?uri as ?relateduri  ) .
			}     
	        ]]></query>
                              
	let $params := 
        map:new((
            map:entry("uri", sem:iri($uri)       )
        ))
    	
	return searchts:sparql($query/text(), $params,$related-graph)
	
	
};	
(: first time in, no offset :)
declare function searchts:return-work-siblings($work-uri as xs:string , $set as xs:string) as element(sparql:results) 
{
	searchts:return-work-siblings($work-uri  , $set, 0)
};
(:~
:   Search database for this Work's related  works
:
:
:   @param  $uri 		string : http:.../resources/work/c0*  or n*
:   @param set		director or indirect text flag
:	@param offset	  defaults to zero if not set
:   @return element( sparql:results) 
:)
declare function searchts:return-work-siblings($work-uri as xs:string , $set as xs:string, $offset) as element(sparql:results) 
{
let $offset:= if (fn:not($offset castable as xs:integer)) then 0
				else if ($offset > 200 ) then 200
				else $offset
(:OPTIONAL {?relateduri rdfs:label 	?label } .:)
    let $query := 
		if ($set="expressions") then
			<query><![CDATA[
					PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
					PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
					PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
					PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	            
					SELECT distinct ?relation ?relateduri ?label ?direction
					WHERE { {  		
			  				?relateduri ?relation ?uri .
							VALUES ?relation {	bf:expressionOf	bf:hasExpression	bf:translationOf	bf:translation	} .
							OPTIONAL {	?relateduri 	bf:title 	?tnode .
										?tnode rdfs:label	?label }.  		
							bind ("Inverse" as ?direction) .
							}
							UNION {  		
				  				?uri  ?relation  ?relateduri .
								values ?relation {	bf:expressionOf	bf:hasExpression	bf:translationOf	bf:translation} .
								OPTIONAL {		?relateduri 	bf:title 		?tnode .
												?tnode 			bf:mainTitle ?label }.  		
							bind ("Direct" as ?direction) .
							 } 
						  } limit 50
						  OFFSET ?offset
	        ]]></query>
        else if ($set ="nonex-relateds") then
			<query><![CDATA[
						PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
						PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
						PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
						PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	            
						SELECT  distinct ?relation ?relateduri ?label ?direction
						WHERE { {  		
				  				?relateduri ?relation ?uri .
								values ?relation {		bf:relatedTo bf:eventContentOf	bf:hasEquivalent	bf:hasPart	bf:partOf	bf:accompaniedBy	bf:accompanies	
														bf:hasDerivative	bf:derivativeOf	bf:precededBy	bf:succeededBy	bf:references	bf:referencedBy	bf:	bf:issuedWith	bf:otherPhysicalFormat	bf:hasReproduction	bf:reproductionOf	bf:dataSource	bf:hasSeries	bf:seriesOf	bf:hasSubseries	bf:subseriesOf	bf:supplement	bf:supplementTo	 
														bf:originalVersion	bf:originalVersionOf	bf:index	bf:indexOf	bf:otherEdition	bf:otherEditionOf
														bf:findingAid	bf:findingAidOf	bf:replacementOf	bf:replacedBy	bf:mergerOf	bf:mergedToForm	bf:continues	
														bf:continuedBy	bf:continuesInPart	bf:splitInto	bf:absorbed	bf:absorbedBy	bf:separatedFrom	bf:continuedInPartBy
												} .
								OPTIONAL {		?relateduri 	bf:title 		?tnode .
										 	?tnode 			bf:mainTitle ?label }.  		
								bind ("Inverse" as ?direction) .
							 } 
							 UNION {  		
				  				?uri  ?relation  ?relateduri .
								values ?relation {		bf:relatedTo bf:eventContentOf	bf:hasEquivalent	bf:hasPart	bf:partOf	bf:accompaniedBy	bf:accompanies	
														bf:hasDerivative	bf:derivativeOf	bf:precededBy	bf:succeededBy	bf:references	bf:referencedBy	bf:	bf:issuedWith	bf:otherPhysicalFormat	bf:hasReproduction	bf:reproductionOf	bf:dataSource	bf:hasSeries	bf:seriesOf	bf:hasSubseries	bf:subseriesOf	bf:supplement	bf:supplementTo	 
														bf:originalVersion	bf:originalVersionOf	bf:index	bf:indexOf	bf:otherEdition	bf:otherEditionOf
														bf:findingAid	bf:findingAidOf	bf:replacementOf	bf:replacedBy	bf:mergerOf	bf:mergedToForm	bf:continues	
														bf:continuedBy	bf:continuesInPart	bf:splitInto	bf:absorbed	bf:absorbedBy	bf:separatedFrom	bf:continuedInPartBy
												} .
								OPTIONAL {		?relateduri 	bf:title 		?tnode .
											?tnode 			bf:mainTitle ?label }.  		
								bind ("Direct" as ?direction) .
							 }
							 } limit 50
							 OFFSET ?offset
					]]>
	        </query>     
		 else (:Indirect:)
           <query><![CDATA[
						PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
						PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
						PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
						PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	            
						SELECT  distinct ?relation ?relateduri ?label ?direction
						WHERE { {  		
				  				?relateduri ?relation ?uri .
								values ?relation {		bf:relatedTo bf:eventContentOf	bf:hasEquivalent	bf:hasPart	bf:partOf	bf:accompaniedBy	bf:accompanies	
														bf:hasDerivative	bf:derivativeOf	bf:precededBy	bf:succeededBy	bf:references	bf:referencedBy	bf:	bf:issuedWith	bf:otherPhysicalFormat	bf:hasReproduction	bf:reproductionOf	bf:dataSource	bf:hasSeries	bf:seriesOf	bf:hasSubseries	bf:subseriesOf	bf:supplement	bf:supplementTo	 
														bf:originalVersion	bf:originalVersionOf	bf:index	bf:indexOf	bf:otherEdition	bf:otherEditionOf
														bf:findingAid	bf:findingAidOf	bf:replacementOf	bf:replacedBy	bf:mergerOf	bf:mergedToForm	bf:continues	
														bf:continuedBy	bf:continuesInPart	bf:splitInto	bf:absorbed	bf:absorbedBy	bf:separatedFrom	bf:continuedInPartBy
												} .
								OPTIONAL {		?relateduri 	bf:title 		?tnode .
											?tnode 			bf:mainTitle ?label }.  		
								bind ("Inverse" as ?direction) .
							 } 
							 UNION {  		
				  				?uri  ?relation  ?relateduri .
								values ?relation {		bf:relatedTo bf:eventContentOf	bf:hasEquivalent	bf:hasPart	bf:partOf	bf:accompaniedBy	bf:accompanies	
														bf:hasDerivative	bf:derivativeOf	bf:precededBy	bf:succeededBy	bf:references	bf:referencedBy	bf:	bf:issuedWith	bf:otherPhysicalFormat	bf:hasReproduction	bf:reproductionOf	bf:dataSource	bf:hasSeries	bf:seriesOf	bf:hasSubseries	bf:subseriesOf	bf:supplement	bf:supplementTo	 
														bf:originalVersion	bf:originalVersionOf	bf:index	bf:indexOf	bf:otherEdition	bf:otherEditionOf
														bf:findingAid	bf:findingAidOf	bf:replacementOf	bf:replacedBy	bf:mergerOf	bf:mergedToForm	bf:continues	
														bf:continuedBy	bf:continuesInPart	bf:splitInto	bf:absorbed	bf:absorbedBy	bf:separatedFrom	bf:continuedInPartBy
												} .
								OPTIONAL {		?relateduri 	bf:title 		?tnode .
												?tnode 			bf:mainTitle ?label }.  		
								 bind ("Direct" as ?direction) .
							 } 
							 
							  UNION {  		
				  				?uri  bflc:relationship ?rel .
								  ?rel bf:relatedTo ?relateduri .
								
								OPTIONAL {		?relateduri 	bf:title 		?tnode .
												?tnode 			bf:mainTitle ?label }.  		
								bind ("Direct" as ?direction) .
							 } 
							 } ORDER BY ?relation ?label 
							  LIMIT 50
							  OFFSET ?offset
					]]>
	        </query>            
  (:let $put := map:put($bindings,"limit",sem:typed-literal('1',sem:iri("xs:integer")))
  let $params := 
        map:new((            
            map:entry( "lccn", sem:typed-literal($lccn,sem:iri("http://www.w3.org/2001/XMLSchema#string")) )
        ))
:)
	let $params:= map:map()
	let $put := map:put($params, "uri",  sem:iri($work-uri)       )
	let $put := map:put($params, "offset",sem:typed-literal($offset, sem:iri("xs:integer")    ))

	let $res:=
			searchts:sparql($query/text(), $params, "/resources/works/")
	

	return $res
};	
(:~
:   Search database for this Work's related  works
: 
:	called by works for direc and indirect
:   @param  $uri 		string : http:.../resources/work/c0*  or n*
:	@param offset	  defaults to zero if not set
:)
declare function searchts:work-siblings-directional($work-uri as xs:string , $direction as xs:string, $offset) as element(sparql:results) 
{
	
	let $limit:=$cfg:SPARQL-LIMIT
	
    let $query := 
		if ($direction="Direct") then
			<query><![CDATA[
						PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
						PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
						PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
						PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
			            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

						SELECT  distinct ?relation ?relateduri ?label ?direction 
						WHERE {  {  		
				  				?uri  ?relation  ?relateduri .
								VALUES ?relation {		bf:relatedTo bf:eventContentOf	bf:hasEquivalent	bf:hasPart	bf:partOf	bf:accompaniedBy	bf:accompanies	
														bf:hasDerivative	bf:derivativeOf	bf:precededBy	bf:succeededBy	bf:references	bf:referencedBy	bf:	bf:issuedWith	bf:otherPhysicalFormat	bf:hasReproduction	bf:reproductionOf	bf:dataSource	bf:hasSeries	bf:seriesOf	bf:hasSubseries	bf:subseriesOf	bf:supplement	bf:supplementTo	 
														bf:originalVersion	bf:originalVersionOf	bf:index	bf:indexOf	bf:otherEdition	bf:otherEditionOf
														bf:findingAid	bf:findingAidOf	bf:replacementOf	bf:replacedBy	bf:mergerOf	bf:mergedToForm	bf:continues	
														bf:continuedBy	bf:continuesInPart	bf:splitInto	bf:absorbed	bf:absorbedBy	bf:separatedFrom	bf:continuedInPartBy
														bf:expressionOf	bf:hasExpression	bf:translationOf	bf:translation
												} .
								FILTER isURI(?relateduri) .
								OPTIONAL {		?relateduri 	bf:title 		?tnode .
												?tnode 			bf:mainTitle ?label }.  		
								bind ("Direct" as ?direction) .
							 }
							 # 2019-09-12: repeats the last one?
						# UNION {  		
				  			#			?uri  bflc:relationship ?rel .
								#  		?rel bf:relatedTo ?relateduri .
								# FILTER isURI(?relateduri) .
								
								#OPTIONAL {		?relateduri 	bf:title 		?tnode .
									#?tnode 			bf:mainTitle ?label }.  		
								#BIND ("Direct" as ?direction) .
							 #}
							  UNION {
				                  		?uri bflc:relationship ?relClass .
					                   	
					                  	?relClass bf:relatedTo ?relateduri .
            					
					            FILTER(  isUri(?relateduri) &&
					                	 !(regex(?relateduri, "#Work"))
					             	    )
					              #OPTIONAL {?relateduri 			rdfs:label		?label  .  	}
								  OPTIONAL {?relClass 		bflc:relation	?relation  .  	}
								    OPTIONAL {		?relateduri 	bf:title 		?tnode .
													?tnode 			bf:mainTitle ?label }.  		
								  
					              BIND  ("text-relation" as ?direction). 				  		
							 			 }
							} limit ?limit
							 OFFSET ?offset
					]]>
	        </query>     
        else (: indirect :)
			<query><![CDATA[
						PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
						PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
						PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
						PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	            
						SELECT  distinct ?relation ?relateduri ?label ?direction
						WHERE { {  		
				  				?relateduri ?relation ?uri .
								values ?relation {		bf:relatedTo bf:eventContentOf	bf:hasEquivalent	bf:hasPart	bf:partOf	bf:accompaniedBy	bf:accompanies	
														bf:hasDerivative	bf:derivativeOf	bf:precededBy	bf:succeededBy	bf:references	bf:referencedBy	bf:	bf:issuedWith	bf:otherPhysicalFormat	bf:hasReproduction	bf:reproductionOf	bf:dataSource	bf:hasSeries	bf:seriesOf	bf:hasSubseries	bf:subseriesOf	bf:supplement	bf:supplementTo	 
														bf:originalVersion	bf:originalVersionOf	bf:index	bf:indexOf	bf:otherEdition	bf:otherEditionOf
														bf:findingAid	bf:findingAidOf	bf:replacementOf	bf:replacedBy	bf:mergerOf	bf:mergedToForm	bf:continues	
														bf:continuedBy	bf:continuesInPart	bf:splitInto	bf:absorbed	bf:absorbedBy	bf:separatedFrom	bf:continuedInPartBy
														bf:expressionOf	bf:hasExpression	bf:translationOf	bf:translation
												} .
								FILTER isURI(?relateduri) .
								OPTIONAL {		?relateduri 	bf:title 		?tnode .
												?tnode 			bf:mainTitle ?label }.  		
								OPTIONAL {		?relateduri 	rdfs:label		?label }.  		
								bind ("Inverse" as ?direction) .
							 } 
							  UNION {#text relation
							   
							   			?relClass bf:relatedTo ?uri .
				                  		?relateduri bflc:relationship ?relClass .
					                   	
					                 
            					
					            FILTER(  isUri(?relateduri) &&
					                	 !(regex(?relateduri, "#Work"))
					             	    )
					              #OPTIONAL {?relateduri 			rdfs:label		?label  .  	}
								  OPTIONAL {?relClass 		bflc:relation	?relation  .  	}
								    OPTIONAL {		?relateduri 	bf:title 		?tnode .
													?tnode 			bf:mainTitle ?label }.  		
								  
					              BIND  ("text-relation" as ?direction). 				  		
							 			

							 	}
							 } limit ?limit
							 	offset ?offset
					]]>
	        </query>     
		        
    (:
	let $params := 
        map:new((
            map:entry("uri", sem:iri($work-uri)       )
        ))
    :)
	let $params:= map:map()
	let $put := map:put($params, "uri",  sem:iri($work-uri)       )
	let $put := map:put($params, "offset",sem:typed-literal(fn:string($offset), sem:iri("xs:integer")    ))
	let $put := map:put($params, "limit",sem:typed-literal(fn:string($limit), sem:iri("xs:integer")    ))
	(:let $_:= xdmp:log("$query","info")
	let $_:= xdmp:log($query,"info")
	let $_:= xdmp:log($work-uri,"info")
	:)
	
let $x:=searchts:sparql($query/text(), $params, "/resources/works/")
    
	return $x
	(:searchts:sparql($query/text(), $params, "/resources/works/"):)
};	
(: first time in no offset? 
:)
declare function searchts:return-my-siblings($parent-uri as xs:string, $graph as xs:string ) as element(sparql:results) {
	searchts:return-my-siblings($parent-uri ,$graph , 0)
};
(:~
:   Search database for this item or instances' siblings; start with the parent work uri (or instance)
:
:
:   @param  $uri 		string : http:.../resources/work/c0* or resources/instances/c*
:   @param  $graph 		string : for collection query /resources/instances/ or /resources/items/
:   @return element( sparql:results) 
:)
declare function searchts:return-my-siblings($parent-uri as xs:string, $graph as xs:string, $offset) as element(sparql:results) 
{
let $limit:=$cfg:SPARQL-LIMIT
    
    let $query := <query><![CDATA[
			PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
			PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
			PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
			PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	            
			SELECT   ?relateduri ?label 
			WHERE {  		
	  				?relateduri ?relation ?uri .
			
			VALUES ?relation {
								bf:instanceOf    bf:itemOf
							} .
			OPTIONAL {		?relateduri 	bf:title 		?tnode .
							?tnode 			rdfs:label		?label }.  					

				} 	
			ORDER BY ?relateduri
			LIMIT $limit
			OFFSET ?offset
	        ]]></query>
                          
(:	let $params := 
        map:new((
            map:entry("uri", sem:iri($parent-uri)       )
        ))
		:)
		
	let $params:= map:map()
	let $put := map:put($params, "uri",  sem:iri($parent-uri)       )
	let $put := map:put($params, "offset",sem:typed-literal(fn:string($offset), sem:iri("xs:integer")    ))

	let $put := map:put($params, "limit",sem:typed-literal(fn:string($limit), sem:iri("xs:integer")    ))

    	(:let $_:=xdmp:log($query,"info"):)
	return searchts:sparql($query/text(), $params, $graph)
};	

					
(:~
:   Search database for this objects children (not item) or parent (not work)
:
:
:   @param  $uri 		string : http:.../resources/works/c0* or instances
:   @param  $relation 	string bf:instanceOf or bf:itemOf
:   @param  $parent-graph 	string /resources/works/ or /resources/instances/
:   @return element( sparql:results) 
:)
declare function searchts:return-specific-family($uri as xs:string, 
					$relation as xs:string, 
					$parent-graph as xs:string)
		as element(sparql:results) 
{
       
    let $query := <query><![CDATA[
			PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
			PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
			PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
			PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>

	            
			SELECT   distinct ?relateduri  ?label   
			WHERE {
					        ?relateduri   	?relation    	?uri .

	  		OPTIONAL {						
								?relateduri 	bf:title 		?tnode .
								?tnode 			rdfs:label		?label .						
								}		

			} ORDER BY ?relateduri
			  LIMIT ?limit
	        ]]></query>
                          
    
	let $params := 
        map:new((
            map:entry("uri", sem:iri($uri)       ),
            map:entry("relation",sem:iri( $relation )      )
        ))
		
    	
	return searchts:sparql($query/text(), $params,  $parent-graph)
};							
		(:~
:   Search database for this instance's  items
:
:
:   @param  $uri 		string : http:.../resources/instances/c0*or e*
:   @return element( sparql:results) 
:)
declare function searchts:return-my-items($uri as xs:string 					
					)
		as element(sparql:results) 
{
        
    let $query := <query><![CDATA[
			PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
			PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
			PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
			PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>

	            
			SELECT   distinct ?relateduri    
			WHERE {
					        ?relateduri   	bf:itemOf   	?uri .

			} ORDER BY ?relateduri
			  LIMIT 20
	        ]]></query>
                          
    
	let $params := 
        map:new((
            map:entry("uri", sem:iri($uri)       )
            
        ))		
    	 
	return searchts:sparql($query/text(), $params, "/resources/items/")
	
};							
(:~
:   Search database for matching relation parent/child: work to instance,to  item, or back .
:May not be used; see specific family
:
:     @param  $uri 		string : http:.../resources/works/c0*
:
:   @return element( sparql:results) 
:)
declare function searchts:return-family($uri as xs:string) as element(sparql:results) 
{
(:works but not the right thing?
:)        
    let $query :=  <query><![CDATA[
        
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
			PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
			PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
			PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
            
			SELECT  ?relateduri  ?related ?label
            WHERE {
               ?relateduri ?relation ?uri .
			   
				
            	values ?relation   {<http://id.loc.gov/ontologies/bibframe/instanceOf> 
									<http://id.loc.gov/ontologies/bibframe/hasInstance> 
									<http://id.loc.gov/ontologies/bflc/itemOf> 
									<http://id.loc.gov/ontologies/bibframe/itemOf>
									<httfdp://id.loc.gov/ontologies/bibframe/hasItem> 
								   }.
				?uri rdfs:label $label .
            } limit 20
            
        ]]></query>
  
    
	let $params := 
        map:new((
            map:entry("uri", sem:iri($uri)            )
        ))
    
	(: let $_ := xdmp:log(fn:concat("params:  ", $params)):)
    (: let $_ := xdmp:log(fn:concat("return-component-uri query is ", $query/text())):)
    
	return searchts:sparql($query/text(), $params)
};
(:~
:   Search database for matching RWO detail. 
: not used in mdoc
:   @param  $sParams    element
:   @param  $count      xs:integer
:   @return element()
:)
declare function searchts:return-detail-uri($label, $property, $scheme_uri) as element(sparql:results) 
{
    
    let $query := 
        <query><![CDATA[
        
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
            SELECT DISTINCT ?uri
            WHERE {
                ?uri $property $label .
                FILTER(isURI(?uri)) .
                ?uri madsrdf:isMemberOfMADSScheme $scheme_uri .
            }
            
        ]]></query>
    let $literal := 
        if ( $property eq "madsrdf:code" ) then
            sem:typed-literal(
                $label, 
                sem:iri("http://www.w3.org/2001/XMLSchema#string")
            )
        else
            rdf:langString(
                $label,
                "en"
            )
    let $params := 
        map:new((
            map:entry("label", $literal),
            map:entry("property", sem:iri( fn:concat("http://www.loc.gov/mads/rdf/v1#", fn:substring-after($property, ":")) ) ),
            map:entry("scheme_uri", sem:iri($scheme_uri))
        ))
   (: let $_ := xdmp:log($params):)
    return searchts:sparql($query/text(), $params)
};

(:~
:   Search database for matching relation,
:   which may be a relation or component.
:
:   @param  $sParams    element
:   @param  $count      xs:integer
:   @return element()
:)
declare function searchts:return-known-relations($uri as xs:string) as element(sparql:results) 
{
    let $query := 
        <query><![CDATA[
        
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            
            SELECT DISTINCT ?uri ?relation ?related ?label ?alabel
            WHERE {
            $resource_uri ?relation ?o .
            ?o $label_prop ?label .
            $resource_uri madsrdf:isMemberOfMADSScheme ?scheme .
            $resource_uri madsrdf:isMemberOfMADSCollection ?collection .

            ?related $label_prop ?label .
            FILTER(?o != ?related) .
            ?related madsrdf:authoritativeLabel ?alabel . 
            ?related madsrdf:isMemberOfMADSScheme ?scheme .
            ?related madsrdf:isMemberOfMADSCollection ?collection .
            FILTER(isURI(?related)) .
            FILTER(
                ?collection != <http://id.loc.gov/authorities/names/collection_LCNAF> && 
                ?collection != <http://id.loc.gov/authorities/subjects/collection_LCSH_General>
            ) .
            BIND($resource_uri as ?uri) .
            }
            
        ]]></query>
    let $label_prop := 
        if ( fn:contains($uri, "/classification/") ) then
            sem:iri("http://www.w3.org/2000/01/rdf-schema#label")
        else
            sem:iri("http://www.loc.gov/mads/rdf/v1#authoritativeLabel")
    let $params := 
        map:new((
            map:entry("label_prop", $label_prop),
            map:entry("resource_uri", sem:iri($uri))
        ))
    return searchts:sparql($query/text(), $params)
};


(:~
:   Retrieve relations based on the resource's URI, not a relation and label.
:   This is a helper function that sets the label property to madsrdf:authoritativeLabel.
:
:   @param  $uri        xs:string
:   @return element(sparql:results)
:)
declare function searchts:return-known-relations-from-uri($uri as xs:string) as element(sparql:results) 
{
    searchts:return-known-relations-from-uri($uri, "http://www.loc.gov/mads/rdf/v1#authoritativeLabel")
};

(:~
:   Retrieve relations based on the resource's URI, not a relation and label.
:
:   @param  $uri        xs:string
:   @param  $label_prop xs:string
:   @return element(sparql:results)
:)
declare function searchts:return-known-relations-from-uri($uri as xs:string, $label_prop as xs:string) as element(sparql:results) 
{
    let $query := 
        <query><![CDATA[
        
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            
            SELECT DISTINCT ?uri ?relation ?related ?alabel
            WHERE {
                #GRAPH <g:extrardf> {
                    $resource_uri ?relation ?related .
                    FILTER( isURI(?related) ) .
                    ?related $label_prop ?alabel .
                    
                    # kefo commented out
                    #OPTIONAL {
                    #   ?related $label_prop ?alabel .
                    #} .
                    #OPTIONAL {
                    #   ?related <http://www.w3.org/2000/01/rdf-schema#label> ?alabel.
                    #} .
                    
                    BIND($resource_uri as ?uri) .
                #}
            }
        ]]></query>
    let $lprop := sem:iri($label_prop)
    let $params := 
        map:new((
            map:entry("label_prop", $lprop),
            map:entry("resource_uri", sem:iri($uri))
        ))
    return searchts:sparql($query/text(), $params)
};

(:~
:   Retrieve relations based on the resource's URI, not a relation and label.
:
:   @param  $uri        xs:string
:   @param  $label_prop xs:string
:   @return element(sparql:results)
:)
declare function searchts:return-known-relations-from-uri-no-label($uri as xs:string) as element(sparql:results) 
{
    (: 
        There are a few ways to do negation in SPARQL.
        You'll note that the below has a couple of commented out lines.  
        These are left for historical purposes, as a reminder that alternates have been tried.
        The first attempt was with FILTER NOT EXISTS.  It works, but it was slow.
        The second was to try MINUS.  It too worked but was equally slow.
        Ergo, the OPTIONAL/FILTER !BOUND pattern was used.  It achieves the same result, but is faster.
    :)
    let $query := 
        <query><![CDATA[
        
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
            PREFIX owl: <http://www.w3.org/2002/07/owl#>
            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            
            SELECT DISTINCT ?uri ?relation ?related
            WHERE {
                $resource_uri ?relation ?related .
                FILTER( isURI(?related) ) .
                FILTER( !CONTAINS(STR(?related), 'id.loc.gov') ).
                FILTER( 
                    ?relation != madsrdf:isMemberOfMADSScheme && 
                    ?relation != madsrdf:isMemberOfMADSCollection && 
                    ?relation != madsrdf:identifiesRWO && 
                    ?relation != rdf:type && 
                    ?relation != owl:sameAs 
                ) .
                
                # FILTER NOT EXISTS { ?related rdfs:label|madsrdf:authoritativeLabel ?label } .
                # MINUS { ?related rdfs:label|madsrdf:authoritativeLabel ?label } .
                
                OPTIONAL { ?related rdfs:label|madsrdf:authoritativeLabel ?label . }
                FILTER(!BOUND(?label)) .
                
                BIND($resource_uri as ?uri) .
            }
        ]]></query>
    let $params := 
        map:new((
            map:entry("resource_uri", sem:iri($uri))
        ))
    return searchts:sparql($query/text(), $params)
};

(: if you call sparql w/o a graph, send in () as graph :)
declare function searchts:sparql($query, $params) as element(sparql:results)
{

 searchts:sparql($query, $params,() ) 
};

(:~
:   This function executes the sparql query.
:
:   @param  $query as xs:string
:   @param  $params as map:map
:   @graph optional cts:collection query
:   @return semresponse as element
:)
declare function searchts:sparql($query, $params,$graph) as element(sparql:results)
{
(: 2018 02 02 add /catalog/ collection query to all queries :)
(:	let $x:= sem:sparql($query, $params)
	let $_ := xdmp:log(fn:concat("$query is ", $query))
	let $_ := xdmp:log(fn:concat("$params is ", $params))
	let $y:=sem:query-results-serialize( $x)
	let $_ := xdmp:log(fn:concat("res is ", $y))

		return $y/sparql:results
:)

if ($graph) then
	(
		(: xdmp:log($query,"info"),:)
    	sem:query-results-serialize( 
			sem:sparql($query, $params, (),
						cts:and-query((
										cts:collection-query("/catalog/"),  
										cts:collection-query($graph) 
									 ))
						) 
		)/sparql:results 
)

    else
	( (:xdmp:log($query,"info"),:)

    	sem:query-results-serialize( sem:sparql($query, $params,(),(),cts:collection-query("/catalog/") ) )/sparql:results
		)

};







(: Keep the below for now. :)





(:~
:   Search database for matching relation,
:   which may be a relation or component.
:
:   @param  $sParams    element
:   @param  $count      xs:integer
:   @return element()
:)
declare function searchts:return-component(
        $sParams as element()
        ) as item()* 
{

    let $ops := 
        for $op in $sParams/param[@prop]
        return fn:concat('?s <' , xs:string($op/@prop) , '> ' , 
            if (fn:matches( xs:string($op/@value) , 'http://|info:/' )) then
                fn:concat('<' , escape-quotes( xs:string($op/@value) ) , '>')
            else 
                fn:concat('"' , escape-quotes( xs:string($op/@value) ) , '"'),
            if ( xs:string($op/@lang) != "") then
                fn:concat('@' , xs:string($op/@lang))
            else ''
            )
            
    let $ops := fn:string-join($ops, ' .
	')
 
    let $types := 
        for $t in $sParams/param[@name="type"]
        return fn:concat('?t = <', xs:string($t), '>')
    let $types := fn:string-join($types, ' &amp;&amp; ') 
    
    let $notcollection := 
        if ($sParams/param[@notprop ne '']) then
            for $np in $sParams/param[@notprop ne '']
            return
                fn:concat(
                    '?s <' , xs:string($np/@notprop) , '> ?npvalue . 
                    FILTER( ?npvalue != <' , xs:string($np/@notvalue) , '>)'
                )
        else '' 
     let $notcollection := fn:string-join($notcollection, ' . ') 

    let $query :=
		if (fn:count( $sParams/param[@name="type"])=1 )  then
		    let $type:=  		fn:concat('<', xs:string($sParams/param[@name="type"]), '>' )	 	
	        return
				fn:concat( '# Components : singletype query:
				SELECT DISTINCT ?s ?l WHERE {
		            ', $ops , ' .
		            ?s <http://www.loc.gov/mads/rdf/v1#generalLabel> ?l .
		            ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ',$type,' .           
		            ' , $notcollection , '
		        }' )   
		
	 	else (: multiple types , could be UNION :)
			fn:concat( '# Components : 
			SELECT DISTINCT ?s ?l WHERE {
	            ', $ops , ' .
	            ?s <http://www.loc.gov/mads/rdf/v1#generalLabel> ?l .
	            ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
	            FILTER(' , $types , ') . 
	            ' , $notcollection , '
	        }' )
	 		(: 
	        ?s <http://www.loc.gov/mads/rdf/v1#isMemberOfMADSCollection> ?subdiv . 
	            FILTER(?subdiv != <http://id.loc.gov/authorities/lcsh/collection_Subdivisions> . 
	        :)	
       
    let $results := searchts:post-sparql-query($query)     	
    
    return searchts:format-sparql-response($results)
    
};

(:~
:   Search database for establishing an inverse relation.
:  
:        SELECT ?s ?p ?l
:        WHERE {
:            ?b1 <http://www.loc.gov/mads/rdf/v1#authoritativeLabel> ?l .
:            ?s ?p ?b1 .
:            FILTER ( !isBLANK(?s) ) .
:            FILTER ( 
:                ?p = <http://www.loc.gov/mads/rdf/v1#hasBroaderExternalAuthority> || 
:                ?p = <http://www.loc.gov/mads/rdf/v1#hasExternalNarrowerAuthority>  ) .
:            ?s ?p1 <http://www.loc.gov/mads/rdf/v1#Topic> . 
:            ?s <http://www.loc.gov/mads/rdf/v1#isMemberOfMADSScheme> ?sc . 
:            FILTER ( ?sc != <http://id.loc.gov/subjects> ) .
:        }
:
:   @param  $sParams    element
:   @param  $count      xs:integer
:   @return element()
:)
declare function searchts:return-inverse-relations(
        $sParams as element()
        ) as item()* 
{
    (: let $relation := xs:string($sParams/param[@name="relationship"]) :)
    
    let $labelprop := xs:string($sParams/param[@name="labelprop"])
    let $types := $sParams/param[@name="type"]
    let $t1 := xs:string($types[1])
    let $t2 := xs:string($types[2])
    let $label := escape-quotes( xs:string($sParams/param[@name="label"]) ) 
    (: is this how a single quote is stored? :)
    let $scheme := xs:string($sParams/param[@name="scheme"])
    let $mu := xs:string($sParams/param[@name="mURI"])
    let $su := xs:string($sParams/param[@name="sURI"])
  
  		
    let $relations2match := 
            for $np in $sParams/param[@name="relationship"]
            return
                fn:concat('?p2invert = <' , xs:string($np) , '>')  
    let $relations2match := if ($relations2match ne '') then
                                fn:string-join($relations2match, ' ||
								 ')
                             else ''
    
    let $relations2match:= if ($relations2match ne '') then
                            fn:concat("  FILTER (" ,
                            $relations2match , " 
                            ) .")
                            else ''

  
    (: 
        This currently does not do anything with the second TYPE.
        Is that going to be a problem?
    :)
    (: 
        2011 10 07 - removing use of the first TYPE.  See how it works.
        The first type inhibits all possible matches.  For example,
        When trying to determine narrower relations to "Deltas--Colombia" (sh00002573)
        it restricts results only to those of a ComplexSubject type.  This
        fails to find, therefore, "Patía River Delta (Colombia)" (sh00002580).
    :)
    (:
        2014 05 19 - Running 4store 1.1.4 on ubuntu 12.04 I believe the below
        query is subject to this bug:  https://github.com/garlik/4store/issues/66
        
        production uses 4store 1.1.3 and seems to be OK.  Weird.  Do not want to 
        rock ship.
        FILTER (
             ' , $relations2match , ' ) .
             # ?s ?p1 <' , $t1 , '> .
             ' ,
    :)
    let $query := 
		fn:concat('# Finding inverse relations : debug=',$cfg:DEBUG, '
			SELECT DISTINCT ?s ?p2invert WHERE {
	        ?b1 ' , $labelprop , ' "' , $label , '"@EN .
	        ?s ?p2invert ?b1      
	         FILTER ( !isBLANK(?s) ) . ',
	         $relations2match,         
	        if ($scheme ne "") then
	            if ($mu ne "") then
	                fn:concat(
	                    if ($su ne "") then
	                        fn:concat( '?s <http://www.loc.gov/mads/rdf/v1#isMemberOfMADSCollection> <', $su ,'> . ' )
	                    else '',
	                        '?s <http://www.loc.gov/mads/rdf/v1#isMemberOfMADSCollection> <', $mu ,'> . ' 
	                    )
	            else				
	                fn:concat('
	                    ?s <http://www.loc.gov/mads/rdf/v1#isMemberOfMADSScheme> ?sc . 
	                    FILTER ( ?sc != <', $scheme ,'> ) . ')
				
	        else '',
	       '
	       }')
    
    let $results := searchts:post-sparql-query($query)
    let $semresponse := searchts:format-sparql-response($results)
     (:let $msg := logging:debug-msg($query):) 
    return $semresponse

};

(:~
:   Search database for matching relation,
:   which may be a relation or component.
:   This is *identical* to return-component and,
:   as such, could probably be unified.
:
:   @param  $sParams    element
:   @return element()
:)
declare function searchts:return-relation(
        $sParams as element()
        ) as item()* 
{

    let $ops := 
        for $op in $sParams/param[@prop]
        return fn:concat('?s <' , xs:string($op/@prop) , '> ' , 
            if (fn:matches( xs:string($op/@value) , 'http://|info:/' )) then
                fn:concat('<' , escape-quotes( xs:string($op/@value) ) , '>')
            else 
                fn:concat('"' , escape-quotes( xs:string($op/@value) ) , '"'),
            if ($op/@lang ne '') then
                fn:concat('@' , $op/@lang)
            else ''
            )
            
    let $ops := fn:string-join($ops, ' . ')
      
	(:  use this for multitypes? soon
	let $newtypes:= if (fn:count($sParams/param[@name="type"]) = 1 ) then
					fn:concat('#?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>  <', xs:string($sParams/param[@name="type"]), '> .')
				else 
					fn:concat('{ ',
						for $t in $sParams/param[@name="type"]
							return fn:concat(' <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>  <',xs:string($t),'> . }'),
							if ( fn:not($sParams/param[@name="type"][fn:position()=fn:last()])) then " UNION " else (),
							') ')      	 		  
:)

    let $types := 
        for $t in $sParams/param[@name="type"]
      	  return fn:concat('?t = <', xs:string($t), '>')
    
	let $types := fn:string-join($types, ' &amp;&amp; ')  
    
	(: 2016 06-17 nate changed the relateds to look for authoritative or general label, not just generalLabel :)
    (: let $query := fn:concat( 'SELECT DISTINCT ?s ?l WHERE {
                    ', $ops , ' .					  					  
					  ?s ?label ?l .
                     FILTER (?label =  <http://www.loc.gov/mads/rdf/v1#generalLabel> || ?label = <http://www.loc.gov/mads/rdf/v1#authoritativeLabel> )
                    ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
                    FILTER(' , $types , ')
                    }' )
					:)
    let $query:= 
		if (fn:count($sParams/param[@name="type"]) = 1 ) then
			let $type:= fn:concat('<', xs:string($sParams/param[@name="type"]), '>')
			return
				fn:concat( '# return-relation: singletype query ', $cfg:DEBUG, '					 
					 SELECT DISTINCT ?s ?l WHERE {
                    ', $ops , ' .					  					  
					{ ?s <http://www.loc.gov/mads/rdf/v1#generalLabel> ?l } UNION { ?s  <http://www.loc.gov/mads/rdf/v1#authoritativeLabel> ?l } .					  
                      ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ',$type, ' . 		
                    }' )
		else
			fn:concat( '# return-relation multiquery
					  SELECT DISTINCT ?s ?l WHERE {
                    ', $ops , ' .					  					  
					{ ?s <http://www.loc.gov/mads/rdf/v1#generalLabel> ?l } UNION { ?s  <http://www.loc.gov/mads/rdf/v1#authoritativeLabel> ?l } .					  
                    ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
                    FILTER(' , $types , ')
                    }' )

	let $results := searchts:post-sparql-query($query)
    let $semresponse := searchts:format-sparql-response($results)
    (: let $msg := logging:debug-msg($semresponse) :)
    return $semresponse
    
};
(:~
:   Search database for matching useFor relations.
:   These are for 010$z cancelled entries; there is nothing on the old deprecated authority so you have to query for it.
:
:   @param  $sParams    element
:   @return element()
:)
declare function searchts:return-useFor-relation(
        $sParams as element()
        ) as item()* 
{
    (:

	
SELECT * WHERE {
 ?newNode madsrdf:useFor <http://id.loc.gov/authorities/names/n205027149> .
} LIMIT 10


   SELECT * WHERE {
 	?deprecatedNode a <http://www.loc.gov/mads/rdf/v1#DeprecatedAuthority> .
 	?newNode madsrdf:useFor ?deprecatedNode  .
} LIMIT 10

    :)
    let $query :=   fn:concat( '#UseFor deprecated 
					SELECT DISTINCT ?s ?l 
                    	WHERE {    ?s <http://www.loc.gov/mads/rdf/v1#useFor>                 
                         			<', xs:string($sParams/param[@name eq "rdfabout"]) , '>
                         		OPTIONAL {
                             		?s <http://www.loc.gov/mads/rdf/v1#authoritativeLabel> ?l .
                         		} .
                         		OPTIONAL {
                             		?s <http://www.w3.org/2000/01/rdf-schema#label> ?l .
                         		} .                     
                    }' )
    let $results := searchts:post-sparql-query($query)
    let $semresponse := searchts:format-sparql-response($results)
    (: let $msg := logging:debug-msg($semresponse) :)
    return $semresponse
};
(:~
:   Search database for matching extrardf relation.
:   These are generally links to external datasets.
:
:   @param  $sParams    element
:   @return element()
:)
declare function searchts:return-extrardf-relation(
        $sParams as element()
        
        ) as item()* 
{
    (: # return-extrardf-relation
    SELECT DISTINCT ?p ?o 
    WHERE { 
        GRAPH <g:extrardf> { 
            <http://id.loc.gov/authorities/subjects/sh85053649> ?p ?o . 
        } 
    }
    :)
    let $query :=   fn:concat('# return-extrardf-relation
					SELECT DISTINCT ?p ?o ?l 
                    WHERE {
                        GRAPH <g:extrardf> {
                            <', xs:string($sParams/param[@name eq "rdfabout"]) , '> ?p ?o .
                            OPTIONAL {
                                ?o <http://www.loc.gov/mads/rdf/v1#authoritativeLabel> ?l .
                            } .
                            OPTIONAL {
                                ?o <http://www.w3.org/2000/01/rdf-schema#label> ?l .
                            } .
                        }
                    }' )
    let $results := searchts:post-sparql-query($query)
    let $semresponse := searchts:format-sparql-response($results)
    (: let $msg := logging:debug-msg($semresponse) :)
    return $semresponse
};

(:~
:   Search database for matching variant record.
:   2016 11 03 NOT USED.
:   @param  $sParams    element
:   @param  $count      xs:integer
:   @return element()
:)
declare function searchts:return-variant(
        $sParams as element()
        ) as item()* 
{

    let $ops := 
        for $op in $sParams/param[@prop]
        return fn:concat('?s <' , xs:string($op/@prop) , '> ' , 
            if (fn:matches( xs:string($op/@value) , 'http://|info:/' )) then
                fn:concat('<' , escape-quotes( xs:string($op/@value) ) , '>')
            else 
                fn:concat('"' , escape-quotes( xs:string($op/@value) ) , '"'),
            if ($op/@lang) then
                fn:concat('@' , $op/@lang)
            else ''
            )
            
    let $ops := fn:string-join($ops, ' . 
	')

    
    let $types := 
        for $t in $sParams/param[@name="type"]
	        return fn:concat('?t = <', xs:string($t), '>')

    let $types := fn:string-join($types, ' &amp;&amp; ') 

    let $query :=  
		if (fn:count($sParams/param[@name="type"]) = 1 ) then
		let $type:= fn:concat('?t = <', xs:string($sParams/param[@name="type"]), '>')
			return
				fn:concat( '# variant : singletype query
							SELECT DISTINCT ?s ?l WHERE {
		                        ', $ops , ' .
		                        ?s <http://www.loc.gov/mads/rdf/v1#generalLabel> ?l .
		                        ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ',$type, ' . 		                       
		                    }' )
		else	
			    fn:concat( '# variant : 
							SELECT DISTINCT ?s ?l WHERE {
		                        ', $ops , ' .
		                        ?s <http://www.loc.gov/mads/rdf/v1#generalLabel> ?l .
		                        ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?t .
		                        FILTER(' , $types , ')
		                    }' )
    let $results := searchts:post-sparql-query($query)
    let $semresponse := searchts:format-sparql-response($results)
    (: let $msg := logging:debug-msg($semresponse) :)
    return $semresponse

};


(:~
:   This function formats responses from sparql queries
:   into something standard and parseable by the app.  It's like
:   the XML the ML search API returns.
:
:   @param  $results as items
:   @return semresponse as element
:)
declare function searchts:post-sparql-query($query)
    as item()*
{

    (: let $msg := logging:debug-msg($query) :)
    sem:query-results-serialize( sem:sparql($query) )

};

(:~
:   This function formats responses from sparql queries
:   into something standard and parseable by the app.  It's like
:   the XML the ML search API returns.
:
:   @param  $results as items
:   @return semresponse as element
:)
declare function searchts:format-sparql-response($results)
    as element(semresponse)
{
    (:
    <sparql xmlns="http://www.w3.org/2005/sparql-results#">
        <head>
            <variable name="s"/>
            <variable name="l"/>
        </head>
        <results>
            <result>
                <binding name="s">
                    <uri>http://id.loc.gov/authorities/subjects/sh85144088</uri>
                </binding>
                <binding name="l">
                    <literal xml:lang="en">Vocal music</literal>
                </binding>
            </result>
            <result>
                <binding name="s">
                    <uri>http://id.loc.gov/authorities/subjects/sh85144088</uri>
                </binding>
                <binding name="l">
                    <literal xml:lang="en">Vocal music</literal>
                </binding>
            </result>
        </results>
    </sparql>
    :)
    element semresponse {
            attribute total {fn:count($results/sparql:results/sparql:result)},
            
            for $r at $pos in $results/sparql:results/sparql:result
            let $uri := xs:string($r/sparql:binding[@name eq "s"]/sparql:uri)
            let $prop := xs:string($r/sparql:binding[@name eq "p"]/sparql:uri)
            let $prop2invert := xs:string($r/sparql:binding[@name eq "p2invert"]/sparql:uri)
            let $objuri := xs:string($r/sparql:binding[@name eq "o"]/sparql:uri)
            let $label := xs:string($r/sparql:binding[@name eq "l"]/sparql:literal)
            let $labellang := xs:string($r/sparql:binding[@name eq "l"]/sparql:literal/@xml:lang)
            return
                element semresult {
                    attribute index {$pos},
                    attribute docuri {format-uri($uri)},
                    attribute tsuri {$uri},
                    attribute prop {$prop},
                    attribute obj {$objuri},
                    attribute p2invert {$prop2invert},
                    attribute label {$label},
                    attribute labellang {$labellang}
                }
        }
};

(:~
:   Escape quotes 
:
:   @param  $str      is the xs:string to be formatted
:   @return xs:string   formatted
:)
declare function escape-quotes($str as xs:string) as xs:string
{
    (: fn:replace( fn:replace( $str , "'" , "\\'") , '"' , '\\"') :)
    fn:replace( $str , '"' , '\\"')

};

(:~
:   This formats the URI for the search results from a 
:   TS query.
:
:   @param  $uri      is the xs:string to be formatted
:   @return xs:string   formatted
:)
declare function format-uri($uri) as xs:string
{
    fn:concat( fn:replace( $uri, "http://id\.loc\.gov" , "") , '.xml')
};
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)