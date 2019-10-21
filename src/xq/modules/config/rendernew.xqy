xquery version "1.0-ml";
(: 
 xslt rendering  for lcdb bib records
    Take a given $id as the objid in mets, and return the permalink display of the marcxml record
    requires transformation from mxe2 to  marcslim, then running displayLcdb.xsl, as adapted from 
    lccnstyle1.xsl, and sending the header/footer, $lcdbDisplay nodes to renderPage.xsl for final layout.
    This will only work  for things with mxe or marc records, not PAE etc. 
:)
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/search-skin.xqy";
import module namespace xslt="info:lc/xq-modules/xslt" at "/xq/modules/xslt.xqy"; 
import module namespace utils= "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
declare namespace xdmp="http://marklogic.com/xdmp";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace http="xdmp:http"; (: for http response:)
declare namespace xhtml="http://www.w3.org/1999/xhtml" ; (:for output:)

declare namespace mxe2="http://www.loc.gov/mxe";
declare variable $id as xs:string := xdmp:get-request-field("id","");
declare variable $behavior as xs:string := xdmp:get-request-field("behavior",""); (:default, pageturner, contactsheet, etc. :)
declare variable $kmlurl as xs:string := xdmp:get-request-field("kmlurl",""); (: geodefault url :)
declare variable $words as xs:string := xdmp:get-request-field("words","");  (:hit highlight words (optional) :)
declare variable $part as xs:string := xdmp:get-request-field("part","");  (: labels, xml, navigation, ?? :)

declare function local:getMattype($leader as element(),$control6,$control7 as element) as xs:string {
import module namespace matconf = "info:lc/xq-modules/config/materials";
let $materials:= matconf:materials() 
let $leader6:= 	substring($leader,7,1)
let $leader6_2:= 	substring($leader,7,2)
let $control_006_1 :=	substring($control6,1,1) 		
let $control_007_1:=	substring($control7,1,1)
		
	return 
		if  ($materials/materialtype[@tag='000_06_2'][@code=$leader6_2]/desc/text()!=''") then 
			$materials/materialtype[@tag='000_06_2'][@code=$leader6_2]/desc
		else if 
		          ( $materials/materialtype[@tag='007_00_1'][@code=$control_007_1]/desc/text()!=''") then
			 $materials/materialtype[@tag='007_00_1'][@code=$control_007_1]/desc
		else if 
		          ( $materials/materialtype[@tag='006_00_1'][@code=$control_006_1]/desc/text()!=''">
			$materials/materialtype[@tag='006_00_1'][@code=$control_006_1]/desc
		else ()


};

let $stylesheetBase :="/xslt/"                         


let $mets:= utils:mets($id)


(: *********************  header/footer ******************** :)
let $displayXsl :=concat( $stylesheetBase ,"displayLcdb.xsl")
let $mxe:=$mets//mxe2:record
let $marcxml:=marcutil:mxe2-to-marcslim($mxe)
let $lcdbDisplay:=
    try { 
		xdmp:xslt-invoke($displayXsl,document{$marcxml})
    	} 	catch ($exception) {
        	$exception
    	}
let $title:=normalize-space($lcdbDisplay//tr[th="Published/Created:"]/td/string())
let $mattype:=local:getMattype($mxe/mxe:leader, $mxe/marc:controlfield[@tag="006"],$mxe/marc:controlfield[@tag="007"])

let $header:= ssk:header($title)
let $footer:= ssk:footer()
let $xml:=<page>{$header, $lcdbDisplay ,$footer}</page>

let $htmlXsl:= concat($stylesheetBase,"renderPage.xsl")

let $html:=
    try {
        xdmp:xslt-invoke($htmlXsl,document{$xml})
    } catch ($exception) {
        $exception
    }

return ($html)

