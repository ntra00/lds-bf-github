xquery version "1.0-ml";

(:
:   Module Name: Search ML
:
:   Module Version: 1.0
:
:   Date: 2010 Dec 13
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp, searchapi (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:     Application specific functions
:       and variables for Searching the ML database.
:
:)

(:~
:   Application specific functions
:   and variables for Searching the ML database.
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since December 13, 2010
:   @version 1.0
:)

module namespace searchml = 'info:lc/id-modules/searchml#';

(: Imported modules :)
import module namespace search              = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
(:import module namespace constants           = "info:lc/id-modules/constants#" at "../constants.xqy";
import module namespace format              = "info:lc/id-modules/format#" at "module.Format.xqy";:)
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
(: Namespaces :)
declare namespace rdf       = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace map       = "http://marklogic.com/xdmp/map";
declare namespace cts       = "http://marklogic.com/cts";
declare namespace index     = "info:lc/xq-modules/lcindex";
declare namespace mxe		= "http://www.loc.gov/mxe";


(: Variables :)
(:
http://marklogic.com/collation/en/S3
collation for authoritative and variant label and uri value index
:)
(:~
:   This variable is for MarkLogic Constraint Search API options.
:)
declare variable $constraint-search-options := 
    <options xmlns="http://marklogic.com/appservices/search">
        <debug>{ xs:string($cfg:DEBUG) }</debug>
        <!-- <constraint name="relation">
            <range type="xs:string" collation="http://marklogic.com/collation/codepoint" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="relation"/>
            </range>
        </constraint> -->
        <constraint name="aLabel">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="aLabel"/>
            </value>
        </constraint>
        <constraint name="vLabel">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="vLabel"/>
            </value>
        </constraint>
        <constraint name="lccn">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="lccn"/>
            </value>
        </constraint>
        <!-- Note should the "code" ever be different from the "token," this will have to be amended. -->
        <constraint name="token">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="token"/>
            </value>
        </constraint>
        <constraint name="code">
            <custom facet="false">
                <parse apply="search-code" ns="info:lc/id-modules/searchml#" at="/models/module.SearchML.xqy" />
            </custom>
        </constraint>
        <constraint name="scheme">
            <range type="xs:string" collation="http://marklogic.com/collation/" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="scheme"/>
                <!--
                
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                
                -->
            </range>
        </constraint>
        <constraint name="cs">
            <range type="xs:string" collation="http://marklogic.com/collation/" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="scheme"/>
                <!--
                
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                
                -->
            </range>
        </constraint>
        <constraint name="memberOf">
            <range type="xs:string" collation="http://marklogic.com/collation/codepoint" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="memberOfURI"/>
                <!--
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                -->
            </range>
        </constraint>
        <constraint name="usePatternCollection">
            <range type="xs:string" collation="http://marklogic.com/collation/codepoint" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="usePatternCollection"/>
                <!--
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                -->
            </range>
        </constraint>
        <constraint name="contentSource">
            <range type="xs:string" collation="http://marklogic.com/collation/codepoint" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="contentSource"/>
                <!--
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                -->
            </range>
        </constraint>
        <constraint name="rdftype">
            <range type="xs:string" collation="http://marklogic.com/collation/" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="rdftype"/>
                <!--
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                -->
            </range>
        </constraint>
        <constraint name="cdate">
            <range type="xs:date" facet="false">
                <!--
                <bucket ge="2010-01-01" lt="2020-01-01" name="2010s">2010s</bucket>
                <bucket lt="2010-01-01" ge="2000-01-01" name="2000s">2000s</bucket>
                <bucket lt="2000-01-01" ge="1990-01-01" name="1990s">1990s</bucket>
                <bucket lt="1990-01-01" ge="1980-01-01" name="1980s">1980s</bucket>
                <bucket lt="1980-01-01" ge="1970-01-01" name="1970s">1970s</bucket>
                <bucket lt="1970-01-01" ge="1960-01-01" name="1960s">1960s</bucket>
                <bucket lt="1960-01-01" ge="1950-01-01" name="1950s">1950s</bucket>
                <bucket lt="1950-01-01" name="1940s">1940s</bucket>
                <bucket ge="2020-01-01" name="unknown">unknown</bucket>
                <facet-option>limit=10</facet-option>
                -->
                <element ns="info:lc/xq-modules/lcindex" name="cDate"/>
            </range>
        </constraint>
        <constraint name="mdate">
            <range type="xs:date" facet="false">
                <!--
                <bucket ge="2010-01-01" lt="2020-01-01" name="2010s">2010s</bucket>
                <bucket lt="2010-01-01" ge="2000-01-01" name="2000s">2000s</bucket>
                <bucket lt="2000-01-01" ge="1990-01-01" name="1990s">1990s</bucket>
                <bucket lt="1990-01-01" ge="1980-01-01" name="1980s">1980s</bucket>
                <bucket lt="1980-01-01" ge="1970-01-01" name="1970s">1970s</bucket>
                <bucket lt="1970-01-01" ge="1960-01-01" name="1960s">1960s</bucket>
                <bucket lt="1960-01-01" ge="1950-01-01" name="1950s">1950s</bucket>
                <bucket lt="1950-01-01" name="1940s">1940s</bucket>
                <bucket ge="2020-01-01" name="unknown">unknown</bucket>
                <facet-option>limit=10</facet-option>
                -->
                <element ns="info:lc/xq-modules/lcindex" name="mDate"/>
            </range>
        </constraint>
<!--        <grammar>
                <starter strength="30" apply="prefix" element="cts:not-query">NOT</starter>  
        </grammar> -->   
        <term apply="search-refinement" ns="info:lc/id-modules/searchml#" at="/models/module.SearchML.xqy">
            <empty apply="all-results"/>
        </term>
    </options>;


(:~
:   This variable is for MarkLogic Constraint Search API options.
:)
declare variable $constraint-search-options-resources := 
    <options xmlns="http://marklogic.com/appservices/search">
        <debug>{ xs:string($cfg:DEBUG) }</debug>
        <constraint name="aLabel">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="aLabel"/>
            </value>
        </constraint>
        <constraint name="uTitle">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="uTitle"/>
            </value>
        </constraint>
        <constraint name="mTitle">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="mTitle"/>
            </value>
        </constraint>
        <!--<constraint name="vTitle">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="vTitle"/>
            </value>
        </constraint>
        <constraint name="creator">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="creator"/>
            </value>
        </constraint>
		
		 <constraint name="contributor">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="contributor"/>
            </value>
        </constraint>
		<constraint name="process">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="process"/>
            </value>
        </constraint>-->
        <!-- Note should the "code" ever be different from the "token," this will have to be amended. -->
        <constraint name="token">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="token"/>
            </value>
        </constraint>
        <constraint name="cs">
            <range type="xs:string" collation="http://marklogic.com/collation/" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="scheme"/>
                <!--
                
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                
                -->
            </range>
        </constraint>
        <constraint name="scheme">
            <range type="xs:string" collation="http://marklogic.com/collation/" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="scheme"/>
                <!--
                
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                
                -->
            </range>
        </constraint>
        <constraint name="memberOf">
            <range type="xs:string" collation="http://marklogic.com/collation/codepoint" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="memberOfURI"/>
                <!--
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                -->
            </range>
        </constraint>
        <constraint name="derivedFrom">
            <range type="xs:string" collation="http://marklogic.com/collation/codepoint" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="derivedFrom"/>
                <!--
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                -->
            </range>
        </constraint>
        <constraint name="rdftype">
            <range type="xs:string" collation="http://marklogic.com/collation/" facet="false">
                <element ns="info:lc/xq-modules/lcindex" name="rdftype"/>
                <!--
                <facet-option>limit=30</facet-option>
                <facet-option>frequency-order</facet-option>
                <facet-option>descending</facet-option>
                -->
            </range>
        </constraint>
        <term apply="search-refinement-resources" ns="info:lc/id-modules/searchml#" at="/models/module.SearchML.xqy">
            <empty apply="all-results"/>
        </term>
    </options>;
        
(:~
:   This variable is for MarkLogic Constraint Search API options.
:)
declare variable $label-search-options := 
    (<options xmlns="http://marklogic.com/appservices/search">
        <debug>{ xs:string($cfg:DEBUG) }</debug>
        <constraint name="aLabel">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="aLabel"/>
            </value>
        </constraint>
        <constraint name="vLabel">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="vLabel"/>
            </value>
        </constraint>
        <term apply="search-refinement-label" ns="info:lc/id-modules/searchml#" at="/models/module.SearchML.xqy">
            <empty apply="all-results"/>
        </term>
    </options>);
    
(:~
:   This variable is for MarkLogic Constraint Search API options.
:)
declare variable $label-search-options-resources := 
    (<options xmlns="http://marklogic.com/appservices/search">
        <debug>{ xs:string($cfg:DEBUG) }</debug>
        <constraint name="aLabel">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="aLabel"/>
            </value>
        </constraint>
        <constraint name="uTitle">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="uTitle"/>
            </value>
        </constraint>
        <constraint name="vTitle">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="vTitle"/>
            </value>
        </constraint>
        <constraint name="creator">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="creator"/>
            </value>
        </constraint>
        <term apply="search-label-refinement-resources" ns="info:lc/id-modules/searchml#" at="/models/module.SearchML.xqy">
            <empty apply="all-results"/>
        </term>
    </options>);
    
(:~
:   This variable is for MarkLogic General Search API options.
:)
declare variable $general-search-options := 
    (<options xmlns="http://marklogic.com/appservices/search">
        <debug>{ xs:string($cfg:DEBUG) }</debug>
        <term apply="search-refinement" ns="info:lc/id-modules/searchml#" at="/models/module.SearchML.xqy">
            <empty apply="all-results"/>
        </term>
    </options>);


(:~
:   Search code - This searches for a code in the system. 
:   It will be most beneficial to LCC, because it will
:   try to determine within what range a class number falls
:   if there is not equivalent match.
:   Thanks to http://blog.davidcassel.net/2011/07/a-custom-facet-for-the-search-api/
:
:   @param  $constrain          is the name of the constraint
:   @param  $query             is the cts query
:   @return cts:query as schema-element
:)
declare function searchml:search-code(
    $constraint as xs:string,
    $query as schema-element(cts:query)
    )
    as schema-element(cts:query)
{
    let $txt := xs:string($query//cts:text[1]) 
    let $q := 
        <cts:or-query qtextconst="{ $txt }">
            { 
                (
                    cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "code"), $txt, ("exact"), 16),
                    cts:and-query((
                        (:
                        On a small dataset, this will work OK.  But, since weighting is ignored, the scheme=classification 
                        constraint overwhelms the query when run against a large dataset.
                        cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "codeStart"), "<", $txt, 'collation=http://marklogic.com/collation/codepoint', 15),
                        cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "codeEnd"), ">", $txt, 'collation=http://marklogic.com/collation/codepoint', 15)
                        :)
                        (: As an alternative, trying the below, though it is costly.  Like element-range-query, weight is ignored
                        so expectations are low. :)
                        cts:field-range-query("sCode", "<", $txt, 'collation=http://marklogic.com/collation/codepoint', 15),
                        cts:field-range-query("eCode", ">", $txt, 'collation=http://marklogic.com/collation/codepoint', 15)
                    ))
                )
            }
        </cts:or-query>
    return $q
};
(:~
:   Get nametitle for a work, adapted from id-main label search
:
:   @param  $scheme         is the scheme requested
:   @param  $label          is the label to be found
:   @return element         as atom:feed element
:)
declare function searchml:get-label(   
    $label as xs:string,
  $serialize as xs:string
    )
{

    let $schemeURI := "/resources/works/"
    
	let $label:=fn:normalize-space($label)

    let $directory := 
      
            "/lscoll/lcdb/works/"
      
            
    
 (: Codepoint search for a matching idx:nameTitle :)
    let $uri := 
        
            	label-search($label , $directory , xs:QName("index:nameTitle"))          	
    let $response := 
        if ($uri[1] ne "" and $serialize ne "") then
            (:redirect:found( fn:concat( $uri[1] , $serialize) , $uri[1] ):)
fn:concat( $uri[1] , $serialize)
        else if ($uri[1] ne "") then
            (:redirect:found( $uri[1] ):)
			 $uri[1]
        else
      (:      redirect:four0four():)
$label
    return fn:concat("No matching term found - authoritative, variant, or deprecated - for " , $label)


};

