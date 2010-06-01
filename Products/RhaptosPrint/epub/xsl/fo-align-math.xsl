<?xml version="1.0" ?>
<!-- 
	pmml2svg provides a baseline-shift element so we can position the graphic correctly
	(Sometimes the math extends below the baseline of text, if the math is inline)
	At this point we correct for it.
 -->
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  >

<xsl:output indent="yes" method="xml"/>
<xsl:include href="debug.xsl"/>
<xsl:include href="ident.xsl"/>

<!-- Move the image up or down according to its baseline -->
<xsl:template match="fo:instream-foreign-object[svg:svg/svg:metadata/pmml2svg:baseline-shift]">
	<xsl:copy>
		<xsl:attribute name="alignment-adjust">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="svg:svg/svg:metadata/pmml2svg:baseline-shift/text()"/>
			<xsl:text>px</xsl:text>
		</xsl:attribute>
		<xsl:apply-templates select="@*|svg:svg"/>
	</xsl:copy>
</xsl:template>

<!-- Hack to dump negative-width SVG elements -->
<xsl:template match="fo:instream-foreign-object[svg:svg[starts-with(@width, '-')]]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Negative width SVG element. Stripping for now</xsl:with-param></xsl:call-template>
</xsl:template>

</xsl:stylesheet>
