xquery version "1.0-ml";

module namespace ssk = "info:lc/xq-modules/search-skin";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace search = "http://marklogic.com/appservices/search";

declare function ssk:footer() as element(footer) {
    <footer xmlns="http://www.w3.org/1999/xhtml">
    	<div id="ds-footer">
	        <div id="footer">
		        <a href="http://www.loc.gov/about/">About</a> | <a href="http://www.loc.gov/pressroom/">Press</a> | <a href="http://www.loc.gov/about/sitemap/">Site Map</a> | <a href="http://www.loc.gov/help/contact-general.html">Contact</a> | <a href="http://www.loc.gov/access/">Accessibility</a> | <a href="http://www.loc.gov/homepage/legal.html">Legal</a> | <a href="http://www.loc.gov/global/disclaim.html">External Link Disclaimer</a> | <a href="http://www.usa.gov/">USA.gov</a>
	        </div><!-- end id:footer --> 
        </div><!-- end id:ds-footer -->
    </footer>
};

declare function ssk:header($title as xs:string) as element(header) {
    <header xmlns="http://www.w3.org/1999/xhtml">
    	<head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <title>{concat($title, " (National Library Collections, Library of Congress)")}</title>
            <meta name="Keywords" content="search results national library collections library congress" />
            <meta name="Description" content="Search Results for . National Library Collections, Library of Congress" />
            <link rel="stylesheet" media="screen, projection" type="text/css" href="/static/natlibcat/css/datastore.css" />
            <link type="text/css" rel="stylesheet" href="/static/natlibcat/css/jquery-ui-1.8.2.all.css"/>
            <link type="text/css" rel="stylesheet" href="/static/natlibcat/css/facybox.css"/>
            <link type="text/css" rel="stylesheet" href="/static/natlibcat/css/mlstyle.css"/>
            <link type="text/css" rel="stylesheet" href="/static/natlibcat/css/splash.css"/>
            <script type="text/javascript" src="/static/natlibcat/js/jquery-1.4.4.min.js"></script>
            <script type="text/javascript" src="/static/natlibcat/js/jquery-ui-1.8.2.all.min.js"></script>  
            <script type="text/javascript" src="/static/natlibcat/js/jquery.address-1.3.2.min.js"></script>
            <script type="text/javascript" src="/static/natlibcat/js/facybox.js"></script> 
            <script type="text/javascript" src="/static/natlibcat/js/natlibcat.min.js"></script>
            <!--<script type="text/javascript" src="http://www.loc.gov:8081/global/foresee/foresee-trigger.js"></script>-->
        </head>
        <body>
            <div id="ds-header">
                <div id="topnav">
                    <div id="top_container">
                        <ul id="menu">
                            <li id="logo_lc" title="The Library of Congress"><a href="http://www.loc.gov"></a></li>
                            <li id="global_nav"><a href="http://www.loc.gov/rr/askalib/"><img src="/static/natlibcat/images/ask_librarian.gif" alt="Ask a Librarian" width="101" height="40" /></a><a href="http://www.loc.gov/library/libarch-digital.html"><img src="/static/natlibcat/images/digital_collections.gif" alt="Digital Collections" width="119" height="40" /></a><a href="http://catalog.loc.gov/"><img src="/static/natlibcat/images/library_catalog.gif" alt="Library Catalogs" width="111" height="40" /></a></li>
                        </ul>
                    </div>
                    <!-- end id:top_container -->
                </div>
                <!-- end id:topnav -->      
                {ssk:crumbs()/div}
                <!-- end id:crumb_nav -->
            </div>
            <!-- end id:ds-header -->
        </body>
    </header>
};

declare function ssk:leftnav() as element(leftnav) {
    <leftnav xmlns="http://www.w3.org/1999/xhtml">
    	<div id="left_nav">
    		<div id="left_nav_top">
    			<a href="http://marklogic1.loctest.gov/index.html">
    				<img height="50" width="197" alt="Datastore Home" src="/marklogic/static/img/lc_photos.gif"/>
    			</a>
    		</div>
    		<div id="left_nav_mid">
    			<form id="site_search" method="get" action="http://marklogic1.loctest.gov/search">
    			<!-- <form id="site_search" method="get" action="../search"> -->    			
    				<input type="hidden" value="titlesort" id="order" name="sort"/>
    				<input type="hidden" value="thumbnail" id="view" name="view"/>
    				<input id="searchtext" onfocus="this.value=''" maxlength="255" value=" Search datastore" name="query" type="text"/>
    				<input value="GO" type="submit" name="submit" class="button" onfocus="clearMainSearchBox();"/>
    				<br/>
    				<a href="../search/pae-search.html">More Search Options</a>
    			</form>
    		</div>
    		<div id="left_nav2">
    			<div class="left_nav2_main">
    				<ul>
    					<li>
    						<a href="/marklogic/rr/datastore/">Home</a>
    					</li>
    					<li>
    						<a href="../home/about.html">About </a>
    					</li>
    					<li>
    						<a href="../home/pae-contact.html">Contact Us</a>
    					</li>
    					<li>
    						<a href="../home/pae-help.html">Help</a>
    					</li>
    					<li>
    						<a href="../home/copyright.html">Copyright</a>
    					</li>
    				</ul>
    			</div>
    			<!--left_nav2_main-->
    		</div>
    		<!--left_nav2-->
    	</div>
    	<!--leftnav-->
    	<span id="skip_menu"/>
    </leftnav>
};

declare function ssk:crumbs() as element(crumbs) {
    <crumbs xmlns="http://www.w3.org/1999/xhtml">
        <div id="crumb_nav">
            <a href="http://www.loc.gov">The Library of Congress</a>
            <span class="crumb-gt"> &gt; </span>
            <a href="/">National Library Catalog (beta)</a>
            <span class="crumb-gt"> &gt; </span>
            <span id="ds-searchcrumb"><a href="/xq/lscoll/app.xqy#/page=search&amp;pg=1&amp;mime=text/html&amp;sort=score-desc&amp;collection=all&amp;count=10">Search</a></span>
            <span class="crumb-gt"> &gt; </span>
            <span id="ds-searchresultcrumb">Enter query</span>
        </div>
    </crumbs>
};

declare function ssk:all() as element(static-wrapper) {
    <static-wrapper>
        {ssk:header("Search")}
        {ssk:crumbs()}
        {ssk:leftnav()}
        {ssk:footer()}
    </static-wrapper>
};