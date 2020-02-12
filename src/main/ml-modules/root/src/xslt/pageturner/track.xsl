<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xlink" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<!-- for compactDisc (add newCompactDisc, recordedevent)-->
<!--can we use item.xsl instead??? -->
	<xsl:include href="../mods/metadata.xsl"/>
	<xsl:include href="utils.xsl"/>
	<xsl:template match="/" as="item()*">

				<xsl:variable name="item-title">
					<xsl:for-each select="//relatedItem[@ID=$itemID]">
						<xsl:value-of select="element[@label='Title']" disable-output-escaping="no"/>
					</xsl:for-each>
				</xsl:variable>
			
								
		<div id="ds-bibrecord">
			
			<h1 id="title-top"><xsl:value-of select="$item-title" disable-output-escaping="no"/></h1>
				<div id="main_menu_fixed">
					<div id="main_body">					
						<h3>From:  <a href="default.html">
								<xsl:value-of select="$title" disable-output-escaping="no"/>
		      					</a></h3>
					    <dl class="full">
							<!-- show bib elements -->
	      <xsl:apply-templates select="//relatedItem[@ID=$itemID]/*[not(local-name()='relatedItem')]"/>

							</dl>
		</div>
				<!--"main_menu_fixed"-->
			</div>
			<!--main-body-->
<!--bibrecord-->
		</div>
	</xsl:template>
</xsl:stylesheet>