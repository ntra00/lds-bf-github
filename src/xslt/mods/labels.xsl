<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xlink mods marcgac mets utils idx index functx" extension-element-prefixes="xdmp" default-validation="strip" input-type-annotations="unspecified" xmlns:functx="http://www.functx.com" xmlns:index="info:lc/xq-modules/index-utils" xmlns:xdmp="http://marklogic.com/xdmp" xmlns:utils="info:lc/xq-modules/mets-utils" xmlns:idx="info:lc/xq-modules/lcindex" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:marcgac="info:lc/xmlns/codelist-v1" xmlns="local">
	<!-- xpath-default-namespace="local"  -->
	<!-- input is mods, output is local -->

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<!--source xml is <set>mets:mets, pages</set>, output is local for groupings.xsl-->
	<!-- profile and behavior params are in utils -->

	<xsl:include href="../pageturner/utils.xsl"/>
	<xsl:param name="uri"/>
	<xsl:param name="ip"/>
	<xsl:param name="branding"/>
	<xsl:param name="ajaxparams"/>
	<xsl:param name="mets"/>

	<!-- OBJID from mets -->

	<!-- these are in /docs -->
	<xsl:variable name="dictionary" select="document('/config/modsLabels.xml')/labels"/>
	<xsl:variable name="relators" select="document('/config/relators.xml')/marcRelators"/>
	<xsl:variable name="languages" select="document('/config/marcLanguages.xml')/marcLanguages"/>
	<xsl:variable name="countries" select="document('/config/marcCountries.xml')/marcCountries"/>

	<xsl:variable name="object" select="$objectHeader"/>
	<xsl:variable name="viewable">
		<xsl:choose>
			<xsl:when test="starts-with($ip, '140.147') or     (not(contains(//mods:mods/mods:accessCondition[@type='restrictionsOnAccess'],'restricted') and not(contains(//mods:mods/mods:accessCondition[@type='useAndReproduction'],'restricted') )))">
				<xsl:text disable-output-escaping="no">yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="no">no</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="searchUrl">
		<xsl:value-of select="concat(' /',$branding,'/search.xqy?q=')" disable-output-escaping="no"/>
	</xsl:variable>
	<xsl:variable name="browseUrl">
		<xsl:value-of select="concat(' /',$branding,'/browse.xqy?bq=')" disable-output-escaping="no"/>
	</xsl:variable>
	<xsl:template match="/mets:mets" as="item()*">
		<descriptive>			
			<pagetitle>
				<xsl:if test="//mods:mods/mods:titleInfo[1]/@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="pageTitle"/>
			</pagetitle>
			<span id="objectType">
				<xsl:value-of select="$profile" disable-output-escaping="no"/>
			</span>
			<objectType>
				<xsl:value-of select="$objectType" disable-output-escaping="no"/>
			</objectType>
			<objectID>
				<xsl:value-of select="$uri" disable-output-escaping="no"/>
			</objectID>
			<gmd>
				<xsl:value-of select="$gmd" disable-output-escaping="no"/>
			</gmd>
			<objectHeader>
				<xsl:value-of select="$objectHeader" disable-output-escaping="no"/>
			</objectHeader>
			<profile>
				<xsl:value-of select="$metsprofile" disable-output-escaping="no"/>
			</profile>
			<viewable>
				<xsl:value-of select="$viewable" disable-output-escaping="no"/>
			</viewable>
			<digitalID>
				<xsl:choose>
					<xsl:when test="//mods:mods/mods:identifier[@displayLabel='IHASDigitalID']">
						<xsl:value-of select="//mods:mods/mods:identifier[@displayLabel='IHASDigitalID']" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:when test="//mods:mods/mods:identifier[@type='DigitalID']">
						<xsl:value-of select="//mods:mods/mods:identifier[@type='DigitalID']" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="//mods:mods/mods:recordInfo/mods:recordIdentifier[1]" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</digitalID>
			<xsl:if test="//mods:note[@type='Standard Restriction']='This item is unavailable due to copyright restrictions.'">
				<contentRestricted>yes</contentRestricted>
			</xsl:if>

			<full>
				<xsl:apply-templates select="//mods:mods" mode="full"/>
			</full>
			<metatags>
				<xsl:apply-templates select="//mods:mods" mode="metatags"/>
			</metatags>
		</descriptive>
	</xsl:template>

	<xsl:template match="mods:mods" mode="full" as="item()*">
		<xsl:apply-templates select="*[not(local-name()='relatedItem')][not(local-name()='recordInfo')]"/>
		<xsl:apply-templates select="mods:relatedItem[@type='host']"/>
		<xsl:apply-templates select="mods:recordInfo/mods:recordChangeDate"/>
	</xsl:template>
	<xsl:template match="mods:mods" mode="metatags">
		<head xmlns="http://www.w3.org/1999/xhtml">

			<meta name="DC.title" content="{mods:titleInfo[not(@type)][1]/mods:title}"/>
			<xsl:for-each select="mods:name">
				<meta name="DC.creator" content="{string-join(*[local-name()!='role'],' ') }"/>
			</xsl:for-each>
			<xsl:for-each select="mods:originInfo/mods:publisher">
				<meta name="DC.publisher" content="{normalize-space(.)}"/>
			</xsl:for-each>
			<!-- <xsl:for-each select="mods:originInfo/mods:place">
			<xsl:call-template name="getPlace"/>
			<meta name="DC.???" content="{normalize-space(.)}"/>
		</xsl:for-each> -->

			<xsl:for-each select="mods:originInfo/*[local-name()='dateIssued' or local-name()='dateCreated' or local-name()='dateCaptured' or local-name()='dateValid' or local-name()='dateModified' or local-name()='copyrightDate'][text()!='OPEN']">
				<xsl:variable name="dt">
					<xsl:choose>
						<xsl:when test="string-length(replace(.,'-','')) &gt; 8 and @encoding='iso8601'">
							<xsl:value-of select="substring(replace(.,'-',''),1,8)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(.)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<meta name="DC.date" content="{$dt}"/>
			</xsl:for-each>
			<xsl:for-each select="mods:identifier[@type='url']">
				<meta name="DC.identifier" content="{normalize-space(.)}"/>
			</xsl:for-each>
			<xsl:for-each select="mods:location/mods:url">
				<!-- 	<mods:location>
  <mods:url displayLabel="Archived site">http://loc.archive.org/pope/2005*/http://www.opoka.org.pl/</mods:url> 
  </mods:location>
- <mods:location>
  <mods:url usage="primary display" access="raw object">http://hdl.loc.gov/loc.natlib/mrva0010.0144</mods:url> 
  </mods:location> -->
				<!-- for lcwa, viewable doesn't count; the crawler is inside, so it'll capture urls unavailable to the outside -->
				<xsl:if test="not(@usage='primary display' or @displayLabel='Archived site')">
					<meta name="DC.identifier" content="{normalize-space(.)}"/>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="mods:recordInfo/mods:recordIdentifier[@source='IHAS']">
				<meta name="DC.identifier" content="/{.}.html"/>
			</xsl:for-each>


			<xsl:for-each select="mods:typeOfResource">
				<meta name="DC.type" content="{normalize-space(.)}"/>
			</xsl:for-each>
<xsl:if test="not(mods:typeOfResource)">
<xsl:for-each select="mods:form[@authority='gmd']">
				<meta name="DC.type" content="{normalize-space(.)}"/>
			</xsl:for-each>
</xsl:if>
			<xsl:for-each select="mods:subject">
				<xsl:choose>
					<xsl:when test="@authority='keyword'"/>
					<xsl:when test="mods:geographic">
						<xsl:for-each select="mods:geographic">
							<meta name="DC.coverage.spatial" content="{normalize-space(.)}"/>
						</xsl:for-each>
						<meta name="DC.subject" content="{normalize-space(string-join(*,'--'))}"/>
					</xsl:when>
					<xsl:when test="mods:hierarchicalGeographic">
						<xsl:for-each select="mods:hierarchicalGeographic">
							<meta name="DC.coverage.spatial" content="{normalize-space(.)}"/>
						</xsl:for-each>
						<meta name="DC.subject" content="{normalize-space(string-join(*,'--'))}"/>
					</xsl:when>
					<xsl:when test="mods:temporal">
						<meta name="DC.coverage.temporal" content="{normalize-space(mods:temporal)}"/>
						<meta name="DC.subject" content="{normalize-space(string-join(*,'--'))}"/>
					</xsl:when>
					<xsl:otherwise>
						<meta name="DC.subject" content="{normalize-space(string-join(*,'--'))}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>

			<xsl:for-each select="mods:relatedItem[@type='host']">
				<xsl:variable name="title">
					<xsl:value-of select="concat(normalize-space(mods:titleInfo[1]),mods:note)"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="mods:identifier[@type='url']">
						<link rel="DC.relation.isPartOf" href="{mods:identifier[@type='url']}" title="{$title}"/>
					</xsl:when>
					<xsl:when test="mods:location/mods:url">
						<link rel="DC.relation.isPartOf" href="{mods:location/mods:url}" title="{$title}"/>
					</xsl:when>
					<xsl:otherwise>
						<meta name="DC.relation.isPartOf" content="{$title}"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>

		</head>
	</xsl:template>

	<xsl:template match="mods:relatedItem" as="item()*">
		<xsl:choose>
			<xsl:when test="@type='host' and mods:titleInfo/mods:title!='encyclopedia' and @displayLabel!='Show Title'">
				<element field="collection" label="Collection" set="5" order="{position()}">
					<value>
						<xsl:value-of select="normalize-space(mods:titleInfo)" disable-output-escaping="no"/>
					</value>
				</element>
			</xsl:when>
