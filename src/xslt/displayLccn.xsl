<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="marc xs metsutils idx mets" extension-element-prefixes="xdmp" default-validation="strip" input-type-annotations="unspecified" xmlns:xdmp="http://marklogic.com/xdmp" xmlns:local="local" xmlns:metsutils="info:lc/xq-modules/mets-utils" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:idx="info:lc/xq-modules/lcindex" xmlns:mets="http://www.loc.gov/METS/">
	<!--class=bibdata, bibdata-name, bibdata-subject, bibdata-subject are for hit-highlighting-->

	<xdmp:import-module namespace="info:lc/xq-modules/mets-utils" href="/xq/modules/mets-utils.xqy"/>
	<xsl:include href="/config/MARC21slimUtils.xsl"/>

	<xsl:output indent="yes" encoding="UTF-8"/>
	<xsl:param name="hostname"/>
	<xsl:param name="lccn"/>
	<xsl:param name="mattype"/>
	<xsl:param name="source"/>
	<!-- name, subject, or bib -->
	<xsl:param name="view"/>
	<xsl:param name="q"/>

	<xsl:variable name="marcRecord">
		<xsl:apply-templates select="//marc:record" mode="root"/>
	</xsl:variable>
	<xsl:variable name="bibid" select=" normalize-space(//marc:controlfield[@tag='001']) "/>
	<xsl:variable name="id" select="concat('loc.natlib.lcdb.', $bibid) "/>
	<xsl:variable name="mlbaseURL">/nlc/search.xqy?collection=all&amp;count=10&amp;pg=1&amp;mime=text%2Fhtml&amp;sort=score-desc&amp;q=</xsl:variable>

	<!--  cheating by calling out to XQuery for some global variables -->

	<!-- <xsl:variable name="tmpmets" select="metsutils:mets($id)"/> -->
	<!-- <xsl:variable name="tmpidxtitle" select="$tmpmets/mets:dmdSec[@ID='IDX1']/mets:mdWrap[@MDTYPE='OTHER']/mets:xmlData/idx:indexTerms/idx:display/idx:title"/>
	<xsl:variable name="tmpidxmat" select="$tmpmets/mets:dmdSec[@ID='IDX1']/mets:mdWrap[@MDTYPE='OTHER']/mets:xmlData/idx:indexTerms/idx:display/idx:typeOfMaterial"/> -->

	<!--<xsl:variable name="tmpidxtitle">test</xsl:variable>
	<xsl:variable name="tmpidxmat">book</xsl:variable>-->

	<xsl:template match="/" as="item()*">


		<!-- begin container -->
		<table class="record">

			<!-- begin content -->
			<!-- display for one or more records retrieved ; was: <xsl:apply-templates select="descendant-or-self::marc:record"/> -->
			<xsl:apply-templates select="$marcRecord" mode="processPage"/>
		</table>
	</xsl:template>

	<xsl:template match="marc:record" mode="processPage" as="item()*">
		<xsl:variable name="fulltitle">
			<xsl:choose>
				<xsl:when test="$source='bib'">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="marc:datafield[@tag='245']/marc:subfield[@code='a']" disable-output-escaping="no"/>
							<xsl:if test="marc:datafield[@tag='245']/marc:subfield[@code='b'or @code='p']">
								<xsl:text disable-output-escaping="no"> </xsl:text>
								<xsl:value-of select="marc:datafield[@tag='245']/marc:subfield[@code='b' or @code='p']" disable-output-escaping="no"/>
							</xsl:if>
						</xsl:with-param>
						<!--<xsl:with-param name="punctuation"><xsl:text>:,;/ </xsl:text></xsl:with-param>-->
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- 			headings are non-repeating; there should only be one: -->
					<xsl:value-of select="string-join(marc:datafield[contains('100 110 111 130 150 151 155',@tag)]/*,' ')" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="not(string-length($fulltitle) &gt; 200)">
					<xsl:value-of select="$fulltitle" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="findLastSpace">
						<xsl:with-param name="titleChop">
							<xsl:value-of select="substring($fulltitle, 1,200)" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text disable-output-escaping="no">...</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- header title display -->
		<div id="title-top">
			<xsl:choose>
				<xsl:when test="string-length($title) &gt; 0">
					<xsl:value-of select="$title" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>[No title]
					<!-- 				<xsl:value-of select="$tmpidxtitle"/> --></xsl:otherwise>
			</xsl:choose>
		</div>
		<xsl:call-template name="layout"/>
		<!-- <xsl:choose>
			<xsl:when test="$view!='marctags'">
				<xsl:call-template name="layout"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="taggedView"/>
			</xsl:otherwise>
		</xsl:choose> -->

	</xsl:template>

	<xsl:template name="layout" as="item()*">
		<xsl:variable name="id">
			<xsl:value-of select="format-number(number($bibid),'0000000000')" disable-output-escaping="no"/>
		</xsl:variable>

		<xsl:variable name="imagePath">
			<xsl:value-of select="concat('/media/loc.natlib.lcdb.',$bibid,'/0001.tif/200')" disable-output-escaping="no"/>
		</xsl:variable>
		<xsl:variable name="thumb">
			<xsl:value-of select="concat('/media/loc.natlib.lcdb.',$bibid,'/thumb')" disable-output-escaping="no"/>
		</xsl:variable>
		<tbody>
			<!-- images only for bibs, and only if well-styled -->
			<!-- <tr>
				<td>
					<img src="{$imagePath}" alt="Book cover image" width="200"/>
				</td>
				<td>
					<img src="{$thumb}" alt="Book cover image"/>
				</td>
			</tr> -->

			<xsl:if test="marc:datafield[@tag='010']/marc:subfield[@code='a']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">LC control no.</xsl:with-param>
					<xsl:with-param name="tag">010</xsl:with-param>
					<xsl:with-param name="subfields">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="source='bib'">
				<xsl:for-each select="marc:leader">
					<xsl:call-template name="matType"/>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="$source='bib'">
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
			</xsl:if>
			<xsl:if test="$source!='bib'">
				<xsl:if test="marc:datafield[contains('100 110 111 130 150 151 155',@tag)]">
					<xsl:call-template name="displayAllGroup">
						<xsl:with-param name="label">Heading</xsl:with-param>
						<xsl:with-param name="tag" select="marc:datafield[contains('100 110 111 130 150 151 155',@tag)]"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Topical subdivision:</xsl:with-param>
					<xsl:with-param name="tag" select="180"/>
					<xsl:with-param name="subfields" select="vxyz"/>
				</xsl:call-template>
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Geographic subdivision:</xsl:with-param>
					<xsl:with-param name="tag" select="181"/>
					<xsl:with-param name="subfields" select="vxyz"/>
				</xsl:call-template>
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Geographic subdiv usage:</xsl:with-param>
					<xsl:with-param name="tag" select="781"/>
					<xsl:with-param name="subfields" select="vxyz"/>
				</xsl:call-template>
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Chronological subdivision:</xsl:with-param>
					<xsl:with-param name="tag" select="182"/>
					<xsl:with-param name="subfields" select="vxyz"/>
				</xsl:call-template>
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Form subdivision:</xsl:with-param>
					<xsl:with-param name="tag" select="185"/>
					<xsl:with-param name="subfields" select="vxyz"/>
				</xsl:call-template>
			</xsl:if>
			<!-- uniform title 130, 240, 243  -->
			<xsl:if test="marc:datafield[@tag='130' or @tag='240' or @tag='243']">
				<xsl:call-template name="displayUT"/>
			</xsl:if>

			<!-- main title 245 -->

			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Main title</xsl:with-param>
				<xsl:with-param name="tag">245</xsl:with-param>
			</xsl:call-template>


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
					<xsl:with-param name="tag" select="marc:datafield[@tag='246' and @ind2='7']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- 242 -->

			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Title translation</xsl:with-param>
				<xsl:with-param name="tag">242</xsl:with-param>
			</xsl:call-template>


			<!-- 222 -->

			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Serial key title</xsl:with-param>
				<xsl:with-param name="tag">222</xsl:with-param>
			</xsl:call-template>


			<!-- 210 -->

			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Abbreviated title</xsl:with-param>
				<xsl:with-param name="tag">210</xsl:with-param>
			</xsl:call-template>


			<!-- Edition 250, 254 -->
			<xsl:if test="marc:datafield[@tag='250' or @tag='254']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Edition</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='250' or @tag='254']"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$source='bib'">
				<!-- Published/Created 260, 261, 262, 257, 270 -->
				<xsl:if test="marc:datafield[@tag='260' or @tag='261' or @tag='262' or @tag='257' or @tag='270']">
					<xsl:call-template name="displayAllGroup">
						<xsl:with-param name="label">Published/Created</xsl:with-param>
						<xsl:with-param name="tag" select="marc:datafield[@tag='260' or @tag='261' or @tag='262' or @tag='257' or @tag='270']"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>

			<!-- 263  -->

			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Projected pub date</xsl:with-param>
				<xsl:with-param name="tag">263</xsl:with-param>
			</xsl:call-template>


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
					<xsl:with-param name="tag" select="marc:datafield[@tag='300' or @tag='340' or @tag='362' or @tag='515']"/>
				</xsl:call-template>
			</xsl:if>

			<!-- Organized/Arranged 351  -->

			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Organized/Arranged</xsl:with-param>
				<xsl:with-param name="tag">351</xsl:with-param>
			</xsl:call-template>


			<!-- Current Frequency 310  -->

			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Current frequency</xsl:with-param>
				<xsl:with-param name="tag">310</xsl:with-param>
			</xsl:call-template>

			<!-- Former Frequency 321  -->
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Former frequency</xsl:with-param>
				<xsl:with-param name="tag">321</xsl:with-param>
			</xsl:call-template>
			<!-- Former Title 247 -->
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Former title</xsl:with-param>
				<xsl:with-param name="tag">247</xsl:with-param>
			</xsl:call-template>


			<!-- Continues; Continues in part; Merger of; Absorbed; Absorbed in part, Separated from 780 -->
			<!-- Continued by; Continued in part by; Absorbed by; Absorbed in part by; Split into; Changed back to 785 -->
			<xsl:if test="marc:datafield[@tag='780' and (@ind2='0' or @ind2='2')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Continues</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='780' and (@ind2='0' or @ind2='2')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='780' and (@ind2='1' or @ind2='3')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Continues in part</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='780' and (@ind2='1' or @ind2='3')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[(@tag='780' and @ind2='4') or (@tag='785' and @ind2='7')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Merger of</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[(@tag='780' and @ind2='4') or (@tag='785' and @ind2='7')]"/>
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
					<xsl:with-param name="tag" select="marc:datafield[@tag='785' and (@ind2='0' or @ind2='2')]"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='785' and (@ind2='1' or @ind2='3')]">
				<xsl:call-template name="display78X">
					<xsl:with-param name="label">Continued in part by</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='785' and (@ind2='1' or @ind2='3')]"/>
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
					<xsl:with-param name="tag" select="marc:datafield[(@tag='357' or @tag='506') or (@tag='307' and @ind1='8')]"/>
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
			<xsl:if test="marc:datafield[@tag='024' and (@ind1='1' or @ind1='3')]/marc:subfield[@code='a']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">UPC/EAN</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and (@ind1='1' or @ind1='3')]"/>
					<xsl:with-param name="subfields">acd2</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='024' and (@ind1='1' or @ind1='3')]/marc:subfield[@code='z']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Invalid UPC/EAN</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and (@ind1='1' or @ind1='3')]"/>
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
			<xsl:if test="marc:datafield[@tag='024' and (@ind1='7' or @ind1='8')]/marc:subfield[@code='a']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Other standard no.</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and (@ind1='7' or @ind1='8')]"/>
					<xsl:with-param name="subfields">acd2</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="marc:datafield[@tag='024' and (@ind1='7' or @ind1='8')]/marc:subfield[@code='z']">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Invalid standard no.</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='024' and (@ind1='7' or @ind1='8')]"/>
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
			<xsl:if test="marc:datafield[@tag='036' or @tag='256' or @tag='352' or @tag='516' or @tag='538' or @tag='753']">
				<xsl:call-template name="displayAllGroup">
					<xsl:with-param name="label">Computer file info</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='036' or @tag='256' or @tag='352' or @tag='516' or @tag='538' or @tag='753']"/>
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
			<xsl:if test="marc:datafield[@tag='678']">
				<!-- authorities -->
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Biography/History note:</xsl:with-param>
					<xsl:with-param name="tag">678</xsl:with-param>
					<xsl:with-param name="subfields">abu</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<!-- Summary, Review, Scope and Content, Abstract 520 -->
			<xsl:if test="marc:datafield[@tag='520' and (@ind1=' ' or @ind1='0' or @ind1='8')]">
				<xsl:call-template name="displayAllInd">
					<xsl:with-param name="label">Summary</xsl:with-param>
					<xsl:with-param name="tag" select="marc:datafield[@tag='520' and (@ind1=' ' or @ind1='0' or @ind1='8')]"/>
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
					<xsl:with-param name="tag" select="marc:datafield[@tag='505' and (@ind1=' ' or @ind1='0' or @ind1='8')]"/>
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
			<xsl:if test="$source='bib' and marc:datafield[number(@tag) &gt; 499 and number(@tag) &lt; 600 and @tag !='502' and @tag !='505' and  @tag !='506' and @tag !='507' and @tag !='508' and @tag !='510' and @tag !='511'  and @tag !='515' and @tag !='516'  and @tag !='520' and @tag !='522' and @tag !='524'  and @tag !='530' and @tag !='533' and @tag !='534' and @tag !='538' and @tag !='540'  and @tag !='541' and @tag !='545' and @tag !='555']">
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
					<xsl:with-param name="tag" select="marc:datafield[@tag='510' and (@ind1=' ' or @ind1='0')]"/>
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
					<xsl:with-param name="tag" select="marc:datafield[@tag='510' and (@ind1='3' or @ind1='4')]"/>
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
					<xsl:with-param name="tag" select="marc:datafield[@tag='555' and (@ind1='0' or @ind1='8')]"/>
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
					<xsl:with-param name="tag" select="marc:datafield[@tag='511' and (@ind1=' ' or @ind1='0')]"/>
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
			<xsl:if test="marc:datafield[@tag='600' or @tag='610' or @tag='611' or @tag='630' or @tag='648' or @tag='650' or @tag='651' or @tag='654' or @tag='656' or @tag='657' or @tag='658' or @tag='662' or @tag='690' or @tag='691' or @tag='692' or @tag='693' or @tag='694' or @tag='695' or @tag='696' or @tag='697' or @tag='698' or @tag='699' or @tag='751' or @tag='752']">
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
			<!-- subject authority: 670 -->

			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Series dates/Sequential designation:</xsl:with-param>
				<xsl:with-param name="tag">640</xsl:with-param>
				<xsl:with-param name="subfields">a</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Series numbering peculiarities:</xsl:with-param>
				<xsl:with-param name="tag">641</xsl:with-param>
				<xsl:with-param name="subfields">a</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Series numbering example:</xsl:with-param>
				<xsl:with-param name="tag">642</xsl:with-param>
				<xsl:with-param name="subfields">ad5</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Series place/Issuing body:</xsl:with-param>
				<xsl:with-param name="tag">643</xsl:with-param>
				<xsl:with-param name="subfields">abd</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Series analysis practice:</xsl:with-param>
				<xsl:with-param name="tag">644</xsl:with-param>
				<xsl:with-param name="subfields">abd5</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Series tracing practice:</xsl:with-param>
				<xsl:with-param name="tag">645</xsl:with-param>
				<xsl:with-param name="subfields">ad5</xsl:with-param>
			</xsl:call-template>


			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Series classification practice:</xsl:with-param>
				<xsl:with-param name="tag">646</xsl:with-param>
				<xsl:with-param name="subfields">ad5</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Scope note:</xsl:with-param>
				<xsl:with-param name="tag">680</xsl:with-param>
				<xsl:with-param name="subfields">ai</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">History note:</xsl:with-param>
				<xsl:with-param name="tag">665</xsl:with-param>
				<xsl:with-param name="subfields">a</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Explanatory note:</xsl:with-param>
				<xsl:with-param name="tag">666</xsl:with-param>
				<xsl:with-param name="subfields">a</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Special note:</xsl:with-param>
				<xsl:with-param name="tag">667</xsl:with-param>
				<xsl:with-param name="subfields">a</xsl:with-param>
			</xsl:call-template>
			<xsl:for-each select="marc:datafield[@tag='670']">
				<xsl:call-template name="foundIn"/>
				<!-- <xsl:with-param name="label">Found in:</xsl:with-param>
					<xsl:with-param name="tag">670</xsl:with-param>
					<xsl:with-param name="subfields">abu</xsl:with-param>
				</xsl:call-template> -->
			</xsl:for-each>
			<xsl:call-template name="displayAll">
				<xsl:with-param name="label">Not found in:</xsl:with-param>
				<xsl:with-param name="tag">675</xsl:with-param>
				<xsl:with-param name="subfields">a</xsl:with-param>
			</xsl:call-template>
			<!-- Series 4XX, 800-830 -->
			<xsl:if test="$source='bib'">
				<xsl:if test="marc:datafield[@tag='400' or @tag='410' or @tag='411' or @tag='440' or @tag='490' or @tag='760' or @tag='762' or @tag='800' or @tag='810' or @tag='811' or @tag='830' or @tag='840']">
					<xsl:call-template name="series"/>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$source!='bib'">
				<xsl:if test="marc:datafield[contains('400 410 411 430 450 451 455 480 481 482 485',@tag)]">
					<xsl:call-template name="displayAllGroup">
						<xsl:with-param name="label">Used for/See from:</xsl:with-param>
						<xsl:with-param name="tag" select="marc:datafield[contains('400 410 411 430 450 451 455 480 481 482 485',@tag)]"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="marc:datafield[contains('260 664',@tag)]">
					<xsl:call-template name="displayAllGroup">
						<xsl:with-param name="label">Search under:</xsl:with-param>
						<xsl:with-param name="tag" select="marc:datafield[contains('260 664',@tag)]"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="marc:datafield[contains('500 510 511 530 550 551 555 580 581 582 585  360 663',@tag)]">
					<xsl:call-template name="displayAllGroup">
						<xsl:with-param name="label">Search also under:</xsl:with-param>
						<xsl:with-param name="tag" select="marc:datafield[contains('500 510 511 530 550 551 555 580 581 582 585  360 663',@tag)]"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>

			<!-- LC Classification 050 -->
			<xsl:if test="marc:datafield[@tag='050']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">LC classification</xsl:with-param>
					<xsl:with-param name="tag">050</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<!-- authorities -->
			<xsl:if test="marc:datafield[@tag='053']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">LC classification</xsl:with-param>
					<xsl:with-param name="tag">053</xsl:with-param>
					<xsl:with-param name="subfields">ab</xsl:with-param>
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
			<xsl:if test="marc:datafield[@tag='042']">
				<xsl:call-template name="displayAll">
					<xsl:with-param name="label">Quality code</xsl:with-param>
					<xsl:with-param name="tag">042</xsl:with-param>
					<xsl:with-param name="subfields">a</xsl:with-param>
				</xsl:call-template>
			</xsl:if>

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
		</tbody>
	</xsl:template>

	<!-- ... -->
	<!-- Generic Templates -->
	<!-- Single tag; includes sfc u processing and special sfc 3 processing for 541 field-->
	<xsl:template match="marc:subfield" as="item()*">
		<xsl:choose>
			<xsl:when test="@code='3' and (../@tag!='541')">
				<xsl:value-of select="." disable-output-escaping="no"/>:</xsl:when>
			<!-- ml only -->
			<!-- <xsl:when test="@code='u' and ( ../@tag='856') and starts-with(../marc:subfield[@code='z'],'Search for images in Prints')">
				<xsl:text> </xsl:text>
			
				<xsl:variable name="link">
					<xsl:choose>
						<xsl:when test="$lccn!=''">
							<xsl:value-of select="concat('http://www.loc.gov/pictures/item/',normalize-space($lccn),'/')"/>
						</xsl:when>
						<xsl:otherwise>http://www.loc.gov/pictures</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<a href="{$link}" target="_new">
					<xsl:value-of select="$link"/>
				</a>
				<xsl:text> </xsl:text>
			</xsl:when> -->
			<xsl:when test="@code='u' and (../@tag='505' or  ../@tag='506' or  ../@tag='510' or  ../@tag='514' or  ../@tag='520' or  ../@tag='530'  or ../@tag='538'  or ../@tag='540'  or ../@tag='542'  or ../@tag='545'  or ../@tag='552'  or ../@tag='555' or ../@tag='563'  or ../@tag='583' or ../@tag='852' or ../@tag='856' or ../@tag='859')">
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
		<xsl:if test="marc:datafield[@tag=$tag]">
			<!-- <xsl:variable name="titles" select="('245','246','247','242','210','222')"/>
		<xsl:variable name="css-class">
			<xsl:choose>
				<xsl:when test="$tag=$titles">bibdata-title</xsl:when>
				<xsl:otherwise>bibdata</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
 -->
			<tr>
				<th rowspan="1" colspan="1">
					<xsl:value-of select="$label" disable-output-escaping="no"/>
				</th>
				<td rowspan="1" colspan="1">
					<xsl:choose>
						<xsl:when test="empty($subfields)">
							<xsl:for-each select="marc:datafield[@tag=$tag]">
								<xsl:apply-templates select="*[@code='3']"/>
								<!-- adds dir=rtl span tag for Hebrew and Arabic -->
								<xsl:choose>
									<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
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
						</xsl:when>
						<xsl:when test="not(empty($subfields))">
							<xsl:if test="marc:datafield[@tag=$tag]/marc:subfield[contains($subfields,@code)]">
								<!-- test to make sure record contains at least on repeatable field with specified sfc -->
								<xsl:for-each select="marc:datafield[@tag=$tag]">
									<!-- test to prevent extra br when some repeated fields lacks specified sfc -->
									<xsl:if test="marc:subfield[contains($subfields,@code)]">
										<xsl:apply-templates select="*[@code='3']"/>
										<!-- adds dir=rtl span tag for Hebrew and Arabic -->
										<xsl:choose>
											<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">

												<xsl:for-each select="*[(@code!='6' and @code!='3' and @code!='0') and contains($subfields,@code)]">
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
												<xsl:apply-templates select="*[(@code!='6' and @code!='3' and @code!='0') and contains($subfields,@code)]"/>
											</xsl:otherwise>
										</xsl:choose>
										<br/>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<!-- Defined group of tags,; no special indicator processing; covers sfc 0, 3, 6-->
	<xsl:template name="displayAllGroup" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>
		<!-- <xsl:variable name="pub-create-label" select="'Published/Created'"/>
		<xsl:variable name="new-pub-create-label" select="'Published_Created'"/> -->

		<tr>
			<th rowspan="1" colspan="1">
				<xsl:value-of select="$label" disable-output-escaping="no"/>
			</th>
			<!--<dd class="{ if ($label eq $pub-create-label) then $new-pub-create-label else $label }">-->
			<td rowspan="1" colspan="1">
				<xsl:for-each select="$tag">
					<xsl:apply-templates select="*[@code='3']"/>
					<xsl:choose>
						<!-- adds dir=rtl span tag for Hebrew and Arabic -->
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
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
			</td>
		</tr>
	</xsl:template>

	<!-- Defined group of tags,; no special indicator processing; covers sfc 0, 3, 6; sfc 3 not moved to beginning of field -->
	<xsl:template name="displayAllGroup3" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>

		<tr>
			<th rowspan="1" colspan="1">
				<xsl:value-of select="$label" disable-output-escaping="no"/>
			</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="$tag">
					<xsl:choose>
						<!-- adds dir=rtl span tag for Hebrew and Arabic -->
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
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
			</td>
		</tr>
	</xsl:template>

	<!-- Defined group of tags,; indicator-specific labels ; used for 024, 246, 505, 510, 511, 520, 555; covers sfc 0, 3, 6 -->
	<xsl:template name="displayAllInd" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>
		<xsl:param name="subfields"/>

		<tr>
			<th rowspan="1" colspan="1">
				<xsl:value-of select="$label" disable-output-escaping="no"/>
			</th>
			<td rowspan="1" colspan="1">
				<xsl:choose>
					<xsl:when test="empty($subfields)">
						<xsl:for-each select="$tag">
							<xsl:apply-templates select="*[@code='3']"/>
							<xsl:apply-templates select="*[@code='i']"/>
							<xsl:choose>
								<!-- adds dir=rtl span tag for Hebrew and Arabic, with exception for 246 sfc i -->
								<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
									<xsl:for-each select="*[@code!='6' and @code!='3' and @code!='0' and @code!='i']">
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
									<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0' and @code!='i']"/>
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
										<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
											<!--<span dir="rtl">
													<xsl:apply-templates select="*[(@code!='6' and @code!='3' and @code!='0' and @code!='i') and contains($subfields,@code)]"/>
													</span>-->
											<xsl:for-each select="*[(@code!='6' and @code!='3' and @code!='0' and @code!='i') and contains($subfields,@code)]">
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
											<xsl:apply-templates select="*[(@code!='6' and @code!='3' and @code!='0' and @code!='i') and contains($subfields,@code)]"/>
										</xsl:otherwise>
									</xsl:choose>
									<br/>
								</xsl:if>
							</xsl:for-each>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>

	<!-- Material Type Template (uses Leader, 006, 007;  note: 336-337-338 not yet included); calls separate Material Type xsl display table-->

	<xsl:template name="matType" as="item()*">

		<tr>
			<th rowspan="1" colspan="1">Type of material</th>
			<td rowspan="1" colspan="1">
				<xsl:choose>
					<xsl:when test="string-length($mattype) gt 0">
						<xsl:value-of select="$mattype" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>[Undetermined]
						<!-- <xsl:value-of select="$tmpidxmat"/> --></xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>


	<!-- Special Group Templates and Global Variables for "More like this" linking to Voyager-->
	<!-- No Title linking for 243, 246, 247, 740; Title linking using Voyager TALL index; TALL includes sfc h  -->
	<!-- No Voyager Subject headings available for 648, 662, 752 -->
	<!-- No Voyager Name or Name-Title Heading support for X00 sfc g -->
	<xsl:variable name="createUrlSearchString">
		<createUrlSearchString name="encodedSubfieldSelect">
			<tag fields="100;400;700;800;" codes="a;b;c;d;k;q;"></tag>
			<tag fields="110;410;710;810;" codes="a;b;c;d;g;k;n;"></tag>
			<tag fields="111;411;711;811;" codes="a;b;c;d;e;g;n;q;"></tag>
			<tag fields="130;730;" codes="a;d;f;g;h;k;l;m;n;o;p;r;s;t;" indicators="ind1;"></tag>
			<tag fields="240;" codes="a;d;f;g;h;k;l;m;n;o;p;r;s;" indicators="ind2;"></tag>
			<tag fields="440;" codes="a;n;p;" indicators="ind2"></tag>
			<tag fields="600;" codes="a;b;c;d;f;g;k;l;m;n;o;p;q;r;s;t;v;x;y;z;"></tag>
			<tag fields="610;" codes="a;b;c;d;f;g;k;l;m;n;o;p;r;s;t;v;x;y;z;"></tag>
			<tag fields="611;" codes="a;b;c;d;e;f;g;k;l;n;p;q;s;t;v;x;y;z;"></tag>
			<tag fields="630;" codes="a;d;f;g;k;l;m;n;o;p;r;s;v;x;y;z;" indicators="ind1;"></tag>
			<tag fields="650;651;" codes="a;b;v;x;y;z;"></tag>
			<tag fields="670;" codes="a;b;u;"></tag>
			<tag fields="655;" codes="a;b;v;x;y;z;"></tag>
			<tag fields="760;762;765;767;770;772;773;774;775;776;777;780;785;786;787;" codes="t;"></tag>
			<tag fields="830;" codes="a;d;f;g;h;k;l;m;n;o;p;r;s;t;" indicators="ind2;"></tag>
		</createUrlSearchString>
	</xsl:variable>

	<xsl:variable name="createDisplayString">
		<createDisplayString xmlns="local">
			<pweblink fields="100;110;111;" name="displayME">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg={$link}&amp;Search_Code=NAME_&amp;CNT=25c</pweblink>
			<pweblink fields="130;240;" name="displayUT">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25</pweblink>

			<pweblink fields="400;410;411;" name="series">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg={$link}&amp;Search_Code=NAME_&amp;CNT=25</pweblink>
			<pweblink fields="440;" name="series">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25</pweblink>
			<pweblink fields="600;610;611;630;650;651;" name="subject">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;SA={$link}&amp;SC=SUBJ&amp;CNT=25</pweblink>
			<pweblink fields="655;" name="formGenre">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;SA={$link}&amp;SC=SUBJ&amp;CNT=25</pweblink>
			<pweblink fields="700;710;711;" name="relatedNames">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg={$link}&amp;Search_Code=NAME_&amp;CNT=25</pweblink>
			<!-- authorities title search found in: -->
			<!-- <pweblink fields="670;" name="foundIn">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Code=CMD&amp;CNT=25&amp;Search_Arg=TALL+</pweblink>  -->
			<!-- add {$link}?" -->
			<pweblink fields="670;" name="foundIn">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25</pweblink>
			<pweblink fields="730;" name="relatedTitles">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25</pweblink>
			<pweblink fields="760;762;" name="series">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25</pweblink>
			<pweblink fields="776;" name="additionalFormats">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CMD&amp;CNT=25</pweblink>
			<pweblink fields="800;810;811;" name="series">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg={$link}&amp;Search_Code=NAME_&amp;CNT=25</pweblink>
			<pweblink fields="830;" name="series">http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?db=local&amp;Search_Arg=TALL+"{$link}?"&amp;Search_Code=CM&amp;CNT=25</pweblink>
		</createDisplayString>
	</xsl:variable>

	<xsl:template name="encodedSubfieldSelect" as="item()*">
		<xsl:param name="delimiter">
			<xsl:text disable-output-escaping="no"> </xsl:text>
		</xsl:param>
		<xsl:variable name="tag" select="concat(@tag, ';')"/>
		<xsl:variable name="ind1" select="normalize-space(@ind1)"/>
		<xsl:variable name="ind2" select="normalize-space(@ind2)"/>
		<xsl:variable name="codes" select="$createUrlSearchString//*[not(parent::*)]/*[contains(@fields, $tag)]/@codes"/>
		<xsl:variable name="indicators" select="$createUrlSearchString//*[not(parent::*)]/*[contains(@fields, $tag)]/@indicators"/>

		<xsl:variable name="codeStr">
			<xsl:for-each select="marc:subfield">
				<xsl:variable name="cd" select="concat(@code, ';')"/>
				<xsl:if test="contains($codes, $cd)">
					<xsl:if test="contains('655;',$tag)">|<xsl:value-of select="$cd" disable-output-escaping="no"/>|</xsl:if>
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
							<xsl:value-of select="substring($codeStr, number($ind1)+1)" disable-output-escaping="no"/>
						</xsl:if>
						<xsl:if test=".='ind2'">
							<xsl:value-of select="substring($codeStr, number($ind2)+1)" disable-output-escaping="no"/>
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
				<xsl:with-param name="chopString" select="substring($codeStr2,1,string-length($codeStr2) - string-length($delimiter))"/>
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

		<tr>
			<th rowspan="1" colspan="1">
				<xsl:value-of select="$label" disable-output-escaping="no"/>
			</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='100' or @tag='110' or @tag='111']">
					<xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect"/>
					</xsl:variable>
					<xsl:variable name="display">
						<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
					</xsl:variable>

					<!-- adds dir=rtl span tag for Hebrew and Arabic, with extra test to prevent span tags on names beginning with Romanized data in sfc a -->
					<xsl:choose>
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
							<a href="{concat($mlbaseURL,$search,'&amp;qname=idx:byName')}">
								<xsl:choose>
									<xsl:when test="matches($display,'[A-Za-z]') ">
										<!--english text -->
										<xsl:value-of select="$display" disable-output-escaping="no"/>
									</xsl:when>
									<xsl:otherwise>
										<span dir="rtl">
											<xsl:value-of select="$display" disable-output-escaping="no"/>
										</span>
									</xsl:otherwise>
								</xsl:choose>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="{concat($mlbaseURL, $search, '&amp;qname=idx:byName')}">
								<xsl:value-of select="$display" disable-output-escaping="no"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<br/>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>

	<!-- Uniform Title Template for 130, 240, 243; covers sfc 0, 6 (240: no sfc 3; 243: no sfc 0, 3)   -->
	<xsl:template name="displayUT" as="item()*">
		<xsl:param name="label"/>
		<tr>
			<th rowspan="1" colspan="1">Uniform title</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='130' or @tag='240']">
					<xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect"/>
					</xsl:variable>
					<xsl:variable name="display">
						<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
					</xsl:variable>
					<xsl:choose>
						<!-- adds dir=rtl span tag for Hebrew and Arabic -->
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
							<a href="{concat($mlbaseURL,$search, '&amp;qname=idx:uniformTitle')}">
								<xsl:choose>
									<xsl:when test="matches($search,'[A-Za-z]') ">
										<!--english text -->
										<xsl:value-of select="$display" disable-output-escaping="no"/>
									</xsl:when>
									<xsl:otherwise>
										<span dir="rtl">
											<xsl:value-of select="$display" disable-output-escaping="no"/>
										</span>
									</xsl:otherwise>
								</xsl:choose>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="{concat($mlbaseURL,$search,'&amp;qname=idx:uniformTitle')}">
								<xsl:value-of select="$display" disable-output-escaping="no"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<br/>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag='243']">
					<xsl:choose>
						<!-- adds dir=rtl span tag for Hebrew and Arabic -->
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
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
			</td>
		</tr>
	</xsl:template>

	<!-- Series Template for 4XX, 760, 762, 800-830, 840; covers sfc 0, 3, 6  (490: no sfc 0; 840 : no sfc 0, 3; 760/752: no sfc 3) -->
	<xsl:template name="series" as="item()*">
		<tr>
			<th rowspan="1" colspan="1">Series</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='400' or @tag='410' or @tag='411' or @tag='440']">
					<xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect"/>
					</xsl:variable>
					<xsl:variable name="display">
						<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
					</xsl:variable>

					<xsl:apply-templates select="*[@code='3']"/>
					<!-- adds dir=rtl span tag for Hebrew and Arabic; as obsolete fields, there should be no 880s for 400-411 -->
					<!-- 				change to idx:seriesTitle after next reindex 20110328 -->
					<a href="{concat($mlbaseURL,$search,'&amp;qname=idx:title')}">
						<xsl:choose>
							<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
								<xsl:choose>
									<xsl:when test="matches($display,'[A-Za-z]') ">
										<!--english text -->
										<xsl:value-of select="$display" disable-output-escaping="no"/>
									</xsl:when>
									<xsl:otherwise>
										<span dir="rtl">
											<xsl:value-of select="$display" disable-output-escaping="no"/>
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
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
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

				<xsl:for-each select="marc:datafield[@tag='800' or @tag='810' or @tag='811' or @tag='830']">
					<xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect"/>
					</xsl:variable>
					<xsl:variable name="display">
						<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
					</xsl:variable>

					<xsl:apply-templates select="*[@code='3']"/>
					<a href="{concat($mlbaseURL,$search)}">
						<!-- adds dir=rtl span tag for Hebrew and Arabic, with extra test to prevent span tags on names beginning with Romanized data in sfc a  (only relevant for 810 and 811) -->
						<xsl:choose>
							<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
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
					<a href="{concat($mlbaseURL,$search)}">
						<xsl:apply-templates select="*[@code!='6' and @code!='0']"/>
					</a>
					<br/>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>

	<!-- Additional Formats Template for 530, 533, 534, 776;  covers sfc 3, 6 (53X: no sfc 0; 776: no sfc 3)   -->
	<xsl:template name="additionalFormats" as="item()*">
		<tr>
			<th rowspan="1" colspan="1">Additional formats</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='530' or @tag='533' or @tag='534']">
					<xsl:apply-templates select="*[@code='3']"/>
					<xsl:choose>
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
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
							<a href="{concat($mlbaseURL,$search)}">
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
			</td>
		</tr>
	</xsl:template>

	<!-- Notes Template for 5XX (with exceptions), 382 ;  covers sfc 3, 6 (no sfc 0) -->
	<xsl:template name="notes" as="item()*">

		<tr>
			<th rowspan="1" colspan="1">Notes</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[number(@tag) &gt; 499 and number(@tag) &lt; 600 and (@tag !='502' and @tag !='505' and @tag !='506' and @tag !='507' and @tag !='508' and @tag !='510' and @tag !='511' and @tag !='515' and @tag !='516' and @tag !='520' and @tag !='522' and @tag !='524' and @tag !='530' and @tag !='533' and @tag !='534' and @tag !='538' and @tag !='540' and @tag !='541' and @tag !='545' and @tag !='555')] | marc:datafield[@tag='382']">
					<xsl:apply-templates select="*[@code='3']"/>
					<xsl:choose>
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
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
			</td>
		</tr>
	</xsl:template>

	<!-- Subjects Template for 600-651, 648, 654, 656-659, 690-699, 751, 752; covers sfc 0, 3, 6 by explicit subfield list in encodedSubfieldSelect   -->
	<xsl:template name="subject" as="item()*">

		<tr>
			<th rowspan="1" colspan="1">Subjects</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='600' or @tag='610' or @tag='611' or @tag='630' or @tag='650' or @tag='651']">
					<xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect">
							<xsl:with-param name="delimiter">--</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					<a href="{concat($mlbaseURL,$search,'&amp;qname=idx:subjectLexicon')}">
						<xsl:apply-templates select="*[@code='3']"/>
						<xsl:for-each select="*[@code!='2' and @code!='3' and @code!='0' and @code!='6' ]">
							<xsl:value-of select="." disable-output-escaping="no"/>
							<xsl:if test="position()!=last()">--</xsl:if>
						</xsl:for-each>
					</a>
					<br/>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag='648' or @tag='654' or @tag='656' or @tag='657' or @tag='658' or @tag='662' or @tag='690' or @tag='691' or @tag='692' or @tag='693' or @tag='694' or @tag='695' or @tag='696' or @tag='697' or @tag='698' or @tag='699' or @tag='751' or @tag='752']">
					<xsl:apply-templates select="*[@code='3']"/>
					<xsl:call-template name="subjectSubfieldSelect"/>
					<br/>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>

	<!-- Form/Genre Template for 655; covers sfc 0, 3, 6 by explicit subfield list in encodedSubfieldSelect  -->
	<xsl:template name="formGenre" as="item()*">

		<tr>
			<th rowspan="1" colspan="1">Form/Genre</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='655']">
					<!--mods: genre gets 655 : a;b;v;x;y;z;-->
					<xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect"/>
					</xsl:variable>

					<a href="{concat($mlbaseURL, $search, '&amp;qname=idx:subjectLexicon')}">
						<xsl:apply-templates select="marc:subfield[@code='3']"/>
						<xsl:apply-templates select="marc:subfield[contains('abvxyz',@code)]"/>
					</a>
					<br/>
				</xsl:for-each>
				<!--	</td>
		</tr>-->
			</td>
		</tr>
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
							<xsl:when test="../@tag!='502' and ../@tag!='662' and ../@tag!='752' and contains('vxyz',@code)">--</xsl:when>
							<xsl:when test="(../@tag='502' and contains('bcdgo',@code)) or (../@tag='662' and contains('bcdefgh',@code)) or (../@tag='752' and contains('bcdfgh',@code))">--</xsl:when>
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
			<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
				<span dir="rtl">
					<xsl:value-of select="substring($str,1,string-length($str))" disable-output-escaping="no"/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring($str,1,string-length($str))" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="dissertation" as="item()*">
		<tr>
			<th rowspan="1" colspan="1">Dissertation note</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='502']">
					<xsl:apply-templates select="*[@code='3']"/>
					<xsl:call-template name="subjectSubfieldSelect"/>
					<br/>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>

	<!-- Related Names Template for 700, 710, 711, 720;  covers sfc 0, 3, 6  -->
	<xsl:template name="relatedNames" as="item()*">

		<tr>
			<th rowspan="1" colspan="1">Related names</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='700' or @tag='710' or @tag='711']">
					<xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect"/>
					</xsl:variable>

					<a href="{concat($mlbaseURL, $search,'&amp;qname=idx:byName')}">

						<xsl:apply-templates select="*[@code='3']"/>
						<!-- adds dir=rtl span tag for Hebrew and Arabic, with extra test to prevent span tags on names beginning with Romanized data in sfc a (relevant for 710 and 711) -->
						<xsl:choose>
							<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')  ">
								<span dir="rtl">
									<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0' ]"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
					<br/>
				</xsl:for-each>



				<xsl:for-each select="marc:datafield[@tag='720']">
					<!-- adds dir=rtl span tag for Hebrew and Arabic; as uncontrolled name should not have Roman data in 880 sfc a -->
					<xsl:choose>
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
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
			</td>
		</tr>
	</xsl:template>
	<xsl:template name="foundIn" as="item()*">
		<!-- based on relatedTitles -->
		<!-- marklogic search <xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect"/>
					</xsl:variable>
					<a href="{concat($mlbaseURL,$search,'&amp;qname=idx:uniformTitle')}">						
						<xsl:choose>
							<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
								<span dir="rtl">
									<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
					<br/> -->

		<!-- pweb: -->
		<xsl:variable name="pTag" select="concat(@tag, ';')"/>
		<xsl:variable name="link">
			<xsl:call-template name="encodedSubfieldSelect"/>
		</xsl:variable>
		<xsl:variable name="pwebString">
			<xsl:value-of select="$createDisplayString//local:pweblink[contains(@fields, $pTag)]" disable-output-escaping="no"/>
		</xsl:variable>

		<!-- <xsl:variable name="pwebA" select="substring-before($pwebString, '{')" />  -->
		<!-- <xsl:variable name="pwebB" select="substring-after($pwebString, '}')" /> -->

		<xsl:apply-templates select="*[@code='3']|text()"/>
		<!-- adds dir=rtl span tag for Hebrew and Arabic -->
		<xsl:choose>
			<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
				<span dir="rtl">
					<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
			</xsl:otherwise>
		</xsl:choose>

		<span class="noprint">
			<xsl:text disable-output-escaping="no"> » </xsl:text>
			<a href="{replace($pwebString,'$link',$link)}">More like this</a>
		</span>
		<br/>
		<!-- <p><xsl:copy-of select="$pTag"/>|<xsl:copy-of select="$createDisplayString//local:pweblink" />|</p> -->
		<!-- <p><xsl:copy-of select="$pTag"/>|<xsl:copy-of select="$createDisplayString//local:link[contains(@fields,'670;')]/text()" />|</p> -->
	</xsl:template>
	<!-- Related TitlesTemplate for 730, 740; covers sfc 0, 3, 6 (740: no sfc 0, 3) -->
	<xsl:template name="relatedTitles" as="item()*">
		<tr>
			<th rowspan="1" colspan="1">Related titles</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='730']">
					<xsl:variable name="search">
						<xsl:call-template name="encodedSubfieldSelect"/>
					</xsl:variable>
					<a href="{concat($mlbaseURL,$search,'&amp;qname=idx:uniformTitle')}">
						<!-- adds dir=rtl span tag for Hebrew and Arabic -->
						<xsl:choose>
							<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3')">
								<span dir="rtl">
									<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0']"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
					<br/>
				</xsl:for-each>

				<xsl:for-each select="marc:datafield[@tag='740']">
					<!-- adds dir=rtl span tag for Hebrew and Arabic -->
					<xsl:choose>
						<xsl:when test="contains(marc:subfield[@code='6'], '(2') or contains(marc:subfield[@code='6'], '(3') ">
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
			</td>
		</tr>
	</xsl:template>

	<!-- 76X-78X Linking Template (760, 762, 776 handled elsewhere); covers sfc 0, 3, 6; no 880s for 76X-78X -->
	<xsl:template name="display78X" as="item()*">
		<xsl:param name="label"/>
		<xsl:param name="tag"/>

		<tr>
			<th rowspan="1" colspan="1">
				<xsl:value-of select="$label" disable-output-escaping="no"/>
			</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="$tag">
					<xsl:choose>
						<xsl:when test="*[@code='t']">
							<!-- what was this for? subfield w isn't on the list of encoded subfield select -->
							<!-- <xsl:variable name="search">
							<xsl:choose>
								<xsl:when test="marc:subfield[@code='w'][contains(text(),'(DLC)')]">
									<xsl:for-each select="marc:subfield[@code='w'][contains(text(),'(DLC)')]">											
										<xsl:value-of select="substring-after(text(),'(DLC)')"/>											
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>									
									<xsl:call-template name="encodedSubfieldSelect"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						 -->
							<xsl:variable name="search">
								<xsl:call-template name="encodedSubfieldSelect"/>
							</xsl:variable>

							<!-- <a href="{concat($mlbaseURL,$search)}"> -->
							<a href="{concat($mlbaseURL,$search,'&amp;qname=idx:title')}">
								<xsl:apply-templates select="*[@code='3']"/>
								<xsl:apply-templates select="*[@code!='6' and @code!='3' and @code!='0' and @code!='w']"/>
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
			</td>
		</tr>
	</xsl:template>

	<!-- 856-859 Linking Template (note: 859 links for serials activated because of Voyager SRU issues with holdings 856 fields ; no 880 text  for 856/859; covers sfc 3 (no sfc 0, 6) -->
	<xsl:template name="link85X" as="item()*">
		<tr>
			<th rowspan="1" colspan="1">Links</th>
			<td rowspan="1" colspan="1">
				<xsl:for-each select="marc:datafield[@tag='856' or @tag='859']">
					<xsl:apply-templates select="*[@code='3' or @code='u']"/>
					<xsl:if test="*[@code='y' or @code='z']">
						<xsl:text disable-output-escaping="no"> </xsl:text>
						<xsl:apply-templates select="*[@code='y' or @code='z']"/>
					</xsl:if>
					<br/>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>

	<!-- Holdings Template  -->
	<!--<xsl:template match="holdings[holding]">
		<hr size="1" noshade="noshade"/>
		<span class="hold-title">Holdings Information:</span>
		<div class="holdings">
			<xsl:apply-templates/>
		</div>
	</xsl:template>-->

	<!--<xsl:template match="holding">			
		<tr><th>Call number</th>
		<td>
			<xsl:if test="callNumber!='Electronic Resource'">
				<a href="http://catalog.loc.gov/cgi-bin/Pwebrecon.cgi?Search_Arg={callNumber}&amp;Search_Code=CALL&amp;CNT=10&amp;HIST=1">
					<xsl:value-of select="callNumber"/>
				</a>
			</xsl:if>
		</td>
	</xsl:template>-->

	<!-- Chop Template for Title header  -->
	<xsl:template name="findLastSpace" as="item()*">
		<xsl:param name="titleChop"/>
		<xsl:choose>
			<xsl:when test="substring($titleChop,string-length($titleChop))!=' '">
				<xsl:call-template name="findLastSpace">
					<xsl:with-param name="titleChop" select="substring($titleChop, 1,string-length($titleChop)-1)"/>
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
						<xsl:element name="{name()}" namespace="{namespace-uri()}" inherit-namespaces="yes">
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
	<xsl:template match="* | @* | text() | comment() | processing-instruction()" mode="global_copy" as="item()*">
		<xsl:copy inherit-namespaces="yes" copy-namespaces="yes">
			<xsl:apply-templates select="* | @* | text() | comment() | processing-instruction()" mode="global_copy"/>
		</xsl:copy>
	</xsl:template>

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
				<br/>•  <xsl:value-of select="." disable-output-escaping="no"/></xsl:when>

			<xsl:when test="@code='a' and contains(text(),'--')">
				<xsl:variable name="chapters" select="tokenize(.,'--')"/>
				<xsl:for-each select="$chapters">• --<xsl:value-of select="." disable-output-escaping="no"/><br/></xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>