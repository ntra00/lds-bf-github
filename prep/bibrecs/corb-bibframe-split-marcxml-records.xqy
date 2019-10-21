xquery version "1.0-ml";
import module namespace bibs2mets = "http://loc.gov/ndmso/bibs-2-mets" at "modules/module.bibs2mets.xqy";
declare default element namespace "http://www.loc.gov/MARC21/slim";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";
declare variable $TODAY := fn:format-date(fn:current-date(),"[Y0001]-[M01]-[D01]");

                 
(:chunks are now in "/bibframe-process/chunks/catalog##/*" (01-19) 
2019-10-02: move 985  process here, s we don't store 985 bibs.

:)
(: corb will pass in a URI of a MARCXML collection document from the /bibframe-process/ collection :)
declare variable $URI as xs:string external;
declare variable $delete-marcxml-collections := fn:false();

declare function local:split-save-records(){
	for $record in fn:doc($URI)//marcxml:record
		let $already-in-pilot:=   
				for $tag in $record/marcxml:datafield[@tag="985"]/marcxml:subfield[@code="a"]
	      			return if (fn:matches(fn:string($tag) ,"BibframePilot2","i")) then
	        			fn:true()
	       			else 
	        			()
	  	return if ($already-in-pilot) then
						xdmp:log(fn:concat("CORB BIB chunk split saving: skip: ",fn:string($record/marcxml:controlfield[@tag="001"]), ", has 985." ), "info")
					else

						let $cf := $record/marcxml:controlfield[@tag='001']
						let $leader := $record/marcxml:leader
						let $hide-deletions:=if(fn:substring($leader, 6,1)="d") then
													local:hide-instances-items($URI,$cf)
												else 
													()
						let $fn := if (fn:string-length($cf) gt 0) then fn:normalize-space($cf) else xdmp:md5(xdmp:random(999999) cast as xs:string)
						let $docuri := fn:concat("/bibframe-process/records/", $cf, ".xml")
						let $collections := ("/bibframe-process/records/", fn:concat("/bibframe-process/load_splitmarcxml/",$TODAY,"/"))
					    let $permissions := (
					        xdmp:permission("id-user-role", "read"),
					        xdmp:permission("id-admin-role", "update"),
					        xdmp:permission("id-admin-role", "insert")
					    )
					    let $quality := ()
						let $forest := ()
					    (:let $forest := (xdmp:forest("id-prep-bibframe-process-1"), xdmp:forest("id-prep-bibframe-process-2")) :)
						return 
							try {
								(
								xdmp:document-insert($docuri, document{$record}, $permissions, $collections, $quality, $forest)
			
								)
							} catch($e) {
								($e, 
								xdmp:log($URI, "error"),
								xdmp:log($e, "error")
								)
							}
};
declare function local:hide-instances-items($URI,$cf){
let $paddedID:= bibs2mets:padded-id(fn:normalize-space($cf) )
let $dirtox := bibs2mets:chars-001($paddedID)
let $destination-root := "/lscoll/lcdb/instances/"
let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
return xdmp:log($dir,"info")

};

declare function local:delete-collection-records() {
	try {	
		xdmp:document-delete($URI)
	} catch ($e)   {$e,
	   (xdmp:log($URI, "error"),
	   xdmp:log($e, "error")
	   )
	}
};

let $start := xdmp:elapsed-time()
return (
	local:split-save-records(), 
	if ($delete-marcxml-collections eq fn:true()) then
		local:delete-collection-records()
	else
		(),
	xdmp:log(fn:concat("CORB-BIBFRAME-SPLIT-RECORDS-EXECUTION: ", $URI, (xdmp:elapsed-time() - $start) cast as xs:string), "info")
)(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)