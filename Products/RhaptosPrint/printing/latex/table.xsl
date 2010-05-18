<?xml version='1.0'?>
<!--
    Transform CALS tables in CNXML to LaTeX tables, with some amenities.

    Author: Chuck Bearden, Adan Galvan, Christine Donica, Brent Hendricks
    (C) 2002-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cnx="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:latex="#latex"
  xmlns:tables="#tables"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
>

  <!-- This variable is part of a system for creating LaTeX command names 
       associated with particular columns and spans in tables.  It looks 
       like we can probably do without it, so later when work is done on 
       this we should look it again and delete it if it turns out to be
       unnecessary.  Likewise the 'latex' namespace declaration above, and
       code below that adds a 'latex:name' attribute to the normalized 
       colspecs.  -->
  <xsl:variable name="alphabet" select="'abcdefghijklmnopqrstuvwxyz'"/>

  <!-- Lookup elements for column and cell alignment specifiers -->
  <tables:column-align mode="lr" key="left">l</tables:column-align>
  <tables:column-align mode="lr" key="center">c</tables:column-align>
  <tables:column-align mode="lr" key="right">r</tables:column-align>
  <tables:column-align mode="lr" key="justify">l</tables:column-align>
  <tables:column-align mode="para" key="left">p</tables:column-align>
  <tables:column-align mode="para" key="center">p</tables:column-align>
  <tables:column-align mode="para" key="right">p</tables:column-align>
  <tables:column-align mode="para" key="justify">p</tables:column-align>
  <tables:column-align mode="entrytbl" key="left">p</tables:column-align>
  <tables:column-align mode="entrytbl" key="center">p</tables:column-align>
  <tables:column-align mode="entrytbl" key="right">p</tables:column-align>
  <tables:column-align mode="entrytbl" key="justify">p</tables:column-align>
  <tables:cell-align key="left">\raggedright{}</tables:cell-align>
  <tables:cell-align key="center">\centering{}</tables:cell-align>
  <tables:cell-align key="right">\raggedleft{}</tables:cell-align>
  <tables:cell-align key="justify"></tables:cell-align>

  <xsl:template match="cnx:table">
    <!-- Leading 'name' elements and trailing 'caption' elements will be 
         handled in the 'tgroup' template, because we can't place the 
         table float until after we have created and tested the saveboxes 
         for the two table formats. -->
    % \textbf{<xsl:value-of select="@id"/>}\par
    <xsl:apply-templates select="cnx:tgroup"/>
    \par
  </xsl:template>

  <xsl:template match="cnx:table/cnx:name | cnx:table/cnx:title">
    \textbf{<xsl:apply-templates />}\par\nopagebreak\vspace{6pt plus 2pt minus 0pt}
  </xsl:template>

  <!-- if the table has no colspec/@colwidth: (xslt)
         typeset in savebox as supertabular
         if savebox is wider than the \textwidth:
           typeset in savebox as supertabular* with equal cell widths
       else: (xslt)
         typeset in savebox as tabular*
         if savebox is longer than \textheight:
           typeset in savebox as supertabular*
       use savebox
       -->
  <xsl:template match="cnx:tgroup">
    <!-- generate normalized colspec nodeset here -->
    <xsl:variable name="normalized-colspecs">
      <xsl:call-template name="normalize-colspecs">
        <xsl:with-param name="colnum" select="1"/>
        <xsl:with-param name="colidx" select="1"/>
        <xsl:with-param name="normalized-colspecs"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- convert the RTF to a node-set -->
    <xsl:variable name="normalized-colspecs-nodeset" 
                  select="exsl:node-set($normalized-colspecs)"/>
    <!-- FIXME: debug cruft: ditch this later -->
    % how many colspecs?  <xsl:value-of select="count($normalized-colspecs-nodeset/cnx:colspec)"/><xsl:text>
    </xsl:text>
    <xsl:for-each select="$normalized-colspecs-nodeset/*">
      <xsl:text>      % name: </xsl:text><xsl:value-of select="name()"/><xsl:text>
      </xsl:text>
      <xsl:text>      % colnum: </xsl:text><xsl:value-of select="@colnum"/><xsl:text>
      </xsl:text>
      <xsl:text>      % colwidth: </xsl:text><xsl:value-of select="@colwidth"/><xsl:text>
      </xsl:text>
      <xsl:text>      % latex-name: </xsl:text><xsl:value-of select="@latex:name"/><xsl:text>
      </xsl:text>
      <xsl:text>      % colname: </xsl:text><xsl:value-of select="@colname"/><xsl:text>
      </xsl:text>
      <xsl:text>      % align/tgroup-align/default: </xsl:text>
                        <xsl:value-of select="@align"/><xsl:text>/</xsl:text>
                        <xsl:value-of select="@tgroup-align"/><xsl:text>/</xsl:text>
                        <xsl:value-of select="@default-align"/><xsl:text>
      </xsl:text>
      <xsl:text>      % -------------------------
      </xsl:text>
    </xsl:for-each>
    <xsl:text>
    </xsl:text>
    <!-- Set variables for footnote accounting. -->
    <xsl:variable name="footnote-count">
      <xsl:call-template name="count-footnotes"/>
    </xsl:variable>
    <xsl:variable name="cnxn-count" select="count(descendant::cnx:cnxn|cnx:link[@document or @target-id or @version or @resource])"/>
    <!-- Capture the alternative LaTeX versions of this table in variables. -->
    <xsl:variable name="lr-mode-data">
      <xsl:call-template name="make-tabular">
        <xsl:with-param name="table-mode" select="'lr'"/>
        <xsl:with-param name="normalized-colspecs-nodeset"
                        select="$normalized-colspecs-nodeset"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="lr-mode-data-long">
      <xsl:call-template name="make-tabular">
        <xsl:with-param name="table-mode" select="'lr'"/>
        <xsl:with-param name="normalized-colspecs-nodeset"
                        select="$normalized-colspecs-nodeset"/>
        <xsl:with-param name="use-supertabular" select="true()"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- compute all the stuff relevant to table widths in paragraph 
         mode here -->
    <xsl:call-template name="tablewidth-info">
      <xsl:with-param name="normalized-colspecs-nodeset" 
                      select="$normalized-colspecs-nodeset"/>
    </xsl:call-template><xsl:text>
    </xsl:text>
    <xsl:variable name="para-mode-data">
      <xsl:call-template name="make-tabular">
        <xsl:with-param name="normalized-colspecs-nodeset" 
                        select="$normalized-colspecs-nodeset"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="para-mode-data-long">
      <xsl:call-template name="make-tabular">
        <xsl:with-param name="normalized-colspecs-nodeset" 
                        select="$normalized-colspecs-nodeset"/>
        <xsl:with-param name="use-supertabular" select="true()"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- Couldn't contents of the following xsl:if be moved down into the 
         following xsl:choose/xsl:otherwise, where LR mode is relevant?  Or 
         is there some ordering problem that the placement here solves? It 
         doesn't seem like there could be. Try this later. -->
    <xsl:if test="not(cnx:colspec/@colwidth or descendant::cnx:code or 
            descendant::cnx:definition or descendant::cnx:example or 
            descendant::cnx:exercise  or descendant::cnx:figure or descendant::cnx:media or 
            descendant::cnx:list or descendant::cnx:note or 
            descendant::cnx:preformat or descendant::cnx:quote or 
            descendant::cnx:rule or descendant::cnx:equation or
            descendant::cnx:entrytbl or descendant::cnx:*[@morerows])">
      % ----- Begin capturing width of table in LR mode woof
      \settowidth{\mytableboxwidth}{<xsl:value-of select="$lr-mode-data"/>} % end mytableboxwidth set
      \addtocounter{footnote}{-<xsl:value-of select="$footnote-count"/>}
      <xsl:if test="$debug-mode > 0">
        \addtocounter{footnote}{-<xsl:value-of select="$cnxn-count"/>}
      </xsl:if>
      % ----- End capturing width of table in LR mode
    </xsl:if>
    <!-- Decide whether we are formatting the table in paragraph mode or 
         whether we are doing conditional formatting. -->
    <xsl:choose>
      <!-- If the following test is true, then our table is in 
           paragraph mode. -->
      <!-- FIXME: investigate whether the descendant::cnx:code here ensures 
           that the second xsl:when in this choose block never gets called.  
           I can't see how it would get called.  Is this right? -->
      <xsl:when test="cnx:colspec/@colwidth or descendant::cnx:code or 
                descendant::cnx:definition or descendant::cnx:example or 
                descendant::cnx:exercise  or descendant::cnx:figure or descendant::cnx:media or 
                descendant::cnx:list or descendant::cnx:note or 
                descendant::cnx:preformat or descendant::cnx:quote or 
                descendant::cnx:rule or descendant::cnx:equation or
                descendant::cnx:entrytbl or descendant::cnx:*[@morerows]">
        <xsl:choose>
          <!-- If the table contains code, we can't test widths: we just have 
               to go with it as it is. -->
          <xsl:when test="descendant::cnx:code or 
                    descendant::cnx:definition or descendant::cnx:example or 
                    descendant::cnx:exercise  or descendant::cnx:figure or descendant::cnx:media or 
                    descendant::cnx:list or descendant::cnx:note or 
                    descendant::cnx:preformat or descendant::cnx:quote or 
                    descendant::cnx:rule or descendant::cnx:equation">
            % ----- Table with code
            <xsl:call-template name="output-table">
              <xsl:with-param name="table-data" select="$para-mode-data-long"/>
              <xsl:with-param name="footnote-count" select="$footnote-count"/>
              <xsl:with-param name="cnxn-count" select="$cnxn-count"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            % ----- Paragraph mode only
            % ----- Begin capturing height of table
            \settoheight{\mytableboxheight}{<xsl:value-of select="$para-mode-data"/>} % end mytableboxheight set
            \settodepth{\mytableboxdepth}{<xsl:value-of select="$para-mode-data"/>} % end mytableboxdepth set
            \addtolength{\mytableboxheight}{\mytableboxdepth}
            % ----- End capturing height of table
            \addtocounter{footnote}{-<xsl:value-of select="2*$footnote-count"/>}
            <xsl:if test="$debug-mode > 0">
              \addtocounter{footnote}{-<xsl:value-of select="2*$cnxn-count"/>}
            </xsl:if>
            % cnx:colspec/@colwidth
            \typeout{textheight: \the\textheight}
            \typeout{mytableboxheight: \the\mytableboxheight}
            \typeout{table contains code, outputting in para mode}
            <xsl:call-template name="output-table">
              <xsl:with-param name="table-data" select="$para-mode-data-long"/>
              <xsl:with-param name="footnote-count" select="$footnote-count"/>
              <xsl:with-param name="cnxn-count" select="$cnxn-count"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- If the table contains code, we can't test widths: we just have to 
           go with it as it is. -->
      <xsl:when test="descendant::cnx:code">
        <xsl:call-template name="output-table">
          <xsl:with-param name="table-data" select="$lr-mode-data"/>
          <xsl:with-param name="footnote-count" select="$footnote-count"/>
          <xsl:with-param name="cnxn-count" select="$cnxn-count"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Otherwise, we must test the table to see if we should typeset 
           in LR or para mode. -->
      <xsl:otherwise>
        % ----- LR or paragraph mode: must test
        % ----- Begin capturing height of table
        \settoheight{\mytableboxheight}{<xsl:value-of select="$lr-mode-data"/>} % end mytableboxheight set
        \settodepth{\mytableboxdepth}{<xsl:value-of select="$lr-mode-data"/>} % end mytableboxdepth set
        \addtolength{\mytableboxheight}{\mytableboxdepth}
        % ----- End capturing height of table
        \addtocounter{footnote}{-<xsl:value-of select="2*$footnote-count"/>}
        <xsl:if test="$debug-mode > 0">
          \addtocounter{footnote}{-<xsl:value-of select="2*$cnxn-count"/>}
        </xsl:if>
        \ifthenelse{\mytableboxwidth&lt;\textwidth}{% the table fits in LR mode
          \addtolength{\mytableboxwidth}{-\mytablespace}
          \typeout{textheight: \the\textheight}
          \typeout{mytableboxheight: \the\mytableboxheight}
          \typeout{textwidth: \the\textwidth}
          \typeout{mytableboxwidth: \the\mytableboxwidth}
          \ifthenelse{\mytableboxheight&lt;\textheight}{%
        <xsl:call-template name="output-table">
          <xsl:with-param name="table-data" select="$lr-mode-data"/>
          <xsl:with-param name="footnote-count" select="$footnote-count"/>
          <xsl:with-param name="cnxn-count" select="$cnxn-count"/>
        </xsl:call-template>
          }{ % else
        <xsl:call-template name="output-table">
          <xsl:with-param name="table-data" select="$lr-mode-data-long"/>
          <xsl:with-param name="footnote-count" select="$footnote-count"/>
          <xsl:with-param name="cnxn-count" select="$cnxn-count"/>
        </xsl:call-template>
          } % 
        }{% else
        % typeset the table in paragraph mode
        % ----- Begin capturing height of table
        \settoheight{\mytableboxheight}{<xsl:value-of select="$para-mode-data"/>} % end mytableboxheight set
        \settodepth{\mytableboxdepth}{<xsl:value-of select="$para-mode-data"/>} % end mytableboxdepth set
        \addtolength{\mytableboxheight}{\mytableboxdepth}
        % ----- End capturing height of table
        \typeout{textheight: \the\textheight}
        \typeout{mytableboxheight: \the\mytableboxheight}
        \typeout{table too wide, outputting in para mode}
        <xsl:call-template name="output-table">
          <xsl:with-param name="table-data" select="$para-mode-data-long"/>
          <xsl:with-param name="footnote-count" select="$footnote-count"/>
          <xsl:with-param name="cnxn-count" select="$cnxn-count"/>
        </xsl:call-template>
        }% ending lr/para test clause
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Output debug information about this table. -->
  <xsl:template match="cnx:table" mode="debug">
    <xsl:param name="footnote-count"/>
    <xsl:text>\underline{</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>} </xsl:text>
    <xsl:if test="descendant::cnx:entrytbl">entrytbl,</xsl:if>
    <xsl:if test="descendant::*/@morerows">@morerows,</xsl:if>
    <xsl:if test="descendant::*/@rowsep">@rowsep,</xsl:if>
    <xsl:if test="descendant::*/@colsep">@colsep,</xsl:if>
    <xsl:if test="descendant::*/@valign">@valign,</xsl:if>
    <xsl:if test="descendant::*/@char|descendant::*/@charoff">@char/@charoff,</xsl:if>
    <xsl:if test="descendant::m:*">MathML,</xsl:if>
    <xsl:if test="$footnote-count > 0">
      <xsl:value-of select="$footnote-count"/>
      <xsl:text> footnotes</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- Construct and output the table float environment for the table, and 
       handle accounting for footnotes in the table. -->
  <xsl:template name="output-table">
    <xsl:param name="table-data"/>
    <xsl:param name="footnote-count"/>
    <xsl:param name="cnxn-count"/>
    <xsl:variable name="ancestor-item-id" 
                  select="generate-id(ancestor::cnx:item[1])"/>
    % \begin{table}[H]
    % \\ '<xsl:value-of select="$ancestor-item-id"/>' '<xsl:value-of select="count(ancestor::cnx:item[generate-id()=$ancestor-item-id])"/>'
    <xsl:choose>
      <xsl:when test="ancestor::cnx:item and not(preceding::node()
                  [ancestor::cnx:item[1][generate-id()=$ancestor-item-id]]
                  [self::* or self::text()]
                  [string-length(normalize-space(.)) &gt; 0])">
        % \\
        \par
      </xsl:when>
      <xsl:otherwise>
        \begin{center}
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not(preceding-sibling::cnx:tgroup)">
      \label{<xsl:call-template name="make-label">
        <xsl:with-param name="instring" select="parent::cnx:table/@id" />
      </xsl:call-template>}
      <xsl:apply-templates select="parent::cnx:table/cnx:name | parent::cnx:table/cnx:title"/>
    </xsl:if>
    \noindent
    <xsl:value-of select="$table-data"/>
    <xsl:if test="not(ancestor::cnx:item and not(preceding::node()
              [generate-id(ancestor::cnx:item[1])=$ancestor-item-id]
              [self::* or self::text()]
              [string-length(normalize-space(.)) &gt; 0]))">
      \end{center}
    </xsl:if>
    <xsl:if test="not(following-sibling::cnx:tgroup)">
      <xsl:call-template name="make-table-caption"/>
    </xsl:if>
    <xsl:if test="$debug-mode > 0">
      <xsl:text>\textbf{Debug: </xsl:text>
      <xsl:apply-templates select="parent::cnx:table" mode="debug">
        <xsl:with-param name="footnote-count">
          <xsl:choose>
            <xsl:when test="$debug-mode > 0">
              <xsl:value-of select="$footnote-count+$cnxn-count"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$footnote-count"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:apply-templates>
      <xsl:text>}</xsl:text>
    </xsl:if>
    %\end{table}
    <!-- <xsl:text>% footnote-count: </xsl:text>
    <xsl:value-of select="$footnote-count"/><xsl:text>
    </xsl:text> -->
    \addtocounter{footnote}{-<xsl:value-of select="$footnote-count"/>}
    <xsl:if test="$debug-mode > 0">
      \addtocounter{footnote}{-<xsl:value-of select="count(descendant::cnx:cnxn|cnx:link[@document or @target-id or @version or @resource])"/>}
    </xsl:if>
    <xsl:apply-templates select="*" mode="table-footnotes"/>
  </xsl:template>

  <!-- Constructs and outputs the tabular environment for the table. -->
  <xsl:template name="make-tabular">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="table-mode" select="'para'"/>
    <xsl:param name="use-supertabular" select="false()"/>
    <xsl:variable name="tabular-prefix">
      <xsl:if test="$use-supertabular">x</xsl:if>
    </xsl:variable>
    <xsl:variable name="table-width">
      <xsl:choose>
        <xsl:when test="$table-mode='para'">\mytableroom</xsl:when>
        <xsl:otherwise>\mytableboxwidth</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$use-supertabular">
      <xsl:text>\tabletail{%
        \hline
        \multicolumn{</xsl:text>
        <xsl:value-of select="count($normalized-colspecs-nodeset/*)"/>
        <xsl:text>}{|p{</xsl:text>
        <xsl:value-of select="$table-width"/>
        <xsl:text>}|}{\raggedleft \small \sl continued on next page}\\
        \hline
      }
      \tablelasttail{}
      </xsl:text>
    </xsl:if>
    <xsl:text>\begin{</xsl:text>
    <xsl:value-of select="$tabular-prefix"/>
    <xsl:text>tabular</xsl:text>
    <xsl:if test="$table-mode = 'para'"><xsl:text>*</xsl:text></xsl:if>
    <xsl:text>}</xsl:text>
    <xsl:if test="$table-mode = 'para'"><xsl:text>{\mytablewidth}</xsl:text></xsl:if>
    <!-- specify column formats -->
    <xsl:text>[t]{|</xsl:text>
    <xsl:choose>
      <xsl:when test="$table-mode = 'para'">
        <xsl:call-template name="column-format-para-mode">
          <xsl:with-param name="colspec" select="$normalized-colspecs-nodeset/cnx:colspec[1]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="column-format-lr-mode">
          <xsl:with-param name="colspec" select="$normalized-colspecs-nodeset/cnx:colspec[1]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}\hline
    </xsl:text>
    <xsl:apply-templates select="cnx:thead">
      <xsl:with-param name="normalized-colspecs-nodeset" 
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="cnx:tbody">
      <xsl:with-param name="normalized-colspecs-nodeset" 
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="cnx:tfoot">
      <xsl:with-param name="normalized-colspecs-nodeset" 
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
    </xsl:apply-templates>
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$tabular-prefix"/>
    <xsl:text>tabular</xsl:text>
    <xsl:if test="$table-mode = 'para'"><xsl:text>*</xsl:text></xsl:if>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- - Need to get correct column width to format the tabularx for 
         the entrytbl.
       - Will probably need a 'make-entrytbl-spanned' template as well 
         to handle entrytbl inside an entry that spans columns. -->
  <xsl:template name="make-entrytbl">
    <xsl:param name="parent-normalized-colspecs-nodeset"/>
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="table-mode" select="'entrytbl'"/>
    <xsl:param name="colidx"/>
    <xsl:param name="use-supertabular" select="false()"/>
    <xsl:variable name="parent-colspec" select="$parent-normalized-colspecs-nodeset/cnx:colspec[$colidx]"/>
    <xsl:variable name="spanname" select="@spanname"/>
    <xsl:variable name="spanspec" select="ancestor::cnx:tgroup/cnx:spanspec[@spanname = $spanname]"/>
    <xsl:variable name="namest">
      <xsl:choose>
        <xsl:when test="$spanspec">
          <xsl:value-of select="$spanspec/@namest"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@namest"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nameend">
      <xsl:choose>
        <xsl:when test="$spanspec">
          <xsl:value-of select="$spanspec/@nameend"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@nameend"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="entrytbl-width">
      <xsl:choose>
        <xsl:when test="@spanname or (@namest and @nameend and (@namest != @nameend))">
          <xsl:variable name="column-count">
            <!-- Number of columns in span -->
            <xsl:call-template name="count-columns">
              <xsl:with-param name="colspec" select="$parent-normalized-colspecs-nodeset/cnx:colspec[@colname = $namest]"/>
              <xsl:with-param name="nameend" select="$nameend"/>
              <xsl:with-param name="totalcols" select="count($normalized-colspecs-nodeset)"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:call-template name="spanspec-columnwidths">
            <xsl:with-param name="colspec" select="$parent-normalized-colspecs-nodeset/cnx:colspec[@colname = $namest]"/>
            <xsl:with-param name="nameend" select="$nameend"/>
            <xsl:with-param name="column-count" select="$column-count"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="colwidth-convert">
            <xsl:with-param name="colspec" select="$parent-normalized-colspecs-nodeset/cnx:colspec[$colidx]"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="entrytbl-column-format">
      <xsl:call-template name="column-format-entrytbl">
        <xsl:with-param name="cols" select="@cols"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>\hspace*{-\tabcolsep}\begin{tabularx}{</xsl:text>
    <!-- table width here -->
    <xsl:text>\dimexpr</xsl:text>
    <xsl:value-of select="$entrytbl-width"/>
    <xsl:text>+2\tabcolsep\relax}[t]{</xsl:text>
    <xsl:value-of select="$entrytbl-column-format"/>
    <xsl:text></xsl:text>
    <xsl:text>}</xsl:text>
    <xsl:apply-templates select="cnx:thead">
      <xsl:with-param name="normalized-colspecs-nodeset" 
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="cnx:tbody">
      <xsl:with-param name="normalized-colspecs-nodeset" 
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
    </xsl:apply-templates>
    <xsl:text>\end{tabularx}</xsl:text>
    <xsl:if test="@spanname or (@namest and @nameend and (@namest != @nameend))">
      <xsl:text>\hspace{-\tabcolsep}</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- Compute the width of the current table and store it in 
       \mytablewidth. -->
  <xsl:template name="tablewidth">
    <!-- Cases: 
         - mix of proportional and fixed
          - \tablewidth = \linewidth
         - all proportional
           - \tablewidth = \linewidth
         - all fixed (there are colspec/@colwidths with fixed measures, and there are no explicit @colwidths)
           - \tablewidth is sum of fixed column measures, plus extras -->
    <xsl:choose>
      <!-- All columns have explicit fixed width:
           compute width of table from these -->
      <xsl:when test="count(cnx:colspec/@colwidth) = number(@cols) and
                      not(cnx:colspec/@colwidth[contains(., '*')])">
        <xsl:text>% computing table width
        </xsl:text>
        <xsl:call-template name="sum-colwidths">
          <xsl:with-param name="colspec" select="cnx:colspec[1]"/>
        </xsl:call-template>
      </xsl:when>
      <!-- All other cases have some proportional widths: 
           use \linewidth for table width-->
      <xsl:otherwise>
        <xsl:text>\setlength\mytablewidth{\linewidth}
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- When all columns have an explicit fixed-measure width, 
       compute the sum and store it in \mytablewidth.
       FIXME: handle conversion for pica: 'pc' in LaTeX, 'pi' in CALS -->
  <xsl:template name="sum-colwidths">
    <xsl:param name="setlength" select="1"/>
    <xsl:param name="colspec"/>
    <xsl:choose>
      <xsl:when test="$setlength">
        <xsl:text>\setlength\mytablewidth{</xsl:text>
        <xsl:value-of select="$colspec/@colwidth"/>
        <xsl:text>}
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\addtolength\mytablewidth{</xsl:text>
        <xsl:value-of select="$colspec/@colwidth"/>
        <xsl:text>}
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$colspec/following-sibling::cnx:colspec">
        <xsl:call-template name="sum-colwidths">
          <xsl:with-param name="setlength" select="0"/>
          <xsl:with-param name="colspec" select="$colspec/following-sibling::cnx:colspec[1]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\addtolength\mytablewidth{\mytablespace}
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Create a RTF containing a normalized set of colspec elements.
       - Add any implicit colspecs.
       - Add any implicit @colnums.
       - Add any implicit @colwidth='*'.
       - Work around any colspecs that already have @colnum.
       -->
  <xsl:template name="normalize-colspecs">
    <xsl:param name="colnum"/>
    <xsl:param name="colidx"/>
    <xsl:param name="normalized-colspecs"/>
    <xsl:variable name="star-multiplier" select="10"/>
    <!-- Fashion the colspec to add to our normalized set;
         we've collapsed five cases into three. -->
    <xsl:variable name="this-colspec">
      <xsl:choose>
        <!-- no colspec: we make one from scratch -->
        <!-- explicit @colnum > $colunum: we make a new one from scratch, 
        recur on this $colspec instead of on the next one -->
        <xsl:when test="$colidx = -1 or not(cnx:colspec[$colidx]) or
                  number(cnx:colspec[$colidx]/@colnum) > $colnum">
          <cnx:colspec>
            <xsl:attribute name="colnum"><xsl:value-of select="$colnum"/></xsl:attribute>
            <xsl:attribute name="colwidth"><xsl:value-of select="$star-multiplier"/>*</xsl:attribute>
            <xsl:attribute name="latex:name">column<xsl:value-of select="substring($alphabet, $colnum, 1)"/></xsl:attribute>
            <xsl:attribute name="align"></xsl:attribute>
            <xsl:attribute name="tgroup-align">
              <xsl:if test="@align"><xsl:value-of select="@align"/></xsl:if>
            </xsl:attribute>
            <xsl:attribute name="default-align">left</xsl:attribute>
            <xsl:if test="@class">
              <xsl:attribute name="class"><xsl:value-of select="normalize-space(@class)"/></xsl:attribute>
            </xsl:if>
          </cnx:colspec>
        </xsl:when>
        <!-- no @colnum or @colnum < $colnum: we give it a (new) @colnum -->
        <!-- explicit @colnum = $colunum: we keep @colnum -->
        <xsl:when test="not(cnx:colspec[$colidx]/@colnum) or
                  cnx:colspec[$colidx]/@colnum &lt;= $colnum">
          <cnx:colspec>
            <xsl:copy-of select="cnx:colspec[$colidx]/@*"/>
            <xsl:attribute name="colnum">
              <xsl:value-of select="$colnum"/>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="contains(cnx:colspec[$colidx]/@colwidth, '*')">
                <xsl:variable name="star-count">
                  <xsl:choose>
                    <xsl:when test="substring-before(cnx:colspec[$colidx]/@colwidth, '*')">
                      <xsl:value-of select="$star-multiplier * number(substring-before(cnx:colspec[$colidx]/@colwidth, '*'))"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="$star-multiplier"/></xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:attribute name="colwidth">
                  <xsl:value-of select="concat($star-count, '*')"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:when test="not(cnx:colspec[$colidx]/@colwidth)">
                <xsl:attribute name="colwidth">
                  <xsl:value-of select="'10*'"/>
                </xsl:attribute>
              </xsl:when>
            </xsl:choose>
            <xsl:attribute name="latex:name">
              <xsl:text>column</xsl:text>
              <xsl:value-of select="substring($alphabet, $colnum, 1)"/>
            </xsl:attribute>
            <xsl:attribute name="align">
              <xsl:value-of select="cnx:colspec[$colidx]/@align"/>
            </xsl:attribute>
            <xsl:attribute name="tgroup-align">
              <xsl:if test="@align"><xsl:value-of select="@align"/></xsl:if>
            </xsl:attribute>
            <xsl:attribute name="default-align">left</xsl:attribute>
            <xsl:if test="@class">
              <xsl:attribute name="class"><xsl:value-of select="normalize-space(@class)"/></xsl:attribute>
            </xsl:if>
          </cnx:colspec>
        </xsl:when>
        <!-- Khaaann! -->
        <xsl:otherwise>
          <xsl:message>Something is not right!</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Recur, or stop here? -->
    <xsl:choose>
      <xsl:when test="$colnum &lt;= @cols">
        <!-- Select the colspec on which to recur.  If we've run out of
              explicit colspecs, the variable is empty. -->
        <xsl:variable name="next-colidx">
          <xsl:choose>
            <!-- We haven't reached this $colspec yet. -->
            <xsl:when test="number(cnx:colspec[$colidx]/@colnum) > number($colnum)">
              <xsl:value-of select="$colidx"/>
            </xsl:when>
            <!-- There are more colspecs; use the next one. -->
            <xsl:when test="cnx:colspec[$colidx]/following-sibling::cnx:colspec">
              <xsl:value-of select="$colidx + 1"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="-1"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
    <!-- <xsl:message>$colidx is a <xsl:value-of select="exsl:object-type($colidx)"/> with <xsl:value-of select="$colidx"/></xsl:message> -->
        <!-- Debug info -->
        <xsl:variable name="debuginfo">
          <xsl:comment> $colnum: <xsl:value-of select="$colnum"/> </xsl:comment>
          <xsl:comment> $colidx: <xsl:value-of select="$colidx"/> </xsl:comment>
          <xsl:comment> number(cnx:colspec[$colidx]/@colnum): <xsl:value-of
            select="number(cnx:colspec[$colidx]/@colnum)"/> </xsl:comment>
          <xsl:comment> count(cnx:colspec[$colidx]/following-sibling::colspec): 
            <xsl:value-of select="count(cnx:colspec[$colidx]/following-sibling::cnx:colspec)"/> </xsl:comment>
        </xsl:variable>
        <!-- There was an old man named Michael Finnegan ... -->
        <xsl:call-template name="normalize-colspecs">
          <xsl:with-param name="colnum" select="$colnum + 1"/>
          <xsl:with-param name="colidx" select="number($next-colidx)"/>
          <xsl:with-param name="normalized-colspecs">
            <xsl:copy-of select="$normalized-colspecs"/><xsl:text>
            </xsl:text>
            <xsl:copy-of select="$this-colspec"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$normalized-colspecs"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Compute the total width occupied by all columns with widths in 
       fixed measures.  -->
  <xsl:template name="fixedwidth">
    <xsl:param name="colspec"/>
    <xsl:variable name="colwidth" select="$colspec/@colwidth"/>
    <!-- write the LaTeX commands to adjust \myfixedwidth -->
    <xsl:if test="not(contains($colwidth, '*'))">
      <xsl:text>    \addtolength\myfixedwidth{</xsl:text>
      <xsl:value-of select="$colwidth"/>
      <xsl:text>}
</xsl:text>
    </xsl:if>
    <!-- recur if there are more colspecs -->
    <xsl:if test="$colspec/following-sibling::cnx:colspec">
      <xsl:call-template name="fixedwidth">
        <xsl:with-param name="colspec" select="$colspec/following-sibling::cnx:colspec[1]"/>
      </xsl:call-template>
    </xsl:if>
<!-- etc. -->
  </xsl:template>

  <!-- Compute the value of one '*' width and store it in \mystarwidth -->
  <xsl:template name="starwidth">
    <xsl:param name="colspec"/>
    <xsl:param name="numstars" select="0"/>
    <xsl:variable name="colwidth" select="$colspec/@colwidth"/>
    <xsl:choose>
      <xsl:when test="$colspec/following-sibling::cnx:colspec">
        <xsl:call-template name="starwidth">
          <xsl:with-param name="colspec" select="$colspec/following-sibling::cnx:colspec[1]"/>
          <xsl:with-param name="numstars">
            <xsl:choose>
              <xsl:when test="contains($colwidth, '*')">
                <xsl:variable name="starcount" select="substring-before($colwidth, '*')"/>
                <xsl:choose>
                  <xsl:when test="number($starcount) > 0">
                    <xsl:value-of select="$numstars + number($starcount)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$numstars + 1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$numstars"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="newstars">
          <xsl:choose>
            <xsl:when test="contains($colwidth, '*')">
              <xsl:variable name="starcount" select="substring-before($colwidth, '*')"/>
              <xsl:choose>
                <xsl:when test="number($starcount) > 0">
                  <xsl:value-of select="number($starcount)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="0"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:text>\setlength\mystarwidth{\mytableroom}
        </xsl:text>
        <xsl:text>\addtolength\mystarwidth{-\myfixedwidth}
        </xsl:text>
        <xsl:if test="($numstars + $newstars) > 0">
          <xsl:text>\divide\mystarwidth </xsl:text><xsl:value-of select="$numstars + $newstars"/><xsl:text>
        </xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="starwidth-old">
    <xsl:param name="cols"/>
    <xsl:param name="colspecs"/>
    <xsl:variable name="numstars">
      <xsl:value-of select="number(@cols) - count($colspecs/@colwidth[not(contains(., '*'))])"/>
    </xsl:variable>
    % Number of stars: <xsl:value-of select="$numstars"/><xsl:text>
    </xsl:text>
    <xsl:if test="number($numstars) > 0">
      <xsl:text>\setlength\mystarwidth{\mytableroom}
      </xsl:text>
      <xsl:for-each select="$colspecs/@colwidth[not(contains(., '*'))]">
        <xsl:text>\addtolength\mystarwidth{</xsl:text><xsl:value-of select="."/>
        <xsl:text>}
        </xsl:text>
      </xsl:for-each>
      <xsl:text>\divide\mystarwidth </xsl:text><xsl:value-of select="$numstars"/><xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="colwidth-convert">
    <!-- FIXME: handle different abbreviations for pica (LaTeX v CALS) -->
    <xsl:param name="colspec"/>
    <xsl:variable name="colwidth" select="$colspec/@colwidth"/>
    <xsl:variable name="output-colwidth">
      <xsl:choose>
        <xsl:when test="contains($colwidth, '*')">
          <xsl:value-of select="substring-before($colwidth, '*')"/><xsl:text>\mystarwidth</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$colwidth"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text></xsl:text><xsl:value-of select="$output-colwidth"/>
  </xsl:template>

  <!-- This template, when called in the context of a tgroup and with a 
       parameter containing a nodeset of normalized colspecs for the tgroup,
       outputs the LaTeX code for the following:
       - \mytablespace
       - \mytableroom
       - \myfixedwidth
       - \mystarwidth
       -->
  <xsl:template name="tablewidth-info">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <!-- compute table space here -->
    \setlength\mytablespace{<xsl:value-of select="number(@cols) * 2"/>\tabcolsep}
    \addtolength\mytablespace{<xsl:value-of select="number(@cols) + 1"/>\arrayrulewidth}
    <!-- compute table width here -->
    <xsl:call-template name="tablewidth"/><xsl:text>
    </xsl:text>
    <!-- compute table content room here -->
    \setlength\mytableroom{\mytablewidth}
    \addtolength\mytableroom{-\mytablespace}
    <!-- compute \myfixedwidth here -->
    \setlength\myfixedwidth{0pt}
    <xsl:call-template name="fixedwidth">
      <xsl:with-param name="colspec" select="$normalized-colspecs-nodeset/cnx:colspec[1]"/>
    </xsl:call-template>
    <!-- compute \mystarwidth here -->
    <xsl:call-template name="starwidth">
      <xsl:with-param name="colspec" select="$normalized-colspecs-nodeset/cnx:colspec[1]"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Output the p{} column format specifiers with correct widths 
       for paragraph mode tables -->
  <!-- FIXME: add support for alignments other than left-justified -->
  <xsl:template name="column-format-para-mode">
    <xsl:param name="colspec"/>
    <xsl:variable name="colwidth">
      <xsl:call-template name="colwidth-convert">
        <xsl:with-param name="colspec" select="$colspec"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="align">
      <xsl:call-template name="align-from-colspec">
        <xsl:with-param name="colspec" select="$colspec"/>
      </xsl:call-template>
    </xsl:variable>
    <!--<xsl:variable name="column-type">
      <xsl:value-of select="document('')/*/tables:column-align[@mode='para'][@key=$align]"/>
    </xsl:variable>
    <xsl:value-of select="$column-type"/>-->
    <xsl:text>p{</xsl:text>
    <xsl:value-of select="$colwidth"/>
    <xsl:text>}|</xsl:text>
    <xsl:if test="$colspec/following-sibling::cnx:colspec">
      <xsl:call-template name="column-format-para-mode">
        <xsl:with-param name="colspec" select="$colspec/following-sibling::cnx:colspec[1]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Output the lcr column format specifiers for LR mode tables -->
  <!-- FIXME: add support for alignments other than l -->
  <xsl:template name="column-format-lr-mode">
    <xsl:param name="colspec"/>
    <xsl:variable name="align">
      <xsl:call-template name="align-from-colspec">
        <xsl:with-param name="colspec" select="$colspec"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="column-type">
      <xsl:value-of select="document('')/*/tables:column-align[@mode='lr'][@key=$align]"/>
    </xsl:variable>
    <xsl:value-of select="$column-type"/><xsl:text>|</xsl:text>
    <xsl:if test="$colspec/following-sibling::cnx:colspec">
      <xsl:call-template name="column-format-lr-mode">
        <xsl:with-param name="colspec" select="$colspec/following-sibling::cnx:colspec[1]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="column-format-entrytbl">
    <xsl:param name="cols"/>
    <xsl:if test="$cols &gt; 0">
      <xsl:text>X</xsl:text>
      <xsl:if test="$cols &gt; 1">
        <xsl:text>|</xsl:text>
      </xsl:if>
      <xsl:call-template name="column-format-entrytbl">
        <xsl:with-param name="cols" select="$cols - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Null op: colspecs are processed by recursive named templates -->
  <xsl:template match="cnx:colspec"></xsl:template>

  <!-- Null op: spanspecs are accessed directly via XPaths -->
  <xsl:template match="cnx:spanspec"></xsl:template>

  <!-- Handle t{head,body,foot} by computing needed values and applying 
       templates to the first cnx:row child.  The template for cnx:row 
       will recur on its following siblings. -->
  <xsl:template match="cnx:thead|cnx:tbody|cnx:tfoot">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="table-mode"/>
    <xsl:variable name="rowspan-info-rtf">
      <xsl:call-template name="make-rowspan-info-rtf">
        <xsl:with-param name="colcount" 
                        select="number(parent::*/@cols)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="rowspan-info-nodeset" 
                  select="exsl:node-set($rowspan-info-rtf)"/>
    <xsl:text>% count in rowspan-info-nodeset: </xsl:text>
    <xsl:value-of select="count($rowspan-info-nodeset/*)"/>
    <xsl:text>
    </xsl:text>
    <xsl:apply-templates select="cnx:row[1]">
      <xsl:with-param name="normalized-colspecs-nodeset"
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
      <xsl:with-param name="row-parent" select="local-name()"/>
      <xsl:with-param name="colidx" select="1"/>
      <xsl:with-param name="prev-rowspan-info-nodeset" select="$rowspan-info-nodeset"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Handle cnx:row by applying templates to first cnx:entry; the applied 
       template will recur on following siblings.  After we handle cnx:entry 
       elements in this row, we go back and assess the rowspan info passed in 
       to this template.  For each rowspan element with a @skipcount > 0, we 
       decrement the value by one.  If a cnx:entry has a @morerows attribute, 
       we assign its value to the corresponding rowspan element.  We then 
       recur on the next row.  -->
  <xsl:template match="cnx:row">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="table-mode"/>
    <xsl:param name="row-parent"/>
    <xsl:param name="colidx"/>
    <xsl:param name="prev-rowspan-info-nodeset"/>
    <!-- Update the rowspan nodeset with info from this row. -->
    <xsl:variable name="rowspan-info-rtf">
      <xsl:call-template name="update-rowspan-info-rtf">
        <xsl:with-param name="prev-rowspan-info-nodeset" 
                        select="$prev-rowspan-info-nodeset"/>
        <xsl:with-param name="normalized-colspecs-nodeset"
                        select="$normalized-colspecs-nodeset"/>
        <xsl:with-param name="table-cells-nodeset" select="*"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="rowspan-info-nodeset" 
                  select="exsl:node-set($rowspan-info-rtf)"/>
    <xsl:apply-templates select="*[1]">
      <xsl:with-param name="normalized-colspecs-nodeset"
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
      <xsl:with-param name="row-parent" select="$row-parent"/>
      <xsl:with-param name="colidx" select="$colidx"/>
      <xsl:with-param name="rowspan-info-nodeset" 
                      select="$rowspan-info-nodeset"/>
    </xsl:apply-templates>
    <xsl:text>% rowspan info: </xsl:text>
    <xsl:for-each select="$rowspan-info-nodeset/cnx:rowspan">
      <xsl:text>col</xsl:text>
      <xsl:value-of select="position()"/>
      <xsl:text> '</xsl:text>
      <xsl:value-of select="@rowcount"/>
      <xsl:text>' | '</xsl:text>
      <xsl:value-of select="@start"/>
      <xsl:text>' | '</xsl:text>
      <xsl:value-of select="@spanright"/>
      <xsl:text>'</xsl:text>
      <xsl:if test="position() != last()">
        <xsl:text> || </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>
    </xsl:text>
    <xsl:text> \tabularnewline</xsl:text>
    <xsl:call-template name="make-clines">
      <xsl:with-param name="rowspan-info-nodeset" select="$rowspan-info-nodeset"/>
    </xsl:call-template>
    <xsl:text>
      %--------------------------------------------------------------------
    </xsl:text>
    <xsl:apply-templates select="following-sibling::cnx:row[1]">
      <xsl:with-param name="normalized-colspecs-nodeset"
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
      <xsl:with-param name="row-parent" select="$row-parent"/>
      <xsl:with-param name="colidx" select="1"/>
      <xsl:with-param name="prev-rowspan-info-nodeset" 
                      select="$rowspan-info-nodeset"/>
    </xsl:apply-templates>
  </xsl:template>

<!--
  <xsl:template match="cnx:tfoot">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="table-mode"/>
    <xsl:apply-templates select="cnx:row/cnx:entry">
      <xsl:with-param name="normalized-colspecs-nodeset"
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
      <xsl:with-param name="row-parent" select="'tfoot'"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="cnx:tbody">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="table-mode"/>
    <xsl:apply-templates select="cnx:row/cnx:entry">
      <xsl:with-param name="normalized-colspecs-nodeset"
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
      <xsl:with-param name="row-parent" select="'tbody'"/>
    </xsl:apply-templates>
  </xsl:template>-->

  <!-- Code common to handling all cnx:row/cnx:entry elements.  Test to see 
       whether or not multicolumn handling is needed, and call the 
       appropriate named template to make the entry. -->
  <xsl:template match="cnx:entry">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="table-mode"/>
    <xsl:param name="row-parent"/>
    <xsl:param name="colidx"/>
    <xsl:param name="rowspan-info-nodeset"/>
    <xsl:choose>
      <xsl:when test="@spanname or (@namest and @nameend and (@namest != @nameend))">
        <xsl:call-template name="make-entry-spanned">
          <xsl:with-param name="normalized-colspecs-nodeset"
                          select="$normalized-colspecs-nodeset"/>
          <xsl:with-param name="table-mode" select="$table-mode"/>
          <xsl:with-param name="rowspan-info-nodeset"
                          select="$rowspan-info-nodeset"/>
          <xsl:with-param name="row-parent" select="$row-parent"/>
          <xsl:with-param name="colidx" select="$colidx"/>
          <xsl:with-param name="data">
            <xsl:apply-templates/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-entry">
          <xsl:with-param name="normalized-colspecs-nodeset"
                          select="$normalized-colspecs-nodeset"/>
          <xsl:with-param name="rowspan-info-nodeset"
                          select="$rowspan-info-nodeset"/>
          <xsl:with-param name="table-mode" select="$table-mode"/>
          <xsl:with-param name="row-parent" select="$row-parent"/>
          <xsl:with-param name="colidx" select="$colidx"/>
          <xsl:with-param name="data">
            <xsl:apply-templates/>
          </xsl:with-param>
       </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnx:entrytbl">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="rowspan-info-nodeset"/>
    <xsl:param name="table-mode"/>
    <xsl:param name="row-parent"/>
    <xsl:param name="colidx"/>
    <xsl:param name="rowspan-info-nodeset"/>
    <xsl:variable name="entrytbl-normalized-colspecs">
      <xsl:call-template name="normalize-colspecs">
        <xsl:with-param name="colnum" select="1"/>
        <xsl:with-param name="colidx" select="1"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- convert the RTF to a node-set -->
    <xsl:variable name="entrytbl-normalized-colspecs-nodeset" 
                  select="exsl:node-set($entrytbl-normalized-colspecs)"/>
    <xsl:text>% Entering entrytbl
    </xsl:text>
    <xsl:variable name="tabular-data">
      <xsl:call-template name="make-entrytbl">
        <xsl:with-param name="parent-normalized-colspecs-nodeset"
                        select="$normalized-colspecs-nodeset"/>
        <xsl:with-param name="normalized-colspecs-nodeset"
                        select="$entrytbl-normalized-colspecs-nodeset"/>
        <xsl:with-param name="colidx" select="$colidx"/>
        <xsl:with-param name="table-mode" select="'entrytbl'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@spanname or (@namest and @nameend and (@namest != @nameend))">
        <xsl:call-template name="make-entry-spanned">
          <xsl:with-param name="normalized-colspecs-nodeset"
                          select="$normalized-colspecs-nodeset"/>
          <xsl:with-param name="rowspan-info-nodeset"
                          select="$rowspan-info-nodeset"/>
          <xsl:with-param name="table-mode" select="$table-mode"/>
          <xsl:with-param name="row-parent" select="$row-parent"/>
          <xsl:with-param name="colidx" select="$colidx"/>
          <xsl:with-param name="data">
            <xsl:copy-of select="$tabular-data"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="make-entry">
          <xsl:with-param name="normalized-colspecs-nodeset"
                          select="$normalized-colspecs-nodeset"/>
          <xsl:with-param name="rowspan-info-nodeset"
                          select="$rowspan-info-nodeset"/>
          <xsl:with-param name="table-mode" select="$table-mode"/>
          <xsl:with-param name="row-parent" select="$row-parent"/>
          <xsl:with-param name="colidx" select="$colidx"/>
          <xsl:with-param name="data">
            <xsl:copy-of select="$tabular-data"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Handle single-cell cnx:entry elements. -->
  <xsl:template name="make-entry">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="rowspan-info-nodeset"/>
    <xsl:param name="table-mode"/>
    <xsl:param name="row-parent"/>
    <xsl:param name="colidx"/>
    <xsl:param name="data"/>
    <xsl:variable name="colspec" 
                  select="$normalized-colspecs-nodeset/cnx:colspec[$colidx]"/>
    <xsl:variable name="rowspan" 
                  select="$rowspan-info-nodeset/cnx:rowspan[$colidx]"/>
    <xsl:variable name="is-rowheader">
      <xsl:call-template name="is-rowheader">
        <xsl:with-param name="colspec" select="$colspec"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="align">
      <xsl:choose>
        <xsl:when test="@align">
          <xsl:value-of select="@align"/>
        </xsl:when>
        <xsl:when test="string($colspec/@align)">
          <xsl:value-of select="$colspec/@align"/>
        </xsl:when>
        <xsl:when test="string($colspec/@trgoup-align)">
          <xsl:value-of select="$colspec/@trgoup-align"/>
        </xsl:when>
        <xsl:when test="string($colspec/@default-align)">
          <xsl:value-of select="$colspec/@default-align"/>
        </xsl:when>
        <xsl:otherwise>left</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="colspec-align">
      <xsl:call-template name="align-from-colspec">
        <xsl:with-param name="colspec" select="$colspec"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>% align/colidx: </xsl:text>
    <xsl:value-of select="$align"/>,<xsl:value-of select="$colidx"/><xsl:text>
    </xsl:text>
    <!-- This is part of the horizontal alignment mechanism that was broken 
         by entrytbl handling (see #4315 and #5816). -->
    <xsl:if test="$align and ($align != $colspec-align)">
      <xsl:choose>
        <xsl:when test="$table-mode = 'lr'">
          <xsl:variable name="left-colsep">
            <xsl:choose>
              <xsl:when test="not(preceding-sibling::*)">|</xsl:when>
              <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:text>\multicolumn{1}{</xsl:text>
          <!-- Add left vertical table rule for this cell if needed -->
          <xsl:value-of select="$left-colsep"/>
          <xsl:value-of select="document('')/*/tables:column-align[@mode=$table-mode][@key=$align]"/>
          <xsl:text>|}{</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="document('')/*/tables:cell-align[@key=$align]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <!-- Begin multirow handling. -->
    % rowcount: '<xsl:value-of select="$rowspan/@rowcount"/>' | start: '<xsl:value-of select="$rowspan/@start"/>' | colidx: '<xsl:value-of select="$colidx"/>'
    <xsl:choose>
      <!-- Typeset an empty placeholder cell for a spanned row, and recur on 
           the same cnx:entry. -->
      <xsl:when test="$rowspan[@rowcount &gt; 0 and @start = 'false']">
        % Inserting a blank placeholder cell and recurring on this cnx:entry or cnx:entrytbl
        <xsl:call-template name="entryend">
          <xsl:with-param name="table-mode" select="$table-mode"/>
          <xsl:with-param name="row-parent" select="$row-parent"/>
          <xsl:with-param name="colidx" select="$colidx"/>
          <xsl:with-param name="rowspan-info-nodeset" select="$rowspan-info-nodeset"/>
        </xsl:call-template>
        <xsl:apply-templates select="self::*">
          <xsl:with-param name="normalized-colspecs-nodeset"
                          select="$normalized-colspecs-nodeset"/>
          <xsl:with-param name="rowspan-info-nodeset"
                          select="$rowspan-info-nodeset"/>
          <xsl:with-param name="table-mode" select="$table-mode"/>
          <xsl:with-param name="row-parent" select="$row-parent"/>
          <xsl:with-param name="colidx" select="$colidx+1"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        % Formatting a regular cell and recurring on the next sibling
        <xsl:call-template name="multirow-handler">
          <xsl:with-param name="rowspan" select="$rowspan"/>
          <xsl:with-param name="colwidth-in" select="$normalized-colspecs-nodeset/*[$colidx]/@colwidth"/>
          <xsl:with-param name="data">
            <xsl:if test="$row-parent = 'thead' or $row-parent = 'tfoot' or $is-rowheader = '1'">
              <xsl:text>{\bfseries </xsl:text>
            </xsl:if>
            <xsl:copy-of select="$data"/>
            <xsl:if test="$row-parent = 'thead' or $row-parent = 'tfoot' or $is-rowheader = '1'">
              <xsl:text>}</xsl:text>
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
        <!-- End multirow handling. -->
        <xsl:if test="$align and ($align != $colspec-align) and ($table-mode = 'lr')">
          <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:call-template name="entryend">
          <xsl:with-param name="table-mode" select="$table-mode"/>
          <xsl:with-param name="row-parent" select="$row-parent"/>
          <xsl:with-param name="colidx" select="$colidx"/>
          <xsl:with-param name="rowspan-info-nodeset" select="$rowspan-info-nodeset"/>
        </xsl:call-template>
        <!-- There's a following entry or entrytbl on which to recur. -->
        <!-- Add apply-templates for next sibling here -->
        <xsl:choose>
          <xsl:when test="not(following-sibling::*)">
            <xsl:call-template name="make-rowspan-placeholders">
              <xsl:with-param name="normalized-colspecs-nodeset"
                              select="$normalized-colspecs-nodeset"/>
              <xsl:with-param name="rowspan-info-nodeset"
                              select="$rowspan-info-nodeset"/>
              <xsl:with-param name="table-mode" select="$table-mode"/>
              <xsl:with-param name="row-parent" select="$row-parent"/>
              <xsl:with-param name="colidx" select="$colidx+1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="following-sibling::*[1]">
              <xsl:with-param name="normalized-colspecs-nodeset"
                              select="$normalized-colspecs-nodeset"/>
              <xsl:with-param name="rowspan-info-nodeset"
                              select="$rowspan-info-nodeset"/>
              <xsl:with-param name="table-mode" select="$table-mode"/>
              <xsl:with-param name="row-parent" select="$row-parent"/>
              <xsl:with-param name="colidx" select="$colidx+1"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Handle cnx:entry elements that span columns. -->
  <xsl:template name="make-entry-spanned">
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="rowspan-info-nodeset"/>
    <xsl:param name="table-mode"/>
    <xsl:param name="row-parent"/>
    <xsl:param name="colidx"/>
    <xsl:param name="data"/>
    <xsl:variable name="spanname" select="@spanname"/>
    <xsl:variable name="spanspec" select="ancestor::cnx:tgroup/cnx:spanspec[@spanname = $spanname]"/>
    <xsl:variable name="namest">
      <xsl:choose>
        <xsl:when test="$spanspec">
          <xsl:value-of select="$spanspec/@namest"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@namest"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="nameend">
      <xsl:choose>
        <xsl:when test="$spanspec">
          <xsl:value-of select="$spanspec/@nameend"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@nameend"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="left-colsep">
      <xsl:choose>
        <xsl:when test="not(preceding-sibling::*)">|</xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="align">
      <xsl:choose>
        <xsl:when test="@align">
          <xsl:value-of select="@align"/>
        </xsl:when>
        <xsl:when test="string($spanspec/@align)">
          <xsl:value-of select="$spanspec/@align"/>
        </xsl:when>
        <xsl:when test="string($normalized-colspecs-nodeset/cnx:colspec[$colidx]/@align)">
          <xsl:value-of select="$normalized-colspecs-nodeset/cnx:colspec[$colidx]/@align"/>
        </xsl:when>
        <xsl:when test="string($normalized-colspecs-nodeset/cnx:colspec[$colidx]/@trgoup-align)">
          <xsl:value-of select="$normalized-colspecs-nodeset/cnx:colspec[$colidx]/@trgoup-align"/>
        </xsl:when>
        <xsl:otherwise>center</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="column-format">
          <xsl:value-of select="document('')/*/tables:column-align[@mode=$table-mode][@key=$align]"/>
    </xsl:variable>
    <xsl:variable name="colspec" select="$normalized-colspecs-nodeset/cnx:colspec[@colname = $namest]"/>
    <xsl:variable name="column-count">
      <!-- Number of columns in span -->
      <xsl:call-template name="count-columns">
        <xsl:with-param name="colspec" select="$colspec"/>
        <xsl:with-param name="nameend" select="$nameend"/>
        <xsl:with-param name="totalcols" select="count($normalized-colspecs-nodeset)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="is-rowheader">
      <xsl:call-template name="is-rowheader">
        <xsl:with-param name="colspec" select="$colspec"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>% My position: </xsl:text><xsl:value-of select="count(preceding-sibling::*)"/><xsl:text>
    </xsl:text>
    <xsl:text>% my spanname: </xsl:text><xsl:value-of select="@spanname"/><xsl:text>
    </xsl:text>
    <xsl:text>% my ct of spanspec: </xsl:text><xsl:value-of select="count($spanspec)"/><xsl:text>
    </xsl:text>
    <xsl:text>% my column-count: </xsl:text><xsl:value-of select="$column-count"/><xsl:text>
    </xsl:text>
    <xsl:text>% align/colidx: </xsl:text>
    <xsl:value-of select="$align"/>,<xsl:value-of select="$colidx"/><xsl:text>
    </xsl:text>
    <xsl:text>\multicolumn{</xsl:text><xsl:value-of select="$column-count"/>
    <xsl:text>}{</xsl:text><xsl:value-of select="$left-colsep"/>
    <xsl:value-of select="$column-format"/>
    <xsl:if test="$table-mode='para' or $table-mode='entrytbl'">
      <xsl:text>{\dimexpr</xsl:text>
      <!-- Width of spanned columns, plus spacers -->
      <xsl:call-template name="spanspec-columnwidths">
        <xsl:with-param name="colspec" select="$normalized-colspecs-nodeset/cnx:colspec[@colname = $namest]"/>
        <xsl:with-param name="nameend" select="$nameend"/>
        <xsl:with-param name="column-count" select="$column-count"/>
      </xsl:call-template>
      <xsl:text>\relax}</xsl:text>
    </xsl:if>
    <xsl:text>|}{</xsl:text>
    <xsl:if test="$row-parent = 'thead' or $row-parent = 'tfoot' or $is-rowheader = '1'">
      <xsl:text>\textbf{</xsl:text>
    </xsl:if>
    <xsl:copy-of select="$data"/>
    <xsl:if test="$row-parent = 'thead' or $row-parent = 'tfoot' or $is-rowheader = '1'">
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text>}
    </xsl:text>
    <xsl:call-template name="entryend">
      <xsl:with-param name="table-mode" select="$table-mode"/>
      <xsl:with-param name="row-parent" select="$row-parent"/>
      <xsl:with-param name="colidx" select="$colidx + $column-count -1"/>
      <xsl:with-param name="rowspan-info-nodeset" select="$rowspan-info-nodeset"/>
    </xsl:call-template>
    <!-- Add apply-templates for next sibling here -->
    <xsl:apply-templates select="following-sibling::*[1]">
      <xsl:with-param name="normalized-colspecs-nodeset"
                      select="$normalized-colspecs-nodeset"/>
      <xsl:with-param name="rowspan-info-nodeset"
                      select="$rowspan-info-nodeset"/>
      <xsl:with-param name="table-mode" select="$table-mode"/>
      <xsl:with-param name="row-parent" select="$row-parent"/>
      <xsl:with-param name="colidx" select="$colidx+$column-count"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Takes a colspec and an ending column name (@nameend from a spanspec or 
       an entry), and an optional accumulator for the column count; evaluates 
       to the number of columns from the given colspec until (and including) 
       the named end column. -->
  <xsl:template name="count-columns">
    <!-- FIXME: defensive coding needed here against indefinite recursion. -->
    <xsl:param name="colspec"/>
    <xsl:param name="nameend"/>
    <xsl:param name="colcount" select="0"/>
    <xsl:param name="totalcols"/>
    <xsl:choose>
      <xsl:when test="($colspec/@colname = $nameend) or 
                      (not($colspec/following-sibling::cnx:colspec[@colname=$nameend]) and $colcount &gt; $totalcols)">
        <xsl:value-of select="$colcount + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="count-columns">
          <xsl:with-param name="colspec" select="$colspec/following-sibling::cnx:colspec[1]"/>
          <xsl:with-param name="nameend" select="$nameend"/>
          <xsl:with-param name="colcount" select="$colcount + 1"/>
          <xsl:with-param name="totalcols" select="$totalcols"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Takes a colspec, an ending column name (@nameend from a spanspec or an 
       entry), an optional plus sign, and an accumulator for the column width 
       expression; evaluates to a LaTeX expression summing the widths of the 
       columns from the given colspec to the colspec with the ending column 
       name.  -->
  <xsl:template name="spanspec-columnwidths">
    <xsl:param name="colspec"/>
    <xsl:param name="nameend"/>
    <xsl:param name="plussign" select="''"/>
    <xsl:param name="colwidths" select="''"/>
    <xsl:param name="column-count"/>
    <!-- <xsl:message>Woof! <xsl:value-of select="$nameend"/> | <xsl:value-of select="$colspec/@colname"/> | <xsl:value-of select="$colspec/@colwidth"/></xsl:message> -->
    <xsl:variable name="colwidth">
      <xsl:choose>
        <xsl:when test="contains($colspec/@colwidth, '*')">
          <xsl:value-of select="concat(substring-before($colspec/@colwidth, '*'), '\mystarwidth')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$colspec/@colwidth"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$colspec/@colname = $nameend">
        <xsl:value-of select="concat($colwidths, $plussign, $colwidth)"/><xsl:text></xsl:text>
        <xsl:value-of select="concat('+', string((2*number($column-count))-2), '\tabcolsep')"/><xsl:text></xsl:text>
        <xsl:value-of select="concat('+', string(number($column-count)-1), '\arrayrulewidth')"/>
      </xsl:when>
      <xsl:when test="$colspec/following-sibling::cnx:colspec[1]">
        <xsl:call-template name="spanspec-columnwidths">
          <xsl:with-param name="colspec" select="$colspec/following-sibling::cnx:colspec[1]"/>
          <xsl:with-param name="nameend" select="$nameend"/>
          <xsl:with-param name="plussign" select="'+'"/>
          <xsl:with-param name="colwidths" select="concat($colwidths, $plussign, $colwidth)"/>
          <xsl:with-param name="column-count" select="$column-count"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Terminates final and non-final table entries -->
  <xsl:template name="entryend">
    <xsl:param name="table-mode"/>
    <xsl:param name="row-parent"/>
    <xsl:param name="colidx"/>
    <xsl:param name="rowspan-info-nodeset"/>
    <xsl:if test="$colidx &lt; ancestor::cnx:*[@cols][1]/@cols">
      <xsl:text> &amp;
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cnx:row" mode="in-last-cals-row">
    <xsl:choose>
      <xsl:when test="not(following-sibling::cnx:row)">
        <xsl:value-of select="'true'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'false'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make-clines">
    <xsl:param name="rowspan-info-nodeset"/>
    <xsl:param name="colidx" select="1"/>
    <xsl:if test="$rowspan-info-nodeset/cnx:rowspan[$colidx]/@rowcount &lt; 2">
      <xsl:text>\cline{</xsl:text>
      <xsl:value-of select="concat($colidx, '-', $colidx)"/>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:if test="$colidx &lt; count($rowspan-info-nodeset/*)">
      <xsl:call-template name="make-clines">
        <xsl:with-param name="rowspan-info-nodeset" select="$rowspan-info-nodeset"/>
        <xsl:with-param name="colidx" select="$colidx + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="align-from-colspec">
    <xsl:param name="colspec"/>
    <xsl:choose>
      <xsl:when test="string($colspec/@align)">
        <xsl:value-of select="$colspec/@align"/>
      </xsl:when>
      <xsl:when test="string($colspec/@tgroup-align)">
        <xsl:value-of select="$colspec/@tgroup-align"/>
      </xsl:when>
      <xsl:when test="string($colspec/@default-align)">
        <xsl:value-of select="$colspec/@default-align"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Initialize our XML structure for keeping track of when to create blank 
       cells for spanned rows. This RTF should contain one 
       cnx:rowspan[@skipcount=0] for each column in a tgroup.  It will be 
       passed in to the template that processes the first cnx:row; after that 
       row is processed, it will be modified based on any @morerow values in 
       entries in that row, and passed in to the next row.  And so on. -->
  <xsl:template name="make-rowspan-info-rtf">
    <xsl:param name="colcount"/>
    <xsl:param name="colidx" select="1"/>
    <xsl:text>% params for make-rowspan-info-rtf: </xsl:text>
    <xsl:text>colcount: </xsl:text>
    <xsl:value-of select="$colcount"/>
    <xsl:text>colidx: </xsl:text>
    <xsl:value-of select="$colidx"/>
    <xsl:text>
    </xsl:text>
    <xsl:if test="$colcount &gt;= $colidx">
      <!-- Make the rowspan -->
      <cnx:rowspan rowcount="0" start="'false'" spanright="'false'"/>
      <!-- Recur -->
      <xsl:call-template name="make-rowspan-info-rtf">
        <xsl:with-param name="colcount" select="$colcount"/>
        <xsl:with-param name="colidx" select="$colidx+1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="update-rowspan-info-rtf">
    <xsl:param name="prev-rowspan-info-nodeset"/>
    <xsl:param name="normalized-colspecs-nodeset"/>
    <xsl:param name="table-cells-nodeset"/>
    <xsl:param name="rowspan-idx" select="1"/>
    <xsl:param name="entry-idx" select="1"/>
    <xsl:variable name="prev-rowspan" 
                  select="$prev-rowspan-info-nodeset/cnx:rowspan[$rowspan-idx]"/>
    <xsl:if test="$rowspan-idx &lt;= count($prev-rowspan-info-nodeset/*)">
      <xsl:choose>
        <!-- Case 1: The @rowcount in the previous rowspan at this position is 
             1 or 0, so we aren't skipping a cell; we check the current entry 
             for @morerows. -->
        <xsl:when test="$prev-rowspan/@rowcount &lt;= 1">
          <xsl:choose>
            <!-- This entry has @morerows -->
            <xsl:when test="$table-cells-nodeset[$entry-idx]/@morerows &gt; 0">
              <cnx:rowspan rowcount="{$table-cells-nodeset[$entry-idx]/@morerows + 1}" start="true"/>
            </xsl:when>
            <!-- This entry has no @morerows -->
            <xsl:otherwise>
              <cnx:rowspan rowcount="0" start="false"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- recur -->
          <xsl:call-template name="update-rowspan-info-rtf">
            <xsl:with-param name="prev-rowspan-info-nodeset" 
                            select="$prev-rowspan-info-nodeset"/>
            <xsl:with-param name="table-cells-nodeset" 
                            select="*"/>
            <xsl:with-param name="rowspan-idx" select="$rowspan-idx + 1"/>
            <xsl:with-param name="entry-idx" select="$entry-idx + 1"/>
          </xsl:call-template>
        </xsl:when>
        <!-- Case 2: the @rowcount in the previous rowspan at this position is 
             2 or greater, which means we are skipping a cell; just output a 
             rowspan with @rowcount decremented by one. -->
        <xsl:otherwise>
          <cnx:rowspan rowcount="{$prev-rowspan/@rowcount - 1}" start="false"/>
          <!-- recur -->
          <xsl:call-template name="update-rowspan-info-rtf">
            <xsl:with-param name="prev-rowspan-info-nodeset" 
                            select="$prev-rowspan-info-nodeset"/>
            <xsl:with-param name="table-cells-nodeset" 
                            select="*"/>
            <xsl:with-param name="rowspan-idx" select="$rowspan-idx + 1"/>
            <xsl:with-param name="entry-idx" select="$entry-idx"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make-rowspan-placeholders">
    <xsl:param name="normalized-colspecs-nodeset" 
               select="$normalized-colspecs-nodeset"/>
    <xsl:param name="rowspan-info-nodeset" select="$rowspan-info-nodeset"/>
    <xsl:param name="table-mode" select="$table-mode"/>
    <xsl:param name="row-parent" select="$row-parent"/>
    <xsl:param name="colidx" select="$colidx+1"/>
    <xsl:text>% make-rowspan-placeholders
    </xsl:text>
    <xsl:if test="$colidx &lt;= ancestor::*[@cols][1]/@cols">
      <xsl:call-template name="entryend">
        <xsl:with-param name="table-mode" select="$table-mode"/>
        <xsl:with-param name="row-parent" select="$row-parent"/>
        <xsl:with-param name="colidx" select="$colidx"/>
        <xsl:with-param name="rowspan-info-nodeset"
                        select="$rowspan-info-nodeset"/>
      </xsl:call-template>
      <xsl:call-template name="make-rowspan-placeholders">
        <xsl:with-param name="normalized-colspecs-nodeset"
                        select="$normalized-colspecs-nodeset"/>
        <xsl:with-param name="rowspan-info-nodeset"
                        select="$rowspan-info-nodeset"/>
        <xsl:with-param name="table-mode" select="$table-mode"/>
        <xsl:with-param name="row-parent" select="$row-parent"/>
        <xsl:with-param name="colidx" select="$colidx+1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="multirow-handler">
    <xsl:param name="data"/>
    <xsl:param name="rowspan"/>
    <xsl:param name="colwidth-in"/>
    <xsl:variable name="colwidth">
      <xsl:choose>
        <xsl:when test="contains($colwidth-in, '*')">
          <xsl:value-of select="concat(substring-before($colwidth-in, '*'), '\mystarwidth')"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$colwidth-in"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$rowspan/@start='true'">
        <xsl:text>\multirow{</xsl:text>
        <xsl:value-of select="$rowspan/@rowcount"/>
        <xsl:text>}{</xsl:text>
        <xsl:value-of select="$colwidth"/>
        <xsl:text>}{</xsl:text>
        <xsl:value-of select="$data"/>
        <xsl:text>}
        </xsl:text>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$data"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="is-rowheader">
    <xsl:param name="colspec"/>
    <xsl:param name="step" select="'entry'"/>
    <xsl:variable name="provided-class">
      <xsl:choose>
        <xsl:when test="$step='entry'">
          <xsl:value-of select="normalize-space(@class)"/>
        </xsl:when>
        <xsl:when test="$step='colspec'">
          <xsl:value-of select="$colspec/@class"/>
        </xsl:when>
        <xsl:when test="$step='spanspec'">
          <xsl:value-of select="normalize-space(ancestor::*[3]/cnx:spanspec[@spanname=current()/@spanname]/@class)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="is-rowheader">
      <xsl:call-template name="class-test">
        <xsl:with-param name="provided-class" select="$provided-class"/>
        <xsl:with-param name="wanted-class" select="'rowheader'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$is-rowheader='1'">1</xsl:when>
      <xsl:when test="$step='entry'">
        <xsl:call-template name="is-rowheader">
          <xsl:with-param name="colspec" select="$colspec"/>
          <xsl:with-param name="step" select="'colspec'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$step='colspec'">
        <xsl:call-template name="is-rowheader">
          <xsl:with-param name="colspec" select="$colspec"/>
          <xsl:with-param name="step" select="'spanspec'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 'table-footnotes' mode is for making a second pass over table 
       contents to set \footnotetext{} commands corresponding to the 
       \footnotemark commands inside the table.
    -->
  <xsl:template match="*" mode="table-footnotes">
    <xsl:apply-templates mode="table-footnotes"/>
  </xsl:template>

<!-- Suppress text in 'table-footnotes' mode: we don't want a replay 
     of the table contents! -->
  <xsl:template match="text()" mode="table-footnotes">
  </xsl:template>

<!-- Templates in 'table-footnotes' mode for elements that yield 
     footnotes are with the other templates for those elements, 
     probably in cnxml.xsl. -->

  <!-- Test @class for presence of wanted token, borrowed from Max. -->
  <xsl:template name="class-test">
    <xsl:param name="provided-class" />
    <xsl:param name="wanted-class" />
    <xsl:if test="$provided-class = $wanted-class or
            starts-with($provided-class, concat($wanted-class, ' ')) or
            contains($provided-class, concat(' ', $wanted-class, ' ')) or 
            substring($provided-class, string-length($provided-class) - string-length($wanted-class)) = concat(' ', $wanted-class)
            ">1</xsl:if>
  </xsl:template>

  <xsl:template name="make-table-caption">
    <xsl:variable name="cnxml-version" select="ancestor::*[local-name()='document']/@cnxml-version"/>
    <xsl:text>\begin{center}{\small\bfseries </xsl:text>
    <xsl:choose>
      <xsl:when test="$cnxml-version='0.6' and parent::cnx:table/cnx:label">
        <xsl:apply-templates select="parent::cnx:table/cnx:label/node()"/>
      </xsl:when>
      <xsl:when test="not(ancestor::cnx:figure)">
        <xsl:text>Table</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="parent::cnx:table/@number">
      <xsl:text> </xsl:text>
      <xsl:value-of select="parent::cnx:table/@number"/>
    </xsl:if>
    <xsl:text>}</xsl:text>
    <xsl:if test="string-length(normalize-space(parent::cnx:table/cnx:caption))&gt;0">
      <xsl:text>: </xsl:text>
      <xsl:apply-templates select="parent::cnx:table/cnx:caption"/>
    </xsl:if>
    <xsl:text>\end{center}</xsl:text>
  </xsl:template>

</xsl:stylesheet>
