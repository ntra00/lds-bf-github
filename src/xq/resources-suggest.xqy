xquery version "1.0-ml";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
(:import module namespace json = "http://marklogic.com/json" at "/modules/lib/json.xqy";:)

import module namespace json = "http://marklogic.com/json" at "/json.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace sem                 = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace sparql = "http://www.w3.org/2005/sparql-results#";
(: OpenSearch Suggestion format: http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0 :)

(:~
:   This variable is for the query. Also for "term", the preferred param for jQuery UI Autocomplete.  Should be interchangable with "q".

	Adapted from page-suggest for the  bf editor  to find /resources/works in LDS
	Directory query wont' work for lds ; change to collection query.

:)

declare variable $q := xdmp:get-request-field("q");
declare variable $term := xdmp:get-request-field("term");
declare variable $rdftype as xs:string? :=  xdmp:get-request-field("rdftype");

(:~
:   This variable is for the scheme to search
:)

declare variable $scheme as xs:string := (xdmp:get-request-field("scheme", "all"));

(:~
:   This variable is for the format, but only xhtml supported.
:   Extensible for future development, could be an ATOM feed, JSON
:)

declare variable $format as xs:string := xdmp:get-request-field("format", "xhtml");

(:~
:   This variable is for the mimetype, but only json supported.
:   Extensible for future development, could be pure XML, text.
:)

declare variable $mimetype as xs:string := xdmp:get-request-field("mimetype", "application/x-suggestions+json"); (:text/plain:)
declare variable $offset as xs:string := xdmp:get-request-field("offset", "1");
declare variable $madsClasses as xs:string+ := ("Work","Instance","Address", "Affiliation", "Area", "Authority", "CitySection", "City", "ComplexSubject", "ComplexType", "ConferenceName", "Continent", "CorporateName", "Country", "County", "DateNameElement", "DeprecatedAuthority", "Element", "ExtraterrestrialArea", "FamilyNameElement", "FamilyName", "FullNameElement", "GenreFormElement", "GenreForm", "Geographic", "GeographicElement", "GivenNameElement", "HierarchicalGeographic", "Island", "LanguageElement", "Language", "MADSCollection", "MADSScheme", "MADSType", "MainTitleElement", "NameElement", "Name", "NameTitle", "NonSortElement", "Occupation", "Identifier", "PartNameElement", "PartNumberElement", "PersonalName", "Province", "RWO", "Region", "SimpleType", "Source", "State", "SubTitleElement", "TemporalElement", "Temporal", "TermsOfAddressNameElement", "Territory", "TitleElement", "Title", "TopicElement", "Topic", "Variant");
declare variable $resultCount as xs:string := xdmp:get-request-field("count", "10");
declare variable $callback as xs:string? := xdmp:get-request-field("callback");

let $strip-mads-ns := replace($rdftype, "(http://www\.loc\.gov/mads/rdf/v1#|madsrdf:|mads:|:)?(.+)", "$2")
  

let $rdftypequery := 
    if ($strip-mads-ns eq $madsClasses) then
       cts:element-range-query(xs:QName("idx:rdftype"), "=", $strip-mads-ns, ("collation=http://marklogic.com/collation/"))
    else
        ()
	
let $scheme:=fn:substring-after($scheme,"http://id.loc.gov") 
let $scheme:=if ( fn:substring(fn:reverse($scheme),1,1)="/") then $scheme else fn:concat($scheme, "/")
let $nodetype:=if (fn:contains($scheme,"works")) then "works" else "instances"
let $ctsquery :=    
        (: trap for authority and vocab searches that need to recurse into sub-vocabularies :)
        if (matches($scheme, "resources/works")) then            
		    cts:and-query((
						cts:or-query((
							cts:collection-query(("/authorities/bfworks/")),
							cts:collection-query(($scheme))
							)),
						 $rdftypequery))
		  else if (matches($scheme, "(authorities|vocabulary|resources)")) then    
            cts:and-query((cts:collection-query(($scheme)), $rdftypequery)) 
        (: if not recursive authorities or vocab, then take the scheme provided and do the search at that directory level only :)
        else if ($scheme ne "all" ) then
            cts:and-query((cts:directory-query(($scheme), "1"), $rdftypequery))
        (: search entire database :)
        else
            cts:and-query((cts:directory-query(("/authorities/", "/vocabulary/"), "infinity"), $rdftypequery))

(: skip stubs :)
let $ctsquery:=cts:and-not-query(
								$ctsquery,cts:collection-query("/bibframe/stubworks/")        
								)
        
let $searchLabel :=  if ($term="token") then
				  			xs:QName("idx:token")
					else if ($term="lccn") then
					  		xs:QName("idx:lccn")
					else if ($term="isbn") then
					  		xs:QName("idx:isbn")
					else
					      xs:QName("idx:nameTitle")

