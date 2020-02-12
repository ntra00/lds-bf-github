<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:mets="http://www.loc.gov/METS/" xmlns:marcxml="http://www.loc.gov/MARC21/slim" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" xmlns:mxe="http://www.loc.gov/mxe" xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/">
	<xsl:template match="/">

		<rdf:RDF xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:mets="http://www.loc.gov/METS/"
		         xmlns:marcxml="http://www.loc.gov/MARC21/slim" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" xmlns:mxe="http://www.loc.gov/mxe" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/">
			<rdf:Description>
				<xsl:for-each select="rdf:RDF">

					<xsl:apply-templates mode="copy"/>
				</xsl:for-each>
			</rdf:Description>
		</rdf:RDF>
	</xsl:template>
	<xsl:template match="bf:Instance" mode="copy">
	<xsl:if test="not(parent::rdf:RDF)"><xsl:copy>
				<xsl:apply-templates select="@* | node()|text()" mode="copy"/>
			</xsl:copy>
			</xsl:if>
	</xsl:template>
	<!-- <xsl:template match="bf:Work[starts-with(@rdf:about,'http://example.org/') and ends-with(@rdf:about,'#Work')]" mode="copy"> -->
	<xsl:template match="bf:Work[contains(@rdf:about,'example.org') and '#Work' = substring(@rdf:about,string-length(@rdf:about)- 4)]" mode="copy">
		<xsl:variable name="workid">
			<xsl:value-of select="@rdf:about"/>
		</xsl:variable>
		<lclocal:graph>
			<xsl:copy>
				<xsl:apply-templates select="@* | node()|text()" mode="copy"/>
			</xsl:copy>
			<xsl:copy-of select="following-sibling::bf:Instance[bf:instanceOf/@rdf:resource=$workid]"/>
		</lclocal:graph>
		<!-- <xsl:apply-templates select="*[not(bf:Instance[bf:instanceOf/@rdf:resource=$workid])]"/> -->
	</xsl:template>
	<xsl:template match=" @* | node()" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()|text()" mode="copy"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="split_0000000.xml.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->
