xquery version "1.0-ml";

import module namespace search="http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";    
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
(:import module namespace vr = "http://www.marklogic.com/ps/view/v-result" at "/nlc/view/v-result.xqy";
import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at "/nlc/view/v-facets.xqy";:)
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/nlc/view/v-search.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace feed = "info:lc/xq-modules/atom-utils" at "/xq/modules/atom-utils.xqy";
import module namespace sru-utils = "info:lc/xq-modules/sru-utils" at "/xq/modules/sru-utils.xqy";
declare namespace qm="http://marklogic.com/xdmp/query-meters";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
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
declare namespace djvu = "http://www.loc.gov/djvu";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace sru = "http://docs.oasis-open.org/ns/search-ws/sruResponse";
declare namespace diag = "http://docs.oasis-open.org/ns/search-ws/diagnostic";
declare namespace zr = "http://explain.z3950.org/dtd/2.1/";
declare namespace param = "http://www.marklogic.com/ps/params";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: input parameters :)
let $page := "advanced"
let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', "text/html"))
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $mypage := lp:get-param-integer($lp:CUR-PARAMS, 'pg', 1)
(: Getting the q param here should provide us with an unescaped URI for the ampersand issue :)
let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q')
let $sortorder as xs:string? := lp:get-param-single($lp:CUR-PARAMS,'sort','score-desc')
let $branding:=$cfg:MY-SITE/cfg:branding/string()
let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
let $collection:=$cfg:MY-SITE/cfg:collection/string()
 let $cln as xs:string? := 
        if($collection eq "all") then 
            $cfg:DEFAULT-COLLECTION 
        else 
            $collection
let $count := lp:get-param-integer($lp:CUR-PARAMS,'count',$cfg:RESULTS-PER-PAGE)        
let $longcount := if($count = (10,25,$cfg:RESULTS-PER-PAGE)) then $count else $cfg:RESULTS-PER-PAGE
let $longstart := (($mypage * $longcount) + 1) - $longcount
let $start := $longstart
let $end := ($start - 1 + $longcount)
let $query := lq:query-from-params($lp:CUR-PARAMS)  
let $_ := xdmp:log(concat("query: ", xdmp:describe($query)), 'debug')
(:let $results := 
    if ($sortorder eq "score-desc") then
        (
            for $result in cts:search(collection($cln), $query,"unfiltered")
            order by cts:score($result) descending, $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
            return
                $result
        )[$start to $end]
    else if ($sortorder eq "score-asc") then
        (
            for $result in cts:search(collection($cln), $query,"unfiltered")
            order by cts:score($result) ascending, $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
            return
                $result
        )[$start to $end]
    else if ($sortorder eq "pubdate-asc") then
        (
            for $result in cts:search(collection($cln), $query,"unfiltered")
            order by $result//idx:pubdateSort descending collation "http://marklogic.com/collation/en/S1", $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
            return
                $result
        )[$start to $end]
    else if ($sortorder eq "pubdate-desc") then
        (
            for $result in cts:search(collection($cln), $query,"unfiltered")
            order by $result//idx:pubdateSort ascending collation "http://marklogic.com/collation/en/S1", $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
            return
                $result
        )[$start to $end]
    else if ($sortorder eq "cre-asc") then
        (
            for $result in cts:search(collection($cln), $query,"unfiltered")
            order by $result//idx:mainCreator ascending collation "http://marklogic.com/collation/en/S1", $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
            return
                $result
        )[$start to $end]
    else if ($sortorder eq "cre-desc") then
        (
            for $result in cts:search(collection($cln), $query,"unfiltered")
            order by $result//idx:mainCreator descending collation "http://marklogic.com/collation/en/S1", $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
            return
                $result
        )[$start to $end]
    else
        (for $result in cts:search(collection($cln), $query,"unfiltered") return $result)[$start to $end]:)