(:~
:   Label search
:
:   @param  $scheme         is the scheme requested
:   @param  $label          is the label to be found
:   @return element         as atom:feed element
:)
declare function searchml:label-search(
    $label as xs:string,
    $directory as xs:string,
    $element as xs:QName
    ) as xs:string*
{
    cts:uris(
        $directory,
        (),        
            cts:element-range-query(
                $element, 
                "=",
                $label,
                ("collation=http://marklogic.com/collation/codepoint")
            )
            
    )
};

(:~
:   Basic, general search. 
:
:   @param  $q                  is search query
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
declare function searchml:search-general(
    $q as xs:string,
    $search-start as xs:integer,
    $search-count as xs:integer
    )
    as element(search:response)
{
    (: if ( fn:matches($q, "aLabel:|vLabel:|rdftype:|cDate:|mDate:|relation:|lccn:|cs:|memberOf:|contentSource:") ) then
        search:search($q,$constraint-search-options,$search-start,$search-count)
    else
        search:search($q,$general-search-options,$search-start,$search-count)
    :)
    let $constraint-options := 
        if ( fn:not(fn:contains($q , "cs:http://id.loc.gov/resources")) ) then
            $constraint-search-options
        else
            $constraint-search-options-resources
    
    let $constraint-options :=  
        <options xmlns="http://marklogic.com/appservices/search">
            {  <additional-query>{
                    cts:not-query(
                        cts:directory-query("/triplestore/", "infinity")
                    )
                }</additional-query>,
                <additional-query>{
                    cts:not-query(
                        cts:collection-query("/bibframe/mergedoutWorks")
                    )
                }</additional-query>,
				<additional-query>{
                    cts:not-query(
                        cts:collection-query("/bibframe-process/records/")
                    )
                }</additional-query>,
    			if ( fn:not(fn:contains($q , "cs:http://id.loc.gov/resources/annotations")) ) then
 					<additional-query>{
                        cts:not-query(
                            cts:collection-query("/resources/annotations")
                        )
                    }</additional-query>
				else
                    (),
                if ( fn:not(fn:contains($q , "cs:http://id.loc.gov/authorities/classification")) ) then
                    <additional-query>{
                        cts:not-query(
                            cts:directory-query("/authorities/classification/")
                        )
                    }</additional-query>
                else
                    (),
                if ( fn:not(fn:contains($q , "cs:http://id.loc.gov/resources")) ) then
                    <additional-query>{
                        cts:not-query(
                            cts:directory-query("/resources/", "infinity")
                        )
                    }</additional-query>
                else
                    let $qStart := fn:substring-before($q, "cs:http://id.loc.gov/resources")
                    let $directory := fn:substring-after($q, "cs:http://id.loc.gov/resources")
                    let $qEnd := 
                        if ( fn:contains($directory, " ") ) then
                            fn:substring-after($directory, " ")
                        else
                            ""
                    let $directory := 
                        if ( fn:contains($directory, " ") ) then
                            fn:substring-before($directory, " ")
                        else
                            $directory
                    
					let $directory := fn:concat("/resources" , $directory , "/")
					
					
                    return 
                        (<additional-query>{
                           cts:directory-query($directory, "infinity") 						   
                        }</additional-query>
					(: 	,
                 		<additional-query>{
                            cts:not-query( cts:collection-query("/bibframe/transformedTitles"))
                        }</additional-query>					:)
                        )
                    
            }
            {$constraint-options/child::node()}
        </options>
        
    let $q := 
        if ( fn:not(fn:contains($q , "cs:http://id.loc.gov/resources")) ) then
            $q
        else
            let $qStart := fn:substring-before($q, "cs:http://id.loc.gov/resources")
            let $directory := fn:substring-after($q, "cs:http://id.loc.gov/resources")
            let $qEnd := 
                if ( fn:contains($directory, " ") ) then
                    fn:concat(" ", fn:substring-after($directory, " "))
                else
                    ""
            return fn:concat($qStart, $qEnd)
    
	return search:search($q,$constraint-options,$search-start,$search-count)
};

(:~
:   Feed search 
:
:   @param  $directory          is the directory to search
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
declare function searchml:search-feed(
    $directory as xs:string,
    $search-start as xs:integer,
    $search-count as xs:integer
    )
    as element(search:response)
{
    let $search-options :=       
        <options xmlns="http://marklogic.com/appservices/search">         
            <additional-query>{cts:directory-query($directory)}</additional-query>
            <sort-order type="xs:date" direction="descending">
                <search:element ns="info:lc/xq-modules/lcindex" name="mDate"/>
            </sort-order>
            <sort-order type="xs:date" direction="descending">
                <search:element ns="info:lc/xq-modules/lcindex" name="cDate"/>
            </sort-order>
			<transform-results apply="empty-snippet" />
			<return-metrics>{fn:false()}</return-metrics>
        </options>
    return search:search("",$search-options,$search-start,$search-count)
};
(:
feed based on director (names, subjects etc
field, (040a)
value (CMalG)

:)
declare function searchml:search-advanced-feed(
    $directory as xs:string,
    $field as xs:string,
    $value as xs:string,
    $search-start as xs:integer,
    $search-count as xs:integer
    )
    as element(search:response)
{ 
let $opts:=("case-insensitive","diacritic-insensitive",    "punctuation-insensitive",   "wildcarded")
    
    let $search-options :=
    if (fn:contains($field,"subfield")) then (:mxe:d100_subfield_a means search this subfield, can use element-value-query :) 
        <options xmlns="http://marklogic.com/appservices/search">         
             <additional-query>{cts:directory-query($directory)}</additional-query>
             <additional-query>{cts:element-value-query( xs:QName( $field),$value,$opts)}</additional-query>
            <sort-order type="xs:date" direction="descending">
                <element ns="info:lc/xq-modules/lcindex" name="mDate"/>
            </sort-order>
            <sort-order type="xs:date" direction="descending">
                <element ns="info:lc/xq-modules/lcindex" name="cDate"/>
            </sort-order>
        </options>
        
        else (:mxe:datafield_100 means search all subfields, can't use element-value-query :)
        <options xmlns="http://marklogic.com/appservices/search">         
             <additional-query>{cts:directory-query($directory)}</additional-query>
             <additional-query>{cts:element-query( xs:QName( $field),$value)}</additional-query>
            <sort-order type="xs:date" direction="descending">
                <element ns="info:lc/xq-modules/lcindex" name="mDate"/>
            </sort-order>
            <sort-order type="xs:date" direction="descending">
                <element ns="info:lc/xq-modules/lcindex" name="cDate"/>
            </sort-order>
        </options>
        (:let $x:=xdmp:log( $search-options,"info"):)
    return
     search:search("",$search-options,$search-start,$search-count)

};

(:~
:   Wiggly label search. 
:
:   @param  $q                  is search query
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
declare function searchml:search-label-wiggly(
    $q as xs:string,
    $directory as xs:string
    )
    as xs:string*
{

    let $constraint-options := 
        if ( fn:contains($directory , "/resources") ) then
            $label-search-options-resources
        else
            $label-search-options
            
    let $search-options := 
        <options xmlns="http://marklogic.com/appservices/search">
            <additional-query>
                {
                    cts:and-query((
                        cts:directory-query(
                            ($directory),
                            "infinity"
                        ),
                    cts:not-query(
                        cts:directory-query(
                            "/authorities/classification/"
                        )
                    ))
            )
                }
            </additional-query>  
            {$constraint-options/child::node()}
        </options>
    let $results := search:search($q,$search-options)
    let $uris := 
        for $r in $results//search:result
        return xs:string($r/@uri)
        
    return $uris
        
};


(:~
:   Search refinement - This refines what fields are searched 
:   and their respective weights in order to produce better/more 
:   accurate search results
:
:   @param  $directory          is the directory to search
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
declare function searchml:search-refinement(
    $term-map as map:map,
    $term-options as element()?
    )
    as schema-element(cts:query)
{
    let $token := searchml:gt($term-map)
    let $tokenFirstLetterCap := fn:concat( fn:upper-case( fn:substring(xs:string($token), 1, 1) ), fn:substring(xs:string($token), 2) )
    let $options := 
        for $opt in $term-options/search:term-option
        where fn:not(fn:starts-with($opt, "lang="))
        return <cts:option>{$opt/fn:string()}</cts:option>
    
    return
        (
            <cts:or-query qtextconst="{ $token }">
            
                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), $tokenFirstLetterCap, ("exact"), 16),
                        cts:or-query((
                            cts:and-query((
                                cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "memberOfURI"), "=", "http://id.loc.gov/authorities/subjects/collection_LCSH_General", 'collation=http://marklogic.com/collation/codepoint'),
                                cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "memberOfURI"), "=", "http://id.loc.gov/authorities/subjects/collection_LCSHAuthorizedHeadings", 'collation=http://marklogic.com/collation/codepoint')
                            )),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "scheme"), "=", "http://id.loc.gov/authorities/names", 'collation=http://marklogic.com/collation/')
                        ))
                    )),  
                    cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), $tokenFirstLetterCap, ("exact"), 12)
                    
                    )
                }
                
                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 15),
                        cts:or-query((
                            cts:and-query((
                                cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "memberOfURI"), "=", "http://id.loc.gov/authorities/subjects/collection_LCSH_General", 'collation=http://marklogic.com/collation/codepoint'),
                                cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "memberOfURI"), "=", "http://id.loc.gov/authorities/subjects/collection_LCSHAuthorizedHeadings", 'collation=http://marklogic.com/collation/codepoint')
                            )),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "scheme"), "=", "http://id.loc.gov/authorities/names", 'collation=http://marklogic.com/collation/')
                        ))
                    )),  
                    cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 11)
                    
                    )
                }

                { 
                    (
                    
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), $tokenFirstLetterCap, ("exact"), 12),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    )),  
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), $tokenFirstLetterCap, ("exact"), 8),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    ))
                    
                    )
                }
                
                { 
                    (
                    
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 10),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    )),  
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 7),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    ))
                    
                    )
                }
                
                
                { 
                    (
                    
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 8),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Title", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "CorporateName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ConferenceName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GenreForm", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Medium", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Language", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Temporal", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ClassNumber", 'collation=http://marklogic.com/collation/')
                        ))
                    )),
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 6),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/') 
                        ))
                    ))
                    
                    )
                }
                { 
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 5),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "NameTitle", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ComplexSubject", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Schedule", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GuideTable", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Table", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                
                { 
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 4),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                { 
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 2),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Title", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "CorporateName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ConferenceName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GenreForm", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Medium", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Language", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Temporal", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ClassNumber", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                {
                    cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "token"), xs:string($token), ("exact"), 0)
                }
                { 
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), -1),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "NameTitle", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ComplexSubject", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Schedule", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GuideTable", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Table", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                { 
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), $options, -4),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "CorporateName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ConferenceName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Title", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GenreForm", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Medium", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Language", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Temporal", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ClassNumber", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                { 
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), $options, -6),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "NameTitle", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ComplexSubject", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Schedule", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GuideTable", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Table", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                { 
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), $options, -8),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "CorporateName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ConferenceName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Title", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GenreForm", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Medium", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Language", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Temporal", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ClassNumber", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                { 
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), $options, -10),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "NameTitle", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ComplexSubject", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Schedule", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GuideTable", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Table", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }

            </cts:or-query>
            ,
             searchml:advance($term-map)
        ) 
};

