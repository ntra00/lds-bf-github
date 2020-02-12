<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="mods mets" default-validation="strip" input-type-annotations="unspecified" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/" as="item()*">
		<xsl:apply-templates select="mods:mods"/>
	</xsl:template>
	<xsl:template match="mods:mods" as="item()*">
		<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
			<xsl:apply-templates select="child::node()"/>
		</oai_dc:dc>
	</xsl:template>

	<xsl:template match="mods:titleInfo" as="item()*">
		<dc:title>
			<xsl:value-of select="mods:nonSort" disable-output-escaping="no"/>
			<xsl:if test="mods:nonSort">
				<xsl:text disable-output-escaping="no"> </xsl:text>
			</xsl:if>
			<xsl:value-of select="mods:title" disable-output-escaping="no"/>
			<xsl:if test="mods:subTitle">
				<xsl:text disable-output-escaping="no">: </xsl:text>
				<xsl:value-of select="mods:subTitle" disable-output-escaping="no"/>
			</xsl:if>
			<xsl:if test="mods:partNumber">
				<xsl:text disable-output-escaping="no">. </xsl:text>
				<xsl:value-of select="mods:partNumber" disable-output-escaping="no"/>
			</xsl:if>
			<xsl:if test="mods:partName">
				<xsl:text disable-output-escaping="no">. </xsl:text>
				<xsl:value-of select="mods:partName" disable-output-escaping="no"/>
			</xsl:if>
		</dc:title>
	</xsl:template>

	<xsl:template match="mods:name" as="item()*">
		<xsl:choose>
			<xsl:when test="mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre' ">
				<dc:creator>
					<xsl:call-template name="name"/>
				</dc:creator>
			</xsl:when>
			<xsl:otherwise>

				<dc:contributor>
					<xsl:call-template name="name"/>
				</dc:contributor>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="mods:classification" as="item()*">
		<dc:subject>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</dc:subject>
	</xsl:template>

	<xsl:template match="mods:subject[mods:topic or mods:name or mods:occupation]" as="item()*">
		<dc:subject>
			<xsl:for-each select="mods:topic | mods:occupation ">
				<xsl:value-of select="." disable-output-escaping="no"/>
				<xsl:if test="position()!=last()">--</xsl:if>
			</xsl:for-each>

			<xsl:for-each select="mods:name">

				<xsl:call-template name="name"/>
			</xsl:for-each>
		</dc:subject>
	</xsl:template>

	<xsl:template match="mods:subject[mods:geographic or mods:temporal or mods:hierarchicalGeographic or  mods:cartographics]" as="item()*">

		<dc:coverage>
			<xsl:choose>
				<xsl:when test="mods:hierarchicalGeographic">
					<xsl:apply-templates mode="coverage2" select="*"/>
				</xsl:when>
				<xsl:when test=" mods:cartographics">
					<xsl:apply-templates mode="coverage1" select="mods:cartographics"/>
				</xsl:when>
				<xsl:when test="mods:temporal">
					<xsl:apply-templates select="mods:temporal"/>
				</xsl:when>
				<xsl:when test="mods:geographic">
					<xsl:value-of select="mods:geographic" disable-output-escaping="no"/>
				</xsl:when>
			</xsl:choose>
		</dc:coverage>
		<!-- 
		<xsl:if test="mods:hierarchicalGeographic">
			<dc:coverage>
				<xsl:apply-templates mode="coverage2" select="*"/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:geographicCode">
			<dc:coverage>
				<xsl:apply-templates mode="coverage1" select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:cartographics">
			<xsl:apply-templates mode="coverage1" select="."/>
		</xsl:for-each>-->
	</xsl:template>

	<xsl:template match="mods:abstract | mods:tableOfContents |mods:note " as="item()*">

		<dc:description>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</dc:description>
	</xsl:template>

	<xsl:template match="mods:originInfo" as="item()*">

		<xsl:apply-templates select="*[@point='start']"/>
		<xsl:for-each select="mods:dateIssued[@point!='start' and @point!='end'] |mods:dateCreated[@point!='start' and @point!='end'] | mods:dateCaptured[@point!='start' and @point!='end'] | mods:dateOther[@point!='start' and @point!='end']">
			<dc:date>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</dc:date>
		</xsl:for-each>

		<xsl:for-each select="mods:publisher">
			<dc:publisher>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</dc:publisher>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mods:genre" as="item()*">
		<xsl:choose>
			<xsl:when test="@authority='dct'">
				<dc:type>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</dc:type>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="../mods:typeOfResource" mode="noGenre"/>
				<!-- <xsl:for-each select="mods:typeOfResource">
					<dc:type>
						<xsl:value-of select="."/>
					</dc:type>
				</xsl:for-each> -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:typeOfResource" mode="noGenre" as="item()*">
		<xsl:if test="@collection='yes'">
			<dc:type>Collection</dc:type>
		</xsl:if>
		<dc:type>
			<xsl:choose>
				<xsl:when test=".='software' and ../mods:genre='database'">DataSet</xsl:when>
				<xsl:when test=".='software' and ../mods:genre='online system or service'">Service</xsl:when>
				<xsl:when test=".='software'">Software</xsl:when>
				<xsl:when test=".='cartographic material'">Image</xsl:when>
				<xsl:when test=".='multimedia'">InteractiveResource</xsl:when>
				<xsl:when test=".='moving image'">MovingImage</xsl:when>
				<xsl:when test=".='three-dimensional object'">PhysicalObject</xsl:when>
				<xsl:when test="starts-with(.,'sound recording')">Sound</xsl:when>
				<xsl:when test=".='still image'">StillImage</xsl:when>
				<xsl:when test=".='text'">Text</xsl:when>
				<xsl:when test=".='notated music'">Text</xsl:when>
			</xsl:choose>
		</dc:type>
	</xsl:template>

	<xsl:template match="mods:physicalDescription" as="item()*">
		<xsl:if test="mods:extent">
			<dc:format>
				<xsl:value-of select="mods:extent" disable-output-escaping="no"/>
			</dc:format>
		</xsl:if>
		<xsl:if test="mods:form">
			<dc:format>
				<xsl:value-of select="mods:form" disable-output-escaping="no"/>
			</dc:format>
		</xsl:if>
		<xsl:if test="mods:internetMediaType">
			<dc:format>
				<xsl:value-of select="mods:internetMediaType" disable-output-escaping="no"/>
			</dc:format>
		</xsl:if>
	</xsl:template>
	<xsl:template match="mods:mimeType" as="item()*">
		<dc:format>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</dc:format>
	</xsl:template>

	<xsl:template match="mods:identifier" as="item()*">
		<xsl:variable name="type" select="translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
		<xsl:choose>
			<xsl:when test="contains ('isbn issn uri doi lccn uri', $type)">
				<dc:identifier>
					<xsl:value-of select="$type" disable-output-escaping="no"/>: <xsl:value-of select="." disable-output-escaping="no"/></dc:identifier>
			</xsl:when>
			<xsl:otherwise>
				<dc:identifier>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</dc:identifier>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:location[mods:url]" as="item()*">
		<dc:identifier>
			<xsl:value-of select="mods:url" disable-output-escaping="no"/>
		</dc:identifier>
	</xsl:template>
	<xsl:template match="mods:language" as="item()*">
		<dc:language>
			<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
		</dc:language>
	</xsl:template>
	<xsl:template match="mods:relatedItem" as="item()*">
		<xsl:choose>
			<xsl:when test="@type='original'">
				<xsl:for-each select="*">
					<dc:source>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</dc:source>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="@type='series'"/>
			<xsl:otherwise>
				<xsl:apply-templates mode="makeRelations" select="child::node()"/>
			</xsl:otherwise>
		</xsl:choose>

		<!-- <xsl:if test="//*[local-name()='relation']">
			<dc:relation>
				<xsl:value-of select="//*[local-name()='relation']"/>
			</dc:relation>
		</xsl:if> -->
	</xsl:template>

	<xsl:template match="mods:titleInfo | mods:name | mods:identifier | mods:location " mode="makeRelations" as="item()*">
		<xsl:apply-templates mode="makeRelations" select="child::node()"/>
	</xsl:template>

	<xsl:template match="text()" mode="makeRelations" as="item()*">
		<xsl:if test="normalize-space(.) != ''">
			<dc:relation>
				<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
			</dc:relation>
		</xsl:if>
	</xsl:template>


	<xsl:template match="*" mode="coverage1" as="item()*">
		<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
	</xsl:template>

	<xsl:template match="*" mode="coverage2" as="item()*">
		<xsl:for-each select="*">
			<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>

			<xsl:if test="position()!=last()">--</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mods:accessCondition" as="item()*">
		<dc:rights>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</dc:rights>
	</xsl:template>

	<xsl:template name="name" as="item()*">

		<xsl:variable name="name">

			<xsl:for-each select="mods:namePart[not(@type)]">
				<xsl:value-of select="." disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no"> </xsl:text>
			</xsl:for-each>
			<xsl:value-of select="mods:namePart[@type='family']" disable-output-escaping="no"/>
			<xsl:if test="mods:namePart[@type='given']">
				<xsl:text disable-output-escaping="no">, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='given']" disable-output-escaping="no"/>
			</xsl:if>
			<xsl:if test="mods:namePart[@type='date']">
				<xsl:text disable-output-escaping="no">, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='date']" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no"/>
			</xsl:if>

			<!-- <xsl:if test="mods:displayForm">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="mods:displayForm"/>
				<xsl:text>) </xsl:text>
			</xsl:if> -->
			<xsl:for-each select="mods:role[mods:roleTerm[@type='text']!='creator']">
				<xsl:text disable-output-escaping="no"> (</xsl:text>
				<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">) </xsl:text>
			</xsl:for-each>
		</xsl:variable>

		<xsl:value-of select="normalize-space($name)" disable-output-escaping="no"/>
		<!-- <xsl:if test="mods:affiliation">
			<xsl:text>. </xsl:text>
		</xsl:if>
		<xsl:value-of select="mods:affiliation"/>
		<xsl:if test="mods:description">
			<xsl:text>. </xsl:text>
		</xsl:if>
		<xsl:value-of select="mods:description"/> -->
	</xsl:template>
	<xsl:template match="mods:dateIssued[@point='start'] |mods:dateCreated[@point='start'] | mods:dateCaptured[@point='start'] | mods:dateOther[@point='start'] " as="item()*">
		<xsl:variable name="dateName" select="local-name()"/>
		<dc:date>
			<xsl:value-of select="." disable-output-escaping="no"/>-<xsl:value-of select="../*[local-name()=$dateName][@point='end']" disable-output-escaping="no"/></dc:date>
	</xsl:template>
	<xsl:template match="mods:temporal[@point='start']  " as="item()*">
		<xsl:value-of select="." disable-output-escaping="no"/>-<xsl:value-of select="../mods:temporal[@point='end']" disable-output-escaping="no"/></xsl:template>
	<xsl:template match="mods:temporal[@point!='start' and @point!='end']  " as="item()*">
		<xsl:value-of select="." disable-output-escaping="no"/>
	</xsl:template>
	<!-- suppress all else:-->
	<xsl:template match="*" as="item()*"/>
</xsl:stylesheet>