xquery version "1.0-ml";

module namespace vr = "http://www.marklogic.com/ps/view/v-result";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "../config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "../lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "../lib/l-param.xqy";
import module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight" at "../lib/l-highlight.xqy";
import module namespace pg = "info:lc/xq-modules/pagination" at "../view/v-pagination.xqy";
import module namespace vd = "http://www.marklogic.com/ps/view/v-detail" at "../view/v-detail.xqy";
declare namespace search = "http://marklogic.com/appservices/search";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mxe2 = "http://www.loc.gov/mxe";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace param = "http://www.marklogic.com/ps/params";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $PAGE_SIZE := $cfg:RESULTS-PER-PAGE;
declare variable $PAGING_LINK_BORDER := 2;


declare function vr:result($result, $index, $searchterm) {
    let $pct := concat(round-half-to-even((cts:confidence($result)), 2) * 100, '%')
    let $uri := xdmp:node-uri($result)
    let $myuri := $uri
    let $mets := $result/mets:mets
	let $docid:=fn:base-uri($mets)
    let $svcid := $mets/@OBJID/string() 
    let $highlight-query :=  lq:get-highlight-query()
    let $matching-text := (:md:matching-text($highlight-query, $result):) ""
    (:let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, 'uri', $svcid) :)   
    (:let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING):)

