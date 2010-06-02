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

<!-- Overloading the file to add glossary metadata -->
<xsl:template match="db:glossentry">
	<!-- Find the 1st character. Used later in the transform to generate a glossary alphbetically -->
	<xsl:variable name="letters">
		<xsl:apply-templates mode="glossaryletters" select="db:glossterm/node()"/>
	</xsl:variable>
	<xsl:variable name="firstLetter" select="translate(substring(normalize-space($letters),1,1),'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: firstLetter="<xsl:value-of select="$firstLetter"/>" of "<xsl:value-of select="normalize-space($letters)"/>"</xsl:with-param></xsl:call-template>
	<db:glossentry _first-letter="{$firstLetter}">
		<xsl:apply-templates select="@*|node()"/>
	</db:glossentry>
</xsl:template>
<!-- Helper template to recursively find the text in a glossary term -->
<xsl:template mode="glossaryletters" select="*">
	<xsl:apply-templates mode="glossaryletters"/>
</xsl:template>
<xsl:template mode="glossaryletters" select="text()">
	<xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>