<!--	<xsl:when test="@type='host' and mods:genre[@authority='marcgt']='periodical'">

</xsl:when>-->
			<xsl:when test="@type='host' and mods:identifier[@type='lccn']">
				<!-- afc cards collections -->
				<xsl:variable name="permalink">
					<xsl:value-of select="concat('http://lccn.loc.gov/',normalize-space(mods:identifier[@type='lccn']))" disable-output-escaping="no"/>
				</xsl:variable>
<xsl:variable name="label">
<xsl:choose><xsl:when test="$branding='nksip' or mods:identifier[@displayLabel='Journal Record'] ">Journal Title</xsl:when><xsl:otherwise>Catalog Record</xsl:otherwise>
</xsl:choose></xsl:variable>
				<element field="collection" label="{$label}" set="1" order="{position()}">
					<value>
						<href>
							<url>
								<xsl:value-of select="$permalink" disable-output-escaping="no"/>
							</url>
							<xsl:value-of select="normalize-space(mods:titleInfo[1])" disable-output-escaping="no"/>
&#160;<xsl:if test="mods:titleInfo[2]/@transliteration or mods:titleInfo[2]/@type='translated'"><xsl:value-of select="normalize-space(mods:titleInfo[2])"/></xsl:if>
						</href>
					</value>
				</element>
	<element field="citation" label="Citation" set="5" order="{position()}">
					<value><xsl:value-of select="normalize-space(mods:titleInfo[1])"/> 

<xsl:for-each select="mods:part">
	<xsl:if test="mods:detail">
