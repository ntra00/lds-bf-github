<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mets mods xlink" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

	<xsl:include href="utils.xsl"/>

	<xsl:template match="/pageTurner" as="item()*">
		<div id="ds-bibrecord">
			<h2><xsl:value-of select="$sheet-title" disable-output-escaping="no"/></h2>
			<p class="select_enlarge">Select a link below to view details and play recording:</p>
			<br/><xsl:copy-of select="." copy-namespaces="yes"/>
			<xsl:if test="descriptive/related/relatedItem[@type='constituent']">
				<ul>
	  <xsl:apply-templates select="descriptive/related/relatedItem[@type='constituent']"/>
	</ul>
			</xsl:if>			
			<!-- end ds-bibrecord--></div>

	</xsl:template>

	<xsl:template match="relatedItem[@type='constituent']" as="item()*">
		<xsl:variable name="track">
			<xsl:value-of select="@ID" disable-output-escaping="no"/>
		</xsl:variable>
		<xsl:variable name="program">
			<xsl:choose>
				<!-- <xsl:when test="relatedItem[@type='constituent']">track</xsl:when> -->
				<xsl:when test="/pageTurner//item[@id=$track]//subItem">track</xsl:when>
				<xsl:otherwise>item</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sheetNumber">
			<xsl:value-of select="element[@label='SheetNumber']/value" disable-output-escaping="no"/>
		</xsl:variable>
		<xsl:variable name="date">
			<xsl:value-of select="element[@label='Date Issued']/value" disable-output-escaping="no"/>
		</xsl:variable>
		<li>
			<a href="{$program}.html?itemID={$track}">
				<xsl:value-of select="concat(element[@label='Title']/value, ' ', $sheetNumber,' ',$date)" disable-output-escaping="no"/>
			</a>
			<xsl:if test="element[contains(@label,'Composer')]"> / <span class="mv-performers">
					<xsl:value-of select="element[contains(@label,'Composer')]" disable-output-escaping="no"/>
				</span></xsl:if>
			<xsl:if test="element[@label='Physical Description']">
				<span class="mv-timings"> (<xsl:value-of select="element[@label='Physical Description']" disable-output-escaping="no"/>)</span>
			</xsl:if>
			<xsl:for-each select="element[@label='Performer note']">
				<span class="mv-performers">
					<xsl:apply-templates select="child::node()"/>
				</span>
			</xsl:for-each>
			<xsl:if test="relatedItem[@type='constituent']">
				<ul>
					<xsl:for-each select="relatedItem[@type='constituent']">
						<xsl:variable name="itemID">
							<xsl:value-of select="@ID" disable-output-escaping="no"/>
						</xsl:variable>
						<xsl:variable name="metadata">
							<xsl:copy-of select="*" copy-namespaces="yes"/>
						</xsl:variable>
						<xsl:for-each select="/pageTurner/pages//*[@id=$itemID]">
							<!-- disc/page/audio or page/audio -->
							<xsl:call-template name="details">
								<xsl:with-param name="item" select="$itemID"/>
								<xsl:with-param name="metadata" select="$metadata"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:for-each>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>


	<xsl:template name="details" as="item()*">
		<xsl:param name="item"/>
		<xsl:param name="metadata"/>
		<xsl:variable name="copyrightRestricted">
			<xsl:choose>
				<xsl:when test="$metadata/element[@label='Standard restriction note']='This item is unavailable due to copyright restrictions.'">yes</xsl:when>

				<xsl:otherwise>no</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<li>
			<xsl:value-of select="$metadata/element[@label='Title']/value" disable-output-escaping="no"/>
			<xsl:choose>
				<!-- select icon based on type of item -->
				<xsl:when test="local-name()='video' and $copyrightRestricted='no'">
					<strong class="blue">»</strong>
				</xsl:when>
				<xsl:when test="local-name()='audio' and $copyrightRestricted='no'">
					<img src="../html/images/audio.gif" alt="" width="16" height="16"/>
				</xsl:when>
			</xsl:choose> <xsl:if test="$metadata/element[contains(@label,'Composer')]"> / <p>
					<span class="mv-performers">
						<xsl:value-of select="normalize-space($metadata/element[contains(@label,'Composer')])" disable-output-escaping="no"/>
					</span>
				</p></xsl:if><xsl:if test="$metadata/element[@label='Physical Description']"><span class="mv-timings"> (<xsl:value-of select="normalize-space($metadata/element[@label='Physical Description'])" disable-output-escaping="no"/>)</span></xsl:if><br/><xsl:if test="$metadata/element[@label='Standard restriction note']='This item is unavailable due to copyright restrictions.'">    <strong>Copyright restricted.</strong></xsl:if></li>
	</xsl:template>
</xsl:stylesheet>