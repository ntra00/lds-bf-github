xquery version "1.0-ml";

declare default element namespace "http://www.loc.gov/MARC21/slim";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";

                 
declare variable $URI as xs:string external;
declare variable $delete-marcxml-collections := fn:false();
(:/bibframe-process/records/123.xml":)
declare function local:padded-id($id as xs:string) 
{

    let $idLen := fn:string-length( $id )
    let $paddedID := 
        if ( $idLen eq 1 ) then
            fn:concat("00000000" , $id)
        else if ( $idLen eq 2 ) then
            fn:concat("0000000" , $id)
        else if ( $idLen eq 3 ) then
            fn:concat("000000" , $id)
        else if ( $idLen eq 4 ) then
            fn:concat("00000" , $id)
        else if ( $idLen eq 5 ) then
            fn:concat("0000" , $id)
        else if ( $idLen eq 6 ) then
            fn:concat("000" , $id)
        else if ( $idLen eq 7 ) then
            fn:concat("00" , $id)
        else if ( $idLen eq 8 ) then
            fn:concat("0" , $id)
        else 
            $id
    return $paddedID
    
};
declare function local:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};

let $bibid:=fn:substring-before(fn:tokenize($URI,"/")[fn:last()],".xml")
let $biburi:=local:padded-id($bibid)
let $biburi := local:padded-id($bibid)

	
let $paddedID := fn:concat("c",$BIBURI)

	let $resclean := $paddedID
	let $dirtox := local:chars-001($resclean)
	let $dest:="/lscoll/lcdb/instances/"
    let $destination-root := $dest
    let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
    let $destination-uri := fn:concat($dir, $resclean, '.xml')
	let $instance-uri := fn:concat($dir, $resclean, '0001.xml')
    let $item-uri:=fn:replace($instance-uri,"instances","items")
return doc-available($item-uri)

(:
 
  let $uris:=
    for $uri in $results//sparql:uri
  	  let $src:=fn:tokenize($uri,"/")[fn:last()]
    	let $srcid:=fn:concat("loc.natlib.instances.",$src)
    let $bibid:=fn:concat("/bibframe-process/records/",fn:substring-before(fn:replace($src,"^c0+",""),"0001"),".xml")
    let $instance-id:=fn:base-uri(cts:search(collection($cfg:DEFAULT-COLLECTION)/mets:mets, cts:element-attribute-value-query(xs:QName("mets:mets"), xs:QName("OBJID"), $srcid))[1])
    let $item-id:=fn:replace($instance-id,"instances","items")
    return $bibid

if (fn:doc-available($URI)) then
	(
	try { xdmp:document-delete($URI)
	}
	catch($e) {xdmp:log(fn:concat("CORB orphan work deletion failed : ",$URI ), "info")
	}
	, 
	 xdmp:log(fn:concat("CORB orphan work deleted : ",$URI ), "info")
	)

else
xdmp:log(fn:concat("CORB  orphan work deletion , doc not found for : ",$URI ), "info")
