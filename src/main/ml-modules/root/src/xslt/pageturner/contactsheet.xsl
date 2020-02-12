<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xsi lp" extension-element-prefixes="xdmp" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xdmp="http://marklogic.com/xdmp" xmlns:lp="http://www.marklogic.com/ps/lib/l-param" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.w3.org/1999/xhtml">
<xsl:include href="utils.xsl"/>
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:variable name="params" select="lp:remove-digital-params($metsprofile)"/>
	<xsl:variable name="numCols">3</xsl:variable>
	<xsl:variable name="colWidth" select="round(100 div $numCols)"/>
	<xdmp:import-module namespace="http://www.marklogic.com/ps/lib/l-param" href="/nlc/lib/l-param.xqy"/>
	<xsl:template match="/" as="item()*">	<div id="ds-bibrecord">
		<xsl:apply-templates select="/pageTurner/pages | /pageTurner/object"/>
		</div>
	</xsl:template>

	<xsl:template match="pages|object" as="item()*">				
		<div id="ds-bibrecord">
			<h1 id="title-top">
				<xsl:value-of select="$sheet-title" disable-output-escaping="no"/>
			</h1>
			<div id="main_menu_fixed">
				<div id="main_body">
					<div class="select_enlarge">Select an image to enlarge:</div>
					<xsl:call-template name="headerfooter">
						<xsl:with-param name="pageCount" select="$pageCount"/>
					</xsl:call-template>
					<table id="contact_sheet_results" summary="Thumbnails from all pages of the item">
						<xsl:call-template name="make-rows"/>
					</table>
					<xsl:if test="$pageCount &gt;=4">
						<!-- more than one row, so add the footer -->
						<xsl:call-template name="headerfooter">
							<xsl:with-param name="pageCount" select="$pageCount"/>
						</xsl:call-template>
					</xsl:if>
				</div>
				<!--"main_menu_fixed"-->
			</div>
			<!--main-body-->
<!--bibrecord-->
		</div>
	
	</xsl:template>

	<xsl:template name="make-cells" as="item()*">
		<xsl:param name="pages"/>
		<xsl:param name="start"/>
		<xsl:param name="version"/>

		<xsl:for-each select="$pages">			
								
			<xsl:variable name="desired-params"><params xmlns="http://www.marklogic.com/ps/params">
				<param>
					<name>section</name>
					<value>
						<xsl:value-of select="$version" disable-output-escaping="no"/>
					</value>
				</param>
			</params></xsl:variable>																						
			<xsl:variable name="new-params" select="lp:param-string(lp:set-digital-params($params , 'pageturner', $metsprofile , $desired-params))"/>												
			
			<!--<href behavior="item" parameters="&amp;itemID={$thisItemID}" file="{$itemLink}">-->			
				
			<td width="{$colWidth}%" rowspan="1" colspan="1">
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">pageturner</xsl:with-param>
					<xsl:with-param name="params" select="$new-params"/>
					<xsl:with-param name="content">
						<xsl:call-template name="makeImageLink">
							<xsl:with-param name="URL" select="image/@href"/>
							<xsl:with-param name="alt" select="$pages/@label"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
				<!--
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">pageturner</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$start - 1 + position()"/><xsl:if test="$profile='photoObject'">&amp;section=<xsl:value-of select="$version"/></xsl:if></xsl:with-param>
					<xsl:with-param name="content">
						<xsl:call-template name="makeImageLink">
							<xsl:with-param name="URL" select="image/@href"/>
							<xsl:with-param name="alt" select="$pages/@label"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>-->
				<br clear="all"/>
				<span>
					<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
					<xsl:call-template name="behaviorLink">
						<xsl:with-param name="behavior">
							<xsl:choose>
								<xsl:when test="$profile='photoObject'">pageturner</xsl:when>
								<xsl:otherwise>enlarge</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="params">page=<xsl:value-of select="$start - 1 + position()" disable-output-escaping="no"/><xsl:if test="$profile='photoObject'">&amp;section=<xsl:value-of select="$version" disable-output-escaping="no"/></xsl:if></xsl:with-param>
						<xsl:with-param name="content">
							<xsl:choose>
								<xsl:when test="@label">
									<xsl:value-of select="@label" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:otherwise>page <xsl:value-of select="$start - 1 + position()" disable-output-escaping="no"/></xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</span>
			</td>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="make-rows" as="item()*">
		<xsl:param name="n" select="1"/>
		<xsl:choose>
			<xsl:when test="$n &gt; count(//page)"/>			
			<!-- photoObject -->
			<xsl:otherwise>
				<tr>
					<xsl:choose>
						<xsl:when test="$profile='photoObject' or ($profile='photoBatch' and version)">
							<xsl:for-each select="version">
								<xsl:call-template name="make-cells">
									<!--<xsl:with-param name="pages" select="page[position() &gt;= $n and position() &lt; $n + $numCols]"/>						-->
									<xsl:with-param name="pages" select="pages/page[1]"/>
									<xsl:with-param name="start" select="$n"/>
									<xsl:with-param name="version" select="@ID"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<!-- page images like sheet music -->
							<xsl:call-template name="make-cells">
								<xsl:with-param name="pages" select="page[position() &gt;= $n and position() &lt; $n + $numCols]"/>
								<xsl:with-param name="start" select="$n"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<!-- added // to page for photoObject -->
					<xsl:if test="not(//page[position() &gt;= $n + $numCols])">
						<xsl:call-template name="fill-row">
							<xsl:with-param name="num-empty" select="$numCols - count(//page) mod $numCols"/>
						</xsl:call-template>
					</xsl:if>
				</tr>
				<xsl:call-template name="make-rows">
					<xsl:with-param name="n" select="$n + $numCols"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="fill-row" as="item()*">
		<xsl:param name="num-empty"/>
		<xsl:choose>
			<xsl:when test="$num-empty = 0"/>
			<xsl:otherwise>
				<td width="{$colWidth}%" rowspan="1" colspan="1">
				</td>
				<xsl:call-template name="fill-row">
					<xsl:with-param name="num-empty" select="$num-empty - 1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="headerfooter" as="item()*">
		<xsl:param name="pageCount"/>
		<xsl:variable name="navigationLabel">
			<xsl:choose>
				<xsl:when test="//version">Versions</xsl:when>
				<xsl:when test="$profile='photoBatch'">Images</xsl:when>
				<xsl:otherwise>Pages</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="page_num">[ <xsl:value-of select="$navigationLabel" disable-output-escaping="no"/> 1 - <xsl:value-of select="$pageCount" disable-output-escaping="no"/> of <xsl:value-of select="$pageCount" disable-output-escaping="no"/>]</div>
	</xsl:template>
</xsl:stylesheet>