(:~
:   Search refinement for Label search - 
:   This performs a search for an exact matching label,
:   case-insensitive, etc.  This is different from the above
:   in that it uses exclusively element-value-query
:
:   @param  $directory          is the directory to search
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
declare function searchml:search-refinement-label(
    $term-map as map:map,
    $term-options as element()?
    )
    as schema-element(cts:query)
{
    let $token := searchml:gt($term-map)
    let $tokenFirstLetterCap := fn:concat( fn:upper-case( fn:substring(xs:string($token), 1, 1) ), fn:substring(xs:string($token), 2) )
    let $options := 
        for $opt in $term-options/search:term-option
        where fn:not(fn:starts-with($opt, "lang="))
        return <cts:option>{$opt/fn:string()}</cts:option>
    
    return
        (
            <cts:or-query qtextconst="{ $token }">
            
                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), $tokenFirstLetterCap, ("exact"), 16),
                        cts:or-query((
                            cts:and-query((
                                cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "memberOfURI"), "=", "http://id.loc.gov/authorities/subjects/collection_LCSH_General", 'collation=http://marklogic.com/collation/codepoint'),
                                cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "memberOfURI"), "=", "http://id.loc.gov/authorities/subjects/collection_LCSHAuthorizedHeadings", 'collation=http://marklogic.com/collation/codepoint')
                            )),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "scheme"), "=", "http://id.loc.gov/authorities/names", 'collation=http://marklogic.com/collation/')
                        ))
                    )),  
                    cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), $tokenFirstLetterCap, ("exact"), 12)
                    
                    )
                }
                
                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 15),
                        cts:or-query((
                            cts:and-query((
                                cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "memberOfURI"), "=", "http://id.loc.gov/authorities/subjects/collection_LCSH_General", 'collation=http://marklogic.com/collation/codepoint'),
                                cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "memberOfURI"), "=", "http://id.loc.gov/authorities/subjects/collection_LCSHAuthorizedHeadings", 'collation=http://marklogic.com/collation/codepoint')
                            )),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "scheme"), "=", "http://id.loc.gov/authorities/names", 'collation=http://marklogic.com/collation/')
                        ))
                    )),  
                    cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 11)
                    
                    )
                }

                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), $tokenFirstLetterCap, ("exact"), 12),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), $tokenFirstLetterCap, ("exact"), 8),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    ))
                    
                    )
                }
                
                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 10),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 7),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    ))
                    
                    )
                }
                
                
                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 8),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Title", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "CorporateName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ConferenceName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GenreForm", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Medium", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Temporal", 'collation=http://marklogic.com/collation/')
                        ))
                    )),
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 6),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    ))
                    
                    )
                }
                { 
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 5),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "NameTitle", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ComplexSubject", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                
                { 
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 4),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "PersonalName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Topic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Geographic", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Authority", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                { 
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 2),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "CorporateName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ConferenceName", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "GenreForm", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Medium", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "Temporal", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }
                { 
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vLabel"), xs:string($token), ("case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), -1),
                        cts:or-query((
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "NameTitle", 'collation=http://marklogic.com/collation/'),
                            cts:element-range-query(fn:QName("info:lc/xq-modules/lcindex", "rdftype"), "=", "ComplexSubject", 'collation=http://marklogic.com/collation/')
                        ))
                    )) 
                }

            </cts:or-query>
            ,
             searchml:advance($term-map)
        ) 
};




