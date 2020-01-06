xquery version "1.0";

(:
:   Module Name: MADSRDF Full to Index
:
:   Module Version: 1.0
:
:   Date: 2012 Sept 18
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: none
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Primary purpose is to take a full MADS/RDF
:       record and create the index document used by MarkLogic 
:       for indexing.  
:
:)
   
(:~
:   Primary purpose is to take a full MADS/RDF
:   record and create the index document used by MarkLogic 
:   for indexing.  
:
:   @author Nate Trail (ntra@loc.gov)
:   @since September 20, 2012
:   @author Kevin Ford (kefo@loc.gov)
:   @since October 18, 2010
:   @version 1.1
: 	Modifications:
:       September 18, 2012:
:			Subdivide Geographically was direct/indirect; that distinction is now gone.
:			Subject LC Classes added as index:lcc
:			localhost/authorities/subjects/sh85046079.index.xml
:       September 20, 2012:
:           Names: fixed slabel for multiple fullnameelements
:       September 27, 2012:
:           Modified/hacked to handle bibframe stuff. File/function should
            really be renamed, but that would require untangling elsewhere.
:       
:)
        

(: NAMESPACES :)
module namespace    madsrdf2index       = "info:lc/id-modules/madsrdf2index#";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf             = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   ri                  = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   bf               = "http://bibframe.org/vocab/";
declare namespace   index               = "info:lc/xq-modules/lcindex";
declare namespace   relators            = "http://id.loc.gov/vocabulary/relators/";

(: VARIABLES :)


