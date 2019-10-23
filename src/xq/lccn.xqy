xquery version "1.0-ml";
(: 
 xslt rendering  for lcdb bib records
    Take a given $id as the objid in mets, and return the permalink display of the marcxml record
    requires transformation from mxe2 to  marcslim, then running displayLccn.xsl, as adapted from 
    lccnstyle1.xsl, and sending the header/footer, $lcdbDisplay nodes to renderPage.xsl for final layout.
    
	This will only work  for things with mxe or marc records, not PAE etc. 

:)
(:
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', "text/html")) 
:)

import module namespace ssk = "info:lc/xq-modules/search-skin" at "/src/xq/modules/natlibcat-skin.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/src/lds/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/src/lds/lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/src/xq/modules/mime-utils.xqy";
import module namespace xslt="info:lc/xq-modules/xslt" at "/src/xq/modules/xslt.xqy"; 
import module namespace utils= "info:lc/xq-modules/mets-utils" at "/src/xq/modules/mets-utils.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils" at "/src/xq/modules/marc-utils.xqy";
import module namespace index= "info:lc/xq-modules/index-utils" at "/src/xq/modules/index-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/src/xq/modules/config/materialtype.xqy";

import module namespace md = "http://www.marklogic.com/ps/model/m-doc" at "/src/lds/model/m-doc.xqy";
declare namespace xdmp="http://marklogic.com/xdmp";
declare namespace marc="http://www.loc.gov/MARC21/slim";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace http="xdmp:http"; (: for http response:)
declare default element namespace "http://www.w3.org/1999/xhtml" ; (:for output:)
declare  namespace xhtml="http://www.w3.org/1999/xhtml" ; (:for output:)
declare namespace mxe="http://www.loc.gov/mxe";
declare namespace zs="http://www.loc.gov/zing/srw/";
declare namespace mat="info:lc/xq-modules/config/materials";

(:
declare variable $mime as xs:string := xdmp:get-request-field("mime","text/xhtml");  (: mxe, mets, mods, marcxml...dc? :)
:)


let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', "text/html")) 

let $lccn as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "lccn", "")

  
let $search:=concat("http://z3950.loc.gov:7090/voyager?operation=searchRetrieve&amp;version=1.1&amp;query=bath.lccn=%22^",$lccn,"%22&amp;recordSchema=marcxml&amp;recordPacking=xml&amp;startRecord=1&amp;maximumRecords=10")
let $result:=xdmp:http-get($search)[2]
  
