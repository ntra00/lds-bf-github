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
      Conversion specs for 640 to 675 (641 is glommed onto 642)
  -->

  <xsl:template match="marc:datafield[@tag='640' or @tag='641' or  @tag='642'  or @tag='643'  or @tag='644'   or @tag='645'   or @tag='646']" mode="work">    
    <xsl:param name="serialization" select="'rdfxml'"/>
	<xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
	  
    <xsl:variable name="seriesClass">
      <xsl:choose>
        <xsl:when test="@tag='640'">bflc:SeriesSequentialDesignation</xsl:when>        
		<xsl:when test="@tag='641'">bflc:SeriesNumberingPeculiarities</xsl:when>        
        <xsl:when test="@tag='642'">bflc:SeriesNumbering</xsl:when>
		<xsl:when test="@tag='643'">bflc:SeriesProvider</xsl:when>
		<xsl:when test="@tag='644'">bflc:SeriesAnalysis</xsl:when>
		<xsl:when test="@tag='645'">bflc:SeriesTracing</xsl:when>
        <xsl:when test="@tag='646'">bflc:SeriesClassification</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="seriesLabel">
      <xsl:choose>
        <xsl:when test="@tag='640'"><xsl:value-of select="marc:subfield[@code='a']"/> <xsl:if test="marc:subfield[@code='z']"> (<xsl:value-of select="marc:subfield[@code='z']"/>)</xsl:if></xsl:when>		
        <xsl:when test="@tag='641'"><xsl:value-of select="marc:subfield[@code='a']"/> <xsl:if test="marc:subfield[@code='z']"> (<xsl:value-of select="marc:subfield[@code='z']"/>)</xsl:if>	</xsl:when>		
		<xsl:when test="@tag='642'"><xsl:value-of select="marc:subfield[@code='a']"/> <xsl:if test="marc:subfield[@code='d']"> (<xsl:value-of select="marc:subfield[@code='d']"/>)</xsl:if>					</xsl:when>		
		<xsl:when test="@tag='643'"><xsl:value-of select="marc:subfield[@code='a']"/> <xsl:if test="marc:subfield[@code='b']">; <xsl:value-of select="marc:subfield[@code='b']"/> </xsl:if>  <xsl:if test="marc:subfield[@code='d']">; <xsl:value-of select="marc:subfield[@code='d']"/> </xsl:if></xsl:when>
		<xsl:when test="@tag='644'">
			<xsl:choose> 
				<xsl:when test="marc:subfield[@code='a']='f'">Full </xsl:when>
				<xsl:when test="marc:subfield[@code='a']='p'">Part </xsl:when>
				<xsl:when test="marc:subfield[@code='a']='n'">Not </xsl:when>		
			</xsl:choose>
			<xsl:if test="marc:subfield[@code='b']">; Exceptions:  <xsl:value-of select="marc:subfield[@code='b']"/> </xsl:if> 
			 <xsl:if test="marc:subfield[@code='d']"> (<xsl:value-of select="marc:subfield[@code='d']"/>) </xsl:if>
		</xsl:when>
		<xsl:when test="@tag='645'">
			<xsl:choose> 
				<xsl:when test="marc:subfield[@code='a']='t' ">Traced </xsl:when>				
				<xsl:when test="marc:subfield[@code='a']='n'">Not </xsl:when>		
			</xsl:choose>
		 	<xsl:if test="marc:subfield[@code='d']"> (<xsl:value-of select="marc:subfield[@code='d']"/>) </xsl:if>
		 </xsl:when>
		<xsl:when test="@tag='646'">
		<xsl:choose> 
				<xsl:when test="marc:subfield[@code='a']='c' ">Collection </xsl:when>				
				<xsl:when test="marc:subfield[@code='a']='m'">With main </xsl:when>		
				<xsl:when test="marc:subfield[@code='a']='s'">Separately </xsl:when>		
			</xsl:choose>
			 <xsl:if test="marc:subfield[@code='d']"> (<xsl:value-of select="marc:subfield[@code='d']"/>) </xsl:if></xsl:when>        
      </xsl:choose>
    </xsl:variable>
	<bflc:seriesTreatment>
		<xsl:element name="{$seriesClass}">
			<rdfs:label>
				<xsl:if test="$vXmlLang != ''">
                	<xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              	</xsl:if>
			  <xsl:value-of select="$seriesLabel"/></rdfs:label>
				<xsl:apply-templates mode="subfield5auth" select="marc:subfield[@code='5']">
            	  <xsl:with-param name="serialization" select="$serialization"/>
            	</xsl:apply-templates>
		</xsl:element>
	</bflc:seriesTreatment>
 </xsl:template>
  <xsl:template match="marc:datafield[@tag='667']" mode="work">    
    <xsl:param name="serialization" select="'rdfxml'"/>
	<xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>	  
		<bf:note><bf:Note>		
			<rdfs:label>
				<xsl:if test="$vXmlLang != ''">
                	<xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              	</xsl:if>
			  <xsl:value-of select="marc:subfield[@code='a']"/></rdfs:label>
				<bf:status>nonpublic</bf:status>
			</bf:Note>
		</bf:note>
	
 	</xsl:template>
    <xsl:template match="marc:datafield[@tag='670' or @tag='675']" mode="adminmetadata">
	<!-- issues: $u couild be a uri, not a string. could all be in one big note?? -->
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if  test="marc:subfield[@code='a' or @code='b'  or @code='u' or @code='w' ]">		
          <bf:note>
            <bf:Note> 
  				 <xsl:choose>
					<xsl:when test="@tag='670' ">   	<bf:noteType>Data source</bf:noteType></xsl:when>
					<xsl:when test="@tag='675' ">   	<bf:noteType>Data not found</bf:noteType></xsl:when>
				</xsl:choose>				 
              	<rdfs:label>   <xsl:apply-templates mode="concat-nodes-space"  select="marc:subfield"  /></rdfs:label>
            	</bf:Note>
			</bf:note>
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