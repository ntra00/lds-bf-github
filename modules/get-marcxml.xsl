<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:mets="http://www.loc.gov/METS/" xmlns:marcxml="http://www.loc.gov/MARC21/slim" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" xmlns:mxe="http://www.loc.gov/mxe" xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/" exclude-result-prefixes="mets">
	<xsl:template match="/">
		<marcxml:collection xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"  xmlns:mets="http://www.loc.gov/METS/"
		                    xmlns:marcxml="http://www.loc.gov/MARC21/slim">

			<xsl:copy-of select="//marcxml:record"/>
		</marcxml:collection>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->