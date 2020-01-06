<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mets mods xlink" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>

	<xsl:param name="ip"/>
	<xsl:include href="utils.xsl"/>
	<xsl:variable name="viewable">
		<xsl:choose>
			<xsl:when test="starts-with($ip, '140.147') or not(contains(/pageTurner/descriptive/full/element[@label='RestrictionOnAccess' or @label='Access Condition'],'restricted') )">
				<xsl:text disable-output-escaping="no">yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="no">no</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/" as="item()*">
		<xsl:variable name="dbheader">
			<xsl:choose>
				<xsl:when test="contains(/pageTurner/descriptive/full/element[contains(@label,'Collection')]/value,'Chasanoff/Elozua')">The Chasanoff/Elozua Amazing Grace Collection <br/><span>A searchable catalog of more than 3000 published recordings of Amazing Grace</span></xsl:when>
				<xsl:when test="contains(/pageTurner/objectID,'afc9999005')">Traditional Music and Spoken Word Catalog <br/><span> from the American Folklife Center</span></xsl:when>
				<xsl:when test="contains(/pageTurner/descriptive/full/element[contains(@label,'Source')]/value,'Jazz on the Screen')">Jazz on the Screen <br/><span>A jazz and blues filmography by David Meeker</span></xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$dbheader!=''">
			<div id="page_head_search">
				<h1>
					<xsl:value-of select="$dbheader" disable-output-escaping="no"/>
				</h1>
			</div>
		</xsl:if>

		<div id="ds-bibrecord">

			<h1 id="title-top">
				<xsl:value-of select="$sheet-title" disable-output-escaping="no"/>
			</h1>
			<!--<xsl:call-template name="image"/> -->
			<xsl:if test="/pageTurner/descriptive/objectType='Bibliographic Record' and contains($ID, 'mrva')">
				<xsl:if test="$viewable='yes'">
					<a href="{//element[@label='Archived site']}">Archived Site</a>
				</xsl:if>
			</xsl:if>
			<!-- display metadata: -->
			<xsl:choose>
				<xsl:when test="$metsprofile='article' or $metsprofile='biography' or $metsprofile='patriotismSongCollection' or $metsprofile='songOfAmericaCollection'">
					<xsl:apply-templates select="/pageTurner/menu/whole/part/content/*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="//full"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="/descriptive/contains"/>
		</div>
		<!--bibrecord-->
	</xsl:template>
	<xsl:template match="a" as="item()*">
		<a href="{@href}">
			<xsl:value-of select="." disable-output-escaping="no"/>
		</a>
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
					<!-- <xsl:apply-templates select="element[not(@order='99')]"/> -->
					<xsl:apply-templates select="element" mode="tree"/>
				</ul>
			</li>
		</ul>
	</xsl:template>
</xsl:stylesheet>