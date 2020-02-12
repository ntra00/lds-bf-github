<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mets xlink mods" 
	xmlns:mets="http://www.loc.gov/METS/" 
	xmlns:mods="http://www.loc.gov/mods/v3" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns="local" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--print material page links-->
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

	<xsl:key name="file" match="/mets:mets/mets:fileSec/mets:fileGrp/mets:file" use="@ID"/>
	<xsl:key name="dmdid" match="/mets:mets/mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods/mods:relatedItem" use="@ID"/>
	<xsl:key name="id" match="*[@ID]" use="@ID"/>
	<!-- this program gets the host mets in order to build the volume navigation -->
	<!-- added deep links 8/6/09 -->
	<xsl:template match="/mets:mets">
		<pages>
			<xsl:call-template name="displayImage"/>
			<xsl:apply-templates select="mets:structMap//mets:div[@TYPE='pm:printMaterial']"/>
			<xsl:apply-templates select="//mods:mods/mods:relatedItem[@type='host'][mods:identifier[@type='local' and @displayLabel='IHASDigitalID']]"/>
		</pages>
	</xsl:template>


	<xsl:template name="displayImage">
		<xsl:if test="//mets:div[mets:fptr][@LABEL='thumb']">
			<displayImage>
				<xsl:apply-templates select="//mets:structMap//mets:div[mets:fptr][@LABEL='thumb']"/>
			</displayImage>
		</xsl:if>
	</xsl:template>

	<xsl:template match="mets:div[@TYPE='pm:printMaterial']">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="mets:div[@TYPE='pm:page']">
		<xsl:if test="@LABEL!='target' or not(@LABEL)">
			<page>
				<xsl:choose>
					<xsl:when test="mets:div[@TYPE='pm:image' ]">					
					<image href="{key('file',mets:div/mets:fptr[2]/@FILEID)/mets:FLocat/@xlink:href}"/>
					</xsl:when>
<xsl:otherwise>					
					<image href="{key('file',mets:fptr[2]/@FILEID)/mets:FLocat/@xlink:href}"/>
</xsl:otherwise>			
				</xsl:choose>
				
				<xsl:if test="key('dmdid',@DMDID)">
					<xsl:for-each select="key('dmdid',@DMDID)/mods:relatedItem">
						<xsl:variable name="link">
							<xsl:choose>
								<xsl:when test="contains(mods:identifier[@type='url'],'extent:')">
									<xsl:value-of select="substring-before(mods:identifier[@type='url'],'extent:')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="mods:identifier[@type='url']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<href file="{$link}" rel="no-follow">
							<xsl:value-of select="normalize-space(mods:titleInfo)"/>
						</href>
					</xsl:for-each>
				</xsl:if>
				<xsl:apply-templates/>
			</page>
		</xsl:if>
	</xsl:template>
	<xsl:template match="mets:div[contains(@TYPE,'illustration')]/mets:div[contains(@TYPE,'pm:image')]">
		<illustration>
			<image href="{key('file',mets:fptr[2]/@FILEID)/mets:FLocat/@xlink:href}"/>
		</illustration>
	</xsl:template>
	<xsl:template match="mets:div[@TYPE='pm:text'] |mets:div[@TYPE='pm:ocrText'] ">
		<ocrText href="{key('file',mets:fptr[1]/@FILEID)/mets:FLocat/@xlink:href}"/>
	</xsl:template>
	<xsl:template match="mets:div[contains(@TYPE,'transcription')  or contains(@TYPE,'sheetMusicLyrics')]">
		<lyrics>
			<text href="{key('file',mets:fptr/@FILEID)/mets:FLocat/@xlink:href}"/>
		</lyrics>
	</xsl:template>
	<xsl:template match="mods:relatedItem[@type='host'][mods:identifier[@type='local' and @displayLabel='IHASDigitalID']]">
		<xsl:variable name="metsURL" select="concat('/loc.natlib.ihas.',mods:identifier[@type='local' and @displayLabel='IHASDigitalID'],'.mets.xml')"/>
		<!-- <xsl:variable name="metsURL" select="concat('http://lcweb2.loc.gov:8081/diglib/vols/',mods:identifier[@type='url'],'mets.xml')"/> -->
		<volumes>
			<xsl:variable name="hostMETS" select="document($metsURL)/mets:mets"/>
			<xsl:apply-templates select="$hostMETS//mets:div[@TYPE='cr:member']"/>
		</volumes>
	</xsl:template>
	<xsl:template match="mets:div[@TYPE='cr:member']">
		<xsl:if test="not(key('id',@DMDID)/mods:note[@type='digitized images'])">
			<volume>
				<position>
					<xsl:value-of select="position()"/>
				</position>
				<link>
					<xsl:value-of select="mets:div[@TYPE='pm:printMaterial']/mets:mptr/@xlink:href"/>
				</link>
				<label>
					<xsl:value-of select="mets:div[@TYPE='pm:printMaterial']/@LABEL"/>
				</label>
			</volume>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
