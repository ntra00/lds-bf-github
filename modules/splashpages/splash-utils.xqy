xquery version "1.0-ml";
(:
 Helper functions for the splash pages
:)
module namespace splash = "info:lc/splashpages/splash-utils";
(:declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace gml = "http://www.opengis.net/gml";:)
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function splash:header($title as xs:string, $branding as xs:string) as element(header) {
    let $prefix := if (not($branding)) then "natlibcat" else $branding
	let $cssfile := if (not($branding)) then "datastore-new" else $branding
	
    return
    <header xmlns="http://www.w3.org/1999/xhtml">
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                 <title>{$title}</title>
                 <link rel="stylesheet" type="text/css" href="/static/{$prefix}/css/{$cssfile}.css" media="screen"/>
                 <link href="http://www.loc.gov/share/sites/8usedrUw/share-min.css" rel="stylesheet" type="text/css" media="screen, all"/>
                 <script type="text/javascript" src="http://cdn.loc.gov/js/lib/jquery-1.5.1.min.js"></script>
                 
                 <script type="text/javascript">
                 var originalValue = "";
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
                                        		
                                        		originalValue = $('input#searchcollection').val();
                                        	}});
                                        }})(jQuery);
                                        
                                        function validateForm() {{
                                            var newValue = $('input#searchcollection').val();
                                            if (originalValue == newValue) {{
                                                $('input#searchcollection').val("");
                                            }}
                                            return true;
                                        }}
                                        </script>
                 <script src="http://cdn.loc.gov/js/lib/modernizr-1.5.min.js"></script>
        </head>
        </header>
};

declare function splash:topnav-div($site-title as xs:string) as element(body){
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
            <div id="crumb_nav">
            <a href="http://www.loc.gov">The Library of Congress</a>
            <span class="crumb-gt"> &gt; </span>
            {$site-title}
            
        </div>
            <!-- end id:crumb_nav -->
        </div>
        <!-- end id:ds-header -->
    </body>
};
