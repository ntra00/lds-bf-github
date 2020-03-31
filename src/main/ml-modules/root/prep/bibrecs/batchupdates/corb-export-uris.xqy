xquery version "1.0-ml";
(: not sure what this does but it runs; I  set it to [1-5] :)
declare variable $NODE as xs:string external := "works";

let $NODE:=if (fn:matches($NODE,"/$") ) then $NODE else fn:concat($NODE,"/")
let $uri-path:=fn:concat("/resources/", $NODE)
let $uris := cts:uris( (), ("ascending", "concurrent" , "item-order"),
				      	cts:and-not-query(
								  cts:collection-query($uri-path) ,
								  cts:collection-query("/bibframe/stubworks/") 
								)
                )[1 to 5]
let $uris:=
	for $uri in $uris
	 	(:uris are like this:/lscoll/lcdb/works/c/0/0/0/0/0/0/0/0/2/c000000002.xml:)

		(: filter out bnode and other :in-process" uris:)
		
		return 	if ( $NODE="works/" 		and fn:matches($uri,"(works/n|works/e|works/c)") or
					 $NODE="instances/" 	and fn:matches($uri,"(instances/n|instances/e|instances/c)") or
					 $NODE="items/"		and fn:matches($uri,"(items/n|items/e|items/c)")) then
						
						(: convert "/resources/works/c000..." to "loc.natlib.works.c000..." for utils:mets :)
						let $u:=fn:concat($uri-path, fn:tokenize($uri,"/")[fn:last()])
						let $u:= fn:replace($u, "/resources/", "loc.natlib.")
						let $u:= fn:replace($u, "resources", "loc.natlib.")
						let $u:= fn:replace($u, "/", ".")	
			    
					return fn:replace($u,".xml","")
				
				else
   					xdmp:log(fn:concat("CORB BFEXPORT skipped for in-process  : ",$uri), "info")    	

let $count := fn:count($uris)

let $_ := xdmp:log(fn:concat("CORB BFEXPORT exporting " ,$count ,"  docs for " ,$NODE), "info")

return ($count, $uris)
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)