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
let $test:="no"

let $node:="bf:electronicLocator"
let $node:="mxe:d856_subfield_u"
let $node:="bflc:target"
let $node:="mxe:d856_subfield_u"

let $uris:=
if ( $test="test" ) then 
              cts:uris((), (),
                        
                    cts:and-query((                       
                          cts:element-query(xs:QName($node),cts:and-query(())),
                      cts:collection-query("/catalog/")                      
                      ))
                      )[1 to 5]
else                      
              cts:uris((), (),
                        
                    cts:and-query((                       
                          cts:element-query(xs:QName($node),cts:and-query(())),
                      cts:collection-query("/catalog/")                      
                      ))
                      )

          
    return ( xdmp:log(fn:concat("CORB shell link regex starting: ",count($uris)),"info"),
			count($uris),$uris
	)

(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)