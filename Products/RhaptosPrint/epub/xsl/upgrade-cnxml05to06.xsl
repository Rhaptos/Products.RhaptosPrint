<xsl:stylesheet
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:md4="http://cnx.rice.edu/mdml/0.4"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0">

<xsl:include href="ident.xsl"/>
<xsl:include href="cnxml-upgrade/cnxml05to06.xsl"/>

<xsl:template match="c:metadata|md:*|md4:*">
	<xsl:call-template name="ident"/>
</xsl:template>

</xsl:stylesheet>