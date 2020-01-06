<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" extension-element-prefixes="date" default-validation="strip" input-type-annotations="unspecified" xmlns:date="http://exslt.org/dates-and-times" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom">
    <xsl:output media-type="application/rss+xml" indent="yes" method="xml" encoding="UTF-8"/>
    <xsl:param name="category">
        <xsl:text disable-output-escaping="no">all</xsl:text>
    </xsl:param>
    <xsl:template match="/atom:feed" as="item()*">
        <xsl:element name="rss" inherit-namespaces="yes">
            <xsl:attribute name="version">
                <xsl:text disable-output-escaping="no">2.0</xsl:text>
            </xsl:attribute>
            <xsl:element name="channel" inherit-namespaces="yes">
                <xsl:element name="title" inherit-namespaces="yes">
                    <xsl:apply-templates select="atom:title"/>
                </xsl:element>
                <xsl:element name="link" inherit-namespaces="yes">
                    <xsl:apply-templates select="atom:link[@rel='alternate']/@href"/>
                </xsl:element>
                <xsl:element name="description" inherit-namespaces="yes">
                    <xsl:apply-templates select="atom:subtitle"/>
                </xsl:element>
                <xsl:element name="pubDate" inherit-namespaces="yes">
                    <xsl:call-template name="dateFormat">
                        <xsl:with-param name="toDateString" select="atom:updated"/>
                    </xsl:call-template>
                </xsl:element>
                <xsl:element name="language" inherit-namespaces="yes">
                    <xsl:apply-templates select="atom:entry[1]/atom:content/@xml:lang"/>
                </xsl:element>
                <xsl:element name="category" inherit-namespaces="yes">
                    <xsl:value-of select="$category" disable-output-escaping="no"/>
                </xsl:element>
                <xsl:element name="generator" inherit-namespaces="yes">
                    <xsl:apply-templates select="atom:generator"/>
                </xsl:element>
                <xsl:element name="managingEditor" inherit-namespaces="yes">
                    <xsl:apply-templates select="atom:author/atom:email"/>
                </xsl:element>
                <xsl:element name="webMaster" inherit-namespaces="yes">
                    <xsl:apply-templates select="atom:author/atom:email"/>
                </xsl:element>
                <xsl:for-each select="atom:entry">
                    <xsl:element name="item" inherit-namespaces="yes">
                        <xsl:element name="title" inherit-namespaces="yes">
                            <xsl:apply-templates select="atom:title"/>
                        </xsl:element>
                        <xsl:element name="link" inherit-namespaces="yes">
                            <xsl:apply-templates select="atom:link[@rel='alternate']/@href"/>
                        </xsl:element>
                        <xsl:element name="description" inherit-namespaces="yes">
                            <xsl:apply-templates select="atom:content/xhtml:div"/>
                        </xsl:element>
                        <xsl:element name="author" inherit-namespaces="yes">
                            <xsl:apply-templates select="atom:author/atom:email"/>
                        </xsl:element>
                        <xsl:for-each select="atom:category">
                            <xsl:element name="category" inherit-namespaces="yes">
                                <xsl:apply-templates select="@term"/>
                            </xsl:element>
                        </xsl:for-each>
                        <xsl:for-each select="atom:link[@rel='enclosure']">
                            <xsl:element name="enclosure" inherit-namespaces="yes">
                                <xsl:attribute name="url">
                                    <xsl:value-of select="@href" disable-output-escaping="no"/>
                                </xsl:attribute>
                                <xsl:attribute name="length">
                                    <xsl:value-of select="@length" disable-output-escaping="no"/>
                                </xsl:attribute>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="@type" disable-output-escaping="no"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:for-each>
                        <xsl:element name="pubDate" inherit-namespaces="yes">
                            <xsl:call-template name="dateFormat">
                                <xsl:with-param name="toDateString" select="atom:published"/>
                            </xsl:call-template>
                        </xsl:element>
                        <xsl:element name="guid" inherit-namespaces="yes">
                            <xsl:attribute name="isPermaLink">
                                <xsl:text disable-output-escaping="no">true</xsl:text>
                            </xsl:attribute>
                            <xsl:apply-templates select="atom:link[@rel='alternate']/@href"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xhtml:div" as="item()*">
        <xsl:apply-templates mode="escape" select="child::node()"/>
    </xsl:template>
    <xsl:template match="*" mode="escape" as="item()*">
        <xsl:text disable-output-escaping="no">&lt;</xsl:text>
        <xsl:value-of select="name()" disable-output-escaping="no"/>
        <xsl:apply-templates mode="escape" select="@*"/>
        <xsl:text disable-output-escaping="no">&gt;</xsl:text>
        <xsl:apply-templates mode="escape" select="child::node()"/>
        <xsl:text disable-output-escaping="no">&lt;/</xsl:text>
        <xsl:value-of select="name()" disable-output-escaping="no"/>
        <xsl:text disable-output-escaping="no">&gt;</xsl:text>
    </xsl:template>
    <xsl:template match="@*" mode="escape" as="item()*">
        <xsl:text disable-output-escaping="no"> </xsl:text>
        <xsl:value-of select="name()" disable-output-escaping="no"/>
        <xsl:text disable-output-escaping="no">="</xsl:text>
        <xsl:value-of select="." disable-output-escaping="no"/>
        <xsl:text disable-output-escaping="no">"</xsl:text>
    </xsl:template>
    <xsl:template name="dateFormat" as="item()*">
        <xsl:param name="toDateString"/>
        <xsl:value-of select="date:day-abbreviation($toDateString)" disable-output-escaping="no"/>
        <xsl:text disable-output-escaping="no">, </xsl:text>
        <xsl:value-of select="date:day-in-month($toDateString)" disable-output-escaping="no"/>
        <xsl:text disable-output-escaping="no"> </xsl:text>
        <xsl:value-of select="date:month-abbreviation($toDateString)" disable-output-escaping="no"/>
        <xsl:text disable-output-escaping="no"> </xsl:text>
        <xsl:value-of select="date:year($toDateString)" disable-output-escaping="no"/>
        <xsl:text disable-output-escaping="no"> </xsl:text>
        <xsl:value-of select="substring(date:time($toDateString), 1, 8)" disable-output-escaping="no"/>
        <xsl:text disable-output-escaping="no"> EST</xsl:text>
    </xsl:template>
</xsl:stylesheet>