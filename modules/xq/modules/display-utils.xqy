xquery version "1.0-ml";
module namespace display = "info:lc/xq-modules/display-utils";
(: 
 rendering  for lcdb bib records
Take a given $id as the objid in mets, and return the permalink display of the marcxml record
requires transformation from mxe2 to  marcslim, then running displayLcdb.xsl, as adapted from 
lccnstyle1.xsl, and sending the header/footer, $lcdbDisplay nodes to renderPage.xsl for final layout.
This will only work  for things with mxe or marc records, not PAE etc. 
:)
import module namespace functx="http://www.functx.com"  at "/xq/modules/functx.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/search-skin.xqy";
import module namespace utils= "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/xq/modules/config/materialtype.xqy";

declare namespace marc="http://www.loc.gov/MARC21/slim";
declare namespace mxe="http://www.loc.gov/mxe";
declare namespace xdmp="http://marklogic.com/xdmp";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml" ; (:for output:)
declare  namespace xhtml="http://www.w3.org/1999/xhtml" ; (:for output:)

declare namespace mat="info:lc/xq-modules/config/materials";

(:
declare  variable $id as xs:string := xdmp:get-request-field("id",""); 
declare variable $behavior as xs:string := xdmp:get-request-field("behavior",""); (:default, pageturner, contactsheet, etc. :)
declare variable $kmlurl as xs:string := xdmp:get-request-field("kmlurl",""); (: geodefault url :)
declare variable $words as xs:string := xdmp:get-request-field("words","");  (:hit highlight words (optional) :)
declare variable $part as xs:string := xdmp:get-request-field("part","");  (: labels, xml, navigation, ?? :)
declare variable $mime as xs:string := xdmp:get-request-field("mime","text/xhtml");  (: mxe, mets, mods, marcxml...dc? :)
declare variable $view as xs:string := xdmp:get-request-field("view","html");  (: could be "marctags" for bibdisplay, or "ajax" for ajax div view :)
:)
declare variable $labels  as element() :=display:labels() ;
declare variable $groupLabels  as element() :=display:groupLabels() ;

