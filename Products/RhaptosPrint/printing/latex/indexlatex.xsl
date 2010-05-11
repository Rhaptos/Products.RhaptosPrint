<?xml version="1.0" encoding="utf-8"?>
<!--
    Format the index at the back of the collection PDF.

    Author: Christine Donica, Chuck Bearden
    (C) 2002-2008 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
  <xsl:stylesheet version="1.0"
		  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		  xmlns:ind="index">


  <xsl:template match="ind:indexlist" mode="index">
    <!-- this is the control template which decides which templates to call
    next.  it assumes that the ind:item's are already sorted in alphabetical
    order. -->
    \begin{description}\setlength{\topsep}{0cm}\setlength{\itemsep}{0cm}
	\setlength{\parskip}{0cm}\setlength{\parsep}{0cm}
	\setlength{\partopsep}{0cm}
        \setlength{\labelwidth}{.6cm}\setlength{\labelsep}{0cm}
        \setlength{\leftmargin}{1cm}
    <xsl:for-each select="ind:item">
      <xsl:if test="text()">
      <xsl:choose>
	<!-- when the first letter of this ind:item does not equal the first
	letter of the preceding ind:item then.... print out the new letter
	block, word and page.  -->
	<xsl:when test="translate(substring(normalize-space(.),1,1),
		  'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
		  !=translate(substring(normalize-space(preceding-sibling::ind:item[1]),1,1),
		  'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')">
	  \vspace{.3cm}
	  \item[<xsl:call-template name="index-print-letter" />]\noindent\raggedright
	  <xsl:value-of select="." />
	  <xsl:call-template name="print-page" />

	</xsl:when>
	<!-- when this ind:item does not equal the preceding ind:item
	then.... end the old word block, print out the new word and page --> 
	<xsl:when test="translate(normalize-space(.),
		  'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
		  !=translate(normalize-space(preceding-sibling::ind:item[1]),
		  'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')">
	  
	  \item[] \noindent\raggedright <xsl:value-of select="normalize-space(.)" />
	  <xsl:call-template name="print-page" />

	</xsl:when>
	<!-- otherwise this word equals the preceding word, so it is only
	necessary to print another page number -->
	<xsl:otherwise>

	  <xsl:call-template name="print-page" />

	</xsl:otherwise>
      </xsl:choose>
      </xsl:if>
    </xsl:for-each>
    \end{description}
  </xsl:template>


  <xsl:template name="index-print-letter">
    <xsl:text>{\large \bfseries </xsl:text>
    <xsl:choose>
      <xsl:when test="starts-with(normalize-space(.), '\lessthan')">
        <xsl:text>\lessthan </xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(normalize-space(.), '\greatthan')">
        <xsl:text>\greatthan </xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(normalize-space(.), '\{')">
        <xsl:text>\{ </xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(normalize-space(.), '\}')">
        <xsl:text>\} </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(substring(normalize-space(.),1,1), 
                             'abcdefghijklmnopqrstuvwxyz', 
                             'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}</xsl:text>
    <!--selects the capital letter of the current ind:item -->
  </xsl:template>
  
  <xsl:template name="print-page">
    <xsl:text>, </xsl:text><!-- comma to go between page references -->

    <xsl:variable name="ref" select="@id"/>
    <!--the variable ref is used to find the module with an id equal to
    @id of a keyword.  the module gives the section number for the keyword -->

    <xsl:choose>
      <!-- If ind:item was a keyword, print the section number and the page
      number.--> 
      <xsl:when test="@type='keyword'">
	<xsl:text> \S~</xsl:text>
	<xsl:value-of select="//document[@id=$ref]/@number"/>
	<xsl:text>(\pageref{</xsl:text>
	<xsl:value-of select="@id"/>
	<xsl:text>})</xsl:text>
      </xsl:when>
      <!-- Otherwise print the page number.-->
      <xsl:otherwise>
	<xsl:text> \pageref{</xsl:text>
	<xsl:value-of select="@id"/>
	<xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  

</xsl:stylesheet>





