xquery version "1.0-ml";

module namespace lcc = "info:lc/xq-modules/config/lcclass";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace idx = "info:lc/xq-modules/lcindex";

declare variable $lcc:TEST1 :=
  <idx:lcc>
    <idx:lccfacet>TF - Railroad engineering and operation</idx:lccfacet>
    <idx:lcc1>T - Technology (General)</idx:lcc1>
    <idx:lcc1code>T</idx:lcc1code>
  </idx:lcc>
;

declare variable $lcc:LAW1 :=
    <idx:lcc>
      <idx:lccfacet>K - Law in general. Comparative and uniform law. Jurisprudence</idx:lccfacet>
      <idx:lcc1>K - Law</idx:lcc1>
      <idx:lcc1code>K</idx:lcc1code>
    </idx:lcc>
;

declare variable $lcc:LAW2 :=
    <idx:lcc>
      <idx:lccfacet>KJ - Law of Europe</idx:lccfacet>
      <idx:lcc2>KJ - Law of Europe</idx:lcc2>
      <idx:lcc2code>KJ</idx:lcc2code>    
      <idx:lcc1>K - Law</idx:lcc1>
      <idx:lcc1code>K</idx:lcc1code>
    </idx:lcc>
;

declare variable $lcc:LAW3 :=
    <idx:lcc>
      <idx:lccfacet>KJR - Law of Denmark</idx:lccfacet>
      <idx:lcc3>KJR - Law of Denmark</idx:lcc3>
      <idx:lcc3code>KJR</idx:lcc3code>
      <idx:lcc2>KJ - Law of Europe</idx:lcc2>
      <idx:lcc2code>KJ</idx:lcc2code>    
      <idx:lcc1>K - Law</idx:lcc1>
      <idx:lcc1code>K</idx:lcc1code>
    </idx:lcc>
;

declare function lcc:threelabel($codemax as xs:string, $stop as xs:boolean) {
    let $results:= cts:search(doc("/config/lcc.skos.rdf")/rdf:RDF/rdf:Description, cts:element-value-query(xs:QName('skos:prefLabel'), $codemax, "exact"))
    let $whole := concat($results/skos:prefLabel[@xml:lang="zxx"]/string(), " - ", $results/skos:prefLabel[@xml:lang="en"]/string())
    let $resultLabel:= 
        <idx:lccfacet>
            {$whole}
        </idx:lccfacet>
    let $num-elem :=
        <idx:lcc3>
            {$whole}
        </idx:lcc3>
    let $code-elem :=
        <idx:lcc3code>{$codemax}</idx:lcc3code>
    return
        ($resultLabel, $num-elem, $code-elem)
};

declare function lcc:twolabel($codemax as xs:string, $stop as xs:boolean) {
    let $results:= cts:search(doc("/config/lcc.skos.rdf")/rdf:RDF/rdf:Description, cts:element-value-query(xs:QName('skos:prefLabel'), $codemax, "exact"))
    let $whole := concat($results/skos:prefLabel[@xml:lang="zxx"]/string(), " - ", $results/skos:prefLabel[@xml:lang="en"]/string())
    let $num-elem :=
        <idx:lcc2>
            {$whole}
        </idx:lcc2>
    let $code-elem :=
        <idx:lcc2code>{$codemax}</idx:lcc2code>
    return
        if ($stop eq true()) then
            (<idx:lccfacet>{$whole}</idx:lccfacet>, $num-elem, $code-elem)
        else
            ($num-elem, $code-elem)
};

declare function lcc:onelabel($codemax as xs:string, $stop as xs:boolean) {
    let $results:= cts:search(doc("/config/lcc.skos.rdf")/rdf:RDF/rdf:Description, cts:element-value-query(xs:QName('skos:prefLabel'), $codemax, "exact"))    
    let $whole := concat($results/skos:prefLabel[@xml:lang="zxx"]/string(), " - ", $results/skos:prefLabel[@xml:lang="en"]/string())
    return
       if ($stop eq true()) then
            (:if stop is true, you're on a single digit code only, then return the altlabel as the specific class in lcc2 and lccfacet, and pref as the overall class in lcc1 and:)
            (:if stop is false, you're parsing a larger code, so don't return the preflabel, and only return the altlabel in lcc1 and lccfacet:)       
            let $specific := concat($results/skos:prefLabel[@xml:lang="zxx"]/string(), " - ", $results/skos:altLabel[@xml:lang="en"]/string())      
            let $num1-elem :=
                <idx:lcc1>
                    {$whole}
                </idx:lcc1>        
            let $code1-elem :=
                <idx:lcc1code>{$codemax}</idx:lcc1code>
            let $num2-elem :=
                <idx:lcc2>
                    {$specific}
                </idx:lcc2>        
            let $code2-elem :=
                <idx:lcc2code>{$codemax}</idx:lcc2code> 
            return
                (<idx:lccfacet>{$specific}</idx:lccfacet>, $num1-elem, $code1-elem, $num2-elem, $code2-elem)
        else (:stop is false:)
            (<idx:lccfacet>{$whole}</idx:lccfacet>, <idx:lcc1>{$whole}</idx:lcc1>, <idx:lcc1code>{$codemax}</idx:lcc1code>)
};

declare function lcc:getLCClass($lccode as xs:string)  {
    (:when parsing KDG, you want KDG, KD and K altlabel, not K preflabel:)    
    let $len := string-length($lccode)
    return      
        if ($len eq 3) then
            (lcc:threelabel($lccode, true()), lcc:twolabel(substring($lccode, 1, 2), false()), lcc:onelabel(substring($lccode, 1, 1), false()))
        else if ($len eq 2) then    
            (lcc:twolabel(substring($lccode, 1, 2), true()), lcc:onelabel(substring($lccode, 1, 1), false()))
        else if ($len eq 1) then
            lcc:onelabel(substring($lccode, 1, 1), true())
        else
            <idx:lccfacet>Unclassified</idx:lccfacet>    
};