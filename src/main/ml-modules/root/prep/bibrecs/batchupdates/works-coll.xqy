xquery version "1.0-ml";

declare default element namespace "http://www.loc.gov/MARC21/slim";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";

declare namespace mets      = "http://www.loc.gov/METS/";
declare namespace xdmp      = "http://marklogic.com/xdmp";

declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace bf	        = "http://id.loc.gov/ontologies/bibframe/";
declare namespace sec  = "http://marklogic.com/xdmp/security";
declare variable $URI as xs:string external;
(: first added resources/works collection, now adding id-user-role /read :)
(:<sec:permission xmlns:sec="http://marklogic.com/xdmp/security">
<sec:capability>read
</sec:capability>
<sec:role-id>9381444860832501163
</sec:role-id>
</sec:permission>:)

let $p:=<node>{xdmp:document-get-permissions($URI)}</node>
return if ($p/*[fn:string(sec:role-id) ="9381444860832501163"][fn:string(sec:capability)="read"] ) then 
			()
			(:xdmp:log(fn:concat("CORB works permissions ok for ",$URI),"info"):)
		else
 			(
				xdmp:document-add-permissions($URI,xdmp:permission("id-user-role","read")),
				xdmp:log(fn:concat ("CORB works permissions updated added for ",$URI),"info")
			)





(:
 xdmp:document-add-collections($URI,"/resources/works/")
,
xdmp:log(fn:concat ("CORB works collection added for ",$URI),"info")
 
)

:)
