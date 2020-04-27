xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: get the facet param name (i.e. f5 ) of the 'digitized' facet :)
declare variable $digitizedfacet as xs:string := string($cfg:DISPLAY-ELEMENTS/elt[facet-param/text() eq 'digitized']/facet-id) ;
(: auto populate form with these values :)
declare variable $query as xs:string? := xdmp:get-request-field("q", ());
declare variable $qname as xs:string? := xdmp:get-request-field("qname", "keyword");
declare variable $digitized as xs:string? := xdmp:get-request-field($digitizedfacet, "");
declare variable $filter as xs:string? := xdmp:get-request-field("filter", "all");
declare variable $precision as xs:string? := xdmp:get-request-field("precision", "anymatch");
declare variable $category as xs:string? := xdmp:get-request-field("category", "all");
declare variable $starting-text := $query;
declare variable $browse-query as xs:string? := xdmp:get-request-field("bq", ());
declare variable $browse as xs:string? := xdmp:get-request-field("browse", "");
(:declare variable $behavior as xs:string? := xdmp:get-request-field("behavior", "bfview");:)
let $hostname:=  $cfg:DISPLAY-SUBDOMAIN
let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $doctype := '<!DOCTYPE html>'
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $today:=fn:current-date()
let $html :=
    <html xmlns="http://www.w3.org/1999/xhtml">
    	<head>
    		<title>{$cfg:META-TITLE}</title>
    		<meta http-equiv="Content-Language" content="en-us" />
    		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <meta name="robots" content="noindex"/>
    		<meta name="keywords" content="Linked Data Services search library congress collections" />
    		<meta name="description" content="Linked Data Services :  Library of Congress Bibliographic and authority data in linked data formats." />
    		<link rel="stylesheet" media="print" type="text/css" href="/static/lds/css/datastore-print.css" />
    		<link rel="stylesheet" media="screen, projection" type="text/css" href="/static/lds/css/datastore-main.css" />
    		<link type="text/css" rel="stylesheet" href="/static/lds/css/jquery-ui-1.8.2.all.css"/>
            <script type="text/javascript" src="/static/lds/js/jquery-1.4.4.min.js"></script>
            <script type="text/javascript" src="/static/lds/js/jquery-ui-1.8.2.all.min.js"></script>
            <script type="text/javascript" src="/static/lds/js/jquery.idTabs.min.js"></script>
            <script type="text/javascript" src="/static/lds/js/jquery.validate.min.js"></script>
            <script type="text/javascript">{$cfg:BLANK-SEARCH-STUB-JS}</script>
            <script type="text/javascript" src="/static/lds/js/natlibcat3.js"></script>
        </head>
        <body>
        <div id="container">
            <a id="skip" href="#skip_menu">skip navigation</a>
            <div id="branding">
                <h2>Library of Congress</h2>
                <h3>Linked Data Services</h3>
            </div>
              <div id="topnav">
                <ul id="menu">
                  <li id="logo_lc"><a title="The Library of Congress" href="http://www.loc.gov"></a></li>
                  <li id="global_nav"><a href="http://www.loc.gov/rr/askalib/"><img src="/static/lds/images/ask.gif" alt="Ask a Librarian" width="127" height="50" /></a><a href="http://www.loc.gov/library/libarch-digital.html"><img src="/static/lds/images/digitalcoll.gif" alt="Digital collections" width="155" height="50" /></a><a href="http://catalog.loc.gov/"><img src="/static/lds/images/catalog.gif" alt="Library Catalog" width="151" height="50" /></a></li>
                  <li id="searchmenu"><form class="metasearch" action="http://www.loc.gov/fedsearch/metasearch/" method="get"><label><a href="http://www.loc.gov/search/more_search.html">Options</a></label><br /><input type="text" name="cclquery" maxlength="200" /><input class="button" id="search_button" name="search_button" type="submit" value="GO" /></form></li>
                </ul>
              </div>
         			<div id="crumb_nav">
        				<div id="crumb">
        					<a href="http://www.loc.gov/">Library of Congress</a>
        	                   <span> &gt; </span>BIBFRAME Database
                       </div>
         			</div>
        
        <div id="content">
        		  	
        <div id="left_nav">
        <div id="left_nav_top">
        	<a href="/lds/"><img src="/static/lds/images/left-img-head-new.gif" alt="Linked Data Services" width="218" height="50" /></a>
			
        </div>
		<a href="/lds/"><img src="/static/lds/images/bf-left-image.jpg" alt="BIBFRAME Database" width="218" height="50" /></a>
        <div id="left_nav_mid">
        	<ul>
              <li><a href="/lds/">Home</a></li>
              <li><a href="/static/lds/html/help.html">Searching Tips</a></li>
              <!-- <li><a href="/static/lds/html/news.html">News</a></li> -->
            </ul>
               <!-- <h2>More Resources</h2>
                <ul id="res_links">
                    <li><a href="http://catalog.loc.gov/">LC Online Catalogs</a></li>
                    <li><a href="http://authorities.loc.gov/">LC Authorities</a></li>
                    <li><a href="http://www.loc.gov/library/libarch-digital.html">Digital Collections</a></li>
                    <li><a href="http://findingaids.loc.gov/">Finding Aids</a></li>
                    <li><a href="http://www.loc.gov/rr/program/bib/bibhome.html">Bibliographies &amp; Guides</a></li>
                </ul>-->
        </div>
        <!-- end left_nav_mid -->
        </div>
        <!-- end left_nav -->
        
        <div id="page_head">
        	<span style="width: 100%;"><a id="skip_menu"></a></span>
        	<h1>BIBFRAME Database <br /><span>Library of Congress Metadata</span></h1>
        </div> 
        
        <div id="main_menu">
        <div id="form">
		<!-- <h4><span style="color:brown">Text searching:</span></h4> -->
				<table ><tr><td><h4><span style="color:brown">Text searching:</span></h4></td>
		<td style="background-color:lightgray;width:16%;margin-right:5px;">Recently edited: <br/>
					<a href="/resources/works/feed/11">works</a> or <a href="/resources/instances/feed/21">instances</a>
		</td></tr>
		
		</table>
        <div id="search_box">
                 <form method="get" action="/lds/search.xqy" accept-charset="UTF-8" id="indexForm">                 	
                 	<div class="search_form">
                        <label class="nodisplay" for="quick-search-box">Keyword Search</label>
                        <input tabindex="1" id="quick-search-box" name="q" type="text" class="search" value="{$starting-text}" size="50" maxlength="300"/>
                        <button tabindex="7" id="indexSubmit">Search</button>
						<input value="score-desc" type="hidden" alt="sort" name="sort" />
						<!-- <input type="hidden" value="bfview" id="behavior" name="behavior"/> -->
                    </div>
                    <div id="quick-search-options">				
                      {
                            if ($qname eq 'keyword') then
                                <input tabindex="2" type="radio" value="keyword" checked="checked" name="qname" class="searchOptionRadioControl" id="all" />
                            else
                                <input tabindex="2" type="radio" value="keyword" name="qname" class="searchOptionRadioControl" id="all" />
                        }
                        <label for="all">Everything</label>
                       {
                            if ($qname eq 'idx:titleLexicon') then
                                <input tabindex="3" type="radio" value="idx:titleLexicon" checked="checked" name="qname" class="searchOptionRadioControl" id="title" />
                            else
                                <input tabindex="3" type="radio" value="idx:titleLexicon" name="qname" class="searchOptionRadioControl" id="title" />                                
                        }
                        <label for="title">Title</label>
                        {
                            if ($qname eq 'idx:mainCreator') then
                                <input tabindex="4" type="radio" value="idx:mainCreator" checked="checked" name="qname" class="searchOptionRadioControl" id="author" />
                            else
                                <input tabindex="4" type="radio" value="idx:mainCreator" name="qname" class="searchOptionRadioControl" id="author" />
                        }
                        <label for="author">Author/Creator</label>
                        {
                            if ($qname eq 'idx:subjectLexicon') then
                                <input tabindex="5" type="radio" value="idx:subjectLexicon" checked="checked" name="qname" class="searchOptionRadioControl" id="subject" />
                            else
                                <input tabindex="5" type="radio" value="idx:subjectLexicon" name="qname" class="searchOptionRadioControl" id="subject" />
                        }
                        <label for="subject">Subject</label>
						 {
                            if ($qname eq 'idx:lccn') then
                                <input tabindex="5" type="radio" value="idx:lccn" checked="checked" name="qname" class="searchOptionRadioControl" id="lccn" />
                            else
                                <input tabindex="5" type="radio" value="idx:lccn" name="qname" class="searchOptionRadioControl" id="lccn" />
                        }
                        <label for="lccn">LCCN</label>						
						{
                            if ($qname eq 'idx:issn') then
                                <input tabindex="5" type="radio" value="idx:issn" checked="checked" name="qname" class="searchOptionRadioControl" id="issn" />
                            else
                                <input tabindex="5" type="radio" value="idx:issn" name="qname" class="searchOptionRadioControl" id="issn" />
                        }
                        <label for="issn">ISSN</label>			
						<br/>
						{
                            if ($qname eq 'bflc:catalogerId') then
                                <input tabindex="5" type="radio" value="bflc:catalogerId" checked="checked" name="qname" class="searchOptionRadioControl" id="catid" />
                            else
                                <input tabindex="5" type="radio" value="bflc:catalogerId" name="qname" class="searchOptionRadioControl" id="catid" />
                        }
                        <label for="catid"><small>Cataloger </small></label>						
						
                    </div>
					<hr />
					<table><tr><td style="width:40%">
					<h3>Filter on:</h3>
					<div id="quick-search-options2">				
					 {
                            if ($filter eq 'all') then
                                <input tabindex="5" type="radio" value="all" checked="checked" name="filter" class="searchOptionRadioControl" id="all" />
                            else
                                <input tabindex="5" type="radio" value="all" name="filter" class="searchOptionRadioControl" id="all" />      
                        	}<label for="all">Everything</label>	
                        {
                            if ($filter eq 'works') then
                                <input tabindex="2" type="radio" value="works" checked="checked" name="filter" class="searchOptionRadioControl" id="works" />
                            else
                                <input tabindex="2" type="radio" value="works" name="filter" class="searchOptionRadioControl" id="works" />
                        }
                        <label for="works">Works</label>
                       {
                            if ($filter eq 'instances') then
                                <input tabindex="3" type="radio" value="instances" checked="checked" name="filter" class="searchOptionRadioControl" id="instances" />
                            else
                                <input tabindex="3" type="radio" value="instances" name="filter" class="searchOptionRadioControl" id="instances" />                                
                        }
                        <label for="instances">Instances</label>
                        {
                            if ($qname eq 'items') then
                                <input tabindex="4" type="radio" value="items" checked="checked" name="filter" class="searchOptionRadioControl" id="items" />
                            else
                                <input tabindex="4" type="radio" value="items" name="filter" class="searchOptionRadioControl" id="items" />
                        }
                        <label for="items">Items</label>
                       				
                    </div>
					</td>
					<td style="width:12%"></td><td style="width:20%">

