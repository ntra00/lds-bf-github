<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="mets xlink" default-validation="strip" input-type-annotations="unspecified" xmlns:mets="http://www.loc.gov/METS/" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:param name="behavior">default</xsl:param>
	<xsl:key name="file" match="mets:file" use="@ID"/>

	<xsl:template match="/mets:mets" as="item()*">
		<xsl:for-each select="mets:structMap/mets:div[@TYPE='pm:printMaterialObject']/mets:div[@TYPE='pm:transcription']/mets:fptr">
			<cinclude:include src="{key('file',@FILEID)/mets:FLocat/@xlink:href}"/>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>