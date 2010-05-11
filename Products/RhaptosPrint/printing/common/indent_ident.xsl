<?xml version="1.0"?>
<!--
    Restructure the module_export_template of a module for module
    PDF generation.

    Author: Chuck Bearden
    (C) 2008-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<!-- Adds @id's and puts module-export-template metadata into a module's document element -->
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

  <xsl:import href="default-type.xsl"/>
  <xsl:output indent="yes" method="xml"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="cnxml:code"/>

  <xsl:variable name="module-id" select="/module/publishing/objectId"/>

  <xsl:template match="/|*">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/module">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cnxml:document">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="cnxml:name"/>
      <module-export>
        <xsl:copy-of select="/module/title"/>
        <xsl:for-each select="/module/metadata/author">
          <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="/module/metadata/licensor">
          <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="/module/metadata/optionalrole">
          <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:copy-of select="/module/metadata/parent"/>
        <xsl:copy-of select="/module/metadata/license"/>
        <xsl:copy-of select="/module/metadata/language"/>
        <xsl:copy-of select="/module/publishing/version"/>
        <xsl:copy-of select="/module/publishing/revised"/>
        <xsl:copy-of select="/module/publishing/portal"/>
        <xsl:copy-of select="/module/display/base"/>
      </module-export>
      <xsl:apply-templates select="*[not(self::cnxml:name)]"/>
    </xsl:copy>
  </xsl:template>

  <!-- Copy all descendents of cnxml:document. -->
  <xsl:template match="cnxml:document//*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="generate-default-type-if-needed"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Add the module ID to element IDs in order to make references work. -->
  <xsl:template match="cnxml:*/@id|bib:*/@id">
    <xsl:attribute name="id">
      <xsl:value-of select="$module-id"/>
      <xsl:if test="not(parent::cnxml:document)">
        <xsl:text>*</xsl:text>
        <xsl:value-of select="."/>
      </xsl:if>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="cnxml:cnxn/@target">
    <xsl:attribute name="target">
      <xsl:choose>
        <!-- Case 1: If cnxn has a document attribute, concatenate that value 
             with the target attribute. -->
        <xsl:when test="normalize-space(../@document)">
          <xsl:value-of select="normalize-space(../@document)"/>
          <xsl:text>*</xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:when>
        <!-- Case 2: If cnxn does not have a document attribute, concatenate 
             the id of the current document with the target attribute. -->
        <xsl:otherwise>
          <xsl:value-of select="$module-id"/>
          <xsl:text>*</xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="cnxml:cite/@target-id | cnxml:cite/@resource | cnxml:link/@target-id">
    <xsl:choose>
      <xsl:when test="../@resource">
        <xsl:attribute name="resource">
          <xsl:choose>
            <!-- Case 1: If element has a document attribute, concatenate that value 
                 with the target-id attribute. -->
            <xsl:when test="normalize-space(../@document)">
              <xsl:value-of select="normalize-space(../@document)"/>
              <xsl:text>*</xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <!-- Case 2: If element does not have a document attribute, concatenate 
                 the id of the current document with the target-id attribute. -->
            <xsl:otherwise>
              <xsl:value-of select="$module-id"/>
              <xsl:text>*</xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="target-id">
          <xsl:choose>
            <!-- Case 1: If element has a document attribute, concatenate that value 
                 with the target-id attribute. -->
            <xsl:when test="normalize-space(../@document)">
              <xsl:value-of select="normalize-space(../@document)"/>
              <xsl:text>*</xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <!-- Case 2: If element does not have a document attribute, concatenate 
                 the id of the current document with the target-id attribute. -->
            <xsl:otherwise>
              <xsl:value-of select="$module-id"/>
              <xsl:text>*</xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Ignore text not under cnxml:document. -->
  <xsl:template match="text()"/>

  <xsl:template match="cnxml:document//text()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="@*|comment()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