(:~
:   Search refinement for *RESOURCES* - This refines which
:   fields are searched and their respective weights in 
:   order to produce better/more 
:   accurate search results
:
:   @param  $directory          is the directory to search
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
declare function searchml:search-label-refinement-resources(
    $term-map as map:map,
    $term-options as element()?
    )
    as schema-element(cts:query)
{
    let $token := searchml:gt($term-map)
    let $options := 
        for $opt in $term-options/search:term-option
        where fn:not(fn:starts-with($opt, "lang="))
        return <cts:option>{$opt/fn:string()}</cts:option>
    
    return
        (
            <cts:or-query qtextconst="{ $token }">
            
                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("exact"), 16),
                        cts:directory-query("/resources/", "infinity")
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 15),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("case-insensitive", "punctuation-insensitive", "diacritic-sensitive"), 14),
                        cts:directory-query("/resources/", "infinity")
                    ))
                    
                    )
                }
 
            </cts:or-query>
            ,
             searchml:advance($term-map)
        ) 
};


(:~
:   Search refinement for *RESOURCES* - This refines which
:   fields are searched and their respective weights in 
:   order to produce better/more 
:   accurate search results
:
:   @param  $directory          is the directory to search
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
declare function searchml:search-refinement-resources(
    $term-map as map:map,
    $term-options as element()?
    )
    as schema-element(cts:query)
{
    let $token := searchml:gt($term-map)
    let $options := 
        for $opt in $term-options/search:term-option
        where fn:not(fn:starts-with($opt, "lang="))
        return <cts:option>{$opt/fn:string()}</cts:option>
    
    return
        (
            <cts:or-query qtextconst="{ $token }">
            
                { 
                    (
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("exact"), 16),
                        cts:directory-query("/resources/", "infinity")
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 15),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), ("case-insensitive", "punctuation-insensitive", "diacritic-sensitive"), 14),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "aLabel"), xs:string($token), $options, 12),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "uTitle"), xs:string($token), ("exact"), 15),
                        cts:directory-query("/resources/", "infinity")
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "uTitle"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 14),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "uTitle"), xs:string($token), ("case-insensitive", "punctuation-insensitive", "diacritic-sensitive"), 13),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "uTitle"), xs:string($token), $options, 11),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "mTitle"), xs:string($token), ("exact"), 14),
                        cts:directory-query("/resources/", "infinity")
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "mTitle"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 13),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "mTitle"), xs:string($token), ("case-insensitive", "punctuation-insensitive", "diacritic-sensitive"), 12),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "mTitle"), xs:string($token), $options, 11),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "creator"), xs:string($token), ("exact"), 14),
                        cts:directory-query("/resources/", "infinity")
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "creator"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 14),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "creator"), xs:string($token), ("case-insensitive", "punctuation-insensitive", "diacritic-sensitive"), 13),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "creator"), xs:string($token), $options, 10),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vTitle"), xs:string($token), ("exact"), 13),
                        cts:directory-query("/resources/", "infinity")
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vTitle"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 12),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "vTitle"), xs:string($token), ("case-insensitive", "punctuation-insensitive", "diacritic-sensitive"), 11),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "vTitle"), xs:string($token), $options, 10),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "contributor"), xs:string($token), ("exact"), 12),
                        cts:directory-query("/resources/", "infinity")
                    )),  
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "contributor"), xs:string($token), ("unstemmed", "case-insensitive", "punctuation-sensitive", "diacritic-sensitive"), 11),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "contributor"), xs:string($token), ("case-insensitive", "punctuation-insensitive", "diacritic-sensitive"), 10),
                        cts:directory-query("/resources/", "infinity")
                    )),
                    cts:and-query((
                        cts:element-word-query(fn:QName("info:lc/xq-modules/lcindex", "contributor"), xs:string($token), $options, 9),
                        cts:directory-query("/resources/", "infinity")
                    ))
                    
                    )
                }
 
            </cts:or-query>
            ,
             searchml:advance($term-map)
        ) 
};







