<?xml version="1.0"?>

<!--  Takes a collection .tmp1 file as input, and outputs the same 
      with only CALS tables as cnx:content descendants.  Use this to 
      create a new .tmp1 file that will be the input for collection 
      PDF generation for a tables-only collection.  Basically, a 
      strainer for all non-table module contents.  This stylesheet 
      could be the model mutatis mutandis for stylesheets that create 
      other sorts of specialized collections.  -->
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

  <xsl:template match="cnxml:content//node()[not(ancestor-or-self::cnxml:table)]">
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
