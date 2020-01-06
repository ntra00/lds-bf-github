xquery version "1.0-ml";

declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace r = "http://www.indexdata.com/turbomarc";

declare variable $URI as xs:string external;

(: The following used for reducing the LC Classification entries down to 1
(xdmp:node-delete(doc($URI)/mets:mets/mets:dmdSec[@ID='IDX1']/mets:mdWrap/mets:xmlData/idx:indexTerms/idx:lcc[position() > 1])(:, $URI:))
:)

(: Used for inserting a date-time stamp attribute on turbomarc holdings records
if (doc($URI)/r:r/@dT) then 
	() 
else 
	xdmp:node-insert-child(doc($URI)/r:r, attribute dT { fn:current-dateTime() })
:)

(: Used for deleting docs without a date-time stamp attribute on turbomarc holdings records
if (doc($URI)/r:r/@dT) then 
	() 
else 
	xdmp:document-delete($URI)
:)

(: Used to remove old bibs prior to a given dateTime stamp :)
if (xs:dateTime(doc($URL)/mets:mets/mets:metsHdr/@LASTMODDATE) le xs:dateTime("2011-06-22T11:59:46")) then 
    xdmp:document-delete($URL)
else
    ()