return 
    if ($result//zs:diagnostics or $result//zs:numberOfRecords=0) then
	   xdmp:http-get("//lccn/html/lccn-problem.html")[2]
	else  if (matches($mime, "application/marcxml\+xml")) then
		$result//marc:record
	else  if (matches($mime,"application/mods\+xml")) then

		 try { 
	            xdmp:xslt-invoke("/config/MARC21slim2MODS3-3HldgsML.xsl",document{$result//marc:record})
	        } catch ($exception) {
	            $exception
	        }
	 else  if (matches($mime, "application/srwdc\+xml")) then
    	   		try 	{                                          
       	 			xdmp:xslt-invoke("/xslt/MARC21slim2SRWDC.xsl",document{$result//marc:record})
	       	 	} catch ($exception) {
	           		<error>{$exception}</error>
	        	}    		               
	 else
		let $leader6 :=	substring($result/marc:record/marc:leader,7,1)
		let $leader6_2:=substring($result/marc:record/marc:leader,7,2)		
		let $control6:= substring($result/marc:controlfield[@tag='006'],1,1)		
		let $control7:= substring($result/marc:controlfield[@tag='007'],1,1)
		let $control821:= substring($result/marc:controlfield[@tag='008'],21,1)
		let $materials:=matconf:materials()
		let $mattype:=  
				if ($materials//mat:materialtype[@tag='008_21_1'][@code=$control821]/mat:desc/string()!="" ) then
		    		$materials//mat:materialtype[@tag='008_21_1'][@code=$control821]
				else if ($materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/text()!="" ) then
		    		$materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/string()
		     	else if ($materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/text()!="") then
			            $materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/string()
		    	else if ($materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/text()!="") then
		             $materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/string()
		     	else ()  

		let $displayXsl :="/xslt/displayLccn.xsl"
		 let $params:=map:map()
	    let $put:=map:put($params, "hostname", $cfg:DISPLAY-SUBDOMAIN)
	    let $put:=map:put($params, "mattype",$mattype)
	    let $put:=map:put($params, "lccn",$lccn)
		let $put:=map:put($params, "source","bib") (: may change to auths, subjects, based on lccn prefix??? :)

    	let $lccnDisplay:=
	        try { 
	            xdmp:xslt-invoke($displayXsl,document{$result//marc:record},$params)
	        } catch ($exception) {
	            $exception
	        }
	let $head:=
			<head>
				<meta http-equiv="Content-Language" content="en-us" />
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<title>Library of Congress LCCN Permalink for {$lccn}</title>				
				<meta name="keywords" content="Library of Congress, LCCN, LC Online Catalog, LCCN permalink, persistent identifier LCCN:{$lccn}"/>
				<meta name="description" content="LCCN Permalink provides persistent links to metadata records in the LC Online Catalog. LCCN:{$lccn}"/>
				
				<link href="/lccn/html/cataloga.css" rel="stylesheet" type="text/css"/>
				<link href="/lccn/html/catalogp.css" rel="stylesheet" type="text/css" media="print"/>
				<link rel="unapi-server" type="application/xml" title="unAPI" href="http://lccn.loc.gov/unapi"/>
				<link href="http://lccn.loc.gov/{$lccn}/mods" type="application/mods+xml" rel="alternate" />
				<link href="http://lccn.loc.gov/{$lccn}/marcxml" type="application/marc+xml" rel="alternate" />
				<link href="http://lccn.loc.gov/{$lccn}/dc" type="application/dc+xml" rel="alternate" />
				<link href="http://lccn.loc.gov/{$lccn}/oai_dc" type="application/oai_dc+xml" rel="alternate" />
			</head>

	let $header:=<header>						
					<div id="crumb_nav"><!-- begin crumb_nav -->
						<a href="http://www.loc.gov/">The Library of Congress</a> > LCCN Permalink</div>
					<div id="header"><!-- begin header -->
						<table class="banner">
							<tr>
								<td width="57">
									<a href="http://catalog.loc.gov/"><img src="/lccn/html/images/banner-rose-left.gif" alt="Search the LC Online Catalog" width="57" height="55" border="0"/></a>
								</td>
								<td width="50%" class="banner-image">&#160;</td>
								<td width="488">
									<a href="http://catalog.loc.gov/"><img src="/lccn/html/images/banner-center-lccn.gif" width="488" height="55" alt="Library of Congress Catalog Record" border="0"/></a>
								</td>
								<td width="50%" class="banner-image">&#160;</td>
								<td width="60">
									<a href="http://catalog.loc.gov/"><img src="/lccn/html/images/banner-rose-right.gif" alt="Search the LC Online Catalog" width="60" height="55" border="0"/></a>
								</td>
							</tr>
						</table>
					</div><!-- end header -->

					<div id="formats"><!-- begin other formats -->						
							<em>View LC holdings for this title in the:&#160;&#160;</em>
							<a href="http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?DB=local&amp;CMD=lccn%22{$lccn}%22&amp;v3=1&amp;CNT=10">LC Online Catalog</a>&#160;&#160;<em>View this record in:&#160;&#160;</em><a href="/xq/lccn.xqy?lccn={$lccn}&amp;mime=application/marcxml+xml">MARCXML</a>&#160;|&#160;<a href="/xq/lccn.xqy?lccn={$lccn}&amp;mime=application/mods+xml">MODS</a>&#160;|&#160;<a href="/xq/lccn.xqy?lccn={$lccn}&amp;mime=application/srwdc+xml">Dublin Core</a>
					</div><!-- end other formats -->
		</header>
	let $footer:=
		<div id="footer"><!-- begin footer -->
						<div id="footer-left">
							<span class="cip">
								<em>LCCN Permalink:</em>&#160;A Service of the Library of Congress</span>
							<br/>
							<br/>
							<a href="http://www.loc.gov/about/">About</a>&#160;|&#160;<a href="http://www.loc.gov/pressroom/">Press</a>&#x20;|&#x20;<a href="http://www.loc.gov/about/sitemap/">Site Map</a>&#160;|&#160;<a href="http://www.loc.gov/help/contact-general.html">Contact</a>&#160;|&#160;<a href="http://www.loc.gov/access/">Accessibility</a>&#160;|&#160;<a href="http://www.loc.gov/homepage/legal.html">Legal</a>&#160;|&#160;<a href="http://www.usa.gov/">USA.gov</a><br/></div>
						<div id="footer-right">More information:&#x20;<a href="/lccn/html/lccnperm-faq.html">LCCN Permalink FAQ</a></div>
					</div>					

let $html:= <html>{$head}
				<body>
				<div id="container"><!-- begin container -->
					<abbr class="unapi-id" title="{$lccn}"></abbr>
					{$header/*}
					<div id="content"><!-- begin content -->
						{$lccnDisplay}
					</div>
					{$footer}
					</div>
				</body>
			</html>			
return ($html)
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)