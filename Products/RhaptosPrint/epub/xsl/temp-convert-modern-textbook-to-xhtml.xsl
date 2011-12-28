<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="xsl:attribute-set">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:element name="xsl:attribute">
      <xsl:attribute name="name">
        <xsl:text>style</xsl:text>
      </xsl:attribute>
      <xsl:if test="@use-attribute-sets">
        <xsl:variable name="name" select="@use-attribute-sets"/>
        <xsl:apply-templates mode="style" select="../xsl:attribute-set[@name=$name]/xsl:attribute"/>
      </xsl:if>
      <xsl:apply-templates mode="style" select="xsl:attribute"/>
    </xsl:element>
    <xsl:apply-templates select="node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template mode="style" match="xsl:attribute">
  <xsl:value-of select="@name"/>
  <xsl:text>: </xsl:text>
  <xsl:copy-of select="node()"/>
  <xsl:text>; </xsl:text>
</xsl:template>

<xsl:template match="fo:wrapper|fo:block">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="fo:inline">
  <span>
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

<xsl:template match="xsl:import[@href='dbk2fo.xsl']/@href">
  <xsl:attribute name="href">
    <xsl:text>dbk2epub.xsl</xsl:text>
  </xsl:attribute>
</xsl:template>

<xsl:template mode="style" match="xsl:attribute[@name='border-bottom-width']">
  <xsl:text>border-bottom: </xsl:text>
  <xsl:copy-of select="../xsl:attribute[@name='border-bottom-width']/node()"/>
  <xsl:text> </xsl:text>
  <xsl:copy-of select="../xsl:attribute[@name='border-bottom-style']/node()"/>
  <xsl:text> </xsl:text>
  <xsl:copy-of select="../xsl:attribute[@name='border-bottom-color']/node()"/>
  <xsl:text>;</xsl:text>
</xsl:template>

<xsl:template match="xsl:template[@name='process.image']"/>

<xsl:template match="fo:basic-link[@internal-destination]">
  <a href="#{@internal-destination}">
    <xsl:apply-templates select="node()"/>
  </a>
</xsl:template>

<xsl:template match="fo:table">
  <table>
    <xsl:apply-templates select="node()"/>
  </table>
</xsl:template>

<xsl:template match="fo:table-row">
  <tr>
    <xsl:apply-templates select="node()"/>
  </tr>
</xsl:template>

<xsl:template match="fo:table-cell">
  <td>
    <xsl:apply-templates select="node()"/>
  </td>
</xsl:template>

<xsl:template match="fo:table-header|fo:table-body">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="xsl:param[not(following-sibling::xsl:param)]">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
  <xsl:element name="xsl:param">
    <xsl:attribute name="name">
      <xsl:text>cnx.font.catchall</xsl:text>
    </xsl:attribute>
    <xsl:apply-templates select="node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="fo:page-number">
  <xsl:text>PGNUM</xsl:text>
</xsl:template>

<xsl:template match="fo:marker">
  <a name="{normalize-space(text())}"/>
</xsl:template>

<xsl:template match="fo:*">
  <xsl:message>Skipping fo:<xsl:value-of select="local-name()"/></xsl:message>
</xsl:template>

<!--
<xsl:param name="cnx.font.catchall">serif,STIXGeneral,STIXSize</xsl:param>

<xsl:template name="select.pagemaster">
  <xsl:text>body</xsl:text>
</xsl:template>
<xsl:template name="page.sequence">
  <xsl:param name="content"/>
  <xsl:copy-of select="$content"/>
</xsl:template>
-->

</xsl:stylesheet>

