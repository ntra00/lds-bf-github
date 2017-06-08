xquery version "1.0-ml";

module namespace lang = "info:lc/xq-modules/config/languages";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare function lang:getLanguages($langs as xs:string+) as element(rdf:RDF) {
    let $hits := 
        for $z in $langs
        let $ewq := cts:element-value-query(xs:QName('skos:prefLabel'), $z, ("case-sensitive", "diacritic-sensitive", "punctuation-sensitive", "whitespace-sensitive", "unstemmed", "unwildcarded"))
        return 
            cts:search(doc("/config/languages.skos.rdf")/rdf:RDF/rdf:Description, $ewq)
    let $filter := 
        for $lang in $langs 
            return 
                $hits[skos:prefLabel[@xml:lang='zxx'] eq $lang]
    let $prefs := 
        for $hit in $hits 
        let $about := string($hit/@rdf:about)
        return
            <rdf:Description rdf:about="{$about}">
                {$hit/skos:prefLabel}
            </rdf:Description>
    return
        <rdf:RDF xmlns:xs="http://www.w3.org/2001/XMLSchema#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:vs="http://www.w3.org/2003/06/sw-vocab-status/ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            {$prefs}
        </rdf:RDF>
};

declare function lang:getPrefLabels($rdf as element(rdf:RDF)) as xs:string* {
    for $prefLabel in $rdf/rdf:Description/skos:prefLabel[@xml:lang='en'] return string($prefLabel)
};


