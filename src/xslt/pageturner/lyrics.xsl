<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="mets mods xlink" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/1999/xhtml">
	<!-- lyrics from tracks of cds or itmes in rec events need a related item ID like "DMD_..."  Lyrics in sheet music are for the whole thing -->
	<xsl:import href="lyricsTEI.xsl"/>

	<xsl:include href="utils.xsl"/>
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

	<xsl:key name="file" match="/compactDisc/mets:mets/mets:fileSec/mets:fileGrp/mets:file" use="@ID"/>
	<xsl:key name="id" match="*[@ID]" use="@ID"/>


	<xsl:variable name="item-title">
		<xsl:choose>
			<xsl:when test="contains($ID,'DMD')">
				<xsl:for-each select="//relatedItem[@ID=$ID]">
					<xsl:value-of select="element[@label='Title']" disable-output-escaping="no"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/pageTurner/descriptive/pagetitle" disable-output-escaping="no"/>
				<!--<xsl:value-of select="/pageTurner/descriptive/full/element[@label='Title']"/>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:template match="/" as="item()*">
<div id="ds-bibrecord">	
			<h1 id="title-top">  <xsl:value-of select="$item-title" disable-output-escaping="no"/>
	    </h1>

				<div id="main_menu_fixed">

					<div id="main_body">
						
						<xsl:if test="contains($ID,'DMD')">
							<h3>From:  <a href="default.html"> <xsl:value-of select="$title" disable-output-escaping="no"/></a></h3>
						</xsl:if>
						<xsl:variable name="fileName">
							<xsl:choose>
								<xsl:when test="contains($ID,'DMD')">
									<xsl:value-of select="//href[@behavior='lyrics'][contains(@parameters,$ID)]/@file" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="//href[@behavior='lyrics']/@file" disable-output-escaping="no"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						
						<xsl:variable name="textDoc" select="document($fileName)"/>
						<xsl:apply-templates select="$textDoc/tei:TEI.2/tei:text"/>						

					</div>
					<!--main_body-->
				</div>
				<!--main_menu-->
<!--end ds-bibrecord -->			</div>
	</xsl:template>
</xsl:stylesheet>