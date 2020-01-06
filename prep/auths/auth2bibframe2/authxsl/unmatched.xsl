<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl marc">

  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>
  <!-- warn about other elements -->
  <xsl:template match="*">
<xsl:variable name="marcfield"><xsl:apply-templates mode="marcKey"/></xsl:variable>
    <xsl:message terminate="no">
      <bflc:missingConversionSpec>
 			<xsl:value-of select="concat(@tag,@ind1,@ind2, $marcfield)"/>
	  </bflc:missingConversionSpec>
	  <xsl:text>WARNING: Unmatched element: </xsl:text><xsl:value-of select="name()"/><xsl:value-of select="concat(@tag,@ind1,@ind2, $marcfield)"/>
    </xsl:message>

    <!-- <xsl:apply-templates select="."/> -->

  </xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->