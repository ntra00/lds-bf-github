<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/" xmlns:rel="http://id.loc.gov/vocabulary/relators" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" exclude-result-prefixes="xsl bf rdf rdfs bflc xs"
                extension-element-prefixes="rdf rdfs bf bflc rel" xmlns:local="local" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<!-- default-validation="strip" xmlns:xdmp="http://marklogic.com/xdmp" 
	input-type-annotations="unspecified"-->
	<xsl:variable name="UPPER">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

	<xsl:variable name="lower">abcdefghijklmnopqrstuvwxy</xsl:variable>
	<xsl:variable name="punc">.;,-%#@()+_:?/\`&amp;'"</xsl:variable>
	<xsl:template match="/">

		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
		

		<!-- <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
		         xmlns:rel="http://id.loc.gov/vocabulary/relators" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#">
			<xsl:fallback>
				<xsl:apply-templates select="*"/>
			</xsl:fallback> -->
		<!-- <xsl:apply-templates select="rdf:RDF/*"> 
		
			</xsl:apply-templates>-->
	</xsl:template>
	<xsl:template name="text-node">
		<xsl:param name="elname"/>
		<xsl:param name="literal"/>
		<xsl:element name="{$elname}">
			<xsl:value-of select="$literal"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="resource-node">
		<xsl:param name="elname"/>
		<xsl:param name="resource-url"/>
		<xsl:element name="{$elname}">
			<xsl:attribute name="rdf:resource">
				<xsl:value-of select="$resource-url"/>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>
	<xsl:template name="flip-about">
		<xsl:param name="node"/>
		<xsl:for-each select="$node">
			<xsl:copy>
				<xsl:attribute name="rdf:resource">
					<xsl:value-of select="*[1]/@rdf:about"/>
				</xsl:attribute>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="cleanOrgCode">
		<xsl:param name="code-string"/>
		<xsl:variable name="code" select="translate($code-string, $UPPER,$lower)"/>
		<xsl:value-of select="translate($code, $punc,'')"/>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="bf:title">
		<xsl:call-template name="text-node">
			<xsl:with-param name="elname">bflc:title</xsl:with-param>
			<xsl:with-param name="literal" select="bf:Title/rdfs:label"/>
		</xsl:call-template>
		<!-- <xsl:element name="bflc:title">
			<xsl:value-of select="bf:Title/rdfs:label"/>
		</xsl:element> -->
	</xsl:template>

	<xsl:template match="bf:classification">
		<xsl:choose>
			<xsl:when test="bf:ClassificationLcc">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:classification</xsl:with-param>
					<xsl:with-param name="resource-url" select="concat('http://id.loc.gov/authorities/classification/',bf:ClassificationLcc/bf:classificationPortion)"/>
				</xsl:call-template>
				<!-- <xsl:element name="bf:classification">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat('http://id.loc.gov/authorities/classification/',bf:ClassificationLcc/bf:classificationPortion)"/>
					</xsl:attribute>
				</xsl:element> -->
			</xsl:when>
			<xsl:when test="bf:ClassificationDdc">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:classification</xsl:with-param>
					<xsl:with-param name="resource-url" select="concat('http://tmpdewey.info/class/',bf:ClassificationDdc/bf:classificationPortion)"/>
				</xsl:call-template>
				<!-- <xsl:element name="bf:classification">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="concat('http://dewey.info/class/',bf:ClassificationDdc/bf:classificationPortion)"/>
					</xsl:attribute>
				</xsl:element> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:note">
		<xsl:call-template name="text-node">
			<xsl:with-param name="elname">bflc:note</xsl:with-param>
			<xsl:with-param name="literal">
				<xsl:choose>
					<xsl:when test="bf:Note/bf:noteType">
						<xsl:value-of select="concat('(',bf:Note/bf:noteType,') ', bf:Note/rdfs:label)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="bf:Note/rdfs:label"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<!-- <xsl:element name="bflc:note">
			<xsl:value-of select="bf:Note/rdfs:label"/>
		</xsl:element> -->
	</xsl:template>
	<xsl:template match="bf:generationProcess">
		<xsl:call-template name="text-node">
			<xsl:with-param name="elname">bflc:generationProcess</xsl:with-param>
			<xsl:with-param name="literal" select="bf:GenerationProcess/rdfs:label"/>
		</xsl:call-template>
		<!-- <xsl:element name="bflc:generationProcess">
			<xsl:value-of select="bf:GenerationProcess/rdfs:label"/>
		</xsl:element> -->
	</xsl:template>
	<!-- <xsl:when test="bf:Language[bf:part]/bf:identifiedBy">
			<bf:language ><bf:Language><xsl:copy-of select="bf:Language/bf:part"/>
			<bflc:target rdf:resource="{bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource}"/></bf:Language>
			</bf:language>
			</xsl:when> -->
	<xsl:template match="bf:language">

		<xsl:choose>
			<xsl:when test="bf:Language[@rdf:about]">
				<xsl:call-template name="flip-about">
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>

				<!-- <xsl:element name="bf:language">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="bf:Language/@rdf:about"/>
					</xsl:attribute>
				</xsl:element> -->
			</xsl:when>
			<xsl:when test="bf:Language/bf:identifiedBy">

				<xsl:variable name="lang-uri">
					<xsl:value-of select="bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource"/>
				</xsl:variable>
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:language</xsl:with-param>
					<xsl:with-param name="resource-url" select="$lang-uri"/>
				</xsl:call-template>
				<!-- <xsl:element name="bf:language">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="$lang-uri"/>
					</xsl:attribute>
				</xsl:element> -->
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|*|text()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- <xsl:template match="madsrdf:componentList">
	<xsl:choose>
	<xsl:when test="*[1][not(contains(@rdf:about,'example.org')) ]">