let $searchLabel2 :=       xs:QName("idx:title")
        
let $stop := xs:integer($offset) + xs:integer($resultCount) - 1
	
let $completions:=
if ( fn:not($term)) then
	distinct-values(
				(
				((cts:element-value-match($searchLabel2, concat(normalize-space($q), "*"),("case-insensitive", "diacritic-insensitive", "ascending", "collation=http://marklogic.com/collation/codepoint"), ($ctsquery))))
				,((cts:element-value-match($searchLabel, concat(normalize-space($q), "*"),("case-insensitive", "diacritic-insensitive", "ascending", "collation=http://marklogic.com/collation/en/S1"), ($ctsquery))))
				)
	)[xs:integer($offset) to $stop]
else 
(: was element value query but isbn has more than exact match ; qualifiers:)
				cts:search( 
		           /mets:mets,   cts:element-query($searchLabel, $q)
				   )
					 
let $search := 
    for $c in $completions    
 		let $mets :=  if (fn:not($term) ) then
			cts:search(
		           /mets:mets,                                
					cts:and-query((
							$ctsquery,
							cts:or-query((
		                          cts:element-range-query($searchLabel, "=",$c, ( "collation=http://marklogic.com/collation/en/S1") ),
								  cts:element-range-query($searchLabel2, "=",$c, ( "collation=http://marklogic.com/collation/codepoint") )
							))
		            ))                    
                  )                              
				  
				  else $c[1]
				  
    		return string($mets[1]/@OBJID)

(: term= missing or lccn or token 
	if it's a nametitle, you found the work 
:)
let $search:= 
	if (fn:contains($search[1],"works.n") and $term="lccn") then
						$search
		   				(:	let $uri:=fn:replace($search,"loc\.natlib","resources")
			   				let $uri:=concat("http://id.loc.gov/", $uri)
							let $uri:=fn:replace($uri,"\.","/")
							return  $uri
						:)
				else  if (fn:not($term) or $term="token") then
							$search
				else 
				 (: regular lccn, or isbn, found on instance, go look for work :)
				  for $t in $search
           				let $uri:=fn:replace($t,"\.","/")
		   				let $uri:=fn:replace($uri,"loc/natlib","resources")
		   				let $uri:=concat("http://id.loc.gov/", $uri)

						let $spq:=
								 <query><![CDATA[
										PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
                      					PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
											PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
											PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
											PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>								      
									       
										  select distinct ?relateduri ?agent ?title
										  
										  where { ?uri bf:instanceOf ?relateduri    .
												  ?relateduri bf:title ?titlenode .
												  ?titlenode rdfs:label ?title .
										  optional { ?relateduri bf:contribution ?c .
									     		     ?c bf:agent ?a .
									      		     ?a rdfs:label ?agent  .
							                    }   
											}	LIMIT 1
	                    
	                                    
								                ]]></query>
							let $params := 
							        map:new((
							            map:entry( "uri", sem:iri( $uri))
							            (:map:entry( "lccn",   $lccn-param):)
							        ))
							let $res:=
								sem:query-results-serialize( sem:sparql($spq, $params, ()				)
													)//sparql:results 
							return $res


 let $docs := 
    for $c in $completions    
 		let $mets := if (fn:not($term) ) then
			cts:search(
		           /mets:mets,                                
					cts:and-query((
							$ctsquery,
							cts:or-query((
		                          cts:element-range-query($searchLabel, "=",$c, ( "collation=http://marklogic.com/collation/en/S1") ),
								  cts:element-range-query($searchLabel2, "=",$c, ( "collation=http://marklogic.com/collation/codepoint") )
							))
		            ))                    
                  )       
				  else ()                       
    	return $mets[1]/mets:dmdSec[@ID="bibframe"]
 
 

let $descriptions := if ($term) then "1 result" else
    if (count($completions) gt 0 ) then
        let $freq :=
            for $t in $completions
            let $freqstring := cts:frequency($t) cast as xs:string
            return
                if ($freqstring eq "1") then
                    "1 result"
                else
                    concat($freqstring, " results")
        return
            $freq
	else
       			()
