xquery version "1.0-ml";

(: splash page for lcwa:)
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
let $subsites:=
	<releases>
	<collection key="lcwa0011" url="http://lcweb2.loc.gov/diglib/lcwa/html/darfur/darfur-overview.html" displayLabel="Crisis in Darfur, Sudan, Web Archive, 2006" releaseDate="6/1/2009" sort="1" shortName="Crisis in Sudan"/>
	<collection key="lcwa0003" url="http://lcweb2.loc.gov/diglib/lcwa/html/iraq/iraq-overview.html" displayLabel="Iraq War, 2003 Web Archive " releaseDate="6/1/2009" sort="2" shortName="Iraq War"/>
	<collection key="lcwa0015" url="http://lcweb2.loc.gov/diglib/lcwa/html/lawlb/lawlb-overview.html" displayLabel="Law Library Legal Blawgs Web Archive" releaseDate="4/1/2009" sort="3" shortName="Legal Blawgs"/>
	<collection key="lcwa0012" url="http://lcweb2.loc.gov/diglib/lcwa/html/orgs/orgs-overview.html" displayLabel="Library of Congress Manuscript Division Archive of Organizational Web Sites" releaseDate="4/1/2009" sort="4" shortName="Manuscripts"/>
	<collection key="lcwa0010" url="http://lcweb2.loc.gov/diglib/lcwa/html/papal/papal-overview.html" displayLabel="Papal Transition 2005 Web Archive" releaseDate="4/1/2009" sort="5" shortName="Papal Transition"/>
	<collection key="lcwa0001" url="http://lcweb2.loc.gov/diglib/lcwa/html/sept11/sept11-overview.html" displayLabel="September 11th, 2001 Web Archive" releaseDate="4/1/2009" sort="6" shortName="September 11th"/>
	<collection key="lcwa0013" url="http://lcweb2.loc.gov/diglib/lcwa/html/ss/ss-overview.html" displayLabel="Single Sites Web Archive" releaseDate="4/1/2009" sort="7" shortName="Single Sites"/>
	<collection key="lcwa0002" url="http://lcweb2.loc.gov/diglib/lcwa/html/107th/107th-overview.html" displayLabel="United States 107th Congress Web Archive" releaseDate="4/1/2009" sort="8" shortName="107th"/>
	<collection key="lcwa0005" url="http://lcweb2.loc.gov/diglib/lcwa/html/108th/108th-overview.html" displayLabel="United States 108th Congress Web Archive" releaseDate="4/1/2009" sort="9" shortName="108th"/>
	<collection key="lcwa0007" url="http://lcweb2.loc.gov/diglib/lcwa/html/elec2000/elec2000-overview.html" displayLabel="Election 2000 Web Archive" releaseDate="4/1/2009" sort="10" shortName="Election2000"/>
	<collection key="lcwa0006" url="http://lcweb2.loc.gov/diglib/lcwa/html/elec2002/elec2002-overview.html" displayLabel="Election 2002 Web Archive" releaseDate="4/1/2009" sort="11" shortName="Election2002"/>
	<collection key="lcwa0016" url="http://lcweb2.loc.gov/diglib/lcwa/html/elec2004/elec2004-overview.html" displayLabel="Election 2004 Web Archive" releaseDate="4/1/2009" sort="12" shortName="Election2004"/>
	<collection key="lcwa0017" url="http://lcweb2.loc.gov/diglib/lcwa/html/elec2006/elec2006-overview.html" displayLabel="Election 2006 Web Archive" releaseDate="4/1/2009" sort="13" shortName="Election2006"/>
	<collection key="lcwa0014" url="http://lcweb2.loc.gov/diglib/lcwa/html/visual/visual-overview.html" displayLabel="Visual Image Web Sites Archive" releaseDate="4/1/2009" sort="14" shortName="Visual Images"/>	
	<collection key="lcwa0008" url="http://lcweb2.loc.gov/diglib/lcwa/html/elec2008/elec2008-overview.html" displayLabel="Election 2008 Web Archive" releaseDate="3/17/2011" sort="15" shortName="Election2008"/>	
	<collection key="lcwa0032" url="http://lcweb2.loc.gov/diglib/lcwa/html/idelec09/idelec09-overview.html" displayLabel="Indonesian General Elections 2009 Web Archive" releaseDate="08/05/2011" sort="16" shortName="Indonesia2009"/>	
	<!--<collection key="lcwa0033" url="http://lcweb2.loc.gov/diglib/lcwa/html/pptopics/pptopics-overview.html" displayLabel="Public Policy Topics Web Archive" releaseDate="" sort="17" shortName="PublicPolicy"/>-->
	<collection key="lcwa0020" url="http://lcweb2.loc.gov/diglib/lcwa/html/egypt/egypt-overview.html" displayLabel="Egypt 2008 Web Archive" releaseDate="" sort="18" shortName="Egypt"/>
	<collection key="lcwa0031" url="http://lcweb2.loc.gov/diglib/lcwa/html/inelec09/inelec09-overview.html" displayLabel="India General Elections 2009  Web Archive" releaseDate="1/19/2012" sort="19" shortName="India"/>
	<!--<collection key="lcwa0004" url="http://lcweb2.loc.gov/diglib/lcwa/html/olympics2002/olympics2002-overview.html" displayLabel="Winter Olympic Games 2002 Web Archive" releaseDate="" sort="15" shortName="Olympics2002"/>-->

