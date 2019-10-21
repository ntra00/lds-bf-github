<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<!-- xmlns:xinclude="http://www.w3.org/TR/xinclude/" -->
<xsl:template match="/">
<xsl:variable name="image"><xsl:value-of select="//image[1]/@href"/></xsl:variable>
<xsl:variable name="thumb"><xsl:value-of select="concat(substring-before($image,'v.jpg'), 'h.jpg')"/></xsl:variable>
<html>
      <body>
	<img src="{$thumb}"/>
      </body>
    </html>
<!-- <xinclude:include src="{$thumb}"/> -->
<!-- <xsl:value-of select="$thumb"/> -->
</xsl:template>

</xsl:stylesheet>