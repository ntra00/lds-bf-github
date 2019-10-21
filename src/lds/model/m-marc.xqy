xquery version "1.0-ml";

module namespace mm = "http://www.marklogic.com/ps/model/m-marc";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/nlc/lib/l-query.xqy";
import module namespace lh = "http://www.marklogic.com/ps/lib/l-highlight" at "/nlc/lib/l-highlight.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/xq/modules/config/materialtype.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace pb = "info:lc/xq-modules/config/profile-behaviors" at "/xq/modules/config/profile-behaviors.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace mem = "http://xqdev.com/in-mem-update" at "/xq/modules/in-mem-update.xqy";
declare namespace lcvar = "info:lc/xq-invoke-variable";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mat = "info:lc/xq-modules/config/materials";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hld = "http://www.indexdata.com/turbomarc";
declare namespace l = "local";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function mm:renderMarcBib($mets as node(), $bibtype as xs:string ) as element()? { 

(:returns xhtml div or error:error or 404 not found and () :)
     
    let $mime := "mime=text/html"
    
    let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'browse-order')
    let $new-params := lp:param-remove-all($new-params, 'bq')
    let $new-params := lp:param-remove-all($new-params, 'browse')
	let $new-params := lp:param-remove-all($new-params, 'collection')
	let $new-params := lp:param-remove-all($new-params, 'branding')
    
    let $ajaxparams := lp:param-string($new-params)
        
    return 
	  if ( not(exists( $mets) ) ) then
			xdmp:set-response-code(404,"Item Not found")
	  else		      
		    let $mxe:=$mets//mxe:record
			let $idxtitle:=$mets//idx:display/idx:title/string()
        
		    let $mattype:=           
		        if (not( empty($mets//mets:dmdSec[@ID="IDX1"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms//idx:typeOfMaterial))) then
		            $mets//mets:dmdSec[@ID="IDX1"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms//idx:typeOfMaterial/string()      
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
		    let $lccn:= ($mxe//mxe:datafield_010/mxe:d010_subfield_a)[1]
		    let $behavior as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'behavior', 'default')
			(:status is the bib circ status:)
    		let $status as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'status', 'no')
			let $branding := lp:get-param-single($lp:CUR-PARAMS, 'branding','lds')
		    let $params:=map:map()
		    let $put:=map:put($params, "hostname", $cfg:DISPLAY-SUBDOMAIN)
		    let $put:=map:put($params, "mattype",$mattype)
		    let $put:=map:put($params, "lccn",$lccn)
		    let $put:=map:put($params, "behavior",$behavior)
			let $put:=map:put($params, "idxtitle",$idxtitle)
			let $put:=map:put($params, "status",$status)
			let $put:= map:put($params, "url-prefix",$cfg:MY-SITE/cfg:prefix/string() )   
			let $put:= if ($bibtype="erms" ) then
						map:put($params, "marcedit","erms" )
					else ()
		    let $put :=
		        if (string-length($ajaxparams) gt 0) then
		            map:put($params, "ajaxparams", $ajaxparams)
		        else
		            ()
        
		    let $lcdbDisplay:=
		        try { 
		            xdmp:xslt-invoke("/xslt/displayLcdb.xsl",document{$marcxml},$params)
		        } catch ($exception) {
		            $exception
		        }    
				(:let $bib:=substring-after($uri,".lcdb.")
				let $statuses:=
				xdmp:http-get(concat("http://lcweb2.loc.gov:8081/diglib/voyager/",$bib,"/statuses"))[2]:)
		    return  
				if ($lcdbDisplay instance of element(error:error)) then
				  $lcdbDisplay
		           (: need to handle this in detail.xqy:(<strong>Error: {$lcdbDisplay//error:message/string()}</strong>,xdmp:add-response-header("status", "500") ) :)
		        else
		            <div id="ajaxview">
		                {$lcdbDisplay//div[@id="ds-bibviews" or @id="ds-bibrecord"]}     
						<!--<br clear="all"/>{$statuses//*[local-name()='STATUS']} -->
		            </div> 			    
};
