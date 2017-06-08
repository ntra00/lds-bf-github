<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="mets mods xlink" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:output method="html" indent="yes"/>
	<xsl:param name="kmlurl"/>
	<xsl:param name="itemID"/>
	<!-- works with geo results  -->
	 <xsl:include href="utils.xsl"/> 
	
	<xsl:template match="/" as="item()*">
		<xsl:variable name="urlkml" select="concat('/marklogic/kml.xqy?svcid=', $kmlurl)"/>
		
		<html>
			<xsl:call-template name="makeGeoHEAD"/>
			<!-- not in utils.xsl, but local-->
			<body onload="geodefaultinit(kmlurl);">
				<abbr title="{$ID}" class="unapi-id"/>
				<xsl:call-template name="leftnav"/>
				<xsl:choose>
					<xsl:when test="contains(pageTurner/descriptive/full/element[contains(@label,'Collection')]/value,'Chasanoff/Elozua')">
						<div id="page_head_fixed">
							<h1>The Chasanoff/Elozua Amazing Grace Collection <br/><span>A searchable catalog of more than 3000 published recordings of Amazing Grace</span></h1>
						</div>
					</xsl:when>
					<xsl:when test="contains(pageTurner/pages/page/image/@href,'afc9999005')">
						<div id="page_head_fixed">
							<h1>Traditional Music and Spoken Word Catalog <br/><span> from the <a href="http://www.loc.gov/folklife">American Folklife Center</a></span></h1>
						</div>
					</xsl:when>
					<xsl:when test="contains(//pageTurner/descriptive/full/element[contains(@label,'Source')]/value,'Jazz on the Screen')">
						<div id="page_head_fixed">
							<h1>Jazz on the Screen <br/><span>A jazz and blues filmography by David Meeker</span></h1>
						</div>
					</xsl:when>
				</xsl:choose>
				<div id="main_menu_fixed">
					<!--<xsl:call-template name="locshare"/>-->
					<div style="min-height: 1450px;" id="main_body">
						<h2>
							<xsl:value-of select="$sheet-title" disable-output-escaping="no"/>
						</h2>
						<div id="gmap">
							<!-- empty div for map -->
						</div>
						<xsl:if test="//pages/page/image/@href or /pageTurner/pages/illustration or /pageTurner/pages/displayImage">
							<xsl:choose>
								<xsl:when test="/pageTurner/pages/displayImage/page/image/@href">
									<!--hand coded display image:-->
									<xsl:call-template name="makeImageLink">
										<xsl:with-param name="URL" select="/pageTurner/pages/displayImage/page/image[1]/@href"/>
										<xsl:with-param name="alt">
											<xsl:value-of select="pageTurner/descriptive/full/element[@label='Title']" disable-output-escaping="no"/>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="/pageTurner/pages/page/image/@href and $profile!='bibRecord'">
									<!-- simpleAudio with bib cards -->
									<xsl:call-template name="makeImageLink">
										<xsl:with-param name="URL" select="/pageTurner/pages/page[1]/image/@href"/>
										<xsl:with-param name="alt">
											<xsl:value-of select="pageTurner/descriptive/full/element[@label='Title']" disable-output-escaping="no"/>
											<!-- Image: see descriptive information to the right -->
										</xsl:with-param>
										<xsl:with-param name="section">
											<xsl:if test="/pageTurner/pages/version/@ID">
												<xsl:value-of select="/pageTurner/pages/version[1]/@ID" disable-output-escaping="no"/>
											</xsl:if>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$profile='simpleAudio' ">
									<!-- <xsl:if test="/pageTurner/pages/page/image/@href"> -->
									<xsl:call-template name="makeImageLink">
										<xsl:with-param name="URL" select="/pageTurner/pages/illustration[1]/image/@href"/>
										<xsl:with-param name="alt">
											<xsl:value-of select="pageTurner/descriptive/full/element[@label='Title']" disable-output-escaping="no"/>
											<!-- Image: see descriptive information to the right -->
										</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="collection" select="pageTurner/descriptive/full/element[@label='Collection']/value"/>
									<xsl:variable name="iconBehavior">
										<xsl:choose>
											<!-- <xsl:when test="$profile='simplePhoto' or $profile='photoObject'">enlarge</xsl:when> -->
											<xsl:when test="$profile='simplePhoto' or $profile='photoObject' or ( $profile='bibRecord' )">enlarge</xsl:when>
											<xsl:otherwise>pageturner</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="params">
										<xsl:choose>
											<xsl:when test="$profile='simplePhoto' or $profile='photoObject'">page=1<xsl:if test="/pageTurner/pages/version/@ID">&amp;section=<xsl:value-of select="/pageTurner/pages/version[1]/@ID" disable-output-escaping="no"/></xsl:if></xsl:when>
											<xsl:when test="$profile='bibRecord'">from=default</xsl:when>
											<xsl:otherwise>page=1</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:call-template name="behaviorLink">
										<xsl:with-param name="behavior">
											<xsl:value-of select="$iconBehavior" disable-output-escaping="no"/>
										</xsl:with-param>
										<xsl:with-param name="params">
											<xsl:value-of select="$params" disable-output-escaping="no"/>
										</xsl:with-param>
										<xsl:with-param name="content">
											<xsl:call-template name="makeImageLink">
												<xsl:with-param name="URL">
													<xsl:choose>
														<xsl:when test="$profile='photoObject'">
															<xsl:value-of select="/pageTurner/pages/page[1]/image/@href" disable-output-escaping="no"/>
														</xsl:when>
														<xsl:when test="/pageTurner/pages/illustration">
															<xsl:value-of select="/pageTurner/pages/illustration[1]/image/@href" disable-output-escaping="no"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="/pageTurner/pages/page[1]/image/@href" disable-output-escaping="no"/>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:with-param>
												<xsl:with-param name="alt">
													<!-- Image: see descriptive information to the right -->
													<xsl:value-of select="pageTurner/descriptive/full/element[@label='Title']" disable-output-escaping="no"/>
												</xsl:with-param>
											</xsl:call-template>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<!-- display metadata: -->
						<xsl:choose>
							<xsl:when test="$profile='simpleAudio' or $profile='bibRecord'">
								<xsl:apply-templates select="/pageTurner/descriptive/full"/>
							</xsl:when>
							<xsl:when test="$profile='article' or $profile='biography' or $profile='patriotismSongCollection' or $profile='songOfAmericaCollection'">
								<xsl:apply-templates select="/pageTurner/menu/whole/part/content/*"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- works with mods-default: -->
								<!-- <xsl:apply-templates select="/pageTurner/descriptive/brief"/> -->
								<!-- works with labels, groupings: -->
								<xsl:apply-templates select="/pageTurner/descriptive/full/element[@display='brief']"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:call-template name="metsLinks"/>
						
						<p style="margin: auto; border: 2px dashed rgb(238, 154, 2); padding: 3px; font-weight: bold; background-color: rgb(241, 201, 141); width: 75%; text-align: center; margin-bottom: 10px;">
