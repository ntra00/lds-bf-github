<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xdmp="http://marklogic.com/xdmp" xmlns="http://www.w3.org/1999/xhtml">
<!--can we use tei2html instead??? -->
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>



	<xsl:template match="titleStmt/title" as="item()*">
		<h4>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</h4>
	</xsl:template>

	<xsl:template match="div" as="item()*">
		<xsl:copy inherit-namespaces="yes" copy-namespaces="yes"><xsl:attribute name="class">lyrics</xsl:attribute>
			<xsl:apply-templates select="child::node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="p" as="item()*">
		<div>
			<xsl:apply-templates select="child::node()"/>
		</div>
	</xsl:template>


	<xsl:template match="lg" as="item()*">
		<strong>
			<xsl:value-of select="@type" disable-output-escaping="no"/>
		</strong>
		<br/>

		<xsl:apply-templates select="child::node()"/>
	</xsl:template>
	<xsl:template match="l" as="item()*">
		<xsl:apply-templates select="child::node()"/>
		<br/>
		
	</xsl:template>
	<xsl:template match="lb" as="item()*">

		<br/>
	</xsl:template>
	<xsl:template match="emph |foreign | title" as="item()*">
		<em>
			<xsl:apply-templates select="*[not(local-name()='hi')]"/>
		</em>
	</xsl:template>
	<xsl:template match="list" as="item()*">
		<xsl:variable name="listType">
			<xsl:choose>
				<xsl:when test="@type='ordered'">ol</xsl:when>
				<xsl:otherwise>ul</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$listType}" inherit-namespaces="yes">
			<div>
				<xsl:apply-templates select="child::node()"/>
			</div>
		</xsl:element>
	</xsl:template>

	<xsl:template match="pb" as="item()*">
		<xsl:if test="@n !=1">
			<hr noshade="noshade" width=" 50%" align="center"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="hi" as="item()*">
		<xsl:choose>
			<xsl:when test="@rend='italic'">
				<em>
					<xsl:apply-templates select="child::node()"/>
				</em>
			</xsl:when>
			<xsl:when test="@rend='center'">
				<p align="center">
					<xsl:apply-templates select="child::node()"/>
				</p>
			</xsl:when>
			<xsl:when test="@rend='left'">
				<p>
					<xsl:apply-templates select="child::node()"/>
				</p>
			</xsl:when>
			<xsl:when test="@rend='right'">
				<div class="right">
					<xsl:apply-templates select="child::node()"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="child::node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="item" as="item()*">
		<li>
			<xsl:apply-templates select="child::node()"/>
		</li>
	</xsl:template>
	<xsl:template match="table" as="item()*">
		<table summary="data positioning table">
      <!--id="search_result_gallery"-->
			<xsl:apply-templates select="child::node()"/>
		</table>
	</xsl:template>

	<xsl:template match="row" as="item()*">
		<tr>
			<xsl:apply-templates select="child::node()"/>
		</tr>
	</xsl:template>
	<xsl:template match="cell" as="item()*">
		<xsl:variable name="width">
			<xsl:value-of select="round(100 div count(../cell))" disable-output-escaping="no"/>
		</xsl:variable>
		<td width="{$width}" rowspan="1" colspan="1">
			<xsl:apply-templates select="child::node()"/>
		</td>
	</xsl:template>
<xsl:template match="span" as="item()*">
			<xsl:apply-templates select="child::node()"/>

	</xsl:template>
</xsl:stylesheet>