let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)
let $url-prefix:=concat("/",$branding,"/")
let $collection as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'collection', $cfg:DEFAULT-COLLECTION)
(:let $_:=xdmp:log("-------------","info")
let $nate:=for $n in $result return xdmp:log(fn:base-uri($n),"info")


let $_:=xdmp:log("-------------","info"):)
    let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, 'index', $index)
    let $new-params := lp:param-remove-all($new-params, "branding")
	let $new-params := lp:param-remove-all($new-params, "collection")
	let $new-params := lp:param-remove-all($new-params, "lref")
    let $new-params-str := lp:param-string($new-params)
    let $span-hit-num := <div class="hit">{$index}.&nbsp;</div>
    return
    (
        if (matches($myuri, "(/catalog)?/lscoll/ead/")) then
            let $ead := $mets/mets:dmdSec[@ID='ead']/mets:mdWrap/mets:xmlData/ead:ead
            let $eadtitle := string($ead/ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper)
            let $eadextents := string-join($ead/ead:archdesc/ead:did/ead:physdesc/ead:extent, " ; ")
            let $eadpub := string($ead/ead:eadheader/ead:filedesc/ead:publicationstmt/ead:publisher)
            let $eadaddr := string-join($ead/ead:eadheader/ead:filedesc/ead:publicationstmt/ead:address/ead:addressline, " ")
            let $eadabstract := string($ead/ead:archdesc/ead:did/ead:abstract)
            let $eadabsfmt :=
                if (string-length($eadabstract) gt 250) then
                    concat(substring($eadabstract, 1, 250), "...")
                else
                    $eadabstract
            return (
                <a class="hitResult ead-result" href="{concat("/xq/conneg.xqy?_uri=", $svcid, "&amp;_mime=text/xml")}">{$eadtitle}</a>,
                <span>&nbsp;<b>({$pct})</b></span>,
                <br />,
                <span class="findaid-ext">{concat($eadextents, " -- ", $eadpub, ", ", $eadaddr)}</span>,
                <br />,
                <span class="format"><span>Format:</span> Finding Aid</span>,
                <br />,
                <span class="location"><span>Location:</span> Available Online</span>,
                <br/>,
                <p><a href="{concat("/", $svcid,"/default.html")}">Bib view</a></p>,
                <div class="findaid-summary">
                    <span>Summary: </span>
                    {$eadabsfmt}
                </div>
            )
        else if (not(contains($svcid, '.lcdb.') )  (:matches($svcid, "loc.natlib.tohap.*"):)   ) then
            let $idx := element idx:index {$mets/mets:dmdSec[@ID='IDX1']/mets:mdWrap[@MDTYPE='OTHER']/mets:xmlData/idx:indexTerms/*,
                                       $mets/mets:dmdSec[fn:contains(@ID,'index')]//mets:mdWrap/mets:xmlData/idx:index/* 
                           }
            let $mods := $mets//mods:mods
            let $partscount := concat(" (", count($mets//tei:TEI), " parts)")
            let $cre :=
                if ($idx//idx:mainCreator) then 
                    $idx//idx:mainCreator[1] 
                else
                    $mods/mods:name[1]/mods:namePart[1]/string()
            let $ed :=
                (: nate commented this out for pae recs 12/22/11
				if (contains($cre, ",")) then
                    let $tox := tokenize($cre, ",\s*")
                    return
                        string-join(reverse($tox), " ")
                else:)
                    $cre
            let $physdesc := $mods/mods:physicalDescription/mods:extent[1]/string()
           let $workid-length:=  if (fn:contains($svcid,"works")) then
							fn:string-length(fn:tokenize($svcid,"\.")[fn:last()])
		   						else
								1
		   let $rdftype:= if ($workid-length > 12 and fn:contains($svcid,"works.n")) then
		   					 		"Work stub from Authority" 
							 else if (fn:contains($svcid,"works.n")) then
									 "Work from Authority" 
							 else if ($workid-length > 12 and fn:contains($svcid,"works.c")) then 
							 		"Work Stub from Bib"
							  else if ($workid-length > 12 and fn:contains($svcid,"works.e")) then 
							  		"Work stub from Editor"
							  else if (fn:contains($svcid,"works.c")) then 
							  		"Work from Bib"							  
							   else if (fn:contains($svcid,"works.e")) then 
							  		"Work from Editor"							  
							  else if (fn:contains($svcid,"instances.c")) then 
							  		"Instance"	
							  else if (fn:contains($svcid,"items.e")) then 
							  		fn:concat("Item from Editor")
							  else if (fn:contains($svcid,"items")) then 
							  		"Item"								 
							  else if (fn:contains($svcid,"instances.e")) then 
							  		"Instance from Editor"							 
							  else ""
		    let $titletext := 
                if (exists($idx/idx:display/idx:title/text())) then
                    string($idx/idx:display/idx:title)
                else
                    normalize-space(string-join(($mods/mods:titleInfo[not(@type)])[1]/mods:title, " "))
			let $url-prefix:=concat("/",$branding,"/")
			let $title-link := concat('/',$branding,'/detail.xqy?',$new-params-str)
						(:if ($branding!="lds") then
							concat('/',$branding,'/detail.xqy?',$new-params-str)
						else
							concat('/',$cfg:DEFAULT-BRANDING,'/detail.xqy?',$new-params-str):)
            let $title :=                
                 <div class="hit-link">                  
                    <a class="hitResult mods-result" href="{$title-link}">                    
                    { if ($idx/idx:nameTitle ) then
						fn:string($idx/idx:nameTitle[1])
					  else  if ($titletext!="" ) then
                           $titletext
                       else						
                            concat("[No title: ", $svcid, "]")
                    }
                    </a>  <span class="format"><b> ({$rdftype})</b></span>
                    <br/> {if ($titletext="" ) then fn:tokenize(fn:base-uri($mets),"/")[fn:last()] else () }
                </div>    
            let $creator := 
                if ($idx/idx:display/idx:mainCreator) then
                    <div class="author">{string($idx/idx:display/idx:mainCreator[1])}</div>
                else if ($idx/idx:byName) then
                    <div class="author">{string($idx/idx:byName[1])}</div>
                else
                    ()
            let $publisher :=
            	if (matches($svcid, "loc.natlib.tohap.*")) then  (:tohap uses extent instead of publisher:)
                   <div class="publisher">{$physdesc}</div>
            	else if ($idx/idx:display/idx:pubinfo/text()  ) then
                    <div class="publisher">{string($idx/idx:display/idx:pubinfo[1])}</div>              
                else if ($idx//idx:beginpubdate or  $idx/idx:imprint or $idx/idx:pubplace ) then                    
					<div class="publisher">{
							(if ($idx//idx:pubplace) then  $idx//idx:pubplace[1]/string() else (),
							 if ($idx//idx:imprint) then  $idx//idx:imprint[1]/string() else (),
							 if ($idx//idx:pubdates[1]/idx:beginpubdate) then  $idx/idx:pubdates[1]/idx:beginpubdate[1]/string() else ()
							 )
						 }</div>                           					
					else if ($idx/idx:imprint ) then                    
						<div class="publisher">{(string($idx/idx:imprint) )}</div>                           
					else
                      ()
            
			let $ids:=if ($idx/idx:lccn or $idx/idx:issn or $idx/idx:issnl or $idx/idx:isbn) then
							 <div class="publisher">{(
								 if ($idx/idx:lccn ) then concat("lccn: ",$idx/idx:lccn[1]) else (),
								 if ($idx/idx:issn ) then concat("issn: ",$idx/idx:issn[1]) else (),
								 if ($idx/idx:isbn ) then concat("isbn: ",$idx/idx:isbn[1]) else ()
								 )
				 
							}</div>

	 				 else ()
			let $typeOfMaterial :=
                    if (exists($idx/idx:display/idx:typeOfMaterial)) then
                        <div class="format">{string($idx/idx:display/idx:typeOfMaterial)}</div>
                    else if (exists($idx/idx:form)) then
                        <div class="format">{string($idx/idx:form[1])}</div>
						 else if ($idx/idx:materialGroup!="Instance") then
                        <div class="format">{string($idx/idx:materialGroup[1])}</div>
						else if ($idx/idx:issuance!="Single unit") then
                        <div class="format">{string($idx/idx:issuance[1])}</div>
                    else
                        ()
            let $online-status :=
                if ($idx//idx:digitized="Online") then
                    <div class="online">Available Online</div>                  
                else if ($idx//idx:digitized="Partly Online") then
                    <div class="part-online">Partly Online (includes links to tables of contents, descriptions, biographical information, etc.)</div>
                else
                    ()
            (:let $snips := lq:tohap-tei-snippet($result)
            	let $filtersnips := lq:filter-snippets($snips, "/tei:")
            	let $snipout :=
                for $zz in $filtersnips/search:match
	                let $path := $zz/@path/string()
	                let $unpath := xdmp:unpath($path)
	                let $part := replace($path, ".+/mets:file\[(\d*)\]?.*", "$1")
	                let $xmlspid := $unpath/parent::tei:sp/@xml:id/string()
	                let $hash := concat("#", $xmlspid)
					let $hit-link:=concat($url-prefix,"tohap.xqy?uri=",$svcid,"&amp;part=",$part,$hash)
	                return
	                    (
	                        <div style="width: 250px; background-color: #DFDFDF;">
	                            <a class="hitResult tohap-result" href="{$hit-link}">
	                                {concat("Part ", $part, ":")}
	                            </a>
	                        </div>,
	                        <p>{lh:snippet-highlight($zz)}</p>    
	                    )
			:)
				let $unapi-link:=<abbr class="unapi-id" title="{$svcid}" />
				let $location :=
	                if ($idx//idx:loc1) then
	                    (<span class="location">{$idx//idx:loc1[1]/string()}</span>, <br/> )
	                else ()
	            let 	$bibid:=  fn:substring-after(tokenize($svcid,"\.")[last()],"c")            
	            let $img := 
					if (matches($svcid,'lcwa')) then
						<img src="{concat('/media/', replace($svcid,'lcwa','mrva'), "/thumb")}" alt="Thumbnail image" class="hit-cover"/>       
					else if (fn:not(fn:contains($svcid,"works")) ) then
						let $token:=tokenize($svcid,"\.")[last()]
	            		let $bibid:=replace($token,"^c0+","")
						let $bibid:=replace($bibid,"^e0+","")
	            		let $bibid:=if (string-length($token) > 10 ) then 
								substring($bibid, 1,string-length($bibid)-4)
							else 
								$bibid
								
						let $paddedid:=format-number(number($bibid), '0000000000')
						let $convgrp:=fn:concat(fn:substring($paddedid,1,4), "_",fn:substring($paddedid,5,2))
						let $tileservice:="//tile.loc.gov/image-services/iiif/service:ndmso:lcdb:"
						let $sizing:="/full/full/0/"
					 
						let $link:=fn:concat($tileservice,":",$convgrp,":",$paddedid,$sizing,"default.jpg")
						return 
							<img src="{$link}" alt=" " class="hit-cover"/>
								
			
				(:			<img src="{concat('http://der02vlp.loc.gov/media/loc.natlib.lcdb.', $bibid, "/thumb")}" alt="Thumbnail image" class="hit-cover"/>":)
						else ()
            return
                ($img, $span-hit-num, $title, $creator,$typeOfMaterial, $publisher,  $ids,  $location,(:$snipout:) $online-status, $unapi-link)
        else
            let $mods := $mets/mets:dmdSec[@ID='dmd1']/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods
            let $idx := $mets/mets:dmdSec[@ID='IDX1' or @ID='ldsindex']/mets:mdWrap[@MDTYPE='OTHER']/mets:xmlData/idx:index
            let $mxe := $mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record
            let $marctitle := $mxe/mxe2:datafield_245/child::*
			let $title-link := concat('/',$branding,'/detail.xqy?',$new-params-str)
						
            let $title := 
                <div class="hit-link">                  
					<a class="hitResult mods-result" href="{$title-link}">                    
                    {
                        if (exists($idx/idx:display/idx:title/text())) then
                            string($idx/idx:display/idx:title)
                        else if (exists($marctitle//text())) then
                            string-join($marctitle//text(), " ")
                        else if (normalize-space(string-join(($mods/mods:titleInfo[not(@type)][1])//text() , " ")   )) then
                            normalize-space(string-join(($mods/mods:titleInfo[not(@type)][1])//text() , " ")   )
                        else
                            concat("[Unknown title: ", $svcid, "]")
                    }
                    </a>                    
                </div>           
            let $creator := 
                if ($idx/idx:display/idx:mainCreator) then
                    <div class="author">{string($idx/idx:display/idx:mainCreator[1])}</div>
                else if ($idx/idx:byName) then
                    <div class="author">{string($idx/idx:byName[1])}</div>
                else
                    ()
            let $publisher :=
                if ($idx/idx:display/idx:pubinfo/text()) then
                    <div class="publisher">{string($idx/idx:display/idx:pubinfo)}</div>
                else if ($mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record/mxe2:datafield_260) then
                    <div class="publisher">{string-join($mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record/mxe2:datafield_260/child::*, " ")}</div>
                else
                    ()
            let $typeOfMaterial := if (1=1) then
					(: if (fn:matches($svcid,"(works|instances|items)") ) then :)
                        (<div class="format">{fn:substring-before($mets/@PROFILE,"Record")  }</div>,
							<div class="format">{$svcid}</div>
						)
                    else if (exists($idx/idx:display/idx:typeOfMaterial)) then
                        <div class="format">{string($idx/idx:display/idx:typeOfMaterial)}</div>
                    else if (exists($idx/idx:form)) then
                        <div class="format">{string($idx/idx:form[1])}</div>                    
					
                    else    ()         
            let $online-status :=
                if ($idx//idx:digitized="Online") then
                    <div class="online">Available Online</div>                  
                else if ($idx//idx:digitized="Partly Online") then
                    <div class="part-online">Partly Online (includes links to tables of contents, descriptions, biographical information, etc.)</div>
                else
                    ()
            (: location is waiting for holdings :)                
            let $location :=
			 if ($idx//idx:loc1) then
                    (<span class="location">{$idx//idx:loc1[1]/string()}</span>, <br/> )
			 else ()
            let $img := <img src="{concat('/media/', $svcid, "/thumb")}" alt="Book cover image" class="hit-cover"/>
			let $unapi-link:=<abbr class="unapi-id" title="{$svcid}" />
            return
                ($img , $span-hit-num, $title, $creator, $publisher, $location, $typeOfMaterial, $online-status, $unapi-link)
                
    )
};

declare function vr:render($results, $start, $time, $longstart, $longcount, $searchterm) {
    let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)
	(:let $params := lp:param-string($lp:CUR-PARAMS):)
	let $params:= lp:get-params()
	let $params := lp:param-remove-all($params, "branding")
	let $params := lp:param-remove-all($params, "collection")
	let $params:=lp:param-string($params)
	let $searchfilter := lp:get-param-single($lp:CUR-PARAMS, 'filter','all')
	let $searchfilter-label := if($searchfilter="all") then "all objects" else $searchfilter
	let $url-prefix:=concat("/",$branding,"/")

    let $mypage := lp:get-param-integer($lp:CUR-PARAMS, 'pg', 1)
    let $count := lp:get-param-integer($lp:CUR-PARAMS,'count',$cfg:RESULTS-PER-PAGE)
	
    let $mycount := if($count = (10,25,$cfg:RESULTS-PER-PAGE)) then $count else $cfg:RESULTS-PER-PAGE
    
	let $estimate :=
        if ($mypage eq 1) then
            cts:remainder($results[1])
        else
            (cts:remainder($results[1]) + (($mypage - 1) * $mycount))
    let $results-count := count($results)
    let $hitsfound := $results-count
    let $beginhit := $start
    let $endhit := 
        if ((($beginhit + $results-count) - 1) gt $estimate) then
            $estimate
        else
            ($beginhit + $results-count) - 1
    let $totalresultspages := ceiling($estimate div $mycount)
    let $currentresultspage := $mypage
    let $request := xdmp:get-request-url()
    let $mysort := lp:get-param-single($lp:CUR-PARAMS, 'sort', "score-desc")
    let $aboutness :=
        if ($results-count lt $mycount) then
            format-number($estimate, "#,###")
        else
            concat("about ", format-number($estimate, "#,###"))
    let $filterlinks:=vd:filter-results($searchfilter, $url-prefix ,"search") 
	let $resultcountsdisp :=
        if ($hitsfound eq 0) then
            <span><strong>No results</strong></span>
        else
           <span>Results <strong>{concat(format-number($beginhit, "#,###"), ' - ', format-number($endhit, "#,###"))}</strong> of {$aboutness} ({$searchfilter-label})</span>
    let $mypaginator :=
        if ($hitsfound gt 0) then
            pg:display-results-pagination($start, $longcount, $estimate, $longcount, $params)
        else
            () 
    let $preserve-param-inputs :=
        for $param in ($lp:CUR-PARAMS//param:param)[not(param:name/text() = ('sort','count'))]
        let $name := $param/param:name/text()
        let $value := $param/param:value/text()
        return
           if($name eq 'pg') then
               <input value="1" type="hidden" alt="{$name}" name="{$name}"  />
           else
		    	if($name != 'uri') then
               <input value="{$value}" type="hidden" alt="{$name}" name="{$name}"  />
			   else ()
    
    let $dsctrl :=
    (
                <div class="ds-count">
                    {$resultcountsdisp}
                </div>,
                  <div class="ds-paging">
                    <div class="center">
                        {$mypaginator}
                    </div>                   
                    <!-- end class:ds-paging -->
                  </div>,                  
                  <div class="ds-views" style="padding-top:5px;">
                    <form class="search-result-options-form" id="search-result-options-form" method="get" action="{concat($url-prefix,'search.xqy')}">
                        <div>{$preserve-param-inputs}</div>
                        <div class="left">
                        <label for="sort" class="norm">Sort by&nbsp;</label>                                   
                            <select name="sort" size="1" id="sort">
                                <option value="score-desc">
                                    {if ($mysort eq "score-desc") then attribute selected {"selected"} else ()}
                                    Relevance
                                </option>
                                
                                <option value="pubdate-desc">
                                    {if ($mysort eq "pubdate-desc") then attribute selected {"selected"} else ()}
                                    Date (newest to oldest)
                                </option>
								<option value="pubdate-asc">
                                    {if ($mysort eq "pubdate-asc") then attribute selected {"selected"} else ()}
                                    
									 Date (oldest to newest)
                                </option>
								<option value="cre-asc">
                                    {if ($mysort eq "cre-asc") then attribute selected {"selected"} else ()}
                                    Main Author/Creator (A-Z)
                                </option>
                                <option value="cre-desc">
                                    {if ($mysort eq "cre-desc") then attribute selected {"selected"} else ()}
                                    Main Author/Creator (Z-A)
                                </option>
                            </select><button id="sort-submit">Go</button>                    
                        </div>
                        <!-- end class:left -->
                        <div class="right">
                            <select name="count" id="count">
                              <label for="count" class="nodisplay">records per page</label>
                              <option value="10">
                                  {if ($mycount eq 10) then attribute selected {"selected"} else ()}
                                  10 per page
                              </option>
                              <option value="25">
                                  {if ($mycount eq 25) then attribute selected {"selected"} else ()}
                                  25 per page
                              </option>
                            </select><button id="count-submit">Go</button>
                        </div>
                    <!-- end class:right -->                    
                    </form>
                    <!-- end class:ds-views -->
                  </div>
    )

    
    let $lc := 
        <div id="results-results">
          <div id="ds-mainright">
                <div id="ds-controls">
                    {$dsctrl}
                </div>
                <div id="ds-hitlist">
                    <ul>
                    {
                        for $result at $i in $results
                        let $oddOrEven :=
                            if ($i mod 2 = 0) then
                                "evenrow"
                            else
                                "oddrow"
                        return <li class="{$oddOrEven}">{vr:result($result, ($i + $start - 1), $searchterm)}</li>
                    }
                    </ul>
                </div>
                <!-- end id:ds-hitlist -->
                  <div id="ds-controls2">
            {$dsctrl}
          </div>
          </div>
          <!-- end id:ds-mainright -->
          <!-- end id:dsresults -->
       
    </div>
    
    let $queryString := <x>{ lq:query-from-params($lp:CUR-PARAMS) }</x>/node()
    (: Changed to simply get down to the cts:element text so that the XPath isn't so strict.                                :)
    (: The strict XPath breaks the use of cts:element-range-query for getting exact hits in                                 :)
    (: the precision=exact search results as pointed to from the browse page.                                               :)
    (: Necessitated change in lh:highlight-query(), lq:query-from-params(), and vr:render() to use cts:element-range query. :)
    (: See Danny Sokolsky at http://www.mail-archive.com/general@developer.marklogic.com/msg02325.html                      :)
    (:let $filter := $queryString/cts:element-query/cts:element/text():)
    (:let $filter := $queryString//cts:element/text() :)
    
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
    return
        vr:highlight-results($lc, $filter, $highlight-query)
		
};

declare function vr:highlight-results($x as node(), $filter, $q as cts:query) {
    typeswitch ($x) 
        case text() return $x
        case element() return 
            if(xs:string($x/@id) eq "ds-hitlist") then
                (: start highlighting :)                
                element {fn:node-name($x)} {
                    for $a in $x/attribute() 
                    return $a, 
                    
                    for $z in $x/node() 
                    return 
                    vr:highlight-results2($z, $filter, $q)
                }
            else
                (: recurse :)
                element {fn:node-name($x)} {
                    for $a in $x/attribute() 
                    return $a, 
                    
                    for $z in $x/node() 
                    return 
                    vr:highlight-results($z, $filter, $q)
                }
        default return $x
};

declare function vr:highlight-results2($x as node(), $filter, $q as cts:query) {
    typeswitch ($x) 
        case text() return $x
        case element(a) return 
           if (($filter = "idx:titleLexicon") or (fn:empty($filter))) then
               cts:highlight($x, $q, <span class="highlt">{$cts:text}</span>)
           else 
               $x
        case element(div) return
            if( (($filter = "idx:mainCreator") and $x[@class eq "author"]  ) or ((fn:empty($filter)) and $x[@class = ("author","publisher","format")  ])) then        
              cts:highlight($x, $q, <span class="highlt">{$cts:text}</span>)              
           else
              element {fn:node-name($x)} {
                  for $a in $x/attribute() 
                  return 
                  $a,
                  
                  for $z in $x/node() 
                  return 
                  vr:highlight-results2($z, $filter, $q)
              }
              
        case element() return 
            element {fn:node-name($x)}  {
                for $a in $x/attribute() 
                return 
                $a,                 
                for $z in $x/node() 
                    return 
                    vr:highlight-results2($z, $filter, $q)
            }
        default return $x 
};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)