<xsl:for-each select="mods:detail">
<xsl:value-of select="@type"/>:&#160;
<xsl:choose><xsl:when test="mods:caption"><xsl:value-of select="mods:caption"/>&#160;
<xsl:value-of select="mods:number"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="." disable-output-escaping="no"/>
</xsl:otherwise>
</xsl:choose>.&#160;
</xsl:for-each>
</xsl:if>
<xsl:if test="mods:extent">
&#160;<xsl:value-of select="mods:extent/@unit" disable-output-escaping="no"/>&#160;
<xsl:value-of select="string-join(mods:extent/*,'-')" disable-output-escaping="no"/>
</xsl:if>
<xsl:if test="mods:date">
,  <xsl:value-of select="mods:date" disable-output-escaping="no"/>.
</xsl:if>
</xsl:for-each>
					</value>
				</element>
			</xsl:when>
			<xsl:when test="@type='host' and mods:identifier[@type='url']">
				<!-- gottlieb or errors; should be location/url -->
				<relatedItem>
					<xsl:if test="@ID">
						<xsl:attribute name="ID">
							<xsl:value-of select="@ID" disable-output-escaping="no"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@type">
						<xsl:attribute name="type">
							<xsl:value-of select="@type" disable-output-escaping="no"/>
						</xsl:attribute>
					</xsl:if>
					<element field="collection" label="Collection Description" set="1" order="{position()}">
						<value>
							<xsl:if test="mods:titleInfo/@script='Arab'">
								<xsl:attribute name="dir">rtl</xsl:attribute>
							</xsl:if>
							<href>
								<url>
									<xsl:value-of select="mods:identifier[@type='url']" disable-output-escaping="no"/>
								</url>
								<xsl:value-of select="normalize-space(mods:titleInfo[1])" disable-output-escaping="no"/>
							</href>
						</value>
					</element>
				</relatedItem>
			</xsl:when>
			<xsl:when test="@type='host' and mods:location/mods:url">
				<!-- afc cards collections -->
				<relatedItem>
					<xsl:if test="@ID">
						<xsl:attribute name="ID">
							<xsl:value-of select="@ID" disable-output-escaping="no"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@type">
						<xsl:attribute name="type">
							<xsl:value-of select="@type" disable-output-escaping="no"/>
						</xsl:attribute>
					</xsl:if>
					<element field="collection" label="Collection Description" set="1" order="{position()}">
						<xsl:for-each select="mods:location/mods:url">
							<value>
								<xsl:if test="ancestor::mods:relatedItem/mods:titleInfo/@script='Arab'">
									<xsl:attribute name="dir">rtl</xsl:attribute>
								</xsl:if>
								<href>
									<url>
										<xsl:value-of select="." disable-output-escaping="no"/>
									</url>
									<xsl:value-of select="normalize-space(ancestor::mods:relatedItem/mods:titleInfo)" disable-output-escaping="no"/>
									<!-- temporary::: -->
									<xsl:if test="position()!=1">(beta)</xsl:if>
								</href>
							</value>
						</xsl:for-each>
					</element>
				</relatedItem>
			</xsl:when>
			<xsl:when test="@type='host' and @displayLabel='Show Title'">
				<!-- m1508shows -->
				<xsl:variable name="titletext">
					<xsl:value-of select="concat(mods:titleInfo/mods:nonSort,' ',mods:titleInfo/mods:title)" disable-output-escaping="no"/>
					<xsl:if test="mods:titleInfo/mods:subTitle">
						<xsl:value-of select="concat('; ', mods:titleInfo/mods:subTitle)" disable-output-escaping="no"/>
					</xsl:if>
				</xsl:variable>

				<xsl:variable name="encodedSearch">
					<xsl:value-of select="encode-for-uri( string-join(mods:titleInfo/*,' ') )" disable-output-escaping="no"/>
				</xsl:variable>
				<!--was showTitle:-->
				<xsl:variable name="search">
					<xsl:value-of select="concat($searchUrl,'&quot;',$encodedSearch,'&quot;&amp;qname=idx:titleLexicon')" disable-output-escaping="no"/>
				</xsl:variable>
				<element field="title" set="1" label="{@displayLabel}" order="1.5">
					<value>
						<xsl:if test="mods:titleInfo/@script='Arab'">
							<xsl:attribute name="dir">rtl</xsl:attribute>
						</xsl:if>
						<href>
							<url>
								<xsl:value-of select="$search" disable-output-escaping="no"/>
							</url>
							<xsl:value-of select="normalize-space($titletext)" disable-output-escaping="no"/>
						</href>
					</value>
				</element>
			</xsl:when>
			<xsl:otherwise>
				<relatedItem>
					<xsl:if test="@ID">
						<xsl:attribute name="ID">
							<xsl:value-of select="@ID" disable-output-escaping="no"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@type">
						<xsl:attribute name="type">
							<xsl:value-of select="@type" disable-output-escaping="no"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="*[local-name()!='relatedItem']"/>
					<xsl:choose>
						<xsl:when test="starts-with(@ID,'DMD_tr') or starts-with(@ID,'DMD_TR')">
							<element>
								<xsl:attribute name="label">
									<xsl:text disable-output-escaping="no">Track</xsl:text>
								</xsl:attribute>
								<value>
									<xsl:value-of select="number(substring(@ID,7))" disable-output-escaping="no"/>
								</value>
							</element>
						</xsl:when>
						<xsl:when test="starts-with(@ID,'DMD_p') or starts-with(@ID,'DMD_P')">
							<element>
								<xsl:attribute name="label">
									<xsl:text disable-output-escaping="no">Part</xsl:text>
								</xsl:attribute>
								<value>
									<xsl:value-of select="number(substring(@ID,6))" disable-output-escaping="no"/>
								</value>
							</element>
						</xsl:when>
						<!-- see also-->
						<xsl:when test="mods:relatedItem[not(@type)]">
							<xsl:for-each select="mods:relatedItem[not(@type)]">
								<xsl:variable name="url">
									<xsl:choose>
										<xsl:when test="contains(mods:location/mods:url,'extent:')">
											<xsl:value-of select="substring-before(mods:location/mods:url, ' extent:')" disable-output-escaping="no"/>
										</xsl:when>
										<xsl:when test="mods:location/mods:url">
											<xsl:value-of select="mods:location/mods:url" disable-output-escaping="no"/>
										</xsl:when>
										<xsl:when test="contains(mods:identifier[@type='url'],'extent:')">
											<xsl:value-of select="substring-before(mods:identifier[@type='url'], ' extent:')" disable-output-escaping="no"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="mods:identifier[@type='url']" disable-output-escaping="no"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<relatedItem>
									<element set="5" order="{position()}" label="See also">
										<value>
											<xsl:if test="mods:titleInfo/@script='Arab'">
												<xsl:attribute name="dir">rtl</xsl:attribute>
											</xsl:if>
											<href>
												<url>
												<xsl:value-of select="$url" disable-output-escaping="no"/>
												</url>
												<xsl:value-of select="normalize-space(mods:titleInfo)" disable-output-escaping="no"/>
											</href>
										</value>
									</element>
								</relatedItem>
							</xsl:for-each>
						</xsl:when>
					</xsl:choose>
				</relatedItem>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:subject[@authority!='keyword' or not(@authority)]" as="item()*">
		<xsl:variable name="order" select="position()"/>
		<xsl:choose>
			<!-- multiple searches in hierarchical geo -->
			<xsl:when test="mods:cartographics">
				<xsl:for-each select="mods:cartographics/*">
					<xsl:variable name="labels">
						<xsl:call-template name="translate"/>
					</xsl:variable>
					<element field="cartographics" order="{$order}" set="5">
						<xsl:attribute name="pluralLabel">
							<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
						</xsl:attribute>
						<xsl:attribute name="label">
							<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
						</xsl:attribute>
						<xsl:if test="@authority">
							<xsl:attribute name="authority">
								<xsl:value-of select="@authority" disable-output-escaping="no"/>
							</xsl:attribute>
						</xsl:if>
						<value>
							<xsl:if test="@script='Arab'">
								<xsl:attribute name="dir">rtl</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="." disable-output-escaping="no"/>
						</value>
					</element>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<element pluralLabel="Subjects" label="Subject" field="subject" order="{position()}" set="5">
					<value>
						<xsl:if test="@script='Arab'">
							<xsl:attribute name="dir">rtl</xsl:attribute>
						</xsl:if>
						<xsl:variable name="subjectDisplay">
							<xsl:apply-templates mode="subjectDisplay" select="*"/>
						</xsl:variable>
						<xsl:variable name="subjectSearch">
							<xsl:value-of select="normalize-space(string-join(*,'--'))" disable-output-escaping="no"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="mods:name">
								<!-- different target -->
								<xsl:variable name="subsearch1">
									<xsl:value-of select="normalize-space(string-join(mods:name/*[local-name()!='role'],' '))" disable-output-escaping="no"/>
								</xsl:variable>
								<xsl:variable name="search">
									<xsl:value-of select="concat($searchUrl,'&quot;',$subsearch1,'&quot;&amp;qname=idx:aboutName')" disable-output-escaping="no"/>
								</xsl:variable>
								<href>
									<url>
										<xsl:value-of select="$search" disable-output-escaping="no"/>
									</url>
									<xsl:if test="@authority='naf'">
										<browseurl>
											<xsl:value-of select="$browseUrl" disable-output-escaping="no"/>
											<xsl:value-of select="$subsearch1" disable-output-escaping="no"/>&amp;browse=name&amp;browse-order=ascending<xsl:if test="$ajaxparams!=''">&amp;<xsl:value-of select="$ajaxparams" disable-output-escaping="no"/></xsl:if></browseurl>
									</xsl:if>
									<xsl:value-of select="$subsearch1" disable-output-escaping="no"/>
									<xsl:text disable-output-escaping="no"> </xsl:text>
									<xsl:value-of select="string-join(*[local-name()!='name'],' ')" disable-output-escaping="no"/>
								</href>
							</xsl:when>
							<!-- multiple searches in hierarchical geo -->
							<xsl:when test="mods:hierarchicalGeographic">
								<xsl:for-each select="mods:hierarchicalGeographic/*">
									<xsl:variable name="subsearch1">	<xsl:value-of select="." disable-output-escaping="no"/>
										<!--chage this back when idx:aboutPlace contains the right strings:<xsl:choose>
											<xsl:when test="position()=first">
											<xsl:value-of select="." disable-output-escaping="no"/>
											</xsl:when>
											<xsl:otherwise>
											<xsl:for-each select="preceding-sibling::*">
											<xsl:value-of select="concat(.,' ')" disable-output-escaping="no"/>
											</xsl:for-each>
											<xsl:value-of select="." disable-output-escaping="no"/>
											</xsl:otherwise>
											</xsl:choose>-->
									</xsl:variable>
									<xsl:variable name="subsearch">
										<xsl:value-of select="normalize-space($subsearch1)" disable-output-escaping="no"/>
									</xsl:variable>
									<xsl:variable name="search">
										<xsl:value-of select="concat($searchUrl,$subsearch,'&amp;qname=idx:aboutPlace')" disable-output-escaping="no"/>
									</xsl:variable>
									<href>
										<url>
											<xsl:value-of select="$search" disable-output-escaping="no"/>
										</url>
										<xsl:if test="@authority='lcsh'">
											<browseurl>
												<xsl:value-of select="$browseUrl" disable-output-escaping="no"/>
												<xsl:value-of select="$subsearch" disable-output-escaping="no"/>&amp;browse=subject&amp;browse-order=ascending<xsl:if test="$ajaxparams!=''">&amp;<xsl:value-of select="$ajaxparams" disable-output-escaping="no"/></xsl:if></browseurl>
										</xsl:if>
										<xsl:value-of select="." disable-output-escaping="no"/>
										<xsl:if test="position()!=last()">
											<xsl:text disable-output-escaping="no">--</xsl:text>
										</xsl:if>
									</href>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="encodedSubject">
									<xsl:value-of select="encode-for-uri($subjectSearch)" disable-output-escaping="no"/>
								</xsl:variable>
								<xsl:variable name="searchfield">
									<xsl:choose>
										<!-- lcsh -->
										<xsl:when test="@authority='lcsh'">&amp;qname=idx:subjectLexicon</xsl:when>
										<!-- <xsl:when test="*/local-name()='name'">&amp;qname=idx:aboutName</xsl:when> -->
										<xsl:otherwise>&amp;qname=idx:topic</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="search">
									<xsl:value-of select="concat($searchUrl,'&quot;',$encodedSubject,'&quot;',$searchfield)" disable-output-escaping="no"/>
								</xsl:variable>
								<href>
									<url>
										<xsl:value-of select="normalize-space($search)" disable-output-escaping="no"/>
									</url>
									<xsl:if test="@authority='lcsh'">
										<browseurl>
											<xsl:value-of select="$browseUrl" disable-output-escaping="no"/>
											<xsl:value-of select="$encodedSubject" disable-output-escaping="no"/>&amp;browse=subject&amp;browse-order=ascending<xsl:if test="$ajaxparams!=''">&amp;<xsl:value-of select="$ajaxparams" disable-output-escaping="no"/></xsl:if></browseurl>
									</xsl:if>
									<xsl:value-of select="$subjectSearch" disable-output-escaping="no"/>
								</href>
							</xsl:otherwise>
						</xsl:choose>
					</value>
				</element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*" mode="subjectDisplay" as="item()*">
		<xsl:choose>
			<xsl:when test="local-name()='geographicCode' and @authority='marccountry'">
				<xsl:call-template name="getPlace"/>
			</xsl:when>
			<xsl:when test="local-name()='geographicCode' and @authority='marcgac'">
				<xsl:call-template name="getMarcGac"/>
			</xsl:when>
			<xsl:when test="local-name()='hierarchicalGeographic'">
				<xsl:apply-templates select="*" mode="subject"/>
			</xsl:when>
			<xsl:when test="position()=last()">
				<xsl:choose>
					<xsl:when test="local-name()='name'">
						<xsl:call-template name="nameValue"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="local-name()='name'">
						<xsl:call-template name="nameValue"/>--</xsl:when>
					<xsl:when test="parent::mods:hierarchicalGeographic">
						<xsl:value-of select="." disable-output-escaping="no"/>
						<xsl:if test="not(position()=last())">
							<xsl:text disable-output-escaping="no"> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(normalize-space(.),'--')" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*" mode="subjectSearch" as="item()*">
		<!-- search string has  AND instead of dash dash -->
		<xsl:choose>
			<xsl:when test="local-name()='geographicCode' and @authority='marccountry'">
				<xsl:call-template name="getPlace"/>
			</xsl:when>
			<xsl:when test="local-name()='geographicCode' and @authority='marcgac'">
				<xsl:call-template name="getMarcGac"/>
			</xsl:when>
			<xsl:when test="local-name()='hierarchicalGeographic'">
				<xsl:apply-templates select="*" mode="subject"/>
			</xsl:when>
			<xsl:when test="position()=last()">
				<xsl:choose>
					<xsl:when test="local-name()='name'">
						<xsl:call-template name="nameValue"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="local-name()='name'">
						<xsl:call-template name="nameValue"/>
					</xsl:when>
					<xsl:when test="parent::mods:hierarchicalGeographic">
						<xsl:value-of select="." disable-output-escaping="no"/>
						<xsl:if test="not(position()=last())">
							<xsl:text disable-output-escaping="no"> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
						<xsl:if test="not(position()=last())">
							<xsl:text disable-output-escaping="no"> </xsl:text>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getMarcGac" as="item()*">
		<!-- returns text geographic region from marcgac -->
		<xsl:variable name="gac" select="text()"/>

		<xsl:variable name="marcgac" select="document('http://www.loc.gov/standards/codelists/gacs.xml')/*[local-name()='codelist']"/>
		<xsl:for-each select="$marcgac/marcgac:gac[marcgac:code=$gac]">
			<xsl:value-of select="name[@authorized='yes']" disable-output-escaping="no"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mods:targetAudience | mods:*[@point='end'] | mods:note[@type='system details']| mods:note[@type='sort'] | mods:note[@type='local']| mods:note[@type='browse display'] | mods:note[@type='quality review']| mods:internetMediaType| mods:reformattingQuality |mods:digitalOrigin |  mods:identifier[@type='membership' or @type='index' or @type='afsNum' or @type='local']| mods:physicalLocation[@authority='marcorg']" as="item()*"/>

	<xsl:template match="mods:originInfo" as="item()*">
		<!--edition, issuance frequency, place publisher, dates-->
		<!-- set2 -->
		<xsl:apply-templates select="*[not(local-name()='dateIssued')]"/>
		<!-- suppress multiple dates based on 008 -->
		<xsl:choose>
			<xsl:when test="count(mods:dateIssued[not(@point)]) &gt; 1 and mods:dateIssued[not(@point)][@encoding='marc']">
				<xsl:apply-templates select="mods:dateIssued[not(@point)][@encoding!='marc' or not(@encoding)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="mods:dateIssued[not(@point)]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="mods:dateIssued[@point='start' or not(@point)] | mods:dateCreated[@point='start' or not(@point)] | mods:dateCaptured[@point='start' or not(@point)] | mods:copyrightDate[@point='start' or not(@point)] | mods:dateValid[@point='start' or not(@point)] | mods:dateModified[@point='start' or not(@point)] | mods:dateOther[@point='start' or not(@point)]" as="item()*">
		<xsl:variable name="labels">
			<xsl:choose>
				<!--minerva:-->
				<xsl:when test="lower-case(ancestor::mods:mods/mods:genre)='web site' and local-name()='dateCaptured'">Dates Captured|Date Captured</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="translate"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<element field="originInfo" order="{position()}" set="2.5">
			<xsl:attribute name="pluralLabel">
				<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:if test="@keyDate">
				<xsl:attribute name="keyDate">
					<xsl:value-of select="@keyDate" disable-output-escaping="no"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:variable name="dateValue">
				<xsl:call-template name="getDate">
					<xsl:with-param name="date">
						<xsl:choose>
							<xsl:when test="contains(.,']') and not(contains(.,'['))">
								<xsl:value-of select="translate(.,']','')" disable-output-escaping="no"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<value>
				<xsl:choose>
					<xsl:when test="not(@point)">
						<xsl:value-of select="$dateValue" disable-output-escaping="no"/>
					</xsl:when>
					<!--one date-->
					<xsl:when test="@point='start'">
						<!--date range-->
						<xsl:variable name="thisDate">
							<xsl:value-of select="local-name()" disable-output-escaping="no"/>
						</xsl:variable>
						<xsl:value-of select="$dateValue" disable-output-escaping="no"/>--<xsl:if test="../*[local-name()=$thisDate][@point='end'][text()!='OPEN']">
							<xsl:call-template name="getDate">
								<xsl:with-param name="date">
									<xsl:value-of select="../*[local-name()=$thisDate][@point='end']" disable-output-escaping="no"/>
								</xsl:with-param>
							</xsl:call-template></xsl:if></xsl:when>
				</xsl:choose>
				<xsl:if test="@qualifier">(<xsl:value-of select="@qualifier" disable-output-escaping="no"/>)</xsl:if>
			</value>
		</element>
	</xsl:template>
	<xsl:template match="mods:place" as="item()*">
		<!-- if there are 2 or more, and this one has authority, skip it -->
		<xsl:if test="not((count(../mods:place) &gt; 1) and (mods:placeTerm/@authority='marccountry'))">
			<xsl:variable name="labels">
				<xsl:call-template name="translate"/>
			</xsl:variable>
			<element field="place" order="{position()}" set="2">
				<xsl:attribute name="pluralLabel">
					<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
				</xsl:attribute>
				<xsl:attribute name="label">
					<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
				</xsl:attribute>
				<xsl:if test="@authority">
					<xsl:attribute name="authority">
						<xsl:value-of select="@authority" disable-output-escaping="no"/>
					</xsl:attribute>
				</xsl:if>
				<value>
					<xsl:if test="@script='Arab'">
						<xsl:attribute name="dir">rtl</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="getPlace"/>
				</value>
			</element>
		</xsl:if>
	</xsl:template>
	<xsl:template match="mods:location" as="item()*">
		<xsl:apply-templates select="* | text()"/>
		<!-- physicallocation, url, shelfLocator -->
	</xsl:template>
	<xsl:template match="mods:shelfLocator" as="item()*">
		<xsl:variable name="labels">
			<xsl:call-template name="translate">
				<xsl:with-param name="string">shelfLocator</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<element field="location" order="{position()}" set="6">
			<xsl:attribute name="pluralLabel">
				<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<value>
				<xsl:if test="@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</value>
		</element>
	</xsl:template>

	<xsl:template match="mods:physicalLocation[not(@authority) or @authority!='marcorg']" as="item()*">
		<xsl:variable name="labels">
			<xsl:call-template name="translate">
				<xsl:with-param name="string">physicalLocation</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="href">
			<xsl:choose>
				<xsl:when test="@xlink:href">
					<xsl:value-of select="@xlink:href" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="contains(.,'Music Division')">http://www.loc.gov/rr/perform/</xsl:when>
				<xsl:when test="contains(.,'Performing Arts')">http://www.loc.gov/rr/perform/</xsl:when>
				<xsl:when test="contains(.,'American Folklife Center')">http://www.loc.gov/folklife/</xsl:when>
				<xsl:when test="contains(.,'Moving Image Section')">http://www.loc.gov/rr/mopic/</xsl:when>
				<xsl:when test="contains(.,'Recorded Sound Section')">http://www.loc.gov/rr/record/</xsl:when>
				<xsl:when test="contains(.,'Prints and Photographs Division')">http://www.loc.gov/rr/print/</xsl:when>
				<xsl:when test="contains(.,'Rare Book')">http://www.loc.gov/rr/rarebook/</xsl:when>
				<xsl:when test="contains(.,'Manuscript Division')">http://www.loc.gov/rr/mss/</xsl:when>
				<xsl:when test="contains(.,'Law Library')">http://www.loc.gov/law/</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<element field="location" order="{position()}" set="6">
			<xsl:attribute name="pluralLabel">
				<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<value>
				<xsl:if test="@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$href!=''">
						<!-- 	<href url="{$href}"> -->
						<href>
							<url>
								<xsl:value-of select="$href" disable-output-escaping="no"/>
							</url>
							<xsl:value-of select="." disable-output-escaping="no"/>
						</href>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</value>
		</element>
	</xsl:template>
	<!-- doesnt work -->
	<xsl:template match="mods:url[@displayLabel='Archived site' or @usage='primary display']" as="item()*"/>
	<!-- <xsl:call-template name="url"/>		
	</xsl:template> -->
	<xsl:template match="mods:url[(@displayLabel!='Archived site' or not(@displayLabel )) and (@usage!='primary display' or not(@usage) )]" as="item()*">
		<xsl:call-template name="url"/>
	</xsl:template>
	<xsl:template name="url" as="item()*">
		<!--<xsl:choose><xsl:when test="$viewable='yes'">-->