declare function display:labels () as element() {
<labels>
       <label tag="010" subfields="a" sort="001">LC Control No.</label>
        <label tag="100" sort="003">Personal Name</label>
        <label tag="110" sort="003">Corporate Name</label>
        <label tag="111"sort="003" >Meeting Name</label>
        <label tag="245" sort="005">Main Title</label>              
        <label tag="246"  ind2=" " sort="006">Variant Title</label>
        <label tag="246"  ind2="0" sort="006"  >Portion of Title</label>
        <label tag="246" ind2="1" sort="006">Parallel Title</label>
        <label tag="246" ind2="2" sort="006">Distinctive Title</label>
        <label tag="246" ind2="3" sort="006">Other Title</label>
        <label tag="246" ind2="4" sort="006">Cover Title</label>
        <label tag="246" ind2="5" sort="006">Added Title Page Title</label>
        <label tag="246" ind2="6" sort="006">Caption Title</label>
        <label tag="246" ind2="6" sort="006">Running Title</label>
        <label tag="246" ind2="6" sort="006">Running Title</label>
<label tag="024" ind1="0" subfields="acd2" sort="007">ISRC</label>
<label tag="024" ind1="0" subfields="z" sort="007">Cancelled/Invalid ISRCI</label>
<label tag="024" ind1="1" subfields="acd2" sort="007">UPC/EAN</label>
<label tag="024" ind1="1" subfields="z" sort="007">Cancelled/Invalid>UPC/EAN</label>
<label tag="024" ind1="3" subfields="acd2" sort="007">UPC/EAN</label>
<label tag="024" ind1="3" subfields="z" sort="007">Cancelled/Invalid UPC/EAN</label>
<label tag="024" ind1="2" subfields="z" sort="007">ISMN</label>
<label tag="024" ind1="2" subfields="z" sort="007">Cancelled/Invalid ISMN</label>
<label tag="024" ind1="4" subfields="acd2" sort="007">SICI</label>
<label tag="024" ind1="4" subfields="z" sort="007">Cancelled/Invalid SICI</label>
<label tag="024" ind1="7" subfields="acd2" sort="007">Other Standard No.</label>
<label tag="024" ind1="7" subfields="z" sort="007">Cancelled/Invalid Standard No.</label>
<label tag="024" ind1="8" subfields="acd2" sort="007">Other Standard No.</label>
<label tag="024" ind1="8" subfields="z" sort="007">Cancelled/Invalid Standard No.</label>
					
        <label tag="242" sort="008">Title Translation</label>
       <label tag="222" sort="009">Serial Key Title</label>
       <label tag="210" sort="010">Abbreviated Title</label>
         <label tag="263" sort="013">Projected Publication Date</label>                        
        <label tag="351">Organized/Arranged</label>
        <label tag="310">Current Frequency</label>
        <label tag="321">Former Frequency</label>
        <label tag="247">Former Title</label>
        <label tag="307" ind1=" ">Hours Available</label>
        <label tag="355">Security Information</label>
	<label tag="022"subfields="a">ISSN</label>
	<label tag="022"subfields="l">Linking ISSN</label>
	<label tag="022"subfields="y">Incorrect  ISSN</label>
        <label tag="022"subfields="z">Cancelled  ISSN</label>
	<label tag="022"subfields="m">Cancelled Linking ISSN</label>
	<label tag="020"subfields="ac">ISBN</label>
	<label tag="020"subfields="z">Cancelled ISBN</label>
	<label tag="010"subfields="z">Cancelled/Invalid LCCN</label>

        (:more 0024, but displayallind??:)
        <label tag="027" subfields="ac">Standard Technical Report No.</label>
        <label tag="027" subfields="z">Cancelled STRN</label>
        	<label tag="028">Publisher No.</label>
        	<label tag="030" subfields="ac">CODEN</label>
	<label tag="030" subfields="z">Cancelled/Invalid CODEN</label>
	<label tag="522">Geographic Coverage</label>
	<label tag="754">Taxonomic ID</label>
	<label tag="545">Biographical/Historical Data</label>
	
        
         <label tag="511" ind1=" ">Performer</label>
         <label tag="511" ind1="0">Performer</label>
         <label tag="524">Cite as</label>
         <label tag="508">Credits</label>
         <label tag="653">Subject Keywords</label>
         <label tag="050">LC Classification</label>
         <label tag="051">LC Copy</label>
         <label tag="052">Geographic Class No.</label>
         <label tag="055">Canadian Class No.</label>
        <label tag="060">NLM Class No.</label>
	<label tag="061">NLM Copy Statement</label>
	<label tag="070">NAL Class No.</label>
	<label tag="071">NAL Copy Statement</label>
	<label tag="086">Government Document No.</label>
	<label tag="090">Local Shelving No.</label>
        <label tag="041">Language Code</label>
        <label tag="044">Country of Publication</label>
        <label tag="032">Postal Registration No.</label>
        <label tag="013">Patent Control No.</label>
        <label tag="017">Copyright Registration No.</label>
	<label tag="018">Copyright Article Fee</label>
	<label tag="015">National Bibliography No.</label>
	<label tag="016">National Bibliographic Agency No.</label>
	<label tag="035" subfields="a">Other System No.</label>
	<label tag="035" subfields="z">Cancelled/Invalid System No.</label>
	<label tag="037">Reproduction No./Source</label>
	<label tag="043">Geographic Area Code</label>
	<label tag="074"  subfields="a">GPO Item No.</label>
	<label tag="074"  subfields="z">Cancelled/Invalid GPO Item No.</label>
	<label tag="088"  subfields="a">Report No.</label>
          <label tag="088"  subfields="z">Cancelled/Invalid Report No.</label>
	<label tag="852">Repository</label>
	<label tag="042"  subfields="a">Quality Code</label>
	<label tag="336"  subfields="a3">Content Type</label>
	<label tag="337"  subfields="a3">Media Type</label>
<label tag="338"  subfields="a3">Carrier Type</label>
		


</labels>
};
declare function display:groupLabels () as element() {
       (: sort="015":if test="marc:datafield[@tag='730' or @tag='740']">
			<xsl:call-template name="relatedTitles"/>
		<:if>
		:)

<labels>
    <group label="Uniform Title" sort="004"><tag>130</tag><tag>240</tag><tag>243</tag></group>
       <group label="Edition Information" sort="011"><tag>250</tag><tag>254</tag></group>       
       <group label="Published/Created" sort="012"><tag>260</tag><tag>261</tag><tag>262</tag><tag>257</tag><tag>270</tag></group>
       <group label="Related Names"  sort="014"><tag>700</tag><tag>710</tag><tag>711</tag></group>
       <group label="Access Advisory"><tag>357</tag><tag>506</tag><tag ind1="8">307</tag></group>
       <group label="Computer File Information"><tag>036</tag><tag>256</tag><tag>352</tag><tag>516</tag><tag>538</tag><tag>753</tag></group>
       <group label="Geospatial Information"><tag>342</tag><tag>343</tag></group>
       <group label="Scale"><tag>255</tag><tag>507</tag></group>
	<group label="Notes"><tag>382</tag><tag>500 </tag><tag>501 </tag><tag>504 </tag>
<tag>513 </tag><tag>514 </tag><tag> 518 </tag><tag> 521 </tag>
<tag> 525 </tag><tag> 526 </tag><tag> 535 </tag><tag> 536 </tag>
<tag> 542 </tag><tag> 544 </tag><tag> 546 </tag><tag> 547 </tag>
<tag> 550 </tag><tag> 552 </tag><tag> 556 </tag><tag> 561 </tag>
<tag> 562 </tag><tag> 563 </tag><tag> 565 </tag><tag> 567 </tag>
<tag> 580 </tag><tag> 581 </tag><tag> 583 </tag><tag> 584 </tag>
<tag> 585 </tag><tag> 586 </tag><tag> 588 </tag>
<tag> 590 </tag><tag> 591 </tag><tag> 592 </tag><tag> 593 </tag>
<tag> 594 </tag><tag> 595 </tag><tag> 596 </tag><tag> 597 </tag>
<tag> 598 </tag><tag> 599 </tag></group>
<group label="Dewey Class No."><tag>082</tag><tag>083</tag></group>
<group label="Other Class No."><tag>084</tag><tag>085</tag></group>

</labels>
};

