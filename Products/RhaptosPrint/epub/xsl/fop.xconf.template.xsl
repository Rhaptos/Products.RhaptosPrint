<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="ident.xsl"/>

<xsl:param name="cnx.basepath">DEFAULT_PATH</xsl:param>

<xsl:template match="@embed-url">
  <xsl:attribute name="embed-url">
    <xsl:value-of select="$cnx.basepath"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

</xsl:stylesheet>