(:~ Get the current token :)
(: This was lifted from /opt/MarkLogic/Modules/MarkLogic/appservices/search/search-impl.xqy :)
declare function searchml:gt($ps as map:map) as element() {
    let $toknum := map:get($ps, "toknum")
    let $toks := map:get($ps, "toks")
    return $toks[fn:position() eq $toknum]
};

(:~ Move to the next token :)
(: As with searchml:gt, this was lifted from /opt/MarkLogic/Modules/MarkLogic/appservices/search/search-impl.xqy :)
declare function searchml:advance($ps as map:map) as empty-sequence() {
    let $toknum := map:get($ps, "toknum")
    let $toks := map:get($ps, "toks")
    let $newpos := if ($toknum+1 ge fn:count($toks) (: be paranoid :) ) then fn:count($toks) else $toknum+1
    return map:put($ps, "toknum", $newpos)
};

(:~
:   Re-order Search API results. 
:   This should be monitored, as each search will open the document twice when this is called.
:   Once to reorder the results and then again whenever the search api response is parsed. 
:
:   @param  $directory          is the directory to search
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
(:
declare function searchml:reorder-based-on-variants(
    $results as element(search:response)
    )
    as element(search:response)
{

    let $start-pos := xs:integer($results/@start)

    let $ordered-results := 
        element search:response {
            $results/attribute::*,
            
            for $r at $pos in $results/search:result
            let $dburi := $r/@uri
            let $i := format:get-index($dburi)
            let $weight := fn:count($i/index:vLabel)
            order by xs:integer($weight) descending, xs:integer($r/@score) descending 
            return 
                element search:result {
                    $r/attribute::*[fn:local-name() ne 'index'],                    
                    attribute weight {$weight},
                    $r/child::node()
                } 
        }

    let $ordered-results := 
        element search:response {
            $results/attribute::*,
            
            for $r at $pos in $ordered-results/search:result
            let $indexNum := ($pos - 1) + $start-pos
            return 
                element search:result {
                    $r/attribute::*, 
                    attribute index {$indexNum},
                    $r/child::node()
                } 
        }
        
    return $ordered-results

};
:)
(:~
:   This formats the label.  The fn:replace 
:   search should be exactly the same as found
:   in madsrdf2index.
:
:   @param  $label      is the xs:string to be formatted
:   @return xs:string   formatted
:)
declare function format-label($label) as xs:string
{
    fn:replace( $label, "([,-\.\(\)\s?']+)" , "-")
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