declare function display:getLabel($element)  {
(:let $labels:=display:labels() :)
    if ($labels/label[@tag=$element/@tag][@ind1=$element/@ind1]  ) then
        ($labels/label[@tag=$element/@tag][@ind1=$element/@ind1]/string(),
        $labels/label[@tag=$element/@tag][@ind1=$element/@ind1]/@subfields/string() )
    else if ($labels/label[@tag=$element/@tag][@ind1=$element/@ind2]) then 
        ($labels/label[@tag=$element/@tag][@ind2=$element/@ind2]/string(),
        $labels/label[@tag=$element/@tag][@ind2=$element/@ind2]/@subfields/string() ) 
    else if (  $labels/label[@tag=$element/@tag]/string()) then
     ($labels/label[@tag=$element/@tag]/string(),
      $labels/label[@tag=$element/@tag]/@subfields/string() )
    else ()

};

declare function display:displayAllGroup($subfield as element() ) as element()* {
(:returns the grouped values in dd elements, assumes dl/dt construct above it:)		
	<dd>				
                    { ($subfield/*[@code='3'],
                        if (matches("^*[\(2|\(3|\(4]*$" , $subfield/marc:subfield[@code='6']) ) then
        	                 <span dir="rtl">{$subfield/*[@code!='6' and @code!='3' and @code!='0'] } </span>
        	            else
        	                    $subfield/*[@code!='6' and @code!='3' and @code!='0']/string()         	     
                        , <br/>)
            }</dd>
};
				
declare function display:displayAll($subfield) {
let $fieldLabel:=$subfield/@label/string()
let $subfields:=$subfield/@subfields/string()
  let $value:= 
   if ($subfields="") then				
	    let $sf:= if (matches("^*[\(2|\(3|\(4]*$" , $subfield/marc:subfield[@code='6']) ) then
        	                <span dir="rtl">{$subfield/*[@code!='6' and @code!='3' and @code!='0'] } </span>
        	            else
        	                $subfield/*[@code!='6' and @code!='3' and @code!='0']/string() 
        	                
               return ( $subfield/*[@code='3'],  
                            if ($subfield/@ind1 or $subfield/@ind2) then $subfield/*[@code='i']/string() (: displayAllInd:) else (),                            
                            $sf,<br/>)			
	else	
		if ($subfield/marc:subfield[contains($subfields,@code)] ) then						
	                let $sf:= if (matches("^*[\(2|\(3|\(4]*$" , $subfield/marc:subfield[@code='6']) ) then	
	                                    <span dir="rtl">{$subfield/*[(@code!='6' and @code!='3' and @code!='0') and contains($subfields,@code) ]/string() } </span>
	                                else
	                                    $subfield/*[(@code!='6' and @code!='3' and @code!='0') and contains($subfields,@code) ]/string()  	                    
	                    return (
			 $subfield/*[@code='3']/string() ,
			 if ($subfield/@ind1 or $subfield/@ind2) then $subfield/*[@code='i']/string() (: displayAllInd:) else (),
			  $sf,<br/>)
	        else ()
	        
return
    <dl class="record">
	<dt>{$fieldLabel}:</dt>
	<dd>{ $value}</dd>
   </dl>
	
};

(:----------------------------------------------------------:)
 declare function display:copy($element ) {

  element {node-name($element)}  
       {     for $attrib in $element/attribute()
                 let $label:=display:getLabel($element)
                 return 
                     if ($attrib/local-name()="tag" and  string($attrib)="880") then 
                        let $realtag:=substring($element/marc:subfield[@code="6"],1,3)                 
                        return (attribute tag {$realtag}, attribute label {$label[1]}, attribute subfields{$label[2]} )                        
                     else
                     if ($attrib/local-name()="tag") then
                         ($attrib, attribute label  {$label[1]} , attribute subfields{$label[2]})
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
declare function display:display($id as xs:string) {

let $id2:="loc.natlib.lcdb.5226"
let $bibid:="5226"
let $marcRecord:=marcutil:mxe2-to-marcslim(utils:mets($id)//mxe:record)
let $rec:=  display:copy($marcRecord)

let $leader6:= substring($rec/marc:leader/string(),7,1)
let $leader6_2:=substring($rec/marc:leader,7,2)

let $control6:=substring($rec/marc:controlfield[@tag='006'],1,1)
let $control7:=substring($rec/marc:controlfield[@tag='007'],1,1)
    let $materials:=matconf:materials()
    let $mattype:=
           if ($materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/text()!="" ) then
    	$materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/string()
          else if ($materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/text()!="") then
    	$materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/string()
          else if ($materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/text()!="") then
                	$materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/string()
           else ()
let $foundtags:= distinct-values($rec/marc:datafield/@tag/string())
let $groupedRecs:=
     for $tag in $groupLabels/group/tag
          return if (matches($tag,$foundtags) ) then
                           <dl class="record"><dt>{$tag/../@label/string()} : </dt>
                                { for $datafield in $rec/marc:datafield[@tag = $tag/string() and ( @ind1=$tag/@ind1 or not($tag/ind1)) and (@ind2=$tag/@ind2 or not($tag/ind2)) ] 
                                          return        display:displayAllGroup($datafield)
                            }</dl>
              else ()
let $singletags:=distinct-values($labels/label/@tag/string())
let $items:= (
    for $subfield in $rec/* 
            return
                   typeswitch ($subfield)
                        case element(marc:controlfield) return ()                   
                        case element(marc:leader) return                                                 
                                <dl class="record"><dt sort="2">Type of  Material:</dt><dd>{$mattype}</dd></dl>                                
                        default return if (matches($singletags,$subfield[@tag] ) then display:displayAll($subfield) else ()
                  ,$groupedRecs)
  return 
     for $item in $items     
     order by $item/@sort
       return $item
       };
       declare function display:html($id) {
  
       <html>
		<body>
			<div id="ds-container">				
				<div id="ds-body">
				{display:display($id )}
				</div>
                                </div>
                     </body>
       </html>
};