</releases>
let $site-title:=$cfg:MY-SITE/cfg:label/string()
let $header := splash:header("Library of Congress Web Archives","")
let $html := <html xmlns="http://www.w3.org/1999/xhtml">
               {$header/head}
               
               <body>
                 
                {splash:topnav-div($site-title)/div}
                 
                 <div id="ds-container">
                   <div id="ds-body">
                     <!-- <div id="dsresults">
                       <div id="content-results">-->
                         
                         <p>add sharetool</p>
                         <!-- END ds-bibrecord-nav -->
                        <!--</div>-->
                       <!-- END content-results -->
                       
                       <!-- New Bib Item Stuff Begins -->
                       
                       <div id="container">
                         <!-- this is the title and statement of responsibility for the object -->
                         <h1>Library of Congress Web Archives</h1>
                         <!-- END title -->
                         
                         
                         <div id="ds-maincontent">
                           <!-- the tabs are for collection framing materials -->
                           <ul class="tabnav">
                             <li class="first">
                               <a href="#tab1">Overview</a>
                             </li>
                             
                             <li>
                               <a href="#tab2">About LCWA</a>
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
								<p>The Library of Congress Web Archives (LCWA) is composed of collections of archived web sites selected by subject specialists to represent web-based information on a designated topic. It is part of a continuing effort by the Library to evaluate, select, collect, catalog, provide access to, and preserve digital materials for future generations of researchers. The early development project for Web archives was called MINERVA.</p>
								 <h2>
                                 <label for="searchcollection">Search by Keyword</label>
                               </h2>
                               <div class="searchnav">
                                 <form action="/lcwa/search.xqy" id="collectionsearch" method="GET" onsubmit="return validateForm();">
                                   <p>                                     
                                     <input name="q" type="text" size="30" class="txt" value="Search web archives" onfocus="this.value=''" id="searchcollection"/>
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
										<option value="idx:beginpubdate">Year captured (YYYY)</option>
										<option value="idx:identifier">Record ID (loc.natlib.lcwa0003.1234)</option>
                                     </select>
                                   </p>
								
                                 </form>
                               </div>
							     <h2>Individual Web Archives Available:</h2>
                               <ul class="std">
							   {for $sub at $x in $subsites//*:collection
							      order by $sub/@displayLabel/string()
							     return 
								 if (not(matches($sub/@key/string(),'(lcwa0001|lcwa0007|lcwa0006)' ))) then
                                 <li class="homelist">
									       <a href="/{$sub/@key/string()}/">{$sub/@displayLabel/string()}</a>								  	                                  	 
								 </li>
								 else
								 
								 <li><a href="{$sub/@url/string()}">{$sub/@displayLabel/string()}</a>
								 </li>
								 }
								 
								 </ul>                                                                
               
                                                                                         
                             </div>
                             <div id="tab2" class="tab_content">
                               <h2 class="hidden">Rights and Restrictions</h2>
                               
                               <h2>About the <span class="oneline">Project</span></h2>
                               <h1>TECHNICAL INFORMATION</h1>
