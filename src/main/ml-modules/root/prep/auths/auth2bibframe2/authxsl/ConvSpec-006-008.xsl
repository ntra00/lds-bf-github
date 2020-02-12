<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
                xmlns:local="local:"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl marc local">

  <!--
      Conversion specs for 006,008
      Modified from bibs; there is no 006, and 008 is radically simpler     
  -->

  <!-- Lookup tables -->
  
<!-- added for authorities -->
  <local:descriptionConventions>
    <a href="http://id.loc.gov/vocabulary/descriptionConventions/ala">ALA</a>
    <b href="http://id.loc.gov/vocabulary/descriptionConventions/aacr">AACR 1</b>
    <c href="http://id.loc.gov/vocabulary/descriptionConventions/aacr">AACR 2</c>
    <d href="http://id.loc.gov/vocabulary/descriptionConventions/aacr">AACR 2 compatible</d>
  </local:descriptionConventions>
  <local:issuance>           
    <a href="http://id.loc.gov/vocabulary/issuance/serl">Monographic series</a>
    <b href="http://id.loc.gov/vocabulary/issuance/mulm">Multipart item</b>    
    <c href="http://id.loc.gov/vocabulary/issuance/serl">Series-like phrase</c>    
    <n href="http://id.loc.gov/vocabulary/issuance/mono">Not applicable</n>
	<z href="http://id.loc.gov/vocabulary/issuance/mono">Other</z>
  </local:issuance>
  
  <xsl:template match="marc:controlfield[@tag='008']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="marcYear" select="substring(.,1,2)"/>
    <xsl:variable name="creationYear">
      <xsl:choose>
        <xsl:when test="$marcYear &lt; 50"><xsl:value-of select="concat('20',$marcYear)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat('19',$marcYear)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
        <bf:creationDate>
          <xsl:attribute name="rdf:datatype"><xsl:value-of select="$xs"/>date</xsl:attribute>
          <xsl:value-of select="concat($creationYear,'-',substring(.,3,2),'-',substring(.,5,2))"/>
        </bf:creationDate>
      </xsl:when>
    </xsl:choose>
    <!-- descriptionConventions -->
    <xsl:variable  name="descConv" select="substring(.,11,1)"/>
    <xsl:for-each select="document('')/*/local:descriptionConventions/*[name() = $descConv]">
      <xsl:choose>
        <xsl:when test="$serialization = 'rdfxml'">
          <bf:descriptionConventions>            
              <xsl:attribute name="rdf:resource"><xsl:value-of select="@href"/></xsl:attribute>
            <!--  <rdfs:label><xsl:value-of select="."/></rdfs:label>-->            
          </bf:descriptionConventions>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  <!--   <xsl:if test="$descConv = 'z' and ../marc:datafield[@tag='040']/marc:subfield[@code='e']">      
      <bf:descriptionConventions>
        <bf:DescriptionConventions>
          <rdfs:label>
            <xsl:value-of select="normalize-space(../marc:datafield[@tag='040']/marc:subfield[@code='e'])"/>
          </rdfs:label>
        </bf:DescriptionConventions>
      </bf:descriptionConventions>
    </xsl:if> -->
                  
  </xsl:template>
  <xsl:template match="marc:controlfield[@tag='008']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <!--auths -->
    <xsl:variable name="issuance">
       <xsl:choose> <!-- nac=mono -->
		<xsl:when test="substring(.,13,1) = ' '">c</xsl:when>
		<xsl:when test="substring(.,13,1) = '|'">c</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="substring(.,13,1)"/>     
    </xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">       
		<xsl:if test="$issuance != ''">				
		  <xsl:for-each select="document('')/*/local:issuance/*[name() = $issuance]">
          <bf:issuance>
            <bf:Issuance>
              <xsl:attribute name="rdf:about"><xsl:value-of select="@href"/></xsl:attribute>
            </bf:Issuance>
          </bf:issuance>
          </xsl:for-each>
        </xsl:if>
      </xsl:when>
    </xsl:choose>   
  </xsl:template>
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->