<xsl:call-template name="flip-about">
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>
				</xsl:when>
				<xsl:otherwise><xsl:copy>
					<xsl:apply-templates select="@*|*"/>
				</xsl:copy></xsl:otherwise>
				</xsl:choose>
				</xsl:template>
	 --><xsl:template match="bf:subject">
		<xsl:choose>
			<xsl:when test="*[1][not(contains(@rdf:about,'example.org')) ]">
				<!-- <xsl:element name="bf:subject">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="*[1]/@rdf:about"/>
					</xsl:attribute>
				</xsl:element> -->
				<xsl:call-template name="flip-about">
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:descriptionLanguage">
		<xsl:choose>
			<xsl:when test="bf:Language[@rdf:about]">
				<xsl:call-template name="flip-about"><xsl:with-param name="node" select="."/></xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:notation">
		<xsl:choose>
			<xsl:when test="bf:Script[bf:code]">
				<xsl:call-template name="resource-node">
				<xsl:with-param name="elname">bflc:scriptNotation</xsl:with-param>
				<xsl:with-param name="resource-url" select="concat('http://tmpid.loc.gov/vocabulary/ScriptNotation/',bf:Script/bf:code,'.',normalize-space(bf:Script/rdfs:label))"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
<xsl:template match="bf:illustrativeContent|bf:content">
		<xsl:choose>
			<xsl:when test="*[1][@rdf:about]">
				<xsl:call-template name="flip-about"><xsl:with-param name="node" select="."/></xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="bf:descriptionConventions">
		<xsl:choose>
			<xsl:when test="bf:DescriptionConventions[@rdf:about]">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:descriptionConventions</xsl:with-param>
					<xsl:with-param name="resource-url" select="bf:DescriptionConventions/@rdf:about"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="bf:DescriptionConventions[translate(bf:code,' ?[]()','')='isbd']">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:descriptionConventions</xsl:with-param>
					<xsl:with-param name="resource-url">http://id.loc.gov/vocabulary/descriptionConventions/isbd</xsl:with-param>
				</xsl:call-template>
				<!-- <bf:descriptionConventions rdf:resource="http://id.loc.gov/vocabulary/descriptionConventions/isbd">
					
				</bf:descriptionConventions> -->
			</xsl:when>
			<xsl:when test="bf:DescriptionConventions[translate(bf:code,' ?[]()','')='aacr']">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:descriptionConventions</xsl:with-param>
					<xsl:with-param name="resource-url">http://id.loc.gov/vocabulary/descriptionConventions/aacr</xsl:with-param>
				</xsl:call-template>
				<!-- <bf:descriptionConventions rdf:resource="http://id.loc.gov/vocabulary/descriptionConventions/aacr">
					
				</bf:descriptionConventions> -->
			</xsl:when>
			<xsl:when test="bf:DescriptionConventions[translate(bf:code,' ?[]()','')='unknown']">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:descriptionConventions</xsl:with-param>
					<xsl:with-param name="resource-url">http://id.loc.gov/vocabulary/descriptionConventions/local</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="bf:descriptionModifier">
		<xsl:choose>
			<xsl:when test="bf:Agent[@rdf:about]">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:descriptionModifier</xsl:with-param>
					<xsl:with-param name="resource-url" select="bf:Agent[@rdf:about]"/>
				</xsl:call-template>
				<!-- <bf:descriptionModifier rdf:resource="{bf:DescriptionModifier/@rdf:about}">
					
				</bf:descriptionModifier> -->
			</xsl:when>
			<xsl:when test="bf:Agent[starts-with(rdfs:label,'DLC') or starts-with(rdfs:label,'OCoLC') ]">
				<xsl:variable name="cleancode">
					<xsl:call-template name="cleanOrgCode">
						<xsl:with-param name="code-string">
							<xsl:value-of select="bf:Agent/rdfs:label"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:descriptionModifier</xsl:with-param>
					<xsl:with-param name="resource-url" select="concat('http://id.loc.gov/vocabulary/organizations/',$cleancode)"/>
				</xsl:call-template>
				<!-- 	<bf:descriptionModifier rdf:resource="{concat('http://id.loc.gov/vocabulary/organizations/',$cleancode)}">
					
				</bf:descriptionModifier> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="bf:descriptionAuthentication">
		<xsl:choose>
			<xsl:when test="bf:DescriptionAuthentication[@rdf:about]">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:descriptionAuthentication</xsl:with-param>
					<xsl:with-param name="resource-url" select="bf:DescriptionAuthentication/@rdf:about"/>
				</xsl:call-template>
				<!-- <bf:descriptionAuthentication rdf:resource="{bf:DescriptionAuthentication/@rdf:about}">
					
				</bf:descriptionAuthentication> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:issuance">
		<xsl:choose>
			<xsl:when test="bf:Issuance[@rdf:about]">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:issuance</xsl:with-param>
					<xsl:with-param name="resource-url" select="bf:Issuance/@rdf:about"/>
				</xsl:call-template>
				<!-- <bf:issuance rdf:resource="{bf:Issuance/@rdf:about}">
					
				</bf:issuance> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:genreForm">
		<xsl:choose>
			<xsl:when test="bf:GenreForm[@rdf:about]">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:genreForm</xsl:with-param>
					<xsl:with-param name="resource-url" select="bf:GenreForm/@rdf:about"/>
				</xsl:call-template>
				<!-- <bf:genreForm rdf:resource="{bf:GenreForm/@rdf:about}">
					
				</bf:genreForm> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:provisionActivity">
		<xsl:variable name="provtype">
			<xsl:choose>
				<xsl:when test="bf:ProvisionActivity/rdf:type/@rdf:resource='http://id.loc.gov/ontologies/bibframe/Publication'">bflc:publish</xsl:when>
				<xsl:when test="bf:ProvisionActivity/rdf:type/@rdf:resource='http://id.loc.gov/ontologies/bibframe/Manufacture'">bflc:manufacture</xsl:when>
				<xsl:when test="bf:ProvisionActivity/rdf:type/@rdf:resource='http://id.loc.gov/ontologies/bibframe/Distribution'">bflc:distribution</xsl:when>
				<xsl:when test="bf:ProvisionActivity/rdf:type/@rdf:resource='http://id.loc.gov/ontologies/bibframe/Production'">bflc:production</xsl:when>
				<xsl:otherwise>bflc:publish</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:for-each select="bf:ProvisionActivity/bf:date">
			<xsl:element name="{concat($provtype,'Date')}">
				<xsl:copy-of select="@*"/>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
		<xsl:for-each select="bf:ProvisionActivity/bf:place">
			<xsl:element name="{concat($provtype,'Location')}">
				<xsl:choose>
					<xsl:when test="bf:Place/@rdf:about">
						<xsl:attribute name="rdf:resource"><xsl:value-of select="bf:Place/@rdf:about"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="bf:Place"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:for-each>



		<xsl:for-each select="bf:ProvisionActivity/bf:agent">
			<xsl:element name="{concat($provtype,'Agent')}">
				<xsl:choose>
					<xsl:when test="bf:Agent/@rdf:about">
						<xsl:copy-of select="bf:Agent/@rdf:about"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="bf:Agent"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="bflc:encodingLevel">
		<xsl:choose>
			<xsl:when test="bflc:EncodingLevel[bf:code]">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bflc:encodingLevel</xsl:with-param>
					<xsl:with-param name="resource-url">
						<xsl:value-of select="concat('http://id.loc.gov/vocabulary/menclvl/',bflc:EncodingLevel/bf:code)"/>
					</xsl:with-param>
				</xsl:call-template>
				<!-- <bf:status rdf:resource="{concat('http://id.loc.gov/vocabulary/menclvl/',bflc:EncodingLevel/bf:code)}">
					
				</bf:status> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:contribution">
		<!-- test on instance -->
		<xsl:variable name="role-element">
			<xsl:choose>
				<xsl:when test="contains(bf:Contribution/bf:role/bf:Role/@rdf:about,'/relators/')">
					<xsl:value-of select="concat('rel:',substring-after(bf:Contribution/bf:role/bf:Role/@rdf:about,'/relators/'))"/>
				</xsl:when>
				<xsl:otherwise>rel:ctb</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


		<xsl:element name="{$role-element}">
			<xsl:choose>
				<xsl:when test="bf:Contribution/bf:agent/*[1]/@rdf:about">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="bf:Contribution/bf:agent/*[1]/@rdf:about"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="bf:Contribution/bf:agent/*"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="bf:status">

		<xsl:choose>
			<xsl:when test="bf:Status[bf:code] and ancestor::bf:AdminMetadata">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:status</xsl:with-param>
					<xsl:with-param name="resource-url">
						<xsl:value-of select="concat('http://id.loc.gov/vocabulary/recstatus/',bf:Status/bf:code)"/>
					</xsl:with-param>
				</xsl:call-template>
				<!-- <bf:status rdf:resource="{concat('http://id.loc.gov/vocabulary/recstatus/',bf:Status/bf:code)}">
					
				</bf:status> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bflc:relationship">
		<xsl:copy-of select="//bf:relatedTo"/>
	</xsl:template>
	<xsl:template match="bf:identifiedBy">
		<xsl:choose>
			<xsl:when test="bf:Local and ancestor::bf:AdminMetadata">

				<xsl:call-template name="text-node">
					<xsl:with-param name="elname">bflc:lclocalid</xsl:with-param>
					<xsl:with-param name="literal" select="bf:Local/rdf:value"/>
				</xsl:call-template>
				<!-- 
				<bflc:lclocalid>
					<xsl:value-of select="bf:Local/rdf:value"/>
				
				</bflc:lclocalid> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:source">
		<xsl:choose>
			<xsl:when test="bf:Source[starts-with(rdfs:label,'DLC') or starts-with(rdfs:label,'OCoLC')]">
				<xsl:variable name="cleancode">
					<xsl:call-template name="cleanOrgCode">
						<xsl:with-param name="code-string" select="bf:Source/rdfs:label"></xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:source</xsl:with-param>
					<xsl:with-param name="resource-url">
						<xsl:value-of select="concat( 'http://id.loc.gov/vocabulary/organizations/', $cleancode)"/>
					</xsl:with-param>
				</xsl:call-template>

				<!-- <bf:source rdf:resource="{concat( 'http://id.loc.gov/vocabulary/organizations/', $cleancode)}">
					
				</bf:source> -->
			</xsl:when>
			<xsl:when test="bf:Source/@rdf:about">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:source</xsl:with-param>
					<xsl:with-param name="resource-url">
						<xsl:value-of select="bf:Source/@rdf:about"/>
					</xsl:with-param>
				</xsl:call-template>
				<!-- <bf:source rdf:resource="{bf:Source/@rdf:about}">
					
				</bf:source> -->
			</xsl:when>
			<xsl:when test="bf:Source/bf:agent/bf:Agent[@rdf:about='http://id.loc.gov/vocabulary/organizations/dlc']">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:source</xsl:with-param>
					<xsl:with-param name="resource-url">http://id.loc.gov/vocabulary/organizations/dlc</xsl:with-param>
				</xsl:call-template>

				<!-- 	<bf:source rdf:resource="http://id.loc.gov/vocabulary/organizations/dlc">
					
				</bf:source> -->
			</xsl:when>
			<xsl:when test="bf:Source/rdfs:label='lcgft'">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:source</xsl:with-param>
					<xsl:with-param name="resource-url">http://id.loc.gov/authorities/genreForms</xsl:with-param>
				</xsl:call-template>
				<!-- <bf:source rdf:resource="http://id.loc.gov/authorities/genreForms"/> -->
			</xsl:when>
			<xsl:when test="bf:Source[rdfs:label='lcsh' or bf:code='lcsh']">
				<!-- <bf:source rdf:resource="http://id.loc.gov/authorities/subjects"/> -->
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:source</xsl:with-param>
					<xsl:with-param name="resource-url">http://id.loc.gov/authorities/subjects</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="bf:Source/rdf:type/@rdf:resource ='http://id.loc.gov/ontologies/bibframe/Agent'">
				<xsl:element name="bf:source">
					<xsl:element name="bf:Agent">
						<xsl:copy-of select="bf:Source/@*|bf:Source/*[not(self::rdf:type)]"/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>

				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
				<!-- </xsl:variable>
				<xsl:choose><xsl:when test="$raw-source/bf:source/bf:Agent[rdf:resource='http://id.loc.gov/ontologies/bibframe/Agent]">
				hi
				</xsl:when>
				<xsl:otherwise><xsl:copy-of select="$raw-source"/></xsl:otherwise></xsl:choose>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[not(name()='bf:source')][not(name()='bf:genreForm')][not(name()='bf:issuance')]      [not(name()='bf:descriptionAuthentication')][not(name()='bf:descriptionConventions')][not(name()='bf:descriptionModifier')]      [not(name()='bf:descriptionLanguage')][not(name()='bf:status')][not(name()='bflc:encodingLevel')]     [not(name()='bf:provisionActivity')][not(name()='bf:language')]   [not(name()='bf:contribution')]   [not(name()='bf:title')]  [not(name()='bf:note')]  [not(name()='bf:classification')]  [not(name()='bf:subject')]   [not(name()='bf:generationProcess')][not(name()='bf:identifiedBy')]     [not(name()='bflc:relationship')] [not(name()='bf:illustrativeContent')] [not(name()='bf:content')]
	[not(name()='bf:notation')]">

		<xsl:copy>

			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="*"/>
			<xsl:apply-templates select="text()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="no" name="Scenario1" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/c019777121.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario2" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/instances/c0159857590001.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario3" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/c017892457.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario4" userelativepaths="yes" externalpreview="no" url="mlvlp04.loc.gov:8230/resources/works/c003576737.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario5" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/c002405297.rdf" htmlbaseurl="" outputurl="" processortype="saxon6" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="instance" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/instances/c0111859390001.rdf" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario6" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/c003576737.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="yes" name="provision test" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/instances/c0068614630001.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->