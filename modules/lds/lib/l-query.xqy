xquery version "1.0-ml";

module namespace lq = "http://www.marklogic.com/ps/lib/l-query";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace search="http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";                    
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace georss = "http://www.georss.org/georss" at "/MarkLogic/geospatial/georss.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace param = "http://www.marklogic.com/ps/params";
(: you have to include all namespaces for facets here or lq:recursive-remove-query won't work :)
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace kml22 = "http://www.opengis.net/kml/2.2";
declare namespace georss11 = "http://www.georss.org/georss/11";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mxe1 = "mxens";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace djvu = "http://www.loc.gov/djvu";

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

declare function lq:remove-higher-tier-params($params, $tiers, $current-tier) {
    let $params-to-remove := $tiers[@level gt xs:int($current-tier)]//*:id/text()
    let $ret-params := $params
    let $_ := 
        for $param in $params-to-remove
        return
            xdmp:set($ret-params, lp:param-remove-all($ret-params, $param))
    return
        $ret-params    
};

declare function lq:tiers-from-params($params as xs:string*) as element(tier)* {
    let $suffixes := ('a','b','c','d','e','f','g','h','i','j','k')
    let $len := fn:count($params)
    let $id := $params[$len]
    let $index := 0
    return
        for $v at $x in $params[1 to ($len - 1)]
        return
            if(($x mod 2) eq 0) then 
                let $_ := xdmp:set($index, $index + 1 )
                return
                    element tier {
                        attribute level { $index },
                        element id { fn:concat($id, $suffixes[$index]) },
                        element namespace { $params[($x - 1)] },
                        element localname { $v }
                    }
            else ()
};

declare function lq:query-from-params($params as element(param:params)) as cts:query? {
    let $term as xs:string? := lp:get-param-single($params, 'q')
    let $sruterm as xs:string? := lp:get-param-single($params, 'query')
    let $qname as xs:string? := lp:get-param-single($params, 'qname')
    let $precision as xs:string? := lp:get-param-single($params, 'precision')
    let $points as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "latlng")
    let $cln as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'collection', $cfg:DEFAULT-COLLECTION)
    let $region :=
        if ($points eq "earth") then
            $cfg:DEFAULT-POLYGON-ROI
        else if ($points) then
            georss:polygon(<georss:polygon>{replace($points, "(, |\(|\))", " ")}</georss:polygon>)
        else
            ()
    let $text-query := 
        if ($term) then
            if ($qname ne "keyword") then
                if ($precision eq "exact") then
                    (: cts:element-value-query(xs:QName($qname), $term, ("exact")) :)
                    (: See Danny Sokolsky at http://www.mail-archive.com/general@developer.marklogic.com/msg02325.html :)
                    cts:element-range-query(xs:QName($qname), "=", $term, ("collation=http://marklogic.com/collation/en/S1"))
                 else
                    cts:element-query(xs:QName($qname), lq:text-to-query($term))
            else
                lq:text-to-query($term)
        else if ($sruterm) then
            lq:text-to-query($sruterm)
        else
            ()
    
    let $geo-query :=
        if ($region instance of empty-sequence()) then
            $region
        else
            cts:element-geospatial-query(xs:QName("georss11:point"), $region, ("boundaries-included", "cached"))
    
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
    
    let $collection-query := 
        if ($cln eq ("/lscoll/", "/lscoll/lcdb/", "/lscoll/erms/")) then
            cts:and-not-query(cts:collection-query($cln), cts:collection-query(("/lscoll/lcdb/holdings/", "/lscoll/erms/holdings/")))
        else
            cts:collection-query($cln)
        
    let $multi-tier-elts := $cfg:DISPLAY-ELEMENTS//elt[data-function/text() eq "vf:facet-multi-tier" ]
    let $multi-tier-queries :=
        for $elt in $multi-tier-elts
        let $id := $elt/facet-id/text()
        let $operation := $elt/facet-operation/text()
        let $tiers := lq:tiers-from-params( ($elt/*:facet-param/text(), $elt/*:facet-id/text()) )
        return
            for $tier in $tiers
            let $id := $tier/*:id/text()
            let $ns := $tier/*:namespace/text()
            let $ln := $tier/*:localname/text()
            let $param-val := (:lp:get-param-mutliple:) lp:get-param-single($params, $id)
            return
                if($param-val) then
                    cts:element-value-query(QName($ns, $ln), $param-val)
                else
                    ()

    let $final-query := cts:and-query(($facet-query, $text-query, $multi-tier-queries, $geo-query, $collection-query))
    let $_ := xdmp:log(concat("final Query: ", xdmp:quote(<blah>{$final-query}</blah>/element())), "info")
    return
        $final-query
};

declare function lq:browse-lexicons($query as xs:string, $field as xs:string, $direction as xs:string, $collection as xs:string) as xs:string* {
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
    let $collation := "collation=http://marklogic.com/collation/en/S1"
    let $opts := ($limit, $order, $collation, "checked", "item-frequency", "concurrent")
    let $cts := cts:collection-query($collection)
    let $seq := cts:element-values(xs:QName($browsefld), $query, $opts, $cts)
    return
        if ($order eq "descending") then
            reverse($seq)
        else
            $seq
};

declare function lq:search-resolve($ctsquery as element(cts:and-query), $start as xs:int, $count as xs:int, $sort as xs:string, $cln as xs:string) as element(search:response) {
    let $sortopt :=
        if ($sort eq "score-desc") then
            <search:sort-order direction="descending">
                <search:score/>
            </search:sort-order>
        else if ($sort eq "score-asc") then
            <search:sort-order direction="ascending">
                <search:score/>
            </search:sort-order>
        else if ($sort eq "pubdate-desc") then
            (
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="descending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="pubdateSort"/>
                </search:sort-order>,
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="titleLexicon"/>
                </search:sort-order>
            )
        else if ($sort eq "pubdate-asc") then
            (
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="pubdateSort"/>
                </search:sort-order>,
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="titleLexicon"/>
                </search:sort-order>
            )
        else if ($sort eq "cre-desc") then
            (
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="descending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="mainCreator"/>
                </search:sort-order>,
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="titleLexicon"/>
                </search:sort-order>
            )
        else if ($sort eq "cre-asc") then
            (
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="mainCreator"/>
                </search:sort-order>,
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="titleLexicon"/>
                </search:sort-order>
            )
        else
            <search:sort-order direction="descending">
                <search:score/>
            </search:sort-order>
    let $se := concat("collection(&apos;", $cln, "&apos;)")
    let $opts := lq:search-api-options($se, $sortopt)    
    return
        search:resolve($ctsquery, $opts, $start, $count)
};

declare function lq:search-api-options($se as xs:string, $sortopt as element(search:sort-order)*) as element(search:options) {
    <search:options>
        <search:searchable-expression>{$se}</search:searchable-expression>
        <search:return-qtext>true</search:return-qtext>
        <search:return-facets>false</search:return-facets>
        <search:debug>true</search:debug>
        <search:term>
            <search:empty apply="no-results" />
            <search:term-option>case-insensitive</search:term-option>
            <search:term-option>diacritic-insensitive</search:term-option>
            <search:term-option>punctuation-insensitive</search:term-option>
            <search:term-option>whitespace-insensitive</search:term-option>
            <search:term-option>stemmed</search:term-option>
        </search:term>
        {$sortopt}
    </search:options>
};

declare function lq:tohap-tei-snippet($result as node()) as element((:search:snippet:))? {
    let $cts := <blah>{lq:get-highlight-query()}</blah>	
    let $transform := 
          <transform-results apply="snippet" xmlns="http://marklogic.com/appservices/search">
              <per-match-tokens>30</per-match-tokens>
              <max-matches>80000</max-matches>
              <max-snippet-chars>15000000</max-snippet-chars>
              <preferred-elements>
                  <element name="sp" ns="http://www.tei-c.org/ns/1.0"/>
                  <element name="titleInfo" ns="http://www.loc.gov/mods/v3"/>
                  <element name="abstract" ns="http://www.loc.gov/mods/v3"/>
              </preferred-elements>
          </transform-results>
    let $snip:=search:snippet($result, $cts/element(), $transform)
    return
        if ($snip//search:highlight) then
            $snip
        else 
            ()
};

declare function lq:filter-snippets($result as element(search:snippet), $filter as xs:string) as element(search:snippet) {
    let $matches :=
        for $match in $result/search:match
        where contains($match/@path/string(), $filter)
        return
            $match
    return
        if (count($matches) gt 0) then
            <search:snippet>{$matches}</search:snippet>
        else
            <search:snippet/>
};

(:
Search on each djvu:PAGECOLUMN (or single PAGECOLUMN) (which contains WORD elements) for word or phrase and highlight words
$pnum is for a single page search triggered from Seadragon
$page is the current page of results a user has requested
$images_per_page is the total number of images to show per page (e.g. 10)
:)
declare function lq:djvu-search-results($uri as xs:string, $pnum as xs:string?, $page as xs:string, $images_per_pages as xs:integer, $barcode as xs:string) as element()* {
    let $doc := concat("/lscoll/fulltext/ia/djvu/",$uri,".xml") (: need to change if/when collection location changes :)
    let $query := lq:get-highlight-query()
    
    let $search :=
        if (exists($pnum)) then
            cts:search(//djvu:PAGECOLUMN[@n=$pnum and @gid=$barcode], cts:and-query(($query, cts:document-query($doc))) )
        else
            let $start := (xs:integer($page) - 1)*$images_per_pages+1
            let $end := $start + $images_per_pages - 1
            return cts:search(//djvu:PAGECOLUMN, cts:and-query(($query, cts:document-query($doc))) )[$start to $end]
    
    for $z in $search
    let $found := cts:highlight($z, $query, <found_word>{$cts:text}</found_word>)
    return $found 
};

declare function lq:djvu-search-count($uri as xs:string) as xs:unsignedLong {
    let $doc := concat("/lscoll/fulltext/ia/",$uri,".xml") (: need to change if/when collection location changes :)
    let $query := lq:get-highlight-query()
    let $search := cts:search(//PAGECOLUMN, cts:and-query(($query, cts:document-query($doc))) )
    return count($search)
};