<h3>Exact match Toggle:</h3>
					<div id="quick-search-options0">				
					 {
                            if ($precision eq 'exact') then
                                <input tabindex="5" type="radio" value="exact" checked="checked" name="precision" class="searchOptionRadioControl" id="precision" />
                            else
                                <input tabindex="5" type="radio" value="exact" name="precision" class="searchOptionRadioControl" id="precision" />                        
                        	}<label for="exact">Exact Match</label>	
                         {
                            if ($precision eq 'anymatch') then
                                <input tabindex="5" type="radio" value="anymatch" checked="checked" name="precision" class="searchOptionRadioControl" id="precision" />
                            else
                                <input tabindex="5" type="radio" value="anymatch" name="precision" class="searchOptionRadioControl" id="precision" />                        
                        	}<label for="anymatch">Any Match</label>	
                        
                       				
                    </div>
</td></tr></table>
					<div>
								<table>
								    <!-- <tr colspan="2">
								        <td>
								            <h4>Category:</h4>
								        </td>
								    </tr> -->
								    <tr>
								        <td>
								            <h5>Instance or Work Categories:</h5>
								        </td>
								        <td/>
								    </tr>
								    <tr>
								        <td> { if ($category eq 'all') then <input tabindex="1" type="radio" value="all"
								                checked="checked" name="category" class="searchOptionRadioControl" id="all3"/> 
								            else
								                <input tabindex="1" type="radio" value="all" name="category"
								                class="searchOptionRadioControl" id="all3"/> }<label for="all3"
								            >Everything</label></td>
								        <td> { if ($category eq 'edited') then <input tabindex="2" type="radio" value="edited"
								                checked="checked" name="category" class="searchOptionRadioControl" id="edited"/>
								            else <input tabindex="2" type="radio" value="edited" name="category"
								                class="searchOptionRadioControl" id="edited"/> } <label for="edited">From BF
								                Editor</label>
								            <br/>
								        </td>
								    </tr>

								    <tr>
								        <td> { if ($category eq 'notMerged') then <input tabindex="3" type="radio" value="notMerged"
								                checked="checked" name="category" class="searchOptionRadioControl" id="notMerged"/>
								            else <input tabindex="3" type="radio" value="notMerged" name="category"
								                class="searchOptionRadioControl" id="notMerged"/> } <label for="notMerged">No Merge
								                activity</label><br/></td>
								        <td> { if ($category eq 'rda') then <input tabindex="4" type="radio" value="rda"
								                checked="checked" name="category" class="searchOptionRadioControl" id="rda"/> else
								                <input tabindex="4" type="radio" value="rda" name="category"
								                class="searchOptionRadioControl" id="rda"/> } <label for="rda">RDA Cataloging Rules </label>
								            <br/>
								        </td>
								    </tr>
								    <tr>
								       
								        <td> { if ($category eq 'ecip') then <input tabindex="4" type="radio" value="ecip"
								                checked="checked" name="category" class="searchOptionRadioControl" id="ecip"/> else
								                <input tabindex="4" type="radio" value="ecip" name="category"
								                class="searchOptionRadioControl" id="ecip"/> } <label for="ecip">E-CIP Records </label>
								            <br/>
								        </td>
										<td> { if ($category eq 'fibc') then <input tabindex="4" type="radio" value="fibc"
								                checked="checked" name="category" class="searchOptionRadioControl" id="fibc"/> else
								                <input tabindex="4" type="radio" value="fibc" name="category"
								                class="searchOptionRadioControl" id="fibc"/> } <label for="fibc">Foreign IBC </label>
								            <br/>
								        </td>
								    </tr>
									
								    <tr>
								        <td> { if ($category eq 'ibc') then <input tabindex="4" type="radio" value="ibc"
								                checked="checked" name="category" class="searchOptionRadioControl" id="ibc"/> else
								                <input tabindex="4" type="radio" value="ibc" name="category"
								                class="searchOptionRadioControl" id="ibc"/> } <label for="ibc">IBC Records </label>
								            <br/>
								        </td>
								        <td> { if ($category eq 'batch') then <input tabindex="4" type="radio" value="batch"
								                checked="checked" name="category" class="searchOptionRadioControl" id="batch"/> else
								                <input tabindex="4" type="radio" value="batch" name="category"
								                class="searchOptionRadioControl" id="batch"/> } <label for="ibc">Any 985 batch code </label>
								            <br/>
								        </td>
								    </tr>
									<tr><td> { if ($category eq 'nondistributed') then <input tabindex="4" type="radio" value="nondistributed"
								                checked="checked" name="category" class="searchOptionRadioControl" id="nondistributed"/> else
								                <input tabindex="4" type="radio" value="nondistributed" name="category"
								                class="searchOptionRadioControl" id="nondistributed"/> } <label for="nondistributed">Non Distributed</label>
								            <br/>
								        </td><td> </td>
										</tr> 
								    <tr>
								        <td colspan="2">
								            <h5>Work Categories:</h5>
								        </td>
								    </tr>
								    <tr>
								        <td> { if ($category eq 'mergedWorks') then <input tabindex="4" type="radio"
								                value="mergedWorks" checked="checked" name="category"
								                class="searchOptionRadioControl" id="mergedWorks"/> else <input tabindex="4"
								                type="radio" value="mergedWorks" name="category" class="searchOptionRadioControl"
								                id="mergedWorks"/> } <label for="mergedWorks">Works that have Bibs merged on
								                them</label><br/>
								        </td>
								        <td>{ if ($category eq 'authNameTitle') then <input tabindex="5" type="radio"
								                value="authNameTitle" checked="checked" name="category"
								                class="searchOptionRadioControl" id="authNameTitle"/> else <input tabindex="5"
								                type="radio" value="authNameTitle" name="category" class="searchOptionRadioControl"
								                id="authNameTitle"/> } <label for="authNameTitle">NameTitle work</label>
								            <br/>
								        </td>
								    </tr>
								    <tr>
								        <td>{ if ($category eq 'authTitle') then <input tabindex="6" type="radio" value="authTitle"
								                checked="checked" name="category" class="searchOptionRadioControl" id="authTitle"/>
								            else <input tabindex="6" type="radio" value="authTitle" name="category"
								                class="searchOptionRadioControl" id="authTitle"/> } <label for="authTitle">Title
								                Work</label>
								           
								        </td>
								        <td> { if ($category eq 'authWork') then <input tabindex="7" type="radio" value="authWork"
								                checked="checked" name="category" class="searchOptionRadioControl" id="authWork"/>
								            else <input tabindex="7" type="radio" value="authWork" name="category"
								                class="searchOptionRadioControl" id="authWork"/> } <label for="authWork">Work from
								                Title or NameTitle Authority</label>
								            
								        </td>
								    </tr>
								    <tr>
								        <td>{ if ($category eq 'expression') then <input tabindex="8" type="radio"
								                value="expression" checked="checked" name="category"
								                class="searchOptionRadioControl" id="expression"/> else <input tabindex="8"
								                type="radio" value="expression" name="category" class="searchOptionRadioControl"
								                id="expression"/> } <label for="expression">Expression </label>
								            
								        </td>
								        <td> { if ($category eq 'stubworks') then <input tabindex="8" type="radio" value="stubworks"
								                checked="checked" name="category" class="searchOptionRadioControl" id="stubworks"/>
								            else <input tabindex="8" type="radio" value="stubworks" name="category"
								                class="searchOptionRadioControl" id="stubworks"/> } <label for="stubworks">Stub
								                Related Works </label>
								           
								        </td>
								    </tr>
										 <tr>
								         <td> { if ($category eq 'nonstubs') then <input tabindex="9" type="radio" value="nonstubs"
								                checked="checked" name="category" class="searchOptionRadioControl" id="nonstubs"/>
								            else <input tabindex="9" type="radio" value="nonstubs" name="category"
								                class="searchOptionRadioControl" id="nonstubs"/> } 
												<label for="nonstubs">Non-Stub Works </label>
								           
								        </td>
								        <td> { if ($category eq 'hasLinks') then <input tabindex="9" type="radio" value="hasLinks"
								                checked="checked" name="category" class="searchOptionRadioControl" id="hasLinks"/>
								            else <input tabindex="9" type="radio" value="hasLinks" name="category"
								                class="searchOptionRadioControl" id="hasLinks"/> } 
												<label for="hasLinks">Has Links to other objects </label>
								           
								        </td>
								    </tr>
								    <tr>
								        <td colspan="2">
								            <h5>Instance categories:</h5>
								        </td>
								    </tr>
								    <tr>
								        <td>{ if ($category eq 'mergedInstances') then <input tabindex="9" type="radio"
								                value="mergedInstances" checked="checked" name="category"
								                class="searchOptionRadioControl" id="mergedInstances"/> else <input tabindex="9"
								                type="radio" value="mergedInstances" name="category"
								                class="searchOptionRadioControl" id="mergedInstances"/> } <label
								                for="mergedInstances">Instances merged onto any Work</label>
								            <br/>
								        </td>
								        <td> { if ($category eq 'authMerge') then <input tabindex="9" type="radio" value="authMerge"
								                checked="checked" name="category" class="searchOptionRadioControl" id="authMerge"/>
								            else <input tabindex="9" type="radio" value="authMerge" name="category"
								                class="searchOptionRadioControl" id="authMerge"/> }<label for="authMerge">Instances
								                merged onto Authority Work</label><br/>
								        </td>
								    </tr>
								    <tr>
								        <td> { if ($category eq 'bibMerge') then <input tabindex="10" type="radio" value="bibMerge"
								                checked="checked" name="category" class="searchOptionRadioControl" id="bibMerge"/>
								            else <input tabindex="10" type="radio" value="bibMerge" name="category"
								                class="searchOptionRadioControl" id="bibMerge"/> } <label for="bibMerge">Instances merged
								                onto Bib Work</label>
								            <br/>
								        </td>
								        <td> </td>
								    </tr>
								</table>
						</div>
						<hr/>
				  
            </form>
        </div>

		
        </div>
        <!-- end search_box -->
		
        <!-- end form -->
		
  
        <div id="browse_box"  style="	background: #e6f2ff;"><br/>
		<h4><span style="color:brown">Left-anchor browsing:</span></h4>
				<form method="get" action="/lds/browse.xqy" accept-charset="UTF-8" id="browseForm" >
				<div class="browse_form">
					<label class="nodisplay" for="browse-search-box">Browse</label>
					<input tabindex="1" id="browse-search-box" name="bq" type="text" class="browse" value="" size="25" maxlength="300"/>
					<button tabindex="5" id="browseSubmit">Browse</button>
					<input type="hidden" value="ascending" id="sort" name="browse-order"/>
				</div>
				<div id="browse-search-options">		
				<table>
				<tr>
								        <td>{
	                if ($browse eq 'author') then
	                    <input tabindex="1" type="radio" value="author" checked="checked" name="browse" class="searchOptionRadioControl" id="b_name" />
	                else
	                    <input tabindex="1" type="radio" value="author" name="browse" class="searchOptionRadioControl" id="b_name" />
	            }
				<label for="b_name">Name</label><span style="margin-left:55px;"> </span>	
								        </td>
								        <td> {
	                if ($browse eq 'subject') then
	                    <input tabindex="2" type="radio" value="subject" checked="checked" name="browse" class="searchOptionRadioControl" id="b_subject" />
	                else
	                    <input tabindex="2" type="radio" value="subject" name="browse" class="searchOptionRadioControl" id="b_subject" />
	             }
				<label for="b_subject">Subject</label><span style="margin-left:20px;"> </span>
								        </td>
								    </tr>
									<tr>
								        <td>{
	                if ($browse eq 'class') then
	                    <input tabindex="3" type="radio" value="class" checked="checked" name="browse" class="searchOptionRadioControl" id="b_class" />
	                else
	                    <input tabindex="3" type="radio" value="class" name="browse" class="searchOptionRadioControl" id="b_class" />
	             }
				 <label for="b_class">LC Call Number</label>
								        </td>
								        <td> 	{
	                if ($browse eq 'date') then
	                    <input tabindex="4" type="radio" value="date" checked="checked" name="browse" class="searchOptionRadioControl" id="b_date" />
	                else
	                    <input tabindex="4" type="radio" value="date" name="browse" class="searchOptionRadioControl" id="b_date" />
	             }<label for="b_date">Date Modified</label>
								        </td>
								    </tr>
				
				 <tr>
								        <td>
				
				 			
				  {
	                if ($browse eq 'lccn') then
	                    <input tabindex="5" type="radio" value="lccn" checked="checked" name="browse" class="searchOptionRadioControl" id="b_lccn" />
	                else
	                    <input tabindex="5" type="radio" value="lccn" name="browse" class="searchOptionRadioControl" id="b_lccn" />
	             }
				 <label for="b_lccn">LCCN</label><span style="margin-left:35px;"> </span>	</td>
				 <td>
				  {
	                if ($browse eq 'loaddate') then
	                    <input tabindex="6" type="radio" value="loaddate" checked="checked" name="browse" class="searchOptionRadioControl" id="b_loaddate" />
	                else
	                    <input tabindex="7" type="radio" value="loaddateitle" name="browse" class="searchOptionRadioControl" id="b_loaddate" />
	             }
				 <label for="b_loaddate">Date <em>Loaded</em></label> (<a href="browse.xqy?bq={$today}&amp;browse-order=ascending&amp;browse=loaddate">today</a>)
				 </td>
				 </tr>
				 <tr><td>
  				{
	                if ($browse eq 'imprint') then
	                    <input tabindex="6" type="radio" value="imprint" checked="checked" name="browse" class="searchOptionRadioControl" id="b_imprint" />
	                else
	                    <input tabindex="7" type="radio" value="imprint" name="browse" class="searchOptionRadioControl" id="b_imprint" />
	             }
				 <label for="b_imprint">Imprint</label>
				 </td>
				  <td>
				  {
	                if ($browse eq 'nameTitle') then
	                    <input tabindex="6" type="radio" value="nameTitle" checked="checked" name="browse" class="searchOptionRadioControl" id="b_nameTitle" />
	                else
	                    <input tabindex="7" type="radio" value="nameTitle" name="browse" class="searchOptionRadioControl" id="b_nameTitle" />
	             }
				 <label for="b_nameTitle">Name/Title</label>
				 </td>
				 </tr>
				 <tr><td>
  				{
	                if ($browse eq 'pubPlace') then
	                    <input tabindex="6" type="radio" value="pubPlace" checked="checked" name="browse" class="searchOptionRadioControl" id="b_pubPlace" />
	                else
	                    <input tabindex="7" type="radio" value="pubPlace" name="browse" class="searchOptionRadioControl" id="b_pubPlace" />
	             }
				 <label for="b_pubPlace">Provision Place</label>
				 </td>
				 <td></td>
				 </tr>
				 		
					
