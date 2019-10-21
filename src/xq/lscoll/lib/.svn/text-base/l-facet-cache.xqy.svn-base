xquery version "1.0-ml";


module namespace lfc = "http://www.marklogic.com/ps/lib/l-facet-cache";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";


declare function lfc:insert-cache( $id as xs:string, $response as node()* ) {

    let $_ := xdmp:log(text{"Caching results for facet: ",$id},"fine")
    let $doc := 
        element lfc:facet-cache {
            element lfc:id { $id },
            element lfc:response { $response }
        }
    let $uri := fn:concat("/facet-cache/",$id,".xml")
    let $_ := xdmp:eval('
        xquery version "1.0-ml";
        declare variable $uri external;
        declare variable $doc external;
        
        xdmp:document-insert($uri,$doc,xdmp:default-permissions(),"lib-facet-cache")
        
        ', 
        (xs:QName("uri"), $uri, xs:QName("doc"), $doc),
        <options xmlns="xdmp:eval">
        <isolation>different-transaction</isolation>
        </options>)
    return
    ()
};

declare function lfc:get-facet-cache( $id as xs:string ) as node()* {
    let $_ := xdmp:log(text{"Retrieving cached results for facet: ",$id},"fine")
    return
    fn:doc(fn:concat("/facet-cache/",$id,".xml"))/lfc:facet-cache/lfc:response/node()
};

declare function lfc:clear-facet-cache( ) {

    let $_ := xdmp:log("Clearing facet-cache","fine")
    return

    for $d in fn:collection("lib-facet-cache")
    let $uri := xdmp:node-uri($d)
    return
    xdmp:document-delete($uri)

};