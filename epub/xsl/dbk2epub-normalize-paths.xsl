<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:output indent="yes" method="xml"/>

<!-- Strip 'em for html generation -->
<xsl:template match="@xml:base"/>

<!-- Make image paths point into the module directory -->
<xsl:template match="@fileref">
	<xsl:attribute name="fileref">
		<xsl:value-of select="substring-before(ancestor::db:section[@xml:base]/@xml:base, '/')"/>
                <xsl:text>/</xsl:text>
		<xsl:value-of select="."/>
	</xsl:attribute>
</xsl:template>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>