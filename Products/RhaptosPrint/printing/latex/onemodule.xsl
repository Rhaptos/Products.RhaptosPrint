<?xml version= "1.0" standalone="no"?>
<!--
    Author: Adan Galvan, Brent Hendricks, Christine Donica
    (C) 2002-2004 Rice University
    
    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:cnx="http://cnx.rice.edu/cnxml"
		xmlns:md="http://cnx.rice.edu/mdml/0.4"
                xmlns:bib="http://bibtexml.sf.net/">

  <xsl:import href="mmltex.xsl"/>
  <xsl:import href="bibtexml.xsl"/>
  <xsl:import href="cnxml.xsl"/>

  <xsl:param name="parent" select="''" />
  <xsl:param name="parentauthors" select="''" />
  <xsl:param name="parenturl" select="''" />
  <xsl:param name="moduleid" select="''" />
  <xsl:param name="moduleurl" select="''" />
  <xsl:param name="moduleversion" select="''" />
  <xsl:param name="license" select="''" />

  <!--ROOT-->
  <xsl:template match="/">
    \documentclass{article}
    
    <xsl:call-template name="preamble"/>

\makeatletter
\newfont{\footsc}{cmcsc10 at 8truept}
\newfont{\footbf}{cmbx10 at 8truept}
\newfont{\footrm}{cmr10 at 10truept}
\newcommand{\ps@cnxheadings}{
    <xsl:if test='$moduleid'>    
      \renewcommand{\@oddhead}{\scriptsize Connexions module:
      <xsl:value-of select="$moduleid"/> \hfil  \thepage}
    </xsl:if>
    \renewcommand{\@evenhead}{\@oddhead}
    <xsl:if test='$moduleurl'>
      \renewcommand{\@oddfoot}{\scriptsize <xsl:value-of select="$moduleurl"/>}
    </xsl:if>
  \renewcommand{\@evenfoot}{\@oddfoot}
  }
\makeatother
\pagestyle{cnxheadings}

\title{\Huge{\sc{<xsl:value-of select="cnx:document/cnx:name"/>}}\\ \small<xsl:if test='$moduleversion'> Version <xsl:value-of select="$moduleversion"/><xsl:text>: </xsl:text></xsl:if> <xsl:value-of select="cnx:document/cnx:metadata/md:revised"/>}
\author{<xsl:for-each select="cnx:document/cnx:metadata/md:authorlist/md:author">{\Large <xsl:value-of select="md:firstname" /><xsl:text> </xsl:text><xsl:value-of select="md:surname" />}\\</xsl:for-each><xsl:if test="$parent">\\<xsl:text>Based on </xsl:text> \it <xsl:value-of select="$parent"/>\footnote{<xsl:value-of select="$parenturl" />}\ \  \rm <xsl:text> by \\</xsl:text><xsl:call-template name='parenttemplate'><xsl:with-param name='authorstring'><xsl:value-of select='$parentauthors' /></xsl:with-param></xsl:call-template>
    </xsl:if>}
\date{\small This work is produced by The Connexions Project<xsl:if test="$license"> and licensed under the \break Creative Commons Attribution License \footnote{<xsl:value-of select='$license' />}</xsl:if>}

    

    \begin{document}
    \fontencoding{C40,T1}
    \selectfont

    \bibliographystyle{plain} 
    \maketitle
    \thispagestyle{cnxheadings}
    <xsl:if test="cnx:document/cnx:metadata/md:abstract">
      \begin{abstract}
      <xsl:value-of select="cnx:document/cnx:metadata/md:abstract" />
      \end{abstract}
    </xsl:if>
    <xsl:call-template name="catcodes" />
    <xsl:apply-templates>
      <xsl:with-param name='moduleid' select='$moduleid'/>
      <xsl:with-param name='moduleurl' select='$moduleurl'/>
      <xsl:with-param name='moduleversion' select='$moduleversion'/>
    </xsl:apply-templates>

    \end{document}
  </xsl:template>

  <!-- Suppress metadata output -->
  <xsl:template match="author|keyword" />

  <!-- Include bibliography -->
  <xsl:template match="bib:file">
    <xsl:apply-templates />
    \bibliography{index}
  </xsl:template>

  <!-- Seperate the authors -->
  <xsl:template name='parenttemplate'>
    <xsl:param name='authorstring'/>
    <xsl:param name='firstauthor' />
    <xsl:if test='string-length($authorstring)>0'> 
      <xsl:choose>
	<xsl:when test="contains($authorstring, ',')">
	  <xsl:value-of select='substring-before($authorstring,",")' />\\
	  <xsl:call-template name='parenttemplate'>
	    <xsl:with-param name='authorstring'><xsl:value-of select='substring-after($authorstring,",")'/></xsl:with-param>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select='$authorstring' />
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
 
</xsl:stylesheet>
