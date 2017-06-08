xquery version "1.0-ml";

(: splash page for lscoll (dev + nlc ) :)
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
declare variable $starting-text := $query;
declare variable $browse-query as xs:string? := xdmp:get-request-field("bq", ());
declare variable $browse as xs:string? := xdmp:get-request-field("browse", "");

let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $collection := lp:get-param-single($lp:CUR-PARAMS, "collection")
let $subsites := <releases>
                   <collection key="lcwa" url="http://marklogic3/lcwa/" displayLabel="Library of Congress Web Archives" releaseDate="6/1/2009" sort="1" shortName="Web Archives"/>
                   <collection key="tohap" url="http://marklogic3.loc.gov/tohap/" displayLabel="Tibetan Oral History" releaseDate="6/1/2009" sort="2" shortName="tohap"/>
                   <collection key="performingarts" url="http://marklogic3.loc.gov/performingarts/" displayLabel="Performing Arts Encyclopedia" releaseDate="4/1/2009" sort="3" shortName="PAE"/>
                   <collection key="nksip" url="http://marklogic3.loc.gov/nksip/" displayLabel="North Korean Serials Articles" releaseDate="4/1/2009" sort="4" shortName="nksip"/>
                   <collection key="gottlieb" url="http://marklogic3.loc.gov/gottlieb/" displayLabel="Gottlieb Photos" releaseDate="4/1/2009" sort="5" shortName="gottlieb"/>
				   <collection key="ggbain" url="http://marklogic3.loc.gov/ggbain/" displayLabel="GG Bain Photos" releaseDate="4/1/2009" sort="6" shortName="ggbain"/>                                  
                   <collection key="copland" url="http://marklogic3.loc.gov/copland/" displayLabel="Aaron Copland Collection" releaseDate="4/1/2009" sort="6" shortName="copland"/>
                   <collection key="fulltext" url="http://marklogic3.loc.gov/fulltext/" displayLabel="Full text books, interviews etc." releaseDate="4/1/2009" sort="6" shortName="fulltext"/>                                  
				   
                 </releases>
