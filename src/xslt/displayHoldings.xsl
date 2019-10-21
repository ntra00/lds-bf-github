<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xs metsutils mets index marc locs hld" extension-element-prefixes="xdmp" default-validation="strip" input-type-annotations="unspecified" xmlns:index="info:lc/xq-modules/index-utils" xmlns:xdmp="http://marklogic.com/xdmp" xmlns:locs="info:lc/xq-modules/config/lclocations" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:metsutils="info:lc/xq-modules/mets-utils" xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:idx="info:lc/xq-modules/lcindex" xmlns:hld="http://www.indexdata.com/turbomarc" xmlns:mets="http://www.loc.gov/METS/">
	<!-- 2011/11/07
		NOT USED!  look in /nlc/parts/holdings.xqy, which calls /xq/modules/holdings-utils: hold:display()
		
 	This is the holdings display extracted from displayLcdb.xsl, 
    so we can call it independently in ajaxy functions, or from the std display.
    display of the browse to lcclass based on holdings will be converted to idx:lcclass, so we
    don't need to open holdings for that.
-->

	<xdmp:import-module namespace="info:lc/xq-modules/config/lclocations" href="/xq/modules/config/lclocations.xqy"/>
	<xdmp:import-module namespace="info:lc/xq-modules/mets-utils" href="/xq/modules/mets-utils.xqy"/>
	<xdmp:import-module namespace="info:lc/xq-modules/index-utils" href="/xq/modules/index-utils.xqy"/>
	<xsl:output indent="yes" encoding="UTF-8"/>

	 <!--<xsl:variable name="bibid" select="normalize-space(//marc:controlfield[@tag='001']) "/>
	<xsl:variable name="id" select="concat('loc.natlib.lcdb.', $bibid) "/> -->

	<xsl:variable name="holdings" select="metsutils:hold-bib(xs:integer($bibid))"/>
	<xsl:variable name="locs" select="locs:locations()"/>
	<xsl:template name="getHoldings" as="item()*">
		<xsl:param name="bibid"/>
		<xsl:choose>
			<xsl:when test="$holdings/hld:r">
				<xsl:apply-templates select="$holdings/hld:r"/>
			</xsl:when>
			<xsl:otherwise>
				<dt class="label">
				</dt>
				<dd class="bibdata">
					<span class="noholdings">Library of Congress Holdings Information Not Available.</span>
				</dd>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="hld:r" as="item()*">
		<xsl:apply-templates select="hld:d852"/>
	</xsl:template>

	<xsl:template match="hld:d852" as="item()*">
		<div class="hr">
			<hr/>
		</div>
		<xsl:variable name="callno" select="string-join(*[local-name()!='s3'][local-name()!='sb'][local-name()!='st'][local-name()!='sx'][local-name()!='sz'],' ')"/>
		<xsl:variable name="callno-text">
			<xsl:choose>
				<xsl:when test="hld:sh and normalize-space($callno)!=''">
					<xsl:value-of select="$callno" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>Not Available</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<dt class="label">Call Number</dt>
		<dd class="bibdata">
			<xsl:value-of select="$callno-text" disable-output-escaping="no"/>

			<xsl:for-each select="hld:st| hld:sz|hld:s3">
				<br/>
				<xsl:value-of select="." disable-output-escaping="no"/>
			</xsl:for-each>
		</dd>

		<xsl:if test="not(ancestor-or-self::hld:r/hld:d856)">
			<!-- suppress the "request in" field for online; that info is in item level locations, which we don't have,
			plus it's online, so you request it by clicking on the 856 -->
			<xsl:for-each select="hld:sb">
				<xsl:variable name="this-location" select="normalize-space(.)"/>

				<dt class="label">Request in</dt>
				<dd class="bibdata">
					<xsl:choose>
						<xsl:when test="../hld:sh='Electronic Resource'">Online</xsl:when>
						<xsl:when test="$locs//locs:location[locs:code=$this-location]/locs:display">
							<xsl:value-of select="$locs//locs:location[locs:code=$this-location]/locs:display" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- highlight holdings that should be suppressed: -->
							<span class="noholdings">
								<xsl:value-of select="$this-location" disable-output-escaping="no"/>
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

	<xsl:template match="hld:*[starts-with(local-name(),'d')][local-name()!='d014'][local-name()!='d035'][local-name()!='d852'][local-name()!='d856'][local-name()!='d866'][local-name()!='d867'][local-name()!='d868'][local-name()!='d986']" as="item()*">
		<dt class="label">Other</dt>
		<dd style="color:red">
			<xsl:value-of select="string-join(hld:*,' ')" disable-output-escaping="no"/>
		</dd>
	</xsl:template>

	<xsl:template match="hld:d014" as="item()*">
		<xsl:if test="normalize-space(hld:sa)!=normalize-space($bibid) and position()!=1">
			<dt class="label">Bound with</dt>
			<dd style="color:red">
				<a href="{concat('http://',$hostname,'/loc.natlib.lcdb.',hld:sa,'.html')}">
					<xsl:value-of select="hld:sa" disable-output-escaping="no"/>
				</a>
			</dd>
		</xsl:if>
	</xsl:template>

	<xsl:template match="hld:d866 | hld:d867" as="item()*">
		<dd>
			<xsl:value-of select="hld:sz" disable-output-escaping="no"/>
			<xsl:text disable-output-escaping="no"> </xsl:text>
			<xsl:value-of select="hld:sa" disable-output-escaping="no"/>
		</dd>
	</xsl:template>
	<xsl:template match="hld:d868" as="item()*">
		<dt class="label">Older Receipts</dt>
		<dd>
			<xsl:value-of select="hld:sa" disable-output-escaping="no"/>
		</dd>
	</xsl:template>

	<xsl:template match="hld:d856" as="item()*">
		<dt class="label">Links</dt>
		<dd class="bibdata">

			<a href="{hld:su[1]}" target="_new">
				<xsl:choose>
					<xsl:when test="hld:s3">
						<xsl:value-of select="hld:s3" disable-output-escaping="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="hld:su[1]" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<br/>
			<xsl:value-of select="hld:sz" disable-output-escaping="no"/>
		</dd>
	</xsl:template>
	
</xsl:stylesheet>