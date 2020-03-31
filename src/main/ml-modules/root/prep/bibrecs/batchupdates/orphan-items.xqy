xquery version "1.0-ml";
declare namespace mets="http://www.loc.gov/METS/";
declare variable $URI external;
let $uri:=$URI
let $instance-docid:=fn:replace($uri, "items","instances")
let $instance-docid:=fn:replace($uri,"[0-9][0-9]\.xml$","01.xml")
let $item-loaded:=doc($uri)/mets:mets/mets:metsHdr/@LASTMODDATE
let  $item-loaded:=xs:dateTime($item-loaded)

let $instance-loaded:=doc( $instance-docid)/mets:mets/mets:metsHdr/@LASTMODDATE
let $instance-loaded:=xs:dateTime($instance-loaded)
let $age:=$instance-loaded - $item-loaded
return

if (days-from-duration($age) >2) then
(
	xdmp:log(fn:concat("CORB orphan item delete :",$uri),"info"),
	  xdmp:document-delete($uri)
  )
  else
  xdmp:document-add-collections($uri,"/bibframe-process/item-not-orphan/")
	
