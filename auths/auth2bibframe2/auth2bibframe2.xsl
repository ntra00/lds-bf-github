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
<!-- Changes :
						2017-08-31 	:	fixed 1xx names to look only before $t
	-->
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>
 
  <xsl:param name="baseuri" select="'http://id.loc.gov/resources/works/'"/>
  <xsl:param name="idfield" select="'001'"/>
  <xsl:param name="serialization" select="'rdfxml'"/>
  <xsl:variable name="vUpper" select= "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="vLower" select= "'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="vAlpha" select="concat($vUpper, $vLower)"/>
  <xsl:variable name="vDigits" select= "'0123456789'"/>

  
	<xsl:include href="xsl/utils.xsl"/>
	<xsl:include href="xsl/ConvSpec-ControlSubfields.xsl"/>
	<xsl:include href="authxsl/ConvSpec-LDR.xsl"/>
	<!--007 is not in auths; ok to run this from bibs; no other changes
		  when 003 is updated for bibs (agent in source)  can go back to using this from xsl
		  -->
	<xsl:include href="authxsl/ConvSpec-001-007.xsl"/>
	<xsl:include href="authxsl/ConvSpec-006-008.xsl"/>
	<xsl:include href="authxsl/ConvSpec-010-048.xsl"/>
	<xsl:include href="authxsl/ConvSpec-050-088.xsl"/>
	<xsl:include href="authxsl/ConvSpec-1XX,6XX,7XX,8XX-names.xsl"/>
	<!-- none in nametitle auths:  -->
	<!-- <xsl:include href="xsl/ConvSpec-200-247not240-Titles.xsl"/> -->
	<!-- 430s not included in bibs, so use auth -->
	<xsl:include href="authxsl/ConvSpec-240andX30-UnifTitle.xsl"/>
	<!-- none in nametitle auths:  -->
	<!-- <xsl:include href="xsl/ConvSpec-250-270.xsl"/> -->
	
	<xsl:include href="authxsl/ConvSpec-3XX.xsl"/>
	<!-- na in auths -->
	<!-- <xsl:include href="xsl/ConvSpec-490-510-530to535-Links.xsl"/> -->
	<!-- handled with 4xx -->
	<!-- <xsl:include href="xsl/ConvSpec-5XX.xsl"/> -->
	
	<!-- auths is different for 6xx -->
	<!-- <xsl:include href="xsl/ConvSpec-648-662.xsl"/> -->
	<xsl:include href="authxsl/ConvSpec-640-675.xsl"/>
	<!-- na in auths -->
	<!-- <xsl:include href="xsl/ConvSpec-720+740to755.xsl"/>
	<xsl:include href="xsl/ConvSpec-760-788-Links.xsl"/>
	<xsl:include href="xsl/ConvSpec-841-887.xsl"/>
	 -->
	<xsl:include href="xsl/ConvSpec-880.xsl"/>
	<!-- auths only: -->
	<xsl:include href="authxsl/unmatched.xsl"/>


	<!-- namespace URIs -->
	<xsl:variable name="bf">http://id.loc.gov/ontologies/bibframe/</xsl:variable>
	<xsl:variable name="bflc">http://id.loc.gov/ontologies/bflc/</xsl:variable>
	<xsl:variable name="edtf">http://id.loc.gov/datatypes/</xsl:variable>
	<xsl:variable name="madsrdf">http://www.loc.gov/mads/rdf/v1#</xsl:variable>
	<xsl:variable name="xs">http://www.w3.org/2001/XMLSchema#</xsl:variable>

	<!-- id.loc.gov vocabulary stems -->
	<xsl:variable name="carriers">http://id.loc.gov/vocabulary/carriers/</xsl:variable>
	<xsl:variable name="classSchemes">http://id.loc.gov/vocabulary/classSchemes/</xsl:variable>
	
	<xsl:variable name="contentType">http://id.loc.gov/vocabulary/contentType/</xsl:variable>
	<xsl:variable name="countries">http://id.loc.gov/vocabulary/countries/</xsl:variable>
	<xsl:variable name="demographicTerms">http://id.loc.gov/authorities/demographicTerms/</xsl:variable>
	<xsl:variable name="descriptionConventions">http://id.loc.gov/vocabulary/descriptionConventions/</xsl:variable>
	<xsl:variable name="genreForms">http://id.loc.gov/authorities/genreForms/</xsl:variable>
	<xsl:variable name="geographicAreas">http://id.loc.gov/vocabulary/geographicAreas/</xsl:variable>
	<xsl:variable name="graphicMaterials">http://id.loc.gov/vocabulary/graphicMaterials/</xsl:variable>
	<xsl:variable name="issuance">http://id.loc.gov/vocabulary/issuance/</xsl:variable>
	<xsl:variable name="languages">http://id.loc.gov/vocabulary/languages/</xsl:variable>
	<xsl:variable name="marcgt">http://id.loc.gov/vocabulary/marcgt/</xsl:variable>
	<xsl:variable name="mcolor">http://id.loc.gov/vocabulary/mcolor/</xsl:variable>
	<xsl:variable name="mediaType">http://id.loc.gov/vocabulary/mediaType/</xsl:variable>
	<xsl:variable name="mmaterial">http://id.loc.gov/vocabulary/mmaterial/</xsl:variable>
	<xsl:variable name="mplayback">http://id.loc.gov/vocabulary/mplayback/</xsl:variable>
	<xsl:variable name="mpolarity">http://id.loc.gov/vocabulary/mpolarity/</xsl:variable>
	<xsl:variable name="marcauthen">http://id.loc.gov/vocabulary/marcauthen/</xsl:variable>
	<xsl:variable name="marcmuscomp">http://id.loc.gov/vocabulary/marcmuscomp/</xsl:variable>
	<xsl:variable name="organizations">http://id.loc.gov/vocabulary/organizations/</xsl:variable>
	<xsl:variable name="relators">http://id.loc.gov/vocabulary/relators/</xsl:variable>
	<xsl:variable name="mproduction">http://id.loc.gov/vocabulary/mproduction/</xsl:variable>
    <xsl:variable name="msoundcontent">http://id.loc.gov/vocabulary/msoundcontent/</xsl:variable>
    <xsl:variable name="mrecmedium">http://id.loc.gov/vocabulary/mrecmedium/</xsl:variable>
    <xsl:variable name="mgeneration">http://id.loc.gov/vocabulary/mgeneration/</xsl:variable>
    <xsl:variable name="mpresformat">http://id.loc.gov/vocabulary/mpresformat/</xsl:variable>
    <xsl:variable name="mmaspect">http://id.loc.gov/vocabulary/maspect/</xsl:variable>
    <xsl:variable name="mrectype">http://id.loc.gov/vocabulary/mrectype/</xsl:variable>
    <xsl:variable name="mspecplayback">http://id.loc.gov/vocabulary/mspecplayback/</xsl:variable>
    <xsl:variable name="mgroove">http://id.loc.gov/vocabulary/mgroove/</xsl:variable>
    <xsl:variable name="mvidformat">http://id.loc.gov/vocabulary/mvidformat/</xsl:variable>
    <xsl:variable name="mbroadstd">http://id.loc.gov/vocabulary/mbroadstd/</xsl:variable>
    <xsl:variable name="mfiletype">http://id.loc.gov/vocabulary/mfiletype/</xsl:variable>
    <xsl:variable name="mregencoding">http://id.loc.gov/vocabulary/mregencoding/</xsl:variable>
    <xsl:variable name="mmusicformat">http://id.loc.gov/vocabulary/mmusicformat/</xsl:variable>
  
	<xsl:variable name="genreFormSchemes">http://id.loc.gov/vocabulary/genreFormSchemes/</xsl:variable>
    <xsl:variable name="subjectSchemes">http://id.loc.gov/vocabulary/subjectSchemes/</xsl:variable>

  <!-- for upper- and lower-case translation (ASCII only) -->
  <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
	<!-- configuration files -->

	<!-- subject thesaurus map -->
	<xsl:variable name="subjectThesaurus" select="document('xsl/conf/subjectThesaurus.xml')"/>

	<!-- language map -->
	<xsl:variable name="languageMap" select="document('xsl/conf/languageCrosswalk.xml')"/>

	<!-- auths only , 1xx name label for matching against 4xx, 5xx sees -->
	<xsl:variable name="primaryNameLabel"><xsl:apply-templates select="//marc:datafield[@tag='100' or @tag='110' or @tag='111'][1]" mode="tNameLabel"></xsl:apply-templates></xsl:variable>
	 	<xsl:variable name="last-edit">2019-12-18T13:00</xsl:variable>
	 
	<xsl:template match="/">

		<!-- RDF/XML document frame -->
		<xsl:choose>
			<xsl:when test="$serialization='rdfxml'">
				<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" 
						xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
				         xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#">
					<xsl:apply-templates select="//marc:record">
						<xsl:with-param name="serialization" select="$serialization"/>
					</xsl:apply-templates>
				</rdf:RDF>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="marc:collection">
		<xsl:param name="serialization"/>

		<!-- pass marc:record nodes on down -->
		<xsl:apply-templates>
			<xsl:with-param name="serialization" select="$serialization"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="marc:record[@type='Bibliographic' or not(@type)]">
		<xsl:param name="serialization"/>

		<xsl:variable name="recordno">
			<xsl:value-of select="position()"/>
		</xsl:variable>

		<xsl:variable name="recordid">
			<xsl:apply-templates mode="recordid" select=".">
				<xsl:with-param name="baseuri" select="$baseuri"/>
				<xsl:with-param name="idfield" select="$idfield"/>
				<xsl:with-param name="recordno" select="$recordno"/>
			</xsl:apply-templates>
		</xsl:variable>

		<!-- generate main Work entity -->	
		
		<xsl:choose>
			<xsl:when test="$serialization = 'rdfxml' ">
				<bf:Work>
					<xsl:attribute name="rdf:about"><xsl:value-of select="translate($recordid,' ','')"/>#Work</xsl:attribute>					
					<!-- pass fields through conversion specs for Work properties 
					except 400? -->
					<!-- lccns in 001 have spaces; fix with translate -->
					   <xsl:apply-templates mode="work">
            <xsl:with-param name="recordid" select="translate($recordid,' ','')"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>										
					<bf:adminMetadata>
						<bf:AdminMetadata>
							<!-- pass fields through conversion specs for AdminMetadata properties -->
							<xsl:apply-templates mode="adminmetadata">
								<xsl:with-param name="serialization" select="$serialization"/>
							</xsl:apply-templates>
							<bf:generationProcess ><bf:GenerationProcess><rdfs:label>							
								<xsl:value-of select="concat('DLC MAuth2BF transform-tool: ' ,$last-edit)"/>
								</rdfs:label>
								</bf:GenerationProcess>
							</bf:generationProcess>														                         
						</bf:AdminMetadata>
					</bf:adminMetadata>
				</bf:Work>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<!-- suppress text from unmatched nodes 
		-->
	<xsl:template match="text()" mode="adminmetadata"/>
	<xsl:template match="text()" mode="work"/>
	<xsl:template match="text()" mode="instance"/>
	<xsl:template match="text()" mode="hasItem"/>

	<!-- warn about other elements
    use authxsl/unmatched.xsl  -->
 <xsl:template match="*">

    <xsl:message terminate="no">
      <xsl:text>WARNING: Unmatched element: </xsl:text><xsl:value-of select="name()"/>
    </xsl:message>

<!--  nate removed   <xsl:apply-templates/> -->

  </xsl:template>
<!-- 
	<xsl:template match="*"><bflc:test>test</bflc:test>
    <xsl:message terminate="no">
      <xsl:text>WARNING: Unmatched element: </xsl:text><xsl:value-of select="name()"/>
    </xsl:message>
    <xsl:apply-templates/>
  </xsl:template>
 -->
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="file:///z:/My Documents/marcxml.xml" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->