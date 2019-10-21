xquery version "1.0-ml";

module namespace util="info:lc/xq-modules/alto-utils";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace alto = "http://schema.ccs-gmbh.com/ALTO";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ndnp="http://www.loc.gov/ndnp";

declare function util:make-paragraphs($begin as xs:integer, $end as xs:integer) as empty-sequence() {
    let $list := cts:uri-match("/alto/*.xml")[$begin to $end]
    for $thing in $list
    return
        if (doc($thing)/alto:alto/alto:Layout/alto:Page/alto:PrintSpace/alto:TextBlock) then
            for $bl in doc($thing)/alto:alto/alto:Layout/alto:Page/alto:PrintSpace/alto:TextBlock
            return
                if ($bl/alto:TextLine/alto:String/@CONTENT and not($bl/alto:p)) then
                   xdmp:node-insert-child($bl, <alto:p>{string-join($bl/alto:TextLine/alto:String/@CONTENT/string(), " ")}</alto:p>)
                else
                    ()
        else
            ()
};

declare function util:get-mets-uri($docuri as xs:string) as xs:string {
    let $tox := tokenize($docuri, "/")
    let $last := $tox[last()]
    let $base := $tox[last() - 1]
    let $dirpath := substring-before($docuri, $last)
    let $mets := cts:uri-match(concat($dirpath, $base, "*.xml"))[1]
    return $mets
};

declare function util:get-alto-title($docuri as xs:string) as element(a) {
    let $pagetok := tokenize($docuri, "/")[last()]
    let $prepage := substring-before($pagetok, ".alto.xml")
    let $metspage := replace($prepage, "^0*(\d+)", "$1", "mi")
    let $uri := util:get-mets-uri($docuri)
    let $metspath := concat("doc('", $uri, "')/mets:mets")
    let $page := util:seq-from-mets($metspath, $metspage)
    let $papertitle := xdmp:eval(concat($metspath, "/@LABEL/string()"))
    let $displaytitle := concat($papertitle, ", Page ", $page)
    let $displaytox := util:ndnp-uri-tox($metspath)
    let $displayuri := concat("http://chroniclingamerica.loc.gov/lccn/", $displaytox[1], "/", $displaytox[2], "/ed-", $displaytox[3], "/seq-",  $page, "/")
    return <a href="{$displayuri}">{$displaytitle}</a>
};

declare function util:ndnp-uri-tox($mets as xs:string) as xs:string+ {
    let $mets := xdmp:eval($mets)
    let $mods := $mets/mets:dmdSec[@ID='issueModsBib']/mets:mdWrap/mets:xmlData/mods:mods
    let $id := $mods/mods:relatedItem[@type='host']/mods:identifier[@type='lccn']/string()
    let $ed := $mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='edition']/mods:number/string()
    let $date := $mods/mods:originInfo/mods:dateIssued/string()
    return ($id, $date, $ed)
};

declare function util:seq-from-mets($mets as xs:string, $val as xs:string) as xs:string {
    let $mets := xdmp:eval($mets)
    let $seq :=
        for $s in $mets/mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods
        where matches($s/mods:relatedItem/mods:identifier[@type='reel sequence number'], $val)
        return $s/mods:part/mods:detail[@type='page number']/mods:number/string()
    return
        if (string-length($seq) gt 0) then
            $seq
        else
            "1"

};
