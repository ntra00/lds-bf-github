xquery version "1.0-ml";

module namespace vb = "http://www.marklogic.com/ps/view/v-browse";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace mets = "http://www.loc.gov/METS/";

declare default collation "http://marklogic.com/collation/en/S1";

declare function vb:render($results as xs:string*, $field as xs:string, $direction as xs:string) as element(div) {
    let $hits := vb:make-hits($results, $field)
    let $first := $hits/li[1]/a/text()
    let $last := $hits/li[last()]/a/text()
    let $rescount := count($results)
    let $nav := vb:browse-nav($first, $last, $field, $rescount)
    let $h1 := 
        if (matches($field, "author", "i")) then
            "Author Headings"
        else if (matches($field, "subject", "i")) then
            "Subjects Headings"
        else if (matches($field, "title", "i")) then
            "Title Headings"
        else if (matches($field, "class", "i")) then
            "Classification list"
        else
            ()
    return
        <div id="ds-results">
            <div id="ds-browseresults">
                <h1 id="title-bottom">{concat("Browse ", $h1)}</h1>
                {($nav, $hits, $nav)}
            </div>
        </div>
};

declare function vb:make-hits($terms as xs:string*, $field as xs:string) as element(ul) {
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
                let $uri := concat("/xq/lscoll/app.xqy#/page=results&amp;count=10&amp;sort=score-desc&amp;pg=1&amp;precision=exact&amp;qname=", $qname, "&amp;q=", $term)
                let $evenodd :=
                    if ($i mod 2 eq 0) then
                        "even"
                    else
                        "odd"
                return
                    <li class="{$evenodd}">
                        <a href="{$uri}">{$term}</a>
                        <span>[{$freq}]</span>
                    </li>
            else
                <li class="odd">No heading with this value exists</li>
        }
        </ul>
};

declare function vb:browse-nav($first as xs:string?, $last as xs:string?, $browsefld as xs:string, $rescount as xs:integer) as element(ul) {
    <ul class="browseresults-nav">
    {
        let $browseback := xdmp:get-session-field("browseback", "/xq/lscoll/index.xqy")
        let $back := <li><a id="backtodetail" class="back" href="/xq/lscoll/app.xqy#{$browseback}">Back to result</a></li>
        return
            if ($rescount eq 0) then
                $back
            else
                let $prev := <li><a class="previous" href="{concat('/xq/lscoll/app.xqy#/page=browse&amp;browse-order=descending&amp;q=', $first, '&amp;browse=', $browsefld)}">Previous</a></li>
                let $next := <li><a class="next" href="{concat('/xq/lscoll/app.xqy#/page=browse&amp;browse-order=ascending&amp;q=', $last, '&amp;browse=', $browsefld)}">Next</a></li>
                return
                    ($back, $prev, $next)
    }
    </ul>
};