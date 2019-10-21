xquery version "1.0-ml";

module namespace lq = "http://www.marklogic.com/ps/lib/l-query";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace search="http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";                    
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace ld = "http://www.marklogic.com/ps/lib/l-date" at "/xq/lscoll/lib/l-date.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace param = "http://www.marklogic.com/ps/params";
(: you have to include all namespaces for facets here or lq:recursive-remove-query won't work :)
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mxe1 = "mxens";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";

declare default collation "http://marklogic.com/collation/en/S1";

declare function lq:store-query($query as cts:query?) as cts:query? {
    let $_ := xdmp:set-session-field("query", $query)
    return
        $query
};

declare function lq:get-last-query() as cts:query? {
    xdmp:get-session-field("query", ())
};

declare function lq:get-highlight-query() as cts:query? {
    cts:or-query((
        <x>{ lq:query-from-params($lp:CUR-PARAMS) }</x>//cts:text
    ))
};

declare function lq:text-to-query($term) as cts:query {
    cts:query(search:parse(lower-case($term), $cfg:SEARCH-OPTIONS) )
};


declare function lq:recursive-remove($nodes, $ns, $ln) {
    for $node in $nodes
    let $this-local-name := local-name($node)
    let $this-namespace := namespace-uri($node)
    return
        if($this-local-name) then
            let $acceptable-children :=
                if($this-local-name = ("and-query","or-query")) then
                    $node/node()
                else
                    ()
            return
                element {QName($this-namespace, $this-local-name)} {
                    lq:recursive-remove($acceptable-children ,$ns,$ln)
                }
        else
            $node
};

declare function lq:recursive-remove-query($ns, $ln, $nodes) {
    for $node in $nodes 
    let $local-name := local-name($node)
    return
        if($local-name ne "") then
           if( contains(($node/cts:element-value-query/cts:element/text())[1],$ln)) then () else
            element {QName(namespace-uri($node),local-name($node))} {
              $node/@*,
              lq:recursive-remove-query($ns,$ln, $node/node())
            }
        else 
            $node
};

declare function lq:get-last-query-without-me($ns,$ln) as cts:query? {
    let $params := $lp:CUR-PARAMS
    let $query := xdmp:get-session-field("query",())
    let $query-xml := (<x>{$query}</x>)/node()
    let $_ := xdmp:log(concat("Orig Query: ",xdmp:quote($query-xml)),'debug')
    let $query-xml-removed := if($query-xml) then lq:recursive-remove-query($ns,$ln,$query-xml) else ()
    let $_ := xdmp:log(concat("Removed Query: ",xdmp:quote($query-xml-removed)),'debug')
    return
        cts:query($query-xml-removed)
};

declare function lq:query-from-params($params as element(param:params)) as cts:query? {
    let $term := lp:get-param-single($params,'q')
    let $qname as xs:string? := lp:get-param-single($params, 'qname')
    let $precision as xs:string? := lp:get-param-single($params, 'precision')
    let $text-query := 
        if ($term) then
            if ($qname ne "keyword") then
                if ($precision eq "exact") then
                    cts:element-value-query(xs:QName($qname), $term)
                 else
                    cts:element-word-query(xs:QName($qname), $term)
            else
                lq:text-to-query($term)
        else
            ()
    let $facet-elts := $cfg:DISPLAY-ELEMENTS//elt[facet-id = $params/param:param/param:name]
    let $facet-query := cts:and-query((    
        for $facet-elt in $facet-elts
        let $ns := ($facet-elt/facet-param)[1]/text()
        let $ln := ($facet-elt/facet-param)[2]/text()
        let $operation := $facet-elt/facet-operation/text()
        let $queries := 
            for $value in ($params/param:param[param:name eq $facet-elt/facet-id])/param:value/text()
            return
                cts:element-value-query(QName($ns, $ln), $value)
        return        
            if($operation = "or") then
                cts:or-query($queries)
            else 
                cts:and-query($queries)
    ))
    
    let $two-tier-elts := $cfg:DISPLAY-ELEMENTS//elt[ fn:starts-with(./facet-id/text(), "ft") ]
    let $two-tier-queries := 
        for $elt in $two-tier-elts
        let $id := $elt/facet-id/text()
        
        let $ns1 := ($elt/facet-param/text())[1]
        let $ln1 := ($elt/facet-param/text())[2]
        let $ns2 := ($elt/facet-param/text())[3]
        let $ln2 := ($elt/facet-param/text())[4]
    
        let $a :=  lp:get-param-single( $params, fn:concat($id,'a') )
        let $b :=  lp:get-param-single( $params, fn:concat($id,'b') )
        return
        (
            if($a) then
                cts:element-value-query(QName($ns1, $ln1), $a)
            else
                (),
            
            if($b) then
                cts:element-value-query(QName($ns2, $ln2), $b)
            else
                ()
        )

    
    let $final-query := cts:and-query(($facet-query, $text-query,$two-tier-queries))
    let $_ := xdmp:log(concat("final Query: ", xdmp:quote($final-query)), "debug")
    return
        $final-query
};

declare function lq:browse-lexicons($query as xs:string, $field as xs:string, $direction as xs:string) as xs:string* {
    let $howMany := 25
    let $browsefld := 
        if ($field eq "subject") then
            "idx:subjectLexicon"
        else if ($field eq "author") then
            "idx:mainCreator"
        else if ($field eq "class") then
            "idx:lcclass"
        else
            "idx:titleLexicon"
    let $limit := concat("limit=", $howMany)
    let $order := $direction
    let $collation := "collation=http://marklogic.com/collation/codepoint"
    let $opts := ($limit, $order, $collation, "checked", "item-frequency", "concurrent")
    let $seq := cts:element-values(xs:QName($browsefld), $query, $opts)
    return
        if ($order eq "descending") then
            reverse($seq)
        else
            $seq
};

declare function lq:search-resolve($ctsquery as element(cts:and-query), $start as xs:int, $count as xs:int) as element(search:response) {
    search:resolve($ctsquery, $cfg:ATOM-SEARCH-OPTIONS, $start, $count)
};