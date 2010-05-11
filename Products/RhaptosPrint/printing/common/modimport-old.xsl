<?xml version= "1.0"?>
<!--
    Format CNXML < 0.5 when generating collection or module PDFs.

    Author: Brent Hendricks and Adan Galvan
    (C) 2005 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:cnx04="http://cnx.rice.edu/cnxml/0.4"
		xmlns:cnx035="http://cnx.rice.edu/cnxml/0.3.5"
                xmlns:cnx03="http://cnx.rice.edu/cnxml/0.3"
		xmlns:cnxml="http://cnx.rice.edu/cnxml"
		xmlns:qml="http://cnx.rice.edu/qml/1.0"
		xmlns:mdml="http://cnx.rice.edu/mdml/0.4">

  <!-- For module, we copy authors, keywords, and content.  That's it -->
  <xsl:template match="cnx04:module|cnx035:module|cnx03:module">
    <xsl:apply-templates select="//mdml:author|//cnx035:author|//cnx03:author"/>
    <xsl:apply-templates select="//mdml:keyword|//cnx035:keyword|//cnx03:keyword"/>
    <xsl:apply-templates select="cnx04:content|cnx035:content|cnx03:*[not(self::cnx03:module or self::cnx03:authorlist or self::cnx03:maintainerlist or self::cnx03:keywordlist or self::cnx03:abstract or self::cnx03:name)]"/>
  </xsl:template>

  <!-- Concatenate the IDs:
       The id of each elements is concatenated with the module id to
       make it unique within the course. The two ids are separated by an * -->
  <xsl:template match="cnx04:*/@id|cnx035:*/@id|cnx03:*/@id|qml:*/@id">
    <xsl:attribute name="id">
      <xsl:value-of select="ancestor::cnx04:module/@id|ancestor::cnx035:module/@id|ancestor::cnx03:module/@id"/>*<xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- And since the ids are concatenated, the 'target' attribute must be modified to refect this -->
  <xsl:template match="cnx04:cnxn/@target|cnx035:cnxn/@target|cnx03:cnxn/@target">
    <xsl:attribute name="target">
      <xsl:choose>
	<!--Case 1: If cnxn has a module attribute, concatenate that value with the target attribute.-->
	<xsl:when test="../@module">
	  <xsl:value-of select="../@module"/>*<xsl:value-of select="."/>
	</xsl:when>
	<!--Case 2: If cnxn does not have a module attribute, concatenate the id of the current module with the target
	    attribute.-->
	<xsl:otherwise>
	  <xsl:value-of select="ancestor::cnx04:module/@id|ancestor::cnx035:module/@id|ancestor::cnx03:module/@id"/>*<xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!-- Turn module attribute into document -->
  <xsl:template match="cnx04:cnxn/@module|cnx035:cnxn/@module|cnx03:cnxn/@module">
    <xsl:attribute name="document">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- Transform to common author format -->
  <xsl:template match="mdml:author|cnx035:author|cnx03:author">
    <author id="{@id}">
      <firstname><xsl:value-of select="mdml:firstname|cnx035:firstname|cnx03:firstname"/></firstname>
      <surname><xsl:value-of select="mdml:surname|cnx035:surname|cnx03:surname"/></surname>
    </author>
  </xsl:template>

  <!-- Transform to common keyword format -->
  <xsl:template match="mdml:keyword|cnx035:keyword|cnx03:keyword">
    <keyword><xsl:value-of select="."/></keyword>
  </xsl:template>

  <!-- Grab the content -->
  <xsl:template match="cnx04:content|cnx035:content|cnx03:*[not(self::cnx03:module or ancestor-or-self::cnx03:authorlist  or ancestor-or-self::cnx03:maintainerlist or ancestor-or-self::cnx03:keywordlist or self::cnx03:abstract or self::cnx03:name)]">
    <cnxml:content>
      <xsl:apply-templates />
    </cnxml:content>
  </xsl:template>

  <!-- Default copying rule for attributes -->
  <xsl:template match="cnx04:*/@*|cnx035:*/@*|cnx03:*/@*">
    <xsl:attribute name="{local-name()}"><xsl:value-of select="." /></xsl:attribute>
  </xsl:template>

  <!-- Transform cnxml tags to new namespace -->
  <xsl:template match="cnx04:content//cnx04:*|cnx035:content//cnx035:*|cnx03:*[not(self::cnx03:module or ancestor-or-self::cnx03:authorlist or ancestor-or-self::cnx03:maintainerlist or ancestor-or-self::cnx03:keywordlist or self::cnx03:abstract or self::cnx03:name)]">
    <xsl:element name="{local-name()}" 
		 namespace="http://cnx.rice.edu/cnxml">
      <!-- Must copy the attributes first and separately, so that the
      templates for 'id' and 'target' are guaranteed to match *before*
      we've copied over any children (See XSLT spec 7.1.3 and and
      Michael Kay's XSLT ref. p 167 for rationale) -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
