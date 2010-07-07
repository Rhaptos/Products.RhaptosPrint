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
	<xsl:variable name="url">
		<xsl:choose>
			<xsl:when test="starts-with(@url, 'http://foo/')">
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Found md:derived-from with a url that starts with 'http://foo/'</xsl:with-param></xsl:call-template>
				<xsl:value-of select="$cnx.url"/>
				<xsl:value-of select="substring-after(@url, '/content/')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@url"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>/</xsl:text>
	</xsl:variable>
	<xsl:variable name="urlSource">
		<xsl:value-of select="$url"/>
		<xsl:text>source</xsl:text>
	</xsl:variable>
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: NET: XIncluding md:derived-from url '<xsl:value-of select="$urlSource"/>'</xsl:with-param></xsl:call-template>
	<xsl:copy>
		<xsl:attribute name="url">
			<xsl:value-of select="$url"/>
		</xsl:attribute>
		<xi:include href="{$urlSource}"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
