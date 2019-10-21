xquery version "1.0-ml";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy"; 
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace djvu = "http://www.loc.gov/djvu";
declare namespace lc = "info:lc/xq-modules/noindex";
declare namespace l = "local";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

(: to be called  by javascript: build a div of search results in pages :)

declare  function local:ia-search($uri, $page)  {
    (: For search form :)
    let $q as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q')
    let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
    let $url:=concat($url-prefix,'parts/ia-search.xqy?uri=',$uri)

    let $count := lq:djvu-search-count($uri)

    return
        (
      	<div class="access-box">
      		<form onsubmit="return searchFullText(this);" method="GET" style="margin-bottom:0px; padding-bottom:0px;">
      		<label for="searchcollection" class="box-label">Search within text:</label><br />
      			<input name="q" type="text" size="50"  maxlength="125"  class="txt" value="{$q}" onfocus="this.value=''" id="searchcollection"/>
      			<button id="submit">Go</button><input name="url" type="hidden" value="{$url}"  id="objid"/>
      		</form>
      	</div>,
      		if ($count = 0) then
      		    <p>There are no results for &quot;<span>{$q}</span>&quot;.</p>
      		else
      		    let $images_per_pages := 10
      		    let $mets:= utils:mets($uri)/mets:fileSec/mets:fileGrp
      		    let $volumes := distinct-values($mets//mets:file/@GROUPID/string())
                let $search := lq:djvu-search-results($uri, (), $page, $images_per_pages, '')
                let $query := <qu>{lq:get-highlight-query()}</qu>
                return
                    (<div class="txt-yoursearch">Your search for &quot;<span>{$q}</span>&quot; was found in {$count} page{if ($count > 1) then 's' else ""}.</div>,
                    <div id="scrolls_search" class="search_navigation">
                    <ul class="scrolls">
                    {for $did in $search
                        let $words_in_page := $did//*:found_word/parent::djvu:WORD
                        let $num_occs := 
                                if (count($query//cts:text) = 1) then
                                   count($words_in_page) div count(cts:tokenize($query//cts:text)[. instance of cts:word])
                                else count($words_in_page)
                        let $image_num := xs:integer($did/@n/string())
                        let $page_id := $did/@id/string()
                        let $group_id := tokenize($page_id,'_')[1]
                        let $text_num := index-of($volumes,$group_id)
                        let $file_id := tokenize($page_id,'_')[2]
                        let $image_link := $mets/mets:file[@GROUPID=$group_id and @ID=$file_id]/mets:FLocat/@xlink:href/string()
                        let $word_coords := 
                            for $word at $count in $words_in_page
                                let $inner_coords := concat(' { ','"x" : "',$word//lc:x/string(),'", "y" : "',$word//lc:y/string(),'", "width" : "',$word//lc:width/string(),'", "height" : "',$word//lc:height/string(),'" } ')
                                  return 
                                    if ($count < count($words_in_page)) then
                                        concat($inner_coords,",")
                                    else $inner_coords
                        return
                            <li>
                            <a class="scroll" onclick="fromSearchResults(event,{xs:integer($image_num) - 1},{$text_num - 1},[{$word_coords}]); return false;" href="">
                            <img src="{$image_link}/100"/>
                            <p>Text {$text_num} - Image {$image_num} - {$num_occs} occurence{if ($num_occs > 1) then 's' else ""}</p>
                            </a>
                            </li>
                    }
                    </ul>
                    </div>,
                    (:Instead of infinite scroll, add button at bottom that searches for more results?:)
                    (:<div id="scroll_footer"><p>Loading more results...</p></div>:)
                    (: Don't need to display more results link if we know we've reached the end. :)
                    if (count($search) < $images_per_pages or $count = count($search)) then
                        <div class="more_results"><p class="more_results">End of results</p></div>
                    else
                        <div class="more_results"><p class="more_results"><a class="more_results" href="#">Click for more results</a></p></div>
                    )
               )
};

declare  function local:ia-page($uri, $num, $gid)  {
    let $pnum :=  functx:pad-integer-to-length(xs:integer($num),4)
    let $search := lq:djvu-search-results($uri, $pnum, '', 1, $gid)[1] (: at most one result :)

    let $words_in_page := $search//*:found_word/parent::djvu:WORD
    let $word_coords := 
        for $word at $count in $words_in_page
            let $inner_coords := concat(' { ','"x" : "',$word//lc:x/string(),'", "y" : "',$word//lc:y/string(),'", "width" : "',$word//lc:width/string(),'", "height" : "',$word//lc:height/string(),'" } ')
              return 
                if ($count < count($words_in_page)) then
                    concat($inner_coords,",")
                else $inner_coords
    return
      (concat('['),$word_coords,']')
};

let $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'uri')
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $num := lp:get-param-single($lp:CUR-PARAMS, 'pnum', '')
let $page := lp:get-param-single($lp:CUR-PARAMS, 'page', '1')
let $gid := lp:get-param-single($lp:CUR-PARAMS, 'gid', '')
return
 	(
                xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
                xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                if ($num = '') then 
				'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
					else ()
				,
				if ($num = '') then
                 local:ia-search($uri, $page)
                else
                 local:ia-page($uri,$num,$gid)
            )
