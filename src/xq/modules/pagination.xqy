xquery version "1.0-ml";

module namespace utils = "info:lc/xq-modules/pagination";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/xq/lscoll/view/v-search.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

(: 
Algorithm derived from the Django framework's Paginator Class: 
django.core.paginator.Paginator

Described at: 
http://docs.djangoproject.com/en/dev/topics/pagination/

This is some Python code to achieve this:

    #!/usr/bin/env python
    
    from django.core.paginator import Paginator, EmptyPage
    import sys
    import getopt
    
    def main():
        current_page = 1
        number_hits_to_return = 25
        # a list or array of hits
        myhits = [1, 2, 3]
        paginator = Paginator(myhits, number_hits_to_return)
        page_num = current_page
        page = paginator.page(page_num)
        page_range = _page_range_short(paginator, page)
        # returns a Python generator function of page numbers with our desired pagination to be iterated over
        return page_range
    
    def _page_range_short(paginator, page):
        middle = 10 
        for p in paginator.page_range:
            if p <= 3:
                yield p
            elif paginator.num_pages - p < 3:
                yield p
            elif abs(p - page.number) < middle:
                yield p
            elif abs(p - page.number) == middle:
                yield "..."
                
    if __name__ == "__main__":
        main()

:)

declare function utils:search-results-paginator($currpage as xs:int, $numpages as xs:int, $request as xs:string) as element(li)* {
    let $middle := 4 (:how many spaces in the middle between ellipses our page number will be nested :)
    let $number := $currpage (: current page number being viewed, so we want to leave out the hyperlink :)
    let $leading := 3 (: the first digits preceding the leading "..." :)
    let $trailing := 0 (: the last digits after the trailing "..." :)
    let $num_pages := $numpages (: total number of pages :)
    let $page_range := (1 to $num_pages) (: 1-based iterated index of total number of pages :)
    let $myli :=
        for $p in $page_range
        let $abs := math:fabs($p - $number)
        let $link := replace($request, "&amp;page=\d+", concat("&amp;page=", $p))
        return
            if ($p eq $number) then
                <li class="on">{vs:recursiveFormat($p cast as xs:string)}</li>
            else if ($p le $leading) then 
                <li><a href="{$link}">{vs:recursiveFormat($p cast as xs:string)}</a></li>
            else if (($num_pages - $p) lt $trailing) then 
                <li><a href="{$link}">{vs:recursiveFormat($p cast as xs:string)}</a></li>
            else if ($abs lt $middle) then
                <li><a href="{$link}">{vs:recursiveFormat($p cast as xs:string)}</a></li>
            else if ($abs eq $middle) then
                <li><a>...</a></li>
            else
                ()
    let $prev :=
        if ($number eq 1) then
            <li class="previous-off">« Previous</li>
        else
            let $math := $number - 1
            let $dirurl := replace($request, "&amp;page=\d+", concat("&amp;page=", $math))
            return
                <li><a href="{$dirurl}">« Previous</a></li>
    let $next :=
        if ($number eq $num_pages) then
            <li class="next-off">Next »</li>
        else
            let $math := $number + 1
            let $dirurl := replace($request, "&amp;page=\d+", concat("&amp;page=", $math))
            return
                <li><a href="{$dirurl}">Next »</a></li>
    return
        ($prev, $myli, $next)
};

