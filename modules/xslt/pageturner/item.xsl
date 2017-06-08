<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="tei lh" extension-element-prefixes="xdmp" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xdmp="http://marklogic.com/xdmp" xmlns:lh="http://www.marklogic.com/ps/lib/l-highlight" xmlns:lq="http://www.marklogic.com/ps/lib/l-query" xmlns:cts="http://marklogic.com/cts" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="tei2HTML.xsl"/>
	<xdmp:import-module namespace="http://www.marklogic.com/ps/lib/l-highlight" href="/nlc/lib/l-highlight.xqy"/>
	
	<!--input is local pageTurner output is xhtml-->


	<xsl:include href="utils.xsl"/>	
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	
	<!-- for compactDisc (add newCompactDisc, recordedevent), transcript of part of item-->
	<!-- item level is single track or part of object (tei document or transcript part, in the case of tohap)-->

	<xsl:template match="/" as="item()*">
		<xsl:variable name="item-title">
			<xsl:for-each select="//relatedItem[@ID=$itemID]">
				<xsl:value-of select="element[@label='Title']" disable-output-escaping="no"/>
			</xsl:for-each>
		</xsl:variable>			
			
		<xsl:variable name="textDoc" select="/pageTurner/pages/page[audio/@id=$itemID]/transcript/content"/>			
		<div id="ds-bibrecord">
			<h1 id="title-top"><xsl:value-of select="$item-title" disable-output-escaping="no"/>
			</h1>
			<h2> From:  <a href="default.html"><xsl:value-of select="$title" disable-output-escaping="no"/></a></h2>						
			<dl class="full">
				<!-- show bib elements -->
				<xsl:apply-templates select="//relatedItem[@ID=$itemID]"/>																												 				
				<xsl:apply-templates select="lh:tei-highlight($textDoc/tei:TEI)"/>							
			</dl>
			<!-- end ds-bibrecord-->	</div>
      					
	</xsl:template>
	
	<xsl:template match="relatedItem[not(@type)]" as="item()*">
		<!--see also items, title and url-->		
		<xsl:apply-templates select="child::node()"/>
	</xsl:template>
	
</xsl:stylesheet>