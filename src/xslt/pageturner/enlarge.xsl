<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xsi" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<!--input is local pageTurner output is xhtml-->
	<xsl:include href="utils.xsl"/>	
	
	<xsl:variable name="pages" select="$pageCount"/>
	<xsl:variable name="thisSize"><xsl:choose>
		<xsl:when test="$size=''">640</xsl:when>		
		<xsl:otherwise><xsl:value-of select="$size" disable-output-escaping="no"/></xsl:otherwise>
	</xsl:choose></xsl:variable>
	
	
	<xsl:template match="/" as="item()*">
		<xsl:choose>
			<xsl:when test="$section!='' and $profile='score'">
				<xsl:apply-templates select="pageTurner//pages/page[position()=$pageNum]"/>
			</xsl:when>
			<xsl:when test="$section!=''  and $profile='photoObject'">
				<xsl:apply-templates select="pageTurner//pages/version[@ID=$section]/pages/page[position()=$pageNum]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="pageTurner//pages/page[position()=$pageNum]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="page" as="item()*">
		<xsl:variable name="dbheader">
			<xsl:choose>
				<xsl:when test="contains(/pageTurner/descriptive/full/element[contains(@label,'Collection')]/value,'Chasanoff/Elozua')">The Chasanoff/Elozua Amazing Grace Collection <br/><span>A searchable catalog of more than 3000 published recordings of Amazing Grace</span></xsl:when>
				<xsl:when test="contains(image/@href,'afc9999005')">Traditional Music and Spoken Word Catalog <br/><span> from the American Folklife Center</span>	</xsl:when>
				<xsl:when test="contains(/pageTurner/descriptive/full/element[contains(@label,'Source')]/value,'Jazz on the Screen')">Jazz on the Screen <br/><span>A jazz and blues filmography by David Meeker</span></xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$dbheader!=''">
			<div id="page_head_search">
				<h1><xsl:value-of select="$dbheader" disable-output-escaping="no"/></h1>
			</div>
		</xsl:if>
	

								
		<div id="ds-bibrecord">
			
			<h1 id="title-top">
				<xsl:choose>
					<xsl:when test="$profile='photoBatch' and @label!=''"><xsl:value-of select="@label" disable-output-escaping="no"/></xsl:when>
					<xsl:when test="$profile='photoBatch'">Image <xsl:value-of select="$pageNum" disable-output-escaping="no"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$sheet-title" disable-output-escaping="no"/></xsl:otherwise>
				</xsl:choose>
			</h1>
			<div class="main_nav2_top">
				<xsl:call-template name="navbar">
					<xsl:with-param name="position">1</xsl:with-param>
					<xsl:with-param name="pageCount">
						<xsl:value-of select="$pageCount" disable-output-escaping="no"/>
					</xsl:with-param>
				</xsl:call-template>
			</div>
			
			<a href="enlarge.html?page={$page}&amp;section={$section}&amp;size=1024&amp;from={$from}">
				<xsl:call-template name="makeImageLink">
					<xsl:with-param name="URL" select="image/@href"/>
					<xsl:with-param name="width" select="$thisSize"/>
				</xsl:call-template>
			</a>
			<br clear="all"/>
			<div class="main_nav2_top search_nav_bot">
				<xsl:call-template name="navbar">
					<xsl:with-param name="position">2</xsl:with-param>
					<xsl:with-param name="pageCount">
						<xsl:value-of select="$pageCount" disable-output-escaping="no"/>
					</xsl:with-param>
				</xsl:call-template>
			</div>
		</div>
						
	</xsl:template>
</xsl:stylesheet>