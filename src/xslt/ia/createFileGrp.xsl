<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/mets:fileGrp" as="item()*">
            <mets:fileGrp USE="SERVICE">
                <xsl:apply-templates select="mets:file"/>
            </mets:fileGrp>
    </xsl:template>
    
    <xsl:template match="mets:file" as="item()*">
        <mets:file MIMETYPE="text/xml" GROUPID="{@GROUPID}" ID="{@ID}">
            <xsl:apply-templates select="mets:FLocat"/>
        </mets:file>
    </xsl:template>
    
    <xsl:template match="mets:FLocat" as="item()*">
        <mets:FLocat LOCTYPE="URL" xlink:href="{@xlink:href}"/>
    </xsl:template>
</xsl:stylesheet>