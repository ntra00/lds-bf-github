xquery version "1.0-ml";

module namespace vb = "http://www.marklogic.com/ps/view/v-browse";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace lang = "xdmp:encoding-language-detect";

declare default collation "http://marklogic.com/collation/en/S1";

declare function vb:render($results as xs:string*, $field as xs:string, $direction as xs:string) as element(div) {
    let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
    let $hits := vb:make-hits($results, $field, $url-prefix)
    let $first := $results[1]
    let $last := $results[last()]
    let $rescount := count($results)
    let $nav := vb:browse-nav($first, $last, $field, $rescount, $url-prefix)
    let $h1 := 
        if (matches($field, "author", "i")) then
            "Name Headings"
        else if (matches($field, "subject", "i")) then
            "Subject Headings"
        else if (matches($field, "title", "i")) then
            "Title Headings"
        else if (matches($field, "class", "i")) then
            "LC Classification"
        else
            ()
    return
        <div id="dsresults">
            <div id="ds-browseresults">
                <h1 id="title-bottom">{concat("Browse ", $h1)}</h1>
                {($nav, $hits, $nav)}
            </div>
        </div>
};

declare function vb:make-hits($terms as xs:string*, $field as xs:string, $url-prefix as xs:string) as element(ul) {
    let $qname :=
        if (matches($field, "author", "i")) then
            "idx:mainCreator"
        else if (matches($field, "subject", "i")) then
            "idx:subjectLexicon"
        else if (matches($field, "title", "i")) then
            "idx:titleLexicon"
        else if (matches($field, "class", "i")) then
            "idx:lcclass"
        else
            "idx:subjectLexicon"
    return
        <ul class="browseresults-list">
        {
            if (count($terms) gt 0) then
                for $term at $i in $terms
                let $freq := cts:frequency($term)
                let $uri := concat($url-prefix,"search.xqy?count=10&amp;sort=score-desc&amp;pg=1&amp;precision=exact&amp;qname=", $qname, "&amp;q=", encode-for-uri($term))
                let $evenodd :=
                    if ($i mod 2 eq 0) then
                        "even"
                    else
                        "odd"
                let $lang := 
                    if (matches($field, "class", "i")) then
                        "zxx"
                    else
                        let $langxml := xdmp:encoding-language-detect(<node>{$term}</node>)[1]
                        return
                            $langxml/lang:language/string()
                return
                    <li class="{$evenodd}">
                        <div class="heading" xml:lang="{$lang}">
                                <a href="{$uri}">{$term}</a>
                        </div>
                        <div class="frequency">
                            [{$freq}]
                        </div>
                    </li>
            else
                <li class="odd">No heading with this value exists</li>
        }
        </ul>
};

declare function vb:browse-nav($first as xs:string?, $last as xs:string?, $browsefld as xs:string, $rescount as xs:integer, $url-prefix as xs:string) as element(ul) {
    <ul class="browseresults-nav">
    {
        let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'bq')
        let $new-params := lp:param-remove-all($new-params, 'browse-order')
        let $new-params := lp:param-remove-all($new-params, 'browse')
        let $new-params := lp:param-remove-all($new-params, 'collection')
        let $new-params := lp:param-remove-all($new-params, 'branding')
        let $new-param-str := lp:param-string($new-params)
        let $text := "Back to results"
        (: we are no longer going from the home page to the browse page, so back is always to detail.xqy for now:)
        (:let $detail-uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'uri', ()):)
        let $browseback := 
            (:if($detail-uri) then :)
                let $back-params := lp:param-remove-all($new-params, 'dtitle')				
                return
                    concat($url-prefix,"detail.xqy?", lp:param-string($back-params))
            (:else
                ("/nlc/index.xqy", xdmp:set($text,"Back"))
				:)
        let $back := <li><a class="back" href="{$browseback}">{$text}</a></li>
        return
            if ($rescount eq 0) then
                $back
            else
            
                let $prev := <li><a class="previous" href="{concat($url-prefix,"browse.xqy?",$new-param-str,"&amp;browse-order=descending&amp;bq=", encode-for-uri($first), "&amp;browse=", $browsefld)}">Previous</a></li>
                let $next := <li><a class="next" href="{concat($url-prefix,"browse.xqy?",$new-param-str,"&amp;browse-order=ascending&amp;bq=", encode-for-uri($last), "&amp;browse=", $browsefld)}">Next</a></li>
                return
                    ($back, $prev, $next)
    }
    </ul>
};