xquery version "1.0-ml";

module namespace md = "http://www.marklogic.com/ps/model/m-doc";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/xq/modules/config/materialtype.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace rdfaxhtml = "info:lc/id-modules/rdfaxhtml#" at "/xq/id-main/modules/module.RDF-2-RDFaXHTML.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace mem = "http://xqdev.com/in-mem-update" at "/xq/modules/in-mem-update.xqy";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace lcvar = "info:lc/xq-invoke-variable";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mat = "info:lc/xq-modules/config/materials";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace hld = "http://www.indexdata.com/turbomarc";
declare namespace bf    ="http://bibframe.org/vocab/";
declare namespace l = "local";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function md:lcrender($uri as xs:string) as element(div) {
(:is this used?:)
    let $params := lp:param-string($lp:CUR-PARAMS)
    let $vars := concat("id=", $uri, ";;", "mime=text/html", ";;", "view=ajax", ";;", "params=", $params)
    let $xml :=
        try {
            xdmp:invoke("/lds/renderajax.xqy", (xs:QName("lcvar:ajaxdata"), $vars))
        } catch($e) {
            $e
        }
    return $xml
};


declare function md:lcrenderBib($mets as node() ,$uri as xs:string) as element()? { 

(:returns xhtml div or error:error or 404 not found and () :)
     
    let $mime := "mime=text/html"
    
    let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'browse-order')
    let $new-params := lp:param-remove-all($new-params, 'bq')
    let $new-params := lp:param-remove-all($new-params, 'browse')
	let $new-params := lp:param-remove-all($new-params, 'collection')
	let $new-params := lp:param-remove-all($new-params, 'branding')
    
    let $ajaxparams := lp:param-string($new-params)
    
    (:let $mets:= utils:mets($uri) :)

    return 
	  if ( not(exists( $mets) ) ) then
			xdmp:set-response-code(404,"Item Not found")
	  else
		    let $stylesheetBase :="/xslt/"
		    let $displayXsl := concat( $stylesheetBase ,"displayLcdb.xsl")
    
		    let $mxe:=$mets//mxe:record
			let $idxtitle:=$mets//idx:display/idx:title/string()
        
		    let $mattype:=           
		        if (not( empty($mets//mets:dmdSec[@ID="IDX1" or @ID="index"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms//idx:typeOfMaterial))) then
		            $mets//mets:dmdSec[@ID="IDX1" or @ID="index"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms//idx:typeOfMaterial/string()      
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
			let $put:=map:put($params, "uri",$uri)
			(:suppress holdings unless marcedit="yes" :)
			let $put:= if (matches($uri,"erms\.e") ) then 
						map:put($params, "marcedit","erms-r" )
					else  if (matches($uri,"erms") ) then					
					  map:put($params, "marcedit","erms" )
					else if (matches($uri,"works") ) then 
						map:put($params, "marcedit","works" )
					else   map:put($params, "marcedit","yes" )
			let $put:= map:put($params, "url-prefix",$cfg:MY-SITE/cfg:prefix/string() )   
		    let $put :=
		        if (string-length($ajaxparams) gt 0) then
		            map:put($params, "ajaxparams", $ajaxparams)
		        else
		            ()
     		
		    let $lcdbDisplay:=
				if ($behavior="bfview") then						
					let $bf:= $mets/mets:dmdSec[@ID="bibframe"]/mets:mdWrap/mets:xmlData/rdf:RDF
						return 
							 <div id="ds-bibrecord">{rdfaxhtml:rdf2rdfaxhtml($bf)}</div>
					(:return <div id="ajaxview"><div id="dsresults"><div id="ds-bibrecord">{rdfaxhtml:rdf2rdfaxhtml($bf)}</div></div></div>:)
				else 					
			        try { 
			            xdmp:xslt-invoke($displayXsl,document{$marcxml},$params)
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
		               {$lcdbDisplay//descendant-or-self::div[@id="ds-bibviews" or @id="ds-bibrecord" or @id="tab1"][1]}     												   
		            </div> 			    
};

declare function md:lcrenderMods($mets as node() )  { (:as element()?:)
(:returns xhtml div or error:error or 404 not found and () 
developed with lcwa content
record profile is probably modsBibRecord, and source is originally mods, not mxe or marcxml
:)
     
if ( not(exists( $mets) ) ) then
			xdmp:set-response-code(404,"Item Not found")
	  else 
	    let $mime := "mime=text/html"
    	let $ip as xs:string? := xdmp:get-request-header("X-Forwarded-For")
    	let $branding:=$cfg:MY-SITE/cfg:branding/string()
		let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()

		(:let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)
        let $url-prefix:=concat("/",$branding,"/"):)
	    let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'browse-order')
	    let $new-params := lp:param-remove-all($new-params, 'bq')
	    let $new-params := lp:param-remove-all($new-params, 'browse')
	    let $new-params := lp:param-remove-all($new-params, 'collection')
	    let $new-params := lp:param-remove-all($new-params, 'branding')
	    let $ajaxparams := lp:param-string($new-params)
		let $objectType := substring-after($mets//@PROFILE,'lc:')
		let $uri := $mets//@OBJID/string()
		let $behavior as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'behavior', 'default')
        
    
 		(:*********************  Description *********************  :)

		    
		    let $labelsParams := map:map()
			let $put := map:put($labelsParams, "uri", $uri)    
		    let $put := map:put($labelsParams, "profile", $objectType)    
		    let $put := map:put($labelsParams, "ip", $ip) 
		    let $put := map:put($labelsParams, "behavior", $behavior)			
		    let $put := map:put($labelsParams, "branding", $branding)
			let $put := map:put($labelsParams, "ajaxparams", $ajaxparams)  

		    let $labels :=
		        try {
		            xdmp:xslt-invoke("/xslt/mods/labels.xsl", $mets, $labelsParams)
		        } catch ($exception) {
		            $exception
		        }      
		    (: ------- group same labels together --------- :)		    
		    let $groupings :=
		        try {
		            xdmp:xslt-invoke("/xslt/mods/groupings.xsl", document{$labels})                  
		        } catch ($exception) {
		            $exception
		        }  
		  let $illustrative:=utils:illustrative($mets/node() ,$uri)      		    
		  let $imagepath := 
				if ( matches($uri,"lcwa") and exists($illustrative) ) then
					<img src="{replace($illustrative,'lcwa','mrva')}/200" alt="thumbnail" />			
			    else if (matches($objectType,"(bibRecord|modsBibRecord|metadataRecord)") and exists($illustrative)) then
			        <img src="{$illustrative}/200" alt="thumbnail" /> 	  	        
					else 					
						()

			  			
		   let $modsDisplay:=   
		        try {
		            xdmp:xslt-invoke("/xslt/mods/mods-metadata.xsl", document{$groupings})                  
		        } catch ($exception) {
		            $exception
		        }   
	let $modsDisplay:=
		if (not(empty($imagepath))) then 
			mem:node-insert-before($modsDisplay//h1[@id="title-top"],$imagepath)
		else $modsDisplay
							
				(:*********************  Menu *********************  :)      
    let $itemID as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'itemID', '')
    let $menuParams := map:map()
    let $put := map:put($menuParams, "url", xdmp:get-request-url()  ) 
    let $put := map:put($menuParams, "behavior", $behavior)
    let $put := map:put($menuParams, "itemID", $itemID)
    let $put := map:put($menuParams, "id", $uri)
    let $put := map:put($menuParams, "hostname", $cfg:DISPLAY-SUBDOMAIN)
    let $menu :=
        try {                     
            xdmp:xslt-invoke("/xslt/pageturner/navigation.xsl",$mets, $menuParams)
        } catch ($exception) {
            $exception
        } 		 	
	let $restricted:=
		if (matches($mets//mods:accessCondition[@type="restrictionOnAccess"],'^Access restricted') ) then
			 true()
		 else  false()
	let $contents :=
	       <ul class="std">{ 
			   	for $item at $count in $menu//l:items/l:item[@fileid]
					return <li id="{$item/@fileID}">
				         <code id="{$item/@fileID}" style="display:none">{$count}</code>
						<a id="{$item/@fileID}" class="player_trigger" href="">{$item//l:title/string()}</a>								
						<p class="abstract">{$item//l:comment/string()}</p></li>
				}
				(: web crawl parts or other links out to known urls :)
				{ 
			   	for $item at $count in $menu//l:item[@id and not(@fileid)]
					return <li id="{$item/@id}">					
								{if (not($restricted) or  matches($ip,"^140.147\.")) then
  								 if (matches($branding,'(lcwa|lcwa[0-9]+)' ) or matches($uri,'lcwa') ) then
									<a id="{$item/@id}"  target="_blank" rel="nofollow" href="{$item//l:href/l:url}">{$item//l:title/string()}</a>
									else
										<a id="{$item/@id}"  href="{$item//l:href/l:url}">{$item//l:title/string()}</a>
								else
									<span>{$item//l:title/string()}</span>
								}
								<p class="abstract">{$item//l:comment/string()}</p>
							</li>
				}
				</ul>
	
		    return  	
			if ($behavior="grp") then
			  	 $groupings		
			   else
			   (:???? could this be dt:transform($groupings/?? instead of modsdisplay??? :)
			   if ($labels instance of element(error:error)) then
				  $labels
				else if ($groupings instance of element(error:error)) then
				  $groupings
			    else if ($modsDisplay instance of element(error:error)) then
				  $modsDisplay           
		        else
		            <div id="ajaxview">
						{$modsDisplay} {md:sidebar($groupings, $contents, $branding, $uri)}
		            </div> 							  
};

declare function md:renderDigital($result as node()) as element(div)* {
    
	let $mets := if ($result/mets:mets) then $result/mets:mets else $result
	
    let $uri := $mets/@OBJID/string()    
    let $stylesheetBase := "/xslt/"
    (:let $objectType := substring-after($mets/@PROFILE,'lc:'):)
	let $objectType := fn:string($mets/@PROFILE)
    let $ip as xs:string? := xdmp:get-request-header("X-Forwarded-For")
    let $behavior as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'behavior', 'default')
    let $hostname :=  $cfg:DISPLAY-SUBDOMAIN
    let $branding:=$cfg:MY-SITE/cfg:branding/string()
	let $site-title:=$cfg:MY-SITE/cfg:label/string()
	let $section as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'section')
 (:   let $page as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'page')
    let $size as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'size'):)
    let $itemID as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'itemID')
	  	
    (:*********************  Menu *********************  :)      
    let $menuXsl := concat($stylesheetBase, "pageturner/navigation.xsl")
    let $menuParams := map:map()
    let $put := map:put($menuParams, "url", xdmp:get-request-url()  ) 
    let $put := map:put($menuParams, "behavior", $behavior)
    let $put := map:put($menuParams, "itemID", $itemID)
    let $put := map:put($menuParams, "id", $uri)
    let $put := map:put($menuParams, "hostname", $cfg:DISPLAY-SUBDOMAIN)
    let $menu :=
        try {                     
            xdmp:xslt-invoke($menuXsl,$mets, $menuParams)
        } catch ($exception) {
            $exception
        }
     
    (:*********************  all full texts (currently just tohap, NOT IA) *********************  :)
	(: won't be necessary to do this when we integrate the JS on tab4 (and snippets??) :)
  let $tei := 
  	if ($mets//tei:TEI) then
  		utils:tei-files($mets)
	else
		()

  let $full-text :=	   
  	if (exists($tei)) then
        try {
            xdmp:xslt-invoke("/xslt/pageturner/tei2HTML.xsl", $tei)
        } catch ($exception) {
            $exception
        }     
		else 
		 ()
		 	
    (:*********************  Description *********************  :)
     
    let $labelsParams := map:map()
	let $put := map:put($labelsParams, "uri", $uri)    
    let $put := map:put($labelsParams, "profile", $objectType)    
    let $put := map:put($labelsParams, "ip", $ip) 
    let $put := map:put($labelsParams, "behavior", $behavior)  
	let $put := map:put($labelsParams, "branding", $branding)  
    let $labels :=
        try {
            xdmp:xslt-invoke("/xslt/mods/labels.xsl", $mets, $labelsParams)
        } catch ($exception) {
            $exception
        }      
	
    (: ------- group same labels together --------- :)
    
    let $groupings :=
        try {
            xdmp:xslt-invoke("/xslt/mods/groupings.xsl", document{$labels})                  
        } catch ($exception) {
            $exception
        }        
	
	(:*********************  related item children contents and snippets if found *********************  :)        
    
    let $contents := 
       <ul class="std">{ 
	   	for $item at $count in $menu//l:items/l:item
			return <li id="{$item/@fileID}"><!--<h1>{$item//l:href/l:sectionTitle/string()}</h1>-->
			         <code id="{$item/@fileID}" style="display:none">{$count}</code>
					<a id="{$item/@fileID}" class="player_trigger" href="">{$item//l:title/string()}</a>
					
					<p class="abstract">{$item//l:comment/string()}</p></li>
			}</ul>

	(:*********************  Right Nav bar (available behaviors, related items ) *********************  :)    
    (: not used anymore - rsin
    let $illustrative:=utils:illustrative($mets,$uri):)
    let $main :=      
	  
       	if ($behavior eq "default") then			      	
		  md:maincontent($groupings, $behavior, $uri, $objectType)
       
		else if ($behavior="menu") then
 				$menu		
		else if ($behavior="tei") then
				$tei
		else if ($behavior="full") then
				$full-text		
		else if ($behavior="contents") then
 				($contents)	
		else if ($behavior eq "labels") then
            	$labels
	    else if ($behavior="bfview") then
 				($groupings)
        else if ($behavior="grp") then
 				($groupings)
        else (: this is not being used , but could access contactsheet and other xsl's :)
                       
            ()
    return 
        <div id="ajaxview">    
			<div id="container"> 						
				<h1 id="title-top" style="width:80%" >{$site-title}<br /><span>{$groupings/l:descriptive/l:pagetitle/text() }</span></h1>
				<abbr title="{normalize-space($uri)}" class="unapi-id"></abbr>
				
				 {md:sidebar($groupings, $contents,$branding,$uri)}
				 {$main}
				 {$groupings//*:metatags}<!-- for seo, removed before display -->
			</div>
			{if ($behavior="debug") then <div class="debug" style="visibility: hidden;">{$groupings}</div>        else ()}
        </div>
};
declare private function md:dt-transform($nodes as node()*) as item()* {
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node            
			case element(l:element) return 
										element dt {attribute class {"label"},
					  								md:dt-transform($node/node())
										 		} 	
			
			case element(l:label) return md:dt-transform($node/node())										 			
            case element(l:value) return element dd {attribute class {"bibdata"},
													md:dt-transform($node/node())
											}
			case element(l:href) return  if ($node//l:browseurl and not($node//l:url)) then 
											md:dt-transform($node/node())										
										 else 
										 	element a {md:dt-transform($node/node())}
														
            case element(l:url) return attribute href {md:dt-transform($node/node())}           
			case element(l:browseurl) return ()	
            default return md:dt-transform($node/node())
};
(:declare function md:li-singletransform($nodes as node()* ) as item()* {
(: each element/value is an li ... not used

:)
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node            
			case element(l:element) return md:li-singletransform($node/node())
			case element(l:label) return 	()
            case element(l:value) return element li {md:li-singletransform($node/node())}
			case element(l:href) return element a {md:li-singletransform($node/node())}
            case element(l:url) return	attribute href {md:li-singletransform($node/node())}           									
			case element(l:browseurl) return ()																				
         default return md:li-singletransform($node/node())
};:)

declare private function md:li-browsetransform($nodes as node()* ) as item()* {
(: each element/value is an li , for right nav bar... uses browse url, not search url
not all values have browseurl (only if lcsh, auth, etc) 

:)
    for $node in $nodes
    return 
        typeswitch($node)
            case text()				return $node            
			case element(l:element) return md:li-browsetransform($node/node())
			case element(l:label) 	return ()
            case element(l:value) 	return if ($node//l:browseurl) then 
												element li {md:li-browsetransform($node/node())}
											else () 
			case element(l:href) 		return element a {md:li-browsetransform($node/node())}            						
			case element(l:browseurl) 	return  attribute href {md:li-browsetransform($node/node())}           																				
            case element(l:url) 		return	()	

		default 					return md:li-browsetransform($node/node())
};
declare private function md:li-alltransform($nodes as node()*) as item()* {
(:

<li>Links: <a href="href/url">href text </a>| <a href="#">Publishers Desciption</a> | <a href="#">Abstract/Review</a></li>


<value>
		<href>
			<url>http://hdl.loc.gov/loc.music/copland.writ0025</url>
			http://hdl.loc.gov/loc.music/copland.writ0025
			</href>
	</value>
:)
    for $node in $nodes
    return 
        typeswitch($node)
            case text() 				return $node            
			case element(l:element) 	return md:li-alltransform($node/node())
			case element(l:label) 		return ()
            case element(l:value) 		return md:li-alltransform($node/node())
			case element(l:href) 		return element a {md:li-alltransform($node/node())}
            case element(l:url) 		return attribute href {md:li-alltransform($node/node())}           
			case element(l:browseurl) 	return ()

         default 						return ()
};
declare function md:locations($groupings, $uri, $objectType) {

let $links:= if (matches($objectType,"(modsBibRecord | bibRecord)")) then
			   	 <li>Links: 
			        {for $link at $x in $groupings//l:element[lower-case(l:label)="url" or l:label="Electronic resource"][//l:href]/l:value   
			    		return ( 
			    			md:li-alltransform($link),  
			    				if ($x != count($groupings//l:element[@field="url" or l:label="Electronic resource"][//l:href]/l:value ) ) then " | "  else () 
			    			),
			    			for $link at $x in $groupings//l:element[@field="identifier"][lower-case(l:label)="url"]/l:value
			    				return (md:li-alltransform($link), if ($x != count($groupings//l:element[@field="identifier"][lower-case(@label)="url"]/l:value)) then " | " else () 
			    			)
					}
		  	 	 </li>
			else () 
let $locations:= if ($groupings//l:element[@field="location" or l:label="Repository"]/l:value) then
					<li>Library Location: 
						{for $loc at $x in $groupings//l:element[@field="location" or l:label="Repository"]/l:value
				    		return
				        		(md:li-alltransform($loc), if ($x != count($groupings//l:element[@field="location" or l:label="Repository"]/l:value) ) then " | " else ())
						}
					</li> 
		else ()
return
    ($links,$locations)
};

declare private function md:sidebar($groupings as node(), $contents as element(), $branding as xs:string , $uri as xs:string) {
 (:let $browse:= $groupings//*[(matches(lower-case(l:label/string()),"(subject|name|call no)")) or matches(@field,"name")] :)
let $ip as xs:string? := xdmp:get-request-header("X-Forwarded-For")


let $browse:= $groupings//*[matches(lower-case(l:label),"(subject|name|classification)")][//l:browseurl]
	(:id="sidebar":)
let $url-prefix:=if (xdmp:get-request-header('X-LOC-Environment')='Staging') then "/tohap/" else ()

return
	<div  id="sidebar">
			<!-- use this to link to the collection/collections for the digital item -->
			{ (: Don't display div at all if there are no relatedItem nodes :)
                if ($groupings//l:relatedItem[@type="host"]) then
        			<div id="collection">
        				<h3>Collection</h3>
        				
        					<ul class="std">
        						{for $item at $x in md:li-alltransform($groupings//l:relatedItem[@type="host"]/l:element)
        						  return <li>
        								  {if ($branding="tohap" and $x=1)then
        								  	<a href="/tohap/">Tibetan Oral History and Archive Project (TOHAP)</a>
        								  	else $item
        								  }</li>
        						 }						
        					</ul>
        			</div>
    			else ()
                    }
			<!-- end id:#sidebar #collection -->
			{if (exists($contents//li) ) then
				<div id="related">					
					<h3>{if (matches($branding,'(lcwa|lcwa[0-9]+)' ) or matches($uri,'lcwa') ) then "Access the Archive" else "Interview Parts"}</h3> 
					<ul class="std">
						{for $item in $contents//li return 									
						 <li>					
							{$item/*[@class!='abstract' or not(@class)]}
						</li>
						}
						</ul>
				</div>
				else ()
			}
			<!-- use this to link to browses for related subjects, names and LC classes -->
			{if (exists($browse)) then
				<div id="xml"><h3>Browse More Like This</h3>
					{
						(  		(:at least one lcsh: :)
							if ($browse[matches(lower-case(l:label),"subject" )]//l:browseurl ) then																														
								<div id="browse-subjects">
									<h4>Subjects</h4>
										<ul class="std">
											{md:li-browsetransform($browse[matches(lower-case(l:label/string()),"subject")][//l:browseurl])}											
										</ul>
								 <!--end browse-subjects --></div>
							 else (),
							 if ($browse[matches(lower-case(l:label),"name" )]//l:browseurl ) then																							
								<div id="browse-names">
									<h4>Names</h4>
										<ul class="std">
											{md:li-browsetransform($browse[matches(lower-case(l:label/string()),"name" )][//l:browseurl])}			
										</ul>
								 <!-- end browse-names --></div>
							 else (),
							  if ($browse[matches(lower-case(l:label),"classification" )]//l:browseurl ) then
								<div id="browse-class">
									<h4>LC Class</h4>
										<ul class="std">										
											{md:li-browsetransform($browse[matches(lower-case(l:label),"classification" )][//l:browseurl])}
										</ul>
								 <!-- end browse-class --></div>
							 else ()
						 )
					 }
					<!-- end id: related -->
					</div>
									
				else () }			
				
				{if ($groupings//l:element[@field="identifier"][starts-with(l:label,'Reproduction Number')]) then
				<div id="duplication">
					<h3>Obtain Copies</h3>					
					<ul class="std">					
					  <li><a href="http://www.loc.gov/duplicationservices/order.html">Duplication Services -- stock number: 
					 { for $item in $groupings//l:element[@field="identifier"][starts-with(l:label,'Reproduction Number')]
					 	 return ($item/l:value/string()," ") }</a></li>
					</ul>									
				<!-- end duplication --></div>
				else ()
					}
			<div id="xml">
			<h3>XML Metadata for This Item</h3>
			<ul class="std">	
				<li>
					<a href="{concat($url-prefix,$uri)}.rdf">BIBFRAME RDF</a>
				</li>
				<li>
						<a href="{concat($url-prefix,$uri)}.dc.xml">Dublin Core (SRU)</a>
				</li>
				<li>
					<a href="{concat($url-prefix,$uri)}.mets.xml">METS</a>
				</li>
			</ul>
			</div><!-- end xml -->
			<div id="permalink">
			<h3>Bookmark This Item</h3>
			<ul class="std">	
				<li>
					<span id="print-permalink" class="white-space">
						<a href="{concat($url-prefix,$uri)}">{$uri}</a>
					</span>
				</li>
			</ul>
			</div> <!--end permalink -->
				{ if (matches($branding,'(lcwa|lcwa[0-9]+)' ) or matches($uri,'lcwa') ) then 	
						()
				else
					ssk:feedback-link(true())
				}
			
		</div>
		};

declare function md:maincontent($groupings as node()?, $behavior as xs:string?, $uri as xs:string, $objectType as xs:string?) as element(div) {

	let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()

	let $imagepath := 		
		if (matches($objectType,"(bibRecord|modsBibRecord)") ) then
			<img src="/media/{replace($uri,'lcwa','mrva')}/0001.tif/200" alt="thumbnail" />			
			else 
				()

	(: holdings-- not done: only if we use tabbed view for lcdb records: :)
	let $hold := 
	   if (contains($uri, "lcdb") and not(contains($uri, "works")) ) then
	       utils:hold-bib(xs:integer(tokenize($uri, "\.")[last()]),"lcdb")
	   else ()    


	(: the ds-viewport class is a container for the viewport or other digital object player; if id=viewport-off, then it will disappear :)	
	let $window:=	
		if (matches($objectType,"(recordedEvent|simpleAudio|videoRecording)")) then 
			(:should we change this to pass in $mets???:)			
			let $json-list:= utils:mets-files($uri,"json","all")						
			let $script:= 
			 	<script type="text/javascript">
    			 $(document).ready(function () {{
    			     clean_json({$json-list});
    			 }});
			 	</script>
			return
			(<div id="lcPlaylistPlayer" style="height: 148px; margin-bottom: 1.5em; width: 522px; display:block;"><!-- end class:lcPlaylistPlayer --></div>
			, $script)
		else
			<div id="ds-digitalport">
				<div id="{if ( contains($uri,'lcwa') or contains($uri,'lcdb') ) then 'viewport-off' else 'viewport-on'}"><!-- end class:viewport-on --></div>
			<!-- end class:ds-viewport --></div>
    
    return    				
    		<div id="ds-maincontent"><span id="objectType" style="visibility: hidden;">{$objectType}</span>
    			{$window}    			
    			<!-- the tabs are for bib views digital behaviors, etc. -->
    			{if (contains($uri,'tohap')) then
    			     md:tohap-content-tab($uri,$url-prefix,$groupings)
    			 else if (contains($uri,'ia')) then
    			     md:ia-content-tab($uri,$url-prefix,$groupings)
    			 else
    			(
				<ul class="tabnav">
				  <li class="first active"><a href="#access">Access/Details</a></li>				 
                  {
                    if (contains($uri,"lcdb")) then
                        <li><a class="get_holdings" href="#holdings">Holdings</a></li>
                    else ()
                  }
					 <li><a href="#rights">Rights/Restrictions</a></li>
				<!-- end class:tabnav --></ul>,

    			<div class="tab_container">
    				<div id="access" class="tab_content">
						{(: removed for now; we can sort the location/url higher if we want on modsbibrecords or 856 on ia/lcdb records 
							let $links-locs:=md:locations($groupings, $uri, $objectType)
					 	  return  if  (exists($links-locs) and $cfg:MY-SITE/cfg:branding/string!="tohap" ) then
    								<div class="access-box">
    									<h2 class="hidden">Access</h2>
    									<ul class="std">{$links-locs}</ul>
    								</div>							 									 								 		
									else 
							 			()
						:)
						}
    					<!-- access-box -->
    					<div id="ds-bibrecord-new">						
    						<h2 class="hidden">Details</h2>
    						{$imagepath}
    						{md:record-display($groupings)}
    					</div>
                    <!--bibrecord-->
    				</div>
    				<!-- access tab -->
    			
    					{
    					   if (contains($uri,"lcdb")) then
    					       (
    					       <a class="hidden" id="holdings_tab_url" href="{$url-prefix}parts/holdings.xqy?uri={$uri}&amp;status=yes"></a>,
    					       <div id="holdings" class="tab_content">
    					       <h2 class="hidden">Holdings</h2>
                                {if ($hold/hld:r) then
                                    (<div class="holdings"></div>)
                                 else
                                    (<span class="noholdings">Library of Congress Holdings Information Not Available.</span>)
                                 }
    					       </div>)
    					   else ()
    					}

                        {md:rights-tab($groupings)}
    			<!-- tab_container --></div>
    			)		
    			}				
    		<!-- maincontent: -->
    		</div>
};

declare function md:record-display($groupings) {
    <dl class="record">
        {                           
          for $element in $groupings//l:full/l:element[l:label/string()!="Copyright"]
              return (
                md:dt-transform($element)                                            
            )                           
        }
    </dl>
};

declare function md:rights-tab($groupings) {
    <div id="rights" class="tab_content">
        <h2 class="hidden">Rights and Restrictions</h2>
        <p>                           
            <strong>Access:&#160;</strong>
            {
                if ($groupings//l:element[matches(lower-case(l:label),"useandreproduction")]) then 
                        for $condition in $groupings//l:element[matches(lower-case(l:label),"useandreproduction")]/l:value
                        return
                            md:li-alltransform($condition)
                else 
                    " Conditions Undetermined."
            }
        </p>                        
        <p>                         
                <strong>Restrictions:&#160;</strong>
                {
                    if ($groupings//l:element[matches(l:label,"estrictions")]) then 
                        for $condition in $groupings//l:element[matches(l:label,"estrictions")]/l:value
                        return
                            md:li-alltransform($condition)                                                                  
                     else 
                         " Undetermined."
                }                           
        </p>                    
        <!--<p>
            <strong>Credit Line:&#160;</strong>
            { if ($groupings//l:element[ matches(l:label,"Permissions")] ) then                             
                    for $condition in $groupings//l:element[matches(l:label,"Permissions")]/l:value
                        return md:li-alltransform($condition)
             else 
              " Undetermined."
            }
            </p>-->
            <p>
            <strong>Copyright Statement:&#160;</strong>
            { if ($groupings//l:element[matches(l:label,"Copyright") ] ) then                           
                    for $condition in $groupings//l:element[matches(l:label,"Copyright") ]/l:value
                        return concat(md:li-alltransform($condition),' ')
             else 
              " Undetermined."
            }
            </p>
   <!-- rights --> </div> 
};

declare function md:tohap-content-tab($uri, $url-prefix,$groupings) {
    let $searchurl:=concat($url-prefix,'parts/tei-tab.xqy?uri=',$uri)
    let $q as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q','')
    let $searchform := <div class="access-box">
            <form onsubmit="return searchFullText(this);" method="GET" style="margin-bottom:0px; padding-bottom:0px;">
            <label for="searchcollection" class="box-label">Search within text/transcript:</label><br />
                <input name="q" type="text" size="50"  maxlength="125"  class="txt" value="{$q}" onfocus="this.value=''" id="searchcollection"/>
                <button id="submit">Go</button><input name="url" type="hidden" value="{$searchurl}"  id="objid"/>
            </form>
        </div>
    return
      (           
        <ul class="tabnav">
            <li class="first active"><a href="#access">Access/Details</a></li>
            <li><a class="get_snippets" href="#snippets">Text/Transcript Search Results</a></li>
            <li><a href="#transcript">Text/Transcript</a></li>
            <li><a href="#rights">Rights/Restrictions</a></li>
        </ul>,
        <div class="tab_container">
            <div id="access" class="tab_content">
                {(: should the searchform only be displayed when in tohap branding??:) 
                $searchform}
                <!-- access-box -->
                <div id="ds-bibrecord-new">                     
                    <h2 class="hidden">Details</h2>
                    {md:record-display($groupings)}
                </div>
            <!--bibrecord-->
            </div>
            <!-- access tab -->
              
            <a id="tei_tab_url" class="hidden" href="{$url-prefix}parts/tei-tab.xqy?uri={$uri}&amp;q={lp:get-param-single($lp:CUR-PARAMS, 'q')}"></a>
                    <div id="snippets" class="tab_content">
                            <h2 class="hidden">Full-text Search Results</h2>
                            <div id="tei-snips"></div>
                        </div>
                   
                        <div id="transcript" class="tab_content">
                            <h2 class="hidden">Full Text</h2>                                   
                            <div id="tei-div"> </div>
                        </div>
            {md:rights-tab($groupings)}    
        <!-- tab_container -->
        </div>   
      )     
};

declare function md:ia-content-tab($uri, $url-prefix, $groupings) {
    (
                <ul class="tabnav">
                  <li class="first active"><a href="#access">Access/Details</a></li>                 
                  <li><a class="get_search_results" href="#search">Text Search Results</a></li>
                  <!-- <li><a href="#citation">Citation Formats</a></li> -->
                  <li><a href="#rights">Rights/Restrictions</a></li>
                </ul>,
                        
                <div class="tab_container">
                    <div id="access" class="tab_content">
                        <!-- access-box -->
                        <div id="ds-bibrecord-new">                     
                            <h2 class="hidden">Details</h2>
                            {md:record-display($groupings)}
                        </div>
                    <!--bibrecord-->
                    </div>
                    <!-- access tab -->

                    <a class="hidden" id="search_tab_url" href="{$url-prefix}parts/ia-search.xqy?uri={$uri}&amp;q={lp:get-param-single($lp:CUR-PARAMS, 'q')}"></a>,
                    <div id="search" class="tab_content" style="overflow: auto"></div>
                    {md:rights-tab($groupings)}
                <!-- tab_container -->
                </div>                                
        )
};