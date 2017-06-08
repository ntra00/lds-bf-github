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
(:declare  variable $id as xs:string := xdmp:get-request-field("id","");:0
declare variable $behavior as xs:string := xdmp:get-request-field("behavior",""); (:default, pageturner, contactsheet, etc. :)
declare variable $kmlurl as xs:string := xdmp:get-request-field("kmlurl",""); (: geodefault url :)
declare variable $words as xs:string := xdmp:get-request-field("words","");  (:hit highlight words (optional) :)
declare variable $part as xs:string := xdmp:get-request-field("part","");  (: labels, xml, navigation, ?? :)
declare variable $mime as xs:string := xdmp:get-request-field("mime","text/xhtml");  (: mxe, mets, mods, marcxml...dc? :)
declare variable $view as xs:string := xdmp:get-request-field("view","html");  (: could be "marctags" for bibdisplay, or "ajax" for ajax div view:)

 declare variable $id as xs:string external;
declare variable  $lccn as xs:string external;
declare variable  $mattype as xs:string external;
declare variable  $view as xs:string external;
declare variable  $ajaxparams as xs:string external;
declare variable  $q as xs:string external; 
declare function local:displayAll($subfield,$label,$subfields) {

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
						 local:copy($subfield/*[@code='3']/string() ), $sf6,<br/>)
				        else ()
		}
			</dd>
		</dl>
	
};
(:----------------------------------------------------------:)
      declare function local:transformData($element as element() ) {
let $tag:= element {concat("t",$element/@tag)} {}
return typeswitch($tag)
  case element(t100) return local:displayAll($element,"Personal Name","")
  case element(t110) return local:displayAll($element,"Corporate Name","")
  case element(t111) return local:displayAll($element,"Conference Name","")
    default return string-join($element," ")
  };

(:----------------------------------------------------------:)
 declare function local:copy($element ) {

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
                local:copy($child)
    else
   if ($element/@code="6" and string($element/parent::marc:datafield/@tag) ="880" ) then
             (: text node of <subfield code="6">260-04/(3/r‏</subfield>:)
         substring($child,5)
else
  $child
}
};

(:----------------------------------------------------------:)

let $id2:="loc.natlib.lcdb.5226"
let $bibid:="5226"	
	(:<xsl:include href="/config/MARC21slimUtils.xsl"/>:)
	  

let $marcRecord:=marcutil:mxe2-to-marcslim(utils:mets($id2)//mxe:record)
let $rec:=  local:copy($marcRecord)
let results:= for $subfield in $rec 
                    return
                           typeswitch ($subfield)
                        
  case element($subfield,marc:leader) return local:mattype($subfield)
  case element($subfield,marc:controlfield) return xs:string($subfield)
  default return local:transformData($subfield)
return $results
       