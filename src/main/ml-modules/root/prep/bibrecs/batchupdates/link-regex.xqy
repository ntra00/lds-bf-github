xquery version "1.0-ml"; 
declare namespace                                                      rdf                                                                      = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace                                                      rdfs                                          = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace                                       mets                                                   = "http://www.loc.gov/METS/";
declare namespace                                                      marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace                                                      madsrdf                                  = "http://www.loc.gov/mads/rdf/v1#";
declare namespace                                                      mxe                                                                   = "http://www.loc.gov/mxe";
declare namespace                                                      bf                                                                       = "http://id.loc.gov/ontologies/bibframe/";
declare namespace                                                       bflc                                                     = "http://id.loc.gov/ontologies/bflc/";
declare namespace                                                      index                                                  = "info:lc/xq-modules/lcindex";
declare namespace                                                      idx                                                       = "info:lc/xq-modules/lcindex";
declare namespace xdmphttp="xdmp:http";

declare variable $URI as xs:string external;



    let $x:=fn:tokenize($URI,"/")[fn:last()]
    let $x:=fn:replace($x,"^c0+","")
    let $bibid:=fn:replace($x,".xml","")
    let $doc:= xdmp:http-get(fn:concat("http://mlvlp04.loc.gov:8230/resources/bibs/",$x))[2]
    return for $u in $doc//marcxml:datafield[@tag="856"]/marcxml:subfield[@code="u"]
       let $url:=fn:string($u)
       let $mat:=fn:matches($url, "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?")
       return if ($mat) then () else xdmp:log( concat("CORB SHELL link bad for bibid ",$bibid, ":",$url),"info")
       
       (:return if (fn:not(fn:matches(fn:string($u),("loc.gov") ))) then
              let $urlcode:=fn:string(xdmp:http-get(fn:string($u))[1]//xdmphttp:code)
                return if (fn:not(fn:matches($urlcode,("302","301") ))) then ( ((concat($bibid, ":", fn:string(     $u), xdmp:quote(xdmp:http-get(fn:string($u))[1]) )) )) else ()
         else ()
   )
   :)
    (:xdmp:document-delete("/lscoll/lcdb/items/c/0/2/1/3/5/4/2/4/4/c0213542440001-1.xml")):)
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)