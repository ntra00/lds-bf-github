xquery version "1.0-ml";

(: splash page for any subcollection. parses collection to get it
/lscoll/lcwa/lcwa0003 = branding=lcwa0003
:)
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace splash = "info:lc/splashpages/splash-utils" at "/splashpages/splash-utils.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
(: get the facet param name (i.e. f5 ) of the 'digitized' facet :)
declare variable $digitizedfacet    as xs:string := string($cfg:DISPLAY-ELEMENTS/elt[facet-param/text() eq "digitized"]/facet-id);
(: auto populate form with these values :)
declare variable $query   as xs:string? := xdmp:get-request-field("q", ());
declare variable $qname   as xs:string? := xdmp:get-request-field("qname", "keyword");
declare variable $digitized    as xs:string? := xdmp:get-request-field($digitizedfacet, "");


let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $site:=$cfg:MY-SITE

let $branding:=$site/cfg:branding/string()
let $subsites:=$cfg:SITES//cfg:site[cfg:subsite[@branding=$branding]]
		let $url-prefix:=$site/cfg:prefix/string()
		let $site-title:=$site/cfg:label/string()
		let $image:=$site/cfg:image-url/string()

let $header := splash:header(concat($site-title, " - Library of Congress"),"")                     

let $html := <html xmlns="http://www.w3.org/1999/xhtml">
               {$header/head}
               <body>
                 
                 {splash:topnav-div($site-title)/div}
                 
                 <div id="ds-container">
                   <div id="ds-body">     
                   
                   {(: removed ds-search because it does the same thing as the search box in Overview tab :)}
                   
                 <!--    <div id="dsresults">
                       <div id="content-results">-->
                         
                         <!--<p>add sharetool</p>-->
                         <!-- END ds-bibrecord-nav -->
                     <!--  </div> --> 
                       <!-- END content-results -->
                       
                       <!-- New Bib Item Stuff Begins -->
                       
                       <div id="container">
                         <!-- this is the title and statement of responsibility for the object -->
                         <h1>{$site-title}</h1>
                         <!-- END title -->
                         
                         
                         <div id="ds-maincontent">
                           <!-- the tabs are for collection framing materials -->
                           <ul class="tabnav">
                             <li class="first">
                               <a href="#details">Overview</a>
                             </li>
                             {if ($site/*:about) then	
                             <li>
                               <a href="#about">About this collection</a>
                             </li>
							 else ()
							 }
                             {if ($site/*:using) then	
								<li>
	                               <a href="#using">Using the Collection</a>
	                             </li>
							   else 							   
							   ()
                        	 }
							 {if ($subsites) then	
								<li>
	                               <a href="#subsites">Explore sub-sites</a>
	                             </li>
							   else 							   
							   ()
                        	 }
                             {if ($site/*:credits) then	
								<li>
	                               <a href="#credits">Acknowledgements</a>
	                             </li>
							   else 							   
							   ()
                        	 }
                           </ul>
                           <!-- end class:tabnav -->
                           <div class="tab_container">
                             <div id="details" class="tab_content">
                               <!-- <h2 class="hidden">Details</h2>                                 
                                 <div id="collection_image">
                                   <img src="/static/natlibcat/images/tohap-collage.jpg" alt="A collage of images showing Professor Goldstein and his students conducting interviews in Tibet and India." width="200" height="299"/>
                                   <div>A collage of images showing Professor Goldstein and his students conducting interviews in Tibet and India.</div>
                                 </div> -->
                               <h2>Collection Overview</h2>
							   {if ($image!='') then
                               	<img src="{$image}" alt="illustrative image" width="223" height="241" hspace="10" align="right"/>
								else ()
								}
                               {if ($site/*:blurb) then 
								   	$site/*:blurb 
								   	else 
								   	<p>Brief intro to this data set</p>
								 }                                                             
                               <h2>
                                 <label for="searchcollection">Search this set</label>
                               </h2>
                               <div class="searchnav">
                                 <form action="{concat($url-prefix,'search.xqy')}" id="collectionsearch" method="GET" onsubmit="return validateForm();">
                                   <p>                                     
                                     <input name="q" type="text" size="30" class="txt" value="Search this set" onfocus="this.value=''" id="searchcollection"/>									 
                                     <button id="submit">GO</button>
                                     <br/>
                                     <label for="qname">Search In (select only one):</label> 
										<span class="limit-header" />
										<br />{
										if ($site/*:search-fields) then							 
											$site/*:search-fields
										else
										<select name="qname" size="9" id="in">
										<option value="keyword" selected="selected">Everything</option>
										<option>-------------------------------------</option>
										<option value="idx:name">Name</option>
										<option value="idx:title">Title</option>
										<option value="idx:topic">Subject</option>
										<option value="idx:abstract">Abstract</option>
										<option value="idx:language">Language</option>
										<option value="idx:beginpubdate">Date</option>
										<option value="idx:identifier">Record ID</option>
										</select>
										}
                                  
                                   </p>
								                        </form>
                              <!--end searchnav--> </div>                                                         
                   
                             
                             </div>
                             <div id="about" class="tab_content">                                                          
                               {if ($site/*:about) then	
							   $site/*:about/*
							   else
							   <h2>About the <span class="oneline">Project</span></h2>							   
							   }
                             </div>
							 <div id="subsites" class="tab_content">
							  <ul class="std">
                                 {for $subsite at $x in $subsites
                                   return                                                                            
									   <li class="homelist">									   									   
                                         <a href="{concat($subsite/cfg:prefix/string())}">{ $subsite/cfg:label/string() }</a>&#160;<!-- ({format-number(count(collection($site/cfg:collection/string())),'###,###,###,##0')} items)-->
                                       </li>									                                        
                                 }                               
                               </ul>
							   </div>
                             <div id="using" class="tab_content">                              
							   {if ($site/*:using) then	
							$site/*:using/*
							   else 							   
							   ()
							   }
                             </div>                         
							 {if ($site/*:credits) then	                             
                            	<div id="credits" class="tab_content">                                                                                      
								   {$site/*:credits/*}
								</div>
							   else
							   <div id="credits" class="tab_content">    
									<h2>Acknowledgements for creating the project<span class="oneline">Project</span></h2>							   
								</div>
							   }

                           
                           </div>
                           <!-- end class:tab_container -->
                         </div>
                         <!-- end #ds-maincontent -->
                       </div>
                       <!-- end #container -->
                       
                       {ssk:feedback-link(false())}
                       
                        {ssk:footer()/div}
                       <!-- end dsresults -->
<!--                    </div>-->
                     <!-- id="ds-body"> -->
                   </div>
                   <!-- end id:ds-container -->
                 </div>
               </body>
             </html>
(:let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, "collection", mime:safe-mime("/lscoll/tohap/") ) :)
return (xdmp:set-response-content-type("text/html; charset=utf-8"), xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()), xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), xdmp:add-response-header("Expires", resp:expires($duration)), $doctype, $html)
