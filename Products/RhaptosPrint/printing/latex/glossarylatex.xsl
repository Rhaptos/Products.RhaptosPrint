<?xml version="1.0" encoding="utf-8"?>
<!--
    Format a glossary at the end of the content object.

    Author: Adan Galvan, Chuck Bearden
    (C) 2003-2008 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
  <xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:glo="glossary"
    xmlns:cnx="http://cnx.rice.edu/cnxml">


  <xsl:template match="glo:glossarylist" mode="glossary">
    <!-- this is the control template which decides which templates to call
    next.  it assumes that the ind:item's are already sorted in alphabetical
    order. -->
    \begin{description}\setlength{\topsep}{0cm}\setlength{\itemsep}{0cm}
    \setlength{\parskip}{0cm}\setlength{\parsep}{0cm}
    \setlength{\partopsep}{0cm}
    \setlength{\labelwidth}{.6cm}\setlength{\labelsep}{0cm}
    \setlength{\leftmargin}{1cm}

    <xsl:for-each select="glo:item">
      <!-- <xsl:if test="text()"> -->
	<xsl:choose>
	  <!-- when the first letter of this ind:item does not equal the first
	  letter of the preceding ind:item then.... print out the new letter
	  block, word and page.  -->
	  <xsl:when test="translate(substring(normalize-space(.),1,1),
	    'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
	    !=translate(substring(normalize-space(preceding-sibling::glo:item[1]),1,1),
	    'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')">
	    \vspace{.3cm}
	    \item[<xsl:call-template name="print-letter"/>]\noindent\raggedright
	    {\bf <xsl:value-of select="./glo:term" />}<xsl:call-template name="print-meanings" />
	  </xsl:when>
	  <!-- when this ind:item does not equal the preceding ind:item
	  then.... end the old word block, print out the new word and page --> 
	  <xsl:when test="translate(normalize-space(.),
	    'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
	    !=translate(normalize-space(preceding-sibling::glo:item[1]),
	    'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')">

	    \item[] \noindent\raggedright {\bf <xsl:value-of select="./glo:term" />}<xsl:call-template name="print-meanings" />

	  </xsl:when>
	  <!-- otherwise this word equals the preceding word, so it is only
	  necessary to print another page number -->
	  <xsl:otherwise>
	    <xsl:call-template name="print-meanings" />
	  </xsl:otherwise>
	</xsl:choose>
   <!--   </xsl:if> -->
    </xsl:for-each>
    \end{description}
  </xsl:template>

  <xsl:template match="/module/cnx:document//cnx:glossary" 
                mode="glossary">
    <xsl:apply-templates select="cnx:definition"/>
  </xsl:template>

  
  <xsl:template name="print-letter">
    <xsl:text>{\large \bfseries </xsl:text>
    <xsl:value-of select="translate(substring(normalize-space(.),1,1),
      'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"
      />
    <xsl:text>}</xsl:text>
    <!--selects the capital letter of the current ind:item -->
  </xsl:template>
  
  <xsl:template name="print-meanings">
    <xsl:text>\\</xsl:text>
    <xsl:text>\begin{description}</xsl:text>
    <xsl:for-each select="glo:meaning">
      <xsl:if test="translate(normalize-space(.), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') != translate(normalize-space(preceding::glo:meaning[1]), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')">
        <xsl:variable name="number">
          <xsl:choose>
            <xsl:when test="count(preceding-sibling::glo:meaning)+count(following-sibling::glo:meaning) > 0">
              <xsl:number level='single'/><xsl:text>.\/
  </xsl:text>
            </xsl:when>
            <xsl:otherwise>\hspace{.3cm}</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:text>\item{\hspace{.3cm}}</xsl:text>
        <xsl:value-of select="$number"/><xsl:apply-templates select="child::*[local-name()='meaning-para']"/>
        <xsl:text>\\</xsl:text>
        <xsl:for-each select="cnx:example">
	  <xsl:text>\item{\hspace{.6cm}}</xsl:text>
	  <xsl:text>\begin{it} Example:\/ \end{it}</xsl:text><xsl:apply-templates/>
	  <xsl:text>\\</xsl:text>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>\end{description}</xsl:text>
  </xsl:template>   

</xsl:stylesheet>
