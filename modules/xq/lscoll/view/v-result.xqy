xquery version "1.0-ml";

module namespace vr = "http://www.marklogic.com/ps/view/v-result";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace md = "http://www.marklogic.com/ps/model/m-doc" at "/xq/lscoll/model/m-doc.xqy";
import module namespace pg = "info:lc/xq-modules/pagination" at "/xq/modules/pagination.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mxe2 = "http://www.loc.gov/mxe";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace param = "http://www.marklogic.com/ps/params";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $PAGE_SIZE := $cfg:RESULTS-PER-PAGE;
declare variable $PAGING_LINK_BORDER := 2;

declare function vr:result($result, $index) {
    let $pct := concat(round-half-to-even((cts:confidence($result)), 2) * 100, '%')
    let $uri := xdmp:node-uri($result)
    let $myuri := $uri
    let $mets := $result/mets:mets
    let $svcid := $mets/@OBJID/string()
    let $highlight-query :=  lq:get-highlight-query()
    let $matching-text := md:matching-text($highlight-query, $result)
    let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, '/page', 'detail')
    let $new-params := lp:param-replace-or-insert($new-params, 'uri', $svcid)
    let $new-params := lp:param-replace-or-insert($new-params, 'index', $index)
    let $new-params-str := lp:param-string($new-params)
    return
    (
        <span class="hit">{$index}.&nbsp;</span>,
        if (starts-with($myuri, "/catalog/lscoll/ead/")) then
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
        else
            let $mods := $mets/mets:dmdSec[@ID='dmd1']/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods
            let $idx := $mets/mets:dmdSec[@ID='IDX1']/mets:mdWrap[@MDTYPE='OTHER']/mets:xmlData/idx:indexTerms
            let $marctitle := $mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record/mxe2:datafield_245/child::*
            let $title := 
                (
                    <a class="hitResult mods-result" href="/xq/lscoll/app.xqy#{$new-params-str}" rel="{$new-params-str}">                    
                    {
                        if (exists($idx/idx:display/idx:title)) then
                            string($idx/idx:display/idx:title)
                        else if (exists($marctitle)) then
                            string-join($marctitle, " ")
                        else                                
                            normalize-space($mods/mods:titleInfo[not(@type)][1])
                    }
                    </a>,
                    <br />
                )            
            let $creator := 
                if (exists($idx/idx:display/idx:mainCreator)) then
                    (<span class="author">{string($idx/idx:display/idx:mainCreator[1])}</span>, <br />)
                else if (exists($idx/idx:byName)) then
                    (<span class="author">{string($idx/idx:byName[1])}</span>, <br />)
                else
                    ()
            let $publisher :=
                if (exists($idx/idx:display/idx:pubinfo)) then
                    (<span class="publisher">{string($idx/idx:display/idx:pubinfo)}</span>, <br />)
                else if (exists($mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record/mxe2:datafield_260)) then
                    (<span class="publisher">{string-join($mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record/mxe2:datafield_260/child::*, " ")}</span>, <br />)
                else
                    ()
            let $typeOfMaterial :=
                    if (exists($idx/idx:display/idx:typeOfMaterial)) then
                        (<span class="format">{string($idx/idx:display/idx:typeOfMaterial)}</span>, <br />)
                    else if (exists($idx/idx:form)) then
                        (<span class="format">{string($idx/idx:form[1])}</span>, <br />)
                    else
                        ()
            (: location is waiting for holdings :)                
            (:let $location := (<span class="location">[Location] <span>Location:</span> ::location label OR "available online"::</span>, <br />):)
            return ($title, $creator, $publisher, $typeOfMaterial)
    )
};


declare function vr:paging-links($pages, $my-page) {
    for $px in $pages
    let $local-start := (($px - 1) * $PAGE_SIZE) + 1    
    let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, 'pg', $local-start)
    let $new-params := lp:param-remove-all($new-params, 'uri')
    let $new-params-str := lp:param-string($new-params)
    return
        <a id="{if($px eq $my-page) then 'paging-this' else 'paging' }" href="/?{$new-params-str}" rel="{$new-params-str}">{$px}</a>
};

declare function vr:paging( $start, $estimate, $results-count){
    <div id="paging">
        <div class="fleft">
            Displaying results {$start} to {$start - 1 + $results-count} out of about {$estimate}
        </div>
        <div class="fright">
            Go to page: {
            
            let $page-count := xs:integer(ceiling($estimate div $PAGE_SIZE))
            let $my-page := xs:integer(ceiling( $start div $PAGE_SIZE ))
            
            let $a := 1
            let $b := min(($page-count,1 + $PAGING_LINK_BORDER))
            let $c := max((($b + 1), ($my-page - $PAGING_LINK_BORDER))) 
            let $d := min(($page-count,($my-page + $PAGING_LINK_BORDER)))
            let $_ := xdmp:log(text{"page-count",$page-count, "my-page",$my-page, "a",$a, "b",$b, "c",$c, "d",$d},"finer")
            return
            (
                vr:paging-links( ($a to $b), $my-page ),
                if(($b + 2) le $c) then " .. " else (),
                if($d gt $b) then vr:paging-links( ($c to $d), $my-page ) else (),
                if(($page-count gt $d) and ($d lt $page-count)) then " ... " else ()
            )
            
            }
        </div>
        <br class="break"/>
    </div>
};

