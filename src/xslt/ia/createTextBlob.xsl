<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:variable name="href" select="//mets:file[1]/mets:FLocat/@xlink:href"/>
    <xsl:variable name="id" select="substring-before(substring-after($href,'/media/'), '/')"/>

    <xsl:template match="/mets:fileGrp" as="item()*">
            <mets:dmdSec ID="IA1">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        <xsl:apply-templates select=".//mets:xmlData"/>
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
    </xsl:template>
    
    <xsl:template match="mets:xmlData" as="item()*">
        <xsl:apply-templates mode="blob" select="child::node()"/>
    </xsl:template>
    
    <xsl:template match="//*[local-name() = 'PAGECOLUMN']" mode="blob" as="item()*">
        <PAGECOLUMN n="{@n}" id="{$id}_{@n}" xmlns="http://www.loc.gov/djvu">
            <xsl:apply-templates mode="blob" select="child::node()"/>
        </PAGECOLUMN>
    </xsl:template>
    
    <xsl:template match="text()" mode="blob" as="item()*"><xsl:text disable-output-escaping="no"> </xsl:text><xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/></xsl:template>
</xsl:stylesheet>