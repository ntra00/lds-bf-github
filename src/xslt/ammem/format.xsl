<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xsp xsp-request esql" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mets="http://www.loc.gov/METS/" xmlns:lc="http://www.loc.gov/mets/profiles" xmlns:xlink="http://www.w3.org/TR/xlink" xmlns:rights="http://www.loc.gov/rights/" xmlns:cd="http://www.loc.gov/mets/profiles/compactDisc" xmlns:natlib="http://www.loc.gov/natlib" xmlns:xsp="http://apache.org/xsp" xmlns:xspdoc="http://apache.org/cocoon/XSPDoc/v1" xmlns:esql="http://apache.org/cocoon/SQL/v2" xmlns:xsp-request="http://apache.org/xsp/request/2.0">

<!--
xmlns:xsp="http://apache.org/xsp" 
xmlns:xspdoc="http://apache.org/cocoon/XSPDoc/v1" 
xmlns:esql="http://apache.org/cocoon/SQL/v2" 
xmlns:xsp-request="http://apache.org/xsp/request/2.0"
-->


  <!-- these instructions do "tidy" for output tree -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>


  <!-- this is an identity transform (plus tidy) -->
  <!--
    <xsl:template match="/">
    <xsl:apply-templates select="mods:mods"/>
    </xsl:template>
    <xsl:template match="mods:mods">
    <xsl:copy-of select="."/>
    </xsl:template>
  -->


  <!-- this is also an identity transform (plus tidy) -->
  <!--
    <xsl:template match="@*|node()">
    <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    </xsl:template>
  -->


  <!-- this is also an identity transform for all nodes except @xsi:schemaLocation (plus tidy) -->

  <xsl:template match="@*|node()" as="item()*">
    <xsl:copy copy-namespaces="no" inherit-namespaces="yes">
      <xsl:apply-templates select="@* except @xsi:schemaLocation|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>