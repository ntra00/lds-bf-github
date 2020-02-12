<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mets xlink" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="local">
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<!-- input is mets, output is local -->
	<xsl:key name="file" match="/mets:mets/mets:fileSec/mets:fileGrp/mets:file" use="@ID"/>

	<xsl:template match="/">
		<pages>
			<!--<xsl:apply-templates select="mets:mets/mets:structMap/mets:div[@TYPE='bib:modsBibRecord']/mets:div[contains(@TYPE,'card') or contains(@TYPE,'illustration')]/mets:div[contains(@TYPE,'image')]"/>-->
			<xsl:apply-templates select="mets:mets/mets:structMap//mets:div[contains(@TYPE,'card') or contains(@TYPE,'illustration')]/mets:div[contains(@TYPE,'image')]"/>			
			<xsl:apply-templates select="mets:mets/mets:structMap//mets:div[@TYPE='pdf:pdfDoc']"/>
		</pages>
	</xsl:template>
	
	<xsl:template match="mets:div[@TYPE!='pdf:pdfDoc'][mets:fptr]">
		<page>
			<image href="{key('file',mets:fptr[2]/@FILEID)/mets:FLocat/@xlink:href}"/>
		</page>
	</xsl:template>
	<xsl:template match="mets:div[@TYPE='pdf:pdfDoc']"><!--first fptr link is pdf, second is illustrative image-->
		<page>
			<image href="{key('file',mets:fptr[2]/@FILEID)/mets:FLocat/@xlink:href}"/>
		</page>
	</xsl:template>
</xsl:stylesheet>
