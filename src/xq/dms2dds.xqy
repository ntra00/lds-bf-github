xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight" at "/nlc/lib/l-highlight.xqy";

declare function local:dms2dds($dms as xs:string) {
    let $neg := if (matches($dms, "-.*")) then ("-") else ("")
    let $degrees := 
        if (matches($dms,  "(-?)(\d+)(d)(\d+)(m)(\d+)(s)"))
            then (replace($dms, "(-?)(\d+)(d)(\d+)(m)(\d+)(s)", "$2"))
        else if (matches($dms,  "(-?)(\d+)(d)(\d+)(m)"))
            then (replace($dms, "(-?)(\d+)(d)(\d+)(m)", "$2"))
        else if (matches($dms,  "(-?)(\d+)(d)"))
            then (replace($dms, "(-?)(\d+)(d)", "$2"))
        else ()
     
    let $minutes := 
        if (matches($dms,  "(-?)(\d+)(d)(\d+)(m)(\d+)(s)"))
            then (replace($dms, "(-?)(\d+)(d)(\d+)(m)(\d+)(s)", "$4"))
        else if (matches($dms,  "(-?)(\d+)(d)(\d+)(m)"))
            then (replace($dms, "(-?)(\d+)(d)(\d+)(m)", "$4"))
        else ()
    
    let $seconds := 
        if (matches($dms,  "(-?)(\d+)(d)(\d+)(m)(\d+)(s)"))
            then (replace($dms, "(-?)(\d+)(d)(\d+)(m)(\d+)(s)", "$6"))
        else ()
    
    let $d := if ($degrees) then (number($degrees)) else ()
    let $m := if ($minutes) then (number($minutes) div 60) else (0)
    let $s := if ($seconds) then (number($seconds) div 3600) else (0)
    let $dd := $d + $m + $s
    let $decimal := round-half-to-even($dd, 7)
    return concat($neg, $decimal)
};

(:expects something like 11d47m17s	-42d19m53s	10d53m48s	43d48m18s ... tokenizes on the 's' for seconds  :)
let $incoords as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'coords')
let $toxcoord := tokenize($incoords, "s")
let $out := for $c in $toxcoord return local:dms2dds(concat($c, "s"))
return string-join($out, " ")