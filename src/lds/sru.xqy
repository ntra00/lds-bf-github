xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace sru-utils = "info:lc/xq-modules/sru-utils" at "/xq/modules/sru-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
declare namespace sru = "http://docs.oasis-open.org/ns/search-ws/sruResponse";
declare namespace diag = "http://www.loc.gov/zing/srw/diagnostic/";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace zr = "http://explain.z3950.org/dtd/2.1/";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare namespace mlhttp = "xdmp:http";
declare namespace idx = "info:lc/xq-modules/lcindex";

let $mime := "application/sru+xml"
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $collection as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'collection', $cfg:DEFAULT-COLLECTION)
let $cln as xs:string? := "/lscoll/lcdb/bib/"
    (:if($collection eq "all") then 
        $cfg:DEFAULT-COLLECTION 
    else 
        $collection:)
let $operation as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'operation', 'searchRetrieve')
let $version as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'version', '1.2')
let $term as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'query')
let $start as xs:integer? := lp:get-param-integer($lp:CUR-PARAMS, 'startRecord', 1)
let $max as xs:integer? := lp:get-param-integer($lp:CUR-PARAMS, 'maximumRecords', 10)
let $pack as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'recordPacking', 'xml')
let $schema as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'recordSchema', 'info:srw/schema/1/marcxml-v1.1' (:'info:srw/schema/1/mods-v3.3':))
let $ttl as xs:integer? := lp:get-param-integer($lp:CUR-PARAMS, 'resultSetTTL', 0)
let $stylesheet as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'resultSetTTL')
let $extra-request as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'extraRequestData')
let $end := $start + $max
return
    (:xdmp:log(xdmp:quote($lp:CUR-PARAMS), 'error'):)
    if (matches($operation, "scan|searchRetrieve|explain") and $version eq '1.2' and string-length($term) gt 0) then
            let $query := lq:query-from-params($lp:CUR-PARAMS)
            let $_ := xdmp:log(concat("query: ", xdmp:describe($query)),'debug')
            let $results :=
                (
                    for $result in cts:search(collection($cln), $query, "unfiltered")
                    order by cts:score($result) descending, $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
                    return
                        $result
                )[$start to $end]
            let $srumets := $results/mets:mets
            let $sruestimate := (cts:remainder($results[1]) + $start)
            return
                (
                    xdmp:set-response-content-type(concat("text/xml", "; charset=utf-8")), 
                    xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                    xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                    xdmp:add-response-header("Expires", resp:expires($duration)),
                    '<?xml version="1.0" encoding="UTF-8"?>',
                    sru-utils:serialize-mets($srumets, $version, $schema, $pack, $start, $max, $sruestimate) 
                )
    else
        let $msg := "Must have a valid query term in the query param, version param equal to '1.2', and operation param equal to 'scan', 'searchRetrieve', or 'explain'."
        return (xdmp:set-response-code(400, "Bad Request"), xdmp:set-response-content-type(concat("text/html", "; charset=utf-8")), $msg)