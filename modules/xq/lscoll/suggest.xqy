xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace myapp = "http://www.marklogic.com/myapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace idx = "info:lc/xq-modules/lcindex";

declare default collation "http://marklogic.com/collation/en/S1";

let $term as xs:string? := normalize-space(xdmp:get-request-field('term', ()))
let $qname as xs:string? := normalize-space(xdmp:get-request-field('qname', "idx:titleLexicon"))
let $num-suggestions := 10

let $tokens := tokenize($term, " ")
let $len := count($tokens)
let $all-but-last := string-join($tokens[1 to ($len - 1)], " ")
let $last-term := $tokens[$len]

(:let $query := lq:get-last-query()
let $andq := cts:and-query((cts:collection-query($cfg:DEFAULT-COLLECTION), $query)):)

let $matches := 
    if($last-term eq "") then 
        () 
    else
        let $_ := xdmp:log(concat("suggestions for: ", $last-term), 'debug')
        return
            cts:element-word-match(xs:QName($qname), concat($last-term, "*"), ("case-insensitive", "diacritic-insensitive", "ascending", "collation=http://marklogic.com/collation/en/S1"))[1 to $num-suggestions]
return
    (xdmp:set-response-content-type("text/plain"), xdmp:set-response-encoding("UTF-8"), string-join(for $match in $matches return normalize-space(string-join(($all-but-last,$match)," ")), ", "))