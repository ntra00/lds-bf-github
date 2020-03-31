xquery version "1.0-ml";
declare namespace idx="info:lc/xq-modules/lcindex";

let $uris :=
cts:uris(
                  (),(),
  
    cts:or-query((
				cts:element-value-query(xs:QName("idx:rdftype"),"Title") ,
                cts:element-value-query(xs:QName("idx:rdftype"),"NameTitle")
    
  				))
  )
return (fn:count($uris) , $uris )
