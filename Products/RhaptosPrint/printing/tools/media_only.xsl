<?xml version="1.0"?>

<!-- A semi-identity transform: for child nodes of cnxml:content, it copies 
     only media and figure elements into the result tree; useful for making 
     image-only versions of collections.  All other nodes elsewhere in the 
     input document get copied into the result tree.
     It operates on a Connexions collection XML file, usually at the first 
     stage ('colXXXXX.tmp1'), and outputs a replacement to be used in the 
     collection PDF generation process. It is analogous to the 
     tables_only.xsl stylesheet in the same svn directory. -->
<!--
    Author: Chuck Bearden
    (C) 2008 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cnxml="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:cc="http://web.resource.org/cc/"
  xmlns:cnx="http://cnx.rice.edu/contexts#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
>

  <xsl:output indent="yes" method="xml"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="cnxml:media" priority="1">
    <para>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:copy-of select="."/>
    </para>
  </xsl:template>

  <xsl:template match="cnxml:figure" priority="1">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="cnxml:content//node()">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|text()|comment()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
