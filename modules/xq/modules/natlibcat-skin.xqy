xquery version "1.0-ml";

module namespace ssk = "info:lc/xq-modules/search-skin";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare  namespace l = "local";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace search = "http://marklogic.com/appservices/search";

(: might  need to add thisfor zotero and metasearch:

<link title="Dublin Core Metadata Schema" rel="schema.DC" href="http://purl.org/DC/elements/1.1/" />
:)


declare function ssk:header($title as xs:string, $crumbs as element()*, $msie as xs:boolean, $atom as xs:string?, $seo as element(meta)* , $uri as xs:string, $objectType as xs:string) as element(header) {
(: 	Header based on objecttype: 
	Seadragon is for pageturner; any collection of images.
   	Player is for audio, video, recordedEvent, tabs are for all digital. 
   	We should have tabs for bibs as well, later
:)
(:let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)	:)

let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
let $site-title:=  $cfg:MY-SITE/cfg:label/string()	
return
        <header xmlns="http://www.w3.org/1999/xhtml">
        	<head>
                {ssk:default-header($title,$uri, $site-title,$url-prefix)/*}								
				{if (matches($objectType,("recordedEvent","simpleAudio","videoRecording") )) then  
					ssk:player-script()/*
			     else if (matches($objectType,'timeline')) then
			         ssk:timeline-script()/*
				else ()
				}
				{ if (not(matches($objectType,"error"))) then				
					(if (not(matches($objectType,("recordedEvent","modsBibRecord","bibRecord","workRecord","instanceRecord","itemRecord","results") )) )  then				
							ssk:seadragon-script($uri)/*				                
						else (),
					if (not(matches($objectType,("results","timeline") )) ) then  				 
						ssk:tab-script()/*
					else ()
					)
				else ()
		
				}
				{ssk:feed-link($atom,$site-title)}
				{$seo//*:meta}
				{	if ( contains($cfg:DISPLAY-SUBDOMAIN,"mlvlp04") and xdmp:get-request-header('X-LOC-Environment')!='Staging')
					(:if (contains($url-prefix,"tohap")) :)
				 then 
					()
					else 
					ssk:sharetool-script()/*	
				}
            </head>            
           {ssk:topnav-div($crumbs)}
        </header>                       
};
(:private:)
declare  function ssk:default-header($title as xs:string, $uri as xs:string, $site-title as xs:string, $url-prefix as xs:string) as element(header) {
(: This is the default starting header for  bibs; digital objects add others.
   Includes baseline css and js, jquery, and unapi server link 
   We need to determine if jquery 1.5 is okay and then move it into /static
:)

	 <header xmlns="http://www.w3.org/1999/xhtml">
 		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta http-equiv="Content-Language" content="en-us" />
        <title>{concat($title, ", ", $site-title, ", Library of Congress)")}</title>               
        <meta name="Keywords" content="search results national library collections library congress" />
        <meta name="Description" content="Search Results for . {$site-title}, Library of Congress" />                
        <link rel="stylesheet" media="screen, projection" type="text/css" href="/static/natlibcat/css/datastore-new.css" />
		<script type="text/javascript" src="http://cdn.loc.gov/js/lib/jquery-1.5.1.min.js"></script>		
        <link type="text/css" rel="stylesheet" href="/static/natlibcat/css/jquery-ui-1.8.2.all.css"/>				
		{ssk:print-script($uri)}
        <link type="text/css" rel="stylesheet" href="/static/natlibcat/css/mlstyle.css"/>
        <link type="text/css" rel="stylesheet" href="/static/natlibcat/css/splash.css"/>             
        
        <script type="text/javascript" src="/static/natlibcat/js/jquery-ui-1.8.2.all.min.js"></script>		
        <script type="text/javascript" src="/static/natlibcat/js/jquery.qtip-1.0.0-rc3.min.js"></script>
        <script type="text/javascript" src="/static/natlibcat/js/jquery.validate.min.js"></script>                
        <script type="text/javascript">{$cfg:BLANK-SEARCH-STUB-JS}</script>
        <script type="text/javascript" src="/static/natlibcat/js/natlibcat3.js"></script>
		<link rel="unapi-server" type="application/xml" title="unAPI" href="{$url-prefix}unapi.xqy"/>
		  <!-- CSS -->
    <link type="text/css" media="screen" rel="stylesheet" href="/xq/id-main/static/css/2012/styles.css"/>
    <link type="text/css" media="print" rel="stylesheet" href="/xq/id-main/static/css/2012/loc_print_v2.css"/>
    <!--[if lte IE 7]><link type="text/css" media="screen" rel="stylesheet" href="/static/css/2012/loc_lte_ie6.css" /><![endif]-->
    <!-- End CSS -->
	 </header>
};

declare  function ssk:feedback-link($has-heading as xs:boolean ) as element()  {
(:  Placed above footer of bib records, in right nav of digital
	Called by m-doc, permalink, search 
	id="feedback" has a border and a title, "ds-feedback" is a link with a mailbox icon
:) 
(:let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING):)
	
	let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
		(:concat("/",$branding,"/"):)
	let $link:=
		(
			<a href="{$url-prefix}feedback.xqy" title="Select this link to send feedback on this page." 
				id="feedback-link">Send Us Your Feedback</a>,
        	let $refer as xs:string? := xdmp:get-request-header("Referer")
           	return
                if (contains($refer, "parts/feedback-mailer.xqy")) then
                    <span id="feedback-response">Thanks for sending your feedback!</span>
                else
                    ()       		
		)
	return  
		if ( $has-heading ) then
			<div id="feedback">
					<h3>Comments</h3>
					<ul class="std">
					  <li>{$link}</li>
					</ul>
			<!-- end feedback --></div>			
		else 
			<div id="ds-feedback">{$link}<!-- end feedback --></div>
           
};
declare private function ssk:tab-script() as element(header)? {
(: 	From the OSI page std design template for jquery tabs:
	http://www.loc.gov/staff/webproduction/design/standardUI/jquery-tabs.php
	Currently, only digital objects use tabs; we may be able to use jquery 1.4 or 1.5 
:)
	<header>
		<!-- <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js"></script> -->
		<script type="text/javascript"> 
		(function($) {{
			$(document).ready(function() {{
				//Default Action
				$(".tab_content").hide(); //Hide all content
				$("ul.tabnav li:first").addClass("active").show(); //Activate first tab
				$(".tab_content:first").show(); //Show first tab content
	
				//On Click Event
				$("ul.tabnav li").click(function() {{
					$("ul.tabnav li").removeClass("active"); //Remove any "active" class
					$(this).addClass("active"); //Add "active" class to selected tab
					$(".tab_content").hide(); //Hide all tab content
					var activeTab = $(this).find("a").attr("href"); //Find the rel attribute value to identify the active tab + content
					$(activeTab).fadeIn(); //Fade in the active content
					return false;
				}});
		
				$('a.tabLink').click(function(event) {{
				  var link = $(event.target);
					if ('' != $(link).attr('rel')) {{
						var tab = $(link).attr('rel');
						$('#' + tab).click();
					}} else {{
						var tab = $(link).attr('href');
						$(tab).click();
						return false;
					}}
				}});
			}});
		}})(jQuery);
		</script>
	</header>
};

declare private function ssk:print-script($uri as xs:string) as element(script) {
(:	Set up window print based on print.xqy
:)

(:let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)	:)
	let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
		(:concat("/",$branding,"/"):)
	let $marctags := 
        if (lp:get-param-single($lp:CUR-PARAMS, 'behavior')) then
            concat("&amp;behavior=",lp:get-param-single($lp:CUR-PARAMS, 'behavior') ) 
		else ""
(:<script type="text/javascript">window.print = function(){{window.open("http://{$cfg:DISPLAY-SUBDOMAIN}{$url-prefix}print.xqy?uri={$uri}{$marctags}");}}</script>:)
	return
		<script type="text/javascript">window.print = function(){{window.open("{$url-prefix}print.xqy?uri={$uri}{$marctags}");}}</script>
		
};

declare private function ssk:player-script() as element(header) {
(:	Based on  jukebox player 9/16/11
	Needs work moving the right things from cdn into static if we're going to use this after OSI looks.
:)
	<header xmlns="http://www.w3.org/1999/xhtml">	
		<script> 
            CDN_URL = 'http://cdn.loc.gov';
            MEDIA_URL = 'http://media.loc.gov';
		</script>
		<script type="text/javascript" src="http://cdn.loc.gov/loccdn.js"></script>		
		<!-- we have this one in static: jquery-ui-1.8.2.all.min should we upgrade in static? -->
		<!-- <script type="text/javascript" src="http://cdn.loc.gov/js/lib/jquery-ui-1.8.10.js"></script> -->
		<script type="text/javascript" src="http://cdn.loc.gov/js/lib/jquery.claypool-1.2.8-lite.js"></script>
		<script type="text/javascript" src="http://cdn.loc.gov/js/lib/jquery.livequery-1.1.1.min.js"></script>
		<script type="text/javascript" src="http://cdn.loc.gov/js/plugins/jquery.utils-1.0.js"></script>
		<script type="text/javascript" src="http://cdn.loc.gov/js/plugins/jquery.url-1.0.js"></script>
		<script type="text/javascript" src="http://cdn.loc.gov/js/lib/modernizr-1.5.min.js"></script>
		<script type="text/javascript" src="http://media.loc.gov/loader/lib/flowplayer-3.2.4.min.js"></script>
		<script type="text/javascript" src="/static/natlibcat/js/player.js"></script>
	</header>

};

declare private function ssk:sharetool-script() as element(header) {
(:	Currently not allowed in production.

:)
	if ( contains($cfg:DISPLAY-SUBDOMAIN,"mlvlp04") and xdmp:get-request-header('X-LOC-Environment')!='Staging')
 then		
		<header xmlns="http://www.w3.org/1999/xhtml">
			<link href="/share/sites/zawrE2Ra/share-min.css" rel="stylesheet" type="text/css" media="screen, all" />									
			<script type="text/javascript">
						var script = document.createElement('script');
						script.src = '/share/sites/zawrE2Ra/share-jquery-min.js';
						script.type = 'text/javascript';
						document.getElementsByTagName('head')[0].appendChild(script);
			</script>
		</header>	
	else <header/>

};
declare private function ssk:feed-link($atom as xs:string?,$site-title as xs:string?)  {
 
        if (not($atom) or $atom instance of empty-sequence()) then
            $atom
        else if ($atom instance of xs:string and matches($atom, "(search|atom).xqy")) then
            <link id="ds-atomfeed" rel="alternate" href="{$atom}" type="application/atom+xml" title="{$site-title} Search Results" />
        else
            ()
};


declare private function ssk:seadragon-script($uri  as xs:string) as element(header)? {
(:	For all viewers of one or more images.
 :)
	let $path:= utils:mets-files($uri,"json","all")		
	return 
		if (exists($path)) then		
		<header xmlns="http://www.w3.org/1999/xhtml">
			<script type="text/javascript" src="/static/natlibcat/js/seadragon-min.js"></script>
            <script type="text/javascript" src="/static/natlibcat/js/seadragon-display.js"></script>		
			<script type="text/javascript" src="/static/natlibcat/js/jquery.galleriffic.js"></script>
			<link type="text/css" rel="stylesheet" href="/static/natlibcat/css/galleriffic-2.css"/>             
            
			<script type="text/javascript">
				var viewer = null;
                var total = null;
                var currentidx = null;
                var volumeidx = null;
                var previdx = null;
                var nextidx = null;
                var pageControl = null;
                var captionControl = null;
				var pages = {$path};
				var browser = null;
				var currentwords = null;
			
           		Seadragon.Utils.addEvent(window, "load", init);
		     </script>
			</header>
	 else ()

};

(: Added for the test timeline page.  Much of this (except for the CSS, which should be moved to the proper file) could stay the same
even if the timeline code is merged into v-detail. :)
declare function ssk:timeline-script() as element(header)? {
    <header xmlns="http://www.w3.org/1999/xhtml">
        <!--<script type="text/javascript" src="http://static.simile.mit.edu/timeline/api-2.3.0/timeline-api.js?bundle=true"></script>-->
         <script>
              Timeline_ajax_url="/static/natlibcat/js/timeline_ajax/simile-ajax-api.js";
              Timeline_urlPrefix='/static/natlibcat/js/timeline_js/';       
              Timeline_parameters='bundle=true';
        </script>
        <script src="/static/natlibcat/js/timeline_js/timeline-api.js" type="text/javascript"></script>
        <script type="text/javascript" src="/static/natlibcat/js/timeline-display.js"></script>
        <style type="text/css">
            .timeline-band-3 .timeline-ether-bg {{
                background-color: #BBBBBB;
            }}
        </style>
    </header>
};

declare function ssk:topnav-div($crumbs as element()*) as element(body){
(:  Crumb bar; called for all headers: detail and results pages
:)
 	<body>
        <div id="ds-header">
            <div id="topnav">
                <div id="top_container">
                    <div id="left_header">
                        <ul id="menu">
                            <li id="logo_lc" title="The Library of Congress"><a href="http://www.loc.gov"></a></li>
                            <li id="global_nav"><a href="http://www.loc.gov/rr/askalib/"><img src="/static/natlibcat/images/ask_librarian.gif" alt="Ask a Librarian" width="101" height="40" /></a><a href="http://www.loc.gov/library/libarch-digital.html"><img src="/static/natlibcat/images/digital_collections.gif" alt="Digital Collections" width="119" height="40" /></a><a href="http://catalog.loc.gov/"><img src="/static/natlibcat/images/library_catalog.gif" alt="Library Catalogs" width="111" height="40" /></a></li>
                        </ul>
                    <!-- end id:left_header -->
                    </div>
                    <div id="right_header"><form class="metasearch" action="http://www.loc.gov/fedsearch/metasearch/" method="get"><span class="options"><a href="http://www.loc.gov/search/more_search.html">Options</a></span><br/><span class="search_wrap"><input type="text" name="cclquery" maxlength="200"/><input class="button" id="search_button" name="search_button" type="submit" value="GO"/></span></form></div>
                <!-- end id:right_header -->
                <!-- end id:top_container -->  
                </div>
                <!-- end id:topnav -->
            </div>
            {ssk:crumbs($crumbs)/div}
            <!-- end id:crumb_nav -->
        </div>
        <!-- end id:ds-header -->
    </body>
};

declare function ssk:crumbs($crumbs as element()* ) as element(crumbs) {
	(:let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING):)


let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
	let $site-title:= $cfg:MY-SITE/cfg:label/string()
					     
	return
    <crumbs xmlns="http://www.w3.org/1999/xhtml">
        <div id="crumb_nav">
            <a href="http://www.loc.gov">The Library of Congress</a>
            <span class="crumb-gt"> &gt; </span>
            <a href="{$url-prefix}">{$site-title}</a>
            <span class="crumb-gt"> &gt; </span>            
            {
                let $len := fn:count($crumbs)
                for $crumb at $x in $crumbs
                return
                (
                    $crumb,
                    if($x ne $len) then
                        <span class="crumb-gt"> &gt; </span>
                    else
                        ()
                )
            }        
        </div>
    </crumbs>
};
declare function ssk:sharetool-div($uri as xs:string ,$title as xs:string) {
	let $hostname :=  $cfg:DISPLAY-SUBDOMAIN
	let $bookmarkhref:=concat('http://', $hostname, '/', $uri)
	let $updated_title:=replace($title, "'","\\'")
	let $media-uri:= if (matches($uri,'lcwa')) then
		replace($uri, 'lcwa','mrva')
	else $uri
	return 
(:		if (contains($hostname,'mlvlp04') and $cfg:MY-SITE/cfg:branding/string()!="tohap") then		:)
		if ( contains($hostname,"mlvlp04") and xdmp:get-request-header('X-LOC-Environment')!='Staging') then
		 	<div class="locshare-this" id="page_toolbar">
				<code>{{ 
					link: '{concat($bookmarkhref,'.html')}', 
            		title: '{$updated_title}',
					thumbnail: {{
									url: '{concat('http://',$hostname,'/media/',$media-uri,'/thumb')}',
									alt: '{$updated_title}'
								}},
					embed_type: 'image',
					embed_detail: '{concat('http://',$hostname,'/media/',$media-uri,'/thumb')}',					
					embed_alt: '{$updated_title}',											
					
					download_links:[
							{{
								label:'MARC Bibliographic Record',
								link: '{concat($bookmarkhref,'.marcxml.xml')}',
								meta: 'XML'
									}},									
							{{
								label:'MODS Bibliographic Record',
								link: '{concat($bookmarkhref,'.mods.xml')}',
								meta: 'XML'
									}},
							{{
								label:'Dublin Core Bibliographic Record',
								link: '{concat($bookmarkhref,'.dc.xml')}',
								meta: 'XML'
									}},
							{{
								label:'METS Object Description',
								link: '{concat($bookmarkhref,'.mets.xml')}',
								meta: 'XML'
									}}
								],
							 show: {{
					                   buttons: {{
					                    print: true,
					                	subscribe: false,
					                    share: true
					                    }},
					                    tabs: {{
					                        share: false,							                       
					                        save: true,
											email: true,
					                    }},
					                    features: {{
					                        link: true,
					                        bookmark: false,													
					                        download: true
					                    }}
					                }}
       			 }}</code>
			</div>
		else
		 ()(:printlink:)
};
declare function ssk:footer() as element(footer) {
(: called by search, detail, permalink:)
    <footer xmlns="http://www.w3.org/1999/xhtml">        		 		
        <div id="footer">
            <div class="f_container">
                <div class="f_inner_top">
                    <h3>Stay Connected with the Library <span><a href="http://www.loc.gov/homepage/connect.html">All ways to connect</a></span></h3>
                    <!-- end class:f_inner_top -->
                </div>
                <div class="f_inner_mid">
                    <div class="find_us">
                        <h4>Find us on</h4><a href="http://www.facebook.com/libraryofcongress"><img width="16" height="16" alt="Facebook" src="/static/natlibcat/images/facebook.gif"/></a><a href="http://twitter.com/librarycongress"><img width="16" height="16" alt="Twitter" src="/static/natlibcat/images/twitter.gif"/></a><a href="http://www.youtube.com/libraryofcongress"><img width="16" height="16" alt="YouTube" src="/static/natlibcat/images/youtube.gif"/></a><a href="http://www.flickr.com/photos/library_of_congress/"><img width="16" height="16" alt="Flickr" src="/static/natlibcat/images/flickr.gif"/></a></div><div class="subscribe"><h4>Subscribe &amp; Comment</h4><span><a href="http://www.loc.gov/rss/">RSS &amp; E-Mail</a></span><span><a href="http://blogs.loc.gov/loc/">Blogs</a></span></div><div class="download"><h4>Download &amp; Play</h4><span><a href="http://www.loc.gov/podcasts/">Podcasts</a></span><span><a href="http://www.loc.gov/webcasts/">Webcasts</a></span><span class="external"><a href="http://deimos3.apple.com/WebObjects/Core.woa/Browse/loc.gov">iTunes U</a></span>
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
    </footer>
};
