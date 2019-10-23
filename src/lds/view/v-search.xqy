xquery version "1.0-ml";

module namespace vs = "http://www.marklogic.com/ps/view/v-search";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";

declare namespace param = "http://www.marklogic.com/ps/params";
declare namespace esi = "http://www.edge-delivery.org/esi/1.0";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default collation "http://marklogic.com/collation/en/S1";

declare function vs:render() as element(div) {
    let $mypage := lp:get-param-integer($lp:CUR-PARAMS, 'pg', 1)
    let $sortorder as xs:string? := lp:get-param-single($lp:CUR-PARAMS,'sort','score-desc')            
    (:let $collection := lp:get-param-single($lp:CUR-PARAMS, 'collection')         :)
    let $count-str :=    lp:get-param-single($lp:CUR-PARAMS, 'count')
    let $count := lp:get-param-integer($lp:CUR-PARAMS,'count',$cfg:RESULTS-PER-PAGE)        
    let $longcount := if($count = (10,25,$cfg:RESULTS-PER-PAGE)) then $count else $cfg:RESULTS-PER-PAGE
    let $q1 as xs:string? := lp:get-param-single($lp:CUR-PARAMS,'q')
    let $qname as xs:string? := lp:get-param-single($lp:CUR-PARAMS,'qname')            
	
	let $url-prefix := $cfg:MY-SITE/cfg:prefix/string()
	let $branding :=  $cfg:MY-SITE/cfg:branding/string()
	let $collection:=  $cfg:MY-SITE/cfg:collection/string()
	let $site-title:=  $cfg:MY-SITE/cfg:label/string()
	(:let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)
	let $collection as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'collection', $cfg:DEFAULT-COLLECTION)
	let $url-prefix:=concat("/",$branding,"/"):)

    let $lcfielded :=
        <select name="qname" size="1" id="lc-fielded" tabindex="1">
            <option value="keyword">
                {if ($qname eq "keyword" or not(empty($qname))) then attribute selected {"selected"} else ()}
                Everything
            </option>
            {if ($branding!="tohap") then
            <option value="idx:mainCreator">
                {if ($qname eq "idx:mainCreator") then attribute selected {"selected"} else ()}
                Author/Creator
            </option>
            else 
             <option value="idx:byName">
                {if ($qname eq "idx:byName") then attribute selected {"selected"} else ()}
                Creator/Contributor
            </option>
            }
            {if ($branding!="tohap") then (: tohap has no subjects, just interview locations in hierarch geo:)
            <option value="idx:subjectLexicon">
                {if ($qname eq "idx:subjectLexicon") then attribute selected {"selected"} else ()}
                Subject
            </option>
            else ()
            }
            <option value="idx:titleLexicon">
                {if ($qname eq "idx:titleLexicon") then attribute selected {"selected"} else ()}
                Title
            </option>
              {if ($branding="tohap") then
	            (<option value="mods:dateCaptured">
	                {if ($qname eq "mods:dateCaptured") then attribute selected {"selected"} else ()}
	                Date Recorded
	            </option>,
	            <option value="idx:abstract">
	                {if ($qname eq "idx:abstract") then attribute selected {"selected"} else ()}
	                Abstract
	            </option>,
			    <option value="idx:aboutPlace">
	                {if ($qname eq "idx:aboutPlace") then attribute selected {"selected"} else ()}
	                Place of Recording
	            </option>)  
		       else ()
            }
			 <option value="idx:lccn">
                {if ($qname eq "idx:lccn") then attribute selected {"selected"} else ()}
                LCCN
            </option>
        </select>


    let $lcsearch := <input value="{$q1}" type="text" alt="q" name="q" size="60" maxlength="200" class="txt" id="quick-search-box" tabindex="2" />
    let $preserve-param-inputs :=
        for $param in ($lp:CUR-PARAMS//param:param)[not(param:name/text() = ('q','qname','precision','behavior','itemID','branding','collection'))]
        	let $name := $param/param:name/text()
        	let $value := $param/param:value/text()
        	return
		        if($name eq 'pg') then
		            <input value="1" type="hidden" alt="{$name}" name="{$name}"  />
		        else
				if($name != 'uri') then
               		<input value="{$value}" type="hidden" alt="{$name}" name="{$name}"  />			   	
			   else ()
		       
    let $search-title:=
			if ($branding!='lds') then 
				<h3>{$site-title}</h3> 
				else
				 ()
			 
    let $lcsearchblock :=
        <div id="ds-search">
            <div id="ds-quicksearch"><!--{$search-title}-->
                <form id="quick-search" method="get" action="{$url-prefix}search.xqy">
                    <fieldset>
                        {$lcsearch}
                        {$preserve-param-inputs}
                        {$lcfielded}
                        <button id="indexSubmit" tabindex="3">Search</button>
                    </fieldset>
                </form>
              {if ($branding='lds') then  
			    <span class="searchhelp">
                    <a href="/static/lds/html/help.html">Search Tips</a>
                </span>
				else ()
				}
            </div>
        </div>
    return
        $lcsearchblock
};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)