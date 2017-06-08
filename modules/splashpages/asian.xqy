xquery version "1.0-ml";

(: splash page for asian (nksip):)
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace splash = "info:lc/splashpages/splash-utils" at "/splashpages/splash-utils.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
(: get the facet param name (i.e. f5 ) of the 'digitized' facet :)
declare variable $digitizedfacet as xs:string := string($cfg:DISPLAY-ELEMENTS/elt[facet-param/text() eq "digitized"]/facet-id);
(: auto populate form with these values :)
declare variable $query as xs:string? := xdmp:get-request-field("q", ());
declare variable $qname as xs:string? := xdmp:get-request-field("qname", "keyword");
declare variable $digitized as xs:string? := xdmp:get-request-field($digitizedfacet, "");

let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $duration := $cfg:HTTP_EXPIRES_CACHE
(:let $collection := lp:get-param-single($lp:CUR-PARAMS, "collection"):)
let $branding:=$cfg:MY-SITE/cfg:branding/string()
	let $collection:=$cfg:MY-SITE/cfg:collection/string()
	let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()

let $site-title:=$cfg:MY-SITE/cfg:label/string()
let $header := splash:header("Asian Digital Collections Home Page","")
let $html := <html xmlns="http://www.w3.org/1999/xhtml">
               {$header/head}
               
               <body>
                 
                 {splash:topnav-div($site-title)/div}
                 
                 <div id="ds-container">
                   <div id="ds-body">
                 <!--    <div id="dsresults">
                       <div id="content-results">-->
                         
                         <p>add sharetool</p>
                         <!-- END ds-bibrecord-nav -->
                       <!--</div>-->
                       <!-- END content-results -->
                       
                       <!-- New Bib Item Stuff Begins -->
                       
                       <div id="container">
                         <!-- this is the title and statement of responsibility for the object -->
                         <h1>Asian Division Collections</h1>
                         <!-- END title -->
                         
                         
                         <div id="ds-maincontent">
                           <!-- the tabs are for collection framing materials -->
                           <ul class="tabnav">
                             <li class="first">
                               <a href="#tab1">Overview</a>
                             </li>
                             
                             <li>
                               <a href="#tab2">About the collections</a>
                             </li>
                             <li>
                               <a href="#tab3">Using the Collections</a>
                             </li>
                             
                             <li>
                               <a href="#tab5">Acknowledgments</a>
                             </li>
                           </ul>
                           <!-- end class:tabnav -->
                           <div class="tab_container">
                             <div id="tab1" class="tab_content">                               
                               <h2 class="hidden">Details</h2>                               
                               <div id="collection_image">                                 
								 <img height="250" width="156" alt="Image: Mosaic of Minerva" src="/static/natlibcat/images/minerva-onwhite_jm.jpg" />                                 
                               </div>                                                            
								<p>The Asian online collections are ...
								</p>
								 <h2>
                                 <label for="searchcollection">Search by Keyword</label>
                               </h2>
                               <div class="searchnav">
                                 <form action="/asian/search.xqy" id="collectionsearch" method="GET" onsubmit="return validateForm();">
                                   <p>                                     
                                     <input name="q" type="text" size="30" class="txt" value="Search Asian collections" onfocus="this.value=''" id="searchcollection"/>									 
                                     <button id="submit">GO</button>
                                     <br/>
                                     <label for="field">Contained in:</label>
                                     <br/>
                                     <select size="9" name="qname" id="field">
                                       <option value="keyword" selected="selected">All fields</option>
										<option>----------------------------------</option>
										<option value="idx:name">Name</option>
										<option value="idx:title">Title</option>
										<option value="idx:topic">Subject</option>
										<option value="idx:abstract">Abstract</option>
										<option value="idx:language">Language</option>
										<option value="idx:beginpubdate">Publication year</option>
										<option value="idx:identifier">Record ID</option>
                                     </select>
                                   </p>
								
                                 </form>
								 <p>Also Search:
								  <ul class="tabnav"><li class="homelist">
									       <a href="/nksip/">North Korean Serials Articles</a>								  	                                  	 
								 </li>
                               </div>                                                            
                               
                             </div>
                             <div id="tab2" class="tab_content">
                               <h2 class="hidden">Rights and Restrictions</h2>
                               
                               <h2>About the <span class="oneline">Project</span></h2>
                               
                             </div>
                             <div id="tab3" class="tab_content">
                               <h2>Using the Collection</h2>
                               <p>Donec sed tellus eget sapien fringilla nonummy. Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.</p>
                             </div>
                             
                             
                             
                             <div id="tab5" class="tab_content">
                               <h2>Acknowledgments and Special Thanks</h2>
                               <p>Coming soon... Donec sed tellus eget sapien fringilla nonummy. Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.</p>
                             </div>
                           </div>
                           <!-- end class:tab_container -->
                         </div>
                         <!-- end #ds-maincontent -->
                       </div>
                       <!-- end #container -->
                       
                      {ssk:feedback-link(false())}
                       
                        {ssk:footer()/div}
                       <!-- end dsresults -->
                   <!--  </div> -->
                     <!-- id="ds-body"> -->
                   </div>
                   <!-- end id:ds-container -->
                 </div>
               </body>
             </html>
(:let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, "collection", mime:safe-mime("/lscoll/tohap/") ) :)
return (xdmp:set-response-content-type("text/html; charset=utf-8"), xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()), xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), xdmp:add-response-header("Expires", resp:expires($duration)), $doctype, $html)