<p>More about current efforts in the areas of national and international partnerships and efforts in the area of web capture can be found at <a href="http://www.loc.gov/webarchiving">www.loc.gov/webarchiving</a>.</p>
<h2>Harvesting</h2>
<p>The Web sites were harvested by the Internet Archive. The harvesting depth varies according to the specifications of the curator. Information about the technical environment and tools used for harvesting web sites is available at <a href="http://www.loc.gov/webarchiving/technical.html">www.loc.gov/webarchiving/technical.html</a>.</p>

<h2>Search Component and Record Contents</h2>
<p>Archived Web sites were cataloged using the Metadata Object Description Schema (MODS). Preliminary keyword, title, and subject metadata were extracted from the archived Web sites to create preliminary MODS records that were subsequently reviewed and/or enhanced by catalogers who assigned controlled subjects from Library of Congress Subject Headings (LCSH) or Thesaurus of Graphic Materials (TGM). A Lucene search interface was developed to search the MODS records both within and across the archived collections.</p>
<h3>
<em>Collection-level:</em>
</h3>
<p>In addition, a MARC record for each <strong>collection</strong> is available in the Library of Congress Online Catalog so that the collection can be found along with other Library materials in the catalog.</p>
<p>Metadata included in <strong>collection</strong>-level records in Library of Congress Online Catalog:</p>

<p>245<span>    </span>$a Collection title $h [electronic resource].<br /> 520<span>    </span>$a General description of the collection content and number of Web sites and date range when<br />             Web sites were captured<br /> 6XX<span>   </span> $a Collection-level subject heading (usually several 6XX fields)<br /> 856<span>    </span>$a http://hdl.loc.gov/loc.natlib/collnatlib.12345678 (link to the collection <strong>Overview</strong> page)</p>

<h3>
<em>Web site level:</em>
</h3>
<p>MODS data included in record for each archived Web site:</p>
<p>
<strong>TITLE INFO</strong>
<br /> <strong>&lt;titleInfo&gt;&lt;title&gt;</strong> - Title extracted by system from HTML title tag (when available) and reviewed by cataloger, otherwise supplied by cataloger<br /> <strong>&lt;titleInfo type="alternative"&gt;&lt;title&gt;</strong> - Alternative Title supplied by cataloger if different and useful.</p>

<p>
<strong>NAME</strong>
<br /> <strong>&lt;name type="personal"&gt;&lt;namePart&gt;</strong> - Name of Web site creator in inverted order; supplied by cataloger<br /> <strong>&lt;name type="corporate"&gt;&lt;namePart&gt;</strong> - Corporate Name of Web site creator; supplied by cataloger</p>
<p>
<strong>TYPE OF RESOURCE</strong>

<br /> <strong>&lt;typeOfResource&gt;</strong> - &quot;text&quot;; supplied by system</p>
<p>
<strong>GENRE</strong>
<br /> <strong>&lt;genre&gt;</strong> - &quot;Web site&quot;; supplied by system</p>
<p>
<strong>ORIGIN INFO</strong> (A single site may have multiple captures--the first and last dates of capture are recorded)<br /> <strong>&lt;originInfo&gt;</strong>

