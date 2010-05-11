<?xml version="1.0"?>
<!--
    Add default value for @type to elements in modules where required.

    Author: Chuck Bearden
    (C) 2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dt="#default-type"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
>

  <dt:default-types>
    <dt:element name="link-group"/>
    <dt:element name="section"/>
    <dt:element name="quote"/>
    <dt:element name="equation"/>
    <dt:element name="note"/>
    <dt:element name="list"/>
    <dt:element name="code"/>
    <dt:element name="figure"/>
    <dt:element name="subfigure"/>
    <dt:element name="example"/>
    <dt:element name="exercise"/>
    <dt:element name="problem"/>
    <dt:element name="solution"/>
    <dt:element name="commentary"/>
    <dt:element name="definition"/>
    <dt:element name="seealso"/>
    <dt:element name="rule"/>
    <dt:element name="statement"/>
    <dt:element name="proof"/>
    <dt:element name="table"/>
  </dt:default-types>

  <xsl:variable name="need-default-types" select="document('')/xsl:stylesheet/dt:default-types"/>

  <xsl:template name="generate-default-type-if-needed">
    <xsl:variable name="local-name" select="local-name()"/>
    <xsl:if test="$need-default-types/dt:element[@name=$local-name] and not(@type)">
      <xsl:attribute name="type"><xsl:value-of select="local-name()"/></xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="generate-default-type-debug">
    <xsl:variable name="local-name" select="local-name()"/>
    <xsl:comment>
      local-name: '<xsl:value-of select="$local-name"/>'
      type: '<xsl:value-of select="@type"/>'
      need-default-types: '<xsl:value-of select="$need-default-types/dt:element[@name=$local-name]/@name"/>'
      need-default-types ct: '<xsl:value-of select="count($need-default-types/dt:element[@name='rule'])"/>'
      need-default-types ot: '<xsl:value-of select="exsl:object-type($need-default-types)"/>'
    </xsl:comment>
  </xsl:template>

</xsl:stylesheet>