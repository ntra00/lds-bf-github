xquery version "1.0-ml";

module namespace utils = "info:lc/xq-modules/pagination";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function utils:display-results-pagination($start as xs:integer, $current-page-items as xs:integer, $total-items as xs:integer, $page-size as xs:integer, $request as xs:string) as element(ul)* { 
 
  if ($total-items lt $page-size) then  
    ()
  else
    (: which page are we on? if there are more than 20 pages, display a sliding window :)
    let $range := 4
    let $this-page := xs:integer(ceiling($start div $page-size))
    let $number-of-pages := xs:integer(ceiling($total-items div $page-size))
    let $first-visible-page := max((1, $this-page - $range))
    let $last-visible-page := (:min(($this-page + $range, $number-of-pages)) :)
        if ($number-of-pages le (1 + ($range * 2))) then
            $number-of-pages
        else if ($this-page le $range) then
            (1 + ($range * 2))        
        else
            min(($this-page + $range, $number-of-pages))
    let $enable-first :=
        if (($this-page - 1) ge ($range + 1)) then
            <li>{utils:get-first-pagination-link("1", 1, $request)}</li>
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

declare function utils:get-first-pagination-link($text as xs:string, $start as xs:integer, $request as xs:string) as element(a) {
  <a rel="nofollow" style="border-right: 0px; padding-right: 0px;" href="{ utils:pagination-href($start, $request) }">{$text}<span class="elipses"> ...</span></a>
};

declare function utils:get-pagination-link($text as xs:string, $start as xs:integer, $request as xs:string) as element(a) {
  <a rel="nofollow" href="{ utils:pagination-href($start, $request) }">{$text}</a>
};

declare function utils:get-pagination-link($text as xs:string, $start as xs:integer, $style as xs:string, $request as xs:string) as element(a) {
  <a rel="nofollow"  style="{$style}" href="{ utils:pagination-href($start, $request) }">{$text}</a>
};

declare function utils:pagination-href($start as xs:integer, $request as xs:string) as xs:string {
  utils:pagination-href($start, (), (), $request)
};

declare function utils:pagination-href($start as xs:integer, $keys as xs:string*, $values as xs:string*, $request as xs:string ) as xs:string {
    (: concat("/lds/search.xqy?", replace($request, "(&amp;)?pg=\d+", concat("$1pg=", $start))) :)
    let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)
	let $url-prefix:=concat("/",$branding,"/")
    let $pattern := "pg=\d+"
    let $new-param := concat("pg=",$start)
    return
    
    fn:concat($url-prefix,"search.xqy?",
    
      if(matches($request,$pattern)) then
          replace($request, $pattern, $new-param)
      else
          string-join((if($request) then $request else (),$new-param),"&amp;")
    
    )
    
};
