xquery version "1.0-ml";

module namespace vs = "http://www.marklogic.com/ps/view/v-search";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
declare namespace esi = "http://www.edge-delivery.org/esi/1.0";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default collation "http://marklogic.com/collation/en/S1";

declare function vs:recursiveFormat($number as xs:string) {
    let $len := string-length($number)
    return
        if($len gt 3) then
            concat(vs:recursiveFormat(substring($number, 1, $len - 3)), ",", substring($number, $len - 2, $len))
    else
        $number
};

declare function vs:render() {
    let $qrel :=
        if (lp:get-param-single($lp:CUR-PARAMS,'/page') eq "browse") then
            let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, '/page', 'results')
            let $new-params := lp:param-remove-all($new-params, 'q')
            let $new-params := lp:param-remove-all($new-params, 'browse-order')
            let $new-params := lp:param-remove-all($new-params, 'browse')
            let $new-params := lp:param-remove-all($new-params, 'precision')
            let $new-params := lp:param-replace-or-insert($new-params, 'pg', "1")
            let $new-params := lp:param-replace-or-insert($new-params, 'count', "10")
            let $new-params := lp:param-replace-or-insert($new-params, 'mime', "text/html")
            let $new-params := lp:param-replace-or-insert($new-params, 'sort', "score-desc")
            let $new-params := lp:param-replace-or-insert($new-params, 'qname', "keyword")
            return lp:param-string($new-params)
        else
            let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, '/page', 'results')
            let $new-params := lp:param-remove-all($new-params, 'q')
            let $new-params := lp:param-replace-or-insert($new-params, 'pg', "1")
            let $new-params := lp:param-replace-or-insert($new-params, 'qname', "keyword")
            let $new-params := lp:param-replace-or-insert($new-params, 'count', "10")
            let $new-params := lp:param-replace-or-insert($new-params, 'mime', "text/html")
            let $new-params := lp:param-replace-or-insert($new-params, 'sort', "score-desc")
            return lp:param-string($new-params)
    let $q1 := lp:get-param-single($lp:CUR-PARAMS,'q')
    let $qname as xs:string? := lp:get-param-single($lp:CUR-PARAMS,'qname')
    let $lcinputval :=
        if (matches(lp:get-param-single($lp:CUR-PARAMS,'/page'), "(search|results|detail)") and empty($q1)) then
            "Enter search word(s)"
        else if (lp:get-param-single($lp:CUR-PARAMS,'/page') eq "browse") then
            "Enter search word(s)"
        else
            $q1
    let $lcfielded :=
        <select name="fieldedsearch" size="1" id="lc-fielded" onchange="javascript:fieldedSel(this);">
            <option value="keyword">
                {if ($qname eq "keyword" or not(exists($qname))) then attribute selected {"selected"} else ()}
                Everything
            </option>
            <option value="idx:mainCreator">
                {if ($qname eq "idx:mainCreator") then attribute selected {"selected"} else ()}
                Author/Creator
            </option>
            <option value="idx:subjectLexicon">
                {if ($qname eq "idx:subjectLexicon") then attribute selected {"selected"} else ()}
                Subject
            </option>
            <option value="idx:titleLexicon">
                {if ($qname eq "idx:titleLexicon") then attribute selected {"selected"} else ()}
                Title
            </option>
        </select>
    let $lcsearch := <input value="{$lcinputval}" type="text" alt="q" name="q" size="75" maxlength="200" class="txt" id="quick-search-box" rel="{$qrel}" onfocus="javascript:clearSearchBox(this.id);"/>
    let $lcsearchblock :=
        <div id="ds-search">
            <div id="ds-quicksearch">
                <form id="quick-search" name="quick-search" method="get" action="#">
                    {$lcsearch}
                    <input value="all" type="hidden" alt="collection" name="collection" id="box-insert-before" />
                    <span><button id="lc-ajax-button" value="submit">Search</button><!-- &nbsp;<label style="margin-left: 4px;" class="norm"><a href="/static/natlibcat/html/advanced.html">Advanced Search</a></label> --></span>
                    {$lcfielded}
                </form>
                <span class="searchhelp">
                    <a href="/static/natlibcat/html/help.html">Search Tips</a>
                </span>
            </div>
        </div>
    let $lcresultsblock :=
        <div id="ds-results"><!-- hold --></div>
    let $spacer :=    
        <div class="search-box">            
            <div style="width: 60%; margin-left: 300px; text-align:center;">               
                {
                    if(lp:get-param-single($lp:CUR-PARAMS,'/page') eq "search") then 
                    (                        
                        <div style="text-align:left; width: 70%;" id="search-instructions">
                            <h3 class="dots">Current contents of the XML Datastore <esi:include src="/xq/lscoll/natlibcat-estimate.xqy"/></h3>
                            <div style="font-size: 10pt; margin-top: 25px; padding: 20px; background-color: #F8FAE0; border: 2px solid #e2e2e2;">
                                <p>The National Library Catalog (beta) is an online catalog offering new ways to search the Library of Congress collections.  In addition to keyword search, it also allows researchers to easily identify materials that are available online and narrow search results based on selected facets or item characteristics.  This initial beta release contains all the records from the Library’s traditional online catalog (<a href="http://catalog.loc.gov/">catalog.loc.gov</a>), with more data sets to be added soon, from sources such as the multimedia Performing Arts Encyclopedia, Encoded Archival Description (EAD) Finding Aids, and the Tibetan Oral History Project.  Eventually all the bibliographic catalogs throughout the Library will be brought into this system allowing for more comprehensive search results.  All metadata records in the National Library Catalog (beta) are available for download in the MARCXML, MODS, Dublin Core (SRW), and METS schemas.</p>
                                <p>Library Services is eager to get feedback from staff during this initial beta release.  Please send comments to <a href="mailto:ils@loc.gov">ils@loc.gov</a>.</p>
                            </div>
                        </div>
                    )
                    else
                        <!-- <hr/> -->
                }              
            </div>
            <br class="break"/>    
        </div>
    return
        ($lcsearchblock, $lcresultsblock, $spacer)
};