<?xml version= "1.0" standalone="yes"?>
<!--
    Try given number of times to retrieve the resource at the given URL,\
    with option to error fatally on failure.

    Author: Chuck Bearden and Ross Reedstrom
    (C) 2008-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="get-doc">
  <xsl:param name="docuri"/>
  <xsl:param name="count" select="0"/>
  <xsl:param name="failonerror" select="0"/>
  <xsl:choose>
    <xsl:when test="$count = 3">
      <xsl:choose>
        <xsl:when test="$failonerror">
          <xsl:processing-instruction name="abort-pdf">
            <xsl:text>Failed to get '</xsl:text>
            <xsl:value-of select="$docuri"/>
            <xsl:text>' </xsl:text>
          </xsl:processing-instruction>
          <xsl:message>Failed to got <xsl:value-of select="$docuri"/></xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Failed to get <xsl:value-of select="$docuri"/> continuing ...</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="my-doc" select="document($docuri)"/>
      <xsl:choose>
        <xsl:when test="not($my-doc)">
          <!-- try again -->
          <xsl:message>Retrying ...</xsl:message>
          <xsl:call-template name="get-doc">
            <xsl:with-param name="docuri" select="$docuri"/>
            <xsl:with-param name="count" select="$count+1"/>
            <xsl:with-param name="failonerror" select="$failonerror"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <!-- return the result tree fragment -->
          <xsl:copy-of select="$my-doc"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
</xsl:stylesheet>
  