let $header := splash:header("Library of Congress Library Services Collections","")
let $site-title:=$cfg:MY-SITE/cfg:label/string()
let $html := <html xmlns="http://www.w3.org/1999/xhtml">
               {$header/head}
               
               <body>
                {splash:topnav-div($site-title)/div}
                 
                 <div id="ds-container">
                   <div id="ds-body">
                   <!--  <div id="dsresults">
                       <div id="content-results">-->
                         
                          <!--  <p>add sharetool</p>-->
                         <!-- END ds-bibrecord-nav -->
                  <!--     </div> -->
                       <!-- END content-results -->
                       
                       <!-- New Bib Item Stuff Begins -->
                       
                       <div id="container">
                         <!-- this is the title and statement of responsibility for the object -->
                         <h1>Library Services Collections</h1>
                         <!-- END title -->
                         
                         
                         <div id="ds-maincontent">
                           <!-- the tabs are for collection framing materials -->
                           <ul class="tabnav">
                             <li class="first">
                               <a href="#details">Overview</a>
                             </li>                                                                                      
                             <li>
                               <a href="#subcoll">Explore Subcollections</a>
                             </li>                                                      
							<!--  <li>
                               <a href="#using">Using the Collection</a>
                             </li>-->
                           </ul>
						   
                           <!-- end class:tabnav -->
                           <div class="tab_container">
                             <div id="details" class="tab_content">
                               <!--<h2 class="hidden">Details</h2>
                               <div id="collection_image">
                                 <img height="250" width="156" alt="Image: Mosaic of Minerva" src="/static/natlibcat/images/minerva-onwhite_jm.jpg"/>                                 
                               </div>-->
                               <p>LSCOLL is all searchable stuff in development; includes NLC plus extra items not in production.  Use the "Explore Subsites" tab for specific sub-sites included.</p>
                               <h2>
                                 <label for="searchcollection">Search by Keyword</label>
                               </h2>
                               <div class="searchnav">
                                 <form action="/lscoll/search.xqy" id="collectionsearch" method="GET" onsubmit="return validateForm();">
                                   <p>
                                     <input name="q" type="text" size="30" class="txt" value="Search these collections" onfocus="this.value=''" id="searchcollection"/>
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
                                       <option value="idx:beginpubdate">Publication Year (YYYY)</option>
                                       <option value="idx:identifier">Record ID</option>
                                     </select>
                                   </p>                                 
                                 </form>
                               </div>
							   <div class="searchnav">
							   <h2>Browse Authorized Headings/Classes</h2>
                               <div id="browse_box">
                                 <form method="get" action="/lscoll/browse.xqy" accept-charset="UTF-8" id="browseForm">                                   
                                   <div class="browse_form">
                                     <label class="nodisplay" for="browse-search-box"><!-- Browse--></label>
                                     <input tabindex="1" id="browse-search-box" name="bq" type="text" class="browse" value="" size="25" maxlength="300"/>
                                     <button tabindex="5" id="browseSubmit">Browse</button>
                                     <input type="hidden" value="ascending" id="sort" name="browse-order"/>
                                   </div>
                                   
                                   <div id="browse-search-options">
                                     <!-- <input tabindex="2" type="radio" value="author" checked="checked" name="browse" class="searchOptionRadioControl" id="b_name"/> -->
                                     {
                                       if($browse eq "author") then <input tabindex="2" type="radio" value="author" checked="checked" name="browse" class="searchOptionRadioControl" id="b_name"/>
                                       else <input tabindex="2" type="radio" value="author" name="browse" class="searchOptionRadioControl" id="b_name"/>
                                     }
                                     <label for="b_name">Name</label>
                                     <!-- <input tabindex="3" type="radio" value="subject" name="browse" class="searchOptionRadioControl" id="b_subject"/> -->			
                                     {
                                       if($browse eq "subject") then <input tabindex="2" type="radio" value="subject" checked="checked" name="browse" class="searchOptionRadioControl" id="b_subject"/>
                                       else <input tabindex="2" type="radio" value="subject" name="browse" class="searchOptionRadioControl" id="b_subject"/>
                                     }
                                     <label for="b_subject">Subject</label>
                                     <!-- <input tabindex="4" type="radio" value="class" name="browse" class="searchOptionRadioControl" id="b_class"/> -->			
                                     {
                                       if($browse eq "class") then <input tabindex="2" type="radio" value="class" checked="checked" name="browse" class="searchOptionRadioControl" id="b_class"/>
                                       else <input tabindex="2" type="radio" value="class" name="browse" class="searchOptionRadioControl" id="b_class"/>
                                     }
                                     <label for="b_class">LC Call Number</label>
                                   </div>
                                   <!-- end ID:browse-search-options -->		
                                 </form>
                               </div>
							   
                               <!-- end CLASS: browse_form -->
							   </div>
                                                                           
                             </div>
                             
                            
                            <div id="subcoll" class="tab_content">
							 <h2>Explore the subcollections</h2>
                           	  <p>Each subcollection page allows a filtering of the dataset down to that subcollection. The same items can also be found from the search page on the main tab.</p>
							   <h2>Filter down to individual sub-sites:</h2>
                              <!-- <ul class="std">
                                 {
                                   for $sub at $x in $subsites//*:collection
                                   return
                                     if($sub/@key/string() != "lcwa0001") then
                                       <li class="homelist">
                                         <a href="/{ $sub/@key/string() }/">{ $sub/@displayLabel/string() }</a>
                                       </li>
                                     else
                                       <li><a href="{ $sub/@url/string() }">{ $sub/@displayLabel/string() }</a>
                                       </li>
                                 }
                               
                               </ul>-->
							   <ul class="std">
                                 {
                                   for $site at $x in $cfg:SITES//cfg:site
                                   return                                     
                                       
									   <li class="homelist">									   
									   {if ($site/cfg:subsite) then "&#160;&#160;&#160;&#160;&#160;" else () }
                                         <a href="{concat($site/cfg:prefix/string())}">{ $site/cfg:label/string() }</a>&#160;<!-- ({format-number(count(collection($site/cfg:collection/string())),'###,###,###,##0')} items)-->
                                       </li>									                                        
                                 }                               
                               </ul>             
                           </div>
						    <!--<div id="using" class="tab_content">
                               <h2>Using the Collection</h2>
                               <p>Search this set to see how new items not yet approved for production play well with the full set in NLC.</p>
                             </div>-->
                           <!-- end class:tab_container -->
                         </div>
                         <!-- end #ds-maincontent -->
                       </div>
                       <!-- end #container -->
                       </div>
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