declare function vr:render($results, $start, $time, $longstart, $longcount) {
    let $params := lp:param-string($lp:CUR-PARAMS)
    let $mypage := lp:get-param-single($lp:CUR-PARAMS,'pg') cast as xs:int
    let $mycount := lp:get-param-single($lp:CUR-PARAMS,'count') cast as xs:int
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
    let $mysort :=
        if (lp:get-param-single($lp:CUR-PARAMS, 'sort')) then
            lp:get-param-single($lp:CUR-PARAMS, 'sort')
        else
            "score-desc"
    let $qstringfound := 
        if (lp:get-param-single($lp:CUR-PARAMS, 'q')) then
            concat(" for ", xdmp:url-decode(lp:get-param-single($lp:CUR-PARAMS, 'q')))
        else
            ()
    let $resultcountsdisp :=
        if ($hitsfound eq 0) then
            <span><strong>No results</strong></span>
        else
           <span>Results <strong>{concat(format-number($beginhit, "#,###"), ' - ', format-number($endhit, "#,###"))}</strong> of about {format-number($estimate, "#,###")}{$qstringfound}<!-- in {$time} seconds --></span>
    
    let $mypaginator :=
        if ($hitsfound gt 0) then
            <div class="right">
              <!-- <ul id="pagination-clean">{(:pg:ajax-search-results-paginator($currentresultspage, $totalresultspages, $params):)}</ul> -->
              {pg:display-results-pagination($start, $longcount, $estimate, $longcount, $params)}
              <!-- end class:right -->
            </div>
        else
            () 
    let $lc := 
        <div id="results-results">
          <div id="ds-mainright">
              <div id="ds-controls">
                  <div class="ds-paging">
                    <div class="left">
                        {$resultcountsdisp}
                    </div>
                    <!-- end class:left -->
                    {$mypaginator}  
                  </div>
                  <!-- end class:ds-paging -->
                  <div class="ds-views">
                    <div class="left">
                      <form class="resort" id="resort" name="resort" method="get" action="resort">
                        <label for="sortorder" class="norm">Sort by</label>                                   
                            <select name="sortorder" size="1" id="sort-order" onchange="javascript:sortOrderSel(this);">
                                <option value="score-desc">
                                    {if ($mysort eq "score-desc") then attribute selected {"selected"} else ()}
                                    Relevance (high-to-low)
                                </option>
                                <option value="score-asc">
                                    {if ($mysort eq "score-asc") then attribute selected {"selected"} else ()}
                                    Relevance (low-to-high)
                                </option>
                                <option value="pubdate-asc">
                                    {if ($mysort eq "pubdate-asc") then attribute selected {"selected"} else ()}
                                    Publication date (newest-to-oldest)
                                </option>
                                <option value="pubdate-desc">
                                    {if ($mysort eq "pubdate-desc") then attribute selected {"selected"} else ()}
                                    Publication date (oldest-to-newest)
                                </option><option value="cre-asc">
                                    {if ($mysort eq "cre-asc") then attribute selected {"selected"} else ()}
                                    Author/creator name (A-Z)
                                </option>
                                <option value="cre-desc">
                                    {if ($mysort eq "cre-desc") then attribute selected {"selected"} else ()}
                                    Author/creator name (Z-A)
                                </option>
                            </select>
                            <!-- <button class="btn-sm" value="submit">Go</button> -->
                      </form>
                    </div>
                    <!-- end class:left -->
                    <div class="right">
                      <form class="numhits" id="number_hits" method="get" action="number_hits">
                        <select class="sel" name="number_hits_sel" id="number_hits_sel" onchange="javascript:numHitsSel(this);">
                          <option value="hits10">
                              {if ($mycount eq 10) then attribute selected {"selected"} else ()}
                              10
                          </option>
                          <option value="hits25">
                              {if ($mycount eq 25) then attribute selected {"selected"} else ()}
                              25
                          </option>
                        </select>&nbsp;<label class="norm" for="number_hits">per page</label>
                      </form>
                    </div>
                    <!-- end class:right -->
                  </div>
                  <!-- end class:ds-views -->
              </div>
              <!-- end id:ds-controls -->
                <div id="ds-hitlist">
                    <ul>
                    {
                        for $result at $i in $results
                        let $oddOrEven :=
                            if ($i mod 2 = 0) then
                                "evenrow"
                            else
                                "oddrow"
                        return <li class="{$oddOrEven}">{vr:result($result, $i + $start - 1)}</li>
                    }
                    </ul>
                </div>
                <!-- end id:ds-hitlist -->
          </div>
          <!-- end id:ds-mainright -->
          <!-- end id:ds-results -->
    </div>
    return $lc
};