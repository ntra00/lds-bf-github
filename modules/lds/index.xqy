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
declare variable $starting-text := $query;
declare variable $browse-query as xs:string? := xdmp:get-request-field("bq", ());
declare variable $browse as xs:string? := xdmp:get-request-field("browse", "");
let $hostname:=  $cfg:DISPLAY-SUBDOMAIN
let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $duration := $cfg:HTTP_EXPIRES_CACHE

let $html :=
    <html xmlns="http://www.w3.org/1999/xhtml">
    	<head>
    		<title>{$cfg:META-TITLE}</title>
    		<meta http-equiv="Content-Language" content="en-us" />
    		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <meta name="robots" content="noindex"/>
    		<meta name="keywords" content="Linked Data Services  search library congress collections" />
    		<meta name="description" content="Linked Data Services :  Library of Congress Bibliographic and authority data in linked data formats." />
    		<link rel="stylesheet" media="print" type="text/css" href="/static/lds/css/datastore-print.css" />
    		<link rel="stylesheet" media="screen, projection" type="text/css" href="/static/lds/css/datastore-main.css" />
    		<link type="text/css" rel="stylesheet" href="/static/lds/ls -acss/jquery-ui-1.8.2.all.css"/>
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
        	                   <span> &gt; </span>Linked Data Services
                       </div>
         			</div>
        
        <div id="content">
        		  	
        <div id="left_nav">
        <div id="left_nav_top">
        	<a href="/lds/"><img src="/static/lds/images/left-img-head-new.gif" alt="Linked Data Services" width="218" height="50" /></a>
        </div>
        <div id="left_nav_mid">
        	<ul>
              <li><a href="/lds/">Home</a></li>
              <li><a href="/static/lds/html/help.html">Searching Tips</a></li>
              <!-- <li><a href="/static/lds/html/news.html">News</a></li> -->
            </ul>
            <h2>More Resources</h2>
                <ul id="res_links">
                    <li><a href="http://catalog.loc.gov/">LC Online Catalogs</a></li>
                    <li><a href="http://authorities.loc.gov/">LC Authorities</a></li>
                    <li><a href="http://www.loc.gov/library/libarch-digital.html">Digital Collections</a></li>
                    <li><a href="http://findingaids.loc.gov/">Finding Aids</a></li>
                    <li><a href="http://www.loc.gov/rr/program/bib/bibhome.html">Bibliographies &amp; Guides</a></li>
                </ul>
        </div>
        <!-- end left_nav_mid -->
        </div>
        <!-- end left_nav -->
        
        <div id="page_head">
        	<span style="width: 100%;"><a id="skip_menu"></a></span>
        	<h1>Linked Data Services <br /><span>Search Library of Congress Collections</span></h1>
        </div> 
        
        <div id="main_menu">
        <div id="form">
        <div id="search_box">
                 <form method="get" action="/lds/search.xqy" accept-charset="UTF-8" id="indexForm">                 	
                 	<div class="search_form">
                        <label class="nodisplay" for="quick-search-box">Keyword Search</label>
                        <input tabindex="1" id="quick-search-box" name="q" type="text" class="search" value="{$starting-text}" size="50" maxlength="300"/>
                        <button tabindex="7" id="indexSubmit">Search</button>
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
                    </div>

                    <!-- end split_button --> 
        			<div id="limits-container">
        			     {
                             if ($digitized eq 'Online') then
                                 <input tabindex="6" name="{$digitizedfacet}" type="checkbox" checked="checked" id="limits" value="Online" /> 
                             else
                                 <input tabindex="6" name="{$digitizedfacet}" type="checkbox" id="limits" value="Online" /> 
                         }
                         <label for="limits">Limit search to materials available online</label>
            	  </div>
            </form>
        </div>
		{if (not(matches($hostname,'marklogic3'))) then
				()
		else
			<div id="browse_box">
				<form method="get" action="/lds/browse.xqy" accept-charset="UTF-8" id="browseForm">
				<div class="browse_form">
					<label class="nodisplay" for="browse-search-box">Browse</label>
					<input tabindex="1" id="browse-search-box" name="bq" type="text" class="browse" value="" size="25" maxlength="300"/>
					<button tabindex="5" id="browseSubmit">Browse</button>
					<input type="hidden" value="ascending" id="sort" name="browse-order"/>
				</div>
				<div id="browse-search-options">			
				 {
	                if ($browse eq 'author') then
	                    <input tabindex="2" type="radio" value="author" checked="checked" name="browse" class="searchOptionRadioControl" id="b_name" />
	                else
	                    <input tabindex="2" type="radio" value="author" name="browse" class="searchOptionRadioControl" id="b_name" />
	            }
				<label for="b_name">Name</label>			
				 {
	                if ($browse eq 'subject') then
	                    <input tabindex="2" type="radio" value="subject" checked="checked" name="browse" class="searchOptionRadioControl" id="b_subject" />
	                else
	                    <input tabindex="2" type="radio" value="subject" name="browse" class="searchOptionRadioControl" id="b_subject" />
	             }
				<label for="b_subject">Subject</label>
				{
	                if ($browse eq 'class') then
	                    <input tabindex="2" type="radio" value="class" checked="checked" name="browse" class="searchOptionRadioControl" id="b_class" />
	                else
	                    <input tabindex="2" type="radio" value="class" name="browse" class="searchOptionRadioControl" id="b_class" />
	             }
				 <label for="b_class">LC Call Number</label>
			</div>
		<!-- end ID:browse-search-options -->		
	</form>
</div>}
<!-- end CLASS: browse_box -->
        <!-- end form -->
        </div>
        <!-- end search_box -->
        </div>
	
        <!-- end main_menu -->
        <div id="main_body">
            <p> Library of Congress Linked Data Services, an online platform for linked data versions of Library's bibliographic and 
			authority data.</p>            
						
            <p> Please <a href="/lds/feedback.xqy">contact us</a> to provide your comments.</p>
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
        )