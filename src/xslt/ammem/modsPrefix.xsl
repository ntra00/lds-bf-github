<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="*" as="item()*">
    <xsl:element name="mods:{local-name()}" inherit-namespaces="yes">
      <xsl:copy-of select="@* except (@xsi:schemaLocation)" copy-namespaces="yes"/>
      <xsl:apply-templates select="child::node()"/>
    </xsl:element>
  </xsl:template>


</xsl:stylesheet>