(:~
:   This is the main function.  It converts full MADS/RDF to 
:   an Index document.
:   It takes the MADS/RDF XML as the only argument.
:
:   @param  $rdf        node() is the MARC XML  
:   @return index:index node
:)
declare function madsrdf2index:madsrdf2index($rdfxml as element()) as node() {
    let $resource := $rdfxml/child::node()[fn:name()][1]
    let $uris := madsrdf2index:get_uris($resource)
    let $types := madsrdf2index:get_types($resource)
    let $labels := madsrdf2index:get_main_label($resource)
    (: let $all_labels := get_all_labels($rdfxml/child::node()) :)
    let $vLabels := madsrdf2index:get_variant_labels($resource)
    let $sLabels := madsrdf2index:get_special_labels($resource)
    let $creation_dates := madsrdf2index:get_creation_dates($resource//ri:recordChangeDate[parent::node()[1]/ri:recordStatus eq "new"])
    let $modification_dates := madsrdf2index:get_modification_dates($resource//ri:recordChangeDate[parent::node()[1]/ri:recordStatus ne "new"])
    let $code := madsrdf2index:get_code($resource/madsrdf:code)
    let $status := madsrdf2index:get_status($resource//ri:recordStatus)
    let $schemes := madsrdf2index:get_schemes($resource/madsrdf:isMemberOfMADSScheme)
    let $tables := madsrdf2index:get_tables($resource/madsrdf:useTable/madsrdf:Table/madsrdf:code)
    let $collections := madsrdf2index:get_collections($resource/madsrdf:isMemberOfMADSCollection)
    let $usePatterns := madsrdf2index:get_usepatterns($resource/madsrdf:usePatternCollection)
    let $contentSources := madsrdf2index:get_contentSources( $resource//ri:recordContentSource )
    let $classes := madsrdf2index:get_classes($resource//madsrdf:classification)
    
    (: bibframe-related extracts :)
    let $uniformTitle :=  madsrdf2index:get_bibframe_uniform_title($resource)
    let $mainTitles := madsrdf2index:get_bibframe_titles($resource)
    let $variantTitles := madsrdf2index:get_bibframe_variantTitles($resource)
    let $bibframeLabels := madsrdf2index:get_bibframe_labels($resource)
    let $creators := madsrdf2index:get_bibframe_creator($resource)
    let $contributors := madsrdf2index:get_bibframe_contributor($resource)
    let $languages := madsrdf2index:get_bibframe_language($resource)
	
	let $language:= for $l in fn:distinct-values($languages)
						return element index:language {$l}
    let $derivations := madsrdf2index:get_bibframe_derivations($resource)
    
    let $relations := madsrdf2index:get_relations($resource)
    (: let $variants := get_relations($rdfxml/child::node()) :)
    return 
        element index:index {
            $uris,
            $schemes,
            $collections,
            $usePatterns,
            $code,
            $types,
            $labels,
            $vLabels,
            $sLabels,
            $uniformTitle,
            $mainTitles,
            $variantTitles,
            $bibframeLabels,
            $creators,
            $contributors,
            $relations,
            $language,
            $derivations,
            $tables,
            $creation_dates,
            $modification_dates,
            $status,
            $classes,
            $contentSources
        }
};



(:~
:   This is creates a relation label. 
:
:   @param  $e        element() is the MADS/RDF related item  
:   @return string
:)
declare function madsrdf2index:create_relation_label($e as element()) as xs:string
{
    (: 
        $enode is current element node - Authority, Variant, 
        or RelationshipType, such as hasEarlierEstablishedForm
    :)
    let $enode := 
        if ( $e/child::node()[fn:name()][1][madsrdf:authoritativeLabel or madsrdf:variantLabel] ) then
            $e/child::node()[fn:name()][1]
        else if ( $e[madsrdf:authoritativeLabel or madsrdf:variantLabel] ) then
            $e
        else ()
    (: 
        $pnode is the parent node of the current element node
    :)
    let $pnode := 
        if ( $e/parent::node()[1]/madsrdf:isMemberOfMADSCollection ) then
            $e/parent::node()[1]
        else if ( $e/madsrdf:isMemberOfMADSCollection ) then
            $e
        else ()
    let $label_text := 
        if ($enode/madsrdf:authoritativeLabel[@xml:lang eq "en"]) then
            xs:string($enode/madsrdf:authoritativeLabel[@xml:lang eq "en"])
        else if ($enode/madsrdf:authoritativeLabel[1]) then
            xs:string($enode/madsrdf:authoritativeLabel[1])
        else if ($enode/madsrdf:variantLabel[@xml:lang eq "en"]) then
            xs:string($enode/madsrdf:variantLabel[@xml:lang eq "en"])
        else if ($enode/madsrdf:variantLabel[1]) then
            xs:string($enode/madsrdf:variantLabel[1])
        else
            ""
    let $label := fn:replace( $label_text , "([,-\.\(\)\s?']+)" , '-')
    return         
        fn:concat( 
            if (fn:local-name($e) ne fn:local-name($enode)) then 
                fn:local-name($e)
            else "", 
            "_",
            fn:local-name($enode),
            "_",
            fn:substring-after($enode/rdf:type[1]/@rdf:resource, "#"),
            "_" ,
            $label,
            "_",
            if ($pnode/madsrdf:isMemberOfMADSCollection[@rdf:resource eq "http://id.loc.gov/authorities/lcsh/collection_LCSH_General"]) then
                "LCSH"
            else if ($pnode/madsrdf:isMemberOfMADSCollection[@rdf:resource eq "http://id.loc.gov/authorities/lcsh/collection_LCSH_Childrens"]) then
                "LCSHSJ"
            else if ($pnode/madsrdf:isMemberOfMADSCollection[@rdf:resource eq "http://id.loc.gov/authorities/names/collection_LCNAF"]) then
                "NAMES"
            else "",
            if ($pnode/madsrdf:isMemberOfMADSCollection[@rdf:resource eq "http://id.loc.gov/authorities/lcsh/collection_TopicSubdivisions"]) then
                "_ToSD"
            else if ($pnode/madsrdf:isMemberOfMADSCollection[@rdf:resource eq "http://id.loc.gov/authorities/lcsh/collection_GenreFormSubdivisions"]) then
                "_GFSD"
            else if ($pnode/madsrdf:isMemberOfMADSCollection[@rdf:resource eq "http://id.loc.gov/authorities/lcsh/collection_TemporalSubdivisions"]) then
                "_TeSD"
            else if ($pnode/madsrdf:isMemberOfMADSCollection[@rdf:resource eq "http://id.loc.gov/authorities/lcsh/collection_GeographicSubdivisions"]) then
                "_GSD"
            else if ($pnode/madsrdf:isMemberOfMADSCollection[@rdf:resource eq "http://id.loc.gov/authorities/lcsh/collection_LanguageSubdivisions"]) then
                "_LSD"
            else ""            
        )
        
};

(:~
:   Records the code
:
:   @param  $el        element() is the MADS/RDF property  
:   @return index:code element()
:)
declare function madsrdf2index:get_code($el as element()*) as element()* {
    for $e in $el
    return 
        (
            element index:code { text { $e/text() } },
            if ( fn:contains(xs:string($e), "-") ) then
                let $codeStart := fn:substring-before(xs:string($e), "-")
                let $codeEnd := fn:substring-after(xs:string($e), "-")
                return 
                    (
                        element index:codeStart { $codeStart },
                        element index:codeEnd { $codeEnd }
                    )
            else
                ()
        )
};

(:~
:   Records the classifications
:
:   @param  $el        	element() is the MADS/RDF property  
:   @return index:class element()
:)
declare function madsrdf2index:get_classes($el as element()*) as element()* {
    for $e in $el
    return 
        (
            element index:lcc { text { $e/text() } }            
        )
};

(:~
:   This is gathers all the collections to which this
:   record belongs.
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:memberURI element()
:)
declare function madsrdf2index:get_collections($el as element()*) as element()* {
    for $e in $el
        return 
            (
                element index:memberOfURI { text { fn:data($e/@rdf:resource) } }
            )
};

(:~
:   This is adds contentSource to the index document.
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:memberURI element()
:)
declare function madsrdf2index:get_contentSources($el as element()*) as element()* {
    for $e in fn:distinct-values($el/@rdf:resource)
        return 
            (
                element index:contentSource { text { fn:data($e) } }
            )
};

(:~
:   Grabs the creation date for the record
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:cDate element()
:)
declare function madsrdf2index:get_creation_dates($el as element()*) as element()* {
    for $e in $el
		let $date:=fn:substring-before($e/text(), "T")
	  	let $date:=if ($e castable as xs:date) then
						$e
				 else "1969-01-01"
        return element index:cDate { $date }
};

(:~
:   Records the aLabel or vLabel
:   Should all the vLabels be extracted, they currently are not
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:aLabel or index:vLabel element()
:		!NOT USED! see get_main_label
:)
declare function madsrdf2index:get_all_labels($el as element()*) as element()* {
    (
        if ($el/madsrdf:authoritativeLabel[@xml:lang eq "en"]) then
            element index:label { text { $el/madsrdf:authoritativeLabel[@xml:lang eq "en"] } }
        else if ($el/madsrdf:authoritativeLabel[1]) then
            element index:label { text { $el/madsrdf:authoritativeLabel[1] } }
        else if ($el/madsrdf:variantLabel[@xml:lang eq "en"]) then
            element index:label { text { $el/madsrdf:variantLabel[@xml:lang eq "en"] } }
        else if ($el/madsrdf:variantLabel[1]) then
            element index:label { text { $el/madsrdf:variantLabel[1] } }
        else (),
    
        for $v in $el/madsrdf:hasVariant
        where $v/child::node()[fn:name()]/madsrdf:variantLabel
        return element index:label { text { $v/child::node()[fn:name()]/madsrdf:variantLabel } } 
    )
};

(:~
:   Records the aLabel or vLabel or dLabel
:   Should all the vLabels be extracted, they currently are not
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:aLabel or index:vLabel element()
:)
declare function madsrdf2index:get_main_label
    ($el as element()*) 
    as element()*
{
    if ($el/madsrdf:authoritativeLabel) then
        for $l in $el/madsrdf:authoritativeLabel
        return
            element index:aLabel {
                $l/@xml:lang, 
                text{ $l }
            }
    else if ($el/madsrdf:variantLabel) then
        for $l in $el/madsrdf:variantLabel
        return
            element index:vLabel {
                $l/@xml:lang, 
                text{ $l }
            }
    else if ($el/madsrdf:deprecatedLabel) then
        for $l in $el/madsrdf:deprecatedLabel
        return
            element index:dLabel {
                $l/@xml:lang, 
                text{ $l }
            }
    else if ($el/rdfs:label) then
        for $l in $el/rdfs:label
        return
            element index:label {
                $l/@xml:lang, 
                text{ $l }
            }
    else ()
};

(:~
:   Records the aLabel or vLabel
:   Should all the vLabels be extracted, they currently are not
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:aLabel or index:vLabel element()
:)
declare function madsrdf2index:get_labels($el as element()*) as element()* {
    (
    if ($el/madsrdf:authoritativeLabel[@xml:lang eq "en"]) then
        element index:aLabel { text { $el/madsrdf:authoritativeLabel[@xml:lang eq "en"] } }
    else if ($el/madsrdf:authoritativeLabel[1]) then
        element index:aLabel { text { $el/madsrdf:authoritativeLabel[1] } }
    else if ($el/madsrdf:variantLabel[@xml:lang eq "en"]) then
        element index:vLabel { text { $el/madsrdf:variantLabel[@xml:lang eq "en"] } }
    else if ($el/madsrdf:variantLabel[1]) then
        element index:vLabel { text { $el/madsrdf:variantLabel[1] } }
    else ()
    )
};


(:~
:   This is gathers all the use-with-pattern-heading relations for indexing.
:
:   @param  $el        element() is the MADS/RDF use pattern heading
:   @return index:memberURI element()
:)
declare function madsrdf2index:get_usepatterns($el as element()*) as element()* {
    for $e in $el
        return 
            (
                element index:usePatternCollection { text { fn:data($e/@rdf:resource) } }
            )
};


(:~
:   Records the aLabel or vLabel
:   Should all the vLabels be extracted, they currently are not
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:aLabel or index:vLabel element()
:)
declare function madsrdf2index:get_variant_labels($el as element()*) as element()* {
    (    
        for $v in $el/madsrdf:hasVariant/child::node()[fn:name()]/madsrdf:variantLabel
        return element index:vLabel {
                $v/@xml:lang, 
                text{ $v }
            }
    )
};

(:~
:   Extracts Special Labels
:
:   Personal: name and name with date: (trailing comma trimmed from "name only")
:       localhost/authorities/names/n79021164.index.xml
:
:   CorporateName:  NameElement only:
:       localhost/authorities/names/n81013222.index.xml
:
:   ConferenceName: NameElement and Name with Date: (without the geo element but with dates)
:       localhost/authorities/names/n83235990.index.xml
:       name plus date has ( and : removed, and is concatenated with a period between name and date
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:aLabel or index:vLabel element()
:)
declare function madsrdf2index:get_special_labels
    ($el as element()) 
    as element()* 
{

    let $elList := $el/madsrdf:elementList
    return
        
        if ($el/fn:local-name()='PersonalName') then      
         (   
            (: drop (fullname in parens) and date :)
            if ( $elList/madsrdf:FullNameElement[2] or $elList/madsrdf:DateNameElement) then
                element index:sLabel {
                    $elList/madsrdf:FullNameElement[1]/madsrdf:elementValue/@xml:lang, 
                    fn:replace($elList/madsrdf:FullNameElement[1]/madsrdf:elementValue/fn:string(),",$","")
                }
            else (),
            
            (:  drop (fullname in parens) :)
            if ( $elList/madsrdf:FullNameElement[2] and $elList/madsrdf:DateNameElement) then
                element index:sLabel { 
                    $elList/madsrdf:FullNameElement[1]/madsrdf:elementValue/@xml:lang, 
                    fn:concat($elList/madsrdf:FullNameElement[1]/madsrdf:elementValue/fn:string(),", ",$elList/madsrdf:DateNameElement/madsrdf:elementValue/fn:string())
                }
            else ()
          )
        
        (: Commenting out - too much cruft would be created :)
        (:
        else if ($el/fn:local-name()='CorporateName') then        
            element index:sLabel {
                $el/madsrdf:elementList/madsrdf:NameElement[1]/madsrdf:elementValue/@xml:lang, 
                fn:replace($el/madsrdf:elementList/madsrdf:NameElement[1]/madsrdf:elementValue/fn:string(),".$","")
            }
        :)
        
        else if ($el/fn:local-name()='ConferenceName') then        
            (     
                (: Remove everything but the first FullNameElement :)
                if ( $elList/madsrdf:FullNameElement[2] or $elList/madsrdf:DateNameElement or $elList/madsrdf:GeographicElement) then
                    element index:sLabel {
                        $elList/madsrdf:NameElement[1]/madsrdf:elementValue/@xml:lang, 
                        fn:replace($elList/madsrdf:NameElement[1]/madsrdf:elementValue/fn:string(),",$","")
                    }
                else (),
                
                (: Remove everything but the first FullNameElement AND the DateNameElement :)
                if ( $elList/madsrdf:DateNameElement ) then
                    element index:sLabel {
                        $elList/madsrdf:FullNameElement[1]/madsrdf:elementValue/@xml:lang, 
                        fn:concat($elList/madsrdf:NameElement[1]/madsrdf:elementValue/fn:string(),". ",
                            fn:normalize-space(fn:replace($elList/madsrdf:DateNameElement/madsrdf:elementValue/fn:string(),"(\(|:)",""))
                        )
                    }
                else (),
                
                (:  
                    If there is no geo reference AND no date, but there is a parenthetical, which is
                    probably a geo reference, remove it. 
                :)
                if ( 
                        fn:not($elList/madsrdf:FullNameElement[2]) and 
                        fn:not($elList/madsrdf:DateNameElement) and 
                        fn:not($elList/madsrdf:GeographicElement) and
                        fn:contains( xs:string($elList/madsrdf:NameElement[1]/madsrdf:elementValue), ")")
                    ) then
                    element index:sLabel {
                        $elList/madsrdf:NameElement[1]/madsrdf:elementValue/@xml:lang, 
                        fn:normalize-space(fn:replace($elList/madsrdf:NameElement[1]/madsrdf:elementValue/fn:string(),"\(([0-9a-zA-Z :,\.]+)\)$",""))
                    }
                else ()
           )
    else ()

};

(:~
:   Grabs the modification date for the record
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:mDate element()
:)
declare function madsrdf2index:get_modification_dates($el as element()*) as element()* {
    for $e in $el
        let $date:=fn:substring-before($e/text(), "T")
	  	let $date:=if ($e castable as xs:date) then
						$e
				 else "1969-01-01"
        return element index:mDate { $date }
};

(:~
:   Records the relations
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:relation element()
:)
declare function madsrdf2index:get_relations($el as element()) as element()* {
    let $relation_possibilities := 
        (
            "madsrdf:hasBroaderAuthority",
            "madsrdf:hasNarrowerAuthority",
            "madsrdf:hasEarlierEstablishedForm",
            "madsrdf:hasLaterEstablishedForm",
            "madsrdf:hasRelatedAuthority",
            "madsrdf:hasParentOrganization",
            "madsrdf:isParentOrganization",
            "madsrdf:hasReciprocalAuthority"
        )
        (: removed hasVariant relationships :)
    let $relations := 
        for $e in $el/child::node()[fn:name() and fn:not(@rdf:resource)]
        where fn:count(fn:index-of($relation_possibilities , fn:name($e))) eq 1
        return madsrdf2index:get_relation_label($e)
        
    return $relations
};

(:~
:   This is creates a relation label. It is a substite/rewrite of 
:   create_relation_label, which is above.  It has been implemented
:   For indexing with elasticsearch
:
:   @param  $e        element() is the MADS/RDF related item  
:   @return string
:)
declare function madsrdf2index:get_relation_label($e as element()) as element(index:relation)
{
    (: 
        $enode is current element node - Authority, Variant, 
        or RelationshipType, such as hasEarlierEstablishedForm
    :)
    let $related-resource := 
        if ( $e/child::node()[fn:name()][1][madsrdf:authoritativeLabel or madsrdf:variantLabel] ) then
            $e/child::node()[fn:name()][1]
        else if ( $e[madsrdf:authoritativeLabel or madsrdf:variantLabel] ) then
            $e
        else ()
    
    let $label-element := ($related-resource/madsrdf:authoritativeLabel, $related-resource/madsrdf:variantLabel)[1]
    let $label := xs:string($label-element)
    
    let $relation := fn:local-name($e)
    
    return         
        element index:relation {
            attribute relType { $relation },
            $label-element/@xml:lang,
            $label
        }
        
};

(:~
:   Records the schemes
:
:   @param  $el        element() is the MADS/RDF property
:   @return index:scheme element()
:)
declare function madsrdf2index:get_schemes($el as element()*) as element()* {
    for $e in $el
        return 
            (
                element index:scheme { text { fn:data($e/@rdf:resource) } }
            )
};

(:~
:   Records the status
:
:   @param  $el        element() is the MADS/RDF property  
:   @return index:status element()
:)
declare function madsrdf2index:get_status($el as element()*) as element()* {
    for $e in $el
        return element index:status { text { $e/text() } }
};

(:~
:   Records the tables to use
:
:   @param  $el        element() is the MADS/RDF property
:   @return index:usestable element()
:)
declare function madsrdf2index:get_tables($el as element()*) as element()* {
    for $e in $el
        return 
            (
                element index:usestable { text { fn:data($e) } }
            )
};

(:~
:   Records the RDF types
:
:   @param  $el        element() is the MADS/RDF property  
:   @return index:rdftype element() - will be multiple element()
:)
declare function madsrdf2index:get_types($el as element()) as element()* 
{
    let $root_rdftype := fn:local-name($el)
    return 
        (
        element index:rdftype { text { $root_rdftype } },
        
        if ($root_rdftype eq "ComplexSubject" or
            $root_rdftype eq "NameTitle" or
            $root_rdftype eq "HierarchicalGeographic") then
            element index:rdftype { text {"ComplexType"} }
        else if ($root_rdftype eq "Geographic" or
            $root_rdftype eq "Language" or
            $root_rdftype eq "Temporal" or
            $root_rdftype eq "GenreForm" or
            $root_rdftype eq "Name" or
            $root_rdftype eq "PersonalName" or
            $root_rdftype eq "CorporateName" or
            $root_rdftype eq "Title" or
            $root_rdftype eq "Occupation" or
            $root_rdftype eq "FamilyName" or
            $root_rdftype eq "ConferenceName" or
            $root_rdftype eq "Topic") then
            element index:rdftype { text {"SimpleType"} }
        else (),
        
        if ($root_rdftype eq "PersonalName" or
            $root_rdftype eq "CorporateName" or
            $root_rdftype eq "ConferenceName" or
            $root_rdftype eq "FamilyName") then
            element index:rdftype { text {"Name"} }
        else (),
        
        for $e in $el/rdf:type/@rdf:resource
        let $tStr := xs:string($e)
        let $t := 
            if ( fn:contains( $tStr, "#" ) ) then
                fn:substring-after( $tStr, '#')
            else if ( fn:contains( $tStr, "_" ) ) then
                fn:substring-after($tStr, '_')
            else if ( fn:contains( $tStr, "/" ) ) then
                xs:string(fn:tokenize($tStr, "/")[fn:last()])
            else
                ""
        return
            if ($t ne "") then
                element index:rdftype { $t }
            else 
                ()
        )
};

(:~
:   Records the URIs
:
:   @param  $el        element() is the MADS/RDF property  
:   @return index:uri element(), index:token element() - will be multiple element()
:)
declare function madsrdf2index:get_uris($el as element()) as element()* {
    let $uri := fn:data($el/@rdf:about)
    let $uri_tokens := fn:tokenize( $uri , '/')
    let $token := $uri_tokens[fn:last()] 
    return
        (
            element index:uri { text { $uri } },
            element index:token { text { $token } }
        )
};

(:~
:   Extracts the contributor from an instance from a work.
:
:   @param  $resource is the resource  
:   @return index:contributor or nothing
:)
declare function madsrdf2index:get_bibframe_contributor
    ($resource as element()) 
    as element()*
{
    for $t in   $resource/bf:contributor|$resource/relators:*
    return
        element index:contributor {
            $t/bf:*/bf:label/@xml:lang,
            xs:string($t/bf:*/bf:label)
        }
};

(:~
:   Extracts the creator from a work.  This 
:   will have to be monitored. Is it possible to
:   simply refine a search query to accurately 
:   identify a resource without knowing
:   the precise relationship between the creator and 
:   the work.
:
:   @param  $resource is the resource  
:   @return index:creator or nothing
:)
declare function madsrdf2index:get_bibframe_creator
    ($resource as element()) 
    as element()*
{
    for $t in   $resource/bf:creator|$resource/bf:author|$resource/bf:reader|
                $resource/bf:illustrator|$resource/bf:sculptor|$resource/bf:carver
    return
        element index:creator {
            $t/bf:*/bf:label/@xml:lang,
            xs:string($t/bf:*/bf:label)
        }
};

(:~
:   Extracts the derivation relationships.
:
:   @param  $resource is the resource  
:   @return index:derivedFrom or nothing
:)
declare function madsrdf2index:get_bibframe_derivations
    ($resource as element()) 
    as element()*
{
    for $t in   $resource/bf:derivedFrom/@rdf:resource
    return
        element index:derivedFrom {
            xs:string($t)
        }
};

(:~
:   Extracts the variant titles
:
:   @param  $resource is the resource  
:   @return index:title elements or nothing
:)
declare function madsrdf2index:get_bibframe_labels
    ($resource as element()) 
    as element()*
{
    for $t in $resource/bf:label
    return
        element index:label {
            $t/@xml:lang,
            xs:string($t)
        }
};

(:~
:   Extracts the language
:   This will require some kind of refinement
:   for codes
:
:   @param  $resource is the resource  
:   @return index:language or nothing
:)
declare function madsrdf2index:get_bibframe_language
    ($resource as element()) 
    as xs:string*
{
      for $lang in $resource/bf:language
		return if ($lang/@rdf:resource) then 
        			
            			xs:string($lang/@rdf:resource)
				
        		else
		 			text {$lang} 
};

(:~
:   Extracts the uniformTitle
:
:   @param  $resource is the resource  
:   @return index:uniformTitle or nothing
:)
declare function madsrdf2index:get_bibframe_uniform_title
    ($resource as element()) 
    as element()*
{
    if ( $resource/bf:uniformTitle ) then
        element index:uTitle {
            $resource/bf:uniformTitle/@xml:lang,
            xs:string($resource/bf:uniformTitle)
        }
    else
        ()
};

(:~
:   Extracts the main titles (i.e. not variants not uniforms)
:
:   @param  $resource is the resource  
:   @return index:title elements or nothing
:)
declare function madsrdf2index:get_bibframe_titles
    ($resource as element()) 
    as element()*
{
    for $t in $resource/bf:title
    return
        element index:mTitle {
            $t/@xml:lang,
            xs:string($t)
        }
};

(:~
:   Extracts the variant titles
:
:   @param  $resource is the resource  
:   @return index:title elements or nothing
:)
declare function madsrdf2index:get_bibframe_variantTitles
    ($resource as element()) 
    as element()*
{
    for $t in $resource/bf:variantTitle
    return
        element index:vTitle {
            $t/@xml:lang,
            xs:string($t)
        }
};
