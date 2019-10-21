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

  <!--
      Conversion specs for 050-088
  -->
  <xsl:include href="../xsl/ConvSpec-050-088.xsl"/>

  <xsl:template match="marc:datafield[@tag='050']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work050a" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='050' or @tag='880']" mode="work050a">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:classification>
            <bf:ClassificationLcc>
              <xsl:if test="../@ind2 = '0'">
                <bf:source>
                  <bf:Source>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="concat($organizations,'dlc')"/></xsl:attribute>
                  </bf:Source>
                </bf:source>
              </xsl:if>
              <bf:classificationPortion>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </bf:classificationPortion>
              <xsl:if test="position() = 1">
                <xsl:for-each select="../marc:subfield[@code='b'][position()=1]">
                  <bf:itemPortion>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </bf:itemPortion>
                </xsl:for-each>
              </xsl:if>
			      <!-- auths only: -->
				  <xsl:for-each select="../marc:subfield[@code='d']">
				  <bflc:appliesTo><bflc:AppliesTo><rdfs:label><xsl:value-of select="."/></rdfs:label></bflc:AppliesTo></bflc:appliesTo>
				  </xsl:for-each>
				  <xsl:for-each select="../marc:subfield[@code='5']"><xsl:apply-templates select="." mode="subfield5auth"/></xsl:for-each>				  
           </bf:ClassificationLcc>
          </bf:classification>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='052']" mode="work"> <!-- use bib spec -->
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work052" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

 

  <xsl:template match="marc:datafield[@tag='060']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:classification>
          <bf:ClassificationNlm>
            <xsl:for-each select="marc:subfield[@code='a']">
              <bf:classificationPortion><xsl:value-of select="."/></bf:classificationPortion>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:itemPortion><xsl:value-of select="."/></bf:itemPortion>
            </xsl:for-each>
            <xsl:if test="@ind2 = '0'">
              <bf:source>
                <bf:Source>
                  <rdfs:label>National Library of Medicine</rdfs:label>
                </bf:Source>
              </bf:source>
            </xsl:if>
			   <!-- auths only: -->
				<xsl:for-each select="../marc:subfield[@code='d']">
				 <bflc:appliesTo><bflc:AppliesTo><rdfs:label><xsl:value-of select="."/></rdfs:label></bflc:AppliesTo></bflc:appliesTo>
				</xsl:for-each>
				<xsl:for-each select="../marc:subfield[@code='5']">
					<xsl:apply-templates select="." mode="subfield5"/>
				</xsl:for-each>
          </bf:ClassificationNlm>
        </bf:classification>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->