<br />    <strong>&lt;dateCaptured encoding="iso8601" point="start"&gt;</strong>
<br />            - Date of first capture of site; extracted by system from site<br />    <strong>&lt;dateCaptured encoding="iso8601" point="end"&gt;</strong>
<br />            - Date of last capture of site; extracted by system from site</p>
<p>
<strong>LANGUAGE</strong> (languageTerm repeated for languages as needed)<br /> <strong>&lt;language&gt;</strong>
<br />    <strong>&lt;languageTerm authority="iso639-2b" type="code"&gt;</strong> - 3 letter code supplied by cataloger</p>

<p>
<strong>PHYSICAL DESCRIPTION</strong> (internetMediaType repeated for types as needed)<br /> <strong>&lt;physicalDescription&gt;<br />     &lt;internetMediaType&gt;</strong> - MIME type; supplied by system</p>
<p>
<strong>ABSTRACT<br /> &lt;abstract&gt;</strong> - Extracted by the system from the META name="description" tag in archived Web site (when available); reviewed and/or edited by cataloger</p>

<p>
<strong>NOTE<br /> &lt;note type=&quot;system details&quot;&gt;</strong> - A note that records the URL of the Web site at the time of capture; supplied by system</p>
<p>
<strong>SUBJECT</strong> (Subject repeated for subject headings and key words as needed)<br /> <strong>&lt;subject authority="lcsh"&gt;</strong> - Collection-level and Web site specific (item-level) LCSH headings; supplied<br />    by cataloger (Collection-level headings are the same as are in collection-level record in LC Online Catalog)<br /> <strong>&lt;subject authority="lctgm"&gt;</strong> - Collection-level and Web site specific (item-level) TGM headings; supplied<br />    by cataloger (Collection-level headings are the same as are in collection-level record in LC Online Catalog)<br /> <strong>&lt;subject authority="local"&gt;</strong> - Subjects assigned by cataloger<br /> <strong>&lt;subject authority="keyword"&gt;</strong> - Subject keywords extracted from META name=keywords tag in archived<br />     Web site (when available); reviewed, augmented, and/or edited by cataloger</p>

<p>
<strong>RELATED ITEM</strong> (Contains the collection title and the persistent ID for the collection)<br /> <strong>&lt;relatedItem type="host"&gt;</strong>
<br />     <strong>&lt;titleInfo&gt;&lt;title&gt;</strong> - Collection Title; supplied by system<br />      <strong>&lt;location&gt;&lt;url&gt;</strong> - Persistent ID for the collection, e.g., http://hdl.loc.gov/loc.natlib/collnatlib.12345678<br />                         that resolves to the collection Overview page; supplied by system</p>

<p>
<strong>IDENTIFIER</strong> (Contains the Resource ID for the Web site for single sites and for the resource page for a site with multiple captures)<br /> <strong>&lt;identifier&gt;</strong> - Resolvable persistent identifier for the archived web site at the Library of Congress; supplied by the system</p>
<p>
<strong>LOCATION<br /> &lt;location&gt;&lt;url usage="primary display"&gt;</strong> - Resolvable persistent identifier for archived Web site; supplied by system</p>

<p>
<strong>ACCESS CONDITION<br /> &lt;accessCondition&gt;</strong> - Rights/permissions information; supplied by system</p>
<p>
<strong>RECORD INFO<br /> &lt;recordInfo&gt;<br />      &lt;recordCreationDate encoding="iso8601"&gt;</strong> - Record creation date; supplied by system<br />      <strong>&lt;recordIdentifier source="dlc"&gt;</strong> - Identifier for the MODS record; supplied by system</p>

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
                     <!-- </div>-->
                     <!-- id="ds-body"> -->
                   </div>
                   <!-- end id:ds-container -->
                 </div>
               </body>
             </html>
(:let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, "collection", mime:safe-mime("/lscoll/tohap/") ) :)
return (xdmp:set-response-content-type("text/html; charset=utf-8"), xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()), xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), xdmp:add-response-header("Expires", resp:expires($duration)), $doctype, $html)
