<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  version="1.0">

  <xsl:output method="text"/>
  
  <!-- This file outputs the col:parameters to be used as args to xsltproc -->
  <xsl:template match="col:parameters/col:param">
        <xsl:value-of select="@name"/>
        <!-- Wrap the value in single quotes so it is treated as a string by xsltproc -->
        <xsl:text> "</xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>"</xsl:text>
        <!-- Print a newline -->
        <xsl:text>
</xsl:text>
  </xsl:template>

  <!-- Recurse -->
  <xsl:template match="@*|node()"> 
    <xsl:apply-templates select="node()"/>
  </xsl:template>
</xsl:stylesheet>