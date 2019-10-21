xquery version "1.0-ml";
(: 
 xslt rendering  for lcdb bib records
    Take a given $id as the objid in mets, and return the permalink display of the marcxml record
    requires transformation from mxe2 to  marcslim, then running displayLcdb.xsl, as adapted from 
    lccnstyle1.xsl, and sending the header/footer, $lcdbDisplay nodes to renderPage.xsl for final layout.
    This will only work  for things with mxe or marc records, not PAE etc. 
:)
(:let $ := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', "text/html")) :)
(:import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/search-skin.xqy";:)
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";

import module namespace xslt="info:lc/xq-modules/xslt" at "/xq/modules/xslt.xqy"; 
import module namespace utils= "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace index= "info:lc/xq-modules/index-utils" at "/xq/modules/index-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/xq/modules/config/materialtype.xqy";

declare namespace xdmp="http://marklogic.com/xdmp";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace http="xdmp:http"; (: for http response:)
declare default element namespace "http://www.w3.org/1999/xhtml" ; (:for output:)
declare  namespace xhtml="http://www.w3.org/1999/xhtml" ; (:for output:)
declare namespace mxe="http://www.loc.gov/mxe";

declare namespace mat="info:lc/xq-modules/config/materials";
(:!!change these to lp:get-param-single():)
declare variable $id as xs:string := xdmp:get-request-field("id","");

declare variable $behavior as xs:string := xdmp:get-request-field("behavior",""); (:default, pageturner, contactsheet, etc. :)
declare variable $kmlurl as xs:string := xdmp:get-request-field("kmlurl",""); (: geodefault url :)
declare variable $words as xs:string := xdmp:get-request-field("words","");  (:hit highlight words (optional) :)
declare variable $part as xs:string := xdmp:get-request-field("part","");  (: labels, xml, navigation, ?? :)
declare variable $mime as xs:string := xdmp:get-request-field("mime","text/xhtml");  (: mxe, mets, mods, marcxml...dc? :)
declare variable $view as xs:string := xdmp:get-request-field("view","html");  (: could be "marctags" for bibdisplay, or "ajax" for ajax div view:)
declare variable $q as xs:string := xdmp:get-request-field("q","");

let $mets:= utils:mets($id)

return 
   if (exists($mets)) then    
        if (contains($mime,"mets")) then
          $mets
        else if  (contains($mime,"mods") ) then
              $mets//mods:mods
        else if  (contains($mime,"mxe")) then
          $mets//mxe:record
         else if  (contains($mime,"idx")) then
              $mets//idx:indexTerms
         else if  (contains($mime,"index")) then
                index:mods-to-idx($mets//mods:mods, $mets//mxe:record)    
        else if  (contains($mime,"srwdc")) then
            let $srwStyle:= "/xslt/MARC21slim2SRWDC.xsl"
            return 
                    try { 
                            xdmp:xslt-invoke($srwStyle,document{marcutil:mxe2-to-marcslim($mets//mxe:record)})                
                    	   } 
                    catch ($exception) {
                        	<error>{$exception}</error>
                         }
            (:     marcutil:marc-to-srwdc(marcutil:mxe2-to-marcslim($mets//mxe:record) ):)
       else if  (contains($mime, "marcxml")) then
           marcutil:mxe2-to-marcslim($mets//mxe:record)
       else  (: display in html  : mime is not a covered format  :) 
          let $stylesheetBase :="/xslt/"
          (: *********************  header/footer ******************** :)
          let $displayXsl :=concat( $stylesheetBase ,"displayLcdb.xsl")
          let $mxe:=$mets//mxe:record
          (:matttype logic should never go beyond the first if, since idx: contains the data:)
          let $mattype:=          
           if (not( empty($mets/mets:dmdSec[@ID="IDX1"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms//idx:typeOfMaterial))) then
                  $mets/mets:dmdSec[@ID="IDX1"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms//idx:typeOfMaterial/string()      
              else
                      let $leader6:= $mxe/mxe:leader/mxe:leader_cp06
                      let $leader6_2:= substring($mxe/mxe:leader,7,2)
                      let $control6:=$mxe/mxe:controlfield_006/mxe:c006_cp00
                      let $control7:= $mxe/mxe:controlfield_007/mxe:c007_cp00            
                      let $materials:=matconf:materials()
                      return
                         if ($materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/text()!="" ) then
                        	$materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/string()
                         else if ($materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/text()!="") then
                  	                 $materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/string()
                        else if ($materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/text()!="") then
                                  	$materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/string()
                         else ()  
                         
          let $marcxml:=marcutil:mxe2-to-marcslim($mxe)
          let $lccn:=$mxe//mxe:datafield_010/mxe:d010_subfield_a
          
          let $title:=$mets//idx:title

          let $params:=map:map()
          let $put:=map:put($params, "hostname", $cfg:DISPLAY-SUBDOMAIN)
          let $put:=map:put($params, "mattype",$mattype)
          let $put:=map:put($params, "lccn",$lccn)
          let $put:= if (not(empty($view)) ) then 
                          map:put($params, "view",$view) 
                         else ()          			
          let $lcdbDisplay:=
              try { 
          	xdmp:xslt-invoke($displayXsl,document{$marcxml},$params)
              	} 
              	catch ($exception) {
                  	$exception
              	}
             	
          return 
          (: if ajax view, don't create html;just send 2 divs :)
             if ($view="raw") then
                  <result><test>{$lcdbDisplay}</test><mets>{$mets}</mets></result> 
              else if ($view="xml") then              
                  <page>{ ssk:header(normalize-space($lccn),<span>{normalize-space($lccn)}</span>, false(),"",<meta/>), $lcdbDisplay ,ssk:footer()}</page> 
              else  if ($view="ajax") then
                  <div id="ajaxview">{$lcdbDisplay//xhtml:div[@id="ds-bibviews" or @id="ds-bibrecord"]}</div>
              else   (: permalink view, contains no search box:)
               
                  (:let $header:= ssk:header($title):)
                  let $header:= ssk:header($title,<span>{$title}</span>, false(),"",<meta/>)
                  let $footer:= ssk:footer()
                             
                  let $xml:=<page>{$header,$lcdbDisplay ,$footer}</page>
                  
                  let $htmlXsl:= concat($stylesheetBase,"renderPage.xsl" )
                  
                return
                      try {
                          xdmp:xslt-invoke($htmlXsl,document{$xml})
                      } catch ($exception) {
                          $exception
                      }        
else (:mets is null:)
  
  let $header:= ssk:header(concat(" Item not found: ",$id) ,<span>{concat(" Item not found: ",$id)}</span>, false(),"",<meta/>)
  
  let $footer:= ssk:footer()
                          
return
    (<html>{$header,<xhtml:body><h1>Item not found: "{$id}"</h1></xhtml:body>, $footer}</html>
                   ,
	xdmp:set-response-code(404, "Item not found")
)