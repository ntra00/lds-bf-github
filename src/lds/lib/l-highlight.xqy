xquery version "1.0-ml";

module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/lds/lib/l-query.xqy";
declare namespace search = "http://marklogic.com/appservices/search";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare default collation "http://marklogic.com/collation/en/S1";

declare function lh:highlight-query($x as node()) {
    cts:or-query( cts:query($x//cts:word-query) ) 
};

(: unused :)
declare function lh:highlight-query-old($x as node()) {

    (: The strict XPath from vr:render() breaks the use of cts:element-range-query for getting exact hits in the precision=exact search results as pointed to from the browse page. :)
    (: Necessitated change in lh:highlight-query(), lq:query-from-params(), and vr:render() to use cts:element-range query. :)
    (: Had been cts:element-value-query :)
    (: See Danny Sokolsky at http://www.mail-archive.com/general@developer.marklogic.com/msg02325.html                      :)

    typeswitch ($x) 
        case text() return $x
        case element(cts:or-query) 
          return
            (: if (not(empty($x/cts:element-value-query))) then () :)
            if (not(empty($x/cts:element-range-query))) then ()
            else element {node-name($x)} {$x/lh:highlight-query($x/node())}  
        case element(cts:element-query) 
            return
                lh:highlight-query(($x/node())[local-name(.) ne "element"]) 
        (:case element(cts:element-value-query) return ():)
        case element(cts:element-range-query) return ()
        case element(cts:element-word-query) 
           return
                <cts:word-query>
                    <cts:text xml:lang="{string($x/cts:text/@xml:lang)}">
                        {replace($x/cts:text/text(), '"', '')}  
                    </cts:text>
                </cts:word-query>
        case element() return element {node-name($x)} {$x/lh:highlight-query($x/node())}
        default return $x 
};


declare function lh:highlight-bib-results($x as node(), $filter, $q as cts:query) {
    typeswitch ($x) 
        case text() return $x
        case element (h1) return
           if ($x/@id eq "title-top" and (($filter = "idx:titleLexicon") or (empty($filter)))) then
              cts:highlight($x, $q, <span class="highlt">{$cts:text}</span>)
           else $x
        case element(dd) return 
           if (empty($filter) and starts-with($x/@class, "bibdata")) then
              cts:highlight($x, $q, <span class="highlt">{$cts:text}</span>)
           else if ($filter eq "idx:titleLexicon" and string($x/@class) eq "bibdata-title")  then
              cts:highlight($x, $q, <span class="highlt">{$cts:text}</span>)      
           else if ($filter eq "idx:subjectLexicon" and $x/@class eq "bibdata-subject") then
              cts:highlight($x, $q, <span class="highlt">{$cts:text}</span>) 
           else if ($filter eq "idx:mainCreator" and string($x/@class) eq "bibdata-name") then
              cts:highlight($x, $q, <span class="highlt">{$cts:text}</span>)
           else $x
        case element() return element {node-name($x)} 
                                      {for $a in $x/attribute() return $a, 
                                       for $z in $x/node() return lh:highlight-bib-results($z, $filter, $q)}
        default return $x 
};

declare function lh:tei-highlight($tei as element(tei:TEI)) as node() {
    (:let $queryString  := lq:query-from-params($lp:CUR-PARAMS):)
(:uses an "or" query so that if terms in q are found outside of tei, the tei found terms are still highlighted:)     
    let $queryString  :=lq:get-highlight-query()
    return 
        cts:highlight($tei, $queryString, <span class="highlt">{$cts:text}</span>)
        
};


declare function lh:snippet-highlight($zz as element(search:match)) {
    for $node in $zz/node()
    return
        typeswitch($node)
              case element(search:highlight) 
                return <span class="highlt">{data($node)}</span> 
              case text() 
                return $node 
              default
                return xs:string($node)
};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)