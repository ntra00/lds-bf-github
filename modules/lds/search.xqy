xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/lds/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace vr = "http://www.marklogic.com/ps/view/v-result" at "/lds/view/v-result.xqy";
import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at "/lds/view/v-facets.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/lds/view/v-search.xqy";
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
declare namespace sru = "http://docs.oasis-open.org/ns/search-ws/sruResponse";
declare namespace diag = "http://docs.oasis-open.org/ns/search-ws/diagnostic";
declare namespace zr = "http://explain.z3950.org/dtd/2.1/";
declare namespace param = "http://www.marklogic.com/ps/params";
declare namespace idservice="http://id.loc.gov/ns/id_service#";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function local:html($msie as xs:boolean, $searchres as element(div), $facets as element(div)*, $searchterm as xs:string?, $url-prefix as xs:string?) as element(html) {
    let $searchtitle := 
        if ($searchterm) then
            concat("Results for &quot;", <strong>{$searchterm}</strong>,"&quot;")
        else
            "Search"
    let $crumbs := <span class="ds-searchresultcrumb">Search Results</span>
    let $atom := 
        if (lp:get-param-single($lp:CUR-PARAMS, 'q')) then
            let $newparam := lp:param-replace-or-insert($lp:CUR-PARAMS, "mime", "application/atom+xml")
            return
                concat($url-prefix,"search.xqy?", lp:param-string($newparam))
        else
            ()
    let $seo := ()
    (: $uri (last ssk:header param) is for share tool printing of a single item; doesn't apply to search results:)
    let $myhead := ssk:header($searchtitle, $crumbs, $msie, $atom, $seo, "","results")
    let $site-title:=$cfg:MY-SITE/cfg:label/string()
    let $searchbar :=
        <div id="search-results">
            {vs:render()}
        </div>
let $suggest:=local:suggest($searchterm)
    return
        <html xmlns="http://www.w3.org/1999/xhtml">
            {$myhead/head}
            <body>
                {$myhead/body/div}
                <div id="ds-container">
                    <div id="ds-body">						
					<div id="page_head">			
                       {$searchbar}
						<h1>{$site-title}<br/><span>{$searchtitle}</span></h1>
						{$suggest}
					</div>
                    {$facets[2]}
                    <div id="ds-colcontainer">
                            <div id="dsresults" class="ds-column dsresults">                                
                                {$searchres}
                            </div>
                            <div id="ds-leftcol" class="ds-column">
                                <div id="ds-facets">
                                    <h2 id="section-title">Refinements</h2>
                                    {$facets[1]}
                                    <!-- end id:ds-facets -->
                                </div>
                            <!-- end id:ds-leftcol -->
                            </div>
                        </div>
                    </div>
                <!-- end id:ds-container -->
                </div>							
                {ssk:feedback-link(false())}			   
                {ssk:footer()/div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
};
declare function local:suggest($searchterm as xs:string) as element(div) {
(: Begin kefo addition :)
    let $idurl := "http://id.loc.gov/authorities/"
let $qname:=lp:get-param-single($lp:CUR-PARAMS, 'qname')
    let $dymqname := 
        if ($qname = "idx:subjectLexicon") then
            "idx:subjectLexicon"
        else if ($qname = "idx:mainCreator" or lp:get-param-single($lp:CUR-PARAMS, 'qname') = "idx:byName") then
            "idx:mainCreator"
        else if ($qname = "idx:titleLexicon") then
            "idx:uniformTitle"
        else 
            ""

    let $didyoumeanresponse :=
        if (lp:get-param-single($lp:CUR-PARAMS, 'lref') = "dym") then
            ()
        else
            if ( $qname = "idx:subjectLexicon"    ) then
                xdmp:http-get( fn:concat($idurl , "subjects/didyoumean/?label=" , xdmp:url-encode($searchterm) , "&amp;rdftype=Topic&amp;rdftype=Temporal&amp;rdftype=Geographic&amp;rdftype=GenreForm") )
            else if ( $qname = "idx:mainCreator" or 
                      $qname = "idx:byName") then
                    xdmp:http-get( fn:concat($idurl , "names/didyoumean/?label=" , xdmp:url-encode($searchterm) , "&amp;rdftype=PersonalName&amp;rdftype=CorporateName") )
            else if ( $qname = "idx:titleLexicon"     ) then
                xdmp:http-get( fn:concat($idurl , "names/didyoumean/?label=" , xdmp:url-encode($searchterm) , "&amp;rdftype=Title") )
            else ()

    let $didyoumean := 
        if ( fn:count($didyoumeanresponse) = 2 and $didyoumeanresponse//idservice:service/@search-hits ne 0) then
			let $dymset:=
                  for $dym in $didyoumeanresponse[2]/idservice:service/idservice:term[1 to 10]
					let $est:=cts:remainder(cts:search(/, cts:element-range-query(xs:QName( $dymqname), "=",  $dym, 
											("collation=http://marklogic.com/collation/en/S1")))[1])
                    return  if($est) then
                        (  <span style="margin-left: 10px;"><a href="/lds/search.xqy?q={xs:string($dym)}&amp;qname={$qname}&amp;lref=dym">{xs:string($dym)}</a> (<span class="hits">{$est}</span>) </span>       )
						else ()
			return if ($dymset) then
			            <div style="position: relative; left: 30px;">  
			                <strong>Did you mean?</strong>
							{$dymset[1 to 4]}
			            </div>
					else ()
        else 
            ()
            
    let $alsoseeresponse := 
        if ($qname = "idx:subjectLexicon") then
            xdmp:http-get( fn:concat($idurl , "subjects/alsosee/?label=" , xdmp:url-encode($searchterm) , "&amp;rdftype=Topic&amp;rdftype=Temporal&amp;rdftype=Geographic&amp;rdftype=GenreForm") )
        else if ($qname = "idx:mainCreator" or lp:get-param-single($lp:CUR-PARAMS, 'qname') = "idx:byName") then
            xdmp:http-get( fn:concat($idurl , "names/alsosee/?label=" , xdmp:url-encode($searchterm) , "&amp;rdftype=PersonalName&amp;rdftype=CorporateName") )
        else if ($qname = "idx:titleLexicon") then
            xdmp:http-get( fn:concat($idurl , "names/alsosee/?label=" , xdmp:url-encode($searchterm) , "&amp;rdftype=Title") )
        else ()
    let $alsosee := 
        if ( fn:count($alsoseeresponse) = 2 and $alsoseeresponse//idservice:service/@search-hits ne 0) then
			let $alsoset:=
				for $as in $alsoseeresponse/idservice:service/idservice:term[1 to 10]
					let $est:=cts:remainder(cts:search(/, cts:element-range-query(xs:QName( $qname), "=",  concat("&quot;",$as/string(),"&quot;"), 
											("collation=http://marklogic.com/collation/en/S1")))[1])
                    return if ($est) then
                        (        <span style="margin-left: 10px;"><a href="/lds/search.xqy?q=&quot;{xs:string($as)}&quot;&amp;qname={$qname}">{xs:string($as)}</a>({$est})</span>                          )
						else ()
			return if ($alsoset) then
			            <div style="position: relative; left: 30px;">  
			                <strong>Also see:</strong>
			                {  $alsoset[1 to 4]         }
			            </div>
				  else 
					()
        else 
            ()
return 
          <div class="suggest">
            {$didyoumean}
            {$alsosee}
          </div>

    (: End kefo addition :)
};
(: input parameters :)
let $page := "search"
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

let $_ := xdmp:log(concat("query: ", xdmp:describe($query)),'debug')
let $results := 
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
        (for $result in cts:search(collection($cln), $query,"unfiltered") return $result)[$start to $end]
return
    if (matches($mime, "(application/xhtml\+xml|text/html)")) then
        let $searchres :=
            <div id="results">
                {
                    let $elapsed := round-half-to-even(seconds-from-duration(xdmp:elapsed-time() cast as xs:duration), 3)
                    return
                        vr:render($results, $start, $elapsed, $longstart, $longcount, $term)               
                }
            </div>
        let $facets :=
            if (exists($cfg:DISPLAY-ELEMENTS//*:elt/*:page[text() = $page])) then
                let $topf :=
                    for $f in $lp:CUR-PARAMS/param:param/param:name
                    let $fval := $f/following-sibling::param:value/string()
                    let $params := $f/ancestor::param:params
                    let $fstr := $f/string()
                    let $newparams := 
                        if (matches($fstr, 'ft\d+a')) then
                            lp:param-remove-all-multi($params, ($fstr, replace($fstr, '(ft\d+)a', '$1b'), replace($f, '(ft\d+)a', '$1c')))
                        else if (matches($fstr, 'ft\d+b')) then
                            lp:param-remove-all-multi($params, ($fstr, replace($fstr, '(ft\d+)b', '$1c')))
                        else
                            lp:param-remove($params, $fstr, $fval)
					let $newparams:=lp:param-remove-all($newparams,"branding")
					let $newparams:=lp:param-remove-all($newparams,"collection")
					
                    let $myhref := concat($url-prefix,"search.xqy?", lp:param-string($newparams))
                    where matches($fstr, 'ft?\d+[a-z]?')
                    return
                        if (count($f) gt 0) then
                            <span class="facet">
                                <img src="/static/natlibcat/images/arrow.gif" alt="&gt;" class="facet-arrow" />
                                {$fval}&nbsp;
                                <span class="cssnav">
                                    <a href="{$myhref}" title="Remove Facet: [{$fval}]">
                                        <img src="/static/natlibcat/images/facet-on.gif" alt="Remove Facet" />
                                    </a>
                                </span>
                            </span>
                        else
                            ()
                let $yoursearch :=
                    (:if ($term) then
                        <span class="your-search">Refined by:</span>
                    else
                        <span class="your-search"><!--Search results-->Refined by:</span>:)
						  if ($topf) then
						  <span class="your-search">Refined by:</span>
                    else
                        ()
                let $topfacets :=
                    <div id="ds-facetvalues">
                        {$yoursearch}
                        {$topf}
                    </div>
                return
                    (<div id="facet-results">{vf:facets($page)}</div>, $topfacets)
            else
                ()
        return
            (
                xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
                xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                xdmp:add-response-header("Expires", resp:expires($duration)),
                $doctype,
                local:html(false(), $searchres, $facets, $term,$url-prefix)
            )
    else if ($mime eq "application/json") then
        "{}"
    else if ($mime eq "application/sru+xml") then
        let $srumets := $results/mets:mets
        let $ver := "1.2"
        let $schema := "info:srw/schema/1/mods-v3.3"
        let $pack := "xml"
        let $srustart := $start
        let $srumax := $longcount
        let $sruestimate :=
            if ($mypage eq 1) then
                cts:remainder($results[1])
            else
                (cts:remainder($results[1]) + (($mypage - 1) * $longcount))
        return
            sru-utils:serialize-mets($srumets, $ver, $schema, $pack, $srustart, $srumax, $sruestimate)
    else if (matches($mime, "application/(atom|rss)\+xml")) then
        (
            xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
            xdmp:add-response-header("Expires", resp:expires($duration)),
            feed:mets-to-atom($results, $term)
        )
    else if (matches($mime, "(application/x-lcsearchresults\+xml|text/xml|application/xml)")) then
        $results
    else
        let $msg := "You must specify a valid mime-type for serialization"
        return
            (xdmp:set-response-code(400, "Bad Request"), xdmp:set-response-content-type(concat("text/html", "; charset=utf-8")), $msg)