let $idnametitles:=  if ($term="lccn" and fn:not(fn:contains($search[1],"works.n"))) then
						for $t in $search/sparql:result[1]
						return fn:concat(fn:string($t//sparql:binding[@name="agent"])," ", fn:string( $t/sparql:binding[@name="title"]))
				 else if ($term) then (: nametitle lccn , isbn or or token; completions has the work :)
					for $c in $completions
							return fn:string( ($c//idx:index/idx:nameTitle|$c//idx:index//idx:aLabel|$c//mets:dmdSec[@ID="index"]//idx:title[1])[1])
				else ()

let $queryurls :=
    if (count($completions) gt 0) then
        let $qurls :=
            for $t in $search
					return if (($term="lccn"  or $term="isbn")and fn:not(fn:contains($search[1],"works.n"))) then
						fn:string($t//sparql:binding[@name="relateduri"][1]/sparql:uri)
							(: <results xmlns=\"http://www.w3.org/2005/sparql-results#\"><result><binding name=\"relateduri\"><uri>http://id.loc.gov/resources/works/c014575167</uri></binding><binding name=\"agent\"><literal>Research &amp; Education Association.</literal></binding><binding name=\"title\"><literal>The best teachers' test preparation for the ICTS, Illinois Certification Testing System : basic skills test, elementary/middle grades tests</literal></binding></result></results> :)
					else
           				let $uri:=fn:replace($t,"\.","/")
		  				 let $uri:=fn:replace($uri,"loc/natlib","resources")
		   
           		 return
					concat("http://id.loc.gov/", $uri)
				
        return
            $qurls
    else
        ()

let $queryfields :=
    if (count($completions) gt 0) then
        let $qf :=
            for $t in $docs
           	
            	return
            		fn:string($t//rdf:RDF/bf:Work/bf:title[1])
					
        return
            $qf
    else
        ()


let $ids :=
    if ($term="isbn") then
					for $t in $search/sparql:result//sparql:uri
				return fn:concat("loc.natlib.",$nodetype,".",fn:tokenize(fn:string($t),"/")[fn:last()])

		else
	if (count($completions) gt 0) then        

for $t in $search
              return 
                tokenize($t,"\.")[last()]

        
    else
        ()

let $xmldoc:=<suggestions>
				<element name="{$term}"> {$q}</element>
				
				<nametitle>{$idnametitles}</nametitle>
				
				
				<hits>{$descriptions}</hits>
				<uris>{$queryurls}</uris>
				<docids>{$ids}</docids>
			</suggestions>

	(:<suggestions>
						<completions>{for $item in $completions return <item>{$item}</item>}</completions>
						<descriptions>{for $item in $descriptions return <item>{$item}</item>}</descriptions>
						<queryurls>{for $item in $queryurls return <item>{$item}</item>}</queryurls>
						<ids>{for $item in $ids return <item>{$item}</item>}</ids>
						<queryfields>{for $item in $search return <item>{$item}</item>}</queryfields></suggestions> :)
						

let $jsondoc := if (fn:not($term)) then
    json:document(
        json:array((
            $q, json:array(($completions)), json:array(($descriptions)), json:array(($queryurls)), json:array(($ids))
        ))
    )
	else 
	 json:document(
        json:array((
            $q, json:array(($idnametitles[1]) ),  json:array(($descriptions[1])), json:array(($queryurls[1])), json:array(($ids[1]))
        ))
    )
(:let $_:=xdmp:log($mimetype):)
(:					  
   	return 
		if ($search) then		 		
			(
			        xdmp:set-response-content-type($mimetype), 		            
					xdmp:add-response-header("Access-Control-Allow-Origin", "*") ,
					$resp
					)
		else
			xdmp:set-response-code(404,"Item Not found")
			:)
return
		if ($search) then		
 		(
		if (contains($mimetype,"xml")) then
				( xdmp:set-response-content-type("application/text+xml; charset=utf-8"),
				xdmp:add-response-header("X-PrefLabel", $idnametitles[1]) ,
				xdmp:add-response-header("X-URI", $queryurls[1]) ,
					$xmldoc
				)
       	else if ($callback) then
                ( xdmp:set-response-content-type("application/javascript; charset=utf-8"), 
					xdmp:add-response-header("Access-Control-Allow-Origin", "*") ,
				 	concat(replace($callback, "[^a-zA-Z0-9_]", ""), "(", json:serialize($jsondoc), ");")
				)
        else if ($term) then
				(: only one result: isbn, lccn , token. so set the uri and label :)		
				(xdmp:set-response-content-type("application/x-suggestions+json; charset=utf-8"),
				 xdmp:add-response-header("Access-Control-Allow-Origin", "*") ,
				 xdmp:add-response-header("X-PrefLabel", $idnametitles[1]) ,
				xdmp:add-response-header("X-URI", $ids[1]) ,
				 json:serialize($jsondoc)
				 ) 					
		else
                                 
				(xdmp:set-response-content-type("application/x-suggestions+json; charset=utf-8"),
				 xdmp:add-response-header("Access-Control-Allow-Origin", "*") ,
				 json:serialize($jsondoc)
				 ) 					
		)
else
			xdmp:set-response-code(404,"Item Not found")(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)