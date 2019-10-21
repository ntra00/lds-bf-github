<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mods mets xlink" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/mets" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<!--input is local <pageTurner>, output is xhtml-->
	<xsl:include href="../pageturner/utils.xsl"/>	
	<xsl:include href="../pageturner/navbar.xsl"/>	
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

	<xsl:template match="/" as="item()*">
		<div id="ds-maincontent">
			<!-- the ds-viewport class is a container for the viewport or other digital object player; if it is empty, then it will disappear -->
			<div id="ds-digitalport">
				<div id="viewport-on"> </div>
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
							<li>Access Online: 
							<!-- <strong>Zoom/Pan</strong> | <a href="#">Contact Sheet</a> | <a href="#">Page Turner</a> -->
							<xsl:apply-templates select="/pageTurner/menu/whole/part[1]|/pageTurner/menu/whole/part[position() &lt; 4 ]"/> | <a href="#">Download TIF</a> </li>
							<li>Links: <a href="#">Table of Contents</a>| <a href="#">Publishers Desciption</a> | <a href="#">Abstract/Review</a></li>
							<li>Library Location: <a href="#">Performing Arts Reading Room (LM 135)</a></li>
							<!-- <li>View/Request: <a href="http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?DB=local&amp;CMD=lccn%222004099254%22&amp;v3=1&amp;CNT=10">LC Online Catalog</a> | <a href="http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?PAGE=REQUESTBIB&amp;bbid=13990048" target="_new">Request Material (onsite only)</a></li> -->
						</ul>
					</div>
					<!-- access-box -->

					<div id="ds-bibrecord">
						<h1 id="title-top">
							<xsl:value-of select="descriptive/pagetitle" disable-output-escaping="no"/>
						</h1>
						<h2 class="hidden">Details</h2>
						<!-- <xsl:copy-of select="descriptive/imagelink/*"/>				 -->		
						<!-- display metadata: -->
						<xsl:choose>
							<xsl:when test="descriptive/profile='article' or descriptive/profile='biography' or descriptive/profile='patriotismSongCollection' or descriptive/profile='songOfAmericaCollection'">
								<xsl:apply-templates select="menu/whole/part/content/*"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="//full"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="descriptive/contains"/>
					</div>
<!--bibrecord-->
				</div>
				<!-- tab1 -->
				<div id="tab2" class="tab_content">
						<h2 class="hidden">Rights and Restrictions</h2>
						<p>There are no known restrictions on publication or distribution of   images in the Liljenquist Family Collection of Civil War Photographs.</p>
						<p>
							<strong>Access:</strong>Restricted. Served by appointment   only. Digital images are available in the Prints &amp; Photographs   Online Catalog where the image content is easier to see than in the   original ambrotypes and tintypes. As a preservation measure, the digital   images are used in preference to serving originals.</p>
						<p>
							<strong>Reproduction (photocopying, hand-held camera copying,                 photoduplication and other forms of copying allowed by "fair            use"):</strong>Digital images are available. Additional copying is restricted because of the fragility of the materials.</p>
						<p>
							<strong>Publication and other forms of distribution:</strong>There are no known restrictions on publication or distribution of the   [type of material] in the [name of collection].   These [types of materials] can be published without requesting permission.</p>
						<p>
							<strong>Credit Line:</strong>Library of Congress, [name of] Division, [reproduction number, e.g., LC-DIG-ppmsca-26460]</p>
					</div>
					<!-- <div id="tab3" class="tab_content">
						<h2 class="hidden">Citation Formats</h2>
						<p>
							<em>The selection of citation formats provided below is based on reference standards. However, formatting rules   can vary widely between applications and fields of interest or study.   The specific requirements for  your project  should be applied.</em>
						</p>
						<h3>APA (6th ed.)</h3>
						<p>Rock, E. T., &amp; Society of Wild Weasels. (2005). <em>First in, last out: Stories by the Wild Weasels</em>. Bloomington, Ind: AuthorHouse.</p>
						<h3>Chicago (Author-Date, 15th ed.)</h3>
						<p>Rock, Edward T. 2005. <em>First in, last out: stories by the Wild Weasels</em>. Bloomington, Ind: AuthorHouse.</p>
						<h3>Harvard (18th ed.)</h3>
						<p>ROCK, E. T. (2005). <em>First in, last out: stories by the Wild Weasels</em>. Bloomington, Ind, AuthorHouse.</p>
						<h3>MLA (7th ed.)</h3>
						<p>Rock, Edward T. <em>First In, Last Out: Stories by the Wild Weasels</em>. Bloomington, Ind: AuthorHouse, 2005. Print.</p>
						<h3>Turabian (6th ed.)</h3>
						<p>Rock, Edward T. <em>First in, Last Out: Stories by the Wild Weasels</em>. Bloomington, Ind: AuthorHouse, 2005.</p>
					</div> -->
					
					
			</div>
			<!-- tab_container -->
		</div>
		<!-- maincontent -->
	</xsl:template>

	<xsl:template match="full" as="item()*">
		<dl class="record">
			<xsl:apply-templates select="element"/>
		</dl>
	</xsl:template>
	<xsl:template match="contains" as="item()*">
		<ul class="mktree">
			<li>
				<strong>
					<xsl:value-of select="element[1]/@label" disable-output-escaping="no"/>
				</strong>
				<ul>
					<xsl:apply-templates select="element" mode="tree"/>
				</ul>
			</li>
		</ul>
	</xsl:template>

	<xsl:template match="element" mode="tree" as="item()*">
		<li>
			<xsl:choose>
				<xsl:when test="value/a">
					<xsl:copy-of select="value/*" copy-namespaces="yes"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="value" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="element">
				<ul>
					<xsl:apply-templates select="element" mode="tree"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	<xsl:template match="element" as="item()*">
		<dt>
			<xsl:value-of select="@label" disable-output-escaping="no"/>
		</dt>
		<xsl:choose>
			<xsl:when test="count(value) &lt; 15">
				<xsl:for-each select="value">
					<dd class="bibdata">
						<xsl:choose>
							<!-- allow search string instead of just text: notes, genre, subjects -->
							<!-- <xsl:when test="(starts-with(../@label,'Subject') or ../@label='Genre') and a"> -->
							<xsl:when test="a">
								<xsl:apply-templates select="a"/>
								<br/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</dd>
				</xsl:for-each>
			</xsl:when>

			<xsl:otherwise>
				<dd>
					<xsl:for-each select="value">
						<xsl:choose>
							<xsl:when test="a">
								<xsl:apply-templates select="a"/>
								<br/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="." disable-output-escaping="no"/>;</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</dd>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="element" mode="tree" as="item()*">
		<li>
			<xsl:choose>
				<xsl:when test="value/a">
					<xsl:apply-templates select="value/a"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="value" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="element">
				<ul>
					<xsl:apply-templates select="element" mode="tree"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	<xsl:template match="a" as="item()*">
		<a href="{@href}">
			<xsl:value-of select="." disable-output-escaping="no"/>
		</a>
	</xsl:template>
</xsl:stylesheet>