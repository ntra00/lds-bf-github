<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="href" select="//mets:file[1]/mets:FLocat/@xlink:href"/>
    <xsl:variable name="id" select="substring-before(substring-after($href,'/media/'), '/')"/>
    
    <xsl:template match="/mets:fileGrp" as="item()*">
            <DjVuXMLSet xmlns="http://www.loc.gov/djvu">
                <xsl:apply-templates mode="coords" select="child::node()"/>
            </DjVuXMLSet>
    </xsl:template>

    <xsl:template match="//*[local-name() = 'PAGECOLUMN']" mode="coords" as="item()*">
        <PAGECOLUMN n="{@n}" id="{ancestor::mets:file/@GROUPID}_{ancestor::mets:file/@ID}" id1="{$id}_{@n}" xmlns="http://www.loc.gov/djvu">
            <xsl:apply-templates mode="coords" select="child::node()"/>
        </PAGECOLUMN>
    </xsl:template>
    
    <xsl:template match="//*[local-name() = 'WORD']" mode="coords" as="item()*">
        <xsl:variable name="newline">
            <xsl:text disable-output-escaping="no">
            </xsl:text>
        </xsl:variable>
        <WORD xmlns="http://www.loc.gov/djvu">
            <xsl:value-of select="." disable-output-escaping="no"/>
            <xsl:value-of select="$newline" disable-output-escaping="no"/>
            <noindex xmlns="info:lc/xq-modules/noindex">
                <x><xsl:value-of select="@x" disable-output-escaping="no"/></x>
                <y><xsl:value-of select="@y" disable-output-escaping="no"/></y>
                <width><xsl:value-of select="@width" disable-output-escaping="no"/></width>
                <height><xsl:value-of select="@height" disable-output-escaping="no"/></height>
                <!--<x><xsl:value-of select="substring(@x,1,8)"/></x>
                    <y><xsl:value-of select="substring(@y,1,8)"/></y>
                    <width><xsl:value-of select="substring(@width1,8)"/></width>
                    <height><xsl:value-of select="substring(@height,1,8)"/></height>-->
            </noindex>
            <!--<xsl:value-of select="$newline"/>-->
        </WORD>
    </xsl:template>
</xsl:stylesheet>