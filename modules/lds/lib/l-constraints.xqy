xquery version "1.0-ml";

module namespace const = "info:lc/xq-modules/constraints/";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace idx = "info:lc/xq-modules/lcindex";

declare private function const:process($constraint-qtext as xs:string, $right as schema-element(cts:query), $query as element()) as schema-element(cts:query) {
    (: add qtextconst attribute so that search:unparse will work - required for some search library functions :)
    element {node-name($query)}
    { 
        attribute qtextconst {
            concat($constraint-qtext, string($right//cts:text)) 
        },
        $query/@*,
        $query/node()
    }
};

(: KPNC :)
declare function const:constraint-kpnc($constraint-qtext as xs:string, $right as schema-element(cts:query)) as schema-element(cts:query) {
    let $query :=
        <root>
        {
            let $s := string($right//cts:text/text())
            (:let $dir :=
                if ( $s eq "book")
                then concat($prefix, "book-dir/")
                else if ( $s eq "api")
                then ( concat($prefix, "api-dir1/"), concat($prefix, "api-dir2/") )
                (: if it does not match, just constrain on the prefix :)
                else $prefix:)
            (: return
                (: make these an or-query so you can look through several dirs :)
                cts:or-query((
                    (:for $x in $dir
                    return
                        cts:directory-query($x, "infinity"):)
                )) :)
            return
                cts:or-query((
                        cts:element-word-query(xs:QName("idx:aboutName"),  $s),
                        cts:element-word-query(xs:QName("idx:byName"),  $s)
                ))
        }
        </root>/*
    return
        const:process($constraint-qtext, $right, $query)
} ;

(: KISN :)
declare function const:constraint-kisn($constraint-qtext as xs:string, $right as schema-element(cts:query)) as schema-element(cts:query) {
    let $query :=
        <root>
        {
            let $s := string($right//cts:text/text())
            return
                cts:or-query((
                        cts:field-word-query("kisn-issn", $s) (:,  cts:field-word-query("kisn-issnl", $s, "exact"):)
                ))
        }
        </root>/*
    return
        const:process($constraint-qtext, $right, $query)
} ;