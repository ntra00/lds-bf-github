xquery version "1.0-ml";

import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
(:import module namespace json = "http://marklogic.com/json" at "/modules/lib/json.xqy";:)
import module namespace json = "http://marklogic.com/json" at "/json.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace idx = "info:lc/xq-modules/lcindex";

(: OpenSearch Suggestion format: http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.0 :)

(:~
:   This variable is for the query. Also for "term", the preferred param for jQuery UI Autocomplete.  Should be interchangable with "q".

	Adapted from page-suggest for the  bf editor  to find /resources/works in LDS
	Directory query won't work for lds ; change to collection query.

*************

	Alert!! This may not be the right program; I think it's in xq/resources-suggest!!!

*************

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
:   This variable is for the mimetype, but only xhtml supported.
:   Extensible for future development, could be pure XML, text.
:)

declare variable $mimetype as xs:string := xdmp:get-request-field("mimetype", "application/x-suggestions+json"); (:text/plain:)
declare variable $offset as xs:string := xdmp:get-request-field("offset", "1");
declare variable $madsClasses as xs:string+ := ("Work","Instance","Address", "Affiliation", "Area", "Authority", "CitySection", "City", "ComplexSubject", "ComplexType", "ConferenceName", "Continent", "CorporateName", "Country", "County", "DateNameElement", "DeprecatedAuthority", "Element", "ExtraterrestrialArea", "FamilyNameElement", "FamilyName", "FullNameElement", "GenreFormElement", "GenreForm", "Geographic", "GeographicElement", "GivenNameElement", "HierarchicalGeographic", "Island", "LanguageElement", "Language", "MADSCollection", "MADSScheme", "MADSType", "MainTitleElement", "NameElement", "Name", "NameTitle", "NonSortElement", "Occupation", "Identifier", "PartNameElement", "PartNumberElement", "PersonalName", "Province", "RWO", "Region", "SimpleType", "Source", "State", "SubTitleElement", "TemporalElement", "Temporal", "TermsOfAddressNameElement", "Territory", "TitleElement", "Title", "TopicElement", "Topic", "Variant");
declare variable $resultCount as xs:string := xdmp:get-request-field("count", "10");
declare variable $callback as xs:string? := xdmp:get-request-field("callback");


let $strip-mads-ns := replace($rdftype, "(http://www\.loc\.gov/mads/rdf/v1#|madsrdf:|mads:|:)?(.+)", "$2")

let $_:=xdmp:log("BFDB error: in the wrong suggest program.", "info")
let $_:=xdmp:log(concat("BFDB error: strip-mads-ns: ",$strip-mads-ns),"info")
let $_:=xdmp:log(concat("BFDB error: scheme: ",$scheme),"info")
let $_:=xdmp:log(concat("BFDB error: $format: ",$format),"info")
let $_:=xdmp:log(concat("BFDB error: $q: ",$mimetype),"info")
let $_:=xdmp:log(concat("BFDB error: $callback: ",$q),"info")
let $_:=xdmp:log(concat("BFDB error: $term: ",$term),"info")
let $_:=xdmp:log(concat("BFDB error: $rdftype: ",$rdftype),"info")

let $_:=for  $a in xdmp:get-request-header-names()
	return xdmp:log(concat("BFDB error: header ",$a, ": ", xdmp:get-request-header($a) ),"info")

let $rdftypequery := 
    if ($strip-mads-ns eq $madsClasses) then
       cts:element-range-query(xs:QName("idx:rdftype"), "=", $strip-mads-ns, ("collation=http://marklogic.com/collation/"))
    else
        ()
let $scheme:=fn:substring-after($scheme,"http://id.loc.gov") 
let $scheme:=if ( fn:substring(fn:reverse($scheme),1,1)="/") then $scheme else fn:concat($scheme, "/")
let $nodetype:=if (fn:contains($scheme,"works")) then "works" else "instances"
let $ctsquery :=
    
         if (matches($scheme, "resources/works")) then            
		    cts:and-query((
						cts:or-query((
							cts:collection-query(("/authorities/bfworks/")),
							cts:collection-query(($scheme))
							)),
						 $rdftypequery))
	else
        (: trap for authority and vocab searches that need to recurse into sub-vocabularies :)
        if (matches($scheme, "(authorities|vocabulary|resources)")) then            
            cts:and-query((cts:collection-query(($scheme)), $rdftypequery)) 
        (: if not recursive authorities or vocab, then take the scheme provided and do the search at that directory level only :)
        else if ($scheme ne "all" ) then
            cts:and-query((cts:directory-query(($scheme), "1"), $rdftypequery))
        (: search entire database :)
        else
            cts:and-query((cts:directory-query(("/authorities/", "/vocabulary/"), "infinity"), $rdftypequery))
        
        
let $searchLabel :=        xs:QName("idx:nameTitle")
let $searchLabel2 :=       xs:QName("idx:title")
let $stop := xs:integer($offset) + xs:integer($resultCount) - 1


let $completions := 
if ( fn:not($term)) then
	distinct-values(
				(
				((cts:element-value-match($searchLabel2, concat(normalize-space($q), "*"),("case-insensitive", "diacritic-insensitive", "ascending", "collation=http://marklogic.com/collation/codepoint"), ($ctsquery))))
				,((cts:element-value-match($searchLabel, concat(normalize-space($q), "*"),("case-insensitive", "diacritic-insensitive", "ascending", "collation=http://marklogic.com/collation/en/S1"), ($ctsquery))))
				)
	)[xs:integer($offset) to $stop]
else 
(cts:element-value-match($searchLabel, concat(normalize-space($q), "*"),
					 ("case-insensitive", "punctuation-insensitive", "diacritic-insensitive", "ascending", "collation=http://marklogic.com/collation/en/S1"), ($ctsquery))
					 )[xs:integer($offset) to $stop]


let $search := 
    for $c in $completions
    
    let $mets := cts:search(
            /mets:mets, 
            cts:and-query(
                (cts:element-range-query($searchLabel, "=", $c, ( "collation=http://marklogic.com/collation/en/S1")), $ctsquery)
                )
            )
    return string($mets[1]/@OBJID)
let $descriptions :=
    if (count($completions) gt 0) then
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
let $queryurls :=
    if (count($completions) gt 0) then
        let $qurls :=
            for $t in $search
           
            return
                concat("http://", $cfg:DISPLAY-SUBDOMAIN, "/", $t)
        return
            $qurls
    else
        ()
		let $query:=concat(" you should not use this program",$q)
let $jsondoc := 
    json:document(
        json:array((
            $query, json:array(($completions)), json:array(($descriptions)), json:array(($queryurls))
        ))
    )
return 
	
        if ($callback) then
                (xdmp:set-response-content-type("application/javascript; charset=utf-8"), concat(replace($callback, "[^a-zA-Z0-9_]", ""), "(", json:serialize($jsondoc), ");"))
        else
                 (:(xdmp:set-response-content-type("application/json; charset=utf-8"), json:serialize($jsondoc)) :)
                
				(xdmp:set-response-content-type("application/x-suggestions+json; charset=utf-8"), json:serialize($jsondoc)) 
				
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)