<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="tei" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://lcweb2.loc.gov/natlib/schemas/teixlite.dtd" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/1999/xhtml">
<!--Can we use item.xsl instead of this?, or use transcript instead, and if there's an item ID, get the specific one
also, if the transcript has a content node, use that, but failing that, use the text/href -->
	
	<xsl:import href="tei2HTML.xsl"/>
<!--input is local pageTurner output is xhtml-->
	<xsl:include href="utils.xsl"/> <!-- does this need to include the stuff moved to mods/metadata? -->	
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:param name="itemID"/>
	
	<xsl:template match="/" as="item()*">
<div id="ds-bibrecord">
			
			<h1 id="title-top"><xsl:value-of select="$sheet-title" disable-output-escaping="no"/></h1>


					<div id="main_body">
						<xsl:variable name="textDoc" select="document(pageTurner/paging/pages/transcript/text/@href)"/>
						<xsl:apply-templates select="$textDoc//tei:text"/>
<!--main_body--></div>
<!-- ds-bibrecord--> </div>

	</xsl:template>
</xsl:stylesheet>