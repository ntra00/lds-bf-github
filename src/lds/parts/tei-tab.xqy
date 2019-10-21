xquery version "1.0-ml";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight" at "/nlc/lib/l-highlight.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace l = "local";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

(: to be called  by javascript: build a div of tei transcript based on a part of a document (itemID=T07) :)

declare private function local:tei-div($uri as xs:string, $itemID as xs:string, $form as element(div))  {
(: returns whole tei as div with q terms highlighted :)
 let $mets:= utils:mets($uri)
 
let $tei := 
  	if ($mets//tei:TEI) then
  		utils:tei-file($mets,$itemID)
	else
		()
(:		all part tei plus metadata :)
 return 
    (
	  $form	,
		<h2>{$tei//l:title/string()}</h2>,

		if ($tei//l:names) then 
			<h3 >Participants: {$tei//l:names/string()}</h3>
	 	else (),	

 		if (exists($mets//tei:TEI)) then
        	try {
	            xdmp:xslt-invoke("/xslt/pageturner/tei2HTML.xsl", $tei)/div
    	    } catch ($exception) {
        	    $exception
        	}     
		else ()
	)
};

declare private  function local:tei-snip($uri as xs:string, $form as element(div), $q as xs:string) as element(div)  {
(: returns snippets of search terms, in each part, with $q highlighted :)


	let $mets:= utils:mets($uri)
 
  	let $snippets := 
  		<l:snip>{
	        if ($mets//tei:TEI) then 
			  for $teidoc at $i in $mets//tei:TEI
			  let $result:= lq:tohap-tei-snippet($teidoc)
	           return 	if (exists($result)) then
			  			 <l:file><l:itemID>{$teidoc//ancestor::mets:file/@ID/string()}</l:itemID>
			   				{$result}
			  			</l:file>
						else 
			 				()
	        else
	           () (: <search:snippet/>:)
		}
		</l:snip>
	let $tei:=	utils:tei-meta($mets)
 	
	(:<li> Found {count($snippets//search:match)} hits</li>:)
 	return 
	 (: makes it hidden for some reason... <div id="fulltext" class="tab_content">:)
	 <div>
		<h2 class="hidden">Text/Transcript Search Results</h2> 
		{$form}
		<div class="txt-yoursearch">Your search for &quot;<span>{$q}</span>&quot; was found {count($snippets//search:match)} times.</div>
				 
			{for $file at $count in $snippets//l:file

					 let $fileID:= $file/l:itemID/string()
					 let $metatitle:=$tei//l:meta[l:key=$fileID]/l:title/string()	
					 let $linked-snippet:=
							()
					return 					
						 (
						 	<h2><a id="{$fileID}" class="player_trigger" href="">{$metatitle}</a> [found {count( $file//search:match	)} times.]</h2>
						  ,
						  <ul class="std">						 	
							{for $match in $file//search:match								
								let $para-id:=xdmp:unpath(
												concat($match/@path/string(),"/@xml:id/string()")
									 			)
								
							     (: can't use '#' because it messes up jQuery when trying to call an element by it's id :)
							     let $concat_id:=concat($fileID,'_',$para-id)
								 
								return 
									(												
									<li>
									<code id="{$concat_id}" style="display:none">{$count}</code>
									<a id="{$concat_id}" class="snippet_trigger" href="">{lh:snippet-highlight($match)}</a></li>)
				 			}
						</ul> )
				}	
			
	</div>
};


let $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'uri')
(: snippets or div :)
let $tabtype as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'tabtype')
let $itemID as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'itemID','T01')
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
let $url:=concat($url-prefix,'parts/tei-tab.xqy?uri=',$uri)
let $q as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q','')
(: id=ds-quicksearch:)
let $form := <div class="access-box">
			<form onsubmit="return searchFullText(this);" method="GET" style="margin-bottom:0px; padding-bottom:0px;">
			<label for="searchcollection" class="box-label">Search within text/transcript:</label><br />
				<input name="q" type="text" size="50"  maxlength="125"  class="txt" value="{$q}" onfocus="this.value=''" id="searchcollection"/>
				<button id="submit">Go</button><input name="url" type="hidden" value="{$url}"  id="objid"/>
			</form>
		</div>
return
 	(
                xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
                xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                if (matches($mime, "text/html")) then 
				'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
					else ()
				,
                 if ($tabtype ='snippets') then
				  	local:tei-snip($uri,$form,$q)
				  else
				  	local:tei-div($uri, $itemID,$form)
				
            )
