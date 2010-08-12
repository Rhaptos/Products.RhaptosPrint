<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file converts dbk files to chunked html which is used in the offline HTML zip file.
    * Modifies links to be localized for offline zip file
 -->
<xsl:import href="dbk2epub.xsl"/>


<xsl:template match="db:imagedata[mml:*]">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Outputting MathML instead of the image</xsl:with-param></xsl:call-template>
    <xsl:copy-of select="mml:*"/>
</xsl:template>
</xsl:stylesheet>