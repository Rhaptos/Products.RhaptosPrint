<?xml version="1.0"?>
<!--
    Format solutions, hints, and other appurtenances to exercise and 
    QML problem elements.

    Author: Chuck Bearden
    (C) 2006-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cnx="http://cnx.rice.edu/cnxml"
  xmlns:cnx-context="http://cnx.rice.edu/contexts#"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:ind="index" 
  xmlns:glo="glossary"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="str"
>

  <xsl:output indent="yes" method="xml" encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>

  <!-- Awful hack to get around our brain-dead escaping of LaTeX special 
       characters: change underscores to hyphens.  I do this because it 
       might handy for debugging purposes to have processing instructions 
       that we pay attention to in all the XML stages. -->
  <xsl:template match="processing-instruction('solution_in_back')">
    <xsl:processing-instruction name="solution-in-back"/>
  </xsl:template>

  <xsl:template name="output-solution">
    <xsl:param name="mode"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$mode='solutions'">
        <xsl:attribute name="ref">
          <xsl:value-of select="ancestor::cnx:exercise[1]/@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="count(parent::*/cnx:solution) &gt; 1">
        <xsl:attribute name="number">
          <xsl:number from="cnx:exercise" format="A"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$mode='solutions'">
          <xsl:apply-templates mode="solutions"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cnx:solution">
    <xsl:choose>
      <xsl:when test="@print-placement='here'">
        <xsl:call-template name="output-solution"/>
      </xsl:when>
      <!-- This case enables authors to override exercise/@print-placement with solution/@print-placement. -->
      <xsl:when test="@print-placement='end'"></xsl:when>
      <xsl:when test="parent::cnx:exercise[@print-placement='here']">
        <xsl:call-template name="output-solution"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:example//cnx:solution">
    <xsl:choose>
      <xsl:when test="@print-placement='end'">
      </xsl:when>
      <!-- This case enables authors to override exercise/@print-placement with solution/@print-placement. -->
      <xsl:when test="@print-placement='here'">
        <xsl:call-template name="output-solution"/>
      </xsl:when>
      <xsl:when test="parent::cnx:exercise[@print-placement='end'] or parent::cnx:exercise/processing-instruction('solution_in_back')"></xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="output-solution"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="qml:answer">
    <xsl:copy>
      <xsl:attribute name="number">
        <xsl:number count="qml:answer" from="qml:item" format=" a) "/>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Chapters in collections: put solutions to exercises in section at end 
       if present -->
  <xsl:template match="*[@cnx-context:class='chapter']|/module/cnx:document/cnx:content">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <solutions>
        <xsl:apply-templates select="descendant::cnx:solution|descendant::qml:item" mode="solutions"/>
      </solutions>
    </xsl:copy>
  </xsl:template>

<!-- QML handling for {single,multiple,ordered}-response items
     - print all numbered answers with the question;
     - print correct answer(s) and feedback(s) in relevant solutions section, or with the question';
       - test qml:key to ensure that it refers to at least one extant answer @id;
     - for ordered-response with multiple parts, add '(in that order)'; 
   -->

  <xsl:template match="*[local-name()='document'][@class='assessment']" mode="solutions">
    <solutions-group moduleid="{@id}">
      <xsl:copy-of select="*[local-name()='name' or local-name()='title']"/>
      <xsl:apply-templates select="descendant::cnx:solution|descendant::qml:item" mode="solutions"/>
    </solutions-group>
  </xsl:template>

  <xsl:template match="cnx:solution" mode="solutions">
    <xsl:choose>
      <xsl:when test="@print-placement='here'"></xsl:when>
      <!-- This case enables authors to override exercise/@print-placement with solution/@print-placement. -->
      <xsl:when test="@print-placement='end'">
        <xsl:call-template name="output-solution">
          <xsl:with-param name="mode" select="'solutions'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="parent::cnx:exercise[@print-placement='here']"></xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="output-solution">
          <xsl:with-param name="mode" select="'solutions'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:example//cnx:solution" mode="solutions">
    <xsl:choose>
      <xsl:when test="@print-placement='end'">
        <xsl:call-template name="output-solution">
          <xsl:with-param name="mode" select="'solutions'"/>
        </xsl:call-template>
      </xsl:when>
      <!-- This case enables authors to override exercise/@print-placement with solution/@print-placement. -->
      <xsl:when test="@print-placement='here'"></xsl:when>
      <xsl:when test="parent::cnx:exercise[@print-placement='end'] or parent::cnx:exercise/processing-instruction('solution_in_back')">
        <xsl:call-template name="output-solution">
          <xsl:with-param name="mode" select="'solutions'"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- If this item has answers whose @id values appear in the key, put them in the solutions section. -->
  <xsl:template match="qml:item" mode="solutions">
    <xsl:variable name="key-values" select="str:tokenize(normalize-space(qml:key/@answer), ',')"/>
    <xsl:if test="count($key-values) or qml:feedback">
      <xsl:variable name="qml-item" select="self::qml:item"/>
      <qml:answers>
        <xsl:copy-of select="@type"/>
        <xsl:attribute name="ref">
          <xsl:choose>
            <xsl:when test="parent::qml:problemset">
              <xsl:value-of select="@id"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="../@id"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:for-each select="$key-values">
          <xsl:variable name="key-value" select="."/>
          <xsl:apply-templates select="$qml-item/qml:answer[@id=$key-value]" mode="solutions"/>
        </xsl:for-each>
        <xsl:copy-of select="qml:feedback"/>
      </qml:answers>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qml:answer" mode="solutions">
    <xsl:copy>
      <xsl:attribute name="number">
        <xsl:number count="qml:answer" from="qml:item" format=" a) "/>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="solutions">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="solutions"/>
      <xsl:apply-templates mode="solutions"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*" mode="solutions">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()|processing-instruction()" mode="solutions">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
