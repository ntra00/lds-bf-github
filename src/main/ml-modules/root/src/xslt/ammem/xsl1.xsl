<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/" as="item()*">
    <xsl:apply-templates select="doc"/>
  </xsl:template>

  <xsl:template match="doc" as="item()*">
    <xsl:copy-of select="." copy-namespaces="yes"/>
  </xsl:template>


</xsl:stylesheet>