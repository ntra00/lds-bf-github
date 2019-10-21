<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="mods" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text" indent="yes"/>
	<xsl:template match="/">
		<xsl:apply-templates select="mods:mods"/>
	</xsl:template>
	<xsl:template match="mods:mods">

		<xsl:apply-templates select="mods:titleInfo[1]"/>
	</xsl:template>
</xsl:stylesheet>