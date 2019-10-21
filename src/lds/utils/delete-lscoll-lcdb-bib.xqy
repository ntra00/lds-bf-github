xquery version "1.0-ml";

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";

declare variable $maxvals := 10000;
declare variable $term := lp:get-param-single($lp:CUR-PARAMS, "term", "");
declare variable $cln := "/lscoll/lcdb/bib/";

declare function local:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};

declare function local:bib-uri-match-delete($lexstart as xs:string) as empty-sequence() {
    let $vals := cts:element-attribute-values(xs:QName("mets:mets"), QName("", "OBJID"), $lexstart, (concat("limit=", $maxvals), "collation=http://marklogic.com/collation/en/S1", "concurrent"), cts:collection-query($cln), (), ())
    for $val in $vals
    let $objid := tokenize($val, "\.")[last()]
    let $dirtox := local:chars-001($objid)
    let $file := concat($cln, string-join($dirtox, '/'), '/', $objid, '.xml')
    return 
        try {
            xdmp:document-delete($file)
        } catch($e) {
            ()
        }
};

local:bib-uri-match-delete($term)