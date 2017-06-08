<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mets xlink mods tei lp" extension-element-prefixes="xdmp" default-validation="strip" input-type-annotations="unspecified" xmlns:xdmp="http://marklogic.com/xdmp" xmlns:lp="http://www.marklogic.com/ps/lib/l-param" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="local">

	<!--input is mets, output is local-->
	<xdmp:import-module namespace="http://www.marklogic.com/ps/lib/l-param" href="/nlc/lib/l-param.xqy"/>

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<xsl:include href="utils.xsl"/>
	<xsl:param name="url"/>

	<xsl:param name="id"/>
	<xsl:variable name="base-url">
		<xsl:value-of select="concat('http://', $hostname,'/nlc/detail.xqy?')" disable-output-escaping="no"/>
	</xsl:variable>
	<xsl:variable name="params" select="lp:remove-digital-params($metsprofile)"/>
	<xsl:variable name="default-desired-params">
		<params xmlns="http://www.marklogic.com/ps/params"/>
	</xsl:variable>
	<xsl:variable name="default-params" select="lp:param-string(lp:set-digital-params($params , 'default', $metsprofile , $default-desired-params))"/>
	<xsl:variable name="contactsheet-params" select="lp:param-string(lp:set-digital-params($params , 'contactsheet', $metsprofile ,$default-desired-params))"/>
	<xsl:variable name="pageturner-params" select="lp:param-string(lp:set-digital-params($params , 'pageturner', $metsprofile ,$default-desired-params))"/>
	<!--<xsl:if test="$metsprofile='printMaterial' or $metsprofile='photoObject' "> 
		<xsl:variable name="contactsheet-params" select="lp:param-string(lp:set-digital-params($params , 'contactsheet', $metsprofile ,$default-desired-params))"/>
		<xsl:variable name="pageturner-params" select="lp:param-string(lp:set-digital-params($params , 'pageturner', $metsprofile ,$default-desired-params))"/>
	</xsl:if>-->

	<xsl:variable name="photolist" select="('photoObject','simplePhoto','photoBatch')"/>
	<xsl:key name="file" match="/mets:mets/mets:fileSec/mets:fileGrp/mets:file" use="@ID"/>
	<xsl:key name="serviceFile" match="/mets:mets/mets:fileSec/mets:fileGrp[@USE='SERVICE']/mets:file" use="@ID"/>
	<xsl:key name="masterFile" match="/mets:mets/mets:fileSec/mets:fileGrp[@USE='MASTER']/mets:file" use="@ID"/>
	<!-- for lyrics, other xml stuff -->
	<xsl:key name="id" match="*[@ID]" use="@ID"/>

	<xsl:template match="/mets:mets" as="item()*">
		<menu>
			<profile>
				<xsl:value-of select="$metsprofile" disable-output-escaping="no"/>
			</profile>
			<xsl:choose>
				<xsl:when test="$metsprofile='simpleAudio'">
					<whole>
						<part>
							<sectionTitle>Audio Views:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
							<href parameters="{$default-params}" behavior="default">Description</href>
							<!-- default has full in it for simpleAudio -->
							<xsl:if test="count(//mets:div[contains(@TYPE,'image')]) = 1 and //mods:identifier[@type='index']='afc9999005'">
								<href behavior="enlarge">Enlargement</href>
							</xsl:if>
						</part>
						<part>
							<sectionTitle>Audio Formats:</sectionTitle>
							<xsl:for-each select="key('serviceFile',mets:structMap//mets:div[@TYPE='sa:recording']/mets:fptr/@FILEID)">
								<href icon="/marklogic/static/img/audio.gif" file="{mets:FLocat/@xlink:href}">
									<xsl:choose>
										<xsl:when test="@MIMETYPE='audio/mp3'">Play MP3</xsl:when>
										<xsl:when test="@MIMETYPE='application/x-pn-realaudio'">Play RealMedia</xsl:when>
									</xsl:choose>
								</href>
							</xsl:for-each>
						</part>
						<xsl:if test="mets:structMap/mets:div/mets:div[@TYPE='cd:booklet']">
							<part>
								<sectionTitle>Additional Materials:</sectionTitle>
								<href behavior="pageturner">CD Booklet</href>
							</part>
						</xsl:if>
						<xsl:if test="//mods:note[@type='Standard Restriction']='Due to copyright restrictions, only excerpts from this item are available.' or        //mods:accessCondition[@type='restrictionOnAccess']='Due to copyright restrictions, only excerpts from this item are available.'">
							<comment>The rights owner for this item has granted permission to use
								only a portion of the material online. An excerpt of the recording
								is available here; if you are interesting in hearing the complete
								version you may do so from a computer located in one of the
								Library's Reading Rooms. For more information about visiting the
								Library of Congress please see: <a href="http://www.loc.gov/loc/visit/">http://www.loc.gov/loc/visit/</a></comment>
						</xsl:if>

						<xsl:call-template name="seeAlso"/>
						<xsl:call-template name="recordformats"/>
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='pdfDoc'">
					<whole>
						<part>
							<sectionTitle>PDF Views</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
							<xsl:for-each select="key('file',mets:structMap/mets:div/mets:div/mets:fptr[1]/@FILEID)">
								<href file="{mets:FLocat/@xlink:href}">View PDF <xsl:if test="@SIZE!=''">[<xsl:call-template name="fileSize">
											<xsl:with-param name="filesize">
												<xsl:value-of select="@SIZE" disable-output-escaping="no"/>
											</xsl:with-param>
		    </xsl:call-template>]</xsl:if></href>
							</xsl:for-each>
							<comment>Note: To view PDF files through your browser, you may need to
								download the freely available <a href="http://www.adobe.com/products/acrobat/readstep2.html">Adobe Acrobat reader</a>.</comment>
						</part>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='article'">
					<whole>
						<part>
							<!-- article is either xhtml blurb or tei -->
							<xsl:for-each select="mets:structMap/mets:div[@TYPE='art:blurb']">
								<xsl:variable name="blurbID" select="mets:fptr/@FILEID"/>
								<xsl:variable name="blurbURL" select="key('id',$blurbID)/mets:FLocat/@xlink:href"/>
								<content>
									<xsl:copy-of select="document($blurbURL)/*/*/*" copy-namespaces="yes"/>
								</content>
							</xsl:for-each>
							<xsl:for-each select="mets:structMap//mets:div[@TYPE='art:tei']">
								<xsl:variable name="teiID" select="mets:fptr/@FILEID"/>
								<xsl:variable name="teiURL" select="key('id',$teiID)/mets:FLocat/@xlink:href"/>
								<xsl:variable name="teiDoc" select="xdmp:http-get($teiURL)[2]"/>
								<content>
									<xsl:apply-templates select="$teiDoc//tei:text"/>
								</content>
							</xsl:for-each>
						</part>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
						<xsl:if test="//mods:subject">
							<part>
								<sectionTitle>More Items:</sectionTitle>
								<xsl:for-each select="//mods:subject">
									<xsl:variable name="search">
										<xsl:choose>
											<xsl:when test="mods:name">
												<xsl:for-each select="mods:name[1]/*[not(self::mods:role)]">
													<xsl:apply-templates select="child::node()"/>
													<xsl:if test="position()!=last()">
														<xsl:text disable-output-escaping="no"> </xsl:text>
													</xsl:if>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates select="."/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:variable name="searchTerm">
										<xsl:value-of select="encode-for-uri($search)" disable-output-escaping="no"/>
									</xsl:variable>
									<xsl:variable name="url">
										<xsl:choose>
											<xsl:when test="mods:name">
												<xsl:value-of select="concat('/nlc/search.xqy?q=(subjectname:',$searchTerm,')or  (fullname=',$searchTerm,')')" disable-output-escaping="no"/>
											</xsl:when>
											<xsl:when test="contains($search,' ')">
												<xsl:value-of select="concat('/nlc/search.xqy?q=&quot;',$searchTerm,'&quot;&amp;qname=idx:topic')" disable-output-escaping="no"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat('/nlc/search.xqy?q=',$searchTerm,'&quot;&amp;qname=idx:topic')" disable-output-escaping="no"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>

									<href file="{$url}">
										<xsl:value-of select="$search" disable-output-escaping="no"/>
									</href>
								</xsl:for-each>
							</part>
						</xsl:if>
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='biography'">
					<whole>
						<part>
							<!--<sectionTitle>Biography Views:</sectionTitle>-->
							<!-- article is either xhtml blurb or tei -->
							<xsl:for-each select="mets:structMap/mets:div[@TYPE='bio:blurb']">
								<xsl:variable name="blurbID" select="mets:fptr/@FILEID"/>
								<xsl:variable name="blurbURL" select="key('id',$blurbID)/mets:FLocat/@xlink:href"/>
								<content>

									<xsl:copy-of select="document($blurbURL)/*/*/*" copy-namespaces="yes"/>
								</content>
							</xsl:for-each>
						</part>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
						<!--						<xsl:variable name="searchTerm">							<xsl:apply-templates select="//mods:subject[1]"/>						</xsl:variable>-->
						<xsl:variable name="search">
							<xsl:choose>
								<xsl:when test="//mods:subject/mods:name">
									<!--<xsl:apply-templates select="//mods:subject/mods:name[1]"/>-->
									<xsl:for-each select="//mods:subject/mods:name[1]/*[not(self::mods:role)]">
										<xsl:apply-templates select="child::node()"/>
										<xsl:if test="position()!=last()">
											<xsl:text disable-output-escaping="no"> </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="contains(//mods:mods/mods:titleInfo/mods:title,',')">
									<xsl:value-of select="substring-before(//mods:mods/mods:titleInfo/mods:title,',')" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="//mods:mods/mods:titleInfo/mods:title" disable-output-escaping="no"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="searchTerm">
							<xsl:value-of select="encode-for-uri(normalize-space($search))" disable-output-escaping="no"/>
						</xsl:variable>
						<xsl:if test="$searchTerm!=''">
							<part>
								<sectionTitle>More Items:</sectionTitle>
								<href file="{concat('/nlc/search?q=(name:&quot;',$searchTerm,'&quot;) or (subjectname=&quot;', $searchTerm, '&quot;)' )}">
									<xsl:value-of select="normalize-space($search)" disable-output-escaping="no"/>
								</href>
							</part>
						</xsl:if>
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='patriotismSongCollection' or $metsprofile='songOfAmericaCollection'">
					<whole>
						<part>

							<xsl:for-each select="mets:structMap/mets:div/mets:div[@TYPE='p:blurb']">
								<xsl:variable name="blurbID" select="mets:fptr/@FILEID"/>
								<xsl:variable name="blurbURL" select="key('id',$blurbID)/mets:FLocat/@xlink:href"/>

								<content>
									<xsl:copy-of select="document($blurbURL)/*/*/*" copy-namespaces="yes"/>
								</content>
							</xsl:for-each>
						</part>
						<xsl:if test="mets:structMap/mets:div/mets:div[@TYPE='p:collectionMembers']">
							<sectionTitle>Available Items:</sectionTitle>
							<xsl:if test="not(mets:structMap/mets:div/mets:div[@TYPE='p:collectionMembers']/*)">
								<comment>No items available</comment>
							</xsl:if>
							<xsl:for-each select="mets:structMap/mets:div/mets:div[@TYPE='p:collectionMembers']">
								<xsl:for-each select="mets:div[not(@TYPE='p:otherObjects')]">
									<part>
										<partTitle>
											<xsl:choose>
												<xsl:when test="@TYPE='p:scoreObjects'">Scores</xsl:when>
												<xsl:when test="@TYPE='p:sheetMusicObjects'">Sheet 	Music</xsl:when>
												<xsl:when test="@TYPE='p:songSheetObjects'">Song Sheets</xsl:when>
												<xsl:when test="@TYPE='p:soundRecordingObjects'">Sound Recordings</xsl:when>
											</xsl:choose>
										</partTitle>
										<xsl:for-each select="mets:div">
											<!--cd:audio-->
											<!-- local digital ID -->
											<href file="../{mets:mptr/@xlink:href}/">
												<xsl:value-of select="@LABEL" disable-output-escaping="no"/>
											</href>
										</xsl:for-each>
									</part>
								</xsl:for-each>
								<xsl:if test="mets:div[@TYPE='p:otherObjects']">
									<part>
										<partTitle>
											<!--<img align="left" height="20" width="20" alt="" src="/marklogic/static/img/other-icon.gif"/>-->Other
											Materials</partTitle>
										<xsl:for-each select="mets:div[@TYPE='p:otherObjects']">
											<xsl:for-each select="mets:div">
												<!--cd:audio-->
												<!-- local digital ID -->
												<href file="../{mets:mptr/@xlink:href}/">
													<xsl:value-of select="@LABEL" disable-output-escaping="no"/>
												</href>
											</xsl:for-each>
										</xsl:for-each>
									</part>
								</xsl:if>
							</xsl:for-each>
							<xsl:call-template name="seeAlso"/>
							<!-- <xsl:call-template name="recordformats"/> -->
						</xsl:if>
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='newCompactDisc'">
					<whole>
						<part>
							<sectionTitle>Compact Disc Views:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
						</part>
						<xsl:choose>
							<xsl:when test="not(//mods:relatedItem[@type='constituent']/mods:relatedItem[@type='constituent'])">
								<xsl:choose>
									<xsl:when test="count(//mets:div[@TYPE='cd:disc']) &gt; 1">
										<xsl:for-each select="//mets:structMap/mets:div/mets:div[@TYPE='cd:disc']">
											<xsl:variable name="disclabel">
												<xsl:choose>
													<xsl:when test="@LABEL">
														<xsl:value-of select="@LABEL" disable-output-escaping="no"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="position()" disable-output-escaping="no"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:variable>
											<part>
												<sectionTitle>Disc <xsl:value-of select="$disclabel" disable-output-escaping="no"/> Contents:</sectionTitle>
												<xsl:for-each select="key('id',*/@DMDID)">
													<xsl:call-template name="contents"/>
												</xsl:for-each>
											</part>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<part>
											<sectionTitle>Disc Contents:</sectionTitle>
											<xsl:for-each select="//mods:relatedItem[@type='constituent'][@ID]">
												<xsl:call-template name="contents"/>
											</xsl:for-each>
										</part>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<part>
									<href behavior="contents">Disc Contents</href>
								</part>
								<items>
									<xsl:for-each select="//mods:mods/mods:relatedItem[@type='constituent'][@ID]">
										<xsl:call-template name="contents"/>
									</xsl:for-each>
								</items>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="mets:structMap/mets:div/mets:div[@TYPE='cd:booklet']">
							<xsl:choose>
								<xsl:when test="key('id','booklet')/mods:note[@type='Standard Restriction']= 'This item is unavailable due to copyright restrictions.'"/>
								<xsl:when test="key('id','booklet')/mods:accessCondition[@type='restrictionOnAccess']= 'This item is unavailable due to copyright restrictions.'"/>
								<xsl:otherwise>
									<part>
										<sectionTitle>Additional Materials:</sectionTitle>
										<href behavior="pageturner" parameters="section=booklet">CD Booklet</href>
									</part>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
					<items>
						<xsl:for-each select="//mods:mods/mods:relatedItem[@type='constituent'][@ID]">
							<xsl:call-template name="subTracks"/>
						</xsl:for-each>
					</items>
					<tracks>
						<xsl:for-each select="//mods:relatedItem[@type='constituent'][@ID][not(mods:relatedItem[@type='constituent'])]">
							<xsl:call-template name="singleTracks">
								<!-- if multiple layers, back is contents, otherwise, it's default -->
								<xsl:with-param name="back">
									<xsl:choose>
										<xsl:when test="mods:relatedItem[@type='constituent'][@ID]">contents</xsl:when>
										<xsl:otherwise>default</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</tracks>
				</xsl:when>
				<xsl:when test="$metsprofile='compactDisc'">
					<whole>
						<part>
							<sectionTitle>Compact Disc Views:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
						</part>
						<xsl:if test="mets:structMap/mets:div/mets:div[@TYPE='cd:booklet']">
							<xsl:choose>
								<xsl:when test="key('id','booklet')/mods:note[@type='Standard Restriction']= 'This item is unavailable due to copyright restrictions.'"/>
								<xsl:when test="key('id','booklet')/mods:accessCondition[@type='restrictionOnAccess']= 'This item is unavailable due to copyright restrictions.'"/>
								<xsl:otherwise>
									<part>
										<sectionTitle>Additional Materials:</sectionTitle>
										<href behavior="pageturner" parameters="section=booklet">CD Booklet</href>
									</part>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="//mods:relatedItem[@type='constituent']">
							<part>
								<sectionTitle>Disc Contents:</sectionTitle>
								<xsl:for-each select="//mods:relatedItem[@type='constituent']">
									<xsl:call-template name="contents"/>
								</xsl:for-each>
							</part>
						</xsl:if>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
					<items>
						<xsl:for-each select="//mods:mods/mods:relatedItem[@type='constituent'][@ID]">
							<xsl:call-template name="subTracks">
								<xsl:with-param name="back">default</xsl:with-param>
								<!-- back to default, not contents-->
							</xsl:call-template>
						</xsl:for-each>
					</items>
					<tracks>
						<xsl:for-each select="//mods:relatedItem[@type='constituent'][@ID][not(mods:relatedItem[@type='constituent'])]">
							<xsl:call-template name="singleTracks">
								<xsl:with-param name="back">default</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</tracks>
				</xsl:when>
				<xsl:when test="$metsprofile='recordedEvent'">
					<whole>
						<part>
							<sectionTitle>Recording Views:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
						</part>
						<xsl:if test="//mods:relatedItem[@type='constituent']">
							<xsl:choose>
								<!-- if not multiple parts layers, use "left nav' for contents -->
								<xsl:when test="not(//mods:relatedItem[@type='constituent']/mods:relatedItem[@type='constituent'])">
									<part>
										<sectionTitle>Recording Contents:</sectionTitle>
										<xsl:for-each select="//mods:relatedItem[@type='constituent']">
											<xsl:call-template name="contents"/>
										</xsl:for-each>
									</part>
								</xsl:when>
								<xsl:otherwise>
									<!-- this shows on main page -->
									<part>
										<href behavior="contents">Recording Contents</href>
									</part>
									<!-- this is for tracks below contents -->
									<items>
										<xsl:for-each select="//mods:mods/mods:relatedItem[@type='constituent'][@ID]">
											<xsl:call-template name="subTracks"/>
										</xsl:for-each>
									</items>
									<!-- use contents behavior-->
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="mets:structMap/mets:div/mets:div[@TYPE='re:eventProgram' or @TYPE='re:text']">
							<part>
								<sectionTitle>Additional Materials:</sectionTitle>
								<xsl:for-each select="mets:structMap/mets:div/mets:div[@TYPE='re:eventProgram']">
									<href behavior="pageturner" parameters="section=booklet">Program</href>
								</xsl:for-each>
								<xsl:for-each select="mets:structMap/mets:div/mets:div[@TYPE='re:text']">
									<href behavior="transcript">Transcript</href>
								</xsl:for-each>
							</part>
						</xsl:if>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
					<items>
						<xsl:for-each select="//mods:mods/mods:relatedItem[@type='constituent']">
							<xsl:call-template name="subTracks"/>
						</xsl:for-each>
					</items>
					<tracks>
						<xsl:for-each select="//mods:relatedItem[@type='constituent'][@ID][not(mods:relatedItem[@type='constituent'])]">
							<xsl:call-template name="singleTracks">
								<xsl:with-param name="back">default</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</tracks>
				</xsl:when>
				<xsl:when test="$metsprofile='collectionRecord'">
					<whole>
						<part>
							<sectionTitle>Description:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
						</part>
						<xsl:if test="//mods:relatedItem[@type='constituent']">
							<xsl:choose>
								<!-- if not multiple parts layers, use "left nav' for contents -->
								<xsl:when test="not(//mods:relatedItem[@type='constituent']/mods:relatedItem[@type='constituent'])">
									<part>
										<sectionTitle>Volumes:</sectionTitle>
										<xsl:for-each select="//mods:relatedItem[@type='constituent'][@ID]">
											<xsl:call-template name="contents"/>
										</xsl:for-each>
									</part>
								</xsl:when>
								<xsl:otherwise>
									<!-- this shows on main page -->
									<part>
										<href behavior="contents">Recording Contents</href>
									</part>
									<!-- this is for tracks below contents -->
									<items>
										<xsl:for-each select="//mods:mods/mods:relatedItem[@type='constituent'][@ID]">
											<xsl:call-template name="subTracks"/>
										</xsl:for-each>
									</items>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='modsBibRecord'">
					<xsl:variable name="label">
						<xsl:choose>
							<xsl:when test="contains(//mods:relatedItem[@type='host'][1],'ncyclopedia') or //mods:relatedItem[@type='host'][1]='Guide to Performing Arts Resources'">Resource</xsl:when>
							<xsl:when test="contains(//mods:relatedItem[@type='host'][1]/mods:titleInfo/mods:title[1],'M1508')">Musical Works</xsl:when>
							<xsl:otherwise>Record</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="showlabel">
						<xsl:if test="//mets:div[contains(@TYPE,'image')] or //mods:location/mods:url[@displayLabel='Online Collection' or @displayLabel='Finding Aid'] or $label='Show'">yes</xsl:if>
					</xsl:variable>
					<whole>
						<part>
							<xsl:if test="$showlabel='yes'">
								<sectionTitle>
									<xsl:value-of select="$label" disable-output-escaping="no"/> Views:</sectionTitle>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="count(//mets:div[contains(@TYPE,'image')]) &gt; 1">
									<href parameters="{$default-params}" behavior="default">Description</href>
									<href behavior="pageturner">Page Turner</href>
									<href behavior="contactsheet">Contact Sheet</href>
								</xsl:when>
								<xsl:when test="count(//mets:div[contains(@TYPE,'image')]) = 1 and //mods:identifier[@type='index']='afc9999005'">
									<!-- <xsl:if test="//mods:identifier[@type='index']='afc9999005'"> -->
									<href parameters="{$default-params}" behavior="default">Description</href>
									<href behavior="enlarge" parameters="from=default">Enlargement</href>
								</xsl:when>
								<xsl:when test="contains(//mods:relatedItem[@type='host'][1],'Showtime!')">
									<href parameters="{$default-params}" behavior="default">Description</href>
									<xsl:if test="//mods:relatedItem[@type='constituent']">
										<part>
											<sectionTitle>Contains:</sectionTitle>
											<xsl:for-each select="//mods:relatedItem[@type='constituent'][@ID]">
												<xsl:call-template name="contents"/>
											</xsl:for-each>
										</part>
									</xsl:if>
								</xsl:when>
								<xsl:when test="contains($digid,'consortium') and //mods:location/mods:url[@usage='primary display']">
									<xsl:variable name="display" select="//mods:location/mods:url[@usage='primary display']"/>
									<xsl:variable name="repository" select="//mods:identifier[@type='membership'][text()!='consortium']"/>
									<xsl:variable name="repositoryLabel" select="concat(translate(substring($repository,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($repository,2))"/>
									<href parameters="{$default-params}" behavior="default">Description</href>
									<href file="{$display}">Go to Item at <xsl:value-of select="$repositoryLabel" disable-output-escaping="no"/></href>
								</xsl:when>
								<xsl:otherwise>
									<href parameters="{$default-params}" behavior="default">Description</href>
									<xsl:if test="//mods:relatedItem[@type='constituent']">
										<href behavior="contents">Contents</href>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="//mods:location/mods:url[@displayLabel='Online Collection' or @displayLabel='Finding Aid']">
								<xsl:for-each select="//mods:location/mods:url[@displayLabel='Online Collection' or @displayLabel='Finding Aid']">
									<href file="{.}">
										<xsl:choose>
											<xsl:when test="@displayLabel='Online Collection'">
												<xsl:attribute name="icon">/marklogic/static/img/pae-online-icon.gif</xsl:attribute>
												<xsl:attribute name="alt">online collection link</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="icon">/marklogic/static/imgpae-findaid-icon.gif</xsl:attribute>
												<xsl:attribute name="alt">finding aid link</xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:value-of select="@displayLabel" disable-output-escaping="no"/>
									</href>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="contains(//mods:note[@type='Source'],'Jazz on the Screen') or //mods:identifier[@type='index']='jots'">
								<comment>
									<em>Jazz on the Screen</em>is a reference work of filmographic
									information and does not point to digitized versions of the
									items described. The Library of Congress may or may not own a
									copy of a particular film or video. To request additional
									information <a href="http://www.loc.gov/rr/askalib/ask-record.html">Ask a
										Librarian</a>.</comment>
							</xsl:if>
							<xsl:if test="//mods:identifier[@type='index']='grace'">
								<comment>This item can be found in the Chasanoff/Elozua Amazing
									Grace Collection at the Library of Congress. A small number of
									recordings of "Amazing Grace" can be heard as part of the <a href="../html/grace/grace-timeline.html"> timeline
										presentation</a>.</comment>
							</xsl:if>
							<xsl:if test="not(//mods:location/mods:url[@displayLabel='Online Collection']) and  //mods:identifier[@type='index']='scdb'">
								<xsl:variable name="ask">
									<xsl:choose>
										<xsl:when test="contains(mods:location/mods:physicalLocation,'Performing')">ask-perform.html</xsl:when>
										<xsl:when test="contains(mods:location/mods:physicalLocation,'Music')">ask-perform.html</xsl:when>
										<xsl:when test="contains(mods:location/mods:physicalLocation,'Motion')">ask-mopic.html</xsl:when>
										<xsl:when test="contains(mods:location/mods:physicalLocation,'Folklife')">ask-folklife.html</xsl:when>
										<xsl:when test="contains(mods:location/mods:physicalLocation,'Manuscripts ')">ask-mss.html</xsl:when>
										<xsl:when test="contains(mods:location/mods:physicalLocation,'Recorded ')">ask-record.html</xsl:when>
									</xsl:choose>
									<xsl:if test="mods:location/mods:url[@displayLabel='Finding Aid']">View the <a href="{mods:location/mods:url[@displayLabel='Finding Aid']}">Finding Aid</a>.</xsl:if>
								</xsl:variable>
								<comment>This collection is not available online. For more
									information on accessing this material:<br/><a href="{concat('http://www.loc.gov/rr/askalib/',$ask)}">Ask a
										Librarian</a></comment>
							</xsl:if>
						</part>
						<!-- <items>							<xsl:for-each select="//mods:mods/mods:relatedItem[@type='constituent'][@ID]">								<xsl:call-template name="subTracks"/>							</xsl:for-each>						</items> -->
						<xsl:if test="mets:structMap//mets:div[@TYPE='mo:text']">
							<part>
								<sectionTitle>Additional Materials:</sectionTitle>
								<xsl:for-each select="mets:structMap//mets:div[@TYPE='mo:text']">
									<href behavior="transcript">Transcript</href>
								</xsl:for-each>
							</part>
						</xsl:if>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
					<tracks>
						<xsl:for-each select="//mods:relatedItem[@type='constituent'][@ID][not(mods:relatedItem[@type='constituent'])]">
							<xsl:call-template name="singleTracks">
								<xsl:with-param name="back">default</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</tracks>
				</xsl:when>
				<xsl:when test="$metsprofile='ead'">
					<whole>
						<part>
							<sectionTitle>Finding Aid Views:</sectionTitle>
							<href behavior="default"/>Catalog Record Description
							<href file="/marklogic/ead.xyq?_xq=searchMfer02.xq&amp;_id={$digid}&amp;&amp;_faSection=overview&amp;_faSubsection=did&amp;_dmdid=d2381e6">Full Document</href>
						</part>

						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='videoProgram'">
					<whole>
						<part>
							<sectionTitle>Video Views:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
						</part>
						<part>
							<sectionTitle>Video Formats:</sectionTitle>
							<xsl:for-each select="mets:structMap/mets:div[@TYPE='vp:videoProgram']/mets:div[@TYPE='vp:programSegment']/mets:div[@TYPE='vp:video']/mets:fptr">
								<xsl:choose>
									<xsl:when test="key('file',@FILEID)/@MIMETYPE='video/mpeg' and key('file',@FILEID)/../@USE='DISPLAYING MASTER'">
										<href icon="/marklogic/static/img/images/video.gif" file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">Play MPEG</href>
									</xsl:when>
									<xsl:when test="key('file',@FILEID)/@MIMETYPE='application/x-pn-realaudio'">
										<href icon="/marklogic/static/img/video.gif" file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">Play RealMedia</href>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</part>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
				</xsl:when>

				<xsl:when test="$metsprofile=$photolist">
					<!--photobatch, photoObject, simplePhoto-->
					<xsl:variable name="gridlabel">
						<xsl:choose>
							<xsl:when test="$metsprofile='photoObject'">All versions</xsl:when>
							<xsl:otherwise>Contact sheet</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<whole>
						<part>
							<sectionTitle>Image Views:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
						</part>
						<part>
							<xsl:choose>
								<xsl:when test="count(mets:structMap/mets:div/mets:div[@TYPE='photo:version'])=1">
									<xsl:variable name="new-params" select="lp:param-string(lp:set-digital-params($params , 'pageturner', $metsprofile , $default-desired-params))"/>
									<href behavior="pageturner" parameters="{$new-params}">View</href>
								</xsl:when>
								<xsl:otherwise>
									<!-- versions behavior-->
									<xsl:variable name="new-params" select="lp:param-string(lp:set-digital-params($params , 'contactsheet', $metsprofile , $default-desired-params))"/>
									<href behavior="contactsheet" parameters="{$new-params}">
										<xsl:value-of select="$gridlabel" disable-output-escaping="no"/>
									</href>
								</xsl:otherwise>
							</xsl:choose>
						</part>
						<xsl:if test="count(mets:structMap/mets:div/mets:div[@TYPE='photo:version'])&gt; 1">
							<part>
								<sectionTitle>Versions:</sectionTitle>
								<xsl:for-each select="mets:structMap/mets:div[@TYPE='photo:photoObject']/mets:div[@TYPE='photo:version']">
									<xsl:variable name="desired-params">
										<params xmlns="http://www.marklogic.com/ps/params">
											<param>
												<name>section</name>
												<value>
													<xsl:value-of select="@DMDID" disable-output-escaping="no"/>
												</value>
											</param>
										</params>
									</xsl:variable>
									<xsl:variable name="new-params" select="lp:param-string(lp:set-digital-params($params , 'pageturner', $metsprofile , $desired-params))"/>
									<href behavior="pageturner" parameters="{$new-params}">
										<xsl:choose>
											<xsl:when test="key('id',@DMDID)/mods:note[@type='version']">
												<xsl:value-of select="key('id',@DMDID)/mods:note[@type='version']" disable-output-escaping="no"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="key('id',@DMDID)/mods:titleInfo[not(@type)][1]/mods:title" disable-output-escaping="no"/>
											</xsl:otherwise>
										</xsl:choose>
									</href>
								</xsl:for-each>
								<xsl:call-template name="authority-browses"/>
							</part>
						</xsl:if>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
				</xsl:when>
				<!--<xsl:when test="$metsprofile='photoBatch'">					
					<whole>
						<part>
							<sectionTitle>Image Views:</sectionTitle>					
							<href parameters="{$default-params}" behavior="default">Description</href>
							<href behavior="pageturner">View</href>
							<href behavior="contactsheet">Contact Sheet</href>
							
						</part>
						<xsl:call-template name="seeAlso"/>
					    <xsl:call-template name="recordformats"/>
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='simplePhoto'">
					
					<whole>
						<part>
							<sectionTitle>Image Views:</sectionTitle>							
							<href parameters="{$default-params}" behavior="default">Description</href>
							<href behavior="pageturner">Enlargement</href>
						</part>
						<xsl:call-template name="seeAlso"/>
	    					<xsl:call-template name="recordformats"/>
					</whole>
				</xsl:when>-->
				<xsl:when test="$metsprofile='score'">
					<whole>
						<part>
							<sectionTitle>Score &amp; Parts Views:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>
						</part>
						<xsl:if test="mets:structMap/mets:div/mets:div[@TYPE='sc:score']">
							<part>
								<sectionTitle>Score Views:</sectionTitle>
								<href behavior="pageturner">Page Turner</href>
								<href behavior="contactsheet">Contact Sheet</href>
								<xsl:for-each select="mets:structMap/mets:div[@TYPE='sc:scoreObject']/mets:div[@TYPE='sc:score']/mets:fptr">
									<xsl:choose>
										<xsl:when test="key('file',@FILEID)/@MIMETYPE='application/pdf'">
											<href file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">PDF for Printing</href>
										</xsl:when>
										<xsl:when test="key('file',@FILEID)/@MIMETYPE='application/finale'">
											<href file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">Finale Notated Music</href>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</part>
						</xsl:if>
						<xsl:if test="mets:structMap/mets:div/mets:div[@TYPE='sc:parts']">
							<part>
								<sectionTitle>Parts Views:</sectionTitle>
							</part>
							<part>
								<partTitle>Individual Parts:</partTitle>
								<select>
									<xsl:for-each select="mets:structMap/mets:div[@TYPE='sc:scoreObject']/mets:div[@TYPE='sc:parts']/mets:div[@TYPE='sc:part']">
										<href behavior="pageturner" parameters="section={@ID}">
											<xsl:value-of select="translate(key('id',@DMDID)/mods:titleInfo/mods:title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" disable-output-escaping="no"/>
										</href>
									</xsl:for-each>
								</select>
							</part>
							<part>
								<partTitle>All Parts:</partTitle>
								<href behavior="pageturner" parameters="section=ALLPARTS"/>Page Turner
								<href behavior="contactsheet" parameters="section=ALLPARTS"/>Contact	Sheet
								<xsl:for-each select="mets:structMap/mets:div[@TYPE='sc:scoreObject']/mets:div[@TYPE='sc:parts']/mets:fptr">
									<href file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">PDF for Printing</href>
								</xsl:for-each>
							</part>
						</xsl:if>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
				</xsl:when>
				<xsl:when test="$metsprofile='printMaterial' and //mods:relatedItem[@type='host'][contains(@ID,'bibid')] and //mods:part">
					<!-- single part of multivolume -->
					<xsl:call-template name="multivolumePageturning"/>
				</xsl:when>
				<xsl:when test="$metsprofile='printMaterial' and //mods:relatedItem[@type='host'] and //mods:part  and contains(@OBJID,'_')">
					<!-- single part of multivolume -->
					<xsl:call-template name="multivolumePageturning"/>
				</xsl:when>
				<xsl:when test="$metsprofile='printMaterial' and //mods:relatedItem[@type='host']/mods:genre='multivolume monograph'">
					<!-- single part of multivolume -->
					<xsl:call-template name="multivolumePageturning"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- manuscript, manuscriptScore, sheetMusic , print material etc -->
					<whole>
						<part>
							<sectionTitle>
								<xsl:value-of select="$objectType" disable-output-escaping="no"/>Views:</sectionTitle>
							<href parameters="{$default-params}" behavior="default">Description</href>

							<xsl:variable name="pageturner-params" select="lp:param-string(lp:set-digital-params($params , 'pageturner', $metsprofile ,$default-desired-params))"/>
							<href parameters="{$pageturner-params}" behavior="pageturner">View</href>
							<!--<href behavior="pageturner">View</href>-->
							<xsl:if test="count(//mets:div[contains(@TYPE,'page')]) &gt; 1">
								<xsl:variable name="contactsheet-params" select="lp:param-string(lp:set-digital-params($params , 'contactsheet', $metsprofile ,$default-desired-params))"/>
								<href parameters="{$contactsheet-params}" behavior="contactsheet">Contact sheet</href>
							</xsl:if>
						</part>
						<xsl:if test="mets:structMap//mets:div[@TYPE='sm:sheetMusicLyrics']">
							<part>
								<sectionTitle>Sheet Music Lyrics:</sectionTitle>
								<xsl:for-each select="key('masterFile',/mets:mets/mets:structMap//mets:div[@TYPE='sm:sheetMusicLyrics']/mets:fptr/@FILEID)">
									<href behavior="lyrics" icon="/marklogic/static/img/text.gif" file="{mets:FLocat/@xlink:href}">Display Lyrics</href>
								</xsl:for-each>
								<href file="lyricsFO.pdf">PDF for Printing</href>
							</part>
						</xsl:if>
						<xsl:if test="mets:structMap//mets:div[@TYPE='pm:transcription']">
							<part>
								<sectionTitle>Print Material Text:</sectionTitle>
								<xsl:for-each select="key('masterFile',/mets:mets/mets:structMap//mets:div[@TYPE='pm:transcription']/mets:fptr/@FILEID)">
									<href behavior="lyrics" icon="/marklogic/static/img/text.gif" file="{mets:FLocat/@xlink:href}">Display Text</href>
								</xsl:for-each>
								<href file="lyricsFO.pdf">PDF for Printing</href>
							</part>
						</xsl:if>
						<xsl:if test="mets:structMap//mets:div[@TYPE='sm:sheetMusicScore']/mets:fptr">
							<part>
								<xsl:for-each select="mets:structMap//mets:div[@TYPE='sm:sheetMusicScore']/mets:fptr">
									<xsl:choose>
										<xsl:when test="key('file',@FILEID)/@MIMETYPE='application/pdf'">
											<href file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">PDF for Printing</href>
										</xsl:when>
										<xsl:when test="key('file',@FILEID)/@MIMETYPE='application/finale'">
											<href file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">Finale Notated Music</href>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</part>
						</xsl:if>
						<xsl:if test="//mods:relatedItem[@type='constituent']">
							<part>
								<sectionTitle>Contains:</sectionTitle>
								<xsl:for-each select="//mods:relatedItem[@type='constituent'][@ID]">
									<xsl:call-template name="contents"/>
								</xsl:for-each>
							</part>
						</xsl:if>
						<xsl:call-template name="seeAlso"/>
						<!-- <xsl:call-template name="recordformats"/> -->
					</whole>
				</xsl:otherwise>
			</xsl:choose>
		</menu>
	</xsl:template>
	<xsl:template name="seeAlso" as="item()*">

		<xsl:for-each select="//mods:mods/mods:relatedItem[@type='host'][mods:identifier]">
			<xsl:call-template name="makeFromLink"/>
		</xsl:for-each>

		<!-- or @type='otherVersion'] removed so photo objects dont get see alsos-->
		<xsl:if test="//mods:mods/mods:relatedItem[not(@type)][mods:identifier[@type='local']] or //mods:mods/mods:relatedItem[not(@type)][mods:identifier[@type='url']]   or //mods:mods/mods:relatedItem[not(@type)][mods:location[mods:url]] or //mods:relatedItem[@type='preceding' or @type='succeeding'] ">
			<part>
				<sectionTitle>See Also:</sectionTitle>
				<xsl:for-each select="//mods:mods/mods:relatedItem[not(@type)][mods:identifier[@type='local'] or mods:location/mods:url or mods:identifier[@type='url' ] ]| //mods:mods/mods:relatedItem[@type='preceding' or @type='succeeding' or @type='otherVersion']">
					<!-- ???? loc/url or id/@url -->
					<!-- <xsl:variable name="digitalID" select="mods:identifier[@type='local']"/> -->
					<xsl:variable name="displayText">
						<xsl:choose>
							<!-- related item type in lc bib records: -->
							<xsl:when test="@type='preceding' or @type='succeeding' or @type='otherVersion'">
								<!-- <xsl:value-of select="normalize-space(concat(@type,': ',mods:titleInfo/mods:nonSort,' ',mods:titleInfo/mods:title,' ', mods:titleInfo/mods:subTitle))"/> -->
								<xsl:value-of select="normalize-space(concat(mods:titleInfo/mods:nonSort,' ',mods:titleInfo/mods:title,' ', mods:titleInfo/mods:subTitle,'[',@type,']' ))" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:when test="mods:titleInfo/mods:title">
								<xsl:value-of select="normalize-space(concat(mods:titleInfo/mods:nonSort,' ',mods:titleInfo/mods:title,' ', mods:titleInfo/mods:subTitle))" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:when test="mods:location/mods:url[@displayLabel]">
								<xsl:value-of select="mods:location/mods:url/@displayLabel" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:when test="mods:identifier[@displayLabel]">
								<xsl:value-of select="mods:identifier/@displayLabel" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="mods:note" disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-- for lcdb preceding, succeeding: -->
					<xsl:variable name="searchText">
						<xsl:value-of select="normalize-space(mods:titleInfo)" disable-output-escaping="no"/>
					</xsl:variable>
					<xsl:variable name="gmd">
						<xsl:choose>
							<xsl:when test="mods:genre">
								<xsl:value-of select="mods:genre[1]" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:when test="mods:identifier[@type='local'][@displayLabel]">
								<xsl:value-of select="translate(mods:identifier[@type='local']/@displayLabel,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="mods:physicalDescription/mods:form" disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="page">
						<xsl:if test="mods:part/mods:extent/mods:start">
							<xsl:value-of select="number(translate(mods:part/mods:extent/mods:start,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz; !@#$%^*(){}[]\',''))" disable-output-escaping="no"/>
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="endpage">
						<xsl:if test="mods:part/mods:extent/mods:end">
							<xsl:value-of select="number(translate(mods:part/mods:extent/mods:end,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz; !@#$%^*(){}[]\',''))" disable-output-escaping="no"/>
						</xsl:if>
					</xsl:variable>
					<xsl:for-each select="mods:identifier[@type='local'] | mods:identifier[@type='issn'] | mods:identifier[@type='lccn'] | mods:location ">
						<xsl:variable name="identifier">
							<xsl:choose>
								<xsl:when test="@type='local' and starts-with(text(),'(DLC)')">
									<xsl:value-of select="normalize-space(substring-after(text(),'(DLC)') )" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="@type='local'">
									<xsl:value-of select="." disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="@type='issn' or @type='lccn'">
									<xsl:value-of select="concat(@type,':',normalize-space(.))" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="@type='url'">
									<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="mods:url">
									<xsl:value-of select="normalize-space(mods:url)" disable-output-escaping="no"/>
								</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="localLink">
							<xsl:choose>
								<!-- lccn: for now, cheat and use the uri version: (won't work when uri is based on bib ID -->
								<xsl:when test="@type='local' and starts-with(text(),'(DLC)')">../loc.natlib.lcdb.<xsl:value-of select="translate($identifier,' ','')" disable-output-escaping="no"/>/default.html</xsl:when>
								<xsl:when test="starts-with($identifier,'loc.')">
									<xsl:value-of select="concat('../',$identifier,'/')" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="starts-with($identifier,'http://')">
									<xsl:value-of select="$identifier" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="starts-with($identifier,'../')">
									<xsl:value-of select="$identifier" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="contains($identifier,':')">
									<xsl:value-of select="concat('/search?q=',$identifier)" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('../loc.natlib.ihas.',$identifier,'/')" disable-output-escaping="no"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="$page!=''">pageturner.html?page=<xsl:value-of select="$page" disable-output-escaping="no"/></xsl:if>
						</xsl:variable>

						<xsl:variable name="display">
							<xsl:value-of select="$displayText" disable-output-escaping="no"/>
							<xsl:choose>
								<xsl:when test="$page = $endpage and $page!=''">
									<xsl:text disable-output-escaping="no"> </xsl:text>p. <xsl:value-of select="$page" disable-output-escaping="no"/></xsl:when>
								<xsl:when test="$page!='' and $endpage!=''">
									<xsl:text disable-output-escaping="no"> </xsl:text>pp. <xsl:value-of select="$page" disable-output-escaping="no"/> -
									<xsl:value-of select="$endpage" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="$page!=''">
									<xsl:text disable-output-escaping="no"> </xsl:text>p. <xsl:value-of select="$page" disable-output-escaping="no"/></xsl:when>
							</xsl:choose>
						</xsl:variable>

						<href file="{$localLink}" rel="nofollow">
							<xsl:value-of select="$display" disable-output-escaping="no"/>
							<xsl:if test="$gmd!=''">
								<xsl:value-of select="concat(' [',$gmd,']')" disable-output-escaping="no"/>
							</xsl:if>
						</href>
					</xsl:for-each>
					<!-- identifier or location-->
					<xsl:if test="not(mods:identifier[@type='local']) and not(mods:location) and not(mods:identifier[@type='issn'])">
						<href file="{concat('/search?q=&quot;',$searchText,'&quot;')}" rel="nofollow">
							<xsl:value-of select="$displayText" disable-output-escaping="no"/>
						</href>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="mods:relatedItem[not(@type)][mods:identifier[@type='url']]">
					<xsl:variable name="gmd">
						<xsl:choose>
							<xsl:when test="mods:genre">
								<xsl:value-of select="mods:genre[1]" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="mods:physicalDescription/mods:form" disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="link">
						<xsl:choose>
							<xsl:when test="contains(mods:identifier[@type='url'],'extent:')">
								<xsl:value-of select="normalize-space(substring-before(mods:identifier[@type='url'],'extent:'))" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(mods:identifier[@type='url'])" disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<href file="{$link}" rel="nofollow" target="_new">
						<xsl:value-of select="normalize-space(concat(mods:titleInfo/mods:nonSort,' ',mods:titleInfo/mods:title,' ', mods:titleInfo/mods:subTitle))" disable-output-escaping="no"/>
						<xsl:if test="$gmd!=''">
							<xsl:value-of select="concat(' [',$gmd,']')" disable-output-escaping="no"/>
						</xsl:if>
					</href>
				</xsl:for-each>
			</part>
		</xsl:if>
	</xsl:template>
	<xsl:template name="fileSize" as="item()*">
		<xsl:param name="filesize"/>
		<xsl:variable name="sizenum">
			<xsl:value-of select="number($filesize)" disable-output-escaping="no"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$sizenum='NaN'"/>
			<xsl:when test="$sizenum &gt; 1024*1024">
				<xsl:value-of select="format-number($sizenum div 1048576,'##,###0.0')" disable-output-escaping="no"/>M</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="format-number($sizenum div 1024,'##,###0')" disable-output-escaping="no"/>K</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="mods:subject" as="item()*">
		<xsl:for-each select="*">
			<xsl:choose>
				<xsl:when test="self::mods:name">
					<xsl:apply-templates select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position()!=last()">--</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="mods:name" as="item()*">
		<xsl:for-each select="*[not(local-name()='role')][not(local-name()='termsOfAddress')]">
			<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
			<xsl:if test="position()!=last()">
				<xsl:text disable-output-escaping="no"> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="contents" as="item()*">
		<xsl:choose>
			<xsl:when test="(starts-with(/mets:mets/@OBJID,'loc.gdc.sr') or starts-with(/mets:mets/@OBJID,'loc.law.law.')) and ($metsprofile='collectionRecord')">
				<xsl:variable name="url" select="concat('/',mods:identifier,'/default.html')"/>
				<href file="{$url}">
					<xsl:value-of select="mods:part//mods:caption" disable-output-escaping="no"/>
				</href>
			</xsl:when>
			<xsl:when test="$metsprofile='collectionRecord'">
				<xsl:variable name="id">
					<xsl:choose>
						<xsl:when test="not(starts-with(mods:identifier[@type='local'],'loc.'))">
							<xsl:value-of select="concat('../loc.natlib.ihas.',mods:identifier[@type='local'],'/default.html')" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('../',mods:identifier[@type='local'],'/default.html')" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<href file="{$id}">
					<xsl:value-of select="mods:titleInfo/mods:title" disable-output-escaping="no"/>
				</href>
			</xsl:when>
			<xsl:when test="$metsprofile='printMaterial'">
				<xsl:variable name="page" select="mods:part/mods:extent/mods:start"/>
				<href behavior="pageturner" parameters="page={$page}">
					<xsl:value-of select="mods:titleInfo" disable-output-escaping="no"/>
				</href>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="thisItemID" select="@ID"/>
				<!--relateditem @ID=DMD_seg01-->
				<xsl:variable name="desired-params">
					<params xmlns="http://www.marklogic.com/ps/params">
						<param>
							<name>itemID</name>
							<value>
								<xsl:value-of select="$thisItemID" disable-output-escaping="no"/>
							</value>
						</param>
					</params>
				</xsl:variable>
				<xsl:variable name="new-params" select="lp:param-string(lp:set-digital-params($params , 'item', $metsprofile , $desired-params))"/>
				<href behavior="item" parameters="{$new-params}">
					<xsl:if test="not(mods:note[@type='Standard Restriction']='This item is unavailable due to copyright restrictions.')                 and not(mods:accessCondition[@type='restrictionOnAccess']='This item is unavailable due to copyright restrictions.')          ">
						<xsl:choose>
							<xsl:when test="/mets:mets/mets:structMap//mets:div[@DMDID=thisItemID]/mets:div[contains(@TYPE,'audio')]">
								<xsl:attribute name="icon">/marklogic/static/img/audio.gif</xsl:attribute>
							</xsl:when>
							<xsl:when test="/mets:mets/mets:structMap//mets:div[@DMDID=thisItemID]/mets:div[contains(@TYPE,'video')]">
								<xsl:attribute name="icon">/marklogic/static/img/video.gif</xsl:attribute>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<title>
						<xsl:value-of select="normalize-space(mods:titleInfo[1]/mods:title)" disable-output-escaping="no"/>
						<!-- <xsl:value-of select="normalize-space(string-join(mods:titleInfo[1],' '))"/> -->
					</title>
				</href>
				<xsl:if test="mods:abstract">
					<comment>
						<h3>
							<xsl:value-of select="@displayLabel" disable-output-escaping="no"/>
						</h3>
						<xsl:value-of select="mods:abstract" disable-output-escaping="no"/>
					</comment>
				</xsl:if>
				<xsl:if test="mods:relatedItem">
					<xsl:call-template name="seeAlso"/>
					<!-- <xsl:call-template name="recordformats"/> -->
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="subTracks" as="item()*">
		<xsl:param name="back">contents</xsl:param>
		<xsl:variable name="track" select="@ID"/>
		<xsl:variable name="trackType">
			<xsl:choose>
				<xsl:when test="$objectType='Compact Disc'">Audio</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$objectType" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="trackLevel">
			<xsl:choose>
				<xsl:when test="parent::mods:relatedItem[@type='constituent']">subItem</xsl:when>
				<xsl:otherwise>item</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="mods:relatedItem[@type='constituent']">
				<!--this item has a sub item (ie audio linked to the tei)-->
				<!-- has sub tracks, don't need a top level dmd_tr-002_005 item link-->
				<xsl:element name="{$trackLevel}" inherit-namespaces="yes">
					<!-- <item id="dmd_seg01"></item>-->
					<xsl:attribute name="fileid">
						<xsl:value-of select="$track" disable-output-escaping="no"/>
					</xsl:attribute>

					<whole>
						<part>
							<sectionTitle>
								<xsl:value-of select="$trackType" disable-output-escaping="no"/> Views:</sectionTitle>
							<xsl:for-each select="mods:relatedItem[@type='constituent']">
								<xsl:call-template name="subTracks">
									<xsl:with-param name="back" select="$back"/>
								</xsl:call-template>
							</xsl:for-each>
						</part>
					</whole>
				</xsl:element>
			</xsl:when>
			<xsl:when test="mods:location/mods:url">
				<xsl:element name="{$trackLevel}" inherit-namespaces="yes">
					<whole>
						<xsl:attribute name="id">
							<xsl:value-of select="$track" disable-output-escaping="no"/>
						</xsl:attribute>
						<part>
							<sectionTitle>
								<xsl:value-of select="mods:titleInfo" disable-output-escaping="no"/>
							</sectionTitle>

							<href file="{mods:location/mods:url}">
								<xsl:value-of select="mods:titleInfo" disable-output-escaping="no"/>
							</href>
						</part>
					</whole>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="textID">
					<xsl:value-of select="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[@TYPE='re:text']/mets:fptr/@FILEID" disable-output-escaping="no"/>
				</xsl:variable>
				<xsl:element name="{$trackLevel}" inherit-namespaces="yes">
					<xsl:attribute name="id">
						<xsl:value-of select="$track" disable-output-escaping="no"/>
					</xsl:attribute>
					<xsl:attribute name="fileID">
						<xsl:value-of select="$textID" disable-output-escaping="no"/>
					</xsl:attribute>
					<part>
						<!-- <xsl:variable name="desired-params">
							<params xmlns="http://www.marklogic.com/ps/params">
								<param>
									<name>itemID</name>
									<value>
										<xsl:value-of select="$track"/>
									</value>
								</param>
							</params>
						</xsl:variable> -->
						<!-- <xsl:variable name="newparams" select="lp:param-string(lp:set-digital-params($params , 'item', $metsprofile , $desired-params))"/> -->
						<href behavior="item">
							<!-- parameters="{$newparams}" -->
							<title>
								<xsl:value-of select="normalize-space(mods:titleInfo/mods:title)" disable-output-escaping="no"/>
								<!-- <xsl:if test="$metsprofile='recordedEvent' and mods:name">/ <xsl:value-of select="mods:name"/></xsl:if> -->
							</title>
						</href>
						<xsl:for-each select="mods:abstract">
							<comment>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</comment>
							<xsl:if test="mods:note[@type='Standard Restriction']='This item is unavailable due to copyright restrictions.'        or mods:accessCondition[@type='restrictionOnAccess']='This item is unavailable due to copyright restrictions.'">
								<comment>Copyright restricted.</comment>
							</xsl:if>
							<xsl:if test="not(mods:note[@type='Standard Restriction']='This item is unavailable due to copyright restrictions.')                  or not(mods:accessCondition[@type='restrictionOnAccess']='This item is unavailable due to copyright restrictions.')">
								<!--	<comment>Copyright restricted.</comment>							</xsl:when>							<xsl:otherwise>-->
								<xsl:if test="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'audio')]">
									<sectionTitle>Section:</sectionTitle>
									<xsl:for-each select="key('serviceFile',/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'audio')]/mets:fptr/@FILEID)">
										<href icon="/marklogic/static/img/audio.gif" file="{mets:FLocat/@xlink:href}">
											<xsl:choose>
												<xsl:when test="@MIMETYPE='audio/mp3'">Play MP3</xsl:when>
												<xsl:when test="@MIMETYPE='application/x-pn-realaudio'">Play RealMedia</xsl:when>
											</xsl:choose>
										</href>
									</xsl:for-each>
								</xsl:if>
								<xsl:if test="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'video')]">
									<sectionTitle>Section:</sectionTitle>
									<xsl:for-each select="key('serviceFile',/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'video')]/mets:fptr/@FILEID)">
										<href icon="/marklogic/static/img/video.gif" file="{mets:FLocat/@xlink:href}">
											<xsl:choose>
												<xsl:when test="@MIMETYPE='video/mpeg' and key('file',@FILEID)/../@USE='DISPLAYING MASTER'">Play MPEG</xsl:when>
												<xsl:when test="@MIMETYPE='application/x-pn-realaudio'">Play RealMedia</xsl:when>
											</xsl:choose>
										</href>
									</xsl:for-each>
								</xsl:if>
							</xsl:if>
						</xsl:for-each>
					</part>
					<xsl:if test="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'lyrics')]">
						<part>
							<sectionTitle>Additional Materials:</sectionTitle>
							<xsl:for-each select="key('masterFile',/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'lyrics')]/mets:fptr/@FILEID)">
								<href behavior="lyrics" icon="/marklogic/static/img/text.gif" file="{mets:FLocat/@xlink:href}" parameters="ID={$track}">Display Lyrics</href>
							</xsl:for-each>
						</part>
					</xsl:if>
					<xsl:for-each select="mods:relatedItem[@type='constituent']">
						<xsl:call-template name="subTracks"/>
					</xsl:for-each>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="singleTracks" as="item()*">
		<xsl:param name="back">contents</xsl:param>
		<xsl:variable name="track" select="@ID"/>
		<xsl:variable name="trackType">
			<xsl:choose>
				<xsl:when test="$objectType='Compact Disc'">Audio</xsl:when>
				<xsl:when test="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'video')]">Video</xsl:when>
				<xsl:when test="//mods:genre[@authority='marcgt']='web site'">Archived Website</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$objectType" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="mods:location/mods:url">
				<item id="{$track}">
					<part>
						<sectionTitle>
							<xsl:value-of select="$trackType" disable-output-escaping="no"/>Views:</sectionTitle>
						<href>
							<title>
								<xsl:value-of select="string-join(mods:titleInfo[1],' ')" disable-output-escaping="no"/>
							</title>
							<url>
								<xsl:value-of select="mods:location/mods:url" disable-output-escaping="no"/>
							</url>
						</href>
					</part>
				</item>
			</xsl:when>
			<xsl:otherwise>

				<xsl:variable name="textID">
					<xsl:value-of select="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[@TYPE='re:text']/mets:fptr/@FILEID" disable-output-escaping="no"/>
				</xsl:variable>
				<xsl:variable name="desired-params">
					<params xmlns="http://www.marklogic.com/ps/params">
						<param>
							<name>itemID</name>
							<value>
								<!-- <xsl:value-of select="$track"/> -->
								<xsl:value-of select="$textID" disable-output-escaping="no"/>
							</value>
						</param>
					</params>
				</xsl:variable>
				<xsl:variable name="newparams" select="lp:param-string(lp:set-digital-params($params , 'item', $metsprofile , $desired-params))"/>
				<item id="{$track}" fileid="{$textID}">
					<part>
						<sectionTitle>
							<xsl:value-of select="$trackType" disable-output-escaping="no"/>Views:</sectionTitle>
						<!--<href behavior="item" parameters="itemID={@ID}">			-->
						<href behavior="item" parameters="{$newparams}">
							<title>
								<xsl:value-of select="string-join(mods:titleInfo[1],' ')" disable-output-escaping="no"/>
							</title>
						</href>
						<xsl:if test="mods:abstract">
							<comment>
								<xsl:value-of select="mods:abstract" disable-output-escaping="no"/>
							</comment>
						</xsl:if>
					</part>
					<part>
						<xsl:choose>
							<xsl:when test="mods:note[@type='Standard Restriction']='This item is unavailable due to copyright restrictions.'      or mods:accessCondition[@type='restrictionOnAccess']='This item is unavailable due to copyright restrictions.'">
								<comment>Copyright restricted.</comment>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'audio')]">
									<sectionTitle>Audio Formats:</sectionTitle>
									<xsl:for-each select="key('serviceFile',/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'audio')]/mets:fptr/@FILEID)">
										<href icon="/marklogic/static/img/audio.gif" file="{mets:FLocat/@xlink:href}"/>
										<xsl:choose>
											<xsl:when test="@MIMETYPE='audio/mp3'">Play MP3</xsl:when>
											<xsl:when test="@MIMETYPE='application/x-pn-realaudio'">Play RealMedia</xsl:when>
										</xsl:choose>
									</xsl:for-each>
								</xsl:if>
								<xsl:if test="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'video')]">
									<sectionTitle>Video Formats:</sectionTitle>
									<xsl:for-each select="key('serviceFile',/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'video')]/mets:fptr/@FILEID)">
										<href icon="/marklogic/static/imgvideo.gif" file="{mets:FLocat/@xlink:href}"/>
										<xsl:choose>
											<xsl:when test="@MIMETYPE='video/mpeg' and key('file',@FILEID)/../@USE='DISPLAYING MASTER'">Play MPEG</xsl:when>
											<xsl:when test="@MIMETYPE='application/x-pn-realaudio'">Play RealMedia</xsl:when>
										</xsl:choose>
									</xsl:for-each>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</part>
					<xsl:if test="/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'lyrics')]">
						<part>
							<sectionTitle>Additional Materials:</sectionTitle>
							<xsl:for-each select="key('masterFile',/mets:mets/mets:structMap//mets:div[@DMDID=$track]/mets:div[contains(@TYPE,'lyrics')]/mets:fptr/@FILEID)">
								<href behavior="lyrics" icon="/marklogic/static/img/text.gif" file="{mets:FLocat/@xlink:href}" parameters="ID={$track}"/>Display Lyrics</xsl:for-each>
						</part>
					</xsl:if>
				</item>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="multivolumePageturning" as="item()*">
		<xsl:variable name="volumeCount" select="count(//volumes/volume)"/>
		<xsl:variable name="parentTitle">
			<xsl:choose>
				<xsl:when test="string-length(//mods:relatedItem[@type='host']/mods:titleInfo/mods:title[1] ) &gt;35">
					<xsl:call-template name="findLastSpace">
						<xsl:with-param name="titleChop">
							<xsl:value-of select="substring(//mods:relatedItem[@type='host']/mods:titleInfo/mods:title, 1, 35)" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text disable-output-escaping="no">...</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="//mods:relatedItem[@type='host']//mods:titleInfo/mods:title[1]" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="parentURL">
			<xsl:choose>
				<xsl:when test="//mods:relatedItem[@type='host']/mods:identifier[@type='url']">
					<xsl:value-of select="concat('../',//mods:relatedItem[@type='host']/mods:identifier[@type='url'] )" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="//mods:relatedItem[@type='host']/mods:identifier[@displayLabel='IHASDigitalID']">
					<xsl:value-of select="concat('../loc.natlib.ihas.',//mods:relatedItem[@type='host']/mods:identifier[@displayLabel='IHASDigitalID'],'/')" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('../loc.gdc.sr.', //relatedItem/element[@label='LCCN']/value, '/')" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<whole>
			<part>
				<href file="{$parentURL}">To Parent Title</href>
			</part>
			<part>
				<sectionTitle>Other Volumes:</sectionTitle>
				<xsl:call-template name="volumes"/>
			</part>
			<part>
				<sectionTitle>This Volume:</sectionTitle>

				<href parameters="{$default-params}" behavior="default">Description</href>
				<href behavior="pageturner">
					<xsl:choose>
						<xsl:when test="count(//mets:div[contains(@TYPE,'page')]) = 1">Enlargement</xsl:when>
						<xsl:otherwise>Page Turner</xsl:otherwise>
					</xsl:choose>
				</href>
				<xsl:if test="count(//mets:div[contains(@TYPE,'page')]) &gt; 1">
					<href behavior="contactsheet">Contact Sheet</href>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="key('file',//mets:div[@TYPE='pm:pdfDoc']/mets:fptr/@FILEID)/@MIMETYPE='application/pdf'">
						<href file="{key('file',//mets:div[@TYPE='pm:pdfDoc']/mets:fptr/@FILEID)/mets:FLocat/@xlink:href}" size="{key('file',//mets:div[@TYPE='pm:pdfDoc']/mets:fptr/@FILEID)/@SIZE}"/>PDF format</xsl:when>
					<xsl:otherwise>
						<href file="{$digid}.pdf">PDF for Printing</href>
					</xsl:otherwise>
				</xsl:choose>
			</part>
			<xsl:if test="mets:structMap//mets:div[@TYPE='sm:sheetMusicLyrics']">
				<part>
					<sectionTitle>Sheet Music Lyrics:</sectionTitle>
					<xsl:for-each select="key('masterFile',/mets:mets/mets:structMap//mets:div[@TYPE='sm:sheetMusicLyrics']/mets:fptr/@FILEID)">
						<href behavior="lyrics" icon="/marklogic/static/img/text.gif" file="{mets:FLocat/@xlink:href}">Display Lyrics</href>
					</xsl:for-each>
					<href file="lyricsFO.pdf">PDF for Printing</href>
					<comment>Note: To view PDF files through your browser, you may need to download
						the freely available <a href="http://www.adobe.com/products/acrobat/readstep2.html">Adobe
							Acrobat reader</a>.</comment>
				</part>
			</xsl:if>
			<xsl:if test="mets:structMap//mets:div[@TYPE='pm:transcription']">
				<part>
					<sectionTitle>Print Material Text:</sectionTitle>
					<xsl:for-each select="key('masterFile',/mets:mets/mets:structMap//mets:div[@TYPE='pm:transcription']/mets:fptr/@FILEID)">
						<href behavior="lyrics" icon="/marklogic/static/img/text.gif" file="{mets:FLocat/@xlink:href}">Display Text</href>
					</xsl:for-each>
					<href file="lyricsFO.pdf">PDF for Printing</href>
					<comment>Note: To view PDF files through your browser, you may need to download
						the freely available <a href="http://www.adobe.com/products/acrobat/readstep2.html">Adobe
							Acrobat reader</a>.</comment>
				</part>
			</xsl:if>
			<xsl:if test="mets:structMap//mets:div[@TYPE='sm:sheetMusicScore']/mets:fptr">
				<part>
					<xsl:for-each select="mets:structMap//mets:div[@TYPE='sm:sheetMusicScore']/mets:fptr">
						<xsl:choose>
							<xsl:when test="key('file',@FILEID)/@MIMETYPE='application/pdf'">
								<href file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">PDF for Printing</href>
								<comment>Note: To view PDF files through your browser, you may need
									to download the freely available <a href="http://www.adobe.com/products/acrobat/readstep2.html">Adobe Acrobat reader</a>.</comment>
							</xsl:when>
							<xsl:when test="key('file',@FILEID)/@MIMETYPE='application/finale'">
								<href file="{key('file',@FILEID)/mets:FLocat/@xlink:href}">Finale Notated Music</href>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</part>
			</xsl:if>
			<xsl:call-template name="seeAlso"/>
			<!-- <xsl:call-template name="recordformats"/> -->
		</whole>
	</xsl:template>
	<xsl:template name="volumes" as="item()*">
		<!-- <xsl:variable name="thisVolume" select="substring-after(/mets:mets/@OBJID,'_')"/> -->
		<xsl:variable name="thisVolume">
			<xsl:choose>
				<xsl:when test="contains(/mets:mets/@OBJID,'_')">
					<xsl:value-of select="substring-after(/mets:mets/@OBJID,'_')" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/mets:mets/@OBJID" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="title" select="normalize-space(//mods:mods/mods:titleInfo[1])"/>
		<xsl:variable name="volumes">
			<!-- get the host mets: -->
			<xsl:for-each select="//mods:relatedItem[@type='host'][mods:identifier[@type='local' and (@displayLabel='IHASDigitalID' or @displayLabel='bibid')]]">
				<xsl:variable name="metsURL">
					<xsl:choose>
						<xsl:when test="mods:identifier[@type='local' and @displayLabel='IHASDigitalID']">
							<xsl:value-of select="concat('http://lcweb2.loc.gov:8081/diglib/ihas/loc.natlib.ihas.',mods:identifier[@type='local' and @displayLabel='IHASDigitalID'],'/mets.xml')" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:when test="mods:identifier[@type='local' and @displayLabel='bibid']">
							<!-- temporarily find on rs5 until app level security is on: -->
							<xsl:value-of select="concat('http://marklogic3.loctest.gov/loc.law.law.',mods:identifier[@type='local' and @displayLabel='bibid'],'/mets.xml')" disable-output-escaping="no"/>
							<!-- <xsl:value-of select="concat('http://lcweb2.loc.gov/natlib/law/metstest/loc.law.law.',mods:identifier[@type='local' and @displayLabel='bibid'],'/mets.xml')"/> -->
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="hostMETS" select="document($metsURL)/mets:mets"/>
				<xsl:for-each select="$hostMETS//mets:div[@TYPE='cr:member']">
					<volume>
						<position>
							<xsl:value-of select="position()" disable-output-escaping="no"/>
						</position>
						<href file="{mets:div[@TYPE='pm:printMaterial']/mets:mptr/@xlink:href}">
							<xsl:if test="contains(mets:div[@TYPE='pm:printMaterial']/mets:mptr/@xlink:href,$thisVolume)">
								<xsl:attribute name="parameters">section=<xsl:value-of select="$thisVolume" disable-output-escaping="no"/></xsl:attribute>
							</xsl:if>
							<xsl:value-of select="mets:div[@TYPE='pm:printMaterial']/@LABEL" disable-output-escaping="no"/>
						</href>
						<label>
							<xsl:value-of select="mets:div[@TYPE='pm:printMaterial']/@LABEL" disable-output-escaping="no"/>
						</label>
					</volume>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="volumeSequenceNumber" select="$volumes/volume[contains(link/@file,$thisVolume)]/position()"/>
		<xsl:variable name="volumeCount" select="count($volumes/volume)"/>
		<xsl:variable name="nextVolume">
			<xsl:choose>
				<xsl:when test="$volumeSequenceNumber=$volumeCount">
					<xsl:value-of select="$volumes/volume[1]/href/@file" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$volumes/volume[position()=$volumeSequenceNumber+1]/href/@file" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="previousVolume">
			<xsl:choose>
				<xsl:when test="$volumeSequenceNumber=1">
					<xsl:value-of select="$volumes/volume[last()]/href/@file" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$volumes/volume[position()=$volumeSequenceNumber - 1]/href/@file" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="firstVolume" select="$volumes/volume[1]/href/@file"/>
		<xsl:variable name="firstLabel" select="$volumes/volume[1]/label"/>
		<xsl:variable name="lastVolume" select="$volumes/volume[last()]/href/@file"/>
		<xsl:variable name="lastLabel" select="$volumes/volume[last()]/label"/>

		<xsl:choose>
			<xsl:when test="$volumeCount=1">
			</xsl:when>
			<xsl:otherwise>
				<line>
					<img src="/marklogic/static/img/arrow_prev.gif" alt="previous"/>
					<a href="{concat('../',$previousVolume,'/pageturner.html?size=',$size)}">Previous</a>
					<xsl:text disable-output-escaping="no"> | </xsl:text>
					<a href="{concat('../',$nextVolume,'/pageturner.html?size=',$size)}">Next</a>
					<img alt="next" src="/marklogic/static/img/arrow_next.gif"/>
				</line>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="makeFromLink" as="item()*">
		<part>
			<sectionTitle>From:</sectionTitle>
			<xsl:for-each select="mods:identifier[@type='local'or @type='url']">
				<xsl:variable name="localLink">
					<xsl:choose>
						<xsl:when test="@displayLabel='Title Record'">
							<xsl:value-of select="concat('/loc.natlib.ihas.',normalize-space( text() ),'/default.html'   )" disable-output-escaping="no"/>
						</xsl:when>

						<xsl:when test="@displayLabel='bibid'">
							<xsl:value-of select="concat('/loc.law.law.',text(),'/default.html'  )" disable-output-escaping="no"/>
						</xsl:when>

						<xsl:when test="@type='url'">
							<xsl:value-of select="text()" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('/search.xqy?q=',normalize-space(substring-after(text(),'(DLC)'))   )" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="displayText">
					<xsl:choose>
						<xsl:when test="contains(text(),'(DLC)')">
							<xsl:value-of select="concat(normalize-space(../mods:titleInfo[1][not(@type)]/mods:title),': ', substring-after(text(),'(DLC)' )) " disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(../mods:titleInfo[1][not(@type)]/mods:title)" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<href file="{$localLink}" rel="nofollow">
					<xsl:value-of select="$displayText" disable-output-escaping="no"/>
				</href>
			</xsl:for-each>
		</part>
	</xsl:template>
	<xsl:template name="recordformats" as="item()*">
		<xsl:variable name="bookmarkhref" select="concat('http://', $hostname, '/', $id)"/>
		<part>
			<sectionTitle>Other Metadata Formats</sectionTitle>
			<!--<href file="/nlc/permalink.xqy?id={$id}&amp;mime=application/mods+xml">MODS</href>-->
			<href file="{concat($bookmarkhref,'.mods.xml')}">MODS</href>
			<href file="{concat($bookmarkhref,'.dc.xml')}">Dublin Core (SRU)</href>
			<href file="{concat($bookmarkhref,'.mets.xml')}">METS</href>
		</part>
		<part>
			<sectionTitle>Bookmark</sectionTitle>
			<href file="{concat($bookmarkhref,'.html')}">
				<xsl:value-of select="concat($bookmarkhref,'.html')" disable-output-escaping="no"/>
			</href>
		</part>
	</xsl:template>
	<xsl:template name="authority-browses" as="item()*">
		<xsl:if test="/mets:mets//mods:mods/mods:subject[@authority='lcsh']">
			<part>
				<sectionTitle>Browse Subject Headings</sectionTitle>
				<xsl:for-each select="/mets:mets//mods:mods/mods:subject[@authority='lcsh']">
					<xsl:variable name="subj">
						<xsl:value-of select="normalize-space(string-join(*,'--'))" disable-output-escaping="no"/>
					</xsl:variable>
					<xsl:variable name="link" select="concat('/nlc/browse.xqy?dtitle=',encode-for-uri(/pageTurner/descriptive/pagetitle),'&amp;browse-order=ascending&amp;bq=', encode-for-uri($subj), '&amp;browse=subject')"/>

					<href file="{$link}">
						<xsl:value-of select="$subj" disable-output-escaping="no"/>
					</href>
				</xsl:for-each>
			</part>
		</xsl:if>
		<xsl:if test="/mets:mets//mods:mods/mods:name">
			<!--toplist???-->
			<part>
				<sectionTitle>Browse Name Headings</sectionTitle>
				<xsl:for-each select="/mets:mets//mods:mods/mods:name">
					<xsl:variable name="name">
						<xsl:value-of select="normalize-space(string-join(mods:namePart[not(@type='date') and not(@type='role')],' '))" disable-output-escaping="no"/>
					</xsl:variable>
					<xsl:variable name="link" select="concat('/nlc/browse.xqy?dtitle=',encode-for-uri(/pageTurner/descriptive/pagetitle),'&amp;','&amp;browse-order=ascending&amp;bq=', encode-for-uri($name), '&amp;browse=author')"/>
					<href file="{$link}">
						<xsl:value-of select="$name" disable-output-escaping="no"/>
					</href>
				</xsl:for-each>
			</part>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>