<xsl:if test="$branding!='tohap'">
		<xsl:variable name="labels">
			<xsl:call-template name="translate">
				<xsl:with-param name="string">
					<xsl:choose>
						<xsl:when test="@displayLabel">
							<xsl:value-of select="@displayLabel" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:when test="@usage">
							<xsl:value-of select="@usage" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:when test="not(@displayLabel)">
							<xsl:value-of select="local-name()" disable-output-escaping="no"/>
						</xsl:when>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<element field="url" order="{position()}" set="6">
			<xsl:attribute name="pluralLabel">
				<xsl:choose>
					<xsl:when test="normalize-space(substring-before($labels,'|'))!=''">
						<xsl:value-of select="$labels" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:when test="contains($labels,'|')">
						<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$labels" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:choose>
					<xsl:when test="normalize-space(substring-after($labels,'|'))!=''">
						<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$labels" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<value>
				<xsl:if test="@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<!-- <xsl:choose>
				<xsl:when test="$viewable='yes'"> -->
				<href>
					<url>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</url>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</href>
				<!-- </xsl:when>
				<xsl:otherwise><xsl:value-of select="." disable-output-escaping="no"/></xsl:otherwise>
				</xsl:choose> -->
			</value>
		</element></xsl:if>
	</xsl:template>

	<xsl:template match="mods:name" as="item()*">
		<xsl:variable name="role">
			<xsl:call-template name="getRole"/>
		</xsl:variable>
		<xsl:variable name="labels">
			<xsl:call-template name="translate">
				<xsl:with-param name="string">
					<xsl:choose>
						<xsl:when test="@authority='naf'">
							<xsl:value-of select="concat('Authorized ',local-name())" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:when test="$role='Performer' and @type='corporate'">
							<xsl:value-of select="concat(@type,$role)" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:when test="$role!=''">
							<xsl:value-of select="$role" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:when test="@type='conference' or @type='corporate'">
							<xsl:value-of select="concat(@type,local-name())" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>Name</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<element field="name" set="1" order="{position()}">
			<xsl:attribute name="pluralLabel">
				<xsl:choose>
					<xsl:when test="contains($labels,'|')">
						<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($labels,'s')" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:choose>
					<xsl:when test="contains($labels,'|')">
						<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$labels" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:call-template name="nameValue"/>
		</element>
	</xsl:template>
	<xsl:template match="mods:identifier[(@type!='local' and @type!='index' and @type!='membership' and @type!='afsNum') or not(@type)]" as="item()*">
		<xsl:variable name="labels">
			<xsl:choose>
				<xsl:when test="@type='stock number'">
					<xsl:call-template name="translate">
						<xsl:with-param name="string">
							<xsl:value-of select="concat('Reproduction Number ',@displayLabel)" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="@displayLabel">
					<xsl:value-of select="@displayLabel" disable-output-escaping="no"/>
				</xsl:when>

				<xsl:when test="@type">
					<xsl:call-template name="translate">
						<xsl:with-param name="string">
							<xsl:value-of select="@type" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="translate"/>
					<!-- (local-name)-->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<element field="identifier" order="{position()}" set="5">
			<xsl:if test="text()">
				<xsl:attribute name="order">
					<xsl:choose>
						<xsl:when test="@type='lccn'">1</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="position()" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="order">
					<xsl:choose>
						<xsl:when test="@type='lccn'">1</xsl:when>
						<xsl:otherwise>5</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="pluralLabel">
					<xsl:choose>
						<xsl:when test="not(contains($labels, '|'))">
							<xsl:value-of select="$labels" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="label">
					<xsl:choose>
						<xsl:when test="not(contains($labels, '|'))">
							<xsl:value-of select="$labels" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<value>
					<xsl:if test="@script='Arab'">
						<xsl:attribute name="dir">rtl</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="@invalid='yes'">
							<xsl:value-of select="." disable-output-escaping="no"/>(invalid)</xsl:when>
						<xsl:when test="@type='lccn'">
							<!-- fix this when permalink comes over -->
							<!-- <xsl:value-of select="../."/>lccn.loc.gov/<xsl:value-of select="."/> -->
							<href>
								<url>http://lccn.loc.gov/<xsl:value-of select="." disable-output-escaping="no"/></url>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</href>
						</xsl:when>
						<xsl:when test="@type='AFS Number'">
							<!--should be limited to memberOf:afc99990005 also!!-->

							<href>
								<url>
									<xsl:value-of select="concat($searchUrl,'&quot;',. ,'&quot;&amp;qname=mods:identifier')" disable-output-escaping="no"/>
								</url>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</href>
						</xsl:when>
						<xsl:when test="@type='AFC Number'">
							<!--should be limited to memberOf:afc99990005 also!!-->
							<href>
								<url>
									<xsl:value-of select="concat($searchUrl,'&quot;',.,'&quot;&amp;qname=mods:identifier')" disable-output-escaping="no"/>
								</url>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</href>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="." disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</xsl:if>
		</element>
	</xsl:template>
	<xsl:template match="mods:subject[@authority='keyword']" as="item()*">
		<!--lcwa html keywords suppressed per Rick et al. -->
		<!-- <element field="subject" order="{position()}" set="5" label="HTML Keywords Note" pluralLabel="HTML Keywords Notes">
			<value>
				<xsl:if test="@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="mods:topic"/>
			</value>
		</element> -->
	</xsl:template>
	<xsl:template match="mods:typeOfResource | mods:publisher |  mods:genre | mods:form | mods:note[parent::mods:physicalDescription] | mods:extent  | mods:abstract | mods:tableOfContents |mods:issuance  |mods:edition|mods:recordIdentifier | mods:classification |mods:accessCondition | mods:part | mods:descriptionStandard" as="item()*">
		<xsl:if test="text()">
