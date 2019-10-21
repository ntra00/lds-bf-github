<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="mods" default-validation="strip" input-type-annotations="unspecified" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- convert all to namespace, then add ns1:
	xmlns:ns1="http://www.tei-c.org/ns/1.0" -->
	<!--
 Source XML:	Bicentennial Local Legacies pages, converted to XHTML
				and TEI files				 				
 Result:		XHTML files (one per project)


	Modification Log:  
	1/18/06:    Changed name to Local Legacies/Community Roots: new graphic and meta tags
	3/23/04:    Changed to use TEI as source, digital IDs
	6/16/04:    Added sponsor

-->

	<xsl:variable name="digitalID" select="descendant-or-self::back/div/note[@type='digitalID']/text()"/>
		
	<!-- <xsl:variable name="title" select="normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title)"/> -->
	<xsl:variable name="stateName" select="descendant-or-self::note[@type='stateName']"/>
	<xsl:variable name="sponsor" select="descendant-or-self::back/div/note[@type='sponsor']/text()"/>



	<xsl:template match="text" as="item()*">
	<xsl:variable name="ID" select="back/div/note[@type='digitalID']/text()"/>
		<xsl:for-each select="body">
			<div id="bio-content">
				<!-- variables from localLegacies.xml reference document -->
				<xsl:variable name="stateCode" select="/descendant-or-self::note[@type='stateCode']"/>
				<xsl:variable name="stateCodeL" select="translate($stateCode,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
				<xsl:variable name="stateNameUp" select="translate($stateName,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>

				<!-- header image: multiple pictures -->


				<!-- 	<table cellSpacing="0" bgcolor="#FFFFFF" align="center" width="90%" border="0" cellPadding="0">

					<tr>
						<td colSpan="3"> -->
				<xsl:if test="div/p/figure">
					<!-- image1 -->
					<!-- <table cellSpacing="0" align="right" width="25%" border="0" cellPadding="0">
									<tr>
										<td background="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/spacer-greygreen.gif" align="center"> -->
					<div id="bio-image">
					
						<img border="2">
							<xsl:attribute name="alt">
								<xsl:choose>
									<!-- if alt= blank  replace with caption -->
									<xsl:when test="not(div/p/figure/figDesc)">
										<xsl:value-of select="div/p/figure/head" disable-output-escaping="no"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="div/p/figure/figDesc" disable-output-escaping="no"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:attribute name="height">200</xsl:attribute>
							<xsl:attribute name="hspace">10</xsl:attribute>
							<xsl:attribute name="src">
								<xsl:value-of select="concat('http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/',$stateCode,'/',$ID,'/',div/p/figure/@url)" disable-output-escaping="no"/>
							</xsl:attribute>
							<xsl:attribute name="vspace">10</xsl:attribute>
							<xsl:attribute name="width">200</xsl:attribute>
						</img>

						<br/>
						<span class="caption">
							<xsl:call-template name="caption"/>
						</span>
					</div>
					<!-- </td>
									</tr>
								</table> -->
				</xsl:if>
				<!-- image1 exists-->
				<a name="content"/>
				<h1>
					<!--<xsl:value-of select="$title"/>-->
					<xsl:value-of select="div/head" disable-output-escaping="no"/>
				</h1>
				<!-- begin paragraphs of text from <div> node -->
				<xsl:for-each select="div">
					<!-- suppress blank paragraphs -->
					<xsl:for-each select="p[text()!=' ']">
						<p>
							<xsl:apply-templates select="child::node()"/>
						</p>
						<xsl:if test="position()=2">
							<!-- after 2nd paragraph, place 2nd image (PR, SD)-->
							<!-- image2 -->
							<xsl:if test="following-sibling::figure">
								<!-- <table cellspacing="0" cellpadding="0" width="25%" align="left" border="0">
												<tbody>
													<tr>
														<td align="left" background="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/spacer-greygreen.gif"> -->
								<div class="bio-image">
									<img border="2">
										<xsl:attribute name="height">200</xsl:attribute>
										<xsl:attribute name="alt">
											<xsl:choose>
												<!-- if alt= blank  replace with caption -->
												<xsl:when test="not(following-sibling::figure/figDesc)">
													<xsl:value-of select="following-sibling::figure/head/caption" disable-output-escaping="no"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="following-sibling::figure/figDesc" disable-output-escaping="no"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
										<xsl:attribute name="hspace">10</xsl:attribute>
										<xsl:attribute name="src">
											<!-- copy natlib directory, st code, digid -->
											<xsl:value-of select="concat('http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/',$stateCode,'/',$digitalID,'/',following-sibling::figure/@url)" disable-output-escaping="no"/>
										</xsl:attribute>
										<xsl:attribute name="width">200</xsl:attribute>
										<xsl:attribute name="vspace">10</xsl:attribute>
									</img>
									<br/>

									<span class="caption">
										<!-- <xsl:call-template name="caption"/> -->
										<xsl:for-each select="//div/figure/head/caption">
											<xsl:apply-templates select="child::node()"/>
										</xsl:for-each>
										<!-- <xsl:for-each select="//div/figure[2]/head/caption">
																			<xsl:apply-templates/>
																		</xsl:for-each> -->
									</span>
								</div>
								<!-- </td>
													</tr>
												</tbody>
											</table> -->
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
				<xsl:if test="$sponsor">
					<p>Originally submitted by: <xsl:value-of select="normalize-space($sponsor)" disable-output-escaping="no"/>.</p>
				</xsl:if>
				<!-- More Legacies ; link back to state page-->
				<br clear="all"/>
				<br clear="all"/>
				<!-- <table cellSpacing="0" background="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/spacer-greygreen.gif" border="0" cellPadding="1">
								<tr>
									<td>
										<table cellSpacing="1" width="425" border="0" cellPadding="4">
											<tr align="center">
												<th background="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/spacer-greygreen.gif"> -->
				<a href="http://www.loc.gov">
					<img align="right" width="97" src="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/loc-icon.gif" alt="link to www.loc.gov" border="0" height="16"/>
				</a>
				<xsl:text disable-output-escaping="no">More Local Legacies...</xsl:text>
				<!-- </th>
											</tr>
											<tr align="center">
												<td background="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/spacer-white.gif" align="left"> -->
				<ul type="square">
					<li>
						<a>
							<xsl:attribute name="href">
								<xsl:value-of select="concat('http://memory.loc.gov/diglib/legacies/',$stateCode,'.html')" disable-output-escaping="no"/>
								<!-- <xsl:text>index.html</xsl:text> -->
							</xsl:attribute>
							<xsl:text disable-output-escaping="no">Additional </xsl:text>
							<xsl:value-of select="$stateName" disable-output-escaping="no"/>
							<xsl:text disable-output-escaping="no"> Local Legacies</xsl:text>
						</a>
					</li>

					<li>
						<a href="http://www.loc.gov/folklife/roots/ac-home.html#states">Local Legacies for all U.S. States</a>
					</li>
				</ul>
				<!-- </td>
											</tr>
										</table>
									</td>
								</tr>
							</table> -->
				<br/>
				<!-- Learn more.. link to event web site if available-->
				<!-- <table cellSpacing="0" background="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/spacer-greygreen.gif" border="0" cellPadding="1">								
								<tr>
									<td> -->
				<xsl:if test="descendant-or-self::p/xref/@url">
					<xsl:variable name="projectUrl">
						<xsl:value-of select="descendant-or-self::p/xref/@url" disable-output-escaping="no"/>
					</xsl:variable>
					<!-- <table cellSpacing="1" width="425" border="0" cellPadding="4">
												<tr align="center">
													<th background="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/spacer-greygreen.gif"> -->
					<a href="http://www.loc.gov/global/disclaim.html">
						<img align="right" width="97" src="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/lclink.gif" alt="disclaimer for external links" border="0" height="16"/>
					</a>Learn More About It...
					<!-- </th>
												</tr>
												<tr align="center">
													<td background="http://lcweb2.loc.gov/natlib/afc2001001/afc-legacies/images/spacer-white.gif" align="left"> -->
					<ul type="square">
						<li>
							<a>
								<xsl:attribute name="href">
									<xsl:value-of select="$projectUrl" disable-output-escaping="no"/>
								</xsl:attribute>
								<xsl:text disable-output-escaping="no">Event Web Site</xsl:text>
							</a>
						</li>
					</ul>
					<!-- </td>
												</tr>
											</table> -->
				</xsl:if>
				<!-- </td>
								</tr>
							</table>
						</td>
					</tr>
				</table> -->

				<!-- End ImageReady Slices -->
				<p class="selected"/>
			</div>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="*" as="item()*"/>

	<xsl:template match="figure" as="item()*"/>

	<xsl:template name="caption" as="item()*">
		<xsl:for-each select="div/p/figure/head/caption">
			<xsl:apply-templates select="child::node()"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="emph" as="item()*">
		<em>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</em>
	</xsl:template>

	<xsl:template match="hi" as="item()*">
		<xsl:if test="@rend='bold'">
			<strong>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</strong>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>