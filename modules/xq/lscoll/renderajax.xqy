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
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/xq/modules/config/materialtype.xqy";

declare namespace xdmp="http://marklogic.com/xdmp";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare default element namespace "http://www.w3.org/1999/xhtml"; (:for output:)
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace http="xdmp:http"; (: for http response:)
declare namespace lcvar="info:lc/xq-invoke-variable";
declare namespace mxe="http://www.loc.gov/mxe";
declare namespace mat="info:lc/xq-modules/config/materials";

(:declare variable $tmpid as xs:string := xdmp:get-request-field("id","");
declare variable $mime as xs:string := xdmp:get-request-field("mime","text/xhtml");:)  (: mxe, mets, mods, marcxml...dc? :)
(:declare variable $tmpview as xs:string := xdmp:get-request-field("view","html"); :) (: could be "marctags" for bibdisplay, or "ajax" for ajax div view:)
declare variable $lcvar:ajaxdata as xs:string external;

let $ajaxvarTox := tokenize($lcvar:ajaxdata, ";;")
let $id := substring-after($ajaxvarTox[1], "id=")
let $mime := substring-after($ajaxvarTox[2], "mime=")
let $view := substring-after($ajaxvarTox[3], "view=")
let $ajaxparams := substring-after($ajaxvarTox[4], "params=")

let $mets:= utils:mets($id)

return
 if ($mime="mets") then
      $mets
    else if  ($mime="mods") then
          $mets//mods:mods
    else if  ($mime="mxe") then
      $mets//mxe:record
     else if  ($mime="idx") then
          $mets//idx:indexTerms
     else if  ($mime="index") then
            marcutil:mods-to-idx($mets//mods:mods, $mets//mxe:record)    
    else if  ($mime="srwdc") then
       marcutil:marc-to-srwdc(marcutil:mxe2-to-marcslim($mets//mxe:record) )
   else if  ($mime="marcxml") then
       marcutil:mxe2-to-marcslim($mets//mxe:record)
   else
        
        let $stylesheetBase :="/xslt/"
        (: *********************  header/footer ******************** :)
        let $displayXsl :=concat( $stylesheetBase ,"displayLcdb.xsl")
        let $mxe:=$mets//mxe:record
        
        let $leader6:= $mxe/mxe:leader/mxe:leader_cp06
        let $leader6_2:= substring($mxe/mxe:leader,7,2)
        let $control6:=$mxe/mxe:controlfield_006/mxe:c006_cp00
        let $control7:= $mxe/mxe:controlfield_007/mxe:c007_cp00
        let $materials:=matconf:materials()
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
          let $title:=$mxe//mxe:datafield_245/mxe:d245_subfield_a
        let $params:=map:map()
        let $put:=map:put($params, "mattype",$mattype)
        let $put:=map:put($params, "lccn",$lccn)
        let $put:= if (not(empty($view)) ) then 
                        map:put($params, "view",$view) 
                       else ()
        let $put :=
            if (string-length($ajaxparams) gt 0) then
                map:put($params, "ajaxparams", $ajaxparams)
            else
                ()
        
        let $lcdbDisplay:=
            try { 
        	    xdmp:xslt-invoke($displayXsl,document{$marcxml},$params)
            } catch ($exception) {
               	$exception
            }
        return
            (: if ajax view, don't create html;just send 2 divs :)
            if ($view="ajax") then
                    <div id="ajaxview">{$lcdbDisplay//div[@id="ds-bibviews" or @id="ds-bibrecord"]}</div>
            else    
            
                let $header:= ssk:header($title)
                let $footer:= ssk:footer()
                let $xml:=<page>{$header, $lcdbDisplay ,$footer}</page>
                
                let $htmlXsl:= concat($stylesheetBase,"renderPage.xsl" )
                
              return
                    try {
                        xdmp:xslt-invoke($htmlXsl,document{$xml})
                    } catch ($exception) {
                        $exception
                    }        
                    
 

