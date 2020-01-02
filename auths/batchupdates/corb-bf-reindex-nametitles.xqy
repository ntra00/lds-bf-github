xquery version "1.0-ml";
(: this re-runs the bibframe to index replacing it, to suppress too many workaaps :)
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace index = "id_index#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bf = "http://bibframe.org/vocab/";
declare namespace bf2 = "http://bibframe.org/vocab2/";
import module namespace bibframe2index      =       "info:lc/id-modules/bibframe2index#" at "modules/module.BIBFRAME-2-INDEX.xqy";

declare variable $URI external;

let $start := xdmp:elapsed-time()
let $mets := fn:doc($URI)/mets:mets
let $bibframe := $mets/mets:dmdSec[@ID="bibframe"]//rdf:RDF
let $work-bfindex := bibframe2index:bibframe2index($bibframe)

	
	let $idx := $mets/mets:dmdSec[@ID="index"]//index:index
	let $insert := 
			try {
				(
				xdmp:node-replace($mets/mets:dmdSec[@ID="index"]//index:index, $work-bfindex) ,
				xdmp:node-replace($mets/mets:metsHdr,<mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>)
				)
			} catch ($e) {
				$e
			}
		return
			if ($insert instance of element(error:error)) then
				xdmp:log($insert, "error")
			else
				xdmp:log(fn:concat("reindexed  ", $URI, " in ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")
	