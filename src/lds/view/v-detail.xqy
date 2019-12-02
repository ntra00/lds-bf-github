xquery version "1.0-ml";

module namespace vd = "http://www.marklogic.com/ps/view/v-detail";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "../config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "../lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "../lib/l-param.xqy";
import module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight" at "../lib/l-highlight.xqy";
import module namespace md = "http://www.marklogic.com/ps/model/m-doc" at "../model/m-doc.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin"at "../../xq/modules/natlibcat-skin.xqy";
import module namespace mem = "http://xqdev.com/in-mem-update" at "../../xq/modules/in-mem-update.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "../../xq/modules/mets-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace bf            	= "http://id.loc.gov/ontogies/bibframe/";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace index="info:lc/xq-modules/lcindex";
declare namespace lcvar="info:lc/xq-invoke-variable";
declare namespace madsrdf="http://www.loc.gov/mads/rdf/v1#";
(: Begin kefo addition :)
declare namespace httpget = "xdmp:http";
(: End kefo addition :)
declare function vd:filter-results($searchfilter as xs:string, $url-prefix as xs:string, $program  as xs:string) as element (div){

let $workparams := $lp:CUR-PARAMS
        let $workparams := lp:param-remove-all($workparams, "filter")
		let $workparams := lp:param-replace-or-insert($workparams, "filter", "works")
		let $workparams := lp:param-remove-all($workparams, "pg")
		let $workparams := lp:param-remove-all($workparams, "index")
		let $workparams := lp:param-remove-all($workparams, "branding")
		let $workparams := lp:param-remove-all($workparams, "collection")
        let $workfilter := lp:param-string($workparams)
		let $works := 
            if ($searchfilter ne "works") then
                <li  style="display:inline;" ><a rel="nofollow"  href="{concat($url-prefix,$program,".xqy?",$workfilter)}">Works </a></li>
            else
                <li  style="display:inline;" >Works</li>
      	
        let $instanceparams := lp:param-remove-all($workparams, "filter")
		let $instanceparams := lp:param-replace-or-insert($workparams, "filter", "instances")
		

        let $instancefilter := lp:param-string($instanceparams)
			let $instances := 
            if ($searchfilter ne "instances") then
                <li  style="display:inline;" ><a rel="nofollow"  href="{concat($url-prefix,$program,".xqy?",$instancefilter)}">Instances </a></li>
            else
                <li  style="display:inline;" >Instances</li>
		
		let $itemparams := lp:param-remove-all($workparams, "filter")
		let $itemparams := lp:param-replace-or-insert($workparams, "filter", "items")
		
        let $itemfilter := lp:param-string($itemparams)
			let $items := 
            if ($searchfilter ne "items") then
                <li  style="display:inline;"><a rel="nofollow"  href="{concat($url-prefix,$program,".xqy?",$itemfilter)}">Items</a></li>
            else
                <li  style="display:inline;" >Items </li>
		let $stubparams := lp:param-remove-all($workparams, "filter")
		let $stubparams := lp:param-replace-or-insert($workparams, "filter", "stubs")
		
        let $stubfilter := lp:param-string($stubparams)
			let $stubs := 
            if ($searchfilter ne "stubs") then
                <li  style="display:inline;"><a rel="nofollow"  href="{concat($url-prefix,$program,".xqy?",$stubfilter)}">Stubs</a></li>
            else
                <li  style="display:inline;" >Stubs</li>
		let $allparams := lp:param-remove-all($workparams, "filter")
		let $allparams := lp:param-replace-or-insert($workparams, "filter", "all")
		
        let $allfilter := lp:param-string($allparams)
			let $allobjects := 
            if ($searchfilter ne "all") then
                <li  style="display:inline;"><a rel="nofollow"  href="{concat($url-prefix,$program,".xqy?",$allfilter)}">All objects</a></li>
            else
                <li  style="display:inline;" >All objects</li>
				
  return            
          <div id="results">  <ul id="pagination-clean" style="background-color: #F0F0F0;">{$works}{$instances}{$items}{$stubs}{$allobjects}</ul></div>
			(:<span style="text-align:left;outline:gray;">{$works}{$instances}{$items}{$allobjects}</span>:)

};
(: if you call render w/o "simple", it redirects with "" as the source (plain bf rdf) :)
declare function vd:render($perm_uri as xs:string) {
vd:render($perm_uri,"")
};
(: if you call render w/o a uri, it redoes  and displays the current search , offset at viewindex
:  actually, there are only 2 mets docs in results at a time; controlled by prev/next, viewindex
:)
declare function vd:render($perm_uri as xs:string, $source_rdf as xs:string) {

    let $viewindex := lp:get-param-integer($lp:CUR-PARAMS, 'index', 1)
	let $sparql-offset:=lp:get-param-integer($lp:CUR-PARAMS, 'offset', 0)
    let $sortorder as xs:string? := lp:get-param-single($lp:CUR-PARAMS,'sort','score-desc')
    
(:	let $path := xdmp:get-request-url():)
	let $branding:=$cfg:MY-SITE/cfg:branding/string()
	let $collection:=$cfg:MY-SITE/cfg:collection/string()
	
	let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
	
    let $cln as xs:string? := 
        if($collection eq "all") then 
            $cfg:DEFAULT-COLLECTION 
        else 
            $collection
	(: nate set to limit to works for now, need to add the collection optionally:)
	let $cln:="/resources/works/"
	let $cln:="/catalog/"
    let $prevint := $viewindex - 1
    let $nextint := $viewindex + 1
    
    let $query := lq:query-from-params($lp:CUR-PARAMS) 	
    let $est := 
        if ($perm_uri = '') then
            xdmp:estimate(cts:search(collection($cln), $query))
        else () (: maybe this should be a number? not that it really matters... rsin :)
    let $start :=
        if ($viewindex eq 1 or $prevint le 1) then
            1
        else
            $prevint     
    let $end :=
        if ($viewindex eq $est or $nextint gt $est) then
            $est
        else
            $nextint 
            
     let $res-index := 
        if( $start eq $end) then
            1
        else if ($start eq $viewindex) then
            1
        else if ($viewindex eq $end) then
            2
        else
           2

 (: this is identical in search.xqy... consolidate so they dont' get out of synch?? :)
    let $results := 
        if ($perm_uri = '') then			
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
                    (:order by $result//idx:pubdateSort ascending collation "http://marklogic.com/collation/en/S1", $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1":)
					order by $result//idx:mDate ascending collation "http://marklogic.com/collation/en/S1", $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
                    return
                        $result
                )[$start to $end]
            else if ($sortorder eq "pubdate-desc") then
                (
                    for $result in cts:search(collection($cln), $query,"unfiltered")
                    (:order by $result//idx:pubdateSort descending collation "http://marklogic.com/collation/en/S1", $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1":)
					order by $result//idx:mDate descending collation "http://marklogic.com/collation/en/S1", $result//idx:titleLexicon ascending collation "http://marklogic.com/collation/en/S1"
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
        else ()
	
	(:let $_ := xdmp:log(concat("query: ", xdmp:describe($query)),'info')	:)
		
    let $current_object :=
        if ($perm_uri = '') then
            $results[$res-index]            
        else
			utils:mets($perm_uri)
		 
    
    let $profile := string($current_object/mets:mets/@PROFILE)
    let $title := string($current_object/mets:mets//idx:titleLexicon)  
    let $uri := 
        if ($perm_uri = '') then
            string($results[$res-index]/mets:mets/@OBJID)
        else
            $perm_uri
    
        
    let $queryString := <x>{ lq:query-from-params($lp:CUR-PARAMS) }</x>/node()
    let $searchfilter := lp:get-param-single($lp:CUR-PARAMS, 'filter','all')(: works instances items all :)
    let $filter := lp:get-param-single($lp:CUR-PARAMS, 'qname')
    let $filter :=
        if($filter) then 
            if($filter eq "keyword") then 
                ()
            else 
                $filter
        else
            ()
                        
    let $highlight-query := lh:highlight-query($queryString)
    let $behavior := lp:get-param-single($lp:CUR-PARAMS, 'behavior', 'bfview')
     
 let $details :=      
	
		if (matches($uri,"(lcdb|africasets|erms|works|instances|items)"  ))   		(: $profile eq "lc:bibRecord":)  then
            let $pre-details := md:lcrenderBib($current_object, $uri, $sparql-offset, $source_rdf)
            return
				if ($pre-details instance of element(error:error)) then
                	$pre-details
				else
				    lh:highlight-bib-results($pre-details, $filter, $highlight-query)
        else
			if (matches($uri,"(lcwa|asian)") ) then			
			 let $pre-details := md:lcrenderMods($current_object)
            return
				if ($pre-details instance of element(error:error)) then
                	$pre-details
				else
				     lh:highlight-bib-results($pre-details, $filter, $highlight-query)
		else
            if ($behavior='default') then			
                lh:highlight-bib-results(md:renderDigital($current_object), $filter, $highlight-query)
            else
                md:renderDigital($current_object)
    
    (:not used??:)
	
    let $highlight-details := lh:highlight-bib-results($details, $filter, $highlight-query)
    

	let $print-link := ()
	    (:if ( not(contains($cfg:DISPLAY-SUBDOMAIN,"mlvlp01") )) then		
	        if ($behavior='bfview') then                    
	            <li><a class="print" target="_new" href="{concat($url-prefix,'print.xqy?uri=', $uri)}" title="Print Labeled Display">Print this item</a></li>
	        else 
	            <li><a class="print" target="_new" href="{concat($url-prefix,'print.xqy?uri=', $uri,'&amp;behavior=marctags')}" title="Print MARC Tagged Display">Print this item</a></li>

		else () :)

	let $seo := <meta>{$details//*:metatags}</meta>
    let $hostname:=  $cfg:DISPLAY-SUBDOMAIN
	(:let $doclink:=
			if ( contains($hostname,"mlvlp04") ) then
		       <a href="{concat("http://",$hostname,"/",$uri,".doc.xml")}">doc</a>
			else ()
	let $biblink:=
		 	if ( contains($hostname,"mlvlp04")  and contains($uri, ".c") ) then
				let $bibid:=fn:tokenize($uri,"\.")[fn:last()]				
				let $bibid:=fn:substring($bibid, 1,10)
				let $bibid:=fn:replace($bibid,"^c0+","")
					
		       return <a href="{concat("http://",$hostname,"/resources/bibs/",$bibid,".xml")}"> MARC </a>
			else if ( contains($hostname,"mlvlp04")  and contains($uri, ".n") ) then
			   <a href="{concat("http://",$hostname,"/",$uri,".marcxml.xml")}">MARC</a>
		
			else ()
	:)
	let $base-uri:=fn:base-uri($current_object)
	let $share-tool := if (  contains($hostname,"mlvlp04") ) then
								()
						else ssk:sharetool-div($uri, $title)	
    let $htmldiv :=
		if ($details instance of element(error:error)) then
			 $details
		else
            <div id="content-results">
                <div id="ds-bibrecord-nav">
                    <ul class="bibrecord-nav" style="background-color: #F0F0F0;line-height:2.0;">
                        { if ($perm_uri = '') then
                            let $backparams := lp:param-remove-all($lp:CUR-PARAMS, "index")
                            let $backparams := lp:param-remove-all($backparams, "pg")
                            let $backparams := lp:param-remove-all($backparams, "uri")
                            let $backparams := lp:param-remove-all($backparams, "itemID")
                            let $backparams := lp:param-remove-all($backparams, "dtitle") (: from browses:)
                            let $backparams := lp:param-remove-all($backparams, "behavior")
                            let $backparams := lp:param-remove-all($backparams, "branding")
                            let $backparams := lp:param-remove-all($backparams, "collection")
                            let $back := concat($url-prefix,"search.xqy?", lp:param-string($backparams))
                            
							let $nextparams := lp:param-replace-or-insert($lp:CUR-PARAMS, "index", $nextint)
                            (:let $nextparams := lp:param-replace-or-insert($nextparams, "uri", $urinext):)
                            let $nextparams := lp:param-remove-all($nextparams, "itemID")
                            let $nextparams := lp:param-remove-all($nextparams, "dtitle")(: from browses:)
                            let $nextparams := lp:param-remove-all($nextparams, "behavior")
                            let $nextparams := lp:param-remove-all($nextparams, "branding")
                            let $nextparams := lp:param-remove-all($nextparams, "collection")
                        
                            let $prevparams := lp:param-replace-or-insert($lp:CUR-PARAMS, "index", $prevint)
                            (:let $prevparams := lp:param-replace-or-insert($prevparams, "uri", $uriprev):)
                            let $prevparams := lp:param-remove-all($prevparams, "itemID")
                            let $prevparams := lp:param-remove-all($prevparams, "behavior")
                            let $prevparams := lp:param-remove-all($prevparams, "branding")
                            let $prevparams := lp:param-remove-all($prevparams, "collection")
                            let $prevdoc := lp:param-string($prevparams)
                            let $nextdoc := lp:param-string($nextparams)
							
							let $prev := 
                                if ($res-index gt 1) then
                                    <li><a rel="nofollow" class="previous" href="{concat($url-prefix,"detail.xqy?",$prevdoc)}">Previous</a></li>
                                else
                                    <li><span class="prev_off">Previous</span></li>
                            let $next := 
                                if ($viewindex ne $est) then
                                    <li><a  rel="nofollow"  class="next" href="{concat($url-prefix,"detail.xqy?",$nextdoc)}">Next</a></li>
                                else
                                    <li><span class="next_off">Next</span></li>

 							let $filterlinks:=vd:filter-results($searchfilter,$url-prefix, "detail")
							let $searchfilter-label := if($searchfilter="all") then "all objects" else $searchfilter
							
                            return
                                (<li><a id="backtoresults" class="back" href="{$back}">Back to results</a></li>,
                                $prev,
                                <li><span class="count">[<strong>{format-number($viewindex, "#,###")}</strong> of about <strong>{format-number($est, "#,###")}</strong>({$searchfilter-label})]</span></li>,
                               $next, $filterlinks//li
                                )
                         else ''
                         }
                        <!--<li>
                            {
                                if(contains($profile,"Record" )) then
                                	(:(contains($uri, ".lcdb."):)
                                	(:$profile eq "lc:bibRecord") then:)
                                
                                    if ($behavior eq 'default') then
                                        let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, 'behavior', 'marctags')
										let $new-params := lp:param-remove-all($new-params, "branding")
										let $new-params := lp:param-remove-all($new-params, "collection")
                                        let $marctags-toggle-title := "Toggle to MARC Tagged View"
                                        let $marctags-toggle-label := "View Tagged Display"
                                        let $marctags-toggle-url := concat($url-prefix,'detail.xqy?', lp:param-string($new-params))
                                        return                              
                                            <a class="marc" title="{$marctags-toggle-title}" href="{$marctags-toggle-url}">{$marctags-toggle-label}</a>
                                    else
                                        let $new-params :=  lp:param-remove-all($lp:CUR-PARAMS, 'behavior')
										let $new-params := lp:param-remove-all($lp:CUR-PARAMS, "branding")
										let $new-params := lp:param-remove-all($new-params, "collection")
                                        let $marctags-toggle-title := "Toggle to Labeled View"
                                        let $marctags-toggle-label := "View Labeled Display"
                                        let $marctags-toggle-url := concat($url-prefix,'detail.xqy?', lp:param-string($new-params))
                                        return
                                            <a class="labeled" title="{$marctags-toggle-title}" href="{$marctags-toggle-url}">{$marctags-toggle-label}</a>
                                else
                                    ()
                            }
                        </li>-->
                       <!--{$print-link}-->
					    <!-- <span style="float:right;"> {$biblink} || {$doclink} ||  [ {$base-uri} ]</span> -->
						<!--<span style="float:right;">{$share-tool}</span>-->
					                         <!-- <img src="http://covers.librarything.com/devkey/2ed454fd22af5dceef59b6069ed7c020/large/isbn/0545010225"/> -->
                    </ul>
    				
                <!-- end id:ds-bibrecord-nav -->			
                
				</div><span style="margin-left:20px;display:inline-block;"><p> </p>{$base-uri}
				<span id="detailURL" style="visibility:hidden">{$uri}</span></span>
								<!-- <span style="margin-left:5px;"> {$biblink} || {$doclink} || [ {$base-uri} ]</span>			  -->

                <!--{$details}-->	<!-- need metatags from marc ( check lccn???)-->
				
				   {if ($details//*:metatags) then  mem:node-delete($details//*:metatags) else $details } 
				 
                 
  
            </div>
          
    (: Begin kefo addition :)
    let $labelservice := "http://id.loc.gov/authorities/subjects/label/"
    let $subjects := $htmldiv//dd[@class="bibdata-subject"][1]//a
    let $subjects := 
        for $s in $subjects
        let $origstr := xs:string($s) 
        let $str := xs:string($s)
        let $str := 
            if ( fn:ends-with($str, ".") ) then
                fn:substring($str, 1, (fn:string-length($str) - 1))
            else
                $str
        let $str := fn:encode-for-uri( $str )
        let $url := fn:concat($labelservice , $str , ".rdf" )
        let $get := try {xdmp:http-get( $url )
						}
					catch ($e) { ()
					}
        let $rdf := 
            if ($get and xs:string($get[1]/httpget:code) = "302") then
                let $found := xs:string($get[1]/httpget:headers/httpget:location)
                let $request := xdmp:http-get($found)
                return $request[2]
            else ()
        let $relations := 
            <subject term="{$origstr}">
            {
            for $prop in $rdf/child::node()[fn:local-name()][1]/child::node()[fn:local-name()][1]/child::node()
            where fn:local-name($prop) = "hasBroaderAuthority" or fn:local-name($prop) = "hasNarrowerAuthority"  
            return 
                element relation {
                    attribute type {fn:local-name($prop)},
                    xs:string($prop/child::node()[fn:local-name()][1]/child::node()[fn:local-name() = "authoritativeLabel"][1])
                }
            }
            </subject>
        return $relations
    let $subjects := <subjects>{$subjects}</subjects>
(: limited narrowers to 10 (after sorting):)
    let $narrowers :=
        if ( $subjects/subject/relation/@type = "hasNarrowerAuthority" ) then
                (<h2>Search Narrower Subjects</h2>,
                <ul>
                    { let $ordered-set:=
							for $r in $subjects/subject/relation[@type="hasNarrowerAuthority"]
        			            order by $r 
							return $r
					for $r in $ordered-set[1 to 10]
                    return 
                        <li>
                            <a href="/lds/search.xqy?count=10&amp;pg=1&amp;mime=text%2Fhtml&amp;sort=score-desc&amp;q={xs:string($r)}&amp;qname=idx:subjectLexicon" >						
									{$r}
							</a>
                        </li>
                    }
                 </ul>
				)
        else ()
    let $broaders :=
        if ( $subjects/subject/relation/@type = "hasBroaderAuthority" ) then
                (<h2 class="top">Search Broader Subjects</h2>,
                <ul>
                    { for $r in distinct-values($subjects/subject/relation[@type = "hasBroaderAuthority"])
(:                    for $r in $subjects/subject/relation
                    where xs:string($r/@type) = "hasBroaderAuthority":)
					   order by $r                 
                    return 
                        <li>
                            <a href="/lds/search.xqy?count=10&amp;pg=1&amp;mime=text%2Fhtml&amp;sort=score-desc&amp;q={$r}&amp;qname=idx:subjectLexicon">{$r}</a>
                        </li>
                    }
                 </ul>)
        else ()
    (: This is so the dotted lines from the CSS looks right :)     
	let $narrowers:= 
		if (not($broaders)) then
             mem:node-insert-child($narrowers//div[@id="ds-bibviews"]/h2[1], attribute class {"top"})
		else $narrowers

     let $htmldiv :=  
		if ($broaders or $narrowers  and $htmldiv//div[@id="ds-bibviews"]/h2[@class='top'] ) then
             mem:node-delete($htmldiv//div[@id="ds-bibviews"]/h2[@class='top']/@class)
			else $htmldiv
    (: This is so the dotted lines from the CSS looks right :)     
    let $htmldiv :=
        if ( $htmldiv//div[@id="ds-bibviews"] ) then 
            <div id="content-results">
                {
                    $htmldiv/div[@id="ds-bibrecord-nav"],
					
                    element div {
                        attribute id {"ajaxview"},						
                        $htmldiv/div[@id="ajaxview"]/div[@id="ds-bibrecord"],						
                        element div {
                            attribute id {"ds-bibviews"},
                            $broaders,
                            $narrowers,
                          $htmldiv/div[@id="ajaxview"]/div[@id="ds-bibviews"]/child::node() 
						
                        }
                    },
                    $htmldiv/span
                }
				
            </div>
        else
            $htmldiv

     
     
    (: End kefo addition :)
       (: nate added current object to return so we can render different formats instead of html for detail.xqy:)
    return
        ($seo, $htmldiv, $current_object, $uri)
};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)