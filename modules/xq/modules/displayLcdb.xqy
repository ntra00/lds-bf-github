xquery version "1.0-ml";
module namespace display = "info:lc/xq-modules/display-utils";
(: 
 rendering  for lcdb bib records
Take a given $id as the objid in mets, and return the permalink display of the marcxml record
requires transformation from mxe2 to  marcslim, then running displayLcdb.xsl, as adapted from 
lccnstyle1.xsl, and sending the header/footer, $lcdbDisplay nodes to renderPage.xsl for final layout.
This will only work  for things with mxe or marc records, not PAE etc. 
:)

import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/search-skin.xqy";

import module namespace utils= "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/xq/modules/config/materialtype.xqy";
declare namespace marc="http://www.loc.gov/MARC21/slim";
declare namespace xdmp="http://marklogic.com/xdmp";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace http="xdmp:http"; (: for http response:)
declare default element namespace "http://www.w3.org/1999/xhtml" ; (:for output:)
declare  namespace xhtml="http://www.w3.org/1999/xhtml" ; (:for output:)
declare namespace mxe="http://www.loc.gov/mxe";
declare namespace mat="info:lc/xq-modules/config/materials";
(:declare  variable $id as xs:string := xdmp:get-request-field("id",""); 
declare variable $behavior as xs:string := xdmp:get-request-field("behavior",""); (:default, pageturner, contactsheet, etc. :)
declare variable $kmlurl as xs:string := xdmp:get-request-field("kmlurl",""); (: geodefault url :)
declare variable $words as xs:string := xdmp:get-request-field("words","");  (:hit highlight words (optional) :)
declare variable $part as xs:string := xdmp:get-request-field("part","");  (: labels, xml, navigation, ?? :)
declare variable $mime as xs:string := xdmp:get-request-field("mime","text/xhtml");  (: mxe, mets, mods, marcxml...dc? :)
declare variable $view as xs:string := xdmp:get-request-field("view","html");  (: could be "marctags" for bibdisplay, or "ajax" for ajax div view :)
:)
  
declare function display:displayAll($subfield,$label,$subfields) {

		<dl class="record">
			<dt>{$label}:</dt>
			<dd>{ if (empty($subfields)) then				
				    let $sf6:= if (matches("^*[\(2|\(3|\(4]*$" , $subfield/marc:subfield[@code='6']) ) then
        				                <span dir="rtl">{string-join($subfield/*[@code!='6' and @code!='3' and @code!='0']," ") } </span>
        				            else
        				                $subfield/*[@code!='6' and @code!='3' and @code!='0']/string() 
        				     
                	                          return ( string-join($subfield/*[@code='3']," " ), $sf6,<br/>)
						
				else	
					if ($subfield/marc:subfield[contains($subfields,@code)] ) then						
				                let $sf6:= if (matches("^*[\(2|\(3|\(4]*$" , $subfield/marc:subfield[@code='6']) ) then	
				                                    <span dir="rtl">{$subfield/*[(@code!='6' and @code!='3' and @code!='0') and contains($subfields,@code) ] } </span>
				                                else
				                                    $subfield/*[(@code!='6' and @code!='3' and @code!='0') and contains($subfields,@code) ]  
				                    
				                    return (
						 display:copy($subfield/*[@code='3']/string() ), $sf6,<br/>)
				        else ()
		}
			</dd>
		</dl>
	
};
(:----------------------------------------------------------:)
      declare function display:transformData($element as element() ) {
let $tag:= element {concat("t",$element/@tag)} {}
return typeswitch($tag)
  case element(t100) return display:displayAll($element,"Personal Name","")
  case element(t110) return display:displayAll($element,"Corporate Name","")
  case element(t111) return display:displayAll($element,"Conference Name","")
    default return string-join($element," ")
  };

(:----------------------------------------------------------:)
 declare function display:copy($element ) {

  element {node-name($element)}  
       {     for $attrib in $element/attribute()
                 return 
                     if ($attrib/local-name()="tag" and  string($attrib)="880") then 
                        let $realtag:=substring($element/marc:subfield[@code="6"],1,3)
                        return attribute tag {$realtag}
                     else
                         $attrib,
       for $child in $element/node()
        return if ($child instance of element() ) then
                display:copy($child)
    else
   if ($element/@code="6" and string($element/parent::marc:datafield/@tag) ="880" ) then
             (: text node of <subfield code="6">260-04/(3/r‏</subfield>:)
         substring($child,5)
else
  $child
}
};

(:----------------------------------------------------------:)
declare function display:display($id as xs:string(),$lccn as xs:string(),$view as xs:string(), $ajaxparams as xs:string())

let $id2:="loc.natlib.lcdb.5226"
let $bibid:="5226"	
	(:<xsl:include href="/config/MARC21slimUtils.xsl"/>:)
	  let $leader6:= substring($rec/marc:leader/string(),7,1)
let $leader6_2:=substring($rec/marc:leader,7,2)


let $control6:=substring($rec/marc:controlfield[@tag='006'],1,1)
let $control7:=substring($rec/marc:controlfield[@tag='007'],1,1)
    let $materials:=matconf:materials()
    let $mattype:=
           if ($materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/text()!="" ) then
    	$materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc
          else if ($materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/text()!="") then
    	$materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc
          else if ($materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/text()!="") then
                	$materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc
           else ()


let $marcRecord:=marcutil:mxe2-to-marcslim(utils:mets($id)//mxe:record)
let $rec:=  display:copy($marcRecord)
let results:= for $subfield in $rec 
                    return
                           typeswitch ($subfield)
                        
  case element($subfield,marc:leader) return display:mattype($subfield)
  case element($subfield,marc:controlfield) return xs:string($subfield)
  default return display:transformData($subfield)
return $results
       