<xsl:if test="not($branding='nksip' and local-name()='classification')">
			<!-- genre, typeofresource=set2set2:edition, issuance frequency , publisherset4: mods:form, extent, mods:note[parent::mods:physicalDescription]set5: abstract, tableofcontents, accessCondition, part-->
			<xsl:variable name="labels">
				<xsl:choose>
					<xsl:when test="@displayLabel">
						<xsl:value-of select="@displayLabel" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:when test="@type">
						<xsl:call-template name="translate">
							<xsl:with-param name="string">
								<xsl:value-of select="@type" disable-output-escaping="no"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="translate"/>
						<!-- (local-name)-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="fieldName">
				<xsl:choose>
					<xsl:when test="parent::mods:mods">
						<xsl:value-of select="local-name()" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="local-name(parent::*)" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="set">
				<xsl:choose>
					<!-- set is combined with order to retain cataloging (mods) order in the data -->
					<xsl:when test="contains('typeOfResource',local-name())">1</xsl:when>
					<xsl:when test="contains('genre',local-name())">2</xsl:when>
					<xsl:when test="contains('edition, issuance frequency, publisher',local-name())">3</xsl:when>
					<xsl:when test="contains('form, extent, note',local-name())">4</xsl:when>
					<xsl:when test="contains('abstract, :tableOfContents classification  accessCondition part',local-name())">5</xsl:when>
					<xsl:when test="contains('recordIdentifier, descriptionStandard',local-name())">6</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="order">
				<xsl:choose>
					<!-- set is combined with order to retain cataloging (mods) order in the data -->
					<xsl:when test="contains('typeOfResource',local-name())">.9</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="position()" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<element field="{$fieldName}" order="{$order}" set="{$set}">
				<xsl:attribute name="pluralLabel">
					<xsl:choose>
						<xsl:when test="contains($labels,'|')">
							<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($labels,'(s)')" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="label">
					<xsl:choose>
						<xsl:when test="contains($labels,'|')">
							<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$labels" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>

				<value>
					<xsl:if test="@script='Arab'">
						<xsl:attribute name="dir">rtl</xsl:attribute>
					</xsl:if>
					<xsl:if test="local-name()='abstract'">
						<xsl:attribute name="xml:space">preserve</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="local-name()='classification' and @authority='lcc'">
							<xsl:variable name="isvalid">
								<xsl:call-template name="verifylcc">
									<xsl:with-param name="class" select="."/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$isvalid = 'true'">
									<xsl:variable name="browse">
										<xsl:value-of select="concat($browseUrl,encode-for-uri(normalize-space(.)),'&amp;',$ajaxparams,'&amp;browse-order=ascending&amp;browse=class')" disable-output-escaping="no"/>
									</xsl:variable>
									<href>
										<browseurl>
											<xsl:value-of select="$browse" disable-output-escaping="no"/>
										</browseurl>
										<xsl:value-of select="." disable-output-escaping="no"/>
									</href>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="." disable-output-escaping="no"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="local-name()='classification'">
							<xsl:value-of select="." disable-output-escaping="no"/>
						</xsl:when>
						<xsl:when test="local-name()='genre' and @authority='local'">
							<xsl:variable name="search">
								<xsl:value-of select="concat($searchUrl,'&quot;',normalize-space(.),'&quot;&amp;qname=mods:genre')" disable-output-escaping="no"/>
							</xsl:variable>
							<href>
								<url>
									<xsl:value-of select="$search" disable-output-escaping="no"/>
								</url>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</href>
						</xsl:when>
						<xsl:when test="@xlink">
							<href>
								<url>
									<xsl:value-of select="@xlink" disable-output-escaping="no"/>
								</url>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</href>
						</xsl:when>
						<xsl:when test="local-name()='part'">
							<xsl:apply-templates select="mods:extent" mode="value"/>
						</xsl:when>
						<xsl:when test="local-name()='typeOfResource' and @collection='yes'">
							<xsl:value-of select="." disable-output-escaping="no"/>
							<xsl:text disable-output-escaping="no"> </xsl:text>collection</xsl:when>
						<!--should this only be for type of resource=text?-->
						<xsl:when test="local-name()='typeOfResource' and ../mods:originInfo/mods:issuance='continuing'">
							<xsl:value-of select="." disable-output-escaping="no"/>
							<xsl:text disable-output-escaping="no"> </xsl:text>(serial)</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="." disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</element>