<span>
		<img style="vertical-align: bottom;" src="/marklogic/static/img/google_earth_link.gif" alt="Download KML for Google Earth"/>
	      </span>
<span style="margin: 1px 3px 1px 15px; font-size: larger;"><a href="{$urlkml}">Download KML</a> of results</span>
</p>
					</div>
					<!--main_body-->
				</div>
				<!--main_menu-->
			</body>
		</html>
	</xsl:template>
	<xsl:template match="a" as="item()*">
		<a href="{@href}">
			<xsl:value-of select="." disable-output-escaping="no"/>
		</a>
		<xsl:if test="not(contains(../text(),'--'))">
			<br/>
		</xsl:if> </xsl:template>
	<xsl:template match="brief | full" as="item()*">
		<dl>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="/pageTurner/pages//image">item</xsl:when>
					<xsl:otherwise>full</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="element"/>
		</dl>
	</xsl:template>
	<xsl:template match="*" as="item()*">
		<xsl:copy-of select="." copy-namespaces="yes"/>
	</xsl:template>
	<xsl:template name="makeGeoHEAD" as="item()*">
		<xsl:variable name="gmd1">
			<xsl:call-template name="format"/>
		</xsl:variable>
		<xsl:variable name="objectTitle">
			<xsl:choose>
				<xsl:when test="$behavior='contents' or $behavior='item'">
					<xsl:value-of select="concat(//mods:mods/mods:titleInfo/mods:nonSort,//mods:mods/mods:titleInfo/mods:title, ' [', $gmd1,']')" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$title" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<head>
			<title>
				<xsl:value-of select="$title" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">:</xsl:text>
				<xsl:value-of select="$objectType" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no"> </xsl:text>
				<xsl:value-of select="$behaviorType" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">: Library of Congress</xsl:text>
			</title>
			<meta name="Keywords" content=" library congress"/>
			<meta name="Description" content="{$title} :{$objectType} {$behaviorType}  ( Library of Congress )"/>
			<link rel="stylesheet" type="text/css" href="/marklogic/static/css/default/loc_pae100_ss.css"/>
			<link rel="stylesheet" type="text/css" href="/marklogic/static/css/default/results.css"/>
			<link rel="stylesheet" type="text/css" href="/marklogic/static/js/jquery-ui/css/cupertino/jquery-ui-1.8rc3.custom.css"/>
			<style type="text/css">#gmap {margin: auto; width: 512px; height:250px;}</style>
			<!-- lc share tool -->
			<link href="/share/sites/zawrE2Ra/share-min.css" rel="stylesheet" type="text/css" media="screen, all"/>
			<script type="text/javascript" src="/share/sites/zawrE2Ra/share-jquery-min.js"> 
				<!-- non empty script -->
			</script>
			<script type="text/javascript"> 
				<!-- non empty script -->{ <xsl:value-of select="$title" disable-output-escaping="no"/> }</script>
			<link href="http://lcweb2.loc.gov/diglib/ihas/unapi" title="unAPI" type="application/xml" rel="unapi-server"/>
			<script type="text/javascript" src="/marklogic/static/js/OpenLayers/OpenLayers.js"> <!-- space --> </script>
			<script type="text/javascript" src="/marklogic/static/js/default/geodefault.js"> <!-- space --> </script>
			<script type="text/javascript" id="ARGGGH">
				<xsl:text disable-output-escaping="no">var kmlurl = "</xsl:text>
				<xsl:value-of select="concat('/marklogic/kml.xqy?svcid=', $kmlurl)" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">";</xsl:text>
			</script>
		</head>
	</xsl:template>
</xsl:stylesheet>