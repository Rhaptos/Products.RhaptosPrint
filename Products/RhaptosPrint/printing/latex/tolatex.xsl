<?xml version= "1.0" standalone="no"?>
<!--
    Master stylesheet for converting CNXML to LaTeX; handles most meta-CNXML
    aspects (title page, TOC, index, bibliography, attributions).

    Author: Chuck Bearden, Christine Donica, Brent Hendricks, Adan Galvan, Scott Kravitz, Brian West
    (C) 2002-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cnx="http://cnx.rice.edu/cnxml"
                xmlns:context="http://cnx.rice.edu/contexts#"
                xmlns:qml="http://cnx.rice.edu/qml/1.0"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:md="http://cnx.rice.edu/mdml"
                xmlns:md4="http://cnx.rice.edu/mdml/0.4"
                xmlns:ind="index"
                xmlns:bib="http://bibtexml.sf.net/"
                xmlns:glo="glossary"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="date"
>
  
  <!-- These stylesheets create the index and the authorlist -->
  <xsl:import href="indexlatex.xsl" />
  <xsl:import href="glossarylatex.xsl"/>
  <xsl:import href="mmltex.xsl"/>
  <xsl:import href="cnxml.xsl"/>

  <!-- Keys and params needed for computing the attribution model -->
  <xsl:key name="module-authors" 
           match="//document[not(ancestor::referenced-objects)]/
                    module-export/author"
           use="."/>
  <xsl:key name="module-authors-byid"
           match="//document[not(ancestor::referenced-objects)]/
                    author"
           use="@id"/>
  <xsl:key name="module-translators"
           match="//document[not(ancestor::referenced-objects)]/
                    module-export/optionalrole[@name='Translator']"
           use="."/>
  <xsl:key name="collection-editors-byname" match="/course/author"
           use="normalize-space(.)"/>

  <xsl:param name="debug-mode"/>
  <xsl:param name="CNX_DISPLAY_HOSTNAME"/>
  <xsl:param name="PROJECT_NAME"/>
  <xsl:param name="PROJECT_SHORT_NAME"/>

  <xsl:variable name="authors" 
                select="//document[not(ancestor::referenced-objects)]/
                        module-export/author[generate-id() =
                        generate-id(key('module-authors', .))]"/>
  <xsl:variable name="authors-byid" 
                select="//document[not(ancestor::referenced-objects)]/
                        author[generate-id() =
                        generate-id(key('module-authors-byid', @id))]"/>
  <xsl:variable name="translators"
                select="//document[not(ancestor::referenced-objects)]/
                        module-export/optionalrole[generate-id() =
                        generate-id(key('module-translators', .))]"/>
  <xsl:variable name="courseId" select="substring-before(substring-after(course/@uri, 'content/'), '/')"/>
  <xsl:variable name="object-id">
    <xsl:choose>
      <xsl:when test="/course">
        <xsl:value-of select="substring-before(substring-after(
                      /course/@uri, 'content/'), '/')"/>
      </xsl:when>
      <xsl:when test="/module">
        <xsl:value-of select="/module/cnx:document/@id"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="object-version">
    <xsl:choose>
      <xsl:when test="/course">
        <xsl:value-of select="substring-after(substring-after(/course/@uri, 'content/'), '/')"/>
      </xsl:when>
      <xsl:when test="/module">
        <xsl:value-of select="/module/cnx:document/module-export/version"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="object-uri-local">
    <xsl:choose>
      <xsl:when test="/course">
        <xsl:value-of select="/course/@uri"/>
      </xsl:when>
      <xsl:when test="/module">
        <xsl:value-of select="/module/cnx:document/module-export/base/@href"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="CNX_CONTENT_URI_LOCAL">
    <xsl:value-of select="substring-before($object-uri-local, 
                  substring-after($object-uri-local, '/content'))"/>
  </xsl:variable>
  <xsl:variable name="CNX_CONTENT_URI">
    <xsl:choose>
      <xsl:when test="string-length(normalize-space($CNX_DISPLAY_HOSTNAME)) > 0">
        <xsl:value-of select="'http://'"/><xsl:value-of select="$CNX_DISPLAY_HOSTNAME"/><xsl:value-of select="'/content'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$CNX_CONTENT_URI_LOCAL"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="CNX_HOST" 
                select="substring-before($CNX_CONTENT_URI, '/content')"/>
  <xsl:variable name="object-uri">
    <xsl:value-of select="$CNX_CONTENT_URI"/><xsl:text>/</xsl:text>
    <xsl:value-of select="$object-id"/><xsl:text>/</xsl:text>
    <xsl:value-of select="$object-version"/><xsl:text>/</xsl:text>
  </xsl:variable>

  <!--ROOT-->
  <xsl:template match="/">
    <xsl:variable name="documentclass">
      <xsl:choose>
        <xsl:when test="/course">book</xsl:when>
        <xsl:when test="/module">article</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fontsize">
      <xsl:choose>
        <xsl:when test="/course/parameters/parameter[@name='fontsize']">
          <xsl:value-of select="/course/parameters/parameter[@name='fontsize']/@value"/>
        </xsl:when>
        <xsl:otherwise>10pt</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nonEditors">
      <xsl:call-template name="editorsAuthors">
        <xsl:with-param name="authors" select="$authors"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="editor-label">
      <xsl:choose>
        <xsl:when test="count(course/author)=1">Collection Editor</xsl:when>
        <xsl:otherwise>Collection Editors</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="author-label">
      <xsl:choose>
        <xsl:when test="count($authors)=1">Author</xsl:when>
        <xsl:otherwise>Authors</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\documentclass[</xsl:text>
    <xsl:value-of select="$fontsize"/>
    <xsl:text>]{</xsl:text>
    <xsl:value-of select="$documentclass"/>
    <xsl:text>}
    </xsl:text>
    <xsl:if test="/course">
      <xsl:call-template name="collection-preamble"/><!-- in cnxml.xsl -->
    </xsl:if>
    <xsl:call-template name="preamble"><!-- in cnxml.xsl -->
      <xsl:with-param name="printfont" 
           select="/course/parameters/parameter[@name='printfont']/@value"/>
      <xsl:with-param name="papersize" 
           select="/course/parameters/parameter[@name='papersize']/@value"/>
    </xsl:call-template>
    <xsl:if test="/module">
      <xsl:call-template name="module-preamble"/><!-- in cnxml.xsl -->
    </xsl:if>
    \begin{document}
    \raggedbottom
    \bibliographystyle{plain} 
    <xsl:if test="/module">
      <xsl:text>\maketitle
    \thispagestyle{cnxheadings}
      </xsl:text>
      <xsl:if test="string-length(module/cnx:document/cnx:metadata/*[self::md4:abstract or self::md:abstract]) and string(module/cnx:document/cnx:metadata/*[self::md4:abstract or self::md:abstract])!='(Blank Abstract)'">
        <xsl:text>\begin{abstract}
        </xsl:text>
        <xsl:apply-templates select="module/cnx:document/cnx:metadata/*[self::md4:abstract or self::md:abstract]/node()"/>
        <xsl:text>
    \end{abstract}
        </xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="catcodes" />
    <xsl:if test="/course">
      <xsl:call-template name="collection-coverpage">
        <xsl:with-param name="nonEditors" select="$nonEditors"/>
        <xsl:with-param name="editor-label" select="$editor-label"/>
      </xsl:call-template>
    </xsl:if>

    \frontmatter
    <xsl:if test="/course">
      <xsl:call-template name="collection-titlepage">
        <xsl:with-param name="nonEditors" select="$nonEditors"/>
        <xsl:with-param name="editor-label" select="$editor-label"/>
        <xsl:with-param name="author-label" select="$author-label"/>
        <xsl:with-param name="authors" select="$authors-byid"/>
        <xsl:with-param name="translators" select="$translators"/>
        <xsl:with-param name="CNX_CONTENT_URI" select="$CNX_CONTENT_URI"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="/course">
      <xsl:call-template name="collection-toc">
        <xsl:with-param name="courseId" select="$courseId"/>
      </xsl:call-template>
    </xsl:if>

    <!-- CONTENT OF THE BOOK -->
    \mainmatter
    <xsl:if test="/course">
      \newpage
    </xsl:if>

    <xsl:apply-templates />

    <!--Glossary -->
    <!-- Only display glossary if they exist -->
    <xsl:choose>
      <xsl:when test="/course/glo:glossarylist">
      \newpage 
      \def\leftmark{GLOSSARY}
      \def\rightmark{GLOSSARY}
      \begin{indexheading}
      \section*{Glossary}
      \label{<xsl:value-of select="$courseId"/>*Glossary}
      \end{indexheading}
      \vspace{.3cm}
      <xsl:if test="not(/course/glo:glossarylist//m:math)">
        \begin{multicols}{2}{
      </xsl:if>
      <xsl:apply-templates select="/course/glo:glossarylist" mode="glossary"/>
      <xsl:if test="not(/course/glo:glossarylist//m:math)">  
        }\end{multicols}
      </xsl:if>
      </xsl:when>
      <xsl:when test="/module/cnx:document//cnx:glossary">
        <xsl:text>\section*{Glossary}
        </xsl:text>
        <xsl:apply-templates select="/module/cnx:document//cnx:glossary" 
                             mode="glossary"/>
      </xsl:when>
    </xsl:choose>

  <!--Bibliography -->
    <xsl:if test="//bib:file[not(ancestor::referenced-objects)]">
      <xsl:if test="/course">\newpage</xsl:if>
      \def\leftmark{BIBLIOGRAPHY}
      \def\rightmark{BIBLIOGRAPHY}
      \label{<xsl:value-of select="$courseId"/>*Bibliography}\nopagebreak\bibliography{index}
    </xsl:if>

      <!--INDEX-->
      <!-- Only display index if entries exist -->
    <xsl:if test="/course //ind:indexlist/ind:item">
      \newpage 
      \def\leftmark{INDEX}
      \def\rightmark{INDEX}
      \begin{indexheading}
      <!--{\LARGE \noindent Index of Keywords and Terms}\\-->
      \section*{Index of Keywords and Terms}
        \label{<xsl:value-of select="$courseId"/>*Index}
        \textbf{Keywords}
        are listed by the section with that keyword 
        (page numbers are in parentheses). Keywords do not necessarily
        appear in the text of the page.  They are merely
        associated with that section. \textsl{Ex. } apples, \S~1.1 (1)
        \textbf{Terms} are
        referenced by the page they appear on. \textsl{Ex. } apples, 1
      \end{indexheading}
      \vspace{.3cm}
      \begin{multicols}{2}{
      <xsl:apply-templates select="//ind:indexlist" mode="index"/>}
      \end{multicols}
    </xsl:if>

    <xsl:if test="/course">
      <xsl:call-template name="attribution-page">
        <xsl:with-param name="courseId" select="$courseId"/>
      </xsl:call-template>
      <xsl:call-template name="collection-backcover"/>
    </xsl:if>
    \end{document}
  </xsl:template>

  <xsl:template name="collection-coverpage">
    <xsl:param name="nonEditors"/>
    <xsl:param name="editor-label"/>
    \begin{center}
    \thispagestyle{empty}

    \vspace*{2in}

    %\rule[5pt]{5.5in}{.5mm}
    {\fontfamily{bch}
    {\Huge <xsl:value-of select="course/name"/>}
    %\rule[5pt]{5.5in}{.5mm}
    \vspace*{1in}
    \\

    <xsl:choose>
      <xsl:when test="$nonEditors = 0">
        {\Large \textbf{By:}\vspace{1mm}\\
        <xsl:for-each select="course/author">
          \indent <xsl:value-of select="."/>\\
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        {\Large \textbf{<xsl:value-of select="$editor-label"/>:}\vspace{1mm}\\
        <xsl:for-each select="course/author">
          \indent <xsl:value-of select="."/>\\
        </xsl:for-each>
        \vspace{3mm}
      </xsl:otherwise>
    </xsl:choose>

    \vfill

    }}
    \end{center}

    <!-- BACK of COVER -->
    \newpage
    \thispagestyle{empty}
  </xsl:template>

  <xsl:template name="collection-titlepage">
    <xsl:param name="nonEditors"/>
    <xsl:param name="editor-label"/>
    <xsl:param name="author-label"/>
    <xsl:param name="authors"/>
    <xsl:param name="translators"/>
    <xsl:param name="CNX_CONTENT_URI"/>
    <!-- Calling YAGNI on licenses other than CC BY [123].0. -->
    <xsl:variable name="cc-license-version"
                  select="translate(substring-after(course/license/@uri, 'http://creativecommons.org/licenses/by/'), '/', '')"/>
    <xsl:variable name="date-revised" select="translate(substring-before(course/revised, ' '), '/', '-')"/>
    <xsl:variable name="year-revised" select="substring-before($date-revised, '-')"/>
    <xsl:variable name="month-revised" select="substring-before(substring-after($date-revised, concat($year-revised, '-')), '-')"/>
    <xsl:variable name="day-revised-tmp" select="substring-after($date-revised, concat($year-revised, '-', $month-revised, '-'))"/>
    <xsl:variable name="day-revised">
      <xsl:choose>
        <xsl:when test="starts-with($day-revised-tmp, '0')">
          <xsl:value-of select="substring-after($day-revised-tmp, '0')"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$day-revised-tmp"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Title page -->
    <xsl:text>\newpage \thispagestyle{empty}
    </xsl:text>
    <xsl:text>\noindent
    </xsl:text>
    <xsl:text>\vspace*{\fill}
    </xsl:text>
    <xsl:text>\begin{center} \fontfamily{bch}
    </xsl:text>
    <xsl:text>{\Huge 
    </xsl:text>
    <xsl:value-of select="course/name"/>
    <xsl:text>}\\
    </xsl:text>
    <xsl:text>\vfill
    </xsl:text>

    <xsl:choose>
      <xsl:when test="$nonEditors = 0">
        <xsl:text>{\Large \textbf{By:}\vspace{1mm}\\
        </xsl:text>
        <xsl:for-each select="course/author">
          <xsl:text>\indent 
          </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>\\
          </xsl:text>
        </xsl:for-each>
        <xsl:text>}
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>{\Large \textbf{
        </xsl:text>
        <xsl:value-of select="$editor-label"/>
        <xsl:text>:}\vspace{1mm}\\
        </xsl:text>
        <xsl:for-each select="course/author">
          <xsl:text>\indent 
          </xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>\\
          </xsl:text>
        </xsl:for-each>
        <xsl:text>\vspace{3mm}
        </xsl:text>
        <xsl:text>\textbf{
        </xsl:text>
        <xsl:value-of select="$author-label"/>
        <xsl:text>:}\vspace{1mm} \\
        </xsl:text>
        <xsl:if test="count($authors) > 5">
          <xsl:text>\begin{multicols}{2}
          </xsl:text>
        </xsl:if>
        <xsl:for-each select="$authors">
          <xsl:sort select="surname"/>
          <xsl:sort select="firstname"/>
          <xsl:variable name="currentid" select="@id" />
          <!-- use the full name in module-export, which may have the surname first. -->
          <xsl:if test="//document/module-export/author[@id=$currentid]">
            <xsl:text>\indent 
            </xsl:text>
            <xsl:value-of select="//document/module-export/author[@id=$currentid]/name"/> 
            <xsl:text>\\
            </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test="count($authors) > 5">
          <xsl:text>\end{multicols}}
          </xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="count($translators) > 0">
        <xsl:text>{\Large \textbf{Translated By:}\vspace{1mm}\\
        </xsl:text>
        <xsl:if test="count($translators) > 3">
          <xsl:text>\begin{multicols}{2}
          </xsl:text>
        </xsl:if>
        <xsl:for-each select="$translators">
          <xsl:text>\indent 
          </xsl:text>
          <xsl:value-of select="normalize-space(name)"/> 
          <xsl:text>\\
          </xsl:text>
        </xsl:for-each>
        <xsl:if test="count($translators) > 3">
          <xsl:text>\end{multicols}}
          </xsl:text>
        </xsl:if>
        <xsl:text>}
        </xsl:text>
    </xsl:if>

    <xsl:text>\vfill
    </xsl:text>

    <xsl:text>{\Large \textbf{Online:}\vspace{1mm} \\
    </xsl:text>

    <xsl:text>\indent \lessthan{}
    </xsl:text>
    <xsl:value-of select="$CNX_CONTENT_URI"/>
    <xsl:value-of select="substring-after(course/@uri, '/content')"/>
    <xsl:text>/
    </xsl:text>
    <xsl:text>\greatthan{} }
    </xsl:text>
    <xsl:text>\vfill
    </xsl:text>
    <xsl:choose>
      <xsl:when test="$PROJECT_SHORT_NAME='Connexions'">
        <xsl:text>{\Large \textbf{C O N N E X I O N S} } \\
        </xsl:text>
        <xsl:text>\vspace*{0.25in}
        </xsl:text>
        <xsl:text>\textbf{Rice University, Houston, Texas}
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>{\Large \textbf{</xsl:text><xsl:value-of select="$PROJECT_SHORT_NAME"/><xsl:text>} } \\
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:text>\end{center}
    </xsl:text>

    <!--Verso of title page -->
    <xsl:text>\newpage
    </xsl:text>
    <xsl:text>\thispagestyle{empty}
    </xsl:text>
    <xsl:text>\noindent\textbf{} \\
    </xsl:text>
    <xsl:text>\par\noindent \textbf{\textsl{}}
    </xsl:text>

    <xsl:text>\vspace{3in} 
    </xsl:text>

    <xsl:text>\vfill
    </xsl:text>
    <xsl:text>\par\noindent{\small This selection and arrangement of content as a collection is copyrighted by </xsl:text>
    <xsl:for-each select="course/licensor">
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:if test="not(position()=last())">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>. It is licensed under the Creative Commons Attribution </xsl:text>
    <xsl:value-of select="$cc-license-version"/> 
    <xsl:text> license (</xsl:text>
    <xsl:value-of select="course/license/@uri" />
    <xsl:text>). \\
    </xsl:text>
    <xsl:if test="string-length($year-revised)">
      <xsl:text>Collection structure revised: </xsl:text>
      <xsl:value-of select="date:month-name($date-revised)"/><xsl:text> </xsl:text>
      <xsl:value-of select="$day-revised"/><xsl:text>, </xsl:text>
      <xsl:value-of select="$year-revised"/><xsl:text> </xsl:text>
      <xsl:text>\\
      </xsl:text>
    </xsl:if>
    <xsl:text>PDF generated: </xsl:text>
    <xsl:value-of select="date:month-name()"/><xsl:text> </xsl:text>
    <xsl:value-of select="date:day-in-month()"/><xsl:text>, </xsl:text>
    <xsl:value-of select="date:year()"/><xsl:text> </xsl:text>
    <xsl:text>\\
    </xsl:text>
    <xsl:text>For copyright and attribution information for the modules contained in this collection, see p. \pageref{</xsl:text>
    <xsl:value-of select="$courseId"/>
    <xsl:text>*Attributions}.}
    </xsl:text>
  </xsl:template>

  <xsl:template name="collection-toc">
    <xsl:param name="courseId"/>
    <!-- TABLE OF CONTENTS PAGE --> 
    \newpage \thispagestyle{empty}
    {\LARGE\sffamily \hfill Table of Contents \\}
    \sloppy
    \begin{toc}
    <!-- Build TOC from elements with @class 'frontmatter' or 'chapter' -->
    <xsl:apply-templates select="course/*[@context:class='frontmatter']|
                          course/*[@context:class='chapter']" mode="toc"/>
    <!-- Add item for glossary -->
    <xsl:if test="course/glo:glossarylist">
      <xsl:text>\item[Glossary]</xsl:text>
      \dotfill\pageref{<xsl:value-of select="$courseId"/>*Glossary}
    </xsl:if>
    <!-- Add item for bibliography -->
    <xsl:if test="//bib:file[not(ancestor::referenced-objects)]">
      <xsl:text>\item[Bibliography]</xsl:text>
      \dotfill\pageref{<xsl:value-of select="$courseId"/>*Bibliography}
    </xsl:if>
    <!-- Add item for index if not empty-->
    <xsl:if test="course/ind:indexlist/ind:item">
      <xsl:text>\item[Index]</xsl:text>
      \dotfill\pageref{<xsl:value-of select="$courseId"/>*Index}
    </xsl:if>
    <xsl:text>\item[Attributions]</xsl:text>
    \dotfill\pageref{<xsl:value-of select="$courseId"/>*Attributions}

    \end{toc}
  </xsl:template>

  <!-- Empty template to prevent printing glossarylist
       in paragraph before the actual glossary         -->
  <xsl:template match="/course/glo:glossarylist|/course/cnx:glossary|
                       /course//cnx:glossary//cnx:definition"/>

  <!--TABLE OF CONTENTS templates-->   
  <!-- TOC Template for frontmatter -->
  <xsl:template match="*[@context:class='frontmatter']" mode="toc">
    <xsl:text>\parbox[b]{\textwidth - 115pt}{\vspace{1pt}\item[</xsl:text><xsl:value-of select="name"/><xsl:text>]</xsl:text>
    \dotfill}\hspace{-2.5pt}\dotfill\pageref{<xsl:value-of select="@id"/>}
    \begin{toc}
    \end{toc}
  </xsl:template>
  
  <!-- TOC Template for groups as chapters -->
  <xsl:template match="group[@context:class='chapter']" mode="toc">
    <xsl:text>\item[</xsl:text>
    <xsl:value-of select="@number"/>
    <xsl:text>]\textbf{</xsl:text><xsl:value-of select="name"/><xsl:text>}</xsl:text>
    \begin{toc}
    <xsl:apply-templates select="*[@context:class='section1']" mode="toc"/>
    <xsl:apply-templates select="solutions" mode="toc"/>
    \end{toc}
  </xsl:template>
  
  <!-- TOC Template for documents (modules) as chapters -->
  <xsl:template match="document[@context:class='chapter']|cnx:document[@context:class='chapter']" mode="toc">
    <xsl:text>\parbox[b]{\textwidth - 115pt}{\vspace{1pt}\item[</xsl:text>
    <xsl:value-of select="@number"/>
    <xsl:text>]\textbf{</xsl:text><xsl:value-of select="name"/><xsl:text>}</xsl:text>
    \dotfill}\hspace{-2.5pt}\dotfill\pageref{<xsl:value-of select="@id"/>}
  </xsl:template>
  
  <!-- TOC Template for top-level sections -->
  <!-- Template contents identical to above for modules as chapters, 
       but this serves a different function, so I'm not collapsing 
       the two just yet.  One day we may be certain that we don't 
       want a different format for top-level sections, and then we 
       could tidy this up. -->
  <xsl:template match="*[@context:class='section1']" mode="toc">
    <xsl:text>\parbox[b]{\textwidth - 115pt}{\vspace{1pt}\item[</xsl:text>
    <xsl:value-of select="@number"/> ] <xsl:value-of select="name"/>
    \dotfill}\hspace{-2.5pt}\dotfill\pageref{<xsl:value-of select="@id"/>}
  </xsl:template>
  
  <xsl:template match="solutions[*]" mode="toc">
    <xsl:variable name="chapnum" select="ancestor::*[@context:class='chapter']/@number"/>
    <xsl:text>\item[]\hspace*{-0.45em}Solutions</xsl:text>
    \dotfill\pageref{chap<xsl:value-of select="$chapnum"/>*solutions}
  </xsl:template>

<!-- Attributions page templates -->
  <xsl:template name="attribution-page">
    <xsl:param name="courseId"/>
    <!-- Attributions page -->
    <xsl:text>\newpage </xsl:text>
    <xsl:text>\setlength{\parskip}{0pt}
    </xsl:text>
    <xsl:text>\section*{Attributions}</xsl:text>
    <xsl:text>\def\leftmark{ATTRIBUTIONS}</xsl:text>
    <xsl:text>\def\rightmark{ATTRIBUTIONS}</xsl:text>
    <xsl:text>\label{</xsl:text>
    <xsl:value-of select="$courseId"/>
    <xsl:text>*Attributions}</xsl:text>
    <xsl:text>\vspace{.3cm}</xsl:text>
    <xsl:variable name="keep-lines-together"
                  select="'\par\nopagebreak\noindent'"/>
    <!-- Attribution for collection -->
    <xsl:text>\begin{minipage}{\textwidth}
    </xsl:text>
    <xsl:text>Collection: \textsl{</xsl:text>
    <xsl:value-of select="course/name"/>
    <xsl:text>}</xsl:text>
    <xsl:value-of select="$keep-lines-together"/>
    <xsl:text>
    </xsl:text>
    <xsl:text>Edited by: </xsl:text>
    <xsl:for-each select="course/author">
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:if test="following-sibling::author"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:value-of select="$keep-lines-together"/>
    <xsl:text>
    </xsl:text>
    <xsl:text>URL: </xsl:text>
    <xsl:value-of select="$CNX_CONTENT_URI"/>
    <xsl:value-of select="substring-after(course/@uri, '/content')"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$keep-lines-together"/>
    <xsl:text>
    </xsl:text>
    <xsl:text>License: </xsl:text>
    <xsl:value-of select="course/license/@uri"/>
    <xsl:text>\par
    </xsl:text>
    <xsl:text>\end{minipage}
    </xsl:text>
    <!-- Attribution for each module -->
    <xsl:for-each select="//document[not(ancestor::referenced-objects)]">
      <xsl:variable name="module-export-uri" select="module-export/base/@href"/>
      <!-- Convert the module URI to a version-specific one, if necessary -->
      <xsl:variable name="version">
        <!-- policy decision: use explicit module version and not 'latest'. see ticket:4572 -->
        <xsl:value-of select="module-export/version"/>
      </xsl:variable>
      <xsl:variable name="module-uri">
        <xsl:value-of select="$CNX_CONTENT_URI"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$version"/>
        <xsl:text>/</xsl:text>
      </xsl:variable>
      <xsl:text>\par\vspace{9pt}\noindent\begin{minipage}{\textwidth}
      </xsl:text>
      <xsl:text>Module: "</xsl:text>
      <xsl:value-of select="module-export/title"/>
      <xsl:text>" </xsl:text>
      <xsl:value-of select="$keep-lines-together"/>
      <xsl:text>
      </xsl:text>
      <xsl:if test="normalize-space(module-export/title) != normalize-space(name)">
        <xsl:text>Used here as: "</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>" </xsl:text>
        <xsl:value-of select="$keep-lines-together"/>
        <xsl:text>
        </xsl:text>
      </xsl:if>
      <xsl:text>By: </xsl:text>
      <xsl:for-each select="module-export/author">
        <xsl:value-of select="normalize-space(name)"/>
        <xsl:if test="following-sibling::author"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:value-of select="$keep-lines-together"/>
      <xsl:text>
      </xsl:text>
      <xsl:text>URL: </xsl:text>
      <xsl:value-of select="$module-uri"/>
      <xsl:value-of select="$keep-lines-together"/>
      <xsl:text>
      </xsl:text>
      <!-- Checks to see whether page label should be singular or plural -->
      <xsl:text>\ifthenelse{\equal{\pageref{</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>}}{\pageref{</xsl:text>
      <xsl:value-of select="concat(@id, '**end')"/>
      <xsl:text>}}}{Page: \pageref{</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>}}{Pages: \pageref{</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>}-\pageref{</xsl:text>
      <xsl:value-of select="concat(@id, '**end')"/>
      <xsl:text>}}</xsl:text>
      <xsl:value-of select="$keep-lines-together"/>
      <xsl:text>
      </xsl:text>
      <xsl:text>Copyright: </xsl:text>
      <xsl:for-each select="module-export/licensor">
        <xsl:value-of select="normalize-space(name)"/>
        <xsl:if test="following-sibling::licensor"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:value-of select="$keep-lines-together"/>
      <xsl:text>
      </xsl:text>
      <xsl:text>License:  </xsl:text>
      <xsl:value-of select="module-export/license/@href"/>
      <xsl:value-of select="$keep-lines-together"/>
      <xsl:text>
      </xsl:text>
      <xsl:if test="module-export/parent">
        <xsl:text>Based on: </xsl:text>
        <xsl:value-of select="module-export/parent/title"/>
        <xsl:value-of select="$keep-lines-together"/>
        <xsl:text>
        </xsl:text>
        <xsl:text>By: </xsl:text>
        <xsl:for-each select="module-export/parent/author">
          <xsl:value-of select="normalize-space(name)"/>
          <xsl:if test="following-sibling::author">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$keep-lines-together"/>
        <xsl:text>
        </xsl:text>
        <xsl:text>URL: </xsl:text>
        <xsl:value-of select="module-export/parent/@href"/>
        <xsl:text>
        </xsl:text>
      </xsl:if>
      <xsl:text>\par\end{minipage}
      </xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="collection-backcover">
    <xsl:variable name="collection_description" 
                  select="/course/context:description"/>
    <!-- Back cover example -->
    \newpage 
    \pagestyle{empty}
    \def\leftmark{}
    \def\rightmark{}
    \noindent
    <xsl:if test="string-length(normalize-space($collection_description)) > 0">
      \textbf{<xsl:value-of select="course/name"/>} \\
      \noindent <xsl:value-of select="/course/context:description"/>
      \vspace*{0.5in} \\
    </xsl:if>

    \noindent\textbf{About <xsl:value-of select="$PROJECT_SHORT_NAME"/>} \\
    <xsl:choose>
      <xsl:when test="$PROJECT_SHORT_NAME='Connexions'">
    \noindent Since 1999, Connexions has been pioneering a global system where anyone can create course materials and make them fully accessible and easily reusable free of charge.  We are a Web-based authoring, teaching and learning environment open to anyone interested in education, including students, teachers, professors and lifelong learners.  We connect ideas and facilitate educational communities.  \par

    \vspace{6pt}\noindent Connexions's modular, interactive courses are in use worldwide by universities, community colleges, K-12 schools, distance learners, and lifelong learners.  Connexions materials are in many languages, including English, Spanish, Chinese, Japanese, Italian, Vietnamese, French, Portuguese, and Thai.  Connexions is part of an exciting new information distribution system that allows for \textbf{Print on Demand Books}.  Connexions has partnered with innovative on-demand publisher QOOP to accelerate the delivery of printed course materials and textbooks into classrooms worldwide at lower prices than traditional academic publishers.
    \vfill
      </xsl:when>
      <xsl:otherwise>
% Your project description goes here.
Rhaptos is a web-based collaborative publishing system for educational material.
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- CONTENT templates -->

  <xsl:template match="*[@context:class='chapter']">
    <!-- temporary apparatus for internal PDF review -->
    <xsl:param name="moduleid">
      <xsl:if test="number($debug-mode) > 0 and local-name(self::*)='document'">
        <xsl:text> (</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:param>
    <xsl:variable name="module-footnotemark">
      <xsl:if test="local-name(self::*) = 'document'">
        <xsl:text>\raisebox{0.6ex}{\normalsize\footnotemark{}}</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="module-footnotetext">
      <xsl:if test="local-name(self::*) = 'document'">
        <xsl:call-template name="module-footnotetext">
          <xsl:with-param name="docnode" select="self::*"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:text>\chapter[</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>]{</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:value-of select="$moduleid"/>
    <xsl:value-of select="$module-footnotemark"/>
    <xsl:text>}
    </xsl:text>
    <xsl:value-of select="$module-footnotetext"/>
    <xsl:text>\setcounter{figure}{1}
    </xsl:text>
    <xsl:text>\setcounter{subfigure}{1}
    </xsl:text>
    <xsl:text>\label{</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>}
    </xsl:text>
    <xsl:apply-templates />
    <xsl:text>\label{</xsl:text>
    <xsl:value-of select="concat(@id, '**end')"/>
    <xsl:text>}
    </xsl:text>
  </xsl:template>

  <xsl:template match="*[@context:class='frontmatter']">
    <!-- temporary apparatus for internal PDF review -->
    <xsl:param name="moduleid">
      <xsl:if test="number($debug-mode) > 0 and local-name(self::*)='document'">
        <xsl:text> (</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:param>
    <xsl:variable name="module-footnotemark">
      <xsl:if test="local-name(self::*) = 'document'">
        <xsl:text>\raisebox{0.6ex}{\normalsize\footnotemark{}}</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="module-footnotetext">
      <xsl:if test="local-name(self::*) = 'document'">
        <xsl:call-template name="module-footnotetext">
          <xsl:with-param name="docnode" select="self::*"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:text>\chapter*{</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:value-of select="$moduleid"/>
    <xsl:value-of select="$module-footnotemark"/>
    <xsl:text>}
    </xsl:text>
    <xsl:value-of select="$module-footnotetext"/>
    <xsl:text>\setcounter{figure}{1}</xsl:text>
    <xsl:text>\setcounter{subfigure}{1}</xsl:text>
    <xsl:text>\label{</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>}
    </xsl:text>
    <xsl:apply-templates />
    <xsl:if test="local-name() = 'document'">
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="concat(@id, '**end')"/>
      <xsl:text>}
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="solutions">
    <xsl:param name="chapnum" select="ancestor::*[@context:class='chapter']/@number"/>
    <xsl:if test="count(cnx:solution|qml:answers)">
      \newpage
      <xsl:choose>
        <xsl:when test="/module">
          \section*{Solutions to Exercises in this Module}
        </xsl:when>
        <xsl:otherwise>
          \section*{Solutions to Exercises in Chapter <xsl:value-of select="$chapnum"/>}
        </xsl:otherwise>
      </xsl:choose>
      \nopagebreak
      \label{chap<xsl:value-of select="$chapnum"/>*solutions}

      <xsl:apply-templates/>

    </xsl:if>
  </xsl:template>

  <xsl:template match="solutions-group">
    <xsl:if test="count(cnx:solution)">
      <xsl:text>\subsection*{Solutions to </xsl:text>
      <xsl:value-of select="name"/>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates select="node()[not(local-name(.)='name')]"/>
    </xsl:if>
  </xsl:template>

  <!-- Suppress metadata output -->
  <xsl:template match="author|licensor|keyword|group[not(starts-with(@context:class, 'section'))]/name|preface/name|course/name" />
  <xsl:template match="created|revised" />
  <!-- Suppress metadata output -->
  <xsl:template match="ind:*" />
  <!-- Suppress documents-as-chapters names -->
  <xsl:template match="document[@context:class='chapter' or @context:class='frontmatter']/name" />

  <!-- Suppress description by default -->
  <xsl:template match="context:description" />

  <!-- Suppress content that is included only because referred to -->
  <xsl:template match="referenced-objects"/>

  <xsl:template name="editorsAuthors">
    <xsl:param name="authors"/>
    <xsl:choose>
      <xsl:when test="$authors">
        <xsl:variable name="first">
          <xsl:choose>
            <xsl:when test="key('collection-editors-byname', normalize-space($authors[1]/name))">0</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="rest">
          <xsl:call-template name="editorsAuthors">
            <xsl:with-param name="authors" select="$authors[position() != 1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$first + $rest"/>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
