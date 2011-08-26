<?xml version= "1.0"?>
<!--
    Transform CNXML elements to LaTeX for collection and module PDF
    generation.

    Author: Chuck Bearden, Scott Kravitz, Christine Donica, Adan Galvan, Brent Hendricks
    (C) 2002-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cnx="http://cnx.rice.edu/cnxml"
                xmlns:qml="http://cnx.rice.edu/qml/1.0"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:md="http://cnx.rice.edu/mdml"
                xmlns:md4="http://cnx.rice.edu/mdml/0.4"
                xmlns:cnx-context="http://cnx.rice.edu/contexts#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:bib="http://bibtexml.sf.net/"
                xmlns:cnxn="#cnxn"
                xmlns:cm="#cnxml-metadata"
                xmlns:glo="glossary"
                xmlns:exsl="http://exslt.org/common"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="exsl str"
>

  <xsl:import href="table.xsl" />
  <xsl:import href="bibtexml.xsl" />
  <xsl:import href="qml.xsl" />
 
  <xsl:param name="moduleid"/>
  <xsl:param name="moduleurl"/>
  <xsl:param name="moduleversion"/>
  <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="graphics-max-width">
    <xsl:choose>
      <xsl:when test="/course/parameters/parameter[@name='papersize']/@value = '6x9'">4.0</xsl:when>
      <xsl:otherwise>6.0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="graphics-max-height">
    <xsl:choose>
      <xsl:when test="/course/parameters/parameter[@name='papersize']/@value = '6x9'">7.0</xsl:when>
      <xsl:otherwise>8.5</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="paraspacing" select="/course/parameters/parameter[@name='paraspacing']/@value"/>
  <xsl:variable name="lower-letters" select="'abcdefghijklmnopqrstuvwxyzäëïöüáéíóúàèìòùâêîôûåøãõæœçłñ'"/>
  <xsl:variable name="upper-letters" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÄËÏÖÜÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÅØÃÕÆŒÇŁÑ'"/>
  <xsl:variable name="supported-types" select="document('')/xsl:stylesheet/cm:supported-types"/>

  <xsl:key name='by-id' 
           match='*[not(local-name()="item" and namespace-uri()="index")]' 
           use='@id'/>
  <xsl:key name='document-by-id' match='document' use='@id'/>
  <xsl:key name='referenced-document-by-id' match='referenced-objects/document' use='@id'/>
  <xsl:key name="exercise-by-id" match="cnx:exercise" use="@id"/>
  <xsl:key name="qmlitem-by-id" match="qml:item" use="@id"/>
  <xsl:key name="solution-by-ref" match="cnx:solution|qml:answers" use="@ref"/>
  <xsl:key name="optionalrole-by-name" match="optionalrole" use="@name"/>
  <cnxn:title-before mode="in-place"> (</cnxn:title-before>
  <cnxn:title-before mode="parenthetical">: </cnxn:title-before>
  <cnxn:title-after mode="in-place">)</cnxn:title-after>
  <cnxn:title-after mode="parenthetical"></cnxn:title-after>

  <cm:supported-types>
    <cnx:rule type="rule"/>
    <cnx:rule type="theorem"/>
    <cnx:rule type="lemma"/>
    <cnx:rule type="corollary"/>
    <cnx:rule type="law"/>
    <cnx:rule type="proposition"/>
    <cnx:note type="note"/>
    <cnx:note type="aside"/>
    <cnx:note type="warning"/>
    <cnx:note type="tip"/>
    <cnx:note type="important"/>
  </cm:supported-types>

  <xsl:template match="md:*|md4:*">
    <!--not dealing with mdml ever-->
  </xsl:template>

  <xsl:template match="module-export">
  </xsl:template>
  
  <xsl:template match="*[local-name()='featured-links']">
  </xsl:template>

  <xsl:template name="module-preamble">
    <xsl:text>
    \makeatletter
    </xsl:text>
    <xsl:if test="not(/course/*[local-name()='language'][1]='vi' or /module/cnx:document/module-export/*[local-name()='language'][1]='vi')">
      <xsl:text>
    \newfont{\footsc}{cmcsc10 at 8truept}
    \newfont{\footbf}{cmbx10 at 8truept}
    \newfont{\footrm}{cmr10 at 10truept}
      </xsl:text>
    </xsl:if>
    <xsl:text>
    \newcommand{\ps@cnxheadings}{
      \renewcommand{\@oddhead}{\scriptsize </xsl:text><xsl:value-of select="$PROJECT_SHORT_NAME"/><xsl:text> module: </xsl:text>
      <xsl:value-of select="$object-id"/><!-- m12173 -->
    <xsl:text>
      \hfil  \thepage}
      \renewcommand{\@evenhead}{\@oddhead}
      \renewcommand{\@oddfoot}{\scriptsize
        </xsl:text>
        <xsl:value-of select="$object-uri"/><!-- http://plantinga.cnx.rice.edu:8080/content/m12173/latest/ -->
    <xsl:text>      }
      \renewcommand{\@evenfoot}{\@oddfoot}
    }
    \makeatother
    \pagestyle{cnxheadings}
    </xsl:text>

    <xsl:text>\title{\Huge{\sc{</xsl:text>
    <xsl:value-of select="/module/cnx:document/module-export/title"/>
    <xsl:text>}\Large\raisebox{7pt}{\footnote{Version </xsl:text>
    <xsl:value-of select="/module/cnx:document/module-export/version"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="/module/cnx:document/module-export/revised"/>
    <xsl:text>}}}\\
    \parbox{}}
    </xsl:text>
    <xsl:text>\author{</xsl:text>
    <xsl:for-each select="/module/cnx:document/module-export/author">
      <xsl:text>{\Large </xsl:text>
      <xsl:value-of select="name" />
      <xsl:text>}\\
      </xsl:text>
    </xsl:for-each><!-- I'm not going to implement optionalrole handling until
                        I can find out what it is all about.
    <xsl:for-each select="/module/metadata/optionalrole[generate-id() = generate-id(key('optionalroles',@name)[1])]">
      <xsl:call-template name="optionalroles">
        <xsl:with-param name="rolename">
          <xsl:value-of select="@name"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each> -->
    <xsl:for-each select="/module/cnx:document/module-export/optionalrole[generate-id() = generate-id(key('optionalrole-by-name',@name)[1])]">
      <xsl:call-template name="optionalroles">
        <xsl:with-param name="rolename">
          <xsl:value-of select="@name"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="/module/cnx:document/module-export/parent">
      <xsl:variable name="parent-uri" select="concat($CNX_CONTENT_URI, '/', substring-after(/module/cnx:document/module-export/parent/@href, 'content/'))"/>
      <xsl:text>\\
      Based on \it </xsl:text>
      <xsl:value-of select="/module/cnx:document/module-export/parent/title"/>
      <xsl:text>\footnote{</xsl:text>
      <xsl:value-of select="$parent-uri" />
      <xsl:text>}\ \  \rm 
      by \\
      </xsl:text>
      <xsl:for-each select="/module/cnx:document/module-export/parent/author">
        <xsl:value-of select="name" />
        <xsl:text>\\
        </xsl:text>
      </xsl:for-each>
    </xsl:if>
    <xsl:text>}
    </xsl:text>
    <xsl:text>\date{\small This work is produced by </xsl:text><xsl:value-of select="$PROJECT_NAME"/><xsl:text> and licensed under the \break Creative Commons Attribution License \footnote{</xsl:text>
    <xsl:value-of select='/module/cnx:document/module-export/license/@href' />
    <xsl:text>}}
    </xsl:text>
  </xsl:template>

  <xsl:template name="optionalroles">
    <xsl:param name="rolename" />
    <xsl:if test="$rolename!='Editor'">\\<xsl:value-of select="@displaybyline"/>
      <xsl:text>: </xsl:text>\\<xsl:for-each select="../optionalrole[@name=$rolename]">
      <xsl:value-of select="name" />\\</xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="collection-preamble">
    \newenvironment{toc}%
    {\begin{description}\setlength{\topsep}{0cm}\setlength{\itemsep}{0cm}%%
    \setlength{\parskip}{0cm}\setlength{\parsep}{0cm}%%
    \setlength{\partopsep}{0cm}}
    {\end{description}}

    \newenvironment{indexheading}%
    {\begin{description}\setlength{\topsep}{0cm}\setlength{\itemsep}{0cm}%%
    \setlength{\parskip}{0cm}\setlength{\parsep}{0cm}%%
    \setlength{\partopsep}{0cm}
    \setlength{\labelwidth}{0cm}\setlength{\labelsep}{0cm}%
    \setlength{\leftmargin}{-1cm} \item[] \noindent}
    {\end{description}}

    \setlength{\marginparsep}{0pt}
    \setlength{\marginparwidth}{0pt}
    %\setlength{\}{0pt}
  </xsl:template>

  <xsl:template name="preamble">
    <xsl:param name="printfont"/>
    <xsl:param name="papersize"/>
    <xsl:variable name="header-width">
      <xsl:choose>
        <xsl:when test="$papersize = '6x9'">3in</xsl:when>
        <xsl:otherwise>5in</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$printfont = 'times'">
        \usepackage{mathptmx}
        %\usepackage{helvet}
        %\usepackage{courier}
      </xsl:when>
      <xsl:when test="$printfont = 'palatino'">
        \usepackage{mathpazo}
        %\usepackage{helvet}
        %\usepackage{courier}
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$papersize = '6x9'">
        \usepackage[paperwidth=6in,paperheight=9in,
          lmargin=0.8in, rmargin=0.8in, 
          tmargin=0.8in, bmargin=0.8in,
          twoside,centering,
          includehead]{geometry}
      </xsl:when>
      <xsl:otherwise>
        \usepackage[paper=letter,
          lmargin=1in, rmargin=1in, 
          tmargin=1in, bmargin=1in,
          twoside,centering,
          includehead]{geometry}
      </xsl:otherwise>
    </xsl:choose>
    \usepackage{layouts}
    \usepackage{multicol}
    \usepackage{amsmath} %for \underset, \overset, and more?
    \usepackage{amssymb} %for set of reals, integers, etc..., \triangleq
    \usepackage{alltt}   %for codeblocks
    \usepackage{url} %for nice url breaks
    \usepackage[pdftex]{graphicx} % for figure support
    \usepackage{epstopdf}
    \usepackage{subfigure}
    \usepackage{tabularx}
    \usepackage{supertabular}
    \usepackage{xtab}
    \usepackage{multirow}
    \usepackage{float}
    \usepackage{ragged2e} 
    \usepackage{array}
    \usepackage{mathrsfs}
    \usepackage{textcomp}
    \usepackage[cjkjis,mathletters,autogenerated,tipa]{ucs}
    <xsl:choose>
      <xsl:when test="/course/*[local-name()='language'][1]='vi' or /module/cnx:document/module-export/*[local-name()='language'][1]='vi'">
        <xsl:text>
    \usepackage[utf8]{vietnam}
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>
    \usepackage[utf8x]{inputenc}
    \usepackage[C40,T1]{fontenc}
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    \usepackage{calc}
    \usepackage{ifthen}
    %\usepackage{breqn}
    \usepackage{ulem}
    \normalem

