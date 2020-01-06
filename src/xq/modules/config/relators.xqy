xquery version "1.0-ml";

module namespace relators = "info:lc/xq-modules/config/relators";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace id = "http://id.loc.gov/vocabulary/relators/";
declare namespace idx = "info:lc/xq-modules/index-utils";
declare namespace modsrdf = "http://www.loc.gov/standards/mods/modsrdf/modsOntology.owl#";
declare namespace madsrdf = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mets    		 	= "http://www.loc.gov/METS/";
declare private function relators:getRelatorsAbstract($rels as xs:string+, $relatorType as xs:string) as element(rdf:RDF) {
    let $opts := ("case-insensitive", "diacritic-sensitive", "punctuation-sensitive", "whitespace-insensitive", "unstemmed", "unwildcarded")
    let $qname :=
        if ($relatorType eq "code") then
            "skos:notation"
        else
            "skos:prefLabel"
    let $hits := 
        for $z in $rels
        let $ewq := cts:element-value-query(xs:QName($qname), $z, $opts)
        return 
            (:(cts:search(doc("/config/relators.skos.rdf"), $ewq))//rdf:Description[matches(xdmp:value($qname), $z, "i")]:)
            (cts:search(doc("/config/relators.skos.rdf"), $ewq))//rdf:Description[cts:contains(xdmp:value($qname), cts:word-query($z, $opts))]
    return
            <rdf:RDF xmlns:xs="http://www.w3.org/2001/XMLSchema#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:vs="http://www.w3.org/2003/06/sw-vocab-status/ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
                {$hits}
            </rdf:RDF>
};

declare function relators:getRelatorsByCode($rels as xs:string+) as element(rdf:RDF) {
    relators:getRelatorsAbstract($rels, "code")
};

declare function relators:getRelatorsByTerm($rels as xs:string+) as element(rdf:RDF) {
    relators:getRelatorsAbstract($rels, "term")
};

declare function relators:getRelators($rels as xs:string+) as element(rdf:RDF) {
    relators:getRelatorsByCode($rels)
};

declare function relators:getPrefLabels($rdf as element(rdf:RDF)) as xs:string* {
    for $term in $rdf/rdf:Description/skos:prefLabel[@xml:lang='en'] 
    return
        string($term)
};

declare function relators:getNotations($rdf as element(rdf:RDF)) as xs:string* {
    for $code in $rdf/rdf:Description/skos:notation
    return
        string($code)
};

declare function relators:getTerms($rdf as element(rdf:RDF)) as xs:string* {
    relators:getPrefLabels($rdf)
};

declare function relators:getCodes($rdf as element(rdf:RDF)) as xs:string* {
    relators:getNotations($rdf)
};

declare function relators:byName($prefLabel as xs:string, $id-uri as xs:anyURI, $statementPosition as xs:string) as map:map* {
    let $hits := (cts:search(collection("/catalog/")/mets:mets, cts:element-value-query(xs:QName("idx:byName"), $prefLabel)))//idx:byName[@role][text() eq $prefLabel]
    let $map := map:map()
    return
        if ($hits) then
            let $out :=
                for $role at $i in $hits
                let $mluri := xdmp:node-uri($role)
                let $rdfuri := concat("http://id.loc.gov/resources/lcdb/bib/", replace(substring-before($mluri, ".xml"), ".+/(\d+)$", "$1"))
                let $label := $role/@role/string()
                let $labeltox := tokenize($label, " \| ")
                for $tox in $labeltox
                let $itermap := map:map()
                let $tryrdf :=
                    if (string-length($tox) eq 3) then
                        relators:getRelatorsByCode($tox)
                    else
                        relators:getRelatorsByTerm($tox)
                return
                  if (not($tryrdf/rdf:Description)) then
                        (
                          map:put($itermap, "resourceURI", $rdfuri),
                          map:put($itermap, "relatorAuthoritySource", "local"),
                          map:put($itermap, "relatorAuthorityURI", "local"),
                          map:put($itermap, "originalResourceRelatorLabel", $tox), $itermap
                        )
                  else
                        let $newlabel :=
                            if ($statementPosition eq "rdf:subject") then
                                concat(relators:getNotations($tryrdf), "Of")
                            else
                                relators:getNotations($tryrdf)
                        let $qname := concat("id:", $newlabel)
                        return
                            (
                                map:put($itermap, "resourceURI", $rdfuri),
                                map:put($itermap, "relatorCode", relators:getNotations($tryrdf)) ,
                                map:put($itermap, "relatorAuthorityURI", "http://id.loc.gov/vocabulary/relators"),
                                map:put($itermap, "relatorAuthoritySource", "marcrelator"),
                                map:put($itermap, "revisedResourceRelatorLabel", $newlabel),
                                map:put($itermap, "relatorQName", $qname),
                                map:put($itermap, "originalResourceRelatorLabel", $tox),
                                $itermap
                            )
          let $_ := 
          (
                map:put($map, "authorityLabel", $prefLabel), 
                map:put($map, "authorityURI", $id-uri), 
                map:put($map, "authorityURIStatementPosition", $statementPosition), 
                map:put($map, "hits", $out)
            )
            return $map
        else
            $map
};