</table>
			</div>
		<!-- end ID:browse-search-options -->		
				<h3>Filter on:</h3>
					<div id="quick-search-options2">				
					 {
                            if ($qname eq 'all') then
                                <input tabindex="5" type="radio" value="all" checked="checked" name="filter" class="searchOptionRadioControl" id="all2" />
                            else
                                <input tabindex="5" type="radio" value="all" name="filter" class="searchOptionRadioControl" id="all" />                        
                        	}<label for="all">Everything</label>		
                        {
                            if ($filter eq 'works') then
                                <input tabindex="2" type="radio" value="works" checked="checked" name="filter" class="searchOptionRadioControl" id="works2" />
                            else
                                <input tabindex="2" type="radio" value="works" name="filter" class="searchOptionRadioControl" id="works2" />
                        }
                        <label for="works">Works</label>
                       {
                            if ($filter eq 'instances') then
                                <input tabindex="3" type="radio" value="instances" checked="checked" name="filter" class="searchOptionRadioControl" id="instances2" />
                            else
                                <input tabindex="3" type="radio" value="instances" name="filter" class="searchOptionRadioControl" id="instances2" />                                
                        }
                        <label for="instances">Instances</label>
                        {
                            if ($qname eq 'items') then
                                <input tabindex="4" type="radio" value="items" checked="checked" name="filter" class="searchOptionRadioControl" id="items2" />
                            else
                                <input tabindex="4" type="radio" value="items" name="filter" class="searchOptionRadioControl" id="items2" />
                        }
                        <label for="items">Items</label>
                       				
                    </div>
		</form>
	</div>
	</div>
	
			
        <!-- end main_menu -->
	      <div id="main_body">
            <p> Library of Congress Linked Data Services, an online platform for linked data versions of Library's bibliographic and 
			authority data.</p>            
						
            <p> Please <a href="/lds/feedback.xqy">contact us</a> to provide your comments.</p>
        <div style="background: #fff;"><p> </p><p> </p><hr/></div>
	<!-- end CLASS: browse_box -->
		</div>
        <!-- end main_body -->
		
        </div>
        <!-- end content -->
        
            <div id="footer">
                <div class="f_container">
                    <div class="f_inner_top">
                        <h3>Stay Connected with the Library <span><a href="http://www.loc.gov/homepage/connect.html">All ways to connect</a></span></h3>
                        <!-- end class:f_inner_top -->
                    </div>
                    <div class="f_inner_mid">
                        <div class="find_us">
                            <h4>Find us on</h4><a href="http://www.facebook.com/libraryofcongress"><img width="16" height="16" alt="Facebook" src="http://www.loc.gov/include/images/facebook.gif"/></a><a href="http://twitter.com/librarycongress"><img width="16" height="16" alt="Twitter" src="http://www.loc.gov/include/images/twitter.gif"/></a><a href="http://www.youtube.com/libraryofcongress"><img width="16" height="16" alt="YouTube" src="http://www.loc.gov/include/images/youtube.gif"/></a><a href="http://www.flickr.com/photos/library_of_congress/"><img width="16" height="16" alt="Flickr" src="http://www.loc.gov/include/images/flickr.gif"/></a></div><div class="subscribe"><h4>Subscribe &amp; Comment</h4><span><a href="http://www.loc.gov/rss/">RSS &amp; E-Mail</a></span><span><a href="http://blogs.loc.gov/loc/">Blogs</a></span></div><div class="download"><h4>Download &amp; Play</h4><span><a href="http://www.loc.gov/podcasts/">Podcasts</a></span><span><a href="http://www.loc.gov/webcasts/">Webcasts</a></span><span class="external"><a href="http://deimos3.apple.com/WebObjects/Core.woa/Browse/loc.gov">iTunes U</a></span>
                        </div>
                        <!-- end class:f_inner_mid -->
                    </div>
                    <div class="f_inner_bot">
                        <div class="sitelinks">
                            <a href="http://www.loc.gov/about/">About</a>
                            &nbsp;|&nbsp;
                            <a href="http://www.loc.gov/pressroom/">Press</a>
                            &nbsp;|&nbsp;
                            <a href="http://www.loc.gov/about/sitemap/">Site Map</a>
                            &nbsp;|&nbsp;
                            <a href="http://www.loc.gov/help/contact-general.html">Contact</a>
                            &nbsp;|&nbsp;
                            <a href="http://www.loc.gov/access/">Accessibility</a>
                            &nbsp;|&nbsp;
                            <a href="http://www.loc.gov/homepage/legal.html">Legal</a>
                            &nbsp;|&nbsp;
                            <a href="http://www.loc.gov/global/disclaim.html">External Link Disclaimer</a>
                            &nbsp;|&nbsp;
                            <a href="http://www.usa.gov/">USA.gov</a></div><div class="speech"><a href="http://www.loc.gov/access/web.html">Speech Enabled</a>
                        </div>
                    <!-- end class:f_inner_bot -->
                    </div>
                <!-- end class:f_container -->
                </div>
            <!-- end id:footer -->
            </div>        
        
        </div>
        <!-- end container -->        
        </body>
    </html>
return
        (
            xdmp:set-response-content-type("text/html; charset=utf-8"), 
            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
            xdmp:add-response-header("Expires", resp:expires($duration)),
            $doctype, 
            $html
        )(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)