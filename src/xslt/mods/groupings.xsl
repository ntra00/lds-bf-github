<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="local">
	

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<!--input is labels, output is local, for mods-default to transform to html-->
	<!-- dedups labels from labels.xsl 	-->

	<xsl:variable name="relatedItems" select="/descriptive/relatedItem/element"/>

	<!-- <xsl:variable name="itemLabels" select="//full/element/@label"/> -->
	<xsl:variable name="uniqueLabels" select="distinct-values(//full/element/@label)"/>


	<xsl:variable name="set">
		<xsl:apply-templates select="//full/element" mode="copy">
		</xsl:apply-templates>
	</xsl:variable>
	<xsl:variable name="uniqueElements">
		<!-- this gets the whole element for each unique label so you can sort on order and set attributes -->
		<xsl:for-each select="$uniqueLabels">
			<xsl:variable name="thisLabel" select="."/>
			<!-- <xsl:copy-of select="$set/element[@label=$thisLabel][1]"/> -->
						<xsl:copy-of select="$set/element[label=$thisLabel][1]" copy-namespaces="yes"/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:template match="/" as="item()*">
		<xsl:choose>
			<xsl:when test="count(//full/element)=count($uniqueLabels)">
				<!--  no duplicate elements -->
				<!-- <xsl:copy-of select="/"/> -->
				<descriptive>
				<xsl:copy-of select="//objectType | //pagetitle | //gmd | //objectHeader | //contentRestricted | //digitalID | // objectID | //profile | //viewable | //imagelink | //span| //metatags " copy-namespaces="yes"/>
				<full><xsl:copy-of select="$set" copy-namespaces="yes"/></full>
				<related>
						<xsl:for-each select="descriptive//relatedItem">
							<xsl:copy-of select="." copy-namespaces="yes"/>
						</xsl:for-each>
					</related>
				</descriptive>
			</xsl:when>
			<xsl:otherwise>
				<!--  dedup the elements: -->
				<descriptive>
					<xsl:copy-of select="//objectType | //pagetitle | //gmd | //objectHeader | //contentRestricted | //digitalID | // objectID | //profile | //viewable | //imagelink | //span| //metatags" copy-namespaces="yes"/>
					<full>
						<xsl:for-each select="$uniqueElements/element">
							<xsl:sort select="number(@set)" data-type="text" order="ascending"/>
							<xsl:sort select="number(@order)" data-type="text" order="ascending"/>
							<xsl:variable name="thisLabel" select="label"/>
							<!-- process the first found $set element for each sorted unique element  -->
							<xsl:apply-templates select="$set/element[label=$thisLabel][1]" mode="getvalues"/>
						</xsl:for-each>						
					</full>

					<related>
						<xsl:for-each select="descriptive//relatedItem">
							<xsl:copy-of select="." copy-namespaces="yes"/>
						</xsl:for-each>
					</related>
				</descriptive>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="element" mode="getvalues" as="item()*">
		<!-- puts the correct label in @label (singular or  plural) then gets all the value elements that go with this label
	, deduping elements -->
		<xsl:variable name="thisLabel" select="label"/>
		<xsl:variable name="labelCount">
			<xsl:value-of select="count($set/element[label=$thisLabel])" disable-output-escaping="no"/>
		</xsl:variable>
		<xsl:copy inherit-namespaces="yes" copy-namespaces="yes">
			<xsl:copy-of select="@*" copy-namespaces="yes"/>
			<xsl:element name="label" inherit-namespaces="yes">				
				<xsl:choose>					
					<xsl:when test="$labelCount = 1">
						<xsl:choose>
							<xsl:when test="label!=''">
								<xsl:value-of select="label" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="field" disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="@pluralLabel!=''">
								<xsl:value-of select="@pluralLabel" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:when test="label!=''">
								<xsl:value-of select="label" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:when test="@label!=''">
								<xsl:value-of select="@label" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="field" disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:for-each select="$set/element[label=$thisLabel]">
				<xsl:copy-of select="value" copy-namespaces="yes"/>
			</xsl:for-each>
			<xsl:if test="$thisLabel='LCCN'">
				<xsl:for-each select="$relatedItems[label=$thisLabel]">
					<xsl:copy-of select="value" copy-namespaces="yes"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="element" mode="copy" as="item()*">
		<xsl:copy inherit-namespaces="yes" copy-namespaces="yes">
		<xsl:element name="label" inherit-namespaces="yes"><xsl:value-of select="@label" disable-output-escaping="no"/>
			</xsl:element>
		<xsl:copy-of select="*" copy-namespaces="yes"/>
		</xsl:copy>		
	</xsl:template>
</xsl:stylesheet>