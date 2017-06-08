xquery version "1.0-ml";

module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default collation "http://marklogic.com/collation/en/S1";

declare function lh:highlight-query($x as node()) {
    typeswitch ($x) 
        case text() return $x
        case element(cts:or-query) 
          return
            if (fn:not(fn:empty($x/cts:element-value-query))) then ()
            else element {fn:node-name($x)} {$x/lh:highlight-query($x/node())}  
        case element(cts:element-value-query) return ()
        case element(cts:element-word-query) 
           return
                <cts:word-query>
                    <cts:text xml:lang="{fn:string($x/cts:text/@xml:lang)}">
                        {fn:replace($x/cts:text/text(), '"', '')}  
                    </cts:text>
                </cts:word-query>
        case element() return element {fn:node-name($x)} {$x/lh:highlight-query($x/node())}
        default return $x 
};