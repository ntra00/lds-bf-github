xquery version "1.0-ml";

module namespace lcc = "info:lc/xq-modules/config/lcclass";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare function lcc:getLCClass($codemax as xs:string )  {
(: for each code, look up the exact match preflabel, and for each broader term, 
look up the altlabel for that term :)

(:codemax=max length, 1 or 2 or 3 chars:)

let $results:=
   cts:search( doc("/config/lcc.skos.rdf")/rdf:RDF/rdf:Description, 
                        cts:element-value-query(
                                                xs:QName('skos:prefLabel'),
                                                $codemax, 
                                                "exact"
                                                )
                     )                                     
 let $resultLabel:= (:lccmax, KBE or NE  :)   
             <idx:lccfacet> 
                    {
                    concat($results//skos:prefLabel[@xml:lang="zxx"]/string()," - ",$results//skos:prefLabel[@xml:lang="en"]/string() )
                    }
                </idx:lccfacet> 
                                                    
let $broaderLabels:=
    for  $hit in  $results[skos:broader]       
         let $broader:=
                cts:search(doc("/config/lcc.skos.rdf")/rdf:RDF/rdf:Description, 
                        cts:element-attribute-value-query(
                        xs:QName('rdf:Description'),
                                                xs:QName('rdf:about'),
                                                $hit/skos:broader/@rdf:resource/string(), 
                                                "exact"
                                             )
                )                   
          let $elname:=       if (string-length($broader/skos:prefLabel[@xml:lang="zxx"]/string())=2 ) then "idx:lcc2" else "idx:lcc1"
        return (element {$elname} 
                        {concat($broader/skos:prefLabel[@xml:lang="zxx"]/string()," - ",$broader/skos:altLabel[@xml:lang="en"]/string() )},
                    element {concat($elname,"code")}{$broader/skos:prefLabel[@xml:lang="zxx"]/string()}
                    )
      
      return     ($resultLabel, $broaderLabels)
     
(:let $code2:= (:if codemax=1 then no code2, if 2, then use codemax:)
    if (string-length($codemax) =3 ) then
        substring($codemax,1,2)
    else ()
let $code1:= (:if codemax=1  then use codemax, :)
   if (string-length($codemax) !=1 ) then
       substring($codemax,1,1)
       else () 

let $hits := 
        cts:search( doc("/config/lcc.skos.rdf")/rdf:RDF/rdf:Description, 
                    cts:or-query(                                   
                    ( if (exists($code1)) then
                         cts:element-value-query(
                                                xs:QName('skos:prefLabel'),
                                                $code1, 
                                                "exact"
                                                )
                       else () 
                       ,
                     if (exists($code2)) then cts:element-value-query(
                                                xs:QName('skos:prefLabel'),
                                               $code2,
                                                "exact"
                        )
                        else ()
                       ,
                    cts:element-value-query(
                                                xs:QName('skos:prefLabel'),
                                               $codemax ,
                                                "exact"
                                                )
                  )
     ) (: or :)
)
:)
  
        (:($resultLabel, $broaderLabels)
    <rdf:RDF xmlns:xs="http://www.w3.org/2001/XMLSchema#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:vs="http://www.w3.org/2003/06/sw-vocab-status/ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            {$resultLabel, $broaderLabels}
        </rdf:RDF>:)
};

declare function lcc:getLCCLabels($lccode as xs:string ) {
(:not used:)
     let $set:= lcc:getLCClass($lccode  )
let $result:=     
     for $item  at $position in $set/rdf:Description
           return
             element {concat("idx:lcc", $position)} 
                {concat($item/skos:prefLabel[@xml:lang="zxx"]," - ",$item/skos:prefLabel[@xml:lang="en"]/string() )}
return ($result,
        <idx:lccfacet> {concat($set//rdf:Description[last()]/skos:prefLabel[@xml:lang="zxx"]/string()," - ",$set//rdf:Description[last()]/skos:prefLabel[@xml:lang="en"]/string() )}</idx:lccfacet>,
        <idx:lccfacetcode>{$set//rdf:Description[last()]/skos:prefLabel[@xml:lang="zxx"]/string()}</idx:lccfacetcode> 
    )
};


