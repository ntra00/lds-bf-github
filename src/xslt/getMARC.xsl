<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" version="1.0" encoding="UTF-8" omit-xml-declaration="yes"/>

<!-- identity template without namespace nodes -->
<xsl:template match="//db |//SQL"/>
<xsl:template match="//MARC_RECORD">
    <xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>