<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:xi='http://www.w3.org/2001/XInclude'
  exclude-result-prefixes="col md"
  >
<xsl:include href="debug.xsl"/>
<xsl:include href="ident.xsl"/>


<xsl:template match="md:derived-from">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Converting md:derived-from title and authors</xsl:with-param></xsl:call-template>
    <xsl:if test="not(metadata)">
      <xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: md:metadata (cnxml0.6+) not found. The derived-from information may not have authors in it</xsl:with-param></xsl:call-template>
    </xsl:if>
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
	    <xsl:apply-templates select="metadata/node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
