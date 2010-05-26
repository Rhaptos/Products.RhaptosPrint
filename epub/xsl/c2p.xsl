<xsl:stylesheet version="1.0"
xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<!-- 
<xsl:include href="c2p-files/cnxmathmlc2p.xsl"/>
-->
<xsl:include href="c2p-files/mathmlc2p-entities-removed.xsl"/>

<!-- 
  UGLY HACKery. mathmlc2p.xsl creates prefixed elements by using escaping
  (so the prefix isn't really bound to anything)
  So, we force a prefix on the mml:math element.
 -->
<xsl:template match="m:math">
	<m:math>
		<xsl:apply-templates select="*"/>
	</m:math>
</xsl:template>

</xsl:stylesheet>