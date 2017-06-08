<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:include href="utils.xsl"/>
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<xsl:variable name="pages">
		<xsl:choose>
			<xsl:when test="$profile='photoObject'">
				<!--pages in this version-->
				<xsl:value-of select="count(/pageTurner/object/version[@ID=$section]/pages/page)" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$pageCount" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/" as="item()*">
		<h1 style="display:none">
			<xsl:copy-of select="$pageCount" copy-namespaces="yes"/>
		</h1>
		<xsl:choose>
			<xsl:when test="starts-with($section, 'ver')">
				<xsl:apply-templates select="//version[@ID=$section]/pages/page[position()=$pageNum]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="//pages/page[position()=$pageNum]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="page" as="item()*">

		<div id="ds-bibrecord">
			<h1 id="title-top">
				<xsl:choose>
					<xsl:when test="$profile='photoBatch' and @label!=''">
						<xsl:value-of select="@label" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:when test="$profile='photoBatch'">Image <xsl:value-of select="$pageNum" disable-output-escaping="no"/></xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$sheet-title" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</h1>
			<xsl:if test="$pageCount &gt; 1">
				<div class="main_nav2_top">
					<xsl:call-template name="navbar">
						<xsl:with-param name="position">1</xsl:with-param>
						<xsl:with-param name="pageCount" select="$pages"/>
					</xsl:call-template>
				</div>
			</xsl:if>
			<xsl:if test="//relatedItem[@type='host'] and $objectHeader='Volume '">
				<xsl:variable name="parentURL">
					<xsl:value-of select="concat('/diglib/vols/loc.rbc.sr.', //relatedItem/element[@label='LCCN']/value, '/')" disable-output-escaping="no"/>
				</xsl:variable>from <a href="{$parentURL}">
					<xsl:value-of select="//relatedItem[@type='host']/element[@label='Title']/value" disable-output-escaping="no"/></a></xsl:if>
			<div id="ds-maincontent">

				<!-- the ds-viewport class is a container for the viewport or other digital object player; if it is empty, then it will disappear -->
				<div id="ds-digitalport">
					<div id="viewport-on">
					</div>
					<!-- end class:viewport-on -->
				</div>
				<!-- end class:ds-viewport -->

				<!-- the tabs are for bib views digital behaviors, etc. -->
				<ul class="tabnav">
					<li class="first">
						<a href="#tab1">Access/Details</a>
					</li>
					<li>
						<a href="#tab2">Rights/Restrictions</a>
					</li>
					<li>
						<a href="#tab3">Citation Formats</a>
					</li>
				</ul>
				<!-- end class:tabnav -->
				<div class="tab_container">
					<div id="tab1" class="tab_content">
						<div class="access-box">
							<h2 class="hidden">Access</h2>
							<ul class="std">
								<li>Access Online: <strong>Zoom/Pan</strong> | <a href="#">Contact Sheet</a> | <a href="#">Page Turner</a> | <a href="#">Download TIF</a></li>
								<li>Links: <a href="#">Table of Contents</a>| <a href="#">Publishers Desciption</a> | <a href="#">Abstract/Review</a></li>
								<li>Library Location: <a href="#">Performing Arts Reading Room (LM 135)</a></li>
								<li>View/Request: <a href="http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?DB=local&amp;CMD=lccn%222004099254%22&amp;v3=1&amp;CNT=10">LC Online Catalog</a> | <a href="http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?PAGE=REQUESTBIB&amp;bbid=13990048" target="_new">Request Material (onsite only)</a></li>
							</ul>
						</div>
						<!-- access-box -->

						<div id="ds-bibrecord">
							<h2 class="hidden">Details</h2>
							<!-- ds-bibrecord -->
						</div>
					</div>
					<!-- tab_content -->
				</div>
				<!-- tab_container -->
				<div id="pageturner_page" style="width:540px;">
					<!--id="pageturner_page"-->
					<xsl:call-template name="behaviorLink">
						<xsl:with-param name="behavior">pageturner</xsl:with-param>
						<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/>&amp;from=<xsl:value-of select="$behavior" disable-output-escaping="no"/></xsl:with-param>
						<xsl:with-param name="content">
							<xsl:call-template name="makeImageLink">
								<xsl:with-param name="URL" select="image/@href"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</div>
				<xsl:if test="$pageCount &gt; 1">
					<div class="main_nav2_bottom">
						<xsl:call-template name="navbar">
							<xsl:with-param name="position">2</xsl:with-param>
							<xsl:with-param name="pageCount" select="$pages"/>
						</xsl:call-template>
					</div>
				</xsl:if>
			</div>
			<!--endds-bibrecord-->
		</div>
	</xsl:template>
</xsl:stylesheet>