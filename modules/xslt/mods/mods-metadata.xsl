<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mods mets xlink" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mets="http://www.loc.gov/mets" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	
	<!--input is local <pageTurner>, output is xhtml-->
	<!-- called by modsbibrecords for lcwa display etc (NKSIP?)-->
	<xsl:include href="../pageturner/utils.xsl"/>
	<xsl:include href="../pageturner/navbar.xsl"/>
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

	<xsl:template match="/" as="item()*">
		<xsl:variable name="uri">
			<xsl:value-of select="descriptive/digitalID" disable-output-escaping="no"/>
		</xsl:variable>
	
	<!-- let $imagepath := 
		if ( matches($uri,"lcwa") and exists($illustrative) ) then
			<img src="{replace($illustrative,'lcwa','mrva')}/200" alt="thumbnail" />			
	    else if (matches($objectType,"(bibRecord|modsBibRecord)") and exists($illustrative)) then
	        <img src="{$illustrative}/200" alt="thumbnail" /> 	  	        
			else 
			()
	 -->	<!-- <xsl:variable name="imagePath">
			<xsl:choose>
				<xsl:when test="contains($uri,'lcwa') and $illustrative!=''">
					<img src="{replace($illustrative,'lcwa','mrva')}/200" alt="thumbnail" />			
					
				</xsl:when>
				<xsl:when test="matches($objectType,'(bibRecord|modsBibRecord)') and exists($illustrative)">
<img src="{$illustrative}/200" alt="thumbnail" /> 	  	        
</xsl:when>
				
			</xsl:choose>
			
		</xsl:variable> -->
		<div id="ds-bibrecord">
			<xsl:for-each select="descriptive/span">
				<span style="visibility: hidden;">
					<xsl:attribute name="id">
						<xsl:value-of select="@id" disable-output-escaping="no"/>
					</xsl:attribute>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</span>
			</xsl:for-each>
			<br/>
			<abbr title="{normalize-space($uri)}" class="unapi-id"></abbr>
			<!-- <img src="{$imagePath}" alt="thumbnail"/> -->
			<h1 id="title-top">
				<xsl:choose>
					<xsl:when test="descriptive/pagetitle/@dir='rtl'">
						<span dir="rtl" style="float:right;">
							<xsl:value-of select="descriptive/pagetitle" disable-output-escaping="no"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="descriptive/pagetitle" disable-output-escaping="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</h1>
			<xsl:apply-templates select="//full"/>

			<xsl:apply-templates select="descriptive/contains"/>
			<xsl:copy-of select="//metatags"/>
			<!-- ds-bibrecord" -->
			
		</div>
		<!--bibrecord-->
	</xsl:template>

	<xsl:template match="full" as="item()*">
		<dl class="record">
			<xsl:copy-of select="span[@id='objectType']" copy-namespaces="yes"/>
			<xsl:apply-templates select="element"/>
		</dl>
	</xsl:template>
	<xsl:template match="contains" as="item()*">
		<ul class="mktree">
			<li>
				<strong>
					<xsl:value-of select="element[1]/label" disable-output-escaping="no"/>
				</strong>
				<ul>
					<xsl:apply-templates select="element" mode="tree"/>
				</ul>
			</li>
		</ul>
	</xsl:template>

	<xsl:template match="element" mode="tree" as="item()*">
		<li>

			<xsl:choose>
				<xsl:when test="value/a">
					<xsl:apply-templates select="value/a"/>
				</xsl:when>
				<xsl:when test="value/href">
					<xsl:apply-templates select="value/href"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="value" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="element">
				<ul>
					<xsl:apply-templates select="element" mode="tree"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template match="element" as="item()*">
		<dt class="label">
			<xsl:value-of select="label" disable-output-escaping="no"/>
			<xsl:value-of select="@pluralLabel" disable-output-escaping="no"/>
		</dt>
		<xsl:choose>
			<xsl:when test="count(value) &lt; 15 and not(value/@dir='rtl')">
				<!--dont' group arabic w/english-->
				<xsl:for-each select="value">
					<xsl:variable name="val">
						<xsl:choose>
							<!-- allow search string instead of just text: notes, genre, subjects -->
							<!-- <xsl:when test="(starts-with(../@label,'Subject') or ../@label='Genre') and a"> -->
							<xsl:when test="a">
								<xsl:apply-templates select="a"/>
								<br/>
							</xsl:when>
							<xsl:when test="href">
								<xsl:apply-templates select="href"/>
								<br/>
							</xsl:when>
							<xsl:when test="normalize-space(.)=''">
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<dd class="bibdata">
						<xsl:choose>
							<xsl:when test="@dir='rtl'">
								<span dir="rtl">
									<xsl:copy-of select="$val" copy-namespaces="yes"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="$val" copy-namespaces="yes"/>
							</xsl:otherwise>
						</xsl:choose>
					</dd>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<dd class="bibdata">
					<xsl:for-each select="value">
						<xsl:variable name="this-value">
							<xsl:choose>
								<xsl:when test="a">
									<xsl:apply-templates select="a"/>
									<br/>
								</xsl:when>
								<xsl:when test="href">
									<xsl:apply-templates select="href"/>
									<br/>
								</xsl:when>
								<xsl:when test="normalize-space(.)=''">
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(.)" disable-output-escaping="no"/>
									<xsl:if test="not(@dir='rtl')">;</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="@dir='rtl'">
								<span dir="rtl" style="float:right;">
									<xsl:copy-of select="$this-value" copy-namespaces="yes"/>
								</span>
								<br clear="all"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="$this-value" copy-namespaces="yes"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</dd>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="a" as="item()*">
		<a href="{@href}">
			<xsl:value-of select="." disable-output-escaping="no"/>
		</a>
	</xsl:template>
	<xsl:template match="href" as="item()*">
		<a href="{url}">
			<xsl:value-of select="text()" disable-output-escaping="no"/>
		</a>
	</xsl:template>
</xsl:stylesheet>
