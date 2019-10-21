xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight" at "/nlc/lib/l-highlight.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/xq/modules/config/materialtype.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace pb = "info:lc/xq-modules/config/profile-behaviors" at "/xq/modules/config/profile-behaviors.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin"at "/xq/modules/natlibcat-skin.xqy";
declare namespace lcvar = "info:lc/xq-invoke-variable";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mat = "info:lc/xq-modules/config/materials";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace l = "local";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace param = "http://www.marklogic.com/ps/params";

(: http://marklogic3.loc.gov/loc.natlib.tohap.H0201.mets.xml:)

(: Getting the q param here should provide us with an unescaped URI for the ampersand issue :)
let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q')
let $sortorder as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'sort', 'score-desc')        
let $collection := lp:get-param-single($lp:CUR-PARAMS, 'collection')
let $cln as xs:string? := if(not($collection) or ($collection eq "all")) then 
        $cfg:DEFAULT-COLLECTION 
    else 
        $collection
let $mypage := lp:get-param-integer($lp:CUR-PARAMS, 'pg', 1)
let $count := lp:get-param-integer($lp:CUR-PARAMS, 'count' , $cfg:RESULTS-PER-PAGE)
let $longcount := if($count = (10, 25, $cfg:RESULTS-PER-PAGE)) then $count else $cfg:RESULTS-PER-PAGE
let $longstart := (($mypage * $longcount) + 1) - $longcount
let $start := $longstart
let $end := ($start - 1 + $longcount)
let $query := lq:query-from-params($lp:CUR-PARAMS)  

let $_ := xdmp:log(concat("query: ", xdmp:describe($query)),'debug')

let $mets :=
        (
            for $result in cts:search(collection($cln), $query, "unfiltered")
            order by cts:score($result) descending, $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
            return
                $result
        )[1]
 return
     lq:tohap-tei-snippet($mets)