declare function utils:ajax-search-results-paginator($currpage as xs:int, $numpages as xs:int, $request as xs:string) as element(li)* {
    let $middle := 2 (:how many spaces in the middle between ellipses our page number will be nested :)
    let $number := $currpage (: current page number being viewed, so we want to leave out the hyperlink :)
    let $leading := 3 (: the first digits preceding the leading "..." :)
    let $trailing := 0 (: the last digits after the trailing "..." :)
    let $num_pages := $numpages (: total number of pages :)
    let $page_range := (: 1-based iterated index of total number of pages :)
        if ($trailing eq 0) then
            if ($num_pages le $leading) then
                (1 to $num_pages)
            else
                ($number to ($number + $middle))
        else
            (1 to $num_pages)
    let $request-clean := fn:concat( "/xq/lscoll/app.xqy#", fn:replace( $request, "&amp;pg=\d+", "" ) )
    let $myli :=
        for $p in $page_range
        let $abs := math:fabs($p - $number)
        let $link := concat( $request-clean, concat("&amp;pg=", $p))
        return
            if ($p eq $number) then
                <li class="on">{vs:recursiveFormat($p cast as xs:string)}</li>
            else if ($p le $leading) then 
                <li><a href="{$link}">{vs:recursiveFormat($p cast as xs:string)}</a></li>
            else if (($num_pages - $p) lt $trailing) then 
                <li><a href="{$link}">{vs:recursiveFormat($p cast as xs:string)}</a></li>
            else if ($abs lt $middle) then
                <li><a href="{$link}">{vs:recursiveFormat($p cast as xs:string)}</a></li>
            else if ($abs eq $middle) then
                <li><a>...</a></li>
            else
                ()
    let $prev :=
        if ($number eq 1) then
            <li class="previous-off">« Previous</li>
        else
            let $math := $number - 1
            let $dirurl := concat($request-clean, "&amp;pg=", $math)
            return
                <li><a href="{$dirurl}">« Previous</a></li>
    let $next :=
        if ($number eq $num_pages) then
            <li class="next-off">Next »</li>
        else
            let $math := $number + 1
            let $dirurl := concat($request-clean, "&amp;pg=", $math)
            return
                <li><a href="{$dirurl}">Next »</a></li>
    return
        ($prev, $myli, $next)
};

declare function utils:display-results-pagination($start as xs:integer, $current-page-items as xs:integer, $total-items as xs:integer, $page-size as xs:integer, $request as xs:string) as element(ul)* { 
  if ($total-items lt $page-size) then  
    ()
  else
    (: which page are we on? if there are more than 20 pages, display a sliding window :)
    let $range := 3
    let $this-page := xs:integer(ceiling($start div $page-size))
    let $number-of-pages := xs:integer(ceiling($total-items div $page-size))
    let $first-visible-page := max((1, $this-page - $range))
    let $last-visible-page :=  min(($this-page + $range, $number-of-pages))
    let $enable-first :=
        if (($this-page - 1) ge ($range + 1)) then
            <li>{utils:get-pagination-link("1", 1, $request)}</li>
        else
            ()
    return
    <ul id="pagination-clean"> {
        if ($this-page le 1) then
            <li class="previous-off">« Previous</li>
        else
            <li>{utils:get-pagination-link("« Previous", (:$start - $page-size:) $this-page - 1, $request)}</li>,
            $enable-first,
            for $p in ($first-visible-page to $last-visible-page)
            return
              if ($p eq $this-page) then
                  <li class="on">{$p}</li>
              else
                  <li>{utils:get-pagination-link(string($p), (:1 + ($p - 1) * $page-size:) $p, $request)}</li>
              ,
              (: display the next-results scroller? :)
              if ($this-page ge $number-of-pages) then
                <li class="next-off">Next »</li>
              else
                <li>{utils:get-pagination-link("Next »", (:$start + $page-size:) $this-page + 1, "border-right: 0px solid #FFFFFF;", $request)}</li>
    }
    </ul>
};

declare function utils:get-pagination-link($text as xs:string, $start as xs:integer, $request as xs:string) as element(a) {
  <a href="{ utils:pagination-href($start, $request) }">{$text}</a>
};

declare function utils:get-pagination-link($text as xs:string, $start as xs:integer, $style as xs:string, $request as xs:string) as element(a) {
  <a style="{$style}" href="{ utils:pagination-href($start, $request) }">{$text}</a>
};

declare function utils:pagination-href($start as xs:integer, $request as xs:string) as xs:string {
  utils:pagination-href($start, (), (), $request)
};

declare function utils:pagination-href($start as xs:integer, $keys as xs:string*, $values as xs:string*, $request as xs:string) as xs:string {
    let $request-clean := concat("/xq/lscoll/app.xqy#", replace($request, "&amp;pg=\d+", ""))
    return concat($request-clean, concat("&amp;pg=", $start))
};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)