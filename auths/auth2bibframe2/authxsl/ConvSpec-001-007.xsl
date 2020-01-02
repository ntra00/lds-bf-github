<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
                exclude-result-prefixes="xsl marc">

  <!--
      Conversion specs for 001-007
	  when 003 is updated for bibs (agent in source)  can go back to using this from xsl
  -->

  <xsl:template match="marc:controlfield[@tag='001']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
        <bf:identifiedBy>
          <bf:Local>
            <rdf:value><xsl:value-of select="."/></rdf:value>
          </bf:Local>
        </bf:identifiedBy>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:controlfield[@tag='003']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
      
          <bf:source>
            <bf:Source>
			
			<xsl:choose>
		  		<xsl:when test="starts-with(.,'DLC')">
					<xsl:attribute  name="rdf:about"><xsl:value-of select="concat($organizations,translate(.,concat($vUpper,'- ' ),$vLower))"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
            	<rdfs:label><xsl:value-of select="."/></rdfs:label>
				</xsl:otherwise>
			</xsl:choose>                          
			
            </bf:Source>
          </bf:source>
      
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:controlfield[@tag='005']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="changeDate" select="concat(substring(.,1,4),'-',substring(.,5,2),'-',substring(.,7,2),'T',substring(.,9,2),':',substring(.,11,2),':',substring(.,13,2))"/>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
        <bf:changeDate>
          <xsl:attribute name="rdf:datatype"><xsl:value-of select="$xs"/>dateTime</xsl:attribute>
          <xsl:value-of select="$changeDate"/>
        </bf:changeDate>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->