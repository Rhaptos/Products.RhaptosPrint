<?xml version= "1.0"?>
<!--
    Transform BibTeXML in CNXML to bibtex files for PDF generation.

    Author: Brent Hendricks, Adan Galvan
    (C) 2003 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:cnx="http://cnx.rice.edu/cnxml"
		xmlns:qml="http://cnx.rice.edu/qml/1.0"
		xmlns:m="http://www.w3.org/1998/Math/MathML">

  <xsl:template match="qml:item">
    <xsl:variable name="instructions">
      <xsl:choose>
        <xsl:when test="@type='single-response'">select one</xsl:when>
        <xsl:when test="@type='multiple-response' or @type='ordered-response'">
          <xsl:text>select all that apply</xsl:text>
          <xsl:if test="@type='ordered-response'">
            <xsl:text>, in order</xsl:text>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="parent::qml:problemset">
      \par\noindent
      \label{<xsl:call-template name="make-label"><xsl:with-param name="instring" select="@id" /></xsl:call-template>}
      <xsl:text>\noindent\textbf{Problem </xsl:text>
      <xsl:value-of select="@number" />
      <xsl:text>: }</xsl:text>
      <xsl:value-of select="qml:question/cnx:section/cnx:name | qml:question/cnx:section/cnx:title"/>
      <xsl:call-template name="end-label"/>
    </xsl:if>
    <xsl:apply-templates select="qml:question/cnx:section/node()[not(self::cnx:name or self::cnx:title)]"/>
    <xsl:if test="string-length($instructions) and qml:answer">
      <xsl:text> {\small \textsl{(</xsl:text><xsl:value-of select="$instructions"/><xsl:text>)}}
      </xsl:text>
    </xsl:if>
    \begin{definition}
    <xsl:if test="@type!='text-response'">
      <xsl:apply-templates select="qml:answer"/>
    </xsl:if>
    <xsl:if test="qml:hint">
      <xsl:variable name="plural"><xsl:if test="count(qml:hint) &gt; 1">s</xsl:if>
      </xsl:variable>
      <xsl:text>\par\nopagebreak\noindent {\small \textsl{ See hint</xsl:text><xsl:value-of select="$plural"/><xsl:text> in footnote</xsl:text><xsl:value-of select="$plural"/><xsl:text>}}</xsl:text>
      <xsl:apply-templates select="qml:hint"/>
    </xsl:if>
    \end{definition}
  </xsl:template>
  


  <xsl:template match="qml:problemset/qml:answer">
  </xsl:template>


  <xsl:template match="qml:answer">
    \par
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="qml:response">
    <xsl:value-of select="../@number" />
    <xsl:apply-templates />
  </xsl:template>  


  <xsl:template match="qml:hint">
    <xsl:text>\footnote{</xsl:text><xsl:apply-templates /><xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="qml:feedback"></xsl:template>

  <xsl:template match="*[self::solutions or self::solution-group]//qml:answer/qml:feedback">
    <xsl:text> \par\noindent\begingroup\leftskip=20pt\rightskip=\leftskip
    </xsl:text>
    <xsl:text>\textsl{(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)} \par\endgroup
    </xsl:text>
  </xsl:template>

  <xsl:template match="*[self::solutions or self::solution-group]//qml:answers/qml:feedback">
    <xsl:text> \par\noindent
    </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\par
    </xsl:text>
  </xsl:template>

  <!-- Not called from anywhere, so far as I can tell. -->
  <xsl:template match="qml:key">
    <xsl:call-template name="solution" />
  </xsl:template>

  <!-- Called only from template matching 'qml:key'. -->
  <xsl:template name="solution">
    <xsl:choose>
      <xsl:when test="parent::*[@type='text-response']">
      </xsl:when>
      <xsl:when test="parent::*[@type='single-response']">
	<xsl:variable name="answer" select="@answer"/>
	<xsl:number
	  value="count(../qml:answer[following-sibling::qml:answer[@id=$answer]])+1"
	  format=" a) "/>
	<xsl:value-of select="../qml:answer[@id=$answer]/qml:response" /> 
	<xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="parent::*[@type='multiple-response']|parent::*[@type='ordered-response']">

	<xsl:call-template name="loop-through-answers"/>

      </xsl:when> 
      <xsl:otherwise>
	Stylesheet ERROR. Did not match a type of QML item in qml.xsl.
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="../qml:feedback"/>
  </xsl:template>

  <!-- Called only from 'solution' named template. -->
  <xsl:template name="loop-through-answers">
    <xsl:param name="answer-string" select="@answer"/>
    <xsl:param name="order-num" select="1"/>
    <xsl:if test="parent::*[@type='ordered-response']">
      <xsl:text> </xsl:text>
      <xsl:value-of select="$order-num"/>- 
    </xsl:if>
    <xsl:choose>
      <xsl:when test="contains($answer-string,',')">
	<xsl:call-template name="print-answer">
	  <xsl:with-param name="answer-string"
	  select="substring-before($answer-string, ',')"/>
	</xsl:call-template>
	<xsl:call-template name="loop-through-answers">
	  <xsl:with-param name="answer-string"
	  select="substring-after($answer-string, ',')"/>
	  <xsl:with-param name="order-num" select="$order-num + 1"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="print-answer">
	  <xsl:with-param name="answer-string" select="$answer-string"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- Called only from 'loop-through-answers' named template. -->
  <xsl:template name="print-answer">
    <xsl:param name="answer-string" />

    <xsl:number
        value="count(../qml:answer[following-sibling::qml:answer[@id=$answer-string]])+1"
        format=" a) "/>
    <xsl:value-of select="../qml:answer[@id=$answer-string]/qml:response" />
  </xsl:template> 
  
  <!-- Used to determine if a paragraph should be ended, depending on whether the first node with visible output is a block list -->
  <!-- Called only from template matching 'qml:problemset/qml:item'. -->
  <xsl:template name="end-label">
    <xsl:param name="context-node" select="."/>
    <xsl:variable name="first-child" select="$context-node/node()[normalize-space()][not(self::cnx:name or self::cnx:title or self::cnx:label)][1]"/>
    <xsl:choose>
      <xsl:when test="$first-child[(self::cnx:list and not(@type='inline' or @display='inline'))]">
      </xsl:when>
      <!-- Recur on first child if a possible ancestor of list, block code, or block preformat -->
      <xsl:when test="$first-child[self::cnx:para or self::cnx:div or self::cnx:section or self::cnx:example or self::cnx:problem or self::cnx:solution or self::cnx:quote[@display='block'] or self::cnx:footnote or self::cnx:note[@display='block'] or self::cnx:item[parent::cnx:list[@display='block']] or self::cnx:longdesc or self::*[parent::cnx:media] or self::cnx:text or self::cnx:commentary or self::cnx:meaning]">
        <xsl:call-template name="end-label">
          <xsl:with-param name="context-node" select="$first-child"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\par\nopagebreak\noindent{}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>






