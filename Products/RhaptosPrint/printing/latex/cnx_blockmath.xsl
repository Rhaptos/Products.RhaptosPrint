<?xml version='1.0' encoding="UTF-8"?>
<!--
    Apply conditional typesetting of block math in LaTeX, so that block math that is too wide for the page doesn't run off the right hand.

    Author: Chuck Bearden
    (C) 2008 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:m="http://www.w3.org/1998/Math/MathML"
		xmlns:glo="glossary"
                xmlns:cnx="http://cnx.rice.edu/cnxml"
                version='1.0'>

  <!-- Handle block math that is not in CALS tables to apply conditional 
       typesetting; this template should pre-empt the template matching 
       'm:math' in mmltex.xsl for m:math elements that aren't descendants 
       of a table and that have mtable children. -->
  <xsl:template match="m:math[@display='block' and not(ancestor::cnx:table)]">
    <xsl:call-template name="math-disarray"/>
  </xsl:template>

  <!-- We avoid absurd indefinite recursion by calling this template to 
       process block math in the default mode and re-enter the default 
       mode from here. m:math is the context node. -->
  <xsl:template name="back-to-default">
    <xsl:variable name="environment-name">
      <xsl:choose>
        <xsl:when test="parent::cnx:equation">equation</xsl:when>
        <xsl:otherwise>displaymath</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\begin{</xsl:text>
    <xsl:value-of select="$environment-name"/><xsl:text>}
    </xsl:text>
    <xsl:if test="@id">
      \label{<xsl:call-template name="make-label">
        <xsl:with-param name="instring" select="@id"/>
      </xsl:call-template>}
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="$environment-name = 'equation'">
      <xsl:text>\tag{</xsl:text>
      <xsl:value-of select="parent::cnx:equation/@number"/>
      <xsl:text>}
      </xsl:text>
    </xsl:if>
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$environment-name"/><xsl:text>}
    </xsl:text>
  </xsl:template>

  <!-- Context node is m:math -->
  <xsl:template name="math-disarray">
    <!-- conditional LaTeX here 
         - typeset in a savebox as per usual 
         - typeset de-arrayed in another savebox
         - if the first savebox is too wide, use the second
         -->
    <!-- Typeset this math in the normal fashion and store its width 
         in a length register -->
    <xsl:text>\settowidth{\mymathboxwidth}{</xsl:text>
    <xsl:call-template name="back-to-default"/><xsl:text>}
    </xsl:text>

    <!-- debug info for the pdflatex log -->
    <xsl:text>\typeout{Columnwidth = \the\columnwidth}</xsl:text>
    <xsl:text>\typeout{math as usual width = \the\mymathboxwidth}
    </xsl:text>

    <!-- Test the width -->    
    <xsl:text>\ifthenelse{\lengthtest{\mymathboxwidth &lt; \columnwidth}}{</xsl:text>
    <xsl:text>% if the math fits, do it again, for real
    </xsl:text>
    <xsl:call-template name="back-to-default"/>
    <xsl:text>}{% else, if it doesn't fit
    </xsl:text>

    <!-- Typeset this math in the de-arrayed fashion; the LaTeX output of 
         this part should come into play only if the standard typesetting 
         above was too wide. -->
    <xsl:apply-templates select="self::node()" mode="math-disarray"/>

    <xsl:text>}% end of conditional for this bit of math
    </xsl:text>
  </xsl:template>

  <!-- Ignore the mtd and apply templates in default mode; we're done 
       stripping out arrayish things -->
  <xsl:template match="m:mtd" mode="math-disarray">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Ignore the mtr and apply-templates in math-disarray mode -->
  <xsl:template match="m:mtr" mode="math-disarray">
    <xsl:apply-templates mode="math-disarray"/>
  </xsl:template>

  <!-- Ignore the mtable and apply templates in math-disarray mode -->
  <xsl:template match="m:mtable" mode="math-disarray">
    <xsl:apply-templates mode="math-disarray"/>
  </xsl:template>

  <!-- Start processing math in math-disarray mode -->
  <!-- Thoughts on setting the width: 
       - try putting \parboxes for the math and the equation numbers inside 
         the minipage, with the idea that they will be arranged side-by-side;
       - if we're in a two-column environment (glossary), use \columnwidth; 
       - in general, decide how much space to allocate to the numbering, and 
         subtract that from \columnwidth or \textwidth to determine the 
         dimensions of the two \parboxes; -->
  <xsl:template match="m:math" mode="math-disarray">
    <xsl:variable name="eqn-number-hspace" select="'48pt'"/>
    <xsl:text>\setlength{\mymathboxwidth}{\columnwidth}
      \addtolength{\mymathboxwidth}{-</xsl:text>
    <xsl:value-of select="$eqn-number-hspace"/>
    <xsl:text>}
    </xsl:text>
    <xsl:text>\par\vspace{12pt}\noindent\begin{minipage}{\columnwidth}
    </xsl:text>
    <xsl:text>\parbox[t]{\mymathboxwidth}{\large\begin{math}
    </xsl:text>
    <xsl:apply-templates mode="math-disarray"/>
    <xsl:text>\end{math}}\hfill
    </xsl:text>
    <xsl:text>\parbox[t]{</xsl:text>
    <xsl:value-of select="$eqn-number-hspace"/>
    <xsl:text>}{\raggedleft 
    </xsl:text>
    <xsl:if test="parent::cnx:equation">(<xsl:value-of select="parent::cnx:equation/@number"/>)</xsl:if>
    <xsl:text>}
    </xsl:text>
    <xsl:text>\end{minipage}\vspace{12pt}\par
    </xsl:text>
  </xsl:template>

  <!-- This catch-all for children of a mtd|mtr|mtable in math-disarray is 
       intended to start processing the node (and its children) in default 
       mode; bounces flow back to default mode in MathML -->
  <xsl:template match="node()" mode="math-disarray">
    <xsl:apply-templates select="self::node()"/>
  </xsl:template>

  <xsl:template name="make-nonmath-equation">
    <xsl:text>\begin{equation}
    </xsl:text>
    <xsl:if test="@id">
      \label{<xsl:call-template name="make-label">
        <xsl:with-param name="instring" select="@id"/>
      </xsl:call-template>}
    </xsl:if>
    <xsl:text>\tag{</xsl:text>
    <xsl:value-of select="@number"/>
    <xsl:text>}
    </xsl:text>
    \text{<xsl:apply-templates select="node()[not(self::cnx:name) and not(self::cnx:title) and not(self::cnx:label)]"/>}
    <xsl:text>\end{equation}
    </xsl:text>
  </xsl:template>

</xsl:stylesheet>