</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template match="mods:subTitle | mods:partNumber" as="item()*">; <xsl:value-of select="." disable-output-escaping="no"/></xsl:template>
	<xsl:template match="mods:extent" mode="value" as="item()*">
		<xsl:choose>
			<xsl:when test="mods:start and mods:end and @unit='page'">
				<xsl:value-of select="concat('pp. ', number(mods:start),'-',number(mods:end))" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="@unit='page'">
				<xsl:value-of select="concat('p. ',.)" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="mods:*" mode="value" as="item()*">
		<xsl:value-of select="." disable-output-escaping="no"/>
	</xsl:template>
	<xsl:template match="mods:recordInfo" as="item()*">
		<xsl:apply-templates select="mods:recordIdentifier"/>
		<xsl:apply-templates select="mods:descriptionStandard"/>
	</xsl:template>
	<xsl:template match="mods:relatedItem[@type='constituent'][not(@ID)]" as="item()*">
		<element label="Contains" field="title" order="{position()}">
			<xsl:for-each select="mods:titleInfo">
				<value>
					<xsl:if test="@script='Arab'">
						<xsl:attribute name="dir">rtl</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
				</value>
			</xsl:for-each>
		</element>
	</xsl:template>
	<xsl:template match="mods:relatedItem[@type='constituent'][not(@ID)]" mode="tree" as="item()*">
		<element label="Contains" field="relatedItem" order="{position()}">
			<xsl:variable name="label">
				<xsl:value-of select="normalize-space(mods:titleInfo[1])" disable-output-escaping="no"/>
				<xsl:if test="mods:genre">[<xsl:value-of select="mods:genre" disable-output-escaping="no"/>]</xsl:if>
			</xsl:variable>
			<value>
				<xsl:if test="mods:titleInfo/@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="mods:location/mods:url">

						<href>
							<url>
								<xsl:value-of select="mods:location/mods:url" disable-output-escaping="no"/>
							</url>
							<xsl:value-of select="$label" disable-output-escaping="no"/>
						</href>
					</xsl:when>
					<xsl:when test="mods:identifier[@type='url']">

						<href>
							<url>
								<xsl:value-of select="mods:identifier[@type='url']" disable-output-escaping="no"/>
							</url>
							<xsl:value-of select="$label" disable-output-escaping="no"/>
						</href>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$label" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</value>
			<xsl:apply-templates select="mods:relatedItem[@type='constituent'][not(@ID)]" mode="tree"/>
		</element>
	</xsl:template>
	<xsl:template match="mods:titleInfo" as="item()*">
		<xsl:variable name="labels">
			<xsl:choose>
				<xsl:when test="@transliteration">Transliterations|Transliteration</xsl:when>
				<xsl:when test="starts-with($index,'m1508shows')">Song titles|Song title</xsl:when>
				<xsl:when test="starts-with($index,'m1508')">Song titles|Song title</xsl:when>
				<xsl:when test="@displayLabel">
					<xsl:value-of select="@displayLabel" disable-output-escaping="no"/>|</xsl:when>
				<xsl:when test="parent::mods:relatedItem/@type='series'">
					<xsl:call-template name="translate">
						<xsl:with-param name="string">
							<xsl:value-of select="concat(parent::mods:relatedItem/@type,local-name())" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>

				<xsl:when test="@type">
					<xsl:call-template name="translate">
						<xsl:with-param name="string">
							<xsl:value-of select="concat(@type,local-name())" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="translate">
						<xsl:with-param name="string">
							<xsl:value-of select="local-name()" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<element field="title" set="1" order="{position()}">
			<xsl:attribute name="pluralLabel">
				<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<value>
				<xsl:if test="@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<xsl:variable name="text">
					<xsl:apply-templates select="* | text()"/>
					<!--<xsl:if test="not(@type) and not (//mods:mods/mods:identifier[@type='membership']='encyclopedia')">
						<xsl:call-template name="genreForm"/>
					</xsl:if>-->
				</xsl:variable>
				<xsl:value-of select="normalize-space($text)" disable-output-escaping="no"/>
			</value>
		</element>
	</xsl:template>
	<xsl:template name="genreForm" as="item()*">
		<xsl:choose>
			<xsl:when test="../mods:genre">
				<xsl:text disable-output-escaping="no"> [</xsl:text>
				<xsl:value-of select="../mods:genre[1]" disable-output-escaping="no"/>]</xsl:when>
			<xsl:when test="count(../mods:physicalDescription/mods:form) &gt; 1 and ../mods:physicalDescription/mods:form[@authority='marcform']">
				<xsl:text disable-output-escaping="no"> [</xsl:text>
				<xsl:value-of select="../mods:physicalDescription/mods:form[not(@authority='marcform') or not(@authority)][1]" disable-output-escaping="no"/>]</xsl:when>
			<xsl:when test="../mods:physicalDescription/mods:form">
				<xsl:text disable-output-escaping="no"> [</xsl:text>
				<xsl:value-of select="../mods:physicalDescription/mods:form[1]" disable-output-escaping="no"/>]</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="mods:language" as="item()*">
		<xsl:variable name="labels">
			<xsl:call-template name="translate"/>
		</xsl:variable>
		<element order="{position()}" set="3">
			<xsl:attribute name="pluralLabel">
				<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:for-each select="mods:languageTerm">
				<value>
					<xsl:if test="../@script='Arab'">
						<xsl:attribute name="dir">rtl</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="getLanguage"/>
				</value>
			</xsl:for-each>
		</element>
	</xsl:template>
	<xsl:template match="mods:relatedItem[@type='otherVersion']" as="item()*">
		<element order="{position()}" set="1">
			<xsl:variable name="labels">
				<xsl:text disable-output-escaping="no">Version </xsl:text>
				<xsl:value-of select="number(substring-after(@ID,'ver'))" disable-output-escaping="no"/>
			</xsl:variable>
			<xsl:attribute name="pluralLabel">
				<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
			</xsl:attribute>
			<value>
				<xsl:if test="@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<xsl:value-of select="mods:note" disable-output-escaping="no"/>
			</value>
		</element>
	</xsl:template>
	<xsl:template match="mods:physicalDescription" as="item()*">
		<xsl:choose>
			<xsl:when test="count(mods:form) &gt; 1 and mods:form[@authority='marcform']">
				<xsl:apply-templates select="mods:form[@authority!='marcform' or not(@authority)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="mods:form"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="mods:extent | mods:note"/>
		<!--form  extent  note-->
	</xsl:template>

	<xsl:template match="mods:recordInfo[substring(mods:recordChangeDate,1,2)!='00' ]/mods:recordChangeDate" as="item()*">

		<!-- <xsl:for-each select="mods:recordInfo[1][substring(mods:recordChangeDate,1,2)!='00']/mods:recordChangeDate"> -->
		<xsl:variable name="century">
			<xsl:choose>
				<xsl:when test="@encoding='marc' and number(substring(.,1, 2))&lt; 50">20</xsl:when>
				<xsl:when test="@encoding='marc' and number(substring(.,1, 2))&gt;= 50">19</xsl:when>
				<xsl:when test="@encoding='iso8601'">
					<xsl:value-of select="substring(.,1, 4)" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="viewFormat">
			<xsl:choose>
				<xsl:when test="@encoding='marc'">
					<xsl:value-of select="concat(substring(.,3, 2),'-',substring(.,5, 2),'-',$century,substring(.,1, 2 ))" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="@encoding='iso8601'">
					<!-- <xsl:value-of select="concat(substring(.,5, 2),'-',substring(.,7, 2),'-',$century,substring(.,3, 2 ))"/> -->
					<xsl:value-of select="concat(substring(.,5, 2),'/',substring(.,7, 2),'/',$century)" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<element label="Record updated" set="6" order="99">
			<value>
				<xsl:value-of select="$viewFormat" disable-output-escaping="no"/>
			</value>
		</element>
	</xsl:template>
	<xsl:template name="translate" as="item()*">
		<xsl:param name="count"/>
		<!-- >1=plural label -->
		<xsl:param name="string">
			<xsl:value-of select="local-name()" disable-output-escaping="no"/>
		</xsl:param>
		<xsl:choose>

			<xsl:when test="$dictionary/entry[@key=$string]">
				<xsl:value-of select="$dictionary/entry[@key=$string]/@plural" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">|</xsl:text>
				<xsl:value-of select="$dictionary/entry[@key=$string]" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(upper-case(substring($string,1,1)) , substring($string,2))" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getDate" as="item()*">
		<xsl:param name="date"/>
		<xsl:choose>
			<!--<mods:dateCaptured encoding="iso8601" point="start" keyDate="yes">20030313</mods:dateCaptured><mods:dateCaptured point="end">OPEN</mods:dateCaptured>-->

			<xsl:when test="@encoding='iso8601' and substring(translate(.,'-',''),7,2)!='00' ">
				<xsl:value-of select="concat(substring(translate($date,'-',''),5,2),'-', substring(translate(.,'-',''),7,2),'-', substring(.,1,4))" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="@encoding='iso8601' and substring(translate(.,'-',''),7,2)='00'">
				<xsl:value-of select="concat(substring(translate($date,'-',''),5,2),'-',  substring(translate(.,'-',''),1,4))" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$date" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getLanguage" as="item()*">
		<xsl:choose>
			<xsl:when test="(@type='code' and @authority='iso639-2b') or starts-with($index, 'afc9999005')">
				<xsl:variable name="languageCode">
					<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
				</xsl:variable>
				<xsl:value-of select="$languages/language[@code=$languageCode]" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getRole" as="item()*">
		<!-- returns text role or nothing -->
		<xsl:variable name="role">
			<xsl:choose>
				<xsl:when test="mods:role[2] and mods:role/mods:roleTerm[@authority='marcrelator']='cre' or mods:role/mods:roleTerm[@authority='marcrelator']='creator'">
					<xsl:copy-of select="mods:role[not(mods:roleTerm[@authority='marcrelator'])]" copy-namespaces="yes"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="mods:role" copy-namespaces="yes"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>

			<xsl:when test="$role/mods:role/mods:roleTerm[@type='text']">
				<xsl:variable name="text">
					<xsl:call-template name="properCase">
						<xsl:with-param name="string">
							<xsl:value-of select="$role/mods:role/mods:roleTerm[@type='text']" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$relators/relator[text()=$text]/@plural" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">|</xsl:text>
				<xsl:value-of select="$text" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="$role/mods:role/mods:roleTerm[not(@type) or @type!='code']">
				<xsl:value-of select="mods:role/mods:roleTerm" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="$role/mods:role/mods:roleTerm[@type='code']">
				<xsl:variable name="code" select="$role/mods:role/mods:roleTerm[@type='code']"/>
				<xsl:value-of select="$relators/relator[@code=$code]/@plural" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">|</xsl:text>
				<xsl:value-of select="$relators/relator[@code=$code]" disable-output-escaping="no"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getPlace" as="item()*">
		<!-- returns text place or contents of placeTerm -->
		<xsl:choose>
			<xsl:when test="mods:placeTerm[@type='text']">
				<xsl:value-of select="mods:placeTerm[@type='text']" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="mods:placeTerm[@type='code'][@authority='marccountry']">
				<xsl:variable name="placeCode" select="translate(normalize-space(mods:placeTerm[@type='code']),'|','')"/>
				<xsl:value-of select="$countries/country[@code=$placeCode]" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="local-name()='geographicCode' and @authority='marccountry'">
				<!-- subject -->
				<xsl:variable name="placeCode" select="translate(.,'|','')"/>
				<xsl:value-of select="$countries/country[@code=$placeCode]" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="mods:placeTerm" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*" mode="subject" as="item()*">
		<xsl:value-of select="concat(text(),' ')" disable-output-escaping="no"/>
	</xsl:template>
	<xsl:template name="properCase" as="item()*">
		<!--convert first char of string to upper-->
		<xsl:param name="string"/>
		<xsl:value-of select="concat(upper-case(substring($string,1,1)),substring($string, 2))" disable-output-escaping="no"/>
	</xsl:template>
	<xsl:template name="nameValue" as="item()*">
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="mods:namePart[@type='family']">
					<xsl:value-of select="mods:namePart[@type='family']" disable-output-escaping="no"/>
					<xsl:if test="mods:namePart[@type='given']">, <xsl:value-of select="mods:namePart[@type='given']" disable-output-escaping="no"/></xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="descendant-or-self::mods:namePart">
						<!--assumes family then given, then termsOfaddress types-->
						<xsl:value-of select="." disable-output-escaping="no"/>
						<xsl:choose>
							<xsl:when test="position()!=last()">
								<xsl:text disable-output-escaping="no">, </xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="index-term">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::mods:subject">idx:aboutName</xsl:when>
				<xsl:otherwise>idx:byName</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<value>
			<xsl:if test="@script='Arab'">
				<xsl:attribute name="dir">rtl</xsl:attribute>
			</xsl:if>
			<href>
				<url>
					<xsl:value-of select="$searchUrl" disable-output-escaping="no"/>
					<xsl:value-of select="encode-for-uri($name)" disable-output-escaping="no"/>&amp;qname=<xsl:value-of select="$index-term"/></url>
				<!--???? nate changed this because it's already on mods:name, right???? 11/21/11-->
				<!--<xsl:if test="mods:name[@authority='naf']">-->
				<xsl:if test="@authority='naf'">
					<browseurl>
						<xsl:value-of select="$browseUrl" disable-output-escaping="no"/>
						<xsl:value-of select="encode-for-uri($name)" disable-output-escaping="no"/>
						<xsl:if test="$ajaxparams!=''">&amp;<xsl:value-of select="$ajaxparams" disable-output-escaping="no"/></xsl:if>&amp;browse=author&amp;browse-order=ascending</browseurl>
				</xsl:if>
				<xsl:value-of select="$name" disable-output-escaping="no"/>
				<xsl:if test="mods:role[2]/mods:roleTerm">, <xsl:value-of select="mods:role[2]/mods:roleTerm" disable-output-escaping="no"/></xsl:if>
			</href>
			<!-- <xsl:if test="mods:namePart[(@type='date')]"><xsl:text> </xsl:text><xsl:value-of select="mods:namePart[(@type='date')]"/></xsl:if> -->
		</value>
	</xsl:template>
	<xsl:template match="mods:note[local-name(parent::*)!='physicalDescription'][(@type!='selection decision' and @type!='local'  and @type!='sort' and  @type!='browse display' and @type!='system details' and @type!='quality review') or not(@type)]" as="item()*">
		<xsl:variable name="labels">
			<xsl:call-template name="translate">
				<xsl:with-param name="string">
					<xsl:choose>
						<!-- <xsl:when test="@displayLabel">							<xsl:value-of select="@displayLabel"/>|<xsl:value-of select="@displayLabel"/>						</xsl:when> -->
						<xsl:when test="substring(@type,2) = 'eneral' or not(@type)">Notes|Note</xsl:when>
						<xsl:when test="@type='statement of responsibility' and contains($index, 'afc9999005')">performance note</xsl:when>
						<xsl:when test="@type">
							<xsl:value-of select="@type" disable-output-escaping="no"/>
						</xsl:when>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<element field="note" order="{position()}" set="5">
			<xsl:attribute name="pluralLabel">
				<xsl:choose>
					<xsl:when test="@displayLabel">
						<xsl:value-of select="@displayLabel" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:when test="contains(substring-before($labels,'|'),'otes')">
						<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before($labels,'|')" disable-output-escaping="no"/>
						<xsl:if test="@type and substring(@type,2)!='eneral'">notes</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="label">
				<xsl:choose>
					<xsl:when test="@displayLabel">
						<xsl:value-of select="@displayLabel" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:when test="contains($labels,'|')">
						<xsl:value-of select="substring-after($labels,'|')" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$labels" disable-output-escaping="no"/>
						<!-- <xsl:if test="substring(@type,2!='eneral')">&#xA0;note</xsl:if> -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>

			<value>
				<xsl:if test="@script='Arab'">
					<xsl:attribute name="dir">rtl</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="@type='gottlieb assignment'">

						<xsl:variable name="search">
							<xsl:value-of select="concat($searchUrl,'&quot;',encode-for-uri(.),'&quot;&amp;qname=mods:note')" disable-output-escaping="no"/>
						</xsl:variable>
						<href>
							<url>
								<xsl:value-of select="normalize-space($search)" disable-output-escaping="no"/>
							</url>
							<xsl:value-of select="." disable-output-escaping="no"/>
						</href>
					</xsl:when>
					<xsl:when test="@type='copyright link'">
						<href>
							<url>
								<xsl:value-of select="." disable-output-escaping="no"/>
							</url>
							<xsl:value-of select="." disable-output-escaping="no"/>
						</href>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</value>
		</element>
	</xsl:template>

	<xsl:template name="pageTitle" as="item()*">
		<!-- title, / first name [gmd ] -->
		<xsl:variable name="titleField">
			<xsl:if test="//mods:mods/mods:titleInfo[1][not(@type)]/mods:nonSort">
				<xsl:value-of select="//mods:mods/mods:titleInfo[1][not(@type)]/mods:nonSort" disable-output-escaping="no"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="//mods:mods/mods:titleInfo[1][not(@type)][mods:subTitle]">
					<xsl:value-of select="concat(//mods:mods/mods:titleInfo[1][not(@type)]/mods:title,'; ',//mods:mods/mods:titleInfo[1][not(@type)]/mods:subTitle)" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="//mods:mods/mods:titleInfo[1][not(@type)]">
					<xsl:value-of select="normalize-space(string-join(//mods:mods/mods:titleInfo[1][not(@type)],' '))" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="//mods:mods/mods:titleInfo[1][mods:subTitle]">
					<xsl:value-of select="concat(//mods:mods/mods:titleInfo[1]/mods:title,'; ',//mods:mods/mods:titleInfo[1]/mods:subTitle)" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="//mods:mods/mods:titleInfo[1]">
					<xsl:value-of select="normalize-space(string-join(//mods:mods/mods:titleInfo[1]/*[local-name()!='nonSort'],' '))" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>[No Title]</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$titleField" disable-output-escaping="no"/>
		<xsl:if test="//mods:mods/mods:name">
			<xsl:text disable-output-escaping="no"> / </xsl:text>
			<xsl:choose>
				<xsl:when test="//mods:mods/mods:name[1][@type='corporate']">
					<xsl:value-of select="//mods:mods/mods:name[1]/mods:namePart[not(@type = 'date')]" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="//mods:mods/mods:name/mods:role/mods:roleTerm[@type='text']='Author'">
							<xsl:for-each select="//mods:mods/mods:name[mods:role/mods:roleTerm[@type='text']='Author'][position()&lt;= 3]">
								<xsl:call-template name="displayName">
									<xsl:with-param name="name" select="mods:namePart[not(@type = 'date')]"/>
								</xsl:call-template>
								<xsl:if test="position()!=last()">
									<xsl:text disable-output-escaping="no">, </xsl:text>
								</xsl:if>
							</xsl:for-each>
							<xsl:if test="count(//mods:mods/mods:name[mods:role/mods:roleTerm[@type='text']='Author'])&gt; 3">
								<xsl:text disable-output-escaping="no">, et. al.</xsl:text>
							</xsl:if>
						</xsl:when>
						<xsl:when test="//mods:mods/mods:name[1]/mods:role/mods:roleTerm[@type='text']!='Recording engineer'">
							<xsl:call-template name="displayName">
								<xsl:with-param name="name" select="//mods:mods/mods:name[1]/mods:namePart[not(@type = 'date')]"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="//mods:mods/mods:name[not(mods:role)]">
							<xsl:for-each select="//mods:mods/mods:name[position()&lt;= 3]">
								<xsl:call-template name="displayName">
									<xsl:with-param name="name" select="mods:namePart[not(@type = 'date')]"/>
								</xsl:call-template>
								<xsl:if test="position()!=last()">
									<xsl:text disable-output-escaping="no">, </xsl:text>
								</xsl:if>
							</xsl:for-each>
							<xsl:if test="count(//mods:mods/mods:name)&gt; 3">
								<xsl:text disable-output-escaping="no">, et. al.</xsl:text>
							</xsl:if>
							<!-- <xsl:call-template name="displayName">
								<xsl:with-param name="name" select="//mods:mods/mods:name[1]/mods:namePart[not(@type = 'date')]"/>
							</xsl:call-template>-->
						</xsl:when>
						<xsl:otherwise>
							<!-- afc stuff: suppress the recordist from the sheet title -->
							<xsl:call-template name="displayName">
								<xsl:with-param name="name" select="//mods:mods/mods:name[mods:role/mods:roleTerm[@type='text']='Singer' or mods:role/mods:roleTerm[@type='text']='Performer'][1]/mods:namePart[not(@type = 'date')]"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!--		<xsl:if test="$gmd!='' and not(//mods:identifier[@type='membership']='encyclopedia')">
			<xsl:text> [</xsl:text>
			<xsl:value-of select="$gmd"/>]</xsl:if>-->
	</xsl:template>
	<!-- not used; image is calculated in mets:illustrative -->
	<!-- <xsl:template name="image">
		<xsl:if test="ancestor::set/pages/page/image/@href or /set/pages/illustration or /set//pages/displayImage">
			<xsl:choose>				
				<xsl:when test="ancestor::set//pages/displayImage/page/image/@href ">
					<xsl:call-template name="makeImageLink">
						<xsl:with-param name="URL" select="(ancestor::set//pages/displayImage/page/image[1]/@href)[1]"/>
						<xsl:with-param name="alt">
							<xsl:value-of select="$title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				
				<xsl:when test="ancestor::set//pages/page/image/@href and $metsprofile!='bibRecord'">
					<xsl:call-template name="makeImageLink">
						<xsl:with-param name="URL" select="(ancestor::set//pages[1]/page[1]/image/@href)[1]"/>
						<xsl:with-param name="alt">
							<xsl:value-of select="$title"/>
						</xsl:with-param>
						<xsl:with-param name="section">
							<xsl:if test="ancestor::set//pages/version/@ID">
								<xsl:value-of select="(ancestor::set//pages[1]/version)[1]/@ID"/>
							</xsl:if>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$metsprofile='simpleAudio'">
					<xsl:call-template name="makeImageLink">
						<xsl:with-param name="URL" select="(ancestor::set//pages/illustration[1]/image/@href)[1]"/>
						<xsl:with-param name="alt">
							<xsl:value-of select="$title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="iconBehavior">
						<xsl:choose>
							<xsl:when test="$metsprofile='simplePhoto' or $metsprofile='photoObject' or ( $metsprofile='bibRecord' )">pageturner</xsl:when>
							<xsl:otherwise>pageturner</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<xsl:call-template name="behaviorLink">
						<xsl:with-param name="behavior">
							<xsl:value-of select="$iconBehavior"/>
						</xsl:with-param>
						
						<xsl:with-param name="content">
							<xsl:call-template name="makeImageLink">
								<xsl:with-param name="URL">
									<xsl:choose>
										<xsl:when test="$metsprofile='photoObject'">
											<xsl:value-of select="(ancestor::set//pages[1]/page[1]/image/@href)[1]"/>
										</xsl:when>
										<xsl:when test="ancestor::set//pages/illustration">
											<xsl:value-of select="(ancestor::set//pages/illustration[1]/image/@href)[1]"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="(ancestor::set//pages[1]/page[1]/image/@href)[1]"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="alt">
									<xsl:value-of select="$title"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template> -->
	<xsl:template name="verifylcc" as="item()*">
		<xsl:param name="class"/>
		<xsl:variable name="strip" select="replace($class, '(\s+|\.).+$', '') "/>
		<xsl:variable name="subclassCode" select="replace($strip, '\d', '')"/>
		<xsl:variable name="validLCC" select="('DAW','DJK','KBM','KBP','KBR','KBU','KDC','KDE','KDG','KDK','KDZ','KEA','KEB','KEM','KEN','KEO','KEP','KEQ','KES','KEY','KEZ','KFA','KFC','KFD','KFF','KFG','KFH','KFI','KFK','KFL','KFM','KFN','KFO','KFP','KFR','KFS','KFT','KFU','KFV','KFW','KFX','KFZ','KGA','KGB','KGC','KGD','KGE','KGF','KGG','KGH','KGJ','KGK','KGL','KGM','KGN','KGP','KGQ','KGR','KGS','KGT','KGU','KGV','KGW','KGX','KGY','KGZ','KHA','KHC','KHD','KHF','KHH','KHK','KHL','KHM','KHN','KHP','KHQ','KHS','KHU','KHW','KJA','KJC','KJE','KJG','KJH','KJJ','KJK','KJM','KJN','KJP','KJR','KJS','KJT','KJV','KJW','KKA','KKB','KKC','KKE','KKF','KKG','KKH','KKI','KKJ','KKK','KKL','KKM','KKN','KKP','KKQ','KKR','KKS','KKT','KKV','KKW','KKX','KKY','KKZ','KLA','KLB','KLD','KLE','KLF','KLH','KLM','KLN','KLP','KLQ','KLR','KLS','KLT','KLV','KLW','KMC','KME','KMF','KMG','KMH','KMJ','KMK','KML','KMM','KMN','KMP','KMQ','KMS','KMT','KMU','KMV','KMX','KMY','KNC','KNE','KNF','KNG','KNH','KNK','KNL','KNM','KNN','KNP','KNQ','KNR','KNS','KNT','KNU','KNV','KNW','KNX','KNY','KPA','KPC','KPE','KPF','KPG','KPH','KPJ','KPK','KPL','KPM','KPP','KPS','KPT','KPV','KPW','KQC','KQE','KQG','KQH','KQJ','KQK','KQM','KQP','KQT','KQV','KQW','KQX','KRB','KRC','KRE','KRG','KRK','KRL','KRM','KRN','KRP','KRR','KRS','KRU','KRV','KRW','KRX','KRY','KSA','KSC','KSE','KSG','KSH','KSK','KSL','KSN','KSP','KSR','KSS','KST','KSU','KSV','KSW','KSX','KSY','KSZ','KTA','KTC','KTD','KTE','KTF','KTG','KTH','KTJ','KTK','KTL','KTN','KTQ','KTR','KTT','KTU','KTV','KTW','KTX','KTY','KTZ','KUA','KUB','KUC','KUD','KUE','KUF','KUG','KUH','KUN','KUQ','KVB','KVC','KVE','KVH','KVL','KVM','KVN','KVP','KVQ','KVR','KVS','KVU','KVW','KWA','KWC','KWE','KWG','KWH','KWL','KWP','KWQ','KWR','KWT','KWW','KWX','KZA','KZD','AC','AE','AG','AI','AM','AN','AP','AS','AY','AZ','BC','BD','BF','BH','BJ','BL','BM','BP','BQ','BR','BS','BT','BV','BX','CB','CC',      'CD','CE','CJ','CN','CR','CS','CT','DA','DB','DC','DD','DE','DF','DG','DH','DJ','DK','DL','DP','DQ','DR','DS','DT','DU','DX','GA','GB','GC','GE',    'GF','GN','GR','GT','GV','HA','HB','HC','HD','HE','HF','HG','HJ','HM','HN','HQ','HS','HT','HV','HX','JA','JC','JF','JJ','JK','JL','JN','JQ','JS','JV','JX','JZ','KB','KD','KE','KF','KG','KH','KJ','KK','KL','KM','KN','KP','KQ','KR','KS','KT','KU','KV','KW','KZ','LA','LB','LC','LD','LE',  'LF','LG','LH','LJ','LT','ML','MT','NA','NB','NC','ND','NE','NK','NX','PA','PB','PC','PD','PE','PF','PG','PH','PJ','PK','PL','PM','PN','PQ','PR','PS','PT','PZ','QA','QB','QC','QD','QE','QH','QK','QL','QM','QP','QR','RA','RB','RC','RD','RE','RF','RG',   'RJ','RK','RL','RM','RS','RT','RV','RX','RZ','SB','SD','SF','SH','SK','TA','TC','TD','TE','TF','TG','TH','TJ','TK','TL','TN','TP','TR','TS','TT','TX','UA','UB','UC','UD','UE','UF','UG','UH','VA','VB','VC','VD','VE','VF','VG','VK','VM','ZA','A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','Z')"/>
		<xsl:if test="substring(substring-after($class, $subclassCode),1,1)!=' ' and $subclassCode = $validLCC">true</xsl:if>
	</xsl:template>
	<!--copied from displayLCDB-->
	<!-- idx:lcclass has what we need, if we've run idx updated (since 11/3/11)
	-->
	<xsl:template name="getLCC" as="item()*">
		<xsl:param name="objid"/>
	</xsl:template>
</xsl:stylesheet>
