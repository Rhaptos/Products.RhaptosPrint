<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
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
<xsl:import href="dbk2html-media.xsl"/>

<!-- Discard the "unsupported media link" and convert the inner c:media element -->
<xsl:template match="db:link[c:media]">
    <xsl:apply-templates select="c:media"/>
</xsl:template>

<xsl:template match="db:link[@ext:resource!='']">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Generating local link to resource</xsl:with-param></xsl:call-template>
    <xsl:variable name="linkend">
        <xsl:if test="$cnx.module.id != ''">
            <!-- If we're generating a collection, include the module dir. -->
            <xsl:value-of select="@ext:document"/>
            <xsl:text>/</xsl:text>
        </xsl:if>
        <xsl:value-of select="@ext:resource"/>
    </xsl:variable>
    <xsl:variable name="content">
        <xsl:value-of select="@ext:resource"/>
    </xsl:variable>

    <xsl:message>linkend=<xsl:value-of select="$linkend"/> content="<xsl:value-of select="$content"/></xsl:message>
    
    <xsl:call-template name="simple.xlink">
	    <xsl:with-param name="node" select="."/>
	    <xsl:with-param name="linkend" select="$linkend"/>
	    <xsl:with-param name="content" select="$content"/>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>