%    \setlength{\emergencystretch}{3em}

    \renewcommand{\thesubfigure}{(\alph{subfigure})}
    \renewcommand{\labelitemi}{\ensuremath{\bullet} }
    \renewcommand{\labelitemii}{\ensuremath{\cdot} }
    \usepackage{enumerate}
    \usepackage{enumitem}

    \DeclareUnicodeCharacter {183} {\ensuremath{\cdot}}
    \DeclareUnicodeCharacter {785} {\textasciibreve}
    \DeclareUnicodeCharacter {787} {'}
    \DeclareUnicodeCharacter {788} {`}
    \DeclareUnicodeCharacter {789} {'}
    \DeclareUnicodeCharacter {940} {[U+03AC]}
    \DeclareUnicodeCharacter {941} {[U+03AD]}
    \DeclareUnicodeCharacter {942} {[U+03AE]}
    \DeclareUnicodeCharacter {943} {[U+03AF]}
    \DeclareUnicodeCharacter {970} {\"{i}}
    \DeclareUnicodeCharacter {972} {[U+03CC]}
    \DeclareUnicodeCharacter {973} {[U+03CD]}
    \DeclareUnicodeCharacter {974} {[U+03CE]}
    \DeclareUnicodeCharacter {978}  {\ensuremath{\Upsilon}}
    \DeclareUnicodeCharacter {988}  {\ensuremath{\digamma}}
    \DeclareUnicodeCharacter {8260} {/}
    \DeclareUnicodeCharacter {8289} {}
    \DeclareUnicodeCharacter {8290} {}
    \DeclareUnicodeCharacter {8407} {\ensuremath{\rightarrow}}
    \DeclareUnicodeCharacter {8474} {\ensuremath{\mathbb{Q}}}
    \DeclareUnicodeCharacter {8484} {\ensuremath{\mathbb{Z}}}
    \DeclareUnicodeCharacter {8497} {\ensuremath{\mathcal{F}}}
    \DeclareUnicodeCharacter {8519} {\ensuremath{\mathbb {e}}}
    \DeclareUnicodeCharacter {8520} {\ensuremath{\mathbb {i}}}
    \DeclareUnicodeCharacter {8596} {\ensuremath{\leftrightarrow}}
    \DeclareUnicodeCharacter {8614} {\ensuremath{\mapsto}}
    \DeclareUnicodeCharacter {8788} {:=}
    \DeclareUnicodeCharacter {9001} {\ensuremath{\textless}}
    \DeclareUnicodeCharacter {9002} {\ensuremath{\textgreater}}   
    \DeclareUnicodeCharacter {9474} {\ensuremath{\textbar}}
    \DeclareUnicodeCharacter {10003} {\checkmark}
  
    \DeclareUnicodeCharacter {61168}{\ensuremath{\jmath}}
    \DeclareUnicodeCharacter {61237}{\ensuremath{\mathscr{A}}}
    \DeclareUnicodeCharacter {61238}{\ensuremath{\mathscr{C}}}
    \DeclareUnicodeCharacter {61239}{\ensuremath{\mathscr{D}}}
    \DeclareUnicodeCharacter {61240}{\ensuremath{\mathscr{G}}}
    \DeclareUnicodeCharacter {61241}{\ensuremath{\mathscr{J}}}
    \DeclareUnicodeCharacter {61242}{\ensuremath{\mathscr{K}}}
    \DeclareUnicodeCharacter {61243}{\ensuremath{\mathscr{N}}}
    \DeclareUnicodeCharacter {61244}{\ensuremath{\mathscr{O}}}
    \DeclareUnicodeCharacter {61245}{\ensuremath{\mathscr{P}}}
    \DeclareUnicodeCharacter {61246}{\ensuremath{\mathscr{Q}}}
    \DeclareUnicodeCharacter {61247}{\ensuremath{\mathscr{S}}}
    \DeclareUnicodeCharacter {61248}{\ensuremath{\mathscr{T}}}
    \DeclareUnicodeCharacter {61249}{\ensuremath{\mathscr{U}}}
    \DeclareUnicodeCharacter {61250}{\ensuremath{\mathscr{V}}}
    \DeclareUnicodeCharacter {61251}{\ensuremath{\mathscr{W}}}
    \DeclareUnicodeCharacter {61252}{\ensuremath{\mathscr{X}}}
    \DeclareUnicodeCharacter {61253}{\ensuremath{\mathscr{Y}}}
    \DeclareUnicodeCharacter {61254}{\ensuremath{\mathscr{Z}}}
    \DeclareUnicodeCharacter {61327}{\ensuremath{\mathbb {E}}}
    \DeclareUnicodeCharacter {61328}{\ensuremath{\mathbb {F}}}
    \DeclareUnicodeCharacter {62838}{\ensuremath{\longleftarrow}}
    \DeclareUnicodeCharacter {62839}{\ensuremath{\longrightarrow}}
    \DeclareUnicodeCharacter {62843}{\ensuremath{\leftrightarrow}}
                
    \newlength\paragraphskip
    \setlength{\paragraphskip}{9.0pt plus 1.0pt}
    <xsl:if test="$paraspacing = 'loose'">
      \setlength{\parindent}{0pt}
    </xsl:if>
    
	\newenvironment{note}[1]%
	{\begin{list}{}{%
 	\setlength{\labelsep}{0pt}\setlength{\rightmargin}{20pt}%
        \setlength{\leftmargin}{20pt}%
	\setlength{\labelwidth}{0pt}\setlength{\listparindent}{0pt}}%
        \item\textsc{#1}}%
	{\end{list}}

    	\newenvironment{cnxcaption}%
	{\begin{list}{}{%
 	\setlength{\labelsep}{0pt}\setlength{\rightmargin}{25pt}%
        \setlength{\leftmargin}{25pt}%
	\setlength{\labelwidth}{0pt}\setlength{\listparindent}{0pt}}%
        \item}%
	{\end{list}}

        \newenvironment{example}{%
          \noindent
          \begingroup
          \leftskip=20pt\rightskip=\leftskip
        }{%
          \vspace{\rubberspace}\par
          \endgroup
        }

        \newenvironment{exercise}{\begin{example}}
        {\end{example}}

        \newenvironment{cnxrule}{\begin{example}}
        {\end{example}}

        \newenvironment{definition}{\begin{example}}
        {\end{example}}

        \newenvironment{listname}{\vspace{\rubberspace}\par\noindent{}}{\vspace*{0pt}
        \nopagebreak}

    \newcommand{\lessthan}{\ensuremath{&lt;}}
    \newcommand{\greatthan}{\ensuremath{&gt;}}

    % --------------------------------------------
    % Hacks for honouring row/entry/@align
    % (\hspace not effective when in paragraph mode)
    % Naming convention for these macros is:
    % 'docbooktolatex' 'align' {alignment-type} {position-within-entry}
    % where r = right, l = left, c = centre
    \newcommand{\docbooktolatexalign}[2]{\protect\ifvmode#1\else\ifx\LT@@tabarray\@undefined#2\else#1\fi\fi}
    \newcommand{\docbooktolatexalignll}{\docbooktolatexalign{\raggedright}{}}
    \newcommand{\docbooktolatexalignlr}{\docbooktolatexalign{}{\hspace*\fill}}
    \newcommand{\docbooktolatexaligncl}{\docbooktolatexalign{\centering}{\hfill}}
    \newcommand{\docbooktolatexaligncr}{\docbooktolatexalign{}{\hspace*\fill}}
    \newcommand{\docbooktolatexalignrl}{\protect\ifvmode\raggedleft\else\hfill\fi}
    \newcommand{\docbooktolatexalignrr}{}

    % ------------------------------------------
    % Break long chapter titles in running heads
    \makeatletter
      \def\@evenhead{\thepage\hfil\parbox{<xsl:value-of select="$header-width"/>}{\raggedleft\slshape\leftmark}}%
    \makeatother

    % ------------------------------------------
    % Lengths etc. for tables
    \newlength\mytablewidth  % full width of table
    \newlength\mytablespace  % non-content hspace in table (tabcolseps and rule widths)
    \newlength\mytableroom   % content hspace in table
    \newlength\mycolwidth
    \newlength\myfixedwidth  % sum of widths of columns that have fixed widths
    \newlength\mystarwidth   % length of one star factor
    \newlength\myspanwidth
    \newsavebox\mytablebox
    \newlength\mytableboxwidth
    \newlength\mytableboxheight
    \newlength\mytableboxdepth
    \newcolumntype{L}[1]{>{\raggedright\hspace{0pt}}p{#1}}
    \newcolumntype{C}[1]{>{\centering\hspace{0pt}}p{#1}}
    \newcolumntype{R}[1]{>{\raggedleft\hspace{0pt}}p{#1}}
    \newcolumntype{J}[1]{>{\hspace{0pt}}p{#1}}

    % ------------------------------------------
    % savebox and length for conditional typesetting of block math
    \newsavebox\mymathbox
    \newlength\mymathboxwidth

    % ------------------------------------------
    % Command to help dmath* be pseudo-text-math
    \newcommand*\nodisplayskips{%
      \setlength\abovedisplayskip{0pt}%
      \setlength\abovedisplayshortskip{0pt}%
      \setlength\belowdisplayskip{0pt}%
      \setlength\belowdisplayshortskip{0pt}%
    }

    \newlength\figurerulewidth
    \setlength\figurerulewidth{\textwidth}
    \addtolength\figurerulewidth{-50pt}
    
    \newlength\rubberspace
    \setlength\rubberspace{3pt plus 3pt}
    
    % Give tables more vertical padding, so that math looks better
    \renewcommand{\arraystretch}{1.4}
  </xsl:template>

  <xsl:template name="catcodes">
    \catcode`\^^J=10 %ignore line feeds since they mean nothing to XML
    \catcode`\^^M=10 %ignore carriage returns since they mean nothing to XML
  </xsl:template>

  <!-- Helper template to compute our section level in the document 
       based on our @number ; each period '.' increments the leve 
       count by 1, so chapters are level 0 -->
  <xsl:template name="countlevel">
    <xsl:param name="numstring"/>
    <xsl:param name="parentlevel"/>
    <xsl:choose>
      <xsl:when test="contains($numstring, '.')">
        <xsl:call-template name="countlevel">
          <xsl:with-param name="numstring" select="substring-after($numstring, '.')"/>
          <xsl:with-param name="parentlevel" select="$parentlevel+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$parentlevel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/module/cnx:document/cnx:name | /module/cnx:document/cnx:title">
  </xsl:template>

  <!-- Ignore language elements -->
  <xsl:template match="/module/cnx:document/module-export/*[local-name()='language']">
  </xsl:template>

  <xsl:template match="/course/*[local-name()='language']">
  </xsl:template>

  <xsl:template name="newpage-for-homework">
    <xsl:param name="module-id"/>
    <xsl:variable name="class-values" select="str:tokenize(@class)"/>
    <xsl:variable name="title-string">
      <xsl:choose>
        <xsl:when test="name"><xsl:value-of select="name"/></xsl:when>
        <xsl:when test="cnx:name"><xsl:value-of select="cnx:name"/></xsl:when>
        <!-- <xsl:when test="cnx:title"><xsl:value-of select="cnx:title"/></xsl:when>  FIXME: hack to avoid adding pagebreaks at subsubsections based on title - can still use @class-->
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="ancestor::group/name='Appendix'">
        <xsl:if test="self::group or ((self::document or self::cnx:document) and generate-id() != generate-id(../*[self::group or self::document or self::cnx:document][1]))">
          <xsl:text>\newpage  % appendix
          </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$class-values='lab' or $class-values='practice' or $class-values='homework' or $class-values='review'">
        <xsl:text>\newpage
        </xsl:text>
      </xsl:when>
      <xsl:when test="contains($title-string, 'Lab') or contains($title-string, 'Practice') or contains($title-string, 'Homework') or contains($title-string, 'Review') or contains($title-string, 'Summary')">
        <xsl:text>\newpage
        </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="document">
    <xsl:call-template name="newpage-for-homework"/>
    <xsl:apply-templates/>
    <xsl:text>\label{</xsl:text>
    <xsl:value-of select="concat(@id, '**end')"/>
    <xsl:text>}
    </xsl:text>
  </xsl:template>

  <!-- Elements that yield sections in collection PDFs -->
  <xsl:template match="/course//*[starts-with(@cnx-context:class, 'section')] |
                       /course//cnx:section">
    <xsl:variable name="level">
      <xsl:choose>
        <!-- Nothing in frontmatter has @number, so we compute level 
             by counting cnx:section -->
        <xsl:when test="ancestor-or-self::document[@cnx-context:class='frontmatter']">
          <xsl:value-of select="count(ancestor-or-self::cnx:section)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="countlevel">
            <xsl:with-param name="numstring" select="@number"/>
            <xsl:with-param name="parentlevel" select="0"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- If the level is greater than 2 (poor devil of a sub-sub), 
         we add a 'sub' to make '\subsubsection' -->
    <xsl:variable name="subsub">
      <xsl:if test="$level > 2">sub</xsl:if>
    </xsl:variable>
    <xsl:variable name="moduleid">
      <xsl:if test="number($debug-mode) > 0 and local-name(.)='document'">
        <xsl:text> (</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="module-footnotemark">
      <xsl:if test="local-name(.) = 'document'">
        <xsl:text>\raisebox{0.4ex}{\small\footnotemark{}}</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="module-footnotetext">
      <xsl:if test="local-name(.) = 'document'">
        <xsl:call-template name="module-footnotetext">
          <xsl:with-param name="docnode" select="."/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="newpage-for-homework"/>
    <!-- Generate the correct section/subsection LaTeX based on $level -->
    <xsl:choose>
      <!-- Error trap -->
      <xsl:when test="$level = '0'">
        \section*{Something is not right! level: <xsl:value-of select="$level"/>}
      </xsl:when>
      <!-- A section -->
      <xsl:when test="$level = '1'">
        <xsl:text>\section*{</xsl:text>
        <xsl:if test="@number">
          <xsl:value-of select="@number"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:if>
        <xsl:if test="cnx:label and (cnx:title or child::*[local-name()='name'])">
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="child::*[local-name()='name']">
            <xsl:apply-templates select="child::*[local-name()='name']"/>
          </xsl:when>
          <xsl:when test="cnx:title">
            <xsl:apply-templates select="cnx:title"/>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$moduleid"/>
        <xsl:value-of select="$module-footnotemark"/>
        <xsl:text>}
        </xsl:text>
        <xsl:value-of select="$module-footnotetext"/>
        <xsl:text>\nopagebreak
        </xsl:text>
        <xsl:text>\label{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id" />
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- Sub-sections and sub-sub-section -->
      <xsl:otherwise>
        <xsl:text>\label{</xsl:text>
        <xsl:call-template name="make-label">
        <xsl:with-param name="instring" select="@id" />
        </xsl:call-template>
        <xsl:text>}
        </xsl:text>
        <xsl:text>\</xsl:text>
        <xsl:value-of select="$subsub"/>
        <xsl:text>subsection*{</xsl:text>
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:value-of select="@number"/>
          </xsl:when>
          <!-- Noop in frontmatter -->
          <xsl:when test="ancestor-or-self::*[@cnx-context:class='frontmatter']">
          </xsl:when>
          <xsl:otherwise>
            <xsl:number count="cnx:section" level="multiple"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:if test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:if>
        <xsl:if test="cnx:label and (cnx:title or child::*[local-name()='name'])">
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="child::*[local-name()='name']">
            <xsl:apply-templates select="child::*[local-name()='name']"/>
          </xsl:when>
          <xsl:when test="cnx:title">
            <xsl:apply-templates select="cnx:title"/>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$moduleid"/>
        <xsl:value-of select="$module-footnotemark"/>
        <xsl:text>}
        </xsl:text>
        <xsl:value-of select="$module-footnotetext"/>
        <xsl:text>\nopagebreak
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="node()[not(self::*[local-name()='name'] or self::cnx:title or self::cnx:label)]"/>
    <xsl:if test="self::document">
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="concat(@id, '**end')"/>
      <xsl:text>}
      </xsl:text>
    </xsl:if>
    <xsl:if test="following-sibling::*[1][self::cnx:para] and $paraspacing = 'loose'">
      <xsl:text>\vspace{\paragraphskip}</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/module//cnx:section">
    <xsl:variable name="subsub">
      <xsl:if test="count(ancestor-or-self::cnx:section) &gt; 1">
        <xsl:text>sub</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="section-number">
      <xsl:choose>
        <xsl:when test="@number">
          <xsl:value-of select="@number"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number count="cnx:section" level="multiple"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\label{</xsl:text>
    <xsl:call-template name="make-label">
    <xsl:with-param name="instring" select="@id" />
    </xsl:call-template>
    <xsl:text>}
    \</xsl:text>
    <xsl:value-of select="$subsub"/>
    <xsl:text>subsection*{</xsl:text>
    <xsl:value-of select="$section-number"/>
    <xsl:text> </xsl:text>
    <xsl:if test="cnx:label">
      <xsl:apply-templates select="cnx:label/node()"/>
    </xsl:if>
    <xsl:if test="cnx:label and (cnx:title or cnx:name)">
      <xsl:text>: </xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="cnx:name">
        <xsl:apply-templates select="cnx:name"/>
      </xsl:when>
      <xsl:when test="cnx:title">
        <xsl:apply-templates select="cnx:title"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>}
    \nopagebreak
    </xsl:text>
    <xsl:apply-templates select="node()[not(self::cnx:name or self::cnx:title or self::cnx:label)]"/>
    <xsl:if test="following-sibling::*[1][self::cnx:para] and $paraspacing = 'loose'">
      <xsl:text>\vspace{\paragraphskip}</xsl:text>
    </xsl:if>
  </xsl:template>

<!-- PARA :) -->
  <xsl:template match="cnx:para">
    <xsl:text>\label{</xsl:text><xsl:call-template name="make-label">
      <xsl:with-param name="instring" select="@id" />
    </xsl:call-template>
    <xsl:text>}</xsl:text>
    <xsl:if test="cnx:name[string-length(normalize-space(.)) > 0] or cnx:title[string-length(normalize-space(.)) > 0]">
      <xsl:text>\noindent{}\textbf{</xsl:text>
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:apply-templates select="cnx:name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="cnx:title"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:call-template name="end-label"/>
    </xsl:if> 
    <xsl:apply-templates select="node()[not(self::cnx:name or self::cnx:title)]"/>
    <!-- Huge test to make sure space is not added when an element that already adds space is at the end of this paragraph, adding \paragraphskip when followed by a paragraph beginning with text and \rubberspace when followed by a nonempty element. -->
    <xsl:if test="child::node()[normalize-space()][last()][not((self::cnx:code and (@type='block' or @display='block')) or self::cnx:definition or self::cnx:rule or self::cnx:figure or self::cnx:table or self::cnx:exercise or self::cnx:equation or self::cnx:note or (self::cnx:list and not(@type='inline' or @display='inline'))) and normalize-space()]">
      <xsl:choose>
        <xsl:when test="following-sibling::*[1][self::cnx:example and normalize-space()]">
          <xsl:text>\vspace{\rubberspace}\vspace{2pt}</xsl:text>
        </xsl:when>
        <xsl:when test="following-sibling::*[1][self::cnx:para]/node()[normalize-space()][1][self::cnx:definition or self::cnx:rule or self::cnx:exercise and normalize-space()] or following-sibling::*[1][(self::cnx:rule or self::cnx:exercise or self::cnx:definition) and normalize-space()]">
          <xsl:text>\vspace{\rubberspace}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="following-sibling::*[1][self::cnx:para]/node()[normalize-space()][1][not((self::cnx:code and (@type='block' or @display)) or self::cnx:figure or self::cnx:table or self::cnx:equation or self::cnx:note or (self::cnx:list and not(@type='inline' or @display='inline'))) and normalize-space()] and $paraspacing = 'loose'">\vspace{\paragraphskip}</xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:text>\par </xsl:text>
  </xsl:template>

<!-- DIV -->
  <xsl:template match="cnx:div">
    <xsl:call-template name="make-div">
      <xsl:with-param name="data">
        <xsl:apply-templates select="node()[not(self::cnx:title)]"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="make-div">
    <xsl:param name="data"/>
    <xsl:if test="@id">
      <xsl:text>\label{</xsl:text><xsl:call-template name="make-label">
        <xsl:with-param name="instring" select="@id" />
      </xsl:call-template>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:call-template name="begin-new-line"/>
    <xsl:if test="cnx:title[string-length(normalize-space(.)) > 0]">
      <xsl:text>\noindent{}\textbf{</xsl:text>
      <xsl:apply-templates select="cnx:title"/>
      <xsl:text>}</xsl:text>
      <xsl:call-template name="end-label"/>
    </xsl:if>
    <xsl:copy-of select="$data"/>
    <!-- Test to make sure space is not added when an element that already adds space is at the end of this element. -->
    <xsl:if test="not(child::node()[normalize-space()][last()][not((self::cnx:code and @display='block') or self::cnx:definition or self::cnx:rule or self::cnx:figure or self::cnx:table or self::cnx:exercise or self::cnx:equation or self::cnx:note or (self::cnx:list and not(@display='inline'))) and normalize-space()])">
      \vspace{2pt}
    </xsl:if>
    <xsl:text>\vspace{\rubberspace}\par </xsl:text>
  </xsl:template>

<!-- SPAN -->
  <xsl:template match="cnx:span">
    <xsl:call-template name="add-optional-label"/> 
    <xsl:choose>
      <xsl:when test="@effect='bold'">
        <xsl:text>\textbf{</xsl:text><xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='italics'">
        <xsl:text>\textsl{</xsl:text><xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='underline'">
        <xsl:text>\uline{</xsl:text><xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='smallcaps'">
        <xsl:text>\textsc{</xsl:text><xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='normal'">
        <xsl:text>\textnormal{</xsl:text><xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Don't put elements with @display="none" in the PDF. -->
  <xsl:template match="*[self::cnx:list or self::cnx:code or self::cnx:media or self::cnx:note or self::cnx:preformat or self::cnx:quote][@display='none']"/>
  
  <!-- PREFORMAT -->
  <xsl:template match="cnx:preformat">
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="@display='inline'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="begin-new-line"/>
        <xsl:if test="cnx:title">
          <xsl:text>\noindent\textbf{</xsl:text>
          <xsl:apply-templates select="cnx:title"/>
          <xsl:text>}</xsl:text>
          <xsl:call-template name="end-label"/>
        </xsl:if>
        <xsl:text>\begin{alltt}\normalfont{}</xsl:text>
        <xsl:apply-templates select="node()[not(self::cnx:title)]"/>
        <xsl:text>\end{alltt}</xsl:text>
        <xsl:text>\vspace{\rubberspace}\par </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!-- Ignore label elements unless explicitly transformed -->
  <xsl:template match="cnx:label"> 
  </xsl:template>
  
  <xsl:template match="cnx:title | cnx:name">
    <xsl:choose>
      <xsl:when test="parent::cnx:table">
        <xsl:apply-imports/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!-- NEWLINE -->
  <xsl:template match="cnx:newline">
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="@effect='underline'">
      <xsl:text>\newline
      </xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@effect='bold'">
        <xsl:text>\textbf{</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='italics'">
        <xsl:text>\textsl{</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='smallcaps'">
        <xsl:text>\textsc{</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='normal'">
        <xsl:text>\textnormal{</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@count">
        <xsl:call-template name="make-new-lines">
          <xsl:with-param name="count" select="@count"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-new-lines"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@effect='bold' or @effect='italics' or @effect='smallcaps' or @effect='normal'">
      <xsl:text>}</xsl:text>
    </xsl:if>
  </xsl:template>

<!-- Newline helper template -->
  <xsl:template name="make-new-lines">
    <xsl:param name="count" select="1"/>
    <xsl:if test="@effect='underline'">
      <xsl:text>\smallskip\hrulefill</xsl:text>
    </xsl:if>
    <xsl:text>\newline
    </xsl:text>
    <xsl:if test="$count>1">
      <xsl:call-template name="make-new-lines">
        <xsl:with-param name="count" select="$count - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
<!-- SPACE -->
  <xsl:template match="cnx:space">
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="@effect='bold'">
        <xsl:text>\textbf{</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='italics'">
        <xsl:text>\textsl{</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='underline'">
        <xsl:text>\uline{</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='smallcaps'">
        <xsl:text>\textsc{</xsl:text>
      </xsl:when>
      <xsl:when test="@effect='normal'">
        <xsl:text>\textnormal{</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>\hspace{</xsl:text>
    <xsl:choose>
      <xsl:when test="@count">
        <xsl:value-of select="@count"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>ex}</xsl:text>
    <xsl:if test="@effect='bold' or @effect='italics' or @effect='underline' or @effect='smallcaps'or @effect='normal'">
      <xsl:text>}</xsl:text>
    </xsl:if>
  </xsl:template>

<!-- LIST :) -->
  <xsl:template match="cnx:list">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:variable name="before">
      <xsl:call-template name="replace-bracket">
        <xsl:with-param name="text" select="@mark-prefix"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="after">
      <xsl:call-template name="replace-bracket">
        <xsl:with-param name="text" select="@mark-suffix"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="bullet-style">
      <xsl:call-template name="replace-bracket">
        <xsl:with-param name="text" select="@bullet-style"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="$cnxml-version='0.6' or $cnxml-version='0.7'">
          <xsl:value-of select="translate(@list-type, $upper-letters, $lower-letters)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@type, $upper-letters, $lower-letters)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="cnx:label or cnx:name or cnx:title">
      <xsl:if test="not($type='inline' or @display='inline')">
        <xsl:text>\begin{listname}</xsl:text>
      </xsl:if>
      <xsl:text>\textbf{</xsl:text>
      <xsl:if test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
        <xsl:if test="cnx:title">
          <xsl:text>: </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="cnx:name"> 
          <xsl:apply-templates select="cnx:name"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title"/>
        </xsl:when>
      </xsl:choose>
      <xsl:text> }</xsl:text>
      <xsl:if test="not($type='inline' or @display='inline')">
        <xsl:text>\end{listname}</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@display='inline' and $cnxml-version='0.7'">
        <xsl:apply-templates select="cnx:item" mode="cnxml-0.7"/>
      </xsl:when>
      <xsl:when test="@display='inline' and $cnxml-version='0.6'">
        <xsl:apply-templates select="cnx:item" mode="cnxml-0.6"/>
      </xsl:when>
      <xsl:when test="$type='inline'">
        <xsl:apply-templates select="cnx:item"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$type='enumerated'">
            <xsl:variable name="step">
              <xsl:if test="str:tokenize(@class)='stepwise'">
                <xsl:text>Step </xsl:text>
              </xsl:if>
            </xsl:variable>
            <xsl:text>\begin{enumerate}[noitemsep</xsl:text>
            <xsl:text>, label=</xsl:text>
            <xsl:value-of select="$step"/>
            <xsl:choose>
              <xsl:when test="ancestor::qml:item">
                <xsl:choose>
                  <xsl:when test="count(ancestor::cnx:list) mod 2=1">
                    <xsl:text>\roman*)</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>\alph*)</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$before"/>
                <xsl:choose>
                  <xsl:when test="@number-style='upper-alpha'">
                    <xsl:text>\Alph*</xsl:text>
                  </xsl:when>
                  <xsl:when test="@number-style='lower-alpha'">
                    <xsl:text>\alph*</xsl:text>
                  </xsl:when>
                  <xsl:when test="@number-style='upper-roman'">
                    <xsl:text>\Roman*</xsl:text>
                  </xsl:when>
                  <xsl:when test="@number-style='lower-roman'">
                    <xsl:text>\roman*</xsl:text>
                  </xsl:when>
                  <xsl:when test="count(ancestor::cnx:list) mod 2=1">
                    <xsl:text>\alph*</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>\arabic*</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="@mark-suffix">
                    <xsl:value-of select="$after"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>.</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@start-value">
                  <xsl:text>, start=</xsl:text>
                  <xsl:value-of select="@start-value"/>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>]
            </xsl:text>
          </xsl:when>
          <xsl:when test="$type='labeled-item' or $type='named-item'">
            <xsl:text>\begin{description}[noitemsep]
            </xsl:text>          
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\begin{itemize}[noitemsep</xsl:text>
            <xsl:if test="@mark-prefix or @bullet-style or @mark-suffix">
              <xsl:text>, label=</xsl:text>
              <xsl:value-of select="$before"/>
              <xsl:choose>
                <xsl:when test="normalize-space($bullet-style)='open-circle'">
                  <xsl:text>\ensuremath{\circ}</xsl:text>
                </xsl:when>
                <xsl:when test="normalize-space($bullet-style)='pilcrow'">
                  <xsl:text>\P{}</xsl:text>
                </xsl:when>
                <xsl:when test="normalize-space($bullet-style)='rpilcrow'">
                  <xsl:text>\protect\reflectbox{\P}</xsl:text>
                </xsl:when>
                <xsl:when test="normalize-space($bullet-style)='asterisk'">
                  <xsl:text>\ensuremath{\ast}</xsl:text>
                </xsl:when>
                <xsl:when test="normalize-space($bullet-style)='dash'">
                  <xsl:text>-</xsl:text>
                </xsl:when>
                <xsl:when test="normalize-space($bullet-style)='section'">
                  <xsl:text>\S{}</xsl:text>
                </xsl:when>
                <xsl:when test="normalize-space($bullet-style)='none'"></xsl:when>
                <xsl:when test="normalize-space($bullet-style) = 'bullet' or not(@bullet-style)">
                  <xsl:text>\textbullet{}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$bullet-style"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="$after"/>
            </xsl:if>
            <xsl:text>]
            </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="nest-indent"/>
        <xsl:choose>
          <xsl:when test="$cnxml-version='0.7'">
            <xsl:apply-templates select="cnx:item" mode="cnxml-0.7"/>
          </xsl:when>
          <xsl:when test="$cnxml-version='0.6'">
            <xsl:apply-templates select="cnx:item" mode="cnxml-0.6"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="cnx:item"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>\end{</xsl:text>
        <xsl:choose>
          <xsl:when test="$type='enumerated'">
          	<xsl:text>enumerate</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$type='named-item'">
              	<xsl:text>description</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>itemize</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>  
        </xsl:choose>
        <xsl:text>}
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="nest-indent">
    <xsl:variable name="levels"
                  select="count(ancestor::cnx:example|ancestor::cnx:exercise|
                                ancestor::cnx:rule|ancestor::cnx:definition)"/>
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="$cnxml-version='0.6' or $cnxml-version='0.7'">
          <xsl:value-of select="translate(@list-type, $upper-letters, $lower-letters)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@type, $upper-letters, $lower-letters)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$levels > 0">
        <xsl:text>\leftskip=</xsl:text>
        <!--<xsl:value-of select="string($levels*20)"/>-->
        <!-- The line above is here in case we do indentations for other nested 
             things like exercises within examples; at present, we don't give 
             an exercise within an example extra indentation, so it doesn't 
             make sense to do more than one extra 20pt of indentation for 
             nested lists either, regardless of how deeply they are nested. 
             If we decide later to do extra indentation to reflect levels of 
             nesting, we can uncomment the above line and remove the one 
             below. -->
        <xsl:choose>
          <xsl:when test="$type='named-item'">
            <xsl:value-of select="'32'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'20'"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>pt</xsl:text>
        <xsl:text>\rightskip=\leftskip</xsl:text>
      </xsl:when>
      <xsl:when test="$type='named-item'">
        <xsl:text>\leftskip=12pt</xsl:text>
        <xsl:text>\rightskip=\leftskip</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="replace-bracket">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="contains($text, '[')">
        <xsl:call-template name="replace-bracket">
          <xsl:with-param name="text" select="substring-before($text, '[')"/>
        </xsl:call-template>
        <xsl:text>\ensuremath{[}</xsl:text>
        <xsl:call-template name="replace-bracket">
          <xsl:with-param name="text" select="substring-after($text, '[')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($text, ']')">
        <xsl:call-template name="replace-bracket">
          <xsl:with-param name="text" select="substring-before($text, ']')"/>
        </xsl:call-template>
        <xsl:text>\ensuremath{]}</xsl:text>
        <xsl:call-template name="replace-bracket">
          <xsl:with-param name="text" select="substring-after($text, ']')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="cnx:item">
    <xsl:variable name="parent-type" select="translate(parent::cnx:list/@type, $upper-letters, $lower-letters)"/>
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="parent::cnx:list[$parent-type='inline']">
	<xsl:if test="cnx:name">\textbf{<xsl:value-of select="cnx:name"/>:} </xsl:if> 
	<xsl:apply-templates select="*[not(self::cnx:name)]|text()"/><xsl:if test="position()!=last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$parent-type='named-item'">
            <xsl:variable name="list-mark">
              <xsl:choose>
                <xsl:when test="string-length(parent::cnx:list/processing-instruction('mark')) &gt; 0">               
                  <xsl:value-of select="parent::cnx:list/processing-instruction('mark')"/>
                </xsl:when>
                <xsl:when test="parent::cnx:list/processing-instruction('mark')">
                  <xsl:text></xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text> - </xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            \item[<xsl:value-of select="cnx:name"/><xsl:value-of select="$list-mark"/>]
          </xsl:when>
          <xsl:otherwise>  
            \item <xsl:if test="cnx:name">\textbf{<xsl:value-of select="cnx:name"/>} - </xsl:if>
          </xsl:otherwise>
	      </xsl:choose>
	      <xsl:apply-templates select="*[not(self::cnx:name)]|text()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="cnx:item" mode="cnxml-0.6">
    <xsl:variable name="before">
      <xsl:call-template name="replace-bracket">
        <xsl:with-param name="text" select="parent::cnx:list/@mark-prefix"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="after">
      <xsl:call-template name="replace-bracket">
        <xsl:with-param name="text" select="parent::cnx:list/@mark-suffix"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="parent-type" select="translate(parent::cnx:list/@list-type, $upper-letters, $lower-letters)"/>
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="parent::cnx:list[@display='inline']"> 
        <xsl:choose>
          <xsl:when test="$parent-type='labeled-item'">
            <xsl:if test="cnx:label">
              <xsl:text>\textbf{</xsl:text>
              <xsl:value-of select="$before"/>
              <xsl:apply-templates select="cnx:label/node()"/>
              <xsl:choose>
                <xsl:when test="parent::cnx:list[@mark-suffix]">
                  <xsl:value-of select="$after"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>:</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text>} </xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$parent-type='enumerated'">
            <xsl:variable name="step">
              <xsl:if test="str:tokenize(@class)='stepwise'">
                <xsl:text>Step </xsl:text>
              </xsl:if>
            </xsl:variable>
            <xsl:text>\textbf{</xsl:text>
            <xsl:value-of select="$step"/>
            <xsl:value-of select="$before"/>
            <xsl:variable name="start-value">
              <xsl:choose>
                <xsl:when test="parent::cnx:list[@start-value]">
                  <xsl:value-of select="parent::cnx:list/@start-value"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="parent::cnx:list/@number-style='upper-alpha'">
                <xsl:number value="position() + $start-value - 1" format="A"/>
              </xsl:when>
              <xsl:when test="parent::cnx:list/@number-style='lower-alpha'">
                <xsl:number value="position() + $start-value - 1" format="a"/>
              </xsl:when>
              <xsl:when test="parent::cnx:list/@number-style='upper-roman'">
                <xsl:number value="position() + $start-value - 1" format="I"/>
              </xsl:when>
              <xsl:when test="parent::cnx:list/@number-style='lower-roman'">
                <xsl:number value="position() + $start-value - 1" format="i"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:number value="position() + $start-value - 1"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="parent::cnx:list[@mark-suffix]">
                <xsl:value-of select="$after"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>.</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\textbf{</xsl:text>
            <xsl:value-of select="$before"/>
            <xsl:choose>
              <xsl:when test="normalize-space(parent::cnx:list/@bullet-style)='open-circle'">
                <xsl:text>\ensuremath{\circ}</xsl:text>
              </xsl:when>
              <xsl:when test="normalize-space(parent::cnx:list/@bullet-style)='pilcrow'">
                <xsl:text>\P{}</xsl:text>
              </xsl:when>
              <xsl:when test="normalize-space(parent::cnx:list/@bullet-style)='rpilcrow'">
                <xsl:text>\protect\reflectbox{\P}</xsl:text>
              </xsl:when>
              <xsl:when test="normalize-space(parent::cnx:list/@bullet-style)='asterisk'">
                <xsl:text>\ensuremath{\ast}</xsl:text>
              </xsl:when>
              <xsl:when test="normalize-space(parent::cnx:list/@bullet-style)='dash'">
                <xsl:text>-</xsl:text>
              </xsl:when>
              <xsl:when test="normalize-space(parent::cnx:list/@bullet-style)='section'">
                <xsl:text>\S{}</xsl:text>
              </xsl:when>
              <xsl:when test="normalize-space(parent::cnx:list/@bullet-style)='none'"></xsl:when>
              <xsl:when test="normalize-space(parent::cnx:list/@bullet-style) = 'bullet' or not(parent::cnx:list[@bullet-style])">
                <xsl:text>\textbullet{}</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="parent::cnx:list/@bullet-style"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="parent::cnx:list[@mark-suffix]">
              <xsl:value-of select="$after"/>
            </xsl:if>
            <xsl:text>} </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
	      <xsl:apply-templates select="*[not(self::cnx:label)]|text()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$parent-type='labeled-item'">
            <xsl:variable name="label">
              <xsl:if test="cnx:label">
                <xsl:value-of select="$before"/>
                <xsl:apply-templates select="cnx:label/node()"/>
                <xsl:choose>
                  <xsl:when test="parent::cnx:list[@mark-suffix]">
                    <xsl:value-of select="$after"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>:</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:variable>
            \item[<xsl:value-of select="$label"/>]
          </xsl:when>
          <xsl:when test="$parent-type='enumerated'">  
            <xsl:text>\item </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\item </xsl:text>
          </xsl:otherwise>
	      </xsl:choose>
	      <xsl:apply-templates select="*[not(self::cnx:label)]|text()" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="following-sibling::cnx:item">
      <xsl:choose>
        <xsl:when test="parent::cnx:list[@item-sep]">
          <xsl:value-of select="parent::cnx:list/@item-sep"/>
        </xsl:when>
        <xsl:when test="parent::cnx:list[@display='inline']">
          <xsl:text>;</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="parent::cnx:list[@display='inline']">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cnx:item" mode="cnxml-0.7">
    <!-- 'cnxml-0.6' mode works for 0.7 as well. -->
    <xsl:apply-templates select="self::cnx:item" mode="cnxml-0.6"/>
  </xsl:template>

<!-- CODE :) -->
  <!-- FIXME: I don't think that 'codeblock' will ever occur in the 
       'http://cnx.rice.edu/cnxml' namespace. I think it is from CNXML 0.4. -->
  <xsl:template match="cnx:codeblock|cnx:codeline|cnx:code">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:variable name="class-values" select="str:tokenize(@class)"/>
    <xsl:choose>
      <xsl:when test="$class-values='listing'">
        <xsl:call-template name="make-figure"/>
      </xsl:when>
      <xsl:when test="@display='block' or (@type='block' and $cnxml-version='0.5') or self::cnx:codeblock">
        <xsl:call-template name="block-code"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="inline-code"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="block-code">
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\noindent</xsl:text>
    <xsl:if test="cnx:label or cnx:title">
      <xsl:text>\textbf{</xsl:text>
      <xsl:if test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
        <xsl:if test="cnx:title">
          <xsl:text>: </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="cnx:title">
        <xsl:apply-templates select="cnx:title/node()"/>
      </xsl:if>
      <xsl:text>}</xsl:text>
      <xsl:call-template name="end-label"/>
    </xsl:if>
    \begin{alltt}
    <xsl:apply-templates select="node()[not(self::cnx:label or self::cnx:title)]"/>
    <xsl:text>\end{alltt}</xsl:text>
  </xsl:template>

  <xsl:template name="inline-code">
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\texttt{</xsl:text><xsl:apply-templates />
    <xsl:text>}</xsl:text>
  </xsl:template>

<!-- EMPHASIS -->
  <xsl:template match="cnx:emphasis">
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="string-length(normalize-space(.)) > 0">   
      <xsl:choose>
        <xsl:when test="@effect='italics'">
          <xsl:text>\textsl{</xsl:text><xsl:apply-templates />
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:when test="@effect='underline'">
          <xsl:text>\uline{</xsl:text><xsl:apply-templates />
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:when test="@effect='smallcaps'">
          <xsl:text>\textsc{</xsl:text><xsl:apply-templates />
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:when test="@effect='normal'">
          <xsl:text>\textnormal{</xsl:text><xsl:apply-templates />
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>\textbf{</xsl:text><xsl:apply-templates />
          <xsl:text>}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cnx:foreign">
    <xsl:call-template name="inline-quote"/>
  </xsl:template>

  <xsl:template match="cnx:quote">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@display='block' or (not(@display) and ($cnxml-version='0.6' or $cnxml-version='0.7')) or (@type='block' and $cnxml-version='0.5')">
        <xsl:call-template name="block-quote"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="inline-quote"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- QUOTE/FOREIGN -->
  <xsl:template name="inline-quote">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="string-length(normalize-space(.)) > 0">
      <xsl:variable name="no-marks">
        <xsl:call-template name="class-test">
          <xsl:with-param name="provided-class" select="@class"/>
          <xsl:with-param name="wanted-class" select="'no-marks'"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="before-content">
        <xsl:choose>
          <xsl:when test="self::cnx:foreign">\textsl{</xsl:when>
          <xsl:when test="$no-marks != '1' and $cnxml-version != '0.5'">``</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="after-content">
        <xsl:choose>
          <xsl:when test="self::cnx:foreign">}</xsl:when>
          <xsl:when test="$no-marks != '1' and $cnxml-version != '0.5'">''</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="cnx:label">
        <xsl:text>\textbf{</xsl:text>
        <xsl:apply-templates select="cnx:label/node()"/>
        <xsl:text>: }</xsl:text>
      </xsl:if>
      <xsl:value-of select="$before-content"/><xsl:apply-templates /><xsl:value-of select="$after-content"/>
    </xsl:if>
  </xsl:template>

<!-- CITE -->
  <xsl:template match="cnx:cite">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="$cnxml-version='0.7'">
        <xsl:call-template name="cite07"/>
      </xsl:when>
      <xsl:when test="$cnxml-version='0.6'">
        <xsl:call-template name="cite06"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test='@src'>
            <xsl:text>\textsl{</xsl:text>
            <xsl:apply-templates />
            <xsl:text>}\cite{</xsl:text>
            <xsl:choose>
              <xsl:when test="starts-with(@src,'#')">
                <xsl:value-of select="ancestor::*[local-name()='document']/@id"/>
                <xsl:text>*</xsl:text>
                <xsl:value-of select="substring-after(@src, '#')"/>
                <xsl:text>}</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@src"/><xsl:text>}</xsl:text>
              </xsl:otherwise>
            </xsl:choose>  
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\textsl{</xsl:text><xsl:apply-templates />
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="cite06">
    <xsl:param name="quote-addition"/>
    <xsl:variable name="target-id">
      <xsl:choose>
        <xsl:when test="@target-id">
          <xsl:value-of select="@target-id"/>
        </xsl:when>
        <xsl:when test="@document and not(@resource)">
          <xsl:value-of select="@document"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="target-nodes" select="key('by-id', $target-id)"/>
    <xsl:variable name="target-node" select="$target-nodes[1]"/>
    <xsl:value-of select="$quote-addition"/>
    <xsl:apply-templates />
    <xsl:if test="normalize-space($quote-addition)">
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:if test="node() and $target-node"><xsl:text> </xsl:text></xsl:if>
    <xsl:choose>
      <!-- Inside of module/collection and pointing to a bib entry -->
      <xsl:when test="not($target-node/ancestor::referenced-objects) and local-name($target-node)='entry'">
        <xsl:text>\cite{</xsl:text>
        <xsl:value-of select="$target-id"/>
        <xsl:text>}</xsl:text>  
      </xsl:when>
      <!-- Inside of module/collection and pointing to a different element -->
      <xsl:when test="not($target-node/ancestor::referenced-objects) and $target-node">
        <xsl:text>(p. \pageref{</xsl:text>
        <xsl:value-of select="$target-id"/>
        <xsl:text>})</xsl:text>
      </xsl:when>
      <!-- In a different module/collection and pointing to a bib entry -->
      <xsl:when test="$target-node/ancestor::referenced-objects and local-name($target-node)='entry'">
        <xsl:variable name="data">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="$target-node//*[local-name()='title']"/>
          <xsl:text>", referenced &lt;</xsl:text>
          <xsl:call-template name="escape-octothorpe">
            <xsl:with-param name="data">
              <xsl:call-template name="make-cnxn-URI">
                <xsl:with-param name="DOC_ID" select="substring-before($target-id, '*')"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:text>\#</xsl:text>
          <xsl:value-of select="substring-after($target-id,'*')"/>
          <xsl:text>&gt;</xsl:text>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="ancestor::cnx:tgroup or ancestor::cnx:figure">
            <xsl:text>\stepcounter{footnote}\footnotetext{\raggedright{}</xsl:text>
            <xsl:value-of select="$data"/>
            <xsl:text>}
            </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\footnote{</xsl:text>
            <xsl:value-of select="$data"/>
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- In a different module/collection and pointing to a different element or anywhere and pointing to a resource -->
      <xsl:when test="($target-node/ancestor::referenced-objects and $target-node) or @resource">
        <xsl:variable name="data">
          <xsl:call-template name="escape-octothorpe">
            <xsl:with-param name="data">
              <xsl:call-template name="make-cnxn-URI">
                <xsl:with-param name="DOC_ID">
                  <xsl:choose>
                    <xsl:when test="$target-node">
                      <xsl:value-of select="substring-before($target-id,'*')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="substring-before(@resource,'*')"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:text>\#</xsl:text>
          <xsl:choose>
            <xsl:when test="$target-node">
              <xsl:value-of select="substring-after($target-id,'*')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-after(@resource,'*')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="ancestor::cnx:tgroup or ancestor::cnx:figure">
            <xsl:text>\stepcounter{footnote}\footnotetext{\raggedright{}</xsl:text>
            <xsl:value-of select="$data"/>
            <xsl:text>}
            </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\footnote{</xsl:text>
            <xsl:value-of select="$data"/>
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@url">
        <xsl:choose>
          <xsl:when test="ancestor::cnx:tgroup or ancestor::cnx:figure">
            <xsl:text>\stepcounter{footnote}\footnotetext{\raggedright{}</xsl:text>
            <xsl:value-of select="@url"/>
            <xsl:text>}
            </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\footnote{</xsl:text>
            <xsl:value-of select="@url"/>
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="cite07">
    <xsl:param name="quote-addition"/>
    <!-- 'cite06' template works for 0.7 as well. -->
    <xsl:call-template name="cite06">
      <xsl:with-param name="quote-addition" select="$quote-addition"/>
    </xsl:call-template>
  </xsl:template>

<!-- CITE TITLE -->
  <xsl:template match="cnx:cite-title">
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="@pub-type='article' or @pub-type='inbook' or @pub-type='incollection' or @pub-type='inproceedings' or @pub-type='misc' or @pub-type='unpublished'">
        <xsl:text>"</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\textsl{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- QUOTE -->
  <xsl:template name="block-quote">
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\begin{quote}</xsl:text>
    <xsl:if test="cnx:label or cnx:title">
      <xsl:text>\textbf{</xsl:text>
      <xsl:apply-templates select="cnx:label/node()"/>
      <xsl:if test="cnx:title">
        <xsl:if test="cnx:label">
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="cnx:title"/>
      </xsl:if>
      <xsl:text>}</xsl:text>
      <xsl:call-template name="end-label"/>
    </xsl:if>
    <xsl:text>{\sl </xsl:text>
    <xsl:apply-templates select="node()[not(self::cnx:title or self::cnx:label)]"/>
    <xsl:text>} % end \textsl
    </xsl:text>
    <xsl:if test="@src or @url or @document or @target-id or @version">
      <xsl:variable name="url">
        <xsl:choose>
          <xsl:when test="@src"><xsl:value-of select="@src"/></xsl:when>
          <xsl:when test="@url"><xsl:value-of select="@url"/></xsl:when>
          <xsl:when test="@target and not(@document or @version)"><xsl:value-of select="@target"/></xsl:when>
          <xsl:when test="@target-id and not(@document or @version)"><xsl:value-of select="@target-id"/></xsl:when>
          <xsl:otherwise><xsl:call-template name="make-cnxn-URI"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="starts-with($url,'http:')">
          <xsl:text>\textsl{</xsl:text>
          <xsl:text>(\href{</xsl:text>
          <xsl:value-of select="$url"/>
          <xsl:text>})}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="starts-with($url,'#')">
              <xsl:text>\cite{</xsl:text>
              <xsl:value-of select="substring-after($url, '#')"/>
              <xsl:text>}
              </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>\cite{</xsl:text>
              <xsl:value-of select="$url"/>
              <xsl:text>}
              </xsl:text>
            </xsl:otherwise>
          </xsl:choose> 
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:text>\end{quote}
    </xsl:text>
  </xsl:template>

  <!-- CITE in QUOTE -->
  <xsl:template match="cnx:quote/cnx:cite">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$cnxml-version='0.7'">
        <xsl:call-template name="cite07">
          <xsl:with-param name="quote-addition">
            <xsl:text>- \textbf{</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$cnxml-version='0.6'">
        <xsl:call-template name="cite06">
          <xsl:with-param name="quote-addition">
            <xsl:text>- \textbf{</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>- </xsl:text>
        <xsl:choose>
          <xsl:when test='@src'>
            <xsl:text>\textbf{</xsl:text>
            <xsl:apply-templates />
            <xsl:text>}{\rm \cite{</xsl:text>
            <xsl:choose>
              <xsl:when test="starts-with(@src,'#')">
                <xsl:value-of select="substring-after(@src, '#')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@src"/>
              </xsl:otherwise>
            </xsl:choose>  
            <xsl:text>}}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\textbf{</xsl:text>
            <xsl:apply-templates />
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


<!-- NOTE :) -->
  <xsl:template match="cnx:note|cnx:footnote">
    <xsl:choose>
      <xsl:when test="translate(@type, $upper-letters, $lower-letters)='footnote' or self::cnx:footnote">
        <xsl:call-template name="make-footnote"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-note"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make-note">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:variable name="note-type" select="translate(@type, $upper-letters, $lower-letters)"/>
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="@display='inline'">
        <xsl:text>\textsc{</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\begin{note}{</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="($cnxml-version='0.6' or $cnxml-version='0.7') and cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/><xsl:text>: </xsl:text>
      </xsl:when>
      <xsl:when test="string-length(normalize-space(@type)) and $supported-types/cnx:note[@type=$note-type]">
	<xsl:value-of select="$note-type"/><xsl:text>: </xsl:text>
      </xsl:when>
      <xsl:when test="@type and not(string-length(normalize-space(@type)))">
        <xsl:text></xsl:text>
      </xsl:when>
      <xsl:otherwise>
	      <xsl:text>note: </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}</xsl:text>
    <xsl:apply-templates select="node()[not(self::cnx:label or self::cnx:title)]"/>
    <xsl:if test="not(@display='inline')">
      <xsl:text>\end{note}</xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template name="make-footnote">
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="ancestor::cnx:tgroup or ancestor::cnx:figure">
        <xsl:text>\footnotemark{}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\footnote{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
      <!--  <xsl:number format="1" 
      level="any" 
      count="cnx:solution|qml:key|cnx:note[translate(@type, $upper-letters, $lower-letters)='footnote']"/>-->
  </xsl:template>

  <!-- This template will be applied after a table, to make the 
       footnotetext commands that correspond to the footnotemarks in 
       the table. -->
  <xsl:template match="cnx:note[@type='footnote'] | cnx:footnote" mode="table-footnotes">
    <xsl:call-template name="footnote-float-footnotes"/>
  </xsl:template>

  <xsl:template match="cnx:note[@type='footnote'] | cnx:footnote" mode="figure-footnotes">
    <xsl:call-template name="footnote-float-footnotes"/>
  </xsl:template>

  <xsl:template name="footnote-float-footnotes">
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\stepcounter{footnote}\footnotetext{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}
    </xsl:text>
  </xsl:template>

<!-- DEFINITION :) -->
<!-- 
To get the Definition or Rules number concatenate it's modules number
attribute with its own number attribute.-->


  <xsl:template match="cnx:definition|cnx:document//cnx:glossary/cnx:definition">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:call-template name="begin-new-line"/> 
      <xsl:call-template name="add-optional-label"/>
      <xsl:text>\begin{definition}</xsl:text>
      <xsl:text>\noindent\textbf{</xsl:text>
      <xsl:choose>
        <xsl:when test="($cnxml-version='0.6' or $cnxml-version='0.7') and cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Definition</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="@number"><xsl:value-of select="@number"/></xsl:when>
        <xsl:otherwise>
          <xsl:number count="cnx:definition" level="any" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>:}
      </xsl:text>
      <xsl:apply-templates select="cnx:term"/>
      <xsl:call-template name="end-label">
        <xsl:with-param name="context-node" select="cnx:meaning[1]"/>
      </xsl:call-template>
      <xsl:apply-templates select="*[not(self::cnx:term)]"/>
      \end{definition}
  </xsl:template>

  <xsl:template match="cnx:term">
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\textbf{</xsl:text><xsl:apply-templates /><xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="cnx:meaning">
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="count(../cnx:meaning)>1">
      <xsl:if test="position()!=1">\par\noindent </xsl:if>
      <xsl:number level="single" count="cnx:meaning" format="1. "/>
    </xsl:if>
    <xsl:apply-templates/>
 </xsl:template>

  <xsl:template match="cnx:meaning/cnx:name | cnx:meaning/cnx:title">
    <xsl:text>\textbf{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>} </xsl:text>
  </xsl:template>

  <xsl:template match="cnx:seealso">
    <xsl:call-template name="add-optional-label"/>
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    \par\noindent
    \textbf{
    <xsl:choose>
      <xsl:when test="($cnxml-version='0.6' or $cnxml-version='0.7') and cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>See Also</xsl:text>
      </xsl:otherwise>
    </xsl:choose>:}
    <xsl:for-each select="cnx:term">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:for-each>
  </xsl:template>  

<!--  <xsl:template match="cnx:definition/cnx:example"> INDENT
    <xsl:choose>
      <xsl:when test="descendant::cnx:codeblock|descendant::cnx:figure">
	<fo:block> Example:
	  <xsl:apply-templates/>
	</fo:block>
      </xsl:when>
      <xsl:otherwise>
	<fo:inline font-style="italic">(<xsl:apply-templates/>)</fo:inline>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> -->

<!-- RULE ?:) -->
  <xsl:template match="cnx:rule">
    <xsl:variable name="type" select="translate(@type, $upper-letters, $lower-letters)"/>
    <xsl:call-template name="begin-new-line"/>
    <xsl:call-template name="add-optional-label"/>
    \begin{cnxrule}
    <xsl:text>\noindent\textbf{</xsl:text>
    <xsl:call-template name="make-rule-type"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@number">
	<xsl:value-of select="@number"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:number level="any"
		    count="cnx:rule[translate(@type, $upper-letters, $lower-letters)=$type]"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>:} </xsl:text>
    <xsl:choose>
      <xsl:when test="cnx:name">
        <xsl:apply-templates select="cnx:name"/>
      </xsl:when>
      <xsl:when test="cnx:title">
        <xsl:apply-templates select="cnx:title"/>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="end-label">
      <xsl:with-param name="context-node" select="cnx:statement[1]"/>
    </xsl:call-template>
    <xsl:apply-templates select="node()[not(self::cnx:name or self::cnx:title or self::cnx:label)]"/>
    \end{cnxrule}
  </xsl:template>

  <xsl:template name="make-rule-type">
    <xsl:choose>
      <xsl:when test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:when>
      <xsl:when test="$supported-types/cnx:rule[@type=translate(current()/@type, $upper-letters, $lower-letters)]">
        <!-- Capitalize first letter -->
        <xsl:value-of select="translate(substring(
                      normalize-space(@type), 1, 1), $lower-letters, $upper-letters)"/>
        <xsl:value-of select="translate(substring(normalize-space(@type), 2), $upper-letters, $lower-letters)"/>
      </xsl:when>
      <xsl:otherwise>Rule</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:statement">
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="cnx:label or cnx:title or cnx:name">
      <xsl:text>\textbf{</xsl:text>
      <xsl:if test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:if>
      <xsl:if test="cnx:label and (cnx:title or cnx:name)">
        <xsl:text>: </xsl:text>
      </xsl:if>
      <xsl:text>}</xsl:text>
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:apply-templates select="cnx:name"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title"/>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="end-label"/>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::cnx:title or self::cnx:label)]"/>
  </xsl:template>


<!-- PROOF -->
  <xsl:template match="cnx:proof">
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\noindent\textbf{</xsl:text>
    <xsl:choose>
      <xsl:when test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Proof</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="count(cnx:proof)>1">
      <xsl:text> </xsl:text><xsl:number />
    </xsl:if>
    <xsl:text>:} </xsl:text>
    <xsl:choose>
      <xsl:when test="cnx:name">
        <xsl:apply-templates select="cnx:name"/>
      </xsl:when>
      <xsl:when test="cnx:title">
        <xsl:apply-templates select="cnx:title"/>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="end-label"/>
    <xsl:apply-templates select="node()[not(self::cnx:title or self::cnx:name)]"/>
    <xsl:call-template name="end-label"/>
  </xsl:template>

<!-- EXAMPLE ?:) -->
  <xsl:template match="cnx:example">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:call-template name="begin-new-line"/>
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\begin{example}</xsl:text>
    <xsl:text>\noindent\textbf{</xsl:text>
    <xsl:choose>
      <xsl:when test="($cnxml-version='0.6' or $cnxml-version='0.7') and cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Example</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not(ancestor::cnx:definition|ancestor::cnx:rule|
                      ancestor::cnx:exercise|ancestor::cnx:text|
                      ancestor::cnx:longdesc|ancestor::cnx:footnote|
                      ancestor::cnx:entry)">
      <xsl:text> </xsl:text> 
      <xsl:if test="@number">
        <xsl:value-of select="@number"/>
      </xsl:if>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="cnx:name">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="cnx:name"/>
      </xsl:when>
      <xsl:when test="cnx:title">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="cnx:title"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>}</xsl:text>
    <xsl:call-template name="end-label"/>
    <xsl:apply-templates select="node()[not(self::cnx:name or self::cnx:title)]"/>
    <xsl:if test="following-sibling::node()[normalize-space()][1][self::cnx:example] and not(child::node()[normalize-space()][last()][self::cnx:exercise])">
      <xsl:text>\vspace{2pt}</xsl:text>
    </xsl:if>
    \end{example}
    \noindent
  </xsl:template>

<!-- EXERCISE -->
  <xsl:template match="cnx:exercise">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:variable name="exercise-label">
      <xsl:choose>
        <xsl:when test="($cnxml-version='0.6' or $cnxml-version='0.7') and cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:when test="ancestor::cnx:example">
          <xsl:variable name="example-id" select="ancestor::cnx:example[1]/@id"/>
          <!-- We don't just want preceding siblings of this exercise, we 
               want all descendant elements and text nodes of the ancestor 
               example that precede this exercise and that contain 
               non-whitespace character data. -->
          <xsl:variable name="preceding-nodeset" 
                        select="preceding::node()[ancestor::cnx:example[@id=$example-id]]
                        [not(self::cnx:name or ancestor::cnx:name or self::cnx:title or ancestor::cnx:title) and (self::* or self::text()) and normalize-space()]"/>
          <!-- Display the 'Problem' label if there is more than one 
               exercise child of example, or if there are substantial 
               descendant nodes of the same example that precede this 
               exercise. -->
          <xsl:if test="count(ancestor::cnx:example//cnx:exercise) &gt; 1 or count($preceding-nodeset/node()) &gt; 0">
            <xsl:text>Problem</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Exercise</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@number">
          <xsl:text> </xsl:text><xsl:value-of select="@number"/>
        </xsl:when>
        <!-- If the exercise is a descendant of example and if it has no 
             @number, don't add anything to the label. -->
        <xsl:when test="ancestor::cnx:example"></xsl:when>
        <xsl:otherwise>
          <xsl:text> </xsl:text><xsl:number count="cnx:exercise" level="any" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="solution" select="key('solution-by-ref', @id)"/>
    <xsl:variable name="solution-label">
      <xsl:choose>
        <xsl:when test="$solution/@id">
          <xsl:call-template name="make-label">
            <xsl:with-param name="instring" select="$solution/@id"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="make-label">
            <xsl:with-param name="instring" select="concat(@id, '*solution')"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="solution-reference">
      <xsl:if test="($solution/@print-placement='end' or processing-instruction('solution_in_back') or not($solution/@print-placement='here' and not(ancestor::cnx:example or @print-placement='here'))) and count($solution) > 0">
        <xsl:text>\hfill{\small \textsl{(Solution</xsl:text>
        <xsl:if test="count($solution) > 1">
          <xsl:text>s</xsl:text>
        </xsl:if>
        <xsl:text> on p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="$solution-label"/>
        </xsl:call-template>
        <xsl:text>}.)}}</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="begin-new-line"/>
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\begin{exercise}</xsl:text>
    <xsl:if test="normalize-space($exercise-label)">
      <xsl:text>\noindent\textbf{</xsl:text>
      <xsl:value-of select="$exercise-label"/>
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:text>: </xsl:text>
          <xsl:apply-templates select="cnx:name"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:text>: </xsl:text>
          <xsl:apply-templates select="cnx:title"/>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="$solution-reference"/>
      <xsl:text>}</xsl:text>
      <xsl:call-template name="end-label"/>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::cnx:name or self::cnx:title)]"/>
    <xsl:if test="not(@print-placement='end' or parent::*/processing-instruction('solution_in_back') or (not(@print-placement='here') and not(ancestor::cnx:example or parent::cnx:exercise[@print-placement='here']))) and following-sibling::node()[normalize-space()][1][self::cnx:exercise]">
      <xsl:text>\vspace{3pt}</xsl:text>
    </xsl:if>
    \end{exercise}
    \noindent
  </xsl:template>

  <!-- Problem -->
  <xsl:template match="cnx:problem">
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="cnx:label or cnx:title or cnx:name">
      <xsl:text>\textbf{</xsl:text>
      <xsl:if test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:if>
      <xsl:if test="cnx:label and (cnx:title or cnx:name)">
        <xsl:text>: </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:apply-templates select="cnx:name"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title"/>
        </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:call-template name="end-label"/>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::cnx:name or self::cnx:title)]"/>
    <xsl:if test="following-sibling::node()[normalize-space()][1][self::cnx:solution or self::cnx:commentary]">
      <xsl:text>\vspace{5pt}</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <!-- Solution -->
  <xsl:template match="cnx:solution|solutions/qml:answers">
    <xsl:variable name="moduleid" select="substring-before(@ref, '*')"/>
    <xsl:variable name="exercise-parent" select="key('exercise-by-id', @ref)"/>
    <xsl:variable name="qmlitem-parent" select="key('qmlitem-by-id', @ref)"/>
    <xsl:variable name="exercise_num">
      <xsl:choose>
        <xsl:when test="count($exercise-parent)">
          <xsl:value-of select="$exercise-parent/@number"/>
        </xsl:when>
        <xsl:when test="count($qmlitem-parent)">
          <xsl:value-of select="$qmlitem-parent/@number"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="exercise_reference" select="@ref"/>
    <xsl:variable name="solution-label">
      <xsl:choose>
        <xsl:when test="@id">
          <xsl:call-template name="make-label">
	    <xsl:with-param name="instring" select="@id" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="make-label">
            <xsl:with-param name="instring" select="concat(@ref, '*solution')" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\label{</xsl:text>
    <xsl:value-of select="$solution-label"/>
    <xsl:text>}\noindent\textbf{</xsl:text>
    <xsl:choose>
      <xsl:when test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Solution</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <!-- Solution is placed at the end, so page reference, etc. needed -->
    <xsl:variable name="exercise_parent_id" select="parent::cnx:exercise/@id"/>
    <xsl:choose>
      <xsl:when test="@print-placement='end' or parent::*/processing-instruction('solution_in_back') or (not(@print-placement='here') and not(ancestor::cnx:example or parent::cnx:exercise[@print-placement='here']))">
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:value-of select="@number"/>
            <xsl:text> </xsl:text>
          </xsl:when>
          <!-- FIXME: this case may no longer be necessary. -->
          <xsl:when test="count($exercise-parent/cnx:solution | ancestor::*[local-name()='document']//cnx:solution[@ref = $exercise_reference]) &gt; 1">
            <xsl:number level="any" from="*[local-name()='document']" count="cnx:solution[parent::cnx:exercise[@id=$exercise_reference] or @ref = $exercise_reference]" format="A"/>
            <xsl:text> </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text>to </xsl:text>
        <xsl:choose>
          <xsl:when test="$exercise-parent/ancestor::cnx:example">
            <xsl:text>Example </xsl:text>
            <xsl:value-of select="$exercise-parent/ancestor::cnx:example[1]/@number"/>
            <xsl:if test="$exercise_num">
              <xsl:text>, Problem </xsl:text>
              <xsl:value-of select="$exercise_num"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Exercise </xsl:text>
            <xsl:value-of select="$exercise_num"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> (p. \pageref{</xsl:text>
          <xsl:call-template name="make-label">
             <xsl:with-param name="instring" select="@ref"/>
          </xsl:call-template>
        <xsl:text>})</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:value-of select="@number"/>
          </xsl:when>
          <!-- FIXME: this case may no longer be necessary. -->
          <xsl:when test="count(parent::cnx:exercise/cnx:solution | ancestor::*[local-name()='document']//cnx:solution[@ref = $exercise_parent_id]) &gt; 1">
            <xsl:number level="any" from="*[local-name()='document']" count="cnx:solution[parent::cnx:exercise[@id=$exercise_parent_id] or @ref = $exercise_parent_id]" format="A"/>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="cnx:name">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="cnx:name"/>
      </xsl:when>
      <xsl:when test="cnx:title">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="cnx:title"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>}</xsl:text>
    <xsl:if test="not(self::qml:answers)">
      <xsl:call-template name="end-label"/>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::cnx:name or self::cnx:title or self::cnx:label)]"/>
    <xsl:if test="self::qml:answers">
      <xsl:text>\par
      </xsl:text>
    </xsl:if>
    <xsl:if test="not(@print-placement='end' or parent::*/processing-instruction('solution_in_back') or (not(@print-placement='here') and not(ancestor::cnx:example or parent::cnx:exercise[@print-placement='here'])))">
      <xsl:if test="not(child::node()[normalize-space()][not(self::cnx:name or self::cnx:title)][last()][self::cnx:list] or child::node()[normalize-space()][not(self::cnx:name or self::cnx:title)][last()][self::cnx:para]/node()[normalize-space()][last()][self::cnx:list])">
        <xsl:text>\vspace{5pt}</xsl:text>
      </xsl:if>
      <xsl:text>\par\noindent{}</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- COMMENTARY -->
  <xsl:template match="cnx:commentary">
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="cnx:label or cnx:title">
      <xsl:text>\noindent\textbf{</xsl:text>
      <xsl:if test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:if>
      <xsl:if test="cnx:title">
        <xsl:if test="cnx:label">
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="cnx:title"/>
      </xsl:if>
      <xsl:text>}</xsl:text>
      <xsl:call-template name="end-label"/>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::cnx:label or self::cnx:title)]"/>
    <xsl:if test="not(child::node()[normalize-space()][not(self::cnx:title)][last()][self::cnx:list] or child::node()[normalize-space()][not(self::cnx:title)][last()][self::cnx:para]/node()[normalize-space()][last()][self::cnx:list])">
      <xsl:text>\vspace{5pt}</xsl:text>
    </xsl:if>
    <xsl:text>\par\noindent{}</xsl:text>
  </xsl:template>

  <!-- SUB -->
  <xsl:template match="cnx:sub">
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\begin{math}_\text{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}\end{math}</xsl:text>
  </xsl:template>
  
  <!-- SUP -->
  <xsl:template match="cnx:sup">
    <xsl:call-template name="add-optional-label"/>
    <xsl:text>\begin{math}^\text{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}\end{math}</xsl:text>
  </xsl:template>
  
  <!-- EQUATION -->
  <xsl:template match="cnx:equation">
    <xsl:call-template name="add-optional-label"/>
    <xsl:if test="cnx:label or cnx:name or cnx:title">
      \vspace{\rubberspace}\par\noindent\textbf{
      <xsl:apply-templates select="cnx:label/node()"/>
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:apply-templates select="cnx:name"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:if test="cnx:label">
            <xsl:text>: </xsl:text>
          </xsl:if>
          <xsl:apply-templates select="cnx:title"/>
        </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text>\nopagebreak\noindent{}</xsl:text>
    <xsl:choose>
      <xsl:when test="m:math">
        <xsl:apply-templates select="node()[not(self::cnx:name) and not(self::cnx:title) and not(self::cnx:label)]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-nonmath-equation"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:equation/*[local-name()='math']">
    <xsl:call-template name="math-disarray"/>
      <xsl:text>\typeout{math as usual width = \the\mymathboxwidth}
    </xsl:text>
  </xsl:template>

<!--FIGURE -->
  <xsl:template match="cnx:figure">
    <xsl:call-template name="make-figure"/>
  </xsl:template>

  <xsl:template name="make-figure">
    <xsl:param name="pinimage">[H]</xsl:param>
    <xsl:variable name="orient">
      <xsl:choose>
        <xsl:when test="@orient">
          <xsl:value-of select="@orient"/>
        </xsl:when>
        <xsl:otherwise>horizontal</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="figure-rule">
      <xsl:if test="parent::cnx:section or parent::cnx:content">
        <xsl:text>\rule[.1in]{\figurerulewidth}{.005in} \\
        </xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="footnote-count">
      <xsl:call-template name="count-footnotes"/>
    </xsl:variable>
    \setcounter{subfigure}{0}
    \begin{figure}<xsl:value-of select="$pinimage"/> % <xsl:value-of select="$orient"/>
    <xsl:call-template name="add-optional-label"/>
    \begin{center}
    <xsl:value-of select="$figure-rule"/>
    <xsl:choose>
      <xsl:when test="self::cnx:figure">
        <xsl:apply-templates select="cnx:name | cnx:title | cnx:media | cnx:subfigure |
                             cnx:table | cnx:codeblock | cnx:code"/>
      </xsl:when>
      <xsl:when test="self::cnx:code">
        <xsl:apply-templates select="cnx:name|cnx:title"/>
        <xsl:text>\begin{alltt}
        </xsl:text>
        <xsl:apply-templates select="node()[not(self::cnx:name or self::cnx:title or self::cnx:caption)]"/>
        <xsl:text>\end{alltt}
        </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="caption"/>
    \vspace{.1in}
    <xsl:value-of select="$figure-rule"/>
    \end{center}
    \end{figure}
    \addtocounter{footnote}{-<xsl:value-of select="$footnote-count"/>}
    <xsl:if test="$debug-mode > 0"><!-- FIXME 0.6? -->
      \addtocounter{footnote}{-<xsl:value-of select="count(descendant::cnx:cnxn)"/>}
    </xsl:if>
    <xsl:apply-templates select="descendant::cnx:link|descendant::cnx:cnxn|descendant::cnx:note[translate(@type, $upper-letters, $lower-letters)='footnote']" mode="figure-footnotes"/>
  </xsl:template>

  <xsl:template name="caption">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="descendant::cnx:caption[string-length(normalize-space()) > 0]">
	<xsl:text>\begin{cnxcaption}
	  \small \textbf{</xsl:text>
      <xsl:choose>
        <xsl:when test="($cnxml-version='0.6' or $cnxml-version='0.7') and cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:when test="self::cnx:figure">
          <xsl:text>Figure</xsl:text>
        </xsl:when>
        <xsl:when test="self::cnx:code">
          <xsl:text>Listing</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>	    
	<xsl:choose>
	  <xsl:when test="@number">
	    <xsl:value-of select="@number"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:number count="cnx:figure" level="any" />
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:text>: }</xsl:text>
	<xsl:apply-templates select="cnx:caption" />
	<xsl:for-each select="cnx:subfigure">
	  <xsl:if test="cnx:caption">  
            <xsl:text> (</xsl:text>
            <xsl:choose>
              <xsl:when test="@number">
                <xsl:value-of select="@number"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:number level="single" count="cnxml:subfigure[translate(@type, $upper-letters, $lower-letters)=$type]" format="a" />
              </xsl:otherwise>
            </xsl:choose>
	    <xsl:text>) </xsl:text>
	    <xsl:apply-templates select="cnx:caption"/>
	  </xsl:if>
	</xsl:for-each>
	\end{cnxcaption}
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>\begin{center}\small\bfseries </xsl:text>
	<xsl:choose>
          <xsl:when test="($cnxml-version='0.6' or $cnxml-version='0.7') and cnx:label">
            <xsl:apply-templates select="cnx:label/node()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Figure</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
	  <xsl:when test="@number">
	    <xsl:value-of select="@number"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:number count="cnx:figure" level="any" />
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:text>\end{center}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Subfigure -->
  <xsl:template match="cnx:subfigure">
    <xsl:variable name="moduleid">
      <xsl:call-template name="module-id"/>
    </xsl:variable>
    <xsl:if test="number($debug-mode) > 0 and cnx:media[@src]">
      <!-- When debug-mode is enabled, display the name of the media file, 
           if any, before the LaTeX \subfigure command; in other cases, the 
           debug info is added in the template for cnx:media. -->
      <xsl:text>\textbf{\ensuremath{\gg}</xsl:text>
      <xsl:value-of select="$moduleid"/>
      <xsl:text>\_</xsl:text>
      <xsl:value-of select="cnx:media/@src"/>
      <xsl:text>\ensuremath{\ll}}</xsl:text>
      <xsl:text> \\
      </xsl:text>
    </xsl:if>
    <xsl:text>\subfigure[</xsl:text>
    <xsl:choose>
      <xsl:when test="cnx:name">
        <xsl:apply-templates select="cnx:name"/>
      </xsl:when>
      <xsl:when test="cnx:title">
        <xsl:apply-templates select="cnx:title"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>]</xsl:text>
    <xsl:text>{</xsl:text>
    <xsl:call-template name="add-optional-label"/>
    <xsl:apply-templates select="cnx:media | cnx:codeblock | cnx:table"/>
    <xsl:text>}
    </xsl:text>
    <xsl:choose>
      <xsl:when test="../@orient='vertical' and not(cnx:subfigure[last()])">
        <xsl:text>\\
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\hspace{.1in}
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

<!-- MEDIA :) -->
  <xsl:template match="cnx:media">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:call-template name="add-optional-label"/>
    <xsl:choose>
      <xsl:when test="$cnxml-version='0.7'">
        <xsl:apply-templates select="self::cnx:media" mode="cnxml-0.7"/>
      </xsl:when>
      <xsl:when test="$cnxml-version='0.6'">
        <xsl:apply-templates select="self::cnx:media" mode="cnxml-0.6"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="self::cnx:media" mode="cnxml-0.5"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="output-image">
    <xsl:param name="print-width"/>
    <xsl:param name="src"/>
    <xsl:param name="moduleid"/>
    <xsl:param name="screen-width"/>
    <xsl:param name="screen-height"/>
    <xsl:variable name="comment-separator" select="';'"/>
    <xsl:choose>
      <!-- We consider an image whose @src begins with 'http://' and that 
           doesn't have a Connexions domain in it to be an external image; 
           we don't fetch these or display them in the collection PDF - we 
           just display a note with the URL for the reader. -->
      <xsl:when test="starts-with($src, 'http://') and 
                not(contains($src, 'cnx.org') or 
                contains($src, 'cnx.rice.edu'))">
        <xsl:text>{\large External Image} \\
        </xsl:text>
        <xsl:text>Please see: \\
        </xsl:text>
        <xsl:value-of select="$src"/>
        <xsl:text> \\
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="graphics-path">
          <xsl:choose>
            <xsl:when test="contains(/module/cnx:document/module-export/base/@href, 'GroupWorkspaces') or 
                      contains(/module/cnx:document/module-export/base/@href, 'Members')">
              <xsl:text>file:</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$CNX_CONTENT_URI_LOCAL"/>
              <xsl:text>/</xsl:text>
              <xsl:value-of select="$moduleid"/>
              <xsl:text>/</xsl:text>
              <xsl:choose>
                <xsl:when test="$moduleversion">
                  <xsl:value-of select='$moduleversion'/>
                  <xsl:text>/</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>latest/</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="child-media" select="cnx:media/@src"/>
        <xsl:text>\includegraphics</xsl:text>
        <xsl:value-of select="$print-width"/>
        <xsl:text>{</xsl:text>
        <xsl:value-of select="$graphics-path"/>
        <xsl:call-template name="unescape-underscore">
          <xsl:with-param name="instring" select="$src"/>
        </xsl:call-template>
        <xsl:text>} % </xsl:text>
        <xsl:value-of select="$moduleid"/><xsl:value-of select="$comment-separator"/>
        <xsl:value-of select="$src"/><xsl:value-of select="$comment-separator"/>
        <xsl:value-of select="$screen-width"/><xsl:value-of select="$comment-separator"/>
        <xsl:value-of select="$screen-height"/><xsl:value-of select="$comment-separator"/>
        <xsl:value-of select="$graphics-max-width"/><xsl:value-of select="$comment-separator"/>
        <xsl:value-of select="$graphics-max-height"/><xsl:value-of select="$comment-separator"/>
        <xsl:value-of select="$child-media"/><xsl:text>
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:media[starts-with(@type,'image') or @type='application/postscript']" mode="cnxml-0.5">
    <xsl:variable name="moduleid">
      <xsl:call-template name="module-id"/>
    </xsl:variable>
    <xsl:variable name="moduleversion">
      <xsl:call-template name="module-version">
        <xsl:with-param name="moduleid" select="$moduleid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="print-width">
      <xsl:if test="descendant::cnx:param[@name='print-width']">
        <xsl:text>[width=</xsl:text>
        <xsl:value-of select="descendant::cnx:param[@name='print-width']/@value"/>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="screen-width">
      <xsl:value-of select="cnx:param[@name='width']/@value"/>
    </xsl:variable>
    <xsl:variable name="screen-height">
      <xsl:value-of select="cnx:param[@name='height']/@value"/>
    </xsl:variable>
    <xsl:variable name="src" select="normalize-space(@src)"/>
    <xsl:if test="@id">
      \label{<xsl:call-template name="make-label">
	<xsl:with-param name="instring" select="@id" />
      </xsl:call-template>}
    </xsl:if>
    <xsl:if test="number($debug-mode) > 0 and not(parent::cnx:subfigure)">
      <!-- When debug-mode is enabled, display the name of the media file; 
           the template for subfigures adds its own debug info for media 
           elements, before the LaTeX \subfigure command. -->
      <xsl:text>\textbf{\ensuremath{\gg}</xsl:text>
      <xsl:value-of select="$moduleid"/>
      <xsl:text>\_</xsl:text>
      <xsl:value-of select="$src"/>
      <xsl:text>\ensuremath{\ll}}</xsl:text>
      <xsl:if test="parent::cnx:figure">
        <xsl:text> \\</xsl:text>
      </xsl:if>
      <xsl:text>
      </xsl:text>
    </xsl:if>
    <xsl:call-template name="output-image">
      <xsl:with-param name="print-width" select="$print-width"/>
      <xsl:with-param name="src" select="$src"/>
      <xsl:with-param name="moduleid" select="$moduleid"/>
      <xsl:with-param name="screen-width" select="$screen-width"/>
      <xsl:with-param name="screen-height" select="$screen-height"/>
    </xsl:call-template>
    <xsl:if test="not(ancestor::cnx:figure) and following-sibling::*[1][self::cnx:para or self::cnx:exercise or self::cnx:example or self::cnx:rule or self::cnx:definition]">
      <xsl:variable name="text-length">
        <xsl:call-template name="text-string-length">
          <xsl:with-param name="context-node" 
                          select="following-sibling::node()[1]"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$text-length = 0">
        <xsl:text>\par
        </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="cnx:media[@type='application/x-java-applet']" mode="cnxml-0.5">
    <xsl:variable name="moduleid">
      <xsl:call-template name="module-id"/>
    </xsl:variable>
    <xsl:variable name="moduleversion">
      <xsl:call-template name="module-version">
        <xsl:with-param name="moduleid" select="$moduleid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="cnx:media">
	<xsl:apply-templates select="cnx:media"/>
	Online this image is a Java Applet.  To view please see <xsl:value-of select="$CNX_CONTENT_URI"/>/<xsl:choose>
	  <xsl:when test="$moduleid"><xsl:value-of select='$moduleid'/>/</xsl:when>
	  <xsl:otherwise><xsl:value-of select="ancestor::*[local-name()='document']/@id" />/</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	  <xsl:when test="$moduleversion"><xsl:value-of select='$moduleversion'/>/
	  </xsl:when>
	  <xsl:otherwise>latest/
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>    
      <xsl:otherwise>
	<xsl:if test="@id">
	  \label{<xsl:call-template name="make-label">
	    <xsl:with-param name="instring" select="@id" />
	  </xsl:call-template>}
	</xsl:if>
	This is a Java Applet.  To view, please see <xsl:value-of select="$CNX_CONTENT_URI"/>/<xsl:choose>
	  <xsl:when test="$moduleid"><xsl:value-of select='$moduleid'/>/</xsl:when>
	  <xsl:otherwise><xsl:value-of select="ancestor::*[local-name()='document']/@id" />/</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	  <xsl:when test="$moduleversion"><xsl:value-of select='$moduleversion'/>/</xsl:when>
	  <xsl:otherwise>latest/</xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>   
  </xsl:template>


  <xsl:template match="cnx:media" mode="cnxml-0.5">
    <xsl:variable name="moduleid">
      <xsl:call-template name="module-id"/>
    </xsl:variable>
    <xsl:variable name="moduleversion">
      <xsl:call-template name="module-version">
        <xsl:with-param name="moduleid" select="$moduleid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="cnx:media">
	<xsl:apply-templates select="cnx:media"/>
	Online this image is a media object. To view please see <xsl:value-of select="$CNX_CONTENT_URI"/>/<xsl:choose>
	  <xsl:when test="$moduleid"><xsl:value-of select='$moduleid'/>/</xsl:when>
	  <xsl:otherwise><xsl:value-of select="ancestor::*[local-name()='document']/@id" />/</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	  <xsl:when test="$moduleversion"><xsl:value-of select='$moduleversion'/>/}
	  </xsl:when>
	  <xsl:otherwise>latest/}
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:if test="@id">
	  \label{<xsl:call-template name="make-label">
	    <xsl:with-param name="instring" select="@id" />
	  </xsl:call-template>}
	</xsl:if>
    \begin{center}
    \rule[.1in]{4.75in}{.005in} \\
	This is an unsupported media type.  To view, please see
	<xsl:value-of select="$CNX_CONTENT_URI"/><xsl:text>/</xsl:text>
        <!-- Add module ID -->
        <xsl:value-of select='$moduleid'/><xsl:text>/</xsl:text>
        <!-- Add version -->
	<xsl:choose>
	  <xsl:when test="$moduleversion">
            <xsl:value-of select='$moduleversion'/><xsl:text>/</xsl:text>
          </xsl:when>
	  <xsl:otherwise>
            <xsl:text>latest/</xsl:text>
          </xsl:otherwise>
	</xsl:choose>
    <xsl:value-of select="@src"/> \\
    \rule[.1in]{4.75in}{.005in}
    \end{center} \\
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Since there are no collisions between cnxml 0.5 element names and the 
       new cnxml 0.6 media object element names, we don't need to use @mode 
       when defining and applying templates.  Add later if needed. -->
  <xsl:template match="cnx:media" mode="cnxml-0.6">
    <xsl:variable name="second-media-object" select="*[self::cnx:object or self::cnx:image or self::cnx:audio or self::cnx:video or self::cnx:java-applet or self::cnx:flash or self::cnx:labview or self::cnx:text or self::cnx:download][2]"/>
    <xsl:choose>
      <xsl:when test="$second-media-object">
        <xsl:apply-templates select="$second-media-object"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[self::cnx:object or self::cnx:image or self::cnx:audio or self::cnx:video or self::cnx:java-applet or self::cnx:flash or self::cnx:labview or self::cnx:text or self::cnx:download][1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:media" mode="cnxml-0.7">
    <xsl:choose>
      <xsl:when test="*[@for='pdf']">
        <xsl:apply-templates select="*[@for='pdf'][1]"/>
      </xsl:when>
      <xsl:when test="*[@for='default']">
        <xsl:apply-templates select="*[@for='default'][1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[self::cnx:object or self::cnx:image or self::cnx:audio or self::cnx:video or self::cnx:java-applet or self::cnx:flash or self::cnx:labview or self::cnx:text or self::cnx:download][not(@for='online')][1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:image">
    <xsl:variable name="moduleid">
      <xsl:call-template name="module-id"/>
    </xsl:variable>
    <xsl:variable name="moduleversion">
      <xsl:call-template name="module-version">
        <xsl:with-param name="moduleid" select="$moduleid"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="print-width">
      <xsl:if test="@print-width">
        <xsl:text>[width=</xsl:text>
        <xsl:value-of select="@print-width"/>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="screen-width">
      <xsl:value-of select="@width"/>
    </xsl:variable>
    <xsl:variable name="screen-height">
      <xsl:value-of select="@height"/>
    </xsl:variable>
    <xsl:variable name="src" select="normalize-space(@src)"/>
    <xsl:choose>
      <xsl:when test="parent::cnx:media/@display='block' or ancestor::cnx:figure">
        <xsl:call-template name="make-div">
          <xsl:with-param name="data">
            <xsl:call-template name="output-image">
              <xsl:with-param name="print-width" select="$print-width"/>
              <xsl:with-param name="src" select="$src"/>
              <xsl:with-param name="moduleid" select="$moduleid"/>
              <xsl:with-param name="screen-width" select="$screen-width"/>
              <xsl:with-param name="screen-height" select="$screen-height"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="output-image">
          <xsl:with-param name="print-width" select="$print-width"/>
          <xsl:with-param name="src" select="$src"/>
          <xsl:with-param name="moduleid" select="$moduleid"/>
          <xsl:with-param name="screen-width" select="$screen-width"/>
          <xsl:with-param name="screen-height" select="$screen-height"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- media/text gets processed normally for now. -->
  <xsl:template match="cnx:text">
    <xsl:choose>
      <!-- Block media. -->
      <xsl:when test="parent::cnx:media/@display='block' or ancestor::cnx:figure">
        <xsl:call-template name="make-div">
          <xsl:with-param name="data">
            <xsl:apply-templates/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <!-- Inline media. -->
      <xsl:otherwise>
        <xsl:text>\textsc{[Media Object]}\footnote{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>} </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:object|cnx:audio|cnx:video|cnx:java-applet|cnx:flash|cnx:labview|cnx:download">
    <xsl:choose>
      <!-- Block media. -->
      <xsl:when test="parent::cnx:media/@display='block' or ancestor::cnx:figure">
        <xsl:call-template name="make-div">
          <xsl:with-param name="data">
            <xsl:call-template name="output-media-backup"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <!-- Inline media. -->
      <xsl:otherwise>
        <xsl:text>\textsc{[Media Object]}\footnote{</xsl:text>
        <xsl:call-template name="output-media-backup"/>
        <xsl:text>} </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="output-media-backup">
    <xsl:variable name="module-publishing" select="ancestor::module[1]/publishing"/>
    <xsl:variable name="nearest-ancestor-id" select="ancestor::*[@id][1]/@id"/>
    <xsl:variable name="default-message">
      <xsl:text>This media object is </xsl:text>
      <xsl:choose>
        <xsl:when test="self::cnx:object">of an unspecified type</xsl:when>
        <xsl:when test="self::cnx:audio">an audio file</xsl:when>
        <xsl:when test="self::cnx:video">a video file</xsl:when>
        <xsl:when test="self::cnx:java-applet">a Java applet</xsl:when>
        <xsl:when test="self::cnx:flash">a Flash object</xsl:when>
        <xsl:when test="self::cnx:labview">a LabVIEW VI</xsl:when>
        <xsl:when test="self::cnx:download">a downloadable file</xsl:when>
      </xsl:choose>
      <xsl:text>.  Please view or download it at \\
        &lt;</xsl:text>
      <xsl:choose>
        <xsl:when test="starts-with(@src,'http') or starts-with(@src,'www.')">
          <xsl:value-of select="@src"/>
        </xsl:when>
        <xsl:when test="starts-with(@src,'/')">
          <xsl:value-of select="'http://'"/><xsl:value-of select="$CNX_DISPLAY_HOSTNAME"/>
          <xsl:value-of select="@src"/>
        </xsl:when>
        <xsl:when test="normalize-space(@src)">
          <xsl:value-of select="ancestor::module/cnx:document/module-export/base/@href"/>
          <xsl:value-of select="@src"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::module/cnx:document/module-export/base/@href"/>
          <xsl:text>\#</xsl:text>
          <xsl:value-of select="substring-after($nearest-ancestor-id, '*')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&gt;
      </xsl:text>
    </xsl:variable>
    <xsl:choose>
      <!-- We have back-up content: use it. -->
      <xsl:when test="*[not(self::cnx:param)] or text()[string-length(normalize-space(.)) &gt; 0]">
        <xsl:text>% woof
        </xsl:text>
        <xsl:apply-templates/>
      </xsl:when>
      <!-- No back-up content: use the default message for this object type. -->
      <xsl:otherwise>
        <xsl:value-of select="$default-message"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Is there a good name for this template?  I need to count the number of 
       non-whitespace characters in text nodes following the context node 
       before the next element sibling in order to decide in the media 
       template whether or not I need a \par command to clear following text 
       from the line on which the media is displayed. -->
  <xsl:template name="text-string-length">
    <xsl:param name="context-node"/>
    <xsl:param name="text-length" select="0"/>
    <xsl:choose>
      <xsl:when test="self::text()">
        <xsl:call-template name="text-string-length">
          <xsl:with-param name="context-node" 
                          select="following-sibling::node()[1]"/>
          <xsl:with-param name="text-length" 
                          select="$text-length+string-length(normalize-space(.))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="self::comment()|self::processing-instruction()">
        <xsl:call-template name="text-string-length">
          <xsl:with-param name="context-node" 
                          select="following-sibling::node()[1]"/>
          <xsl:with-param name="text-length" 
                          select="$text-length"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text-length"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:figure/cnx:name | cnx:figure/cnx:title | cnx:code/cnx:title">
    \textbf{<xsl:apply-templates />}\vspace{.1in} \nopagebreak\\
  </xsl:template>


<!-- CNXN :) -->
  <!-- Handles cnxn elements in default XSLT mode; 
       - identifies target node of cnxn
       - computes the cnxn-mode for the cnxn ('in-place', 'parenthetical', 
         'footnote')
       - calls cnxn-expansion-dispatch
       - if in debug mode, calls cnxn-debug-footnote -->
  <xsl:template match="cnx:cnxn|cnx:link">
    <xsl:variable name="cnxml-version">
      <xsl:call-template name="get-cnxml-version"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="(self::cnx:link and $cnxml-version='0.5') or self::cnx:link[@url]">
        <xsl:apply-templates select="self::cnx:link" mode="cnxml-0.5"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
        <xsl:choose>
          <!-- Because of XSLT limitations on selecting nodes into variables 
               and on using copy-of to add a bare attribute to an RTF, we 
               need a separate case to handle @resource as a link target. -->
          <xsl:when test="string-length(@resource)">
            <xsl:variable name="cnxn-mode">
              <xsl:call-template name="make-cnxn-mode">
                <xsl:with-param name="target-node" select="@resource"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$debug-mode > 0">
              <xsl:text> % cnxn-mode: </xsl:text>
              <xsl:value-of select="$cnxn-mode"/>
              <xsl:text>
              </xsl:text>
            </xsl:if>
            <xsl:call-template name="cnxn-expansion-dispatch">
              <xsl:with-param name="target-node" select="@resource"/>
              <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
            </xsl:call-template>
            <!-- call cnxn-debug-footnote with cnxn-mode = 'debug-footnote' -->
            <xsl:if test="$debug-mode > 0">
              <xsl:call-template name="cnxn-debug-footnote">
                <xsl:with-param name="target-node" select="@resource"/>
                <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="target">
              <xsl:choose>
                <xsl:when test="@target-id">
                  <xsl:value-of select="@target-id"/>
                </xsl:when>
                <xsl:when test="@target">
                  <xsl:value-of select="@target"/>
                </xsl:when>
                <xsl:when test="@document">
                  <xsl:value-of select="@document"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="target-nodes" select="key('by-id', $target)"/>
            <xsl:variable name="target-node" select="$target-nodes[1]"/>
            <xsl:variable name="cnxn-mode">
              <xsl:call-template name="make-cnxn-mode">
                <xsl:with-param name="target-node" select="$target-node"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$debug-mode > 0">
              <xsl:text> % cnxn-mode: </xsl:text>
              <xsl:value-of select="$cnxn-mode"/>
              <xsl:text>
              </xsl:text>
            </xsl:if>
            <xsl:call-template name="cnxn-expansion-dispatch">
              <xsl:with-param name="target" select="$target"/>
              <xsl:with-param name="target-node" select="$target-node"/>
              <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
            </xsl:call-template>
            <!-- call cnxn-debug-footnote with cnxn-mode = 'debug-footnote' -->
            <xsl:if test="$debug-mode > 0">
              <xsl:call-template name="cnxn-debug-footnote">
                <xsl:with-param name="target" select="$target"/>
                <xsl:with-param name="target-node" select="$target-node"/>
                <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:cnxn|cnx:link[@document or @target-id or @version or @resource]" mode="table-footnotes">
    <xsl:call-template name="cnxn-float-footnotes"/>
  </xsl:template>

  <xsl:template match="cnx:cnxn|cnx:link[@document or @target-id or @version or @resource]" mode="figure-footnotes">
    <xsl:call-template name="cnxn-float-footnotes"/>
  </xsl:template>
  
  <!-- Handles the construction of the \footnotetext{} commands after tables -->
  <xsl:template name="cnxn-float-footnotes">
    <xsl:variable name="target">
      <xsl:choose>
        <xsl:when test="@target-id">
          <xsl:value-of select="@target-id"/>
        </xsl:when>
        <xsl:when test="@target">
          <xsl:value-of select="@target"/>
        </xsl:when>
        <xsl:when test="@document">
          <xsl:value-of select="@document"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="resource">
      <xsl:if test="@resource">
        <xsl:value-of select="@resource"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="target-nodes" select="key('by-id', $target)"/>
    <xsl:variable name="target-node" select="$target-nodes[1]"/>
    <xsl:variable name="cnxn-mode">
      <xsl:call-template name="make-cnxn-mode">
        <xsl:with-param name="target-node" select="$target-node"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- If this cnxn left a footnotemark in the table, we need to make a 
         \footnotetext{} here -->
    <xsl:if test="$cnxn-mode = 'footnotemark'">
      <xsl:call-template name="cnxn-expansion-dispatch">
        <!-- should only produce output for cnxns that expand to footnote -->
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="target-node" select="$target-node"/>
        <xsl:with-param name="cnxn-mode" select="'footnotetext'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- call cnxn-debug-footnote with cnxn-mode = 'debug-footnotetext' -->
    <xsl:if test="$debug-mode > 0">
      <xsl:call-template name="cnxn-debug-footnote">
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="target-node" select="$target-node"/>
        <xsl:with-param name="cnxn-mode" select="'debug-footnotetext'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!-- Delegates expansion of cnxn elements to templates specific to each 
       target element, and uses the result plus the cnxn-mode in calling 
       cnxn-wrapper -->
  <!-- FIXME: could this logic be incorporated into cnxn-wrapper? I think 
       this template is now redundant. -->
  <xsl:template name="cnxn-expansion-dispatch">
    <xsl:param name="target"/>
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:variable name="target-name" select="local-name($target-node)"/>
    <xsl:variable name="target-xmlns" select="namespace-uri($target-node)"/>
    <xsl:variable name="display-uri">
      <xsl:call-template name="escape-octothorpe">
        <xsl:with-param name="data">
          <xsl:call-template name="make-cnxn-URI"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="cnxn-wrapper">
      <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
      <xsl:with-param name="data">
        <xsl:choose>
          <xsl:when test="@resource">
            <xsl:apply-templates select="@resource" mode="cnxn-expansion">
              <xsl:with-param name="display-uri" select="$display-uri"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$target-node" mode="cnxn-expansion">
              <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
              <xsl:with-param name="display-uri" select="$display-uri"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="display-uri" select="$display-uri"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Creates debug footnotes for cnxns; fills the same role for cnxn debug 
       footnotes as 'cnxn-expansion-dispatch' does for the cnxn elements 
       themselves. -->
  <xsl:template name="cnxn-debug-footnote">
    <xsl:param name="target"/>
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:variable name="target-name" select="local-name($target-node)"/>
    <xsl:variable name="cnxn-debug-mode">
      <xsl:choose>
        <xsl:when test="$cnxn-mode='debug-footnotetext'">debug-footnotetext</xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="make-cnxn-debug-mode">
            <xsl:with-param name="target-node" select="$target-node"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="target-type"
                  select="normalize-space($target-node/@type)"/>
    <xsl:variable name="in-ex">
      <xsl:choose>
        <xsl:when test="not($target-node/ancestor::referenced-objects)">in</xsl:when>
        <xsl:otherwise>ex</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="is-empty">
      <xsl:choose>
        <xsl:when test="normalize-space(string(self::*))">-</xsl:when>
        <xsl:otherwise>+</xsl:otherwise>
      </xsl:choose>
      <xsl:text>empty</xsl:text>
    </xsl:variable>
    <xsl:variable name="has-title">
      <xsl:choose>
        <xsl:when test="normalize-space($target-node/cnx:name) or normalize-space($target-node/cnx:title)">+</xsl:when>
        <xsl:otherwise>-</xsl:otherwise>
      </xsl:choose>
      <xsl:text>title</xsl:text>
    </xsl:variable>
    <xsl:call-template name="cnxn-wrapper">
      <xsl:with-param name="cnxn-mode" select="$cnxn-debug-mode"/>
      <xsl:with-param name="data">
        <xsl:text>\textbf{[CNXN </xsl:text>
        <xsl:value-of select="$target-name"/>
        <xsl:text>|TYPE:</xsl:text>
        <xsl:value-of select="$target-type"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="$in-ex"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="$is-empty"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="$has-title"/>
        <xsl:text>|DOC:</xsl:text>
        <xsl:value-of select="normalize-space(@document)"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>|VER:</xsl:text>
        <xsl:value-of select="normalize-space(@version)"/>
        <xsl:text>|MODE:</xsl:text>
        <xsl:value-of select="$cnxn-mode"/>
        <xsl:text>]}</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Takes a cnxn-mode and the cnxn expansion data, and wraps it in the 
       LaTeX appropriate to the cnxn-mode -->
  <!-- FIXME: assess how far this code could be consolidated with 
       cnxn-expansion-dispatch, and how far values could be passed in as 
       params rather than being re-computed here. -->
  <xsl:template name="cnxn-wrapper">
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="data"/>
    <xsl:param name="display-uri"/>
    <!-- FIXME 0.6 -->
    <xsl:variable name="target">
      <xsl:choose>
        <xsl:when test="@target-id">
          <xsl:value-of select="@target-id"/>
        </xsl:when>
        <xsl:when test="@target">
          <xsl:value-of select="@target"/>
        </xsl:when>
        <xsl:when test="@document">
          <xsl:value-of select="@document"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="resource">
      <xsl:if test="string-length(@resource)">
        <xsl:value-of select="@resource"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="target-nodes" select="key('by-id', $target)"/>
    <xsl:variable name="target-node" select="$target-nodes[1]"/>
    <xsl:choose>
      <xsl:when test="$cnxn-mode = 'in-place'">
        <xsl:if test="$debug-mode > 0"><xsl:text>\uline{</xsl:text></xsl:if>
        <xsl:value-of select="$data"/>
        <xsl:if test="$debug-mode > 0">
          <xsl:text>}</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$cnxn-mode = 'parenthetical'">
        <xsl:if test="$target-node"> 
          <xsl:text> (</xsl:text> 
        </xsl:if>
        <xsl:if test="$debug-mode > 0"><xsl:text>\uline{</xsl:text></xsl:if>
        <xsl:value-of select="$data"/>
        <xsl:if test="$debug-mode > 0">
          <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:if test="$target-node">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$cnxn-mode = 'footnote'">
        <xsl:choose>
          <xsl:when test="not(ancestor::cnx:note[translate(@type, $upper-letters, $lower-letters)='footnote'] or ancestor::cnx:footnote)">
            <xsl:if test="not(*|text())">
              <xsl:text> </xsl:text>
              <xsl:if test="$debug-mode > 0"><xsl:text>\uline{</xsl:text></xsl:if>
              <xsl:text>here</xsl:text>
              <xsl:if test="$debug-mode > 0"><xsl:text>}</xsl:text></xsl:if>
            </xsl:if>
            <xsl:text>\footnote{\raggedright{}</xsl:text>
            <xsl:value-of select="$data"/>
            <xsl:text>}</xsl:text>
            <xsl:if test="$debug-mode > 0"><xsl:text>\raisebox{1ex}{\small ,}</xsl:text></xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> (&lt;</xsl:text>
            <xsl:value-of select="$display-uri"/>
            <xsl:text>&gt;)</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$cnxn-mode = 'footnotemark'">
        <xsl:if test="not(*|text())">
          <xsl:text> </xsl:text>
          <xsl:if test="$debug-mode > 0"><xsl:text>\uline{</xsl:text></xsl:if>
          <xsl:text>here</xsl:text>
          <xsl:if test="$debug-mode > 0"><xsl:text>}</xsl:text></xsl:if>
        </xsl:if>
        <xsl:text>\footnotemark{}</xsl:text>
        <xsl:if test="$debug-mode > 0"><xsl:text>\raisebox{1ex}{\small ,}</xsl:text></xsl:if>
        <!-- <xsl:if test="$debug-mode > 0"><xsl:text>\footnotemark{}</xsl:text></xsl:if> -->
      </xsl:when>
      <xsl:when test="$cnxn-mode = 'footnotetext'">
        <xsl:text>\stepcounter{footnote}\footnotetext{\raggedright{}</xsl:text>
        <xsl:value-of select="$data"/>
        <xsl:text>}
        </xsl:text>
      </xsl:when>
      <!-- FIXME: work in a comma before the footnote mark, to set 
           this footnote mark off from the real footnote mark. -->
      <xsl:when test="$cnxn-mode = 'debug-footnote'">
        <xsl:text>\footnote{</xsl:text>
        <xsl:value-of select="$data"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="$cnxn-mode = 'debug-footnotemark'">
        <xsl:text>\footnotemark{}</xsl:text>
<!-- <xsl:if test="$debug-mode > 0"><xsl:text>\footnotemark{}</xsl:text></xsl:if> -->
      </xsl:when>
      <xsl:when test="$cnxn-mode = 'debug-footnotetext'">
        <xsl:text>\stepcounter{footnote}\footnotetext{</xsl:text>
        <xsl:value-of select="$data"/>
        <xsl:text>}
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>% We hit the "otherwise" case!</xsl:text>
        <xsl:value-of select="$cnxn-mode"/>
        <xsl:text>
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Takes a cnxn, constructs a URI that points to its target -->
  <xsl:template name="make-cnxn-URI">
    <xsl:param name="CONTENT_URI"/>
    <xsl:param name="DOC_ID"/>
    <xsl:variable name="version">
      <xsl:choose>
        <xsl:when test="string-length(normalize-space(@version))">
          <xsl:value-of select="normalize-space(@version)"/>
        </xsl:when>
        <xsl:otherwise>latest</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="target">
      <xsl:choose>
        <xsl:when test="@target-id">
          <xsl:value-of select="substring-after(@target-id, '*')"/>
        </xsl:when>
        <xsl:when test="@target">
          <xsl:value-of select="substring-after(@target, '*')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="resource">
      <xsl:if test="string-length(@resource)">
        <xsl:value-of select="@resource"/>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length(normalize-space($CONTENT_URI)) > 0">
        <xsl:value-of select="$CONTENT_URI"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$CNX_CONTENT_URI"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="@document">
        <xsl:value-of select="normalize-space(@document)"/>
      </xsl:when>
      <xsl:when test="normalize-space($DOC_ID)">
        <xsl:value-of select="normalize-space($DOC_ID)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="ancestor::*[local-name()='document'][1]/@id"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="normalize-space($version)"/>
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="string-length($target)">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$target"/>
      </xsl:when>
      <xsl:when test="string-length($resource)">
        <xsl:value-of select="$resource"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make-cnxn-mode">
    <xsl:param name="target-node"/>
    <xsl:choose>
      <xsl:when test="@resource">
        <xsl:choose>
          <!-- the cnxn is inside a table; leave a \footnotemark -->
          <xsl:when test="ancestor::cnx:tgroup or ancestor::cnx:figure">footnotemark</xsl:when>
          <!-- otherwise, just make a footnote -->
          <xsl:otherwise>footnote</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- in-place: target is in the collection, and cnxn is empty -->
      <xsl:when test="not($target-node/ancestor::referenced-objects) and 
                      not(*|text())">
        <xsl:text>in-place</xsl:text>
      </xsl:when>
      <!-- parenthetical: target is in the collection, and cnxn has 
           element or text content -->
      <xsl:when test="not($target-node/ancestor::referenced-objects)">
        <xsl:text>parenthetical</xsl:text>
      </xsl:when>
      <!-- footnote: target is not in the collection -->
      <xsl:when test="$target-node/ancestor::referenced-objects">
        <xsl:choose>
          <!-- the cnxn is inside a table; leave a \footnotemark -->
          <xsl:when test="ancestor::cnx:tgroup or ancestor::cnx:figure">footnotemark</xsl:when>
          <!-- otherwise, just make a footnote -->
          <xsl:otherwise>footnote</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Ascertains the appropriate cnxn-mode for debug footnotes; is not used 
       for generating \footnotetext{} commands after tables: in that case, 
       cnxn-mode is set manually in the cnx:cnxn[@mode='table-footnotes'] 
       template. -->
  <xsl:template name="make-cnxn-debug-mode">
    <xsl:param name="target-node"/>
    <xsl:choose>
      <xsl:when test="ancestor::cnx:tgroup">debug-footnotemark</xsl:when>
      <xsl:otherwise>debug-footnote</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 'rdf:RDF' (a collection) as a cnxn target; must be outside the doc, 
       hence it always becomes a footnote. -->
  <xsl:template match="rdf:RDF" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:text>\textsl{</xsl:text>
    <xsl:value-of select="key('by-id', @id)/rdf:Description[@about='urn:context:root']/cnx-context:name"/>
    <xsl:text>}</xsl:text><!-- end textsl -->
    <xsl:text> &lt;</xsl:text>
    <xsl:value-of select="$display-uri"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <!-- 'document' as cnxn target inside the collection can either be 
       a chapter or a section.
       -->
  <xsl:template match="document|cnx:document" mode="cnxn-expansion">
    <!--<xsl:param name="target-node"/>-->
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:choose>
          <!-- It's a chapter -->
          <xsl:when test="@cnx-context:class='chapter'">
            <xsl:text>Chapter~</xsl:text>
          </xsl:when>
          <!-- It's a section -->
          <xsl:otherwise>
            <xsl:text>Section~</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="@number"/>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="self::*"/>
        </xsl:call-template>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:figure" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="figure-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="figure-label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>Figure</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:value-of select="$figure-label"/><xsl:text>~</xsl:text>
        <xsl:value-of select="@number"/>
        <!-- if the figure has a title, use it -->
        <xsl:if test="string-length($figure-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$figure-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text><xsl:value-of select="$figure-label"/><xsl:text>~</xsl:text>
        <!--<xsl:value-of select="position(ancestor::document//figure[@id=$target-node-id])"/>-->
        <!--<xsl:call-template name="">
        </xsl:call-template>-->
        <xsl:for-each select="ancestor::document//cnx:figure">
          <xsl:if test="@id=$target-node-id">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test="string-length($figure-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$figure-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:section" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="section-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="section-label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>Section</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:value-of select="$section-label"/><xsl:text>~</xsl:text>
        <xsl:value-of select="@number"/>
        <!-- if the figure has a title, use it -->
        <xsl:if test="string-length($section-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$section-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="string-length($section-title)">
            <xsl:text>: </xsl:text><xsl:value-of select="$section-label"/><xsl:text> </xsl:text>
            <xsl:value-of select="$section-title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>, see section at</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:equation" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="equation-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="equation-label">
      <xsl:if test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:if test="string-length($equation-label)">
          <xsl:value-of select="$equation-label"/><xsl:text>~</xsl:text>
        </xsl:if>
        <xsl:if test="$cnxn-mode != 'parenthetical'"><xsl:text>(</xsl:text></xsl:if>
        <xsl:value-of select="@number"/>
        <xsl:if test="$cnxn-mode != 'parenthetical'"><xsl:text>)</xsl:text></xsl:if>
        <!-- if the figure has a title, use it -->
        <xsl:if test="string-length($equation-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$equation-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="string-length($equation-label)">
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$equation-label"/><xsl:text>~</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>, </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>(</xsl:text>
        <xsl:for-each select="ancestor::document//cnx:equation">
          <xsl:if test="@id=$target-node-id">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>) </xsl:text>
        <xsl:if test="string-length($equation-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$equation-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="m:math" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="equation-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:if test="$cnxn-mode != 'parenthetical'"><xsl:text>(</xsl:text></xsl:if>
          <xsl:text>p. \pageref{</xsl:text>
          <xsl:call-template name="make-label">
            <xsl:with-param name="instring" select="@id"/>
          </xsl:call-template>
        <xsl:text>}</xsl:text>
        <xsl:if test="$cnxn-mode != 'parenthetical'"><xsl:text>)</xsl:text></xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, (</xsl:text>
        <xsl:for-each select="ancestor::document//m:math">
          <xsl:if test="@id=$target-node-id">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>) </xsl:text>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:para" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="para-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- if the para has a title, use it -->
        <xsl:if test="string-length($para-title)">
          <xsl:value-of select="$para-title"/>
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:if test="string-length($para-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$para-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:definition" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="definition-term" select="normalize-space(cnx:term)"/>
    <xsl:variable name="definition-label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>Definition</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- use the definition's term -->
        <xsl:value-of select="$definition-label"/><xsl:text>: "</xsl:text>
        <xsl:value-of select="$definition-term"/>
        <xsl:text>", p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text><xsl:value-of select="$definition-label"/><xsl:text> </xsl:text>
        <xsl:apply-templates select="self::*" 
                             mode="document-element-count">
          <xsl:with-param name="level" select="'any'"/>
        </xsl:apply-templates>
        <xsl:text>: "</xsl:text>
        <xsl:value-of select="$definition-term"/>
        <xsl:text>" &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:meaning|cnx:seealso" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="self::cnx:meaning">
          <xsl:text>Meaning</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>See also</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="term" select="normalize-space(parent::cnx:definition/cnx:term)"/>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- use the term -->
        <xsl:value-of select="$label"/>
        <xsl:text>: "</xsl:text>
        <xsl:value-of select="$term"/>
        <xsl:text>", p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$label"/>
        <xsl:text>: "</xsl:text>
        <xsl:value-of select="$term"/>
        <xsl:text>" &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:note" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="note-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="note-label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:when test="$supported-types/cnx:note[normalize-space(@type)=current()/@type]">
          <xsl:value-of select="translate(substring(normalize-space(@type), 1, 1), $lower-letters, $upper-letters)"/>
          <xsl:value-of select="substring(normalize-space(@type), 2)"/>
        </xsl:when>
        <xsl:otherwise>Note</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- if the note has a title, use it -->
        <xsl:choose>
          <xsl:when test="string-length($note-title)">
            <xsl:value-of select="$note-title"/>
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:when test="string-length($note-label)">
            <xsl:value-of select="$note-label"/>
            <xsl:text>, </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="string-length($note-title)">
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$note-title"/>
          </xsl:when>
          <xsl:when test="string-length($note-label)">
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$note-label"/>
          </xsl:when>
        </xsl:choose>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:table" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="table-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="table-label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>Table</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- if the table has a title, use it -->
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:value-of select="$table-label"/><xsl:text> </xsl:text>
            <xsl:value-of select="@number"/>
            <xsl:if test="string-length($table-title)">
              <xsl:text>: </xsl:text>
              <xsl:value-of select="$table-title"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="string-length($table-title)">
              <xsl:value-of select="$table-title"/>
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:text>p. \pageref{</xsl:text>
            <xsl:call-template name="make-label">
              <xsl:with-param name="instring" select="@id"/>
            </xsl:call-template>
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$table-label"/><xsl:text> </xsl:text>
            <xsl:value-of select="@number"/>
            <xsl:if test="string-length($table-title)">
              <xsl:text>: </xsl:text>
              <xsl:value-of select="$table-title"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="string-length($table-title)">
              <xsl:text>: </xsl:text>
              <xsl:value-of select="$table-title"/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:example" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="example-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="example-label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>Example</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- if the example has a title, use it -->
        <xsl:choose>
          <xsl:when test="string-length($example-label)">
            <xsl:value-of select="$example-label"/>
          </xsl:when>
          <xsl:otherwise>Example</xsl:otherwise>
        </xsl:choose>
        <xsl:text>~</xsl:text>
        <xsl:value-of select="@number"/>
        <xsl:if test="string-length($example-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$example-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text><xsl:value-of select="$example-label"/><xsl:text>~</xsl:text>
        <xsl:for-each select="ancestor::document//cnx:example">
          <xsl:if test="@id=$target-node-id">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test="string-length($example-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$example-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:list" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="list-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="list-label">
      <xsl:if test="cnx:label">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- if the list has a title, use it -->
        <xsl:if test="string-length($list-label)">
          <xsl:value-of select="$list-label"/>
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:if test="string-length($list-title)">
          <xsl:value-of select="$list-title"/>
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:if test="string-length($list-label)">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$list-label"/>
        </xsl:if>
        <xsl:if test="string-length($list-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$list-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:subfigure" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="subfigure-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="figure-label">
      <xsl:choose>
        <xsl:when test="parent::cnx:figure/cnx:label">
          <xsl:apply-templates select="parent::cnx:figure/cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>Figure</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:value-of select="$figure-label"/><xsl:text>~</xsl:text>
        <xsl:value-of select="parent::cnx:figure/@number"/>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="self::*"
                             mode="document-element-count">
          <xsl:with-param name="level" select="'single'"/>
          <xsl:with-param name="format" select="'a'"/>
        </xsl:apply-templates>
        <xsl:text>)</xsl:text>
        <!-- if the subfigure has a title, use it -->
        <xsl:if test="string-length($subfigure-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$subfigure-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text><xsl:value-of select="$figure-label"/><xsl:text>~</xsl:text>
        <xsl:apply-templates select="parent::cnx:figure"
                             mode="document-element-count">
          <xsl:with-param name="level" select="'any'"/>
        </xsl:apply-templates>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="self::*"
                             mode="document-element-count">
          <xsl:with-param name="level" select="'single'"/>
          <xsl:with-param name="format" select="'a'"/>
        </xsl:apply-templates>
        <xsl:text>)</xsl:text>
        <xsl:if test="string-length($subfigure-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$subfigure-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:exercise" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="exercise-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="example-id" select="ancestor::cnx:example[1]/@id"/>
    <xsl:variable name="exercise-label">
      <xsl:choose>
        <xsl:when test="ancestor::cnx:example[1]/cnx:label">
          <xsl:apply-templates select="ancestor::cnx:example[1]/cnx:label/node()"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="ancestor::cnx:example[1]/@number"/>
        </xsl:when>
        <xsl:when test="ancestor::cnx:example">
          <xsl:value-of select="concat('Example ', ancestor::cnx:example[1]/@number)"/>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:if test="ancestor::cnx:example">, </xsl:if>
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <!-- Catch all exercises that have example ancestors, even if the enclosed if test is false. -->
        <xsl:when test="ancestor::cnx:example">
          <!-- Though we catch all example//exercise cases here, we only 
               label them when there is more than one exercise in the example, 
               or when there is significant content in the example before the 
               exercise. -->
          <xsl:if test="count(ancestor::cnx:example[1]//cnx:exercise) &gt; 1 or count(preceding::node()[ancestor::cnx:example[@id=$example-id]][not(self::cnx:name or ancestor::cnx:name or self::cnx:title or ancestor::cnx:title) and (self::* or self::text()) and string-length(normalize-space())]) &gt; 0">
            <xsl:text>, Problem</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>Exercise</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:value-of select="$exercise-label"/><xsl:text>~</xsl:text>
        <xsl:value-of select="@number"/>
        <!-- if the exercise has a title, use it -->
        <xsl:if test="string-length($exercise-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$exercise-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text><xsl:value-of select="$exercise-label"/><xsl:text>~</xsl:text>
        <xsl:apply-templates select="self::*"
                             mode="document-element-count">
          <xsl:with-param name="level" select="'any'"/>
        </xsl:apply-templates>
        <xsl:if test="string-length($exercise-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$exercise-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:solution" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="exercise-ref-parent" select="key('exercise-by-id', @ref)"/>
    <xsl:variable name="exercise-direct-parent" select="parent::cnx:exercise"/>
    <xsl:variable name="solution-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="solution-label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>Solution</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:value-of select="$solution-label"/>
        <xsl:if test="@number">
          <xsl:text>~</xsl:text>
          <xsl:value-of select="@number"/>
        </xsl:if>
        <!-- if the solution has a title, use it -->
        <xsl:if test="string-length($solution-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$solution-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
        <xsl:text> to </xsl:text>
        <xsl:choose>
          <xsl:when test="$exercise-ref-parent/ancestor::cnx:example">
            <xsl:text>Example </xsl:text>
            <xsl:value-of select="$exercise-ref-parent/ancestor::cnx:example[1]/@number"/>
            <xsl:if test="$exercise-ref-parent/@number">
              <xsl:text>, Problem </xsl:text>
              <xsl:value-of select="$exercise-ref-parent/@number"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$exercise-direct-parent/ancestor::cnx:example">
            <xsl:text>Example </xsl:text>
            <xsl:value-of select="$exercise-direct-parent/ancestor::cnx:example[1]/@number"/>
            <xsl:if test="$exercise-direct-parent/@number">
              <xsl:text>, Problem </xsl:text>
              <xsl:value-of select="$exercise-direct-parent/@number"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$exercise-ref-parent">
            <xsl:text>Exercise </xsl:text>
            <xsl:value-of select="$exercise-ref-parent/@number"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Exercise </xsl:text>
            <xsl:value-of select="$exercise-direct-parent/@number"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="document('')/xsl:stylesheet/cnxn:title-before[@mode=$cnxn-mode]"/>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="document('')/xsl:stylesheet/cnxn:title-after[@mode=$cnxn-mode]"/>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text><xsl:value-of select="$solution-label"/>
        <xsl:if test="@number">
          <xsl:text>~</xsl:text>
          <xsl:value-of select="@number"/>
        </xsl:if>
        <xsl:if test="string-length($solution-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$solution-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:item" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="item-label">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="parent-list"
                  select="parent::cnx:list"/>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:choose>
          <!-- if the item has a title, use it -->
          <xsl:when test="string-length($item-label)">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$item-label"/>
            <xsl:text>", </xsl:text>
          </xsl:when>
          <!-- otherwise, use 'list' -->
          <xsl:otherwise>
            <xsl:text>list, </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Item or bullet info -->
        <!-- FIXME: for now we assume single-level lists -->
        <xsl:choose>
          <xsl:when test="$parent-list[translate(@type, $upper-letters, $lower-letters)='enumerated']">
            <xsl:text>item~</xsl:text>
            <xsl:apply-templates select="self::*"
                                 mode="document-element-count">
              <xsl:with-param name="level" select="'single'"/>
            </xsl:apply-templates>
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:when test="$parent-list[translate(@type, $upper-letters, $lower-letters)='bulleted' or not(@type)]">
            <xsl:variable name="item-number">
              <xsl:apply-templates select="self::*"
                                   mode="document-element-count">
                <xsl:with-param name="level" select="'single'"/>
              </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="$item-number"/>
            <xsl:call-template name="ordinal">
              <xsl:with-param name="number" select="$item-number"/>
            </xsl:call-template>
            <xsl:text> bullet, </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="string-length($item-label)">
            <xsl:text>: "</xsl:text>
            <xsl:value-of select="$item-label"/>
            <xsl:text>"</xsl:text>
          </xsl:when>
          <xsl:otherwise>, list</xsl:otherwise>
        </xsl:choose>
        <xsl:text>, </xsl:text>
        <xsl:choose>
          <xsl:when test="$parent-list[translate(@type, $upper-letters, $lower-letters)='enumerated']">
            <xsl:text>item </xsl:text>
            <xsl:apply-templates select="self::*"
                                 mode="document-element-count">
              <xsl:with-param name="level" select="'single'"/>
            </xsl:apply-templates>
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:when test="$parent-list[translate(@type, $upper-letters, $lower-letters)='bulleted']">
            <xsl:variable name="item-number">
              <xsl:apply-templates select="self::*"
                                   mode="document-element-count">
                <xsl:with-param name="level" select="'single'"/>
              </xsl:apply-templates>
            </xsl:variable>
            <xsl:value-of select="$item-number"/>
            <xsl:call-template name="ordinal">
              <xsl:with-param name="number" select="$item-number"/>
            </xsl:call-template>
            <xsl:text> bullet, </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:media" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="media-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode='in-place' or $cnxn-mode='parenthetical'">
        <xsl:variable name="cnxn-para-id"
                      select="generate-id(ancestor::cnx:para[1])"/>
        <xsl:variable name="media-para-id"
             select="generate-id(ancestor::cnx:para[1])"/>
        <xsl:variable name="cnxn-item-id"
                      select="generate-id(ancestor::cnx:item[1])"/>
        <xsl:variable name="media-item-id"
             select="generate-id(ancestor::cnx:item[1])"/>
        <xsl:choose>
          <!-- If the media has a common para or item ancestor 
               with the cnxn... -->
          <xsl:when test="($cnxn-para-id and ($cnxn-para-id=$media-para-id))
                            or
                          ($cnxn-item-id and ($cnxn-item-id=$media-item-id))">
            <xsl:text>this </xsl:text>
            <xsl:choose>
              <xsl:when test="cnx:image">
                <xsl:text>image</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>media</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Otherwise -->
          <xsl:otherwise>
            <xsl:text>p. \pageref{</xsl:text>
            <xsl:call-template name="make-label">
              <xsl:with-param name="instring" select="@id"/>
            </xsl:call-template>
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, see the media at &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:object|cnx:image|cnx:audio|cnx:video|cnx:java-applet|cnx:flash|cnx:labview|cnx:text|cnx:download" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:apply-templates select="parent::cnx:media" mode="cnxn-expansion">
      <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
      <xsl:with-param name="display-uri" select="$display-uri"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="cnx:problem" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/> 
    <xsl:variable name="problem-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="problem-label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:otherwise>Problem</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:value-of select="$problem-label"/><xsl:text>~</xsl:text>
        <xsl:value-of select="parent::cnx:exercise/@number"/>
        <!-- if the problem has a title, use it -->
        <xsl:if test="string-length($problem-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$problem-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text><xsl:value-of select="$problem-label"/><xsl:text>~</xsl:text>
        <xsl:apply-templates select="parent::cnx:exercise"
                             mode="document-element-count">
          <xsl:with-param name="level" select="'any'"/>
        </xsl:apply-templates>
        <xsl:if test="string-length($problem-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$problem-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:rule" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="rule-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rule-type">
      <xsl:call-template name="make-rule-type"/>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:value-of select="$rule-type"/><xsl:text>~</xsl:text>
        <xsl:value-of select="@number"/>
        <xsl:text>, </xsl:text>
        <!-- if the rule has a title, use it -->
        <xsl:if test="string-length($rule-title)">
          <xsl:value-of select="$rule-title"/>
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$rule-type"/><xsl:text>~</xsl:text>
        <xsl:apply-templates select="self::*"
                             mode="document-element-count">
          <xsl:with-param name="level" select="'any'"/>
        </xsl:apply-templates>
        <xsl:if test="string-length($rule-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$rule-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="cnx:statement|cnx:proof" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="rule-parent" select="parent::cnx:rule"/>
    <xsl:variable name="title">
        <xsl:if test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="cnx:label">
          <xsl:apply-templates select="cnx:label/node()"/>
        </xsl:when>
        <xsl:when test="self::cnx:statement">
          <xsl:text>Statement</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Proof</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> of </xsl:text>
      <xsl:choose>
        <xsl:when test="$rule-parent/cnx:label">
          <xsl:apply-templates select="$rule-parent/cnx:label/node()"/>
        </xsl:when>
        <xsl:when test="$supported-types/cnx:rule[@type=$rule-parent/@type]">
          <!-- Capitalize first letter -->
          <xsl:value-of select="translate(substring(
                        normalize-space($rule-parent/@type), 1, 1), $lower, $upper)"/>
          <xsl:value-of select="substring(normalize-space($rule-parent/@type), 2)"/>
        </xsl:when>
        <xsl:otherwise>Rule</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:value-of select="$label"/>
        <xsl:if test="$rule-parent/@number">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$rule-parent/@number"/>
        </xsl:if>
        <xsl:text>, </xsl:text>
        <!-- if there is a title, use it -->
        <xsl:if test="string-length($title)">
          <xsl:value-of select="$title"/>
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$label"/>
        <xsl:if test="$rule-parent/@number">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$rule-parent/@number"/>
        </xsl:if>
        <xsl:if test="string-length($title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- FIXME: Use code/label in link expansion? -->
  <xsl:template match="cnx:code" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, see the code at &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:newline|cnx:space|cnx:sub|cnx:sup|cnx:emphasis|cnx:term|cnx:foreign|cnx:quote" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:div|cnx:preformat|cnx:span" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="target-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="target-label">
      <xsl:if test="string-length(normalize-space(cnx:label))">
        <xsl:apply-templates select="cnx:label/node()"/>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- if the element has a label, use it -->
        <xsl:if test="string-length($target-label)">
          <xsl:value-of select="$target-label"/>
          <xsl:if test="string-length($target-title)">
            <xsl:text>: </xsl:text>
          </xsl:if>
        </xsl:if>
        <!-- if the element has a title, use it -->
        <xsl:if test="string-length($target-title)">
          <xsl:value-of select="$target-title"/>
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:text>p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:if test="string-length($target-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$target-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:title|cnx:label" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:apply-templates select="parent::*" mode="cnxn-expansion">
      <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
      <xsl:with-param name="display-uri" select="$display-uri"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="cnx:commentary" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:apply-templates select="parent::cnx:exercise" mode="cnxn-expansion">
      <xsl:with-param name="cnxn-mode" select="$cnxn-mode"/>
      <xsl:with-param name="display-uri" select="$display-uri"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="cnx:footnote" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="target-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <!-- if the element has a title, use it -->
        <xsl:if test="string-length($target-title)">
          <xsl:value-of select="$target-title"/>
          <xsl:text>, </xsl:text>
        </xsl:if><!-- FIXME footnote ref here? -->
        <xsl:text>footnote on p. \pageref{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:variable name="target-module" select="ancestor::*[local-name()='document']"/>
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="$target-module"/>
        </xsl:call-template>
        <xsl:text>: footnote </xsl:text>
        <xsl:if test="string-length($target-title)">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="$target-title"/>
          <xsl:text>) </xsl:text>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@resource" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:text>See the file at &lt;</xsl:text>
    <xsl:value-of select="$display-uri"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="bib:entry" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:text>\cite{</xsl:text>
        <xsl:call-template name="make-label">
          <xsl:with-param name="instring" select="@id"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, reference </xsl:text>
        <xsl:apply-templates select="self::*"
                             mode="document-element-count">
          <xsl:with-param name="level" select="'single'"/>
          <xsl:with-param name="format" select="'[1]'"/>
        </xsl:apply-templates>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="qml:item" mode="cnxn-expansion">
    <xsl:param name="target-node"/>
    <xsl:param name="cnxn-mode"/>
    <xsl:param name="display-uri"/>
    <xsl:variable name="target-node-id" select="@id"/>
    <xsl:variable name="item-title">
      <xsl:choose>
        <xsl:when test="cnx:name">
          <xsl:value-of select="normalize-space(cnx:name)"/>
        </xsl:when>
        <xsl:when test="cnx:title">
          <xsl:apply-templates select="cnx:title/node()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- It's in this collection -->
      <xsl:when test="$cnxn-mode = 'in-place' or $cnxn-mode = 'parenthetical'">
        <xsl:text>Problem~</xsl:text>
        <xsl:value-of select="@number"/>
        <!-- if the problem has a title, use it -->
        <xsl:if test="string-length($item-title)">
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-before[@mode=$cnxn-mode]"/>
          <xsl:value-of select="$item-title"/>
          <xsl:value-of select="document('')/xsl:stylesheet/
                                  cnxn:title-after[@mode=$cnxn-mode]"/>
        </xsl:if>
      </xsl:when>
      <!-- It's not in this collection; just make a footnote  -->
      <xsl:when test="starts-with($cnxn-mode, 'footnote')">
        <xsl:call-template name="get-module-title">
          <xsl:with-param name="document-node" select="ancestor::document"/>
        </xsl:call-template>
        <xsl:text>, Problem~</xsl:text>
        <xsl:apply-templates select="self::*"
                             mode="document-element-count">
          <xsl:with-param name="level" select="'any'"/>
        </xsl:apply-templates>
        <xsl:if test="string-length($item-title)">
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$item-title"/>
        </xsl:if>
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="$display-uri"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FIXME: exception handling here -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <!-- Context node is the element to be numbered; assumes that there is a 
       'document' element in its ancestry. 'level' and 'format' param values 
       should be ones valid for xsl:number. -->
  <xsl:template match="*" mode="document-element-count">
    <xsl:param name="level" select="'any'"/>
    <xsl:param name="format" select="'1'"/>
    <xsl:variable name="target-node-name"
                  select="local-name()"/>
    <xsl:variable name="target-node-xmlns"
                  select="namespace-uri()"/>
    <xsl:variable name="parent-doc-id"
                  select="ancestor::*[local-name()='document']/@id"/>
    <xsl:choose>
      <xsl:when test="$level='single'">
        <xsl:number count="//*[local-name()='document'][@id=$parent-doc-id]//
                             *[local-name()=$target-node-name]
                              [namespace-uri()=$target-node-xmlns]"
                    level="single" format="{$format}"/>
      </xsl:when>
      <xsl:when test="$level='any'">
        <xsl:number count="//*[local-name()='document'][@id=$parent-doc-id]//
                             *[local-name()=$target-node-name]
                              [namespace-uri()=$target-node-xmlns]"
                    level="any" format="{$format}"/>
      </xsl:when>
      <xsl:when test="$level='multiple'">
        <xsl:number count="//*[local-name()='document'][@id=$parent-doc-id]//
                             *[local-name()=$target-node-name]
                              [namespace-uri()=$target-node-xmlns]"
                    level="multiple" format="{$format}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:rule" mode="document-element-count">
    <xsl:param name="level" select="'any'"/>
    <xsl:param name="format" select="'1'"/>
    <xsl:variable name="target-node-name" select="local-name()"/>
    <xsl:variable name="target-node-xmlns" select="namespace-uri()"/>
    <xsl:variable name="target-node-type" select="@type"/>
    <xsl:variable name="parent-doc-id" select="ancestor::document/@id"/>
    <xsl:choose>
      <xsl:when test="$level='single'">
        <xsl:number count="//document[@id=$parent-doc-id]//
                    *[local-name()=$target-node-name]
                    [namespace-uri()=$target-node-xmlns]
                    [@type=$target-node-type]"
                    level="single" format="{$format}"/>
      </xsl:when>
      <xsl:when test="$level='any'">
        <xsl:number count="//document[@id=$parent-doc-id]//
                    *[local-name()=$target-node-name]
                    [namespace-uri()=$target-node-xmlns]
                    [@type=$target-node-type]"
                    level="any" format="{$format}"/>
      </xsl:when>
      <xsl:when test="$level='multiple'">
        <xsl:number count="//document[@id=$parent-doc-id]//
                    *[local-name()=$target-node-name]
                    [namespace-uri()=$target-node-xmlns]
                    [@type=$target-node-type]"
                    level="multiple" format="{$format}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Takes a nodeset containing a CNXML document; evaluates to the 
       document's title, with the standard decoration -->
  <xsl:template name="get-module-title">
    <xsl:param name="document-node"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$document-node/module-export/title"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

<!--  LINK :)  -->
  <xsl:template match="cnx:link" mode="cnxml-0.5">
    <xsl:variable name="linksrc">
      <xsl:call-template name="escape-octothorpe">
        <xsl:with-param name="data">
          <xsl:call-template name="make-linksrc"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="add-optional-label"/>
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="ancestor::cnx:tgroup or ancestor::cnx:figure">
        <xsl:text>\footnotemark{}</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::cnx:note[translate(@type, $upper-letters, $lower-letters)='footnote'] or ancestor::cnx:footnote">
        <xsl:text> (&lt;</xsl:text>
        <xsl:value-of select="$linksrc"/>
        <xsl:text>&gt;)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\footnote{</xsl:text>
        <xsl:value-of select="$linksrc"/>
        <xsl:text>}
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This template will be applied after a table, to make the 
       footnotetext commands that correspond to the footnotemarks in 
       the table. -->
  <xsl:template match="cnx:link[@src or @url]" mode="table-footnotes">
    <xsl:call-template name="link-float-footnotes"/>
  </xsl:template>

  <xsl:template match="cnx:link[@src or @url]" mode="figure-footnotes">
    <xsl:call-template name="link-float-footnotes"/>
  </xsl:template>

  <xsl:template name="link-float-footnotes">
    <xsl:variable name="linksrc">
      <xsl:call-template name="escape-octothorpe">
        <xsl:with-param name="data">
          <xsl:call-template name="make-linksrc"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>\stepcounter{footnote}\footnotetext{</xsl:text>
    <xsl:value-of select="$linksrc"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template name="make-linksrc">
    <xsl:variable name="linking-attribute">
      <xsl:choose>
        <xsl:when test="@url"><xsl:value-of select="@url"/></xsl:when>
        <xsl:when test="@src"><xsl:value-of select="@src"/></xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($linking-attribute, 'http://') or starts-with($linking-attribute, 'https://')">
        <xsl:value-of select="$linking-attribute"/>
      </xsl:when>
      <xsl:when test="starts-with($linking-attribute, '/')">
        <xsl:value-of select="$CNX_HOST"/><xsl:value-of select="$linking-attribute"/>
      </xsl:when>
      <xsl:when test="starts-with($linking-attribute, 'mailto:')">
        <xsl:value-of select="substring-after($linking-attribute, 'mailto:')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="moduleId">
          <xsl:call-template name="module-id"/>
        </xsl:variable>
        <xsl:variable name="moduleVersion">
          <xsl:call-template name="module-version">
            <xsl:with-param name="moduleid" select="$moduleId"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$CNX_CONTENT_URI"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$moduleId"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$moduleVersion"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$linking-attribute"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- GLOSSARY -->
  <xsl:template match="cnx:document//cnx:glossary">
  </xsl:template>

  <xsl:template match="/module/glo:glossarylist">
  </xsl:template>

<!-- Process text nodes -->
  <xsl:template match="text()">
    <xsl:call-template name="escape-octothorpe">
      <xsl:with-param name="data" select="."/>
    </xsl:call-template>
  </xsl:template>


<!-- NAMED TEMPLATES -->
  <xsl:template name="print-capital-attribute">
    <xsl:param name="attribute" select="@type"/>
    <xsl:value-of select="translate(substring($attribute, 1, 1),
    $lower-letters, $upper-letters)"/><xsl:value-of
    select="substring($attribute, 2)"/>
  </xsl:template>


  <!-- Used to determine if a paragraph should be ended, depending on whether the first node with visible output is a block list -->
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

  <!-- Starts a new line for container elements such as preformat and div when not preceded by elements that add space themselves -->
  <xsl:template name="begin-new-line">
    <xsl:variable name="wanted-preceding-node" select="preceding::node()[not(self::text() and not(normalize-space()))][1]"/>
    <xsl:choose>
      <!-- If a child of example, exercise, rule, or definition, do nothing, unless there is a preceding sibling node other than empty text or a name/label/title -->
      <xsl:when test="(parent::cnx:example or parent::cnx:exercise or parent::cnx:rule or parent::cnx:definition) and not(preceding-sibling::node()[not(self::text() and not(normalize-space()))][not(cnx:name or cnx:label or cnx:title)])"></xsl:when>
      <!-- If a child of para or item and preceding sibling is non-empty text, add extra space -->
      <xsl:when test="(parent::cnx:para or parent::cnx:item) and preceding-sibling::node()[not(self::text() and not(normalize-space()))][1][self::text()]">
        <xsl:text>\vspace{\rubberspace}\par
        </xsl:text>
      </xsl:when>
      <!-- If immediately preceding node, excluding empty text, is text inside of an element that does not already add space at its end, start a new paragraph -->
      <xsl:when test="$wanted-preceding-node[self::text()]">
        <xsl:choose>
          <xsl:when test="$wanted-preceding-node/parent::cnx:para"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:example"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:exercise"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:equation"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:note[not(@display='inline')]"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:list[not(@type='inline' or @display='inline')]"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:code[@type='block' or @display='block']"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:quote[not(@type='inline' or @display='inline')]"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:div"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:preformat[not(@display='inline')]"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:definition"></xsl:when>
          <xsl:when test="$wanted-preceding-node/parent::cnx:rule"></xsl:when>
          <xsl:otherwise>
            <xsl:text>\par
            </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- Add a label if this element has an @id -->
  <xsl:template name="add-optional-label">
    <xsl:if test="@id">
      <xsl:text>\label{</xsl:text>
      <xsl:call-template name="make-label">
	<xsl:with-param name="instring" select="@id" />
      </xsl:call-template>
      <xsl:text>}</xsl:text>
    </xsl:if>
  </xsl:template>

<!-- MANIPULATION OF UNDERSCORES -->
  <xsl:template name="make-label">
    <xsl:param name="instring" />
    <xsl:choose>
      <xsl:when test="contains($instring,'_')">
	<xsl:value-of select="substring-before($instring,'\_')" />
	<xsl:call-template name="remove-underscore">
	  <xsl:with-param name="instring">
	    <xsl:value-of select="substring-after($instring,'_')"/>
	  </xsl:with-param>
	  <xsl:with-param name="replace-with">
	    <xsl:value-of select="string('!!!underscore!!!')"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$instring" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <xsl:template name="unescape-underscore">
    <xsl:param name="instring" />
    <xsl:choose>
      <xsl:when test="contains($instring,'_')">
	<xsl:value-of select="substring-before($instring,'\_')" />
	<xsl:call-template name="remove-underscore">
	  <xsl:with-param name="instring">
	    <xsl:value-of select="substring-after($instring,'_')"/>
	  </xsl:with-param>
	  <xsl:with-param name="replace-with">
	    <xsl:value-of select="string('_')"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$instring" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="remove-underscore">
    <xsl:param name="instring" />
    <xsl:param name="replace-with"/>
    <xsl:value-of select="$replace-with" />
    <xsl:value-of select="substring-before($instring,'\_')" />
    <xsl:choose>
      <xsl:when test="contains($instring,'_')">
	<xsl:call-template name="remove-underscore">
	  <xsl:with-param name="instring">
	    <xsl:value-of select="substring-after($instring,'_')"/>
	  </xsl:with-param>
	  <xsl:with-param name="replace-with">
	    <xsl:value-of select="$replace-with"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$instring" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Escape '#' as '\#' for LaTeX -->
  <xsl:template name="escape-octothorpe">
    <xsl:param name="data"/>
    <xsl:choose>
      <xsl:when test="contains($data, '#')">
        <xsl:value-of select="substring-before($data, '#')"/>
        <xsl:text>\#</xsl:text>
        <xsl:call-template name="escape-octothorpe">
          <xsl:with-param name="data" select="substring-after($data, '#')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$data"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="module-id">
    <xsl:choose>
      <xsl:when test="ancestor::cnx:solution[not(ancestor::cnx:example)]">
        <xsl:value-of select="substring-before(ancestor::cnx:solution/@ref, '*')"/>
      </xsl:when>
      <xsl:when test="ancestor::*[local-name() = 'document']">
        <xsl:value-of select="ancestor::*[local-name() = 'document']/@id"/>
      </xsl:when>
      <xsl:when test="ancestor::glo:meaning">
        <xsl:value-of select="ancestor::glo:meaning/@moduleid"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'???'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="module-version">
    <xsl:param name="moduleid"/>
    <xsl:variable name="docnode" select="key('by-id', $moduleid)"/>
    <xsl:choose>
      <xsl:when test="$docnode/module-export/version/@latest='true'">
        <xsl:text>latest</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$docnode/module-export/version"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Helper template to create a footnote from the title at the 
       beginning of each module, at whatever level (chapter, section, 
       etc.) it occurs. -->
  <xsl:template name="module-footnotetext">
    <xsl:param name="docnode"/>
    <xsl:variable name="moduleversion">
      <xsl:value-of select="$docnode/module-export/version"/>
    </xsl:variable>
    <xsl:variable name="moduleuri">
      <xsl:value-of select="$CNX_CONTENT_URI"/><xsl:text>/</xsl:text>
      <xsl:value-of select="$docnode/@id"/><xsl:text>/</xsl:text>
      <xsl:value-of select="$moduleversion"/><xsl:text>/</xsl:text>
    </xsl:variable>
    <xsl:text>\footnotetext{This content is available online at \textless{}</xsl:text>
    <xsl:value-of select="$moduleuri"/>
    <xsl:text>\textgreater{}.}
    </xsl:text>
  </xsl:template>

  <!-- Copped from Abel Braaksma via 
       http://www.dpawson.co.uk/xsl/sect2/N5758.html#d8529e694 -->
  <xsl:template name="ordinal">
    <xsl:param name="number" />
    <xsl:choose>
      <xsl:when test="$number mod 100 = 11">th</xsl:when>
      <xsl:when test="$number mod 100 = 12">th</xsl:when>
      <xsl:when test="$number mod 100 = 13">th</xsl:when>
      <xsl:when test="$number mod 10 = 3">rd</xsl:when>
      <xsl:when test="$number mod 10 = 2">nd</xsl:when>
      <xsl:when test="$number mod 10 = 1">st</xsl:when>
      <xsl:otherwise>th</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- Returns a count of the descendent elements of the context node 
     that should be rendered as footnotes -->
  <xsl:template name="count-footnotes">
    <xsl:variable name="note-footnotes"
                  select="count(descendant::cnx:note[translate(@type, $upper-letters, $lower-letters)='footnote']|cnx:footnote)"/>
    <xsl:variable name="link-footnotes" select="count(descendant::cnx:link[@src or @url or @resource])"/>
    <xsl:variable name="cnxn-footnotes">
      <xsl:call-template name="count-cnxn-footnotes">
        <xsl:with-param name="cnxn-nodeset"
                        select="descendant::cnx:cnxn|descendant::cnx:link[@document or @target-id or @version or @resource]"/>
        <xsl:with-param name="position" select="1"/>
      </xsl:call-template>
    </xsl:variable>
<!-- <xsl:text>% count-footnotes
</xsl:text>
<xsl:text>% note: '</xsl:text>
<xsl:value-of select="$note-footnotes"/>
<xsl:text>'
</xsl:text>
<xsl:text>% link: '</xsl:text>
<xsl:value-of select="$link-footnotes"/>
<xsl:text>'
</xsl:text>
<xsl:text>% cnxn: '</xsl:text>
<xsl:value-of select="$cnxn-footnotes"/>
<xsl:text>'
</xsl:text> -->
    <xsl:value-of select="$note-footnotes+$link-footnotes+$cnxn-footnotes"/>
  </xsl:template>

  <xsl:template name="count-cnxn-footnotes">
    <xsl:param name="cnxn-nodeset"/>
    <xsl:param name="position"/>
    <xsl:param name="count" select="0"/>
    <!-- <xsl:if test="count($cnxn-nodeset)"> -->
      <xsl:variable name="this-cnxn" select="$cnxn-nodeset[$position]"/>
      <xsl:variable name="target">
        <xsl:choose>
          <xsl:when test="$this-cnxn/@target-id">
            <xsl:value-of select="$this-cnxn/@target-id"/>
          </xsl:when>
          <xsl:when test="$this-cnxn/@target">
            <xsl:value-of select="$this-cnxn/@target"/>
          </xsl:when>
          <xsl:when test="$this-cnxn/@document">
            <xsl:value-of select="$this-cnxn/@document"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="resource">
        <xsl:if test="@resource">
          <xsl:value-of select="@resource"/>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="target-nodes" select="key('by-id', $target)"/>
      <xsl:variable name="target-node" select="$target-nodes[1]"/>
      <xsl:variable name="cnxn-mode">
        <xsl:call-template name="make-cnxn-mode">
          <xsl:with-param name="target-node" select="$target-node"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="this-count">
        <xsl:choose>
          <xsl:when test="starts-with($cnxn-mode, 'footnote')">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
<!-- 
<xsl:text>
% count: '</xsl:text>
<xsl:value-of select="$count"/>
<xsl:text>'
</xsl:text>
<xsl:text>% this-count: '</xsl:text>
<xsl:value-of select="$this-count"/>
<xsl:text>'
</xsl:text>
-->
      <xsl:choose>
        <!-- <xsl:when test="$position &lt; count($cnxn-nodeset)"> -->
        <xsl:when test="count($cnxn-nodeset[$position])">
          <xsl:call-template name="count-cnxn-footnotes">
            <xsl:with-param name="cnxn-nodeset"
                            select="$cnxn-nodeset"/>
            <xsl:with-param name="position" select="$position+1"/>
            <xsl:with-param name="count" select="$count+$this-count"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$count+$this-count"/>
        </xsl:otherwise>
      </xsl:choose>
    <!-- </xsl:if> -->
  </xsl:template>

  <xsl:template name="get-cnxml-version">
    <xsl:variable name="context-doc-rtf">
      <xsl:choose>
        <xsl:when test="ancestor::document">
          <xsl:copy-of select="ancestor::document[1]"/>
        </xsl:when>
        <xsl:when test="ancestor::cnx:document">
          <xsl:copy-of select="ancestor::cnx:document[1]"/>
        </xsl:when>
        <xsl:when test="ancestor-or-self::cnx:solution[@ref]">
          <xsl:copy-of select="key('document-by-id', substring-before(ancestor-or-self::cnx:solution[@ref][1]/@ref, '*'))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="context-doc" select="exsl:node-set($context-doc-rtf)"/>
    <xsl:choose>
      <xsl:when test="$context-doc/*/@cnxml-version">
        <xsl:value-of select="$context-doc/*/@cnxml-version"/>
      </xsl:when>
      <xsl:otherwise>0.5</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="class-test">
    <xsl:param name="provided-class" />
    <xsl:param name="wanted-class" />
    <xsl:if test="$provided-class = $wanted-class or
            starts-with($provided-class, concat($wanted-class, ' ')) or
            contains($provided-class, concat(' ', $wanted-class, ' ')) or 
            substring($provided-class, string-length($provided-class) - string-length($wanted-class)) = concat(' ', $wanted-class)
            ">1</xsl:if>
  </xsl:template>

</xsl:stylesheet>
