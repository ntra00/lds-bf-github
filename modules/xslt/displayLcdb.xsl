<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xs metsutils idx mets locs hld index hold"
	extension-element-prefixes="xdmp" default-validation="strip"
	input-type-annotations="unspecified" xmlns:xdmp="http://marklogic.com/xdmp"
	xmlns:metsutils="info:lc/xq-modules/mets-utils"
	xmlns:locs="info:lc/xq-modules/config/lclocations" xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:idx="info:lc/xq-modules/lcindex"
	xmlns:hld="http://www.indexdata.com/turbomarc" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:index="info:lc/xq-modules/index-utils" xmlns:hold="info:lc/xq-modules/holdings-utils">
	<!-- xmlns:loc="info:lc/xq-modules/config/lclocations" -->
	<!--class=bibdata, bibdata-name, bibdata-subject, bibdata-subject are for hit-highlighting-->
	<!-- <xdmp:import-module namespace="info:lc/xq-modules/config/lclocations" href="/xq/modules/config/lclocations.xqy"/> -->
	<xdmp:import-module namespace="info:lc/xq-modules/mets-utils" href="/xq/modules/mets-utils.xqy"/>
	<xdmp:import-module namespace="info:lc/xq-modules/holdings-utils"
		href="/xq/modules/holdings-utils.xqy"/>
	<xdmp:import-module namespace="info:lc/xq-modules/index-utils"
		href="/xq/modules/index-utils.xqy"/>

	<xsl:include href="/xslt/MARC21slimUtils.xsl"/>
	<xsl:output indent="yes" encoding="UTF-8"/>
	<xsl:param name="hostname"/>

	<xsl:param name="lccn"/>
	<xsl:param name="mattype"/>
	<xsl:param name="behavior"/>
	<!--ajax (=nothing=default) or marctags -->
	<xsl:param name="ajaxparams"/>
	<xsl:param name="q"/>
	<xsl:param name="idxtitle"/>
	<xsl:param name="status"/>
	<xsl:param name="uri"/>
	<xsl:param name="url-prefix"/>
	<!-- morgan's marcedit program passes "yes" to marcedit to turn off holdings and right nav: -->
	<xsl:param name="marcedit">yes</xsl:param>
	<xsl:variable name="marcRecord">
		<xsl:apply-templates select="//marc:record" mode="root"/>
	</xsl:variable>

	<xsl:variable name="bibid" select="normalize-space(//marc:controlfield[@tag='001']) "/>
	<xsl:variable name="objid">
		<xsl:value-of select="$uri "/>
		<!--		<xsl:choose>
			<xsl:when test="$marcedit!='erms'">
				<xsl:value-of select="concat('loc.natlib.lcdb.', $bibid) "/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('loc.natlib.erms.', $bibid) "/>
			</xsl:otherwise>
		</xsl:choose>-->
	</xsl:variable>
	<!--	<xsl:variable name="baseURL">/nlc/search.xqy?collection=all&amp;count=10&amp;pg=1&amp;mime=text%2Fhtml&amp;sort=score-desc&amp;q=</xsl:variable>-->
	<xsl:variable name="baseURL"><xsl:value-of select="$url-prefix"
		/>search.xqy?count=10&amp;pg=1&amp;mime=text%2Fhtml&amp;sort=score-desc&amp;q=</xsl:variable>

	<xsl:variable name="bookmarkhref" select="concat('http://', $hostname, '/', $objid)"/>



	<xsl:template match="/">
		<div id="dsresults">
			<!-- begin container -->
			<!-- <abbr class="unapi-id" title="{normalize-space($objid)}">unapi link</abbr> -->

			<div id="ds-bibrecord">
				<!-- begin content -->
				<!-- display for one or more records retrieved ; was: <xsl:apply-templates select="descendant-or-self::marc:record"/> -->
				<abbr class="unapi-id" title="{normalize-space($objid)}"/>
				<span title="{normalize-space($objid)}" class="unapi-uri"/>
				<xsl:apply-templates select="$marcRecord" mode="processPage"/>

				<!-- end bibrecord:-->
				<span id="objectType" style="visibility: hidden;">bibRecord</span>
			</div>
			<xsl:if test="$marcedit!='yes'">
				<xsl:call-template name="rightnav"/>
			</xsl:if>
			<!--end dsresults: -->
		</div>
	</xsl:template>

	<xsl:template match="marc:record" mode="processPage">
		<xsl:variable name="fulltitle">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:value-of select="marc:datafield[@tag='245']/marc:subfield[@code='a']"
						disable-output-escaping="no"/>
					<xsl:if test="marc:datafield[@tag='245']/marc:subfield[@code='b'or @code='p']">
						<xsl:text disable-output-escaping="no"> </xsl:text>
						<xsl:value-of
							select="marc:datafield[@tag='245']/marc:subfield[@code='b' or @code='p']"
							disable-output-escaping="no"/>
					</xsl:if>
				</xsl:with-param>
				<!--<xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>-->
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="not(string-length($fulltitle) &gt; 200)">
					<xsl:value-of select="$fulltitle" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="findLastSpace">
						<xsl:with-param name="titleChop">
							<xsl:value-of select="substring($fulltitle, 1,200)"
								disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text disable-output-escaping="no">...</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- header title display -->
		<h1 id="title-top">
			<xsl:choose>
				<xsl:when test="string-length($title) &gt; 0">
					<xsl:value-of select="$title" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="string-length($idxtitle) &gt; 0">
					<xsl:value-of select="$idxtitle" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>[Unknown]</xsl:otherwise>
			</xsl:choose>
		</h1>
		<xsl:choose>
			<xsl:when test="$behavior!='marctags'">
				<xsl:call-template name="layout"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="taggedView"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="layout">
		<!-- <xsl:variable name="id">
			<xsl:value-of select="format-number(number($bibid),'0000000000')"/>
		</xsl:variable> -->
		<!-- <xsl:variable name="pngPath"><xsl:value-of select="concat('/thumbnails/',substring($objid,1,4), '_',substring($objid,5,2),'/th_',$objid,'.png')"/></xsl:variable>
		<xsl:variable name="imagePath"><xsl:value-of select="concat('/thumbnails/',substring($objid,1,4), '_',substring($objid,5,2),'/',$objid,'.jpg')"/></xsl:variable> -->

		<xsl:variable name="imagePath">
			<xsl:value-of select="concat('/media/',$objid,'/0001.tif/200')"
				disable-output-escaping="no"/>
		</xsl:variable>
		<!--<img src="{$imagePath}" alt="Book cover image"/>-->
		<img src="http://id.loc.gov{$imagePath}" alt="Book cover image"/>		
		<dl class="record">
			<xsl:if test="marc:datafield[@tag='010']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">LC control no.</xsl:with-param>
					<xsl:with-param name="tag">010</xsl:with-param>
					<xsl:with-param name="subfields">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<xsl:for-each select="marc:leader">
				<xsl:call-template name="matType"/>
			</xsl:for-each>

			<!-- 100 -->
			<xsl:if test="marc:datafield[@tag='100']">
				<xsl:call-template name="displayME">
					<xsl:with-param name="label">Personal name</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- 110  i-->
			<xsl:if test="marc:datafield[@tag='110']">
				<xsl:call-template name="displayME">
					<xsl:with-param name="label">Corporate name</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- 111  -->
			<xsl:if test="marc:datafield[@tag='111']">
				<xsl:call-template name="displayME">
					<xsl:with-param name="label">Meeting name</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- uniform title 130, 240, 243  -->
			<xsl:if test="marc:datafield[@tag='130' or @tag='240' or @tag='243']">
				<xsl:call-template name="displayUT"/>
			</xsl:if>

			<!-- main title 245 -->
			<xsl:if test="marc:datafield[@tag='245']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Main title</xsl:with-param>
					<xsl:with-param name="tag">245</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- 246 -->
			<xsl:if test="marc:datafield[@tag='246' and @ind2=' ']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Variant title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2=' ']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='0']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Portion of title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='0']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='1']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Parallel title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='1']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='2']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Distinctive title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='2']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='3']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Other title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='3']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='4']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Cover title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='4']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='5']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Added title page title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='5']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='6']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Caption title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='6']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='7']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Running title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='7']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='246' and @ind2='8']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Spine title</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='8']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- 242 -->
			<xsl:if test="marc:datafield[@tag='242']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Title translation</xsl:with-param>
					<xsl:with-param name="tag">242</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- 222 -->
			<xsl:if test="marc:datafield[@tag='222']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Serial key title</xsl:with-param>
					<xsl:with-param name="tag">222</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- 210 -->
			<xsl:if test="marc:datafield[@tag='210']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Abbreviated title</xsl:with-param>
					<xsl:with-param name="tag">210</xsl:with-param>
				</xsl:call-template>
			</xsl:if>


			<!-- Edition 250, 254 -->
			<xsl:if test="marc:datafield[@tag='250' or @tag='254']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Edition</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='250' or @tag='254']"/>
				</xsl:call-template>
			</xsl:if>


			<!-- Published/Created 260, 261, 262, 257, 270 -->
			<xsl:if
				test="marc:datafield[@tag='260' or @tag='261' or @tag='262' or @tag='257' or @tag='270']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Published/Created</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='260' or @tag='261' or @tag='262' or @tag='257' or @tag='270']"
					/>
				</xsl:call-template>
			</xsl:if>

			<!-- 263  -->
			<xsl:if test="marc:datafield[@tag='263']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Projected pub date</xsl:with-param>
					<xsl:with-param name="tag">263</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Related Names 700, 710, 711, 720 -->
			<xsl:if test="marc:datafield[@tag='700' or @tag='710' or @tag='711' or @tag='720']">
				<xsl:call-template name="relatedNames"/>
			</xsl:if>

			<!-- Related Titles 730, 740 -->
			<xsl:if test="marc:datafield[@tag='730' or @tag='740']">
				<xsl:call-template name="relatedTitles"/>
			</xsl:if>

			<!-- Description 300, 340, 362, 515 -->
			<xsl:if test="marc:datafield[@tag='300' or @tag='340' or @tag='362' or @tag='515']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Description</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='300' or @tag='340' or @tag='362' or @tag='515']"
					/>
				</xsl:call-template>
			</xsl:if>

			<!-- Organized/Arranged 351  -->
			<xsl:if test="marc:datafield[@tag='351']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Organized/Arranged</xsl:with-param>
					<xsl:with-param name="tag">351</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Current Frequency 310  -->
			<xsl:if test="marc:datafield[@tag='310']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Current frequency</xsl:with-param>
					<xsl:with-param name="tag">310</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Former Frequency 321  -->
			<xsl:if test="marc:datafield[@tag='321']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Former frequency</xsl:with-param>
					<xsl:with-param name="tag">321</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Former Title 247 -->
			<xsl:if test="marc:datafield[@tag='247']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Former title</xsl:with-param>
					<xsl:with-param name="tag">247</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Continues; Continues in part; Merger of; Absorbed; Absorbed in part, Separated from 780 -->
			<!-- Continued by; Continued in part by; Absorbed by; Absorbed in part by; Split into; Changed back to 785 -->
			<xsl:if test="marc:datafield[@tag='780' and (@ind2='0' or @ind2='2')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Continues</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='780' and (@ind2='0' or @ind2='2')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='780' and (@ind2='1' or @ind2='3')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Continues in part</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='780' and (@ind2='1' or @ind2='3')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[(@tag='780' and @ind2='4') or (@tag='785' and @ind2='7')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Merger of</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[(@tag='780' and @ind2='4') or (@tag='785' and @ind2='7')]"
					/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='780' and @ind2='5']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Absorbed</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='780' and @ind2='5']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='780' and @ind2='6']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Absorbed in part</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='780' and @ind2='6']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='785' and (@ind2='0' or @ind2='2')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Continued by</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='785' and (@ind2='0' or @ind2='2')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='785' and (@ind2='1' or @ind2='3')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Continued in part by</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='785' and (@ind2='1' or @ind2='3')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='785' and @ind2='4']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Absorbed by</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='785' and @ind2='4']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='785' and @ind2='5']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Absorbed in part by</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='785' and @ind2='5']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='785' and @ind2='6']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Split into</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='785' and @ind2='6']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='780' and @ind2='7']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Separated from</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='785' and @ind2='8']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='785' and @ind2='8']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Changed back to</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='780' and @ind2='7']"/>
				</xsl:call-template>
			</xsl:if>
			<!--???? 780/785 separated from-->

			<!-- Rights Advisory 540, 542 -->
			<xsl:if test="marc:datafield[@tag='540' or @tag='542']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Rights advisory</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='540' or @tag='542']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Access Advisory 307, 357, 506 -->
			<xsl:if test="marc:datafield[(@tag='357' or @tag='506') or (@tag='307' and @ind1='8')]">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Access advisory</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[(@tag='357' or @tag='506') or (@tag='307' and @ind1=8)]"
					/>
				</xsl:call-template>
			</xsl:if>

			<!-- Hours Available 307 -->
			<xsl:if test="marc:datafield[@tag='307' and @ind1=' ']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Hours available</xsl:with-param>
					<xsl:with-param name="tag">307</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Security Information 355 -->
			<xsl:if test="marc:datafield[@tag='355']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Security info</xsl:with-param>
					<xsl:with-param name="tag">355</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- ISSN, Incorrect ISSN, Cancelled ISSN 022, Linking ISSN, Cancelled Linking ISSN -->
			<xsl:if test="marc:datafield[@tag='022']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">ISSN</xsl:with-param>
					<xsl:with-param name="tag">022</xsl:with-param>
					<xsl:with-param name="subfields">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='022']/marc:subfield[@code='l']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Linking ISSN</xsl:with-param>
					<xsl:with-param name="tag">022</xsl:with-param>
					<xsl:with-param name="subfields">l</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='022']/marc:subfield[@code='y']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Incorrect ISSN</xsl:with-param>
					<xsl:with-param name="tag">022</xsl:with-param>
					<xsl:with-param name="subfields">y</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='022']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid ISSN</xsl:with-param>
					<xsl:with-param name="tag">022</xsl:with-param>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='022']/marc:subfield[@code='m']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid linking ISSN</xsl:with-param>
					<xsl:with-param name="tag">022</xsl:with-param>
					<xsl:with-param name="subfields">m</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- ISBN,  Cancelled ISBN 020 -->
			<xsl:if test="marc:datafield[@tag='020']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">ISBN</xsl:with-param>
					<xsl:with-param name="tag">020</xsl:with-param>
					<xsl:with-param name="subfields">ac</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='020']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid ISBN</xsl:with-param>
					<xsl:with-param name="tag">020</xsl:with-param>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Cancelled/Invalid LCCN 010z -->
			<xsl:if test="marc:datafield[@tag='010']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid LCCN</xsl:with-param>
					<xsl:with-param name="tag">010</xsl:with-param>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- ISRC, UPC/EAN, ISMN, SICI, Other Standard No. 024 -->
			<xsl:if test="marc:datafield[@tag='024' and @ind1='0']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">ISRC</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and @ind1='0']"/>
					<xsl:with-param name="subfields">acd2</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='024' and @ind1='0']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Invalid ISRC</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and @ind1='0']"/>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if
				test="marc:datafield[@tag='024' and (@ind1='1' or @ind1='3')]/marc:subfield[@code='a']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">UPC/EAN</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='024' and (@ind1='1' or @ind1='3')]"/>
					<xsl:with-param name="subfields">acd2</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if
				test="marc:datafield[@tag='024' and (@ind1='1' or @ind1='3')]/marc:subfield[@code='z']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Invalid UPC/EAN</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='024' and (@ind1='1' or @ind1='3')]"/>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='024' and @ind1='2']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">ISMN</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and @ind1='2']"/>
					<xsl:with-param name="subfields">acd2</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='024' and @ind1='2']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Invalid ISMN</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and @ind1='2']"/>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='024' and @ind1='4']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">SICI</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and @ind1='4']"/>
					<xsl:with-param name="subfields">acd2</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='024' and @ind1='4']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Invalid SICI</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and @ind1='4']"/>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if
				test="marc:datafield[@tag='024' and (@ind1='7' or @ind1='8')]/marc:subfield[@code='a']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Other standard no.</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='024' and (@ind1='7' or @ind1='8')]"/>
					<xsl:with-param name="subfields">acd2</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if
				test="marc:datafield[@tag='024' and (@ind1='7' or @ind1='8')]/marc:subfield[@code='z']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Invalid standard no.</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='024' and (@ind1='7' or @ind1='8')]"/>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Standard Technical Report No., Cancelled STRN 027 -->
			<xsl:if test="marc:datafield[@tag='027']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Standard tech rep no.</xsl:with-param>
					<xsl:with-param name="tag">027</xsl:with-param>
					<xsl:with-param name="subfields">ac</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='027']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid tech rep no.</xsl:with-param>
					<xsl:with-param name="tag">027</xsl:with-param>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Publisher No. 028 -->
			<xsl:if test="marc:datafield[@tag='028']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Publisher no.</xsl:with-param>
					<xsl:with-param name="tag">028</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- CODEN, Cancelled/Invalid CODEN 030 -->
			<xsl:if test="marc:datafield[@tag='030']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">CODEN</xsl:with-param>
					<xsl:with-param name="tag">030</xsl:with-param>
					<xsl:with-param name="subfields">ac</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='030']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid CODEN</xsl:with-param>
					<xsl:with-param name="tag">030</xsl:with-param>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Computer File Information 036, 256, 352, 516, 538, 753 -->
			<xsl:if
				test="marc:datafield[@tag='036' or @tag='256' or @tag='352' or @tag='516' or @tag='538' or @tag='753']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Computer file info</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='036' or @tag='256' or @tag='352' or @tag='516' or @tag='538' or @tag='753']"
					/>
				</xsl:call-template>
			</xsl:if>

			<!-- Geographic Coverage 522 -->
			<xsl:if test="marc:datafield[@tag='522']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Geographic coverage</xsl:with-param>
					<xsl:with-param name="tag">522</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Geospatial Information 342, 343 -->
			<xsl:if test="marc:datafield[@tag='342' or @tag='343']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Geospatial info</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='342' or @tag='343']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Scale Information 255, 507 -->
			<xsl:if test="marc:datafield[@tag='255' or @tag='507']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Scale</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='255' or @tag='507']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Taxonomic ID 754 -->
			<xsl:if test="marc:datafield[@tag='754']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Taxonomic ID</xsl:with-param>
					<xsl:with-param name="tag">754</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Bibliographic/Historical Data 545 -->
			<xsl:if test="marc:datafield[@tag='545']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Biography/History note</xsl:with-param>
					<xsl:with-param name="tag">545</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Summary, Review, Scope and Content, Abstract 520 -->
			<xsl:if test="marc:datafield[@tag='520' and (@ind1=' ' or @ind1='0' or @ind1='8')]">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Summary</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='520' and (@ind1=' ' or @ind1='0' or @ind1='8')]"
					/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='520' and @ind1='1']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Review</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='520' and @ind1='1']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='520' and @ind1='2']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Scope and content</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='520' and @ind1='2']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='520' and @ind1='3']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Abstract</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='520' and @ind1='3']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Contents, Incomplete Contents, Partial Contents 505 -->
			<xsl:if test="marc:datafield[@tag='505' and (@ind1=' ' or @ind1='0' or @ind1='8')]">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Contents</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='505' and (@ind1=' ' or @ind1='0' or @ind1='8')]"
					/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='505' and @ind1='1']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Incomplete contents</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='505' and @ind1='1']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='505' and @ind1='2']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Partial contents</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='505' and @ind1='2']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Notes 382 or 5xx (not 502, 505, 506, 507, 508, 510, 511, 515, 516, 520, 522, 524, 530, 533, 534, 538, 540, 541, 545, 555) -->
			<xsl:if test="marc:datafield[@tag='382']">
				<xsl:call-template name="notes"/>
			</xsl:if>
			<xsl:if
				test="marc:datafield[number(@tag) &gt; 499 and number(@tag) &lt; 600 and @tag !='502' and @tag !='505' and  @tag !='506' and @tag !='507' and @tag !='508' and @tag !='510' and @tag !='511'  and @tag !='515' and @tag !='516'  and @tag !='520' and @tag !='522' and @tag !='524'  and @tag !='530' and @tag !='533' and @tag !='534' and @tag !='538' and @tag !='540'  and @tag !='541' and @tag !='545' and @tag !='555']">
				<xsl:call-template name="notes"/>
			</xsl:if>

			<!-- Dissertation, 502 -->
			<xsl:if test="marc:datafield[@tag='502']">
				<xsl:call-template name="dissertation"/>
			</xsl:if>

			<!-- Indexed by, Indexed entirely by, Indexed selectively by, References 510 -->
			<xsl:if test="marc:datafield[@tag='510' and (@ind1=' ' or @ind1='0')]">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Indexed by</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='510' and (@ind1=' ' or @ind1='0')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='510' and @ind1='1']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Indexed entirely by</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='510' and @ind1='1']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='510' and @ind1='2']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Indexed selectively by</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='510' and @ind1='2']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='510' and (@ind1='3' or @ind1='4')]">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">References</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='510' and (@ind1='3' or @ind1='4')]"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Indexes, Finding Aids 555 -->
			<xsl:if test="marc:datafield[@tag='555' and @ind1=' ']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Indexes</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='555' and @ind1=' ']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='555' and (@ind1='0' or @ind1='8')]">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Finding aids</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='555' and (@ind1='0' or @ind1='8')]"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Cite as 524 -->
			<xsl:if test="marc:datafield[@tag='524']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Cite as</xsl:with-param>
					<xsl:with-param name="tag">524</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Cast, Presenter, Narrator 511 -->
			<xsl:if test="marc:datafield[@tag='511' and (@ind1=' ' or @ind1='0')]">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Performer</xsl:with-param>
					<xsl:with-param name="tag"
						select="marc:datafield[@tag='511' and (@ind1=' ' or @ind1='0')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='511' and @ind1='1']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Cast</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='511' and (@ind1='1')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='511' and @ind1='2']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Presenter</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='511' and @ind1='2']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='511' and @ind1='3']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Narrator</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='511' and @ind1='3']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Credits 508 -->
			<xsl:if test="marc:datafield[@tag='508']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Credits</xsl:with-param>
					<xsl:with-param name="tag">508</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Acquisition source 265, 541 -->
			<xsl:if test="marc:datafield[@tag='265' or @tag='541']">
				<xsl:call-template name="displayAllGroup3">
					<xsl:with-param name="label">Acquisition source</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='265' or @tag='541']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Translation of 765 -->
			<xsl:if test="marc:datafield[@tag='765']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Translation of</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='765']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Translated as 767 -->
			<xsl:if test="marc:datafield[@tag='767']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Translated as</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='767']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Has Supplement 770 -->
			<xsl:if test="marc:datafield[@tag='770']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Has supplement</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='770']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Supplement to 772 -->
			<xsl:if test="marc:datafield[@tag='772']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Supplement to</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='772']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Collection 773 -->
			<xsl:if test="marc:datafield[@tag='773']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Collection</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='773']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Constituent Unit 774 -->
			<xsl:if test="marc:datafield[@tag='774']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Constituent unit</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='774']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Other Edition Available 775 -->
			<xsl:if test="marc:datafield[@tag='775']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Other edition</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='775']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Additional Formats 530, 533, 534, 776 -->
			<xsl:if test="marc:datafield[@tag='530' or @tag='533' or @tag='534' or @tag='776']">
				<xsl:call-template name="additionalFormats"/>
			</xsl:if>

			<!-- Issued With 777 -->
			<xsl:if test="marc:datafield[@tag='777']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Issued with</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='777']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Data Source 786 -->
			<xsl:if test="marc:datafield[@tag='786']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Data source</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='786']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Related Item 787 -->
			<xsl:if test="marc:datafield[@tag='787']">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Related item</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='787']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Subjects, 600-752 -->
			<xsl:if
				test="marc:datafield[@tag='600' or @tag='610' or @tag='611' or @tag='630' or @tag='648' or @tag='650' or @tag='651' or @tag='654' or @tag='656' or @tag='657' or @tag='658' or @tag='662' or @tag='690' or @tag='691' or @tag='692' or @tag='693' or @tag='694' or @tag='695' or @tag='696' or @tag='697' or @tag='698' or @tag='699' or @tag='751' or @tag='752']">
				<xsl:call-template name="subject"/>
			</xsl:if>

			<!-- Subject Keywords 653 -->
			<xsl:if test="marc:datafield[@tag='653']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Subject keywords</xsl:with-param>
					<xsl:with-param name="tag">653</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Form/Genre 655 -->
			<xsl:if test="marc:datafield[@tag='655']">
				<xsl:call-template name="formGenre"/>
			</xsl:if>

			<!-- Series 4XX, 800-830 -->
			<xsl:if
				test="marc:datafield[@tag='400' or @tag='410' or @tag='411' or @tag='440' or @tag='490' or @tag='760' or @tag='762' or @tag='800' or @tag='810' or @tag='811' or @tag='830' or @tag='840']">
				<xsl:call-template name="series"/>
			</xsl:if>

			<!-- LC Classification 050 -->
			<xsl:if test="marc:datafield[@tag='050']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">LC classification</xsl:with-param>
					<xsl:with-param name="tag">050</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- LC Copy 051 -->
			<xsl:if test="marc:datafield[@tag='051']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">LC copy</xsl:with-param>
					<xsl:with-param name="tag">051</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Geographic class no. 052 -->
			<xsl:if test="marc:datafield[@tag='052']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Geographic class no.</xsl:with-param>
					<xsl:with-param name="tag">052</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Canadian class no. 055 -->
			<xsl:if test="marc:datafield[@tag='055']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Canadian class no.</xsl:with-param>
					<xsl:with-param name="tag">055</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- NLM class no. 060 -->
			<xsl:if test="marc:datafield[@tag='060']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">NLM class no.</xsl:with-param>
					<xsl:with-param name="tag">060</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- NLM Copy Statement 061 -->
			<xsl:if test="marc:datafield[@tag='061']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">NLM copy info</xsl:with-param>
					<xsl:with-param name="tag">061</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- NAL class no. 070 -->
			<xsl:if test="marc:datafield[@tag='070']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">NAL class no.</xsl:with-param>
					<xsl:with-param name="tag">070</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- NAL Copy Statement 071 -->
			<xsl:if test="marc:datafield[@tag='071']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">NAL copy info</xsl:with-param>
					<xsl:with-param name="tag">071</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Dewey class no. 082, 083 -->
			<xsl:if test="marc:datafield[@tag='082' or @tag='083']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Dewey class no.</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='082' or @tag='083']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Other class no. 084, 085 -->
			<xsl:if test="marc:datafield[@tag='084' or @tag='085']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Other class no.</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='084' or @tag='085']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Government Document No. 086 -->
			<xsl:if test="marc:datafield[@tag='086']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Government doc no.</xsl:with-param>
					<xsl:with-param name="tag">086</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Local Shelving No. 090 -->
			<xsl:if test="marc:datafield[@tag='090']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Local shelving no.</xsl:with-param>
					<xsl:with-param name="tag">090</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Language Code 041 -->
			<xsl:if test="marc:datafield[@tag='041']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Language code</xsl:with-param>
					<xsl:with-param name="tag">041</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Country of Publication 044 -->
			<xsl:if test="marc:datafield[@tag='044']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Country of publication</xsl:with-param>
					<xsl:with-param name="tag">044</xsl:with-param>
				</xsl:call-template>
			</xsl:if>


			<!-- Postal Registration No. 032 -->
			<xsl:if test="marc:datafield[@tag='032']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Postal reg no.</xsl:with-param>
					<xsl:with-param name="tag">032</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Overseas Acquisition No. 025 -->
			<xsl:if test="marc:datafield[@tag='025']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Overseas acq no.</xsl:with-param>
					<xsl:with-param name="tag">025</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Patent Control No. 013 -->
			<xsl:if test="marc:datafield[@tag='013']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Patent Control No.</xsl:with-param>
					<xsl:with-param name="tag">013</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Copyright Registration No. 017 -->
			<xsl:if test="marc:datafield[@tag='017']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Copyright reg no.</xsl:with-param>
					<xsl:with-param name="tag">017</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Copyright Article Fee 018 -->
			<xsl:if test="marc:datafield[@tag='018']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Copyright article fee</xsl:with-param>
					<xsl:with-param name="tag">018</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- National Bibliography No. 015 -->
			<xsl:if test="marc:datafield[@tag='015']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">National bib no.</xsl:with-param>
					<xsl:with-param name="tag">015</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- National Bibliographic Agency No. 016 -->
			<xsl:if test="marc:datafield[@tag='016']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">National bib agency no.</xsl:with-param>
					<xsl:with-param name="tag">016</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Other System No. 035 -->
			<xsl:if test="marc:datafield[@tag='035']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Other system no.</xsl:with-param>
					<xsl:with-param name="tag">035</xsl:with-param>
					<xsl:with-param name="subfields">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='035']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid System No.</xsl:with-param>
					<xsl:with-param name="tag">035</xsl:with-param>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Reproduction/Stock No. 037 -->
			<xsl:if test="marc:datafield[@tag='037']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Reproduction no./Source</xsl:with-param>
					<xsl:with-param name="tag">037</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Geographic Area Code 043 -->
			<xsl:if test="marc:datafield[@tag='043']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Geographic area code</xsl:with-param>
					<xsl:with-param name="tag">043</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- GPO Item No., Cancelled/Invalid GPO Item No. 074 -->
			<xsl:if test="marc:datafield[@tag='074']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">GPO item no.</xsl:with-param>
					<xsl:with-param name="tag">074</xsl:with-param>
					<xsl:with-param name="subfields">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='074']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid GPO item no.</xsl:with-param>
					<xsl:with-param name="tag">074</xsl:with-param>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Report No., Cancelled/Invalid Report No. 088 -->
			<xsl:if test="marc:datafield[@tag='088']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Report no.</xsl:with-param>
					<xsl:with-param name="tag">088</xsl:with-param>
					<xsl:with-param name="subfields">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='088']/marc:subfield[@code='z']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Invalid report no.</xsl:with-param>
					<xsl:with-param name="tag">088</xsl:with-param>
					<xsl:with-param name="subfields">z</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Repository 852 -->
			<xsl:if test="marc:datafield[@tag='852']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Repository</xsl:with-param>
					<xsl:with-param name="tag">852</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Quality Code 042 -->
			<!-- suppressed 5/18/11 -->
			<!-- <xsl:if test="marc:datafield[@tag='042']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Quality code</xsl:with-param>
					<xsl:with-param name="tag">042</xsl:with-param>
					<xsl:with-param name="subfields">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if> -->

			<!-- Electronic File Information 856, 859 or Links -->
			<xsl:if test="marc:datafield[@tag='856' or @tag='859']">
				<xsl:call-template name="link85X"/>
			</xsl:if>

			<!-- Quality Code 336 -->
			<xsl:if test="marc:datafield[@tag='336']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Content type</xsl:with-param>
					<xsl:with-param name="tag">336</xsl:with-param>
					<xsl:with-param name="subfields">a3</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Quality Code 337 -->
			<xsl:if test="marc:datafield[@tag='337']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Media type</xsl:with-param>
					<xsl:with-param name="tag">337</xsl:with-param>
					<xsl:with-param name="subfields">a3</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<!-- Quality Code 338 -->
			<xsl:if test="marc:datafield[@tag='338']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Carrier type</xsl:with-param>
					<xsl:with-param name="tag">338</xsl:with-param>
					<xsl:with-param name="subfields">a3</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

			<br/>
			<xsl:if test="$marcedit!='yes'">
				<xsl:variable name="hold" select="hold:display($objid, $status)"/>
				<xsl:choose>
					<xsl:when test="$hold">
						<xsl:copy-of select="$hold"/>
					</xsl:when>
					<xsl:otherwise>
						<dt class="label"> </dt>
						<dd class="bibdata">
							<span class="noholdings">Library of Congress Holdings Information Not
								Available.</span>
						</dd>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!--<xsl:call-template name="getHoldings">
				<xsl:with-param name="bibid" select="$bibid"/>
				</xsl:call-template>-->

			<!--<xsl:if test="$marcedit!='yes'">
				<xsl:variable name="hold" select="hold:display($objid, $status)"/>
				<div class="holdings" id="holdings">
					<xsl:copy-of select="$hold/*" copy-namespaces="yes"/>
				</div>
				</xsl:if>-->
			<!--	<div class="holdings" id="holdings">
				<xsl:copy-of select="$hold/*" copy-namespaces="yes"/>
			</div>-->

		</dl>
	</xsl:template>

	<!-- ... -->
	<!-- Generic Templates -->
	<!-- Single tag; includes sfc u processing and special sfc 3 processing for 541 field-->
	<xsl:template match="marc:subfield" as="item()*">
		<xsl:choose>
			<xsl:when test="@code='3' and (../@tag!='541')">
				<xsl:value-of select="." disable-output-escaping="no"/>:</xsl:when>
			<xsl:when
				test="@code='u' and ( ../@tag='856') and starts-with(../marc:subfield[@code='z'],'Search for images in Prints')">
				<xsl:text disable-output-escaping="no"> </xsl:text>
				<xsl:variable name="link">
					<xsl:choose>
						<xsl:when test="normalize-space($lccn)!=''">
							<xsl:value-of
								select="concat('http://www.loc.gov/pictures/item/',normalize-space($lccn),'/')"
								disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>http://www.loc.gov/pictures</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<a href="{$link}" target="_new">
					<xsl:value-of select="$link" disable-output-escaping="no"/>
				</a>
				<xsl:text disable-output-escaping="no"> </xsl:text>
			</xsl:when>
			<xsl:when
				test="@code='u' and (../@tag='505' or  ../@tag='506' or  ../@tag='510' or  ../@tag='514' or  ../@tag='520' or  ../@tag='530'  or ../@tag='538'  or ../@tag='540'  or ../@tag='542'  or ../@tag='545'  or ../@tag='552'  or ../@tag='555' or ../@tag='563'  or ../@tag='583' or ../@tag='852' or ../@tag='856' or ../@tag='859')">
				<!-- 031u not displayed in LCDB -->
				<xsl:text disable-output-escaping="no"> </xsl:text>
				<a href="{.}" target="_new">
					<xsl:value-of select="." disable-output-escaping="no"/>
				</a>
				<xsl:text disable-output-escaping="no"> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." disable-output-escaping="no"/>
				<xsl:if test="count(following-sibling::*[1])!=0">
					<xsl:text disable-output-escaping="no"> </xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Single tag,; no special indicator processing;  covers sfc 0, 3, 6-->
	<xsl:template name="displayAll" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>
		<xsl:param name="subfields"/>

		<xsl:variable name="titles" select="('245','246','247','242','210','222')"/>
		<xsl:variable name="css-class">
			<xsl:choose>
				<xsl:when test="$tag=$titles">bibdata-title</xsl:when>
				<xsl:otherwise>bibdata</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<dt class="label">
			<xsl:value-of select="$label" disable-output-escaping="no"/>
		</dt>
		<dd class="{$css-class}">
			<xsl:choose>
				<!-- with the upgrade from 4.2.2 to 4.2.7, I had to change empty to ='' -->
				<!-- <xsl:when test="empty($subfields)"> -->
				<xsl:when test="$subfields=''">
					<xsl:for-each select="marc:datafield[@tag=$tag]">
						<xsl:apply-templates select="*[@code='3']"/>
						<!-- adds dir=rtl span tag for Hebrew and Arabic -->
						<xsl:choose>
							<xsl:when
								test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
								<xsl:for-each select="*[@code!='6' and @code!='3' and @code!='0']">
									<xsl:choose>
										<xsl:when test="matches(.,'[A-Za-z]') ">
											<!--english text -->
											<xsl:apply-templates select="child::node()"/>
										</xsl:when>
										<xsl:otherwise>
											<span dir="rtl">
												<xsl:apply-templates select="child::node()"/>
											</span>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates
									select="*[@code!='6' and @code!='3' and @code!='0']"/>
							</xsl:otherwise>
						</xsl:choose>
						<br/>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$subfields!=''">
					<xsl:if
						test="marc:datafield[@tag=$tag]/marc:subfield[contains($subfields,@code)]">
						<!-- test to make sure record contains at least on repeatable field with specified sfc -->
						<xsl:for-each select="marc:datafield[@tag=$tag]">
							<!-- test to prevent extra br when some repeated fields lacks specified sfc -->
							<xsl:if test="marc:subfield[contains($subfields,@code)]">
								<xsl:apply-templates select="*[@code='3']"/>
								<!-- adds dir=rtl span tag for Hebrew and Arabic -->
								<xsl:choose>
									<xsl:when
										test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
										<xsl:for-each
											select="*[(@code!='6' and @code!='3' and @code!='0') and contains($subfields,@code)]">
											<xsl:choose>
												<xsl:when test="matches(.,'[A-Za-z]') ">
												<!--english text -->
												<xsl:apply-templates select="child::node()"/>
												</xsl:when>
												<xsl:otherwise>
												<span dir="rtl">
												<xsl:apply-templates select="child::node()"/>
												</span>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates
											select="*[(@code!='6' and @code!='3' and @code!='0') and contains($subfields,@code)]"
										/>
									</xsl:otherwise>
								</xsl:choose>
								<br/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</dd>
	</xsl:template>

	<!-- Defined group of tags,; no special indicator processing; covers sfc 0, 3, 6-->
	<xsl:template name="displayAllGroup" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>
		<xsl:variable name="pub-create-label" select="'Published/Created'"/>
		<xsl:variable name="new-pub-create-label" select="'Published_Created'"/>

		<dt class="label">
			<xsl:value-of select="$label" disable-output-escaping="no"/>
		</dt>
		<!--<dd class="{ if ($label eq $pub-create-label) then $new-pub-create-label else $label }">-->
		<dd class="bibdata">
			<xsl:for-each select="$tag">
				<xsl:apply-templates select="*[@code='3']"/>
				<xsl:choose>
					<!-- adds dir=rtl span tag for Hebrew and Arabic -->
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
						<xsl:for-each select="*[@code!='6' and @code!='3' and @code!='0']">
							<xsl:choose>
								<xsl:when test="matches(.,'[A-Za-z]') ">
									<!--english text -->
									<xsl:apply-templates select="child::node()"/>
								</xsl:when>
								<xsl:otherwise>
									<span dir="rtl">
										<xsl:apply-templates select="child::node()"/>
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Defined group of tags,; no special indicator processing; covers sfc 0, 3, 6; sfc 3 not moved to beginning of field -->
	<xsl:template name="displayAllGroup3" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>

		<dt class="label">
			<xsl:value-of select="$label" disable-output-escaping="no"/>
		</dt>
		<dd class="bibdata">
			<xsl:for-each select="$tag">
				<xsl:choose>
					<!-- adds dir=rtl span tag for Hebrew and Arabic -->
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
						<xsl:for-each select="*[@code!='6' and @code!='0']">
							<xsl:choose>
								<xsl:when test="matches(.,'[A-Za-z]') ">
									<!--english text -->
									<xsl:apply-templates select="child::node()"/>
								</xsl:when>
								<xsl:otherwise>
									<span dir="rtl">
										<xsl:apply-templates select="child::node()"/>
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Defined group of tags,; indicator-specific labels ; used for 024, 246, 505, 510, 511, 520, 555; covers sfc 0, 3, 6 -->
	<xsl:template name="displayAllInd" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>
		<xsl:param name="subfields"/>

		<dt class="label">
			<xsl:value-of select="$label" disable-output-escaping="no"/>
		</dt>
		<dd class="bibdata">
			<xsl:choose>
				<!-- <xsl:when test="not(exists($subfields))"> -->
				<xsl:when test="$subfields=''">
					<xsl:for-each select="$tag">
						<!-- tag is the whole element! -->
						<xsl:apply-templates select="*[@code='3']"/>
						<xsl:apply-templates select="*[@code='i']"/>
						<xsl:choose>
							<!-- adds dir=rtl span tag for Hebrew and Arabic, with exception for 246 sfc i -->
							<xsl:when
								test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
								<xsl:for-each
									select="*[@code!='6' and @code!='3' and @code!='0' and @code!='i']">
									<xsl:choose>
										<xsl:when test="matches(.,'[A-Za-z]') ">
											<!--english text -->
											<xsl:apply-templates select="child::node()"/>
										</xsl:when>
										<xsl:otherwise>
											<span dir="rtl">
												<xsl:apply-templates select="child::node()"/>
											</span>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates
									select="*[@code!='6' and @code!='3' and @code!='0' and @code!='i']"
								/>
							</xsl:otherwise>
						</xsl:choose>
						<br/>
					</xsl:for-each>
				</xsl:when>

				<xsl:otherwise>
					<xsl:if test="$tag/marc:subfield[contains($subfields,@code)]">
						<!-- test to make sure record contains at least on repeatable field with specified sfc -->
						<xsl:for-each select="$tag">
							<!-- test to prevent extra br when some repeated fields lacks specified sfc -->
							<xsl:if test="marc:subfield[contains($subfields,@code)]">
								<xsl:apply-templates select="*[@code='3']"/>
								<xsl:apply-templates select="*[@code='i']"/>
								<xsl:choose>
									<!-- adds dir=rtl span tag for Hebrew and Arabic -->
									<xsl:when
										test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
										<!--<span dir="rtl">
													<xsl:apply-templates select="*[(@code!='6' and @code!='3' and @code!='0' and @code!='i') and contains($subfields,@code)]"/>
													</span>-->
										<xsl:for-each
											select="*[(@code!='6' and @code!='3' and @code!='0' and @code!='i') and contains($subfields,@code)]">
											<xsl:choose>
												<xsl:when test="matches(.,'[A-Za-z]') ">
												<!--english text -->
												<xsl:apply-templates select="child::node()"/>
												</xsl:when>
												<xsl:otherwise>
												<span dir="rtl">
												<xsl:apply-templates select="child::node()"/>
												</span>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates
											select="*[(@code!='6' and @code!='3' and @code!='0' and @code!='i') and contains($subfields,@code)]"
										/>
									</xsl:otherwise>
								</xsl:choose>
								<br/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</dd>
	</xsl:template>

	<!-- Material Type Template (uses Leader, 006, 007;  note: 336-337-338 not yet included); calls separate Material Type xsl display table-->
	<xsl:template name="matType" as="item()*">
		<!--mattype now comes from xquery as param-->
		<dt class="label">Type of material</dt>
		<dd class="bibdata">
			<xsl:choose>
				<xsl:when test="string-length($mattype) gt 0">
					<xsl:value-of select="$mattype" disable-output-escaping="no"/>
				</xsl:when>
				<!-- this was already calculated in the calling program and passed as a param	-->
				<!-- <xsl:when test="string-length($tmpidxmat) gt 0">
			                       <xsl:value-of select="$tmpidxmat"/>
			               </xsl:when> -->
				<xsl:otherwise>
					<br/>
				</xsl:otherwise>
			</xsl:choose>
		</dd>
	</xsl:template>


	<!-- Special Group Templates and Global Variables for "More like this" linking to Voyager-->
	<!-- No Title linking for 243, 246, 247, 740; Title linking using Voyager TALL index; TALL includes sfc h  -->
	<!-- No Voyager Subject headings available for 648, 662, 752 -->
	<!-- No Voyager Name or Name-Title Heading support for X00 sfc g -->
	<xsl:variable name="createUrlSearchString">
		<createUrlSearchString name="encodedSubfieldSelect">
			<tag fields="100;400;700;800;" codes="a;b;c;d;k;q;"/>
			<tag fields="110;410;710;810;" codes="a;b;c;d;g;k;n;"/>
			<tag fields="111;411;711;811;" codes="a;b;c;d;e;g;n;q;"/>
			<tag fields="130;730;" codes="a;d;f;g;h;k;l;m;n;o;p;r;s;t;" indicators="ind1;"/>
			<tag fields="240;" codes="a;d;f;g;h;k;l;m;n;o;p;r;s;" indicators="ind2;"/>
			<tag fields="440;" codes="a;n;p;" indicators="ind2"/>
			<tag fields="600;" codes="a;b;c;d;f;g;k;l;m;n;o;p;q;r;s;t;v;x;y;z;"/>
			<tag fields="610;" codes="a;b;c;d;f;g;k;l;m;n;o;p;r;s;t;v;x;y;z;"/>
			<tag fields="611;" codes="a;b;c;d;e;f;g;k;l;n;p;q;s;t;v;x;y;z;"/>
			<tag fields="630;" codes="a;d;f;g;k;l;m;n;o;p;r;s;v;x;y;z;" indicators="ind1;"/>
			<tag fields="650;651;" codes="a;b;v;x;y;z;"/>
			<tag fields="655;" codes="a;b;v;x;y;z;"/>
			<tag fields="760;762;765;767;770;772;773;774;775;776;777;780;785;786;787;" codes="t;"/>
			<tag fields="830;" codes="a;d;f;g;h;k;l;m;n;o;p;r;s;t;" indicators="ind2;"/>
		</createUrlSearchString>
	</xsl:variable>

	<xsl:variable name="createDisplayString">
		<createDisplayString>
			<link fields="100;110;111;" name="displayME"
			/>http://catalog.loc.gov/vwebv/search&amp;searchArg1={$link}&amp;searchCode1=NAME_&amp;CNT=25
				<link fields="130;240;" name="displayUT"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1=TALL+"{$link}?"&amp;searchCode1=CMD&amp;CNT=25
				<link fields="400;410;411;" name="series"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1={$link}&amp;searchCode1=NAME_&amp;CNT=25
				<link fields="440;" name="series"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1=TALL+"{$link}?"&amp;searchCode1=CMD&amp;CNT=25
				<link fields="600;610;611;630;650;651;" name="subject"
			/>http://catalog.loc.gov/vwebv/search?&amp;SA={$link}&amp;SC=SUBJ&amp;CNT=25
				<link fields="655;" name="formGenre"
			/>http://catalog.loc.gov/vwebv/search?&amp;SA={$link}&amp;SC=SUBJ&amp;CNT=25
				<link fields="700;710;711;" name="relatedNames"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1={$link}&amp;searchCode1=NAME_&amp;CNT=25
				<link fields="730;" name="relatedTitles"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1=TALL+"{$link}?"&amp;searchCode1=CMD&amp;CNT=25
				<link fields="760;762;" name="series"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1=TALL+"{$link}?"&amp;searchCode1=CMD&amp;CNT=25
				<link fields="776;" name="additionalFormats"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1=TALL+"{$link}?"&amp;searchCode1=CMD&amp;CNT=25
				<link fields="800;810;811;" name="series"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1={$link}&amp;searchCode1=NAME_&amp;CNT=25
				<link fields="830;" name="series"
			/>http://catalog.loc.gov/vwebv/search?&amp;searchArg1=TALL+"{$link}?"&amp;searchCode1=CM&amp;CNT=25</createDisplayString>
		<!--<createDisplayString>
			<link fields="100;110;111;" name="displayME"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg={$link}&amp;Search_Code=NAME_&amp;CNT=25
			<link fields="130;240;" name="displayUT"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25
			<link fields="400;410;411;" name="series"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg={$link}&amp;Search_Code=NAME_&amp;CNT=25
			<link fields="440;" name="series"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25
			<link fields="600;610;611;630;650;651;" name="subject"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;SA={$link}&amp;SC=SUBJ&amp;CNT=25
			<link fields="655;" name="formGenre"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;SA={$link}&amp;SC=SUBJ&amp;CNT=25
			<link fields="700;710;711;" name="relatedNames"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg={$link}&amp;Search_Code=NAME_&amp;CNT=25
			<link fields="730;" name="relatedTitles"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25
			<link fields="760;762;" name="series"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25
			<link fields="776;" name="additionalFormats"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25
			<link fields="800;810;811;" name="series"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg={$link}&amp;Search_Code=NAME_&amp;CNT=25
			<link fields="830;" name="series"
			/>http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CM&amp;CNT=25</createDisplayString>-->
	</xsl:variable>
	<!--http://catalog.loc.gov/vwebv/search?searchArg1=59012697&searchCode1=lccn&searchType=2-->
	<xsl:template name="encodedSubfieldSelect" as="item()*">
		<xsl:param name="delimiter">
			<xsl:text disable-output-escaping="no"> </xsl:text>
		</xsl:param>
		<xsl:variable name="tag" select="concat(@tag, ';')"/>
		<xsl:variable name="ind1" select="normalize-space(@ind1)"/>
		<xsl:variable name="ind2" select="normalize-space(@ind2)"/>
		<xsl:variable name="codes"
			select="$createUrlSearchString//*[not(parent::*)]/*[contains(@fields, $tag)]/@codes"/>
		<xsl:variable name="indicators"
			select="$createUrlSearchString//*[not(parent::*)]/*[contains(@fields, $tag)]/@indicators"/>

		<xsl:variable name="codeStr">
			<xsl:for-each select="marc:subfield">
				<xsl:variable name="cd" select="concat(@code, ';')"/>
				<xsl:if test="contains($codes, $cd)">
					<!-- <xsl:if test="contains('655;',$tag)">|<xsl:value-of select="$cd"/>|</xsl:if> -->
					<xsl:value-of select="text()" disable-output-escaping="no"/>
					<xsl:value-of select="$delimiter" disable-output-escaping="no"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<!-- process non-filing indicators -->
		<xsl:variable name="codeStr2">
			<xsl:choose>
				<xsl:when test="string-length($indicators)!=0">
					<xsl:for-each select="tokenize($indicators, ';')">
						<xsl:if test=".='ind1'">
							<xsl:value-of select="substring($codeStr, number($ind1)+1)"
								disable-output-escaping="no"/>
						</xsl:if>
						<xsl:if test=".='ind2'">
							<xsl:value-of select="substring($codeStr, number($ind2)+1)"
								disable-output-escaping="no"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$codeStr" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- converts link text to escaped URL hex values for Voyager search strings -->


		<!-- removes ending delimiter, chop punc, and adds quotes for exact searching -->
		<xsl:variable name="codeStr3">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString"
					select="substring($codeStr2,1,string-length($codeStr2) - string-length($delimiter))"
				/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="count(tokenize($codeStr3, '\W+')[. != '']) &gt;1">
				<xsl:text disable-output-escaping="no">"</xsl:text>
				<xsl:value-of select="encode-for-uri($codeStr3)" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="encode-for-uri($codeStr3)" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Main Entry Template for 100, 110, 111; covers sfc 0, 6 (no sfc 3)   -->
	<xsl:template name="displayME" as="item()*">
		<xsl:param name="label"/>

		<dt class="label">
			<xsl:value-of select="$label" disable-output-escaping="no"/>
		</dt>
		<dd class="bibdata-name">
			<xsl:for-each select="marc:datafield[@tag='100' or @tag='110' or @tag='111']">
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect"/>
				</xsl:variable>
				<xsl:variable name="display">
					<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
				</xsl:variable>

				<!-- adds dir=rtl span tag for Hebrew and Arabic, with extra test to prevent span tags on names beginning with Romanized data in sfc a -->
				<xsl:choose>
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
						<a href="{concat($baseURL,$search,'&amp;qname=idx:byName')}"
							rel="nofollow">
							<xsl:choose>
								<xsl:when test="matches($display,'[A-Za-z]') ">
									<!--english text -->
									<xsl:value-of select="$display" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:otherwise>
									<span dir="rtl">
										<xsl:value-of select="$display" disable-output-escaping="no"
										/>
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<a href="{concat($baseURL, $search, '&amp;qname=idx:byName')}"
							rel="nofollow">
							<xsl:value-of select="$display" disable-output-escaping="no"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Uniform Title Template for 130, 240, 243; covers sfc 0, 6 (240: no sfc 3; 243: no sfc 0, 3)   -->
	<xsl:template name="displayUT" as="item()*">
		<xsl:param name="label"/>
		<dt class="label">Uniform title</dt>
		<dd class="bibdata-title">
			<xsl:for-each select="marc:datafield[@tag='130' or @tag='240']">
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect"/>
				</xsl:variable>
				<xsl:variable name="display">
					<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
				</xsl:variable>
				<xsl:choose>
					<!-- adds dir=rtl span tag for Hebrew and Arabic -->
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
						<a href="{concat($baseURL,$search, '&amp;qname=idx:uniformTitle')}"
							rel="nofollow">
							<xsl:choose>
								<xsl:when test="matches($search,'[A-Za-z]') ">
									<!--english text -->
									<xsl:value-of select="$display" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:otherwise>
									<span dir="rtl">
										<xsl:value-of select="$display" disable-output-escaping="no"
										/>
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<a href="{concat($baseURL,$search,'&amp;qname=idx:uniformTitle')}"
							rel="nofollow">
							<xsl:value-of select="$display" disable-output-escaping="no"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag='243']">
				<xsl:choose>
					<!-- adds dir=rtl span tag for Hebrew and Arabic -->
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
						<xsl:for-each select="*[@code!='6' ]">
							<xsl:choose>
								<xsl:when test="matches(.,'[A-Za-z]') ">
									<!--english text -->
									<xsl:apply-templates select="*[@code!='6']"/>
								</xsl:when>
								<xsl:otherwise>
									<span dir="rtl">
										<xsl:apply-templates select="*[@code!='6']"/>
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6']"/>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Series Template for 4XX, 760, 762, 800-830, 840; covers sfc 0, 3, 6  (490: no sfc 0; 840 : no sfc 0, 3; 760/752: no sfc 3) -->
	<xsl:template name="series" as="item()*">
		<dt class="label">Series</dt>
		<dd class="bibdata">
			<xsl:for-each
				select="marc:datafield[@tag='400' or @tag='410' or @tag='411' or @tag='440']">
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect"/>
				</xsl:variable>
				<xsl:variable name="display">
					<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
				</xsl:variable>

				<xsl:apply-templates select="*[@code='3']"/>
				<!-- adds dir=rtl span tag for Hebrew and Arabic; as obsolete fields, there should be no 880s for 400-411 -->
				<!-- 				change to idx:seriesTitle after next reindex 20110328 -->
				<a href="{concat($baseURL,$search,'&amp;qname=idx:title')}" rel="nofollow">
					<xsl:choose>
						<xsl:when
							test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
							<xsl:choose>
								<xsl:when test="matches($display,'[A-Za-z]') ">
									<!--english text -->
									<xsl:value-of select="$display" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:otherwise>
									<span dir="rtl">
										<xsl:value-of select="$display" disable-output-escaping="no"
										/>
									</span>
								</xsl:otherwise>
							</xsl:choose>
							<span dir="rtl">
								<xsl:value-of select="$display" disable-output-escaping="no"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$display" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
				<br/>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag='490']">
				<xsl:apply-templates select="*[@code='3']"/>
				<!-- adds dir=rtl span tag for Hebrew and Arabic; as obsolete fields -->
				<xsl:choose>
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
						<xsl:for-each select="*[@code!='6' and @code!='3']">
							<xsl:choose>
								<xsl:when test="matches(.,'[A-Za-z]') ">
									<!--english text -->
									<xsl:apply-templates select="*[@code!='6' and @code!='3']"/>
								</xsl:when>
								<xsl:otherwise>
									<span dir="rtl">
										<xsl:apply-templates select="*[@code!='6' and @code!='3']"/>
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6' and @code!='3']"/>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>

			<xsl:for-each
				select="marc:datafield[@tag='800' or @tag='810' or @tag='811' or @tag='830']">
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect"/>
				</xsl:variable>
				<xsl:variable name="display">
					<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
				</xsl:variable>

				<xsl:apply-templates select="*[@code='3']"/>
				<a href="{concat($baseURL,$search)}" rel="nofollow">
					<!-- adds dir=rtl span tag for Hebrew and Arabic, with extra test to prevent span tags on names beginning with Romanized data in sfc a  (only relevant for 810 and 811) -->
					<xsl:choose>
						<xsl:when
							test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
							<span dir="rtl">
								<xsl:value-of select="$display" disable-output-escaping="no"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$display" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
				<br/>
			</xsl:for-each>

			<!-- as obsolete field, there should be no 880s for 840 -->
			<xsl:for-each select="marc:datafield[@tag='840']">
				<xsl:apply-templates select="*[@code!='6']"/>
				<br/>
			</xsl:for-each>

			<!-- no 880s for 76X-78X -->
			<xsl:for-each select="marc:datafield[@tag='760' or @tag='762']">
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect"/>
				</xsl:variable>
				<a href="{concat($baseURL,$search)}" rel="nofollow">
					<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
				</a>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Additional Formats Template for 530, 533, 534, 776;  covers sfc 3, 6 (53X: no sfc 0; 776: no sfc 3)   -->
	<xsl:template name="additionalFormats" as="item()*">
		<dt class="label">Additional formats</dt>
		<dd class="bibdata">
			<xsl:for-each select="marc:datafield[@tag='530' or @tag='533' or @tag='534']">
				<xsl:apply-templates select="*[@code='3']"/>
				<xsl:choose>
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
						<span dir="rtl">
							<xsl:apply-templates select="*[@code!='6' and @code!='3']"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6' and @code!='3']"/>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>

			<!-- no 880s for 76X-78X -->
			<xsl:for-each select="marc:datafield[@tag='776']">
				<xsl:choose>
					<xsl:when test="*[@code='t']">
						<xsl:variable name="search">
							<xsl:call-template name="encodedSubfieldSelect"/>
						</xsl:variable>

						<!-- no 880 text for 76X-78X -->
						<a href="{concat($baseURL,$search)}" rel="nofollow">
							<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
						</a>
						<br/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
						<br/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Notes Template for 5XX (with exceptions), 382 ;  covers sfc 3, 6 (no sfc 0) -->
	<xsl:template name="notes" as="item()*">

		<dt class="label">Notes</dt>
		<dd class="bibdata">
			<xsl:for-each
				select="marc:datafield[number(@tag) &gt; 499 and number(@tag) &lt; 600 and (@tag !='502' and @tag !='505' and @tag !='506' and @tag !='507' and @tag !='508' and @tag !='510' and @tag !='511' and @tag !='515' and @tag !='516' and @tag !='520' and @tag !='522' and @tag !='524' and @tag !='530' and @tag !='533' and @tag !='534' and @tag !='538' and @tag !='540' and @tag !='541' and @tag !='545' and @tag !='555')] | marc:datafield[@tag='382']">
				<xsl:apply-templates select="*[@code='3']"/>
				<xsl:choose>
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
						<span dir="rtl">
							<xsl:apply-templates select="*[@code!='6' and @code!='3']"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6' and @code!='3']"/>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Subjects Template for 600-651, 648, 654, 656-659, 690-699, 751, 752; covers sfc 0, 3, 6 by explicit subfield list in encodedSubfieldSelect   -->
	<xsl:template name="subject" as="item()*">

		<dt class="label">Subjects</dt>
		<dd class="bibdata-subject">
			<xsl:for-each
				select="marc:datafield[@tag='600' or @tag='610' or @tag='611' or @tag='630' or @tag='650' or @tag='651']">
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect">
						<xsl:with-param name="delimiter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="searchfield">
					<xsl:choose>
						<!-- lcsh -->
						<xsl:when test="@ind2='0'">&amp;qname=idx:subjectLexicon</xsl:when>
						<xsl:otherwise>&amp;qname=idx:topic</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- <a href="{concat($baseURL,$search,'&amp;qname=idx:subjectLexicon')}" rel="nofollow"> -->
				<!-- changed from subjectLexicon (only lcsh) to topic, which all subjects go into, for searching -->
				<a href="{concat($baseURL,$search,$searchfield)}" rel="nofollow">
					<xsl:apply-templates select="*[@code='3']"/>
					<xsl:for-each
						select="*[@code!='2' and @code!='3' and @code!='0' and @code!='6' ]">
						<xsl:value-of select="." disable-output-escaping="no"/>
						<xsl:if test="position()!=last()">--</xsl:if>
					</xsl:for-each>
				</a>
				<br/>
			</xsl:for-each>

			<xsl:for-each
				select="marc:datafield[@tag='648' or @tag='654' or @tag='656' or @tag='657' or @tag='658' or @tag='662' or @tag='690' or @tag='691' or @tag='692' or @tag='693' or @tag='694' or @tag='695' or @tag='696' or @tag='697' or @tag='698' or @tag='699' or @tag='751' or @tag='752']">
				<xsl:apply-templates select="*[@code='3']"/>
				<xsl:call-template name="subjectSubfieldSelect"/>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Form/Genre Template for 655; covers sfc 0, 3, 6 by explicit subfield list in encodedSubfieldSelect  -->
	<xsl:template name="formGenre" as="item()*">

		<dt class="label">Form/Genre</dt>
		<dd class="bibdata">
			<xsl:for-each select="marc:datafield[@tag='655']">
				<!--mods: genre gets 655 : a;b;v;x;y;z;-->
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect"/>
				</xsl:variable>
				<xsl:variable name="searchfield">
					<xsl:choose>
						<!-- lcsh -->
						<xsl:when test="@ind2='0'">&amp;qname=idx:subjectLexicon</xsl:when>
						<xsl:otherwise>&amp;qname=idx:topic</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- changed from subjectLexicon (only lcsh) to topic, which all subjects go into, for searching -->
				<a href="{concat($baseURL, $search, $searchfield)}" rel="nofollow">
					<xsl:apply-templates select="marc:subfield[@code='3']"/>
					<xsl:apply-templates select="marc:subfield[contains('abvxyz',@code)]"/>
				</a>
				<br/>
			</xsl:for-each>
			<!--	</td>
		</tr>-->
		</dd>
	</xsl:template>

	<!-- Subfield dashes for Subjects, Form/Genre, 502. 662, 752 fields  -->
	<xsl:template name="subjectSubfieldSelect" as="item()*">
		<xsl:param name="codes">abcdefghijklmnopqrstuvwxyz24</xsl:param>
		<!-- not displaying sfc5, sfc6; sfc3 already displayed -->
		<!-- adds dashes between appropriate subfields -->
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($codes, @code)">
					<xsl:if test="not(position()=1)">
						<xsl:choose>
							<xsl:when
								test="../@tag!='502' and ../@tag!='662' and ../@tag!='752' and contains('vxyz',@code)"
								>--</xsl:when>
							<xsl:when
								test="(../@tag='502' and contains('bcdgo',@code)) or (../@tag='662' and contains('bcdefgh',@code)) or (../@tag='752' and contains('bcdfgh',@code))"
								>--</xsl:when>
							<xsl:otherwise>
								<xsl:text disable-output-escaping="no"> </xsl:text>
							</xsl:otherwise>
							<!-- &#160; results in a leading non-breaking space if sfc 6 is first sfc -->
						</xsl:choose>
					</xsl:if>
					<xsl:value-of select="text()" disable-output-escaping="no"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<!-- adds dir=rtl span tag for Hebrew and Arabic, with extra test to prevent span tags on names beginning with Romanized data in sfc a -->

		<xsl:choose>
			<xsl:when
				test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
				<span dir="rtl">
					<xsl:value-of select="substring($str,1,string-length($str))"
						disable-output-escaping="no"/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring($str,1,string-length($str))"
					disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="dissertation" as="item()*">
		<dt class="label">Dissertation note</dt>
		<dd class="bibdata">
			<xsl:for-each select="marc:datafield[@tag='502']">
				<xsl:apply-templates select="*[@code='3']"/>
				<xsl:call-template name="subjectSubfieldSelect"/>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Related Names Template for 700, 710, 711, 720;  covers sfc 0, 3, 6  -->
	<xsl:template name="relatedNames" as="item()*">

		<dt class="label">Related names</dt>
		<dd class="bibdata-name">
			<xsl:for-each select="marc:datafield[@tag='700' or @tag='710' or @tag='711']">
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect"/>
				</xsl:variable>

				<a href="{concat($baseURL, $search,'&amp;qname=idx:byName')}" rel="nofollow">

					<xsl:apply-templates select="*[@code='3']"/>
					<!-- adds dir=rtl span tag for Hebrew and Arabic, with extra test to prevent span tags on names beginning with Romanized data in sfc a (relevant for 710 and 711) -->
					<xsl:choose>
						<xsl:when
							test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')  ">
							<span dir="rtl">
								<xsl:apply-templates
									select="*[@code!='6' and @code!='3' and @code!='0' and @code!='4' ]"
								/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates
								select="*[@code!='6' and @code!='3' and @code!='0' and @code!='4'  ]"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
				<br/>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag='720']">
				<!-- adds dir=rtl span tag for Hebrew and Arabic; as uncontrolled name should not have Roman data in 880 sfc a -->
				<xsl:choose>
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
						<span dir="rtl">
							<xsl:apply-templates select="*[@code!='6']"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6']"/>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- Related TitlesTemplate for 730, 740; covers sfc 0, 3, 6 (740: no sfc 0, 3) -->
	<xsl:template name="relatedTitles" as="item()*">

		<dt class="label">Related titles</dt>
		<dd class="bibdata-title">
			<xsl:for-each select="marc:datafield[@tag='730']">
				<xsl:variable name="search">
					<xsl:call-template name="encodedSubfieldSelect"/>
				</xsl:variable>

				<a href="{concat($baseURL,$search,'&amp;qname=idx:uniformTitle')}"
					rel="nofollow">
					<!-- adds dir=rtl span tag for Hebrew and Arabic -->
					<xsl:choose>
						<xsl:when
							test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
							<span dir="rtl">
								<xsl:apply-templates
									select="*[@code!='6' and @code!='3' and @code!='0']"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates
								select="*[@code!='6' and @code!='3' and @code!='0']"/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
				<br/>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag='740']">
				<!-- adds dir=rtl span tag for Hebrew and Arabic -->
				<xsl:choose>
					<xsl:when
						test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
						<span dir="rtl">
							<xsl:apply-templates select="*[@code!='6']"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code!='6']"/>
					</xsl:otherwise>
				</xsl:choose>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- 76X-78X Linking Template (760, 762, 776 handled elsewhere); covers sfc 0, 3, 6; no 880s for 76X-78X -->
	<xsl:template name="display78X" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>

		<dt class="label">
			<xsl:value-of select="$label" disable-output-escaping="no"/>
		</dt>
		<dd class="bibdata">
			<xsl:for-each select="$tag">
				<xsl:choose>
					<xsl:when test="*[@code='t']">
						<xsl:variable name="search">
							<xsl:call-template name="encodedSubfieldSelect"/>
						</xsl:variable>
						<a href="{concat($baseURL,$search,'&amp;qname=idx:title')}"
							rel="nofollow">
							<xsl:apply-templates select="*[@code='3']"/>
							<xsl:apply-templates
								select="*[@code!='6' and @code!='3' and @code!='0' and @code!='w']"
							/>
						</a>
						<br/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[@code='3']"/>
						<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
						<br/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</dd>
	</xsl:template>

	<!-- 856-859 Linking Template (note: 859 links for serials activated because of Voyager SRU issues with holdings 856 fields ; no 880 text  for 856/859; covers sfc 3 (no sfc 0, 6) -->
	<xsl:template name="link85X" as="item()*">
		<dt class="label">Links</dt>
		<dd class="bibdata">
			<xsl:for-each select="marc:datafield[@tag='856']">
				<xsl:apply-templates select="*[@code='3' or @code='u']"/>
				<xsl:if test="*[@code='y' or @code='z']">
					<xsl:text disable-output-escaping="no"> </xsl:text>
					<xsl:apply-templates select="*[@code='y' or @code='z']"/>
				</xsl:if>
				<br/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='859']/marc:subfield[@code='u']">
				<xsl:value-of select="." disable-output-escaping="no"/>
				<br/>
			</xsl:for-each>
		</dd>
	</xsl:template>



	<!-- Chop Template for Title header  -->
	<xsl:template name="findLastSpace" as="item()*">
		<xsl:param name="titleChop"/>
		<xsl:choose>
			<xsl:when test="substring($titleChop,string-length($titleChop))!=' '">
				<xsl:call-template name="findLastSpace">
					<xsl:with-param name="titleChop"
						select="substring($titleChop, 1,string-length($titleChop)-1)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$titleChop" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 880 templates: Michael Ferrando 8/23/10  -->
	<xsl:template match="marc:record" mode="root" as="item()*">
		<xsl:element name="{name()}" namespace="{namespace-uri()}" inherit-namespaces="yes">
			<xsl:apply-templates select="*" mode="subfields"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="marc:leader | marc:controlfield" mode="subfields" as="item()*">
		<xsl:apply-templates select="self::*" mode="global_copy"/>
	</xsl:template>

	<xsl:template match="marc:datafield" mode="subfields" as="item()*">
		<xsl:choose>
			<xsl:when test="child::marc:subfield[@code='6']">
				<xsl:choose>
					<xsl:when test="@tag='880'">
						<xsl:apply-templates select="self::*" mode="global_copy"/>
						<xsl:comment>RETRANSFORMED 880 FIELD</xsl:comment>
						<xsl:text disable-output-escaping="no"> </xsl:text>
						<xsl:apply-templates select="self::*" mode="vernacular"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{name()}" namespace="{namespace-uri()}"
							inherit-namespaces="yes">
							<xsl:apply-templates select="@*" mode="global_copy"/>
							<xsl:apply-templates select="*" mode="global_copy"/>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{name()}" namespace="{namespace-uri()}" inherit-namespaces="yes">
					<xsl:apply-templates select="@*" mode="global_copy"/>
					<xsl:apply-templates select="*" mode="global_copy"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="marc:datafield" mode="vernacular" as="item()*">
		<xsl:variable name="sf06" select="normalize-space(marc:subfield[@code='6'])"/>
		<xsl:variable name="sf06a" select="substring($sf06, 1, 3)"/>
		<xsl:variable name="sf06b" select="substring($sf06, 4)"/>
		<xsl:element name="{name()}" namespace="{namespace-uri()}" inherit-namespaces="yes">
			<xsl:apply-templates select="@*" mode="global_copy"/>
			<xsl:attribute name="tag">
				<xsl:value-of select="$sf06a" disable-output-escaping="no"/>
			</xsl:attribute>
			<xsl:apply-templates select="*[not(@code='6')]" mode="global_copy"/>
			<xsl:element name="subfield" namespace="{namespace-uri()}" inherit-namespaces="yes">
				<xsl:attribute name="code">6</xsl:attribute>
				<xsl:value-of select="concat('880', $sf06b)" disable-output-escaping="no"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- 880 global copy templates -->
	<xsl:template match="* |  @* | text() | comment() | processing-instruction()" mode="global_copy"
		as="item()*">
		<xsl:copy inherit-namespaces="yes" copy-namespaces="yes">
			<xsl:apply-templates select="* | @* | text() | comment() | processing-instruction()"
				mode="global_copy"/>
		</xsl:copy>
	</xsl:template>
	<!-- 
	<xsl:template match="* | @* | text() | comment() | processing-instruction()" mode="global_copy">
		<xsl:copy>
			<xsl:apply-templates select="* | @* | text() | comment() | processing-instruction()" mode="global_copy"/>
		</xsl:copy>
	</xsl:template> -->


	<!--from http://www.loc.gov/standards/marcxml/xslt/MARC21slim2HTML.xsl-->
	<xsl:template name="taggedView" as="item()*">
		<div id="marc-view">
			<div class="field">
				<div class="tag_ind">
					<span class="tag">000</span>
					<span class="control_field_values">
						<xsl:value-of select="marc:leader" disable-output-escaping="no"/>
					</span>
				</div>
			</div>
			<xsl:apply-templates select="marc:datafield |marc:controlfield " mode="taggedView"/>
		</div>
	</xsl:template>

	<xsl:template match="marc:controlfield" mode="taggedView" as="item()*">
		<div class="field">
			<div class="tag_ind">
				<span class="tag">
					<xsl:value-of select="@tag" disable-output-escaping="no"/>
				</span>
				<span class="control_field_values">
					<xsl:value-of select="." disable-output-escaping="no"/>
				</span>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="marc:datafield" mode="taggedView" as="item()*">
		<div class="field">
			<div class="tag_ind">
				<span class="tag">
					<xsl:value-of select="@tag" disable-output-escaping="no"/>
				</span>
				<div class="ind1">
					<xsl:value-of select="@ind1" disable-output-escaping="no"/>
				</div>
				<div class="ind2">
					<xsl:value-of select="@ind2" disable-output-escaping="no"/>
				</div>
			</div>
			<div class="subfields">
				<xsl:apply-templates select="marc:subfield" mode="taggedView"/>
			</div>
		</div>
	</xsl:template>

	<!-- <xsl:template match="hld:r">
		<xsl:apply-templates select="hld:d852"/>
	</xsl:template> -->
	<!-- <xsl:template match="hld:d852">
		<div class="hr">
			<hr/>
		</div>

		<xsl:variable name="callno" select="string-join(*[local-name()!='s3'][local-name()!='sb'][local-name()!='st'][local-name()!='sx'][local-name()!='sz'],' ')"/>
		<xsl:variable name="callno-text">
			<xsl:choose>
				<xsl:when test="hld:sh and normalize-space($callno)!=''">
					<xsl:value-of select="$callno"/>
				</xsl:when>
				<xsl:otherwise>Not Available</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<dt class="label">Call Number</dt>
		<dd class="bibdata">
			<xsl:value-of select="$callno-text"/>

			<xsl:for-each select="hld:st| hld:sz|hld:s3">
				<br/>
				<xsl:value-of select="."/>
			</xsl:for-each>			
		</dd>

		<xsl:if test="not(ancestor-or-self::hld:r/hld:d856)">			
			<xsl:for-each select="hld:sb">
				<xsl:variable name="this-location" select="normalize-space(.)"/>

				<dt class="label">Request in</dt>
				<dd class="bibdata">
					<xsl:choose>
						<xsl:when test="../hld:sh='Electronic Resource'">Online</xsl:when>
						<xsl:when test="$locs//locs:location[locs:code=$this-location]/locs:display">
							<xsl:value-of select="$locs//locs:location[locs:code=$this-location]/locs:display"/>
						</xsl:when>
						<xsl:otherwise>
							<span class="noholdings">
								<xsl:value-of select="$this-location"/>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</dd>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="ancestor-or-self::hld:r/hld:d866">
			<dt class="label">Contains</dt>
			<xsl:apply-templates select="ancestor-or-self::hld:r/hld:d866"/>
		</xsl:if>
		<xsl:if test="ancestor-or-self::hld:r/hld:d867">
			<dt class="label">Supplements</dt>
			<xsl:apply-templates select="ancestor-or-self::hld:r/hld:d867"/>
		</xsl:if>
		<xsl:apply-templates select="ancestor-or-self::hld:r/hld:d868"/>
		<xsl:apply-templates select="ancestor-or-self::hld:r/hld:d856"/>
		<xsl:apply-templates select="ancestor-or-self::hld:r/*[starts-with(local-name(),'d')][local-name()!='d035'][local-name()!='d852'][local-name()!='d856'][local-name()!='d866'][local-name()!='d867'][local-name()!='d868'][local-name()!='d986']"/>
	</xsl:template>
	<xsl:template match="hld:*[starts-with(local-name(),'d')][local-name()!='d014'][local-name()!='d035'][local-name()!='d852'][local-name()!='d856'][local-name()!='d866'][local-name()!='d867'][local-name()!='d868'][local-name()!='d986']">
		<dt class="label">Other</dt>
		<dd style="color:red">
			<xsl:value-of select="string-join(hld:*,' ')"/>
		</dd>
	</xsl:template> -->
	<!-- <xsl:template match="hld:d014">		
		<xsl:if test="normalize-space(hld:sa)!=normalize-space($bibid) and position()!=1">
			<dt class="label">Bound with</dt>
			<dd style="color:red">
				<a href="{concat('http://',$hostname,'/loc.natlib.lcdb.',hld:sa,'.html')}">
					<xsl:value-of select="hld:sa"/>
				</a>
			</dd>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hld:d866 | hld:d867">		
		<dd>
			<xsl:value-of select="hld:sz"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="hld:sa"/>
		</dd>
	</xsl:template>
	<xsl:template match="hld:d868">
		<dt class="label">Older Receipts</dt>
		<dd>
			<xsl:value-of select="hld:sa"/>
		</dd>
	</xsl:template> -->
	<!-- <xsl:template match="hld:d856">
		<dt class="label">Links</dt>
		<dd class="bibdata">

			<a href="{hld:su[1]}" target="_new">
				<xsl:choose>
					<xsl:when test="hld:s3">
						<xsl:value-of select="hld:s3"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="hld:su[1]"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<br/>
			<xsl:value-of select="hld:sz"/>
		</dd>
	</xsl:template> -->
	<xsl:template match="marc:subfield" mode="taggedView" as="item()*">
		<span class="sub_code">
			<xsl:text disable-output-escaping="no"> </xsl:text>
			<xsl:value-of select="@code" disable-output-escaping="no"/>|</span>
		<xsl:value-of select="." disable-output-escaping="no"/>
		<xsl:text disable-output-escaping="no"> </xsl:text>
	</xsl:template>
	<xsl:template match="marc:subfield" mode="t505" as="item()*">
		<!--fancy version, not used:-->
		<xsl:choose>
			<xsl:when test="@code='t'">
				<br/>• <xsl:value-of select="." disable-output-escaping="no"/></xsl:when>
			<xsl:when test="@code='a' and contains(text(),'--')">
				<xsl:variable name="chapters" select="tokenize(.,'--')"/>
				<xsl:for-each select="$chapters">• --<xsl:value-of select="."
						disable-output-escaping="no"/><br/></xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="verifylcc" as="item()*">
		<xsl:param name="class"/>
		<xsl:variable name="strip" select="replace($class, '(\s+|\.).+$', '') "/>
		<xsl:variable name="subclassCode" select="replace($strip, '\d', '')"/>
		<xsl:variable name="validLCC"
			select="('DAW','DJK','KBM','KBP','KBR','KBU','KDC','KDE','KDG','KDK','KDZ','KEA','KEB','KEM','KEN','KEO','KEP','KEQ','KES','KEY','KEZ','KFA','KFC','KFD','KFF','KFG','KFH','KFI','KFK','KFL','KFM','KFN','KFO','KFP','KFR','KFS','KFT','KFU','KFV','KFW','KFX','KFZ','KGA','KGB','KGC','KGD','KGE','KGF','KGG','KGH','KGJ','KGK','KGL','KGM','KGN','KGP','KGQ','KGR','KGS','KGT','KGU','KGV','KGW','KGX','KGY','KGZ','KHA','KHC','KHD','KHF','KHH','KHK','KHL','KHM','KHN','KHP','KHQ','KHS','KHU','KHW','KJA','KJC','KJE','KJG','KJH','KJJ','KJK','KJM','KJN','KJP','KJR','KJS','KJT','KJV','KJW','KKA','KKB','KKC','KKE','KKF','KKG','KKH','KKI','KKJ','KKK','KKL','KKM','KKN','KKP','KKQ','KKR','KKS','KKT','KKV','KKW','KKX','KKY','KKZ','KLA','KLB','KLD','KLE','KLF','KLH','KLM','KLN','KLP','KLQ','KLR','KLS','KLT','KLV','KLW','KMC','KME','KMF','KMG','KMH','KMJ','KMK','KML','KMM','KMN','KMP','KMQ','KMS','KMT','KMU','KMV','KMX','KMY','KNC','KNE','KNF','KNG','KNH','KNK','KNL','KNM','KNN','KNP','KNQ','KNR','KNS','KNT','KNU','KNV','KNW','KNX','KNY','KPA','KPC','KPE','KPF','KPG','KPH','KPJ','KPK','KPL','KPM','KPP','KPS','KPT','KPV','KPW','KQC','KQE','KQG','KQH','KQJ','KQK','KQM','KQP','KQT','KQV','KQW','KQX','KRB','KRC','KRE','KRG','KRK','KRL','KRM','KRN','KRP','KRR','KRS','KRU','KRV','KRW','KRX','KRY','KSA','KSC','KSE','KSG','KSH','KSK','KSL','KSN','KSP','KSR','KSS','KST','KSU','KSV','KSW','KSX','KSY','KSZ','KTA','KTC','KTD','KTE','KTF','KTG','KTH','KTJ','KTK','KTL','KTN','KTQ','KTR','KTT','KTU','KTV','KTW','KTX','KTY','KTZ','KUA','KUB','KUC','KUD','KUE','KUF','KUG','KUH','KUN','KUQ','KVB','KVC','KVE','KVH','KVL','KVM','KVN','KVP','KVQ','KVR','KVS','KVU','KVW','KWA','KWC','KWE','KWG','KWH','KWL','KWP','KWQ','KWR','KWT','KWW','KWX','KZA','KZD','AC','AE','AG','AI','AM','AN','AP','AS','AY','AZ','BC','BD','BF','BH','BJ','BL','BM','BP','BQ','BR','BS','BT','BV','BX','CB','CC',      'CD','CE','CJ','CN','CR','CS','CT','DA','DB','DC','DD','DE','DF','DG','DH','DJ','DK','DL','DP','DQ','DR','DS','DT','DU','DX','GA','GB','GC','GE',    'GF','GN','GR','GT','GV','HA','HB','HC','HD','HE','HF','HG','HJ','HM','HN','HQ','HS','HT','HV','HX','JA','JC','JF','JJ','JK','JL','JN','JQ','JS','JV','JX','JZ','KB','KD','KE','KF','KG','KH','KJ','KK','KL','KM','KN','KP','KQ','KR','KS','KT','KU','KV','KW','KZ','LA','LB','LC','LD','LE',  'LF','LG','LH','LJ','LT','ML','MT','NA','NB','NC','ND','NE','NK','NX','PA','PB','PC','PD','PE','PF','PG','PH','PJ','PK','PL','PM','PN','PQ','PR','PS','PT','PZ','QA','QB','QC','QD','QE','QH','QK','QL','QM','QP','QR','RA','RB','RC','RD','RE','RF','RG',   'RJ','RK','RL','RM','RS','RT','RV','RX','RZ','SB','SD','SF','SH','SK','TA','TC','TD','TE','TF','TG','TH','TJ','TK','TL','TN','TP','TR','TS','TT','TX','UA','UB','UC','UD','UE','UF','UG','UH','VA','VB','VC','VD','VE','VF','VG','VK','VM','ZA','A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','Z')"/>
		<xsl:if
			test="substring(substring-after($class, $subclassCode),1,1)!=' ' and $subclassCode = $validLCC"
			>true</xsl:if>
	</xsl:template>
	<xsl:template name="rightnav" as="item()*">

		<xsl:variable name="browseclass">
			<xsl:choose>
				<xsl:when test="$marcedit!='yes'">
					<!--not erms, not yes-->
					<xsl:for-each
						select="$marcRecord//marc:datafield[@tag='050']/marc:subfield[@code='a']">
						<xsl:call-template name="getLCC">
							<xsl:with-param name="objid" select="$objid"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getLCC">
						<xsl:with-param name="objid" select="$objid"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div id="ds-bibviews">
			<xsl:variable name="toplist">
				<xsl:choose>
					<xsl:when
						test="$marcRecord//marc:datafield[starts-with(@tag,'6')][not(@tag='653')]"
						>subjects</xsl:when>
					<xsl:when test="$marcRecord//marc:datafield[starts-with(@tag,'1')]"
						>names</xsl:when>
					<!-- <xsl:when test="$marcRecord//marc:datafield[@tag='050']">class</xsl:when> -->
					<xsl:when test="$browseclass//li">class</xsl:when>
					<xsl:when test="normalize-space($lccn)=''">save</xsl:when>
					<xsl:otherwise>holdings</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$marcRecord//marc:datafield[starts-with(@tag,'6')][not(@tag='653')]">
				<!-- class="top" -->
				<h2>
					<xsl:if test="$toplist='subjects'">
						<xsl:attribute name="class">top</xsl:attribute>
					</xsl:if>Browse Subject Headings</h2>
				<ul>
					<xsl:for-each
						select="$marcRecord//marc:datafield[starts-with(@tag,'6')][not(@tag='653')]">
						<xsl:variable name="subj">
							<xsl:value-of
								select="string-join(*[@code!='6' and @code!='3' and @code!='0' and @code!='2'],'--')"
								disable-output-escaping="no"/>
						</xsl:variable>
						<xsl:variable name="link"
							select="concat($url-prefix,'browse.xqy?bq=',encode-for-uri($subj),'&amp;',$ajaxparams,'&amp;browse-order=ascending&amp;browse=subject')"/>
						<xsl:variable name="idlink"
							select="concat('http://id.loc.gov/nlc/browse.xqy?bq=',encode-for-uri($subj),'&amp;',$ajaxparams,'&amp;browse-order=ascending&amp;browse=subject')"/>
						<!-- http://id.loc.gov/search/?q=dogs&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2Fsubjects -->
						<li>
							<a href="{$link}" rel="nofollow">
								<xsl:value-of select="$subj" disable-output-escaping="no"/>
							</a>
							<!-- (<a href="{$idlink}">auth</a>) -->
						</li>
					</xsl:for-each>
				</ul>
			</xsl:if>
			<xsl:if
				test="$marcRecord//marc:datafield[starts-with(@tag,'10') or  starts-with(@tag,'11')]">

				<h2>
					<xsl:if test="$toplist='names'">
						<xsl:attribute name="class">top</xsl:attribute>
					</xsl:if>Browse Name Headings</h2>
				<ul>
					<xsl:for-each select="$marcRecord//marc:datafield[starts-with(@tag,'1')]">
						<xsl:variable name="name">
							<xsl:value-of
								select="string-join(*[@code!='e' and @code!='4'  and @code!='6'],' ')"
								disable-output-escaping="no"/>
						</xsl:variable>
						<xsl:variable name="link"
							select="concat($url-prefix,'browse.xqy?bq=', encode-for-uri($name),'&amp;',$ajaxparams,'&amp;browse-order=ascending&amp;browse=author')"/>
						<li>
							<a href="{$link}" rel="nofollow">
								<xsl:value-of select="$name" disable-output-escaping="no"/>
							</a>
						</li>
					</xsl:for-each>
				</ul>
			</xsl:if>

			<xsl:if test="$browseclass//*:li">
				<h2>
					<xsl:if test="$toplist='class'">
						<xsl:attribute name="class">top</xsl:attribute>
					</xsl:if>Browse LC Classification</h2>

				<ul>
					<xsl:for-each select="distinct-values($browseclass//text())">
						<xsl:variable name="link" select="."/>
						<xsl:copy-of select="$browseclass//*:li[*:a/text()=$link][1]"
							copy-namespaces="yes"/>
					</xsl:for-each>
				</ul>
			</xsl:if>


			<xsl:variable name="catalogLink">
				<xsl:choose>
					<xsl:when test="$marcedit='erms' and $marcRecord//marc:datafield[@tag='035']">
						<xsl:variable name="ermsbib">
							<xsl:value-of
								select="$marcRecord//marc:datafield[@tag='035'][starts-with(marc:subfield[@code='a'],'.b')]/substring-after(marc:subfield[@code='a'],'.')"
							/>
						</xsl:variable>
						<xsl:value-of
							select="concat('http://eresources.loc.gov/record=',$ermsbib,'~S1')"
							disable-output-escaping="no"/>
					</xsl:when>

					<xsl:when test="normalize-space($lccn)!=''">
						<xsl:value-of
							select="concat('http://catalog.loc.gov/vwebv/search?searchArg1=%27',normalize-space($lccn),'%27&amp;searchCode1=KNUM&amp;searchType=2')"
							disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="concat('http://catalog.loc.gov/vwebv/holdingsInfo?bibId=',$bibid)"
							disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="catalogLabel">
				<xsl:choose>
					<xsl:when test="$marcedit!='erms'">LC Online Catalog</xsl:when>
					<xsl:otherwise>LC Electronic Resources Catalog</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<h2>
				<xsl:if test="$toplist='holdings'">
					<xsl:attribute name="class">top</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$marcedit!='erms'">View / Request </xsl:when>
					<xsl:otherwise>View in Catalog </xsl:otherwise>
				</xsl:choose>
			</h2>
			<ul>
				<li><!-- <a href="{$catalogLink}" rel="nofollow"> -->
					<a href="" rel="nofollow">
						<span style="color:gray;"><xsl:value-of select="$catalogLabel"/></span>
					</a>
				</li>
				<!-- <xsl:if test="$idxtitle!=''  and $marcedit!='erms'">
					<li>
						<a
							href="http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?PAGE=REQUESTBIB&amp;bbid={normalize-space($bibid)}"
							target="_new" rel="nofollow">Request Material (onsite only)</a>
					</li>
				</xsl:if> -->
			</ul>

			<h2>XML Metadata for This Item</h2>
			<ul>
				<!-- <li>
					<a href="{concat($bookmarkhref,'.marcxml.xml')}">MARCXML</a>
				</li>
				<li>
					<a href="{concat($bookmarkhref,'.mods.xml')}">MODS</a>
				</li> -->
				<li>
					<a href="{concat($bookmarkhref,'.rdf')}">BIBFRAME RDF</a>
				</li>
				<li>
					<a href="/{$objid}.mets.xml">METS</a>
				</li>
			</ul>
			<h2>Bookmark This Item</h2>
			<ul>
				<li>
					<span id="print-permalink" class="white-space">
						<a href="{$bookmarkhref}">
							<xsl:value-of select="$bookmarkhref"
								disable-output-escaping="no"/>
						</a>
					</span>
				</li>
			</ul>
			<!-- end id:ds-bibviews: -->
		</div>
	</xsl:template>
	<xsl:template name="getLCC" as="item()*">
		<xsl:param name="objid"/>
		<!--this code is also in mods/labels.xsl-->
		<!-- idx:lcclass has what we need, if we've run idx updated (since 11/3/11)
		-->
		<xsl:variable name="idx" select="metsutils:mets($objid)//idx:indexTerms"/>
		<xsl:choose>
			<xsl:when test="$idx//idx:lcclass[@search]">
				<xsl:for-each select="$idx//idx:lcclass[@search]">
					<!-- new style, ready to be used for browse -->
					<xsl:variable name="search"
						select="concat($url-prefix,'browse.xqy?bq=', encode-for-uri(@search),'&amp;',$ajaxparams,'&amp;browse-order=ascending&amp;browse=class')"/>
					<li>
						<a href="{$search}" rel="nofollow">
							<xsl:value-of select="." disable-output-escaping="no"/>
						</a>
					</li>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$marcedit!='erms'">

				<!-- this part can go away if we reload all after 11/4/11 
					if idx:lcclass doesnt' have@search, re-run idx:getlcc : -->
				<xsl:variable name="mods">
					<xsl:element name="mods" inherit-namespaces="yes"
						xmlns="http://www.loc.gov/mods/v3"/>
				</xsl:variable>
				<xsl:variable name="holdings"
					select="metsutils:hold-bib(xs:integer($bibid), 'lcdb')"/>


				<xsl:variable name="class" select="index:getLcc( $mods/element(), $holdings)"/>
				<xsl:for-each select="$class[local-name()='lcclass']">
					<xsl:variable name="search"
						select="concat($url-prefix,'browse.xqy?bq=', encode-for-uri(@search),'&amp;',$ajaxparams,'&amp;browse-order=ascending&amp;browse=class')"/>
					<li>
						<a href="{$search}" rel="nofollow">
							<xsl:value-of select="." disable-output-escaping="no"/>
						</a>
					</li>
				</xsl:for-each>
			</xsl:when>

		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->