let $grammar :=
    <grammar xmlns="http://marklogic.com/appservices/search">
        <quotation>"</quotation>
        <implicit>
            <cts:and-query strength="20" xmlns:cts="http://marklogic.com/cts"/>
        </implicit>
        <starter strength="30" apply="grouping" delimiter=")">(</starter>
        <starter strength="40" apply="prefix" element="cts:not-query">NOT</starter>
        <joiner strength="10" apply="infix" element="cts:or-query" tokenize="word">OR</joiner>
        <joiner strength="20" apply="infix" element="cts:and-query" tokenize="word">AND</joiner>
        <joiner strength="30" apply="infix" element="cts:near-query" tokenize="word">NEAR</joiner>
        <joiner strength="30" apply="near2" element="cts:near-query">NEAR/</joiner>
        <joiner strength="50" apply="constraint">:=</joiner>
        <joiner strength="50" apply="constraint" compare="LT" tokenize="word">LT</joiner>
        <joiner strength="50" apply="constraint" compare="LE" tokenize="word">LE</joiner>
        <joiner strength="50" apply="constraint" compare="GT" tokenize="word">GT</joiner>
        <joiner strength="50" apply="constraint" compare="GE" tokenize="word">GE</joiner>
        <joiner strength="50" apply="constraint" compare="NE" tokenize="word">NE</joiner>
    </grammar>      

let $opts := 
    <options xmlns="http://marklogic.com/appservices/search">
        {$grammar}
        <debug>true</debug>
        <term>
            <term-option>case-insensitive</term-option>
            <term-option>diacritic-insensitive</term-option>
            <term-option>punctuation-insensitive</term-option>
            <term-option>whitespace-insensitive</term-option>
            <term-option>stemmed</term-option>
            <term-option>wildcarded</term-option>
        </term>
        <constraint name="KPUB">
            <word>
                <element ns="info:lc/xq-modules/lcindex" name="pubinfo"/>
            </word>
        </constraint>
        <constraint name="KSUB">
            <word>
                <element ns="info:lc/xq-modules/lcindex" name="subjectLexicon"/>
            </word>
        </constraint>
        <constraint name="KURL">
            <word>
                <element ns="http://www.loc.gov/mxe" name="d856_subfield_u"/>
            </word>
        </constraint>
        <constraint name="KSGE">
            <word>
                 <element ns="info:lc/xq-modules/lcindex" name="aboutPlace"/>
            </word>
        </constraint>
        <constraint name="KPNC">
            <custom facet="false">
                <parse apply="constraint-kpnc" ns="info:lc/xq-modules/constraints/" at="/nlc/lib/l-constraints.xqy"/>
            </custom>
        </constraint>
        <constraint name="K010">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="lccn"/>
            </value>
        </constraint>
        <constraint name="KNUM">
            <value>
                <element ns="info:lc/xq-modules/lcindex" name="identifier"/>
            </value>
        </constraint>
        <constraint name="KISN">
            <custom facet="false">
                <parse apply="constraint-kisn" ns="info:lc/xq-modules/constraints/" at="/nlc/lib/l-constraints.xqy"/>
            </custom>
        </constraint>
    </options>

let $q1 := "istanbul NEAR/3 constantinople AND (turk* OR asia) NOT (iran OR iraq)"
let $q2 := '(KPNC:="Paine, Thomas" OR KPNC:=Chalmers) AND KNUM:=04016003'
let $q3 := 'KISN:=0022-3727 '
let $kpub := "KPUB:=John Stockdale AND KSUB:=Paine"
let $kurl := "KURL:=cph.3a16729"
let $ksge := "Pi︠a︡tigorsk Region (Russia)"
let $begin := 1
let $end := 10
return
(:   The following do the same thing, just different in that the first is search API and the latter is straight cts :)
search:search($ksge, $opts, $begin, $end)
(:(cts:search(collection(), cts:query(search:parse($q2, $opts))))[$begin to $end] :)