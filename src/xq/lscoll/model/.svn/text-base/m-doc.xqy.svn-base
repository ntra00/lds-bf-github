xquery version "1.0-ml";

module namespace md = "http://www.marklogic.com/ps/model/m-doc";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace search="http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace e = "http://marklogic.com/entity";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace lcvar="info:lc/xq-invoke-variable";

declare variable $e-ns := "http://marklogic.com/entity";

declare function md:get-title($result) {
  let $retval := string($result//mlapp:metadata/@title)
  let $retval := if ($retval) then $retval else $result//mlapp:metadata/@orig-name
  let $retval := if ($retval) then $retval else substring($result//mlapp:metadata/mlapp:summary/text(), 1, 30)
  let $retval := if ($retval) then $retval else base-uri($result)
  return normalize-space($retval)
};

declare function md:matching-text($highlight-query, $doc) {
    md:matching-text($highlight-query, $doc, ())
};

declare function md:matching-text($highlight-query, $doc, $color as xs:string?) {
    let $xmlQuery := <a>{$highlight-query}</a>
    let $result := <span><span>{$doc//mlapp:body/node()}</span></span>
    let $snippet := search:snippet($result, $xmlQuery/node())
    return
        md:snippet-recurse($snippet/search:match/node(), $color)
};

declare function md:snippet-recurse($things as node()*, $color as xs:string?) {
    for $x in $things
    return
        typeswitch ($x)
          case element(search:highlight) return (
            if($color) then
                <span style="background-color:{$color}" class="highlt">
                    {md:snippet-recurse($x/node(),$color)}
                </span>
            else
                <span class="highlt">
                    {md:snippet-recurse($x/node(),$color)}
                </span>,
            " "
          )
          case text() return $x      
          default return (md:snippet-recurse($x/node(),$color)," ")
};

declare function md:get-date($result) {
    $result//mlapp:doc-date/text()
};



declare function md:convertEntities($nodes) {

    let $entity-count := 0
    return

    for $node in $nodes
    let $ln := local-name($node)
    let $ns := namespace-uri($node)
    return
        if($ln eq "") then 
            $node
        else if ($ns eq $e-ns) then
            element xhtml:span {
                attribute class {"entity"},
                attribute id {$entity-count},
                attribute type {$ln},
                $node/@*,
                md:convertEntities($node/node()),
                xdmp:set($entity-count,$entity-count + 1)
            }
        else
            element { xs:QName(concat("xhtml:",$ln)) } {
                $node/@*,
                md:convertEntities($node/node())
            }
};

declare function md:binary-original($doc) {
    let $binary-uri := $doc//mlapp:metadata/mlapp:original-binary/text()
    return
        if($binary-uri) then (
            let $mime := xdmp:uri-content-type($binary-uri)
            let $pic := 
                if($mime eq "application/msword") then
                  "/images/ms_word.gif"
                else
                  ()
            let $link :=
              <a href="/api/get-document.xqy?uri={encode-for-uri($binary-uri)}&amp;type=download">
                <div style="text-align:center;">
                    {
                    if($pic) then
                        <img src="{$pic}"/>
                    else ()
                    }
                    <div>Download Original</div>
                </div>
                
              </a>
                 
            return
            <div class="fright">{$link}</div>,
            <br class="break"/>
        )
        else 
            ()
};



declare function md:lcrender($uri as xs:string) {
    let $params := lp:param-string($lp:CUR-PARAMS)
    let $vars := concat("id=", $uri, ";;", "mime=text/html", ";;", "view=ajax", ";;", "params=", $params)
    let $xml :=
        try {
            xdmp:invoke("/xq/lscoll/renderajax.xqy", (xs:QName("lcvar:ajaxdata"), $vars))
        } catch($e) {
            $e
        }
    return $xml
};