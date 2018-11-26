<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/" xmlns:rel="http://id.loc.gov/vocabulary/relators" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" exclude-result-prefixes="xsl bf rdf rdfs bflc xs"
                extension-element-prefixes="rdf rdfs bf bflc rel" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<!-- default-validation="strip" xmlns:xdmp="http://marklogic.com/xdmp" 
	input-type-annotations="unspecified"-->
	<xsl:variable name="UPPER">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

	<xsl:variable name="lower">abcdefghijklmnopqrstuvwxy</xsl:variable>
	<xsl:variable name="punc">.;,-%#@()+_:?/\`&amp;'"</xsl:variable>
	<xsl:variable name="flipable">
		<flipable>
			<node name="acquisitionSource"></node>
			<!-- <node name="adminMetadata"></node> -->
			<node name="agent"></node>
			<node name="grantingInstitution"></node>
			<node name="heldBy"></node>
			<node name="contributor"></node>
			<node name="assigner"></node>
			<node name="descriptionModifier"></node>
			<node name="appliedMaterial"></node>
			<node name="arrangement"></node>
			<node name="aspectRatio"></node>
			<node name="barcode"></node>
			<node name="baseMaterial"></node>
			<node name="bookFormat"></node>
			<node name="capture"></node>
			<node name="carrier"></node>
			<node name="cartographicAttributes"></node>
			<node name="classification"></node>
			<node name="colorContent"></node>
			<node name="content"></node>
			<node name="contentAccessibility"></node>
			<!-- <node name="contribution"></node> -->
			<node name="copyrightRegistration"></node>
			<node name="hasEquivalent"></node>
			<node name="hasPart"></node>
			<node name="partOf"></node>
			<node name="accompaniedBy"></node>
			<node name="accompanies"></node>
			<node name="references"></node>
			<node name="referencedBy"></node>
			<node name="coverArt"></node>
			<node name="descriptionAuthentication"></node>
			<node name="descriptionConventions"></node>
			<node name="digitalCharacteristic"></node>
			<node name="dissertation"></node>
			<node name="emulsion"></node>
			<node name="enumerationAndChronology"></node>
			<node name="eventContentOf"></node>
			<node name="propertyName"></node>
			<node name="extent"></node>
			<node name="fontSize"></node>
			<node name="frequency"></node>
			<node name="generation"></node>
			<node name="generationProcess"></node>
			<node name="genreForm"></node>
			<node name="geographicCoverage"></node>
			<node name="identifiedBy"></node>
			<node name="illustrativeContent"></node>
			<node name="immediateAcquisition"></node>
			<node name="hasInstance"></node>
			<node name="itemOf"></node>
			<node name="issuedWith"></node>
			<node name="otherPhysicalFormat"></node>
			<node name="hasReproduction"></node>
			<node name="reproductionOf"></node>
			<node name="intendedAudience"></node>
			<node name="issuance"></node>
			<node name="hasItem"></node>
			<node name="language"></node>
			<node name="descriptionLanguage"></node>
			<node name="layout"></node>
			<node name="media"></node>
			<node name="mount"></node>
			<node name="ensemble"></node>
			<node name="musicFormat"></node>
			<node name="instrument"></node>
			<node name="musicMedium"></node>
			<node name="voice"></node>
			<node name="notation"></node>
			<node name="note"></node>
			<node name="place"></node>
			<node name="originPlace"></node>
			<node name="polarity"></node>
			<node name="productionMethod"></node>
			<node name="projection"></node>
			<node name="projectionCharacteristic"></node>
			<node name="provisionActivity"></node>
			<node name="rdf:type"></node>
			<node name="identifies"></node>
			<!-- <node name="subject"></node> -->
			<node name="electronicLocator"></node>
			<node name="relatedTo"></node>
			<node name="reductionRatio"></node>
			<node name="review"></node>
			<node name="role"></node>
			<node name="scale"></node>
			<node name="shelfMark"></node>
			<node name="soundCharacteristic"></node>
			<node name="soundContent"></node>
			<node name="source"></node>
			<node name="status"></node>
			<node name="sublocation"></node>
			<node name="summary"></node>
			<node name="supplementaryContent"></node>
			<node name="systemRequirement"></node>
			<node name="tableOfContents"></node>
			<!-- <node name="title"></node> -->
			<node name="unit"></node>
			<node name="usageAndAccessPolicy"></node>
			<node name="videoCharacteristic"></node>
			<node name="instanceOf"></node>
			<node name="hasExpression"></node>
			<node name="expressionOf"></node>
			<node name="eventContent"></node>
			<node name="hasDerivative"></node>
			<node name="derivativeOf"></node>
			<node name="precededBy"></node>
			<node name="succeededBy"></node>
			<node name="dataSource"></node>
			<node name="hasSeries"></node>
			<node name="seriesOf"></node>
			<node name="hasSubseries"></node>
			<node name="subseriesOf"></node>
			<node name="supplement"></node>
			<node name="supplementTo"></node>
			<node name="translation"></node>
			<node name="translationOf"></node>
			<node name="originalVersion"></node>
			<node name="originalVersionOf"></node>
			<node name="index"></node>
			<node name="indexOf"></node>
			<node name="otherEdition"></node>
			<node name="otherEditionOf"></node>
			<node name="findingAid"></node>
			<node name="findingAidOf"></node>
			<node name="replacementOf"></node>
			<node name="replacedBy"></node>
			<node name="mergerOf"></node>
			<node name="mergedToForm"></node>
			<node name="continues"></node>
			<node name="continuedBy"></node>
			<node name="continuesInPart"></node>
			<node name="splitInto"></node>
			<node name="absorbed"></node>
			<node name="absorbedBy"></node>
			<node name="separatedFrom"></node>
			<node name="continuedInPartBy"></node>
		</flipable>
	</xsl:variable>

	<xsl:template match="/">

		<xsl:for-each select="rdf:RDF">
			<xsl:copy>

				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:for-each>
		<!-- 
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
		         xmlns:rel="http://id.loc.gov/vocabulary/relators" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#">
			<xsl:fallback>
				<xsl:apply-templates select="rdf:RDF/*"/> 
			</xsl:fallback>
			<xsl:apply-templates select="rdf:RDF/*"/> 
		</rdf:RDF> -->
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
	<xsl:template name="try-to-flip">
		<!-- ="bf:illustrativeContent|bf:content|bf:media|bf:carrier|bf:geographicCoverage|bf:originPlace"> -->
		<xsl:choose>
			<xsl:when test="*[1][@rdf:about]">
				<xsl:call-template name="flip-about">
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@rdf:resource">
				<xsl:copy>
					<xsl:copy-of select="@rdf:resource"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>

				<xsl:apply-templates select="@*|*|text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:copy-of select="."/>
	</xsl:template>
	<xsl:template match="bf:title">

		<xsl:variable name="elname">
			<xsl:choose>
			<xsl:when test="bflc:TransliteratedTitle">bflc:variantTitle</xsl:when>
				<xsl:when test="bf:*[rdf:type and rdf:type/@rdf:resource!='http://id.loc.gov/ontologies/bibframe/Title']">bflc:variantTitle</xsl:when>
				<xsl:otherwise>bflc:title</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$elname}">
			<xsl:choose>
				<xsl:when test="bf:Title/rdfs:label">
					<xsl:copy-of select="bf:Title/rdfs:label/@xml:lang"/>
					<xsl:value-of select="bf:Title/rdfs:label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="bf:Title/bf:mainTitle/@xml:lang"/>
					<xsl:value-of select="bf:Title/bf:mainTitle"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
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
				<xsl:apply-templates select="@*|*|text()"/>
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
	
	<xsl:template match="madsrdf:componentList">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<!-- if sub components were found, skip all but the url -->
			<xsl:for-each select="*[@rdf:about and not(contains(@rdf:about,'example.org')) ][not(contains(@rdf:about,'#Topic')) ][not(contains(@rdf:about,'#Agent')) ]">
				<xsl:copy>
					<xsl:copy-of select="@rdf:about"/>
				</xsl:copy>
			</xsl:for-each>



			<xsl:copy-of select="*[not(@rdf:about) or contains(@rdf:about,'example.org') or contains(@rdf:about,'#Topic')  or contains(@rdf:about,'#Agent')]"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="bf:subject">
		<xsl:choose>
			<xsl:when test="*[1][@rdf:about and not(contains(@rdf:about,'example.org')) ][not(contains(@rdf:about,'#Topic')) ]">
				
				<xsl:call-template name="flip-about">
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy><xsl:apply-templates select="@*|*|text()"/></xsl:copy>
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
				<xsl:apply-templates select="@*|*|text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="bf:descriptionConventions[*|@*]">
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
					<xsl:apply-templates select="@*|*|text()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:descriptionModifier|bflc:applicableInstitution">
		<xsl:choose>
			<xsl:when test="bf:Agent[@rdf:about]">
				<!-- <xsl:call-template name="resource-node">
					<xsl:with-param name="elname">
						<xsl:value-of select="name(.)"/>
					</xsl:with-param>
					<xsl:with-param name="resource-url" select="bf:Agent[@rdf:about]"/>
				</xsl:call-template> -->
				<xsl:call-template name="flip-about">
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="bf:Agent[starts-with(rdfs:label,'DLC') or starts-with(rdfs:label,'OCoLC') or  starts-with(rdfs:label,'DPCC')  or starts-with(bf:code,'DLC') or starts-with(bf:code,'OCoLC') or  starts-with(bf:code,'DPCC') ]">
				<xsl:variable name="cleancode">
					<xsl:call-template name="cleanOrgCode">
						<xsl:with-param name="code-string">
							<xsl:value-of select="(bf:Agent/rdfs:label|bf:Agent/bf:code)[1]"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">
						<xsl:value-of select="name(.)"/>
					</xsl:with-param>
					<xsl:with-param name="resource-url" select="concat('http://id.loc.gov/vocabulary/organizations/',$cleancode)"/>
				</xsl:call-template>
			</xsl:when>
			<!-- someday, oclc symbols:
			"https://www.oclc.org/en/contacts/libraries/c03"  or https://worldcat.org/registry/Institutions/8655
			-->
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|*|text()"/>
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
			<xsl:copy>	<xsl:apply-templates select="@*|*|text()"/></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="bf:genreForm">
		<xsl:choose>
			<xsl:when test="*[1][@rdf:about and not(contains(@rdf:about,'example.org')) and not(contains(@rdf:about,'#GenreForm')) ]">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:genreForm</xsl:with-param>
					<xsl:with-param name="resource-url" select="*[1]/@rdf:about"/>
				</xsl:call-template>
				<!-- <bf:genreForm rdf:resource="{bf:GenreForm/@rdf:about}">
					
				</bf:genreForm> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="@*|*|text()"/>
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
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="bf:Place/@rdf:about"/>
						</xsl:attribute>
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
			<xsl:when test="bflc:EncodingLevel[rdfs:label]">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bflc:encodingLevel</xsl:with-param>
					<xsl:with-param name="resource-url">
						<xsl:value-of select="concat('http://id.loc.gov/vocabulary/menclvl/',bflc:EncodingLevel/rdfs:label)"/>
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
		<xsl:for-each select="*/bf:role/bf:Role">
			<xsl:variable name="role-element">
				<xsl:choose>
					<xsl:when test="contains(@rdf:about,'/relators/')">
						<xsl:value-of select="concat('rel:',substring-after(@rdf:about,'/relators/'))"/>
					</xsl:when>
					<xsl:otherwise>rel:ctb</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>


			<xsl:element name="{$role-element}">
				<xsl:choose><!--  Contribution or Primary contribution -->
					<xsl:when test="not(contains(ancestor-or-self::bf:contribution/*/bf:agent/*[1]/@rdf:about,'#Agent'))">
						<xsl:attribute name="rdf:resource">
							<xsl:value-of select="ancestor-or-self::bf:contribution/*/bf:agent/*[1]/@rdf:about"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="ancestor-or-self::bf:contribution/*/bf:agent/*"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:for-each>
		<xsl:if test="not(*/bf:role/bf:Role)">
			<xsl:element name="rel:ctb">
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
		</xsl:if>
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
				<xsl:copy><xsl:apply-templates select="@*|*|text()"/></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bflc:relationship">
		<xsl:apply-templates  select="*/bf:relatedTo"/>
	</xsl:template>
	<xsl:template match="bf:identifiedBy">
		<xsl:choose>
			<xsl:when test="bf:Local and ancestor::bf:AdminMetadata">
				<xsl:call-template name="text-node">
					<xsl:with-param name="elname">bflc:lclocalid</xsl:with-param>
					<xsl:with-param name="literal" select="bf:Local/rdf:value"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="name(*[1])='bf:Issn' or name(*[1])='bf:IssnL'">
				<xsl:variable name="node" select="*[1]"/>
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:identifiedBy</xsl:with-param>
					<xsl:with-param name="resource-url">
						<xsl:value-of select="concat('https://portal.issn.org/resource/issn/',string($node/rdf:value))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy><xsl:apply-templates select="@*|*|text()"/></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="bf:source">
		<xsl:choose>

			<xsl:when test="bf:Source[@rdf:about]|bf:Agent[@rdf:about]">
				<xsl:element name="bf:source">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="*/@rdf:about"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:when>

			<xsl:when test="bf:Source/bf:agent/bf:Agent[@rdf:about='http://id.loc.gov/vocabulary/organizations/dlc']">
				<xsl:call-template name="resource-node">
					<xsl:with-param name="elname">bf:source</xsl:with-param>
					<xsl:with-param name="resource-url">http://id.loc.gov/vocabulary/organizations/dlc</xsl:with-param>
				</xsl:call-template>

				<!-- 	<bf:source rdf:resource="http://id.loc.gov/vocabulary/organizations/dlc">
					
				</bf:source> -->
			</xsl:when>
			<xsl:when test="*[starts-with(rdfs:label,'DLC') or starts-with(rdfs:label,'OCoLC')]">
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
					<xsl:apply-templates select="@*|*|text()"/>
				</xsl:copy>
			</xsl:otherwise>
			<!-- </xsl:variable>
				<xsl:choose><xsl:when test="$raw-source/bf:source/bf:Agent[rdf:resource='http://id.loc.gov/ontologies/bibframe/Agent]">
				hi
				</xsl:when>
				<xsl:otherwise><xsl:copy-of select="$raw-source"/></xsl:otherwise></xsl:choose>-->
		</xsl:choose>
	</xsl:template>

	<!-- 	<xsl:template match="*[not(name()='bf:source')][not(name()='bf:genreForm')][not(name()='bf:issuance')]      [not(name()='bf:descriptionAuthentication')][not(name()='bf:descriptionConventions')][not(name()='bf:descriptionModifier')]      [not(name()='bf:descriptionLanguage')][not(name()='bf:status')][not(name()='bflc:encodingLevel')]     [not(name()='bf:provisionActivity')][not(name()='bf:language')]   [not(name()='bf:contribution')]   [not(name()='bf:title')]  [not(name()='bf:note')]  [not(name()='bf:classification')]  [not(name()='bf:subject')]   [not(name()='bf:generationProcess')][not(name()='bf:identifiedBy')]     [not(name()='bflc:relationship')] [not(name()='bf:illustrativeContent')] [not(name()='bf:content')]  [not(name()='bf:notation')][not(name()='bf:media')][not(name()='bf:carrier')][not(name()='bflc:applicableInstitution')]  [not(name()='bf:geographicCoverage')]  [not(name()='madsrdf:componentList')] [not(name()='bf:originPlace')]"> -->
	<xsl:template match="*">
		<xsl:variable name="this-name" select="local-name(.)"/>
		<xsl:choose>
			<xsl:when test="$this-name='relatedTo'">
				<xsl:call-template name="try-to-flip"/>
			</xsl:when>
			
			<xsl:when test="$flipable//node[@name=$this-name]">
				<xsl:call-template name="try-to-flip"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{name(.)}">

					<xsl:apply-templates select="node()|@*|text()"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="no" name="Scenario1" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/c019777121.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario2" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/instances/c0159857590001.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario3" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/c017892457.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario4" userelativepaths="yes" externalpreview="no" url="mlvlp04.loc.gov:8230/resources/works/c003576737.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario5" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/c002405297.rdf" htmlbaseurl="" outputurl="" processortype="saxon6" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="instance" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/instances/c0111859390001.rdf" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario6" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/c003576737.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="provision test" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/instances/c0068614630001.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="error" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8231/resources/works/c018921113.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="bfedited" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8231/resources/works/e2018600147.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="instance error" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/instances/c0131846020001.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario7" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8231/resources/instances/e20180547900001.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="Scenario8" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/instances/c0174401100001.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="no" name="auth rel:ctb" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8231/resources/works/n80149989.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="yes" name="Scenario9" userelativepaths="yes" externalpreview="no" url="http://mlvlp04.loc.gov:8230/resources/works/e2017441766.rdf" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->