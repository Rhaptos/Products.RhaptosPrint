<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<xsl:import href="dbk2fo.xsl"/>

<!-- Ignore Section title pages overridden in dbkplus.xsl -->
<xsl:import href="../docbook-xsl/fo/titlepage.templates.xsl"/>

<xsl:output indent="yes" method="xml"/>

<!-- ============================================== -->
<!-- Customize docbook params for this style        -->
<!-- ============================================== -->
<xsl:param name="cnx.margin.outer">2.5</xsl:param>

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"></xsl:param>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="toc.section.depth">1</xsl:param>

<xsl:param name="body.font.family">sans-serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>

<!-- @class='margin': Custom page layout (for things like marginalia) -->
<xsl:param name="page.margin.outer">
  <xsl:value-of select="$cnx.margin.outer"/>
  <xsl:text>in</xsl:text>
</xsl:param>

<xsl:param name="body.font.master">10</xsl:param>

<xsl:param name="generate.toc">
appendix  toc,title
<!--chapter   toc,title-->
book      toc,title
</xsl:param>

<!-- To get page titles to match left/right alignment, we need to add blank pages between chapters (wi they all start on the same left/right side) -->
<xsl:param name="double.sided" select="1"/>

<xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
</xsl:param>

<!--<xsl:param name="xref.with.number.and.title" select="0"/>-->

<!-- ============================================== -->
<!-- Customize colors and formatting                -->
<!-- ============================================== -->

<xsl:param name="cnx.font.large" select="$body.font.master * 1.2"/>
<xsl:param name="cnx.font.larger" select="$body.font.master * 1.4"/>
<xsl:param name="cnx.font.huge" select="$body.font.master * 6.0"/>
<xsl:param name="cnx.color.orange">#EDA642</xsl:param>
<xsl:param name="cnx.color.blue">#0A4383</xsl:param>
<xsl:param name="cnx.color.red">#BF7822</xsl:param>
<xsl:param name="cnx.color.silver">#FAECD4</xsl:param>
<xsl:param name="cnx.color.green">#79A52B</xsl:param>

<xsl:attribute-set name="cnx.equation">
  <xsl:attribute name="keep-together">10</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.larger"/></xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="space-before.minimum">16</xsl:attribute>
  <xsl:attribute name="space-before.optimum">18</xsl:attribute>
  <xsl:attribute name="space-before.maximum">20</xsl:attribute>
  <xsl:attribute name="padding-before">2px</xsl:attribute>
  <xsl:attribute name="padding-after">2px</xsl:attribute>
  <xsl:attribute name="margin-right">1em</xsl:attribute>
  <xsl:attribute name="border-bottom-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
  <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
  <xsl:attribute name="border-bottom-width">2px</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title.text">
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.green"/></xsl:attribute>
  <xsl:attribute name="padding-before">4px</xsl:attribute>
  <xsl:attribute name="padding-after">4px</xsl:attribute>
  <xsl:attribute name="padding-start">1em</xsl:attribute>
  <xsl:attribute name="padding-end">4px</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title.inner">
  <xsl:attribute name="font-size">12</xsl:attribute>
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="padding-before">5px</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <!-- font size is calculated dynamically by section.heading template -->
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <xsl:attribute name="font-size">12pt</xsl:attribute>
  <xsl:attribute name="padding-before">6pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="example.title.properties" use-attribute-sets="cnx.formal.title.text">
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="figure.title.properties"
                   use-attribute-sets="normal.para.spacing">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.red"/></xsl:attribute>
  <xsl:attribute name="font-size">8</xsl:attribute>

  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="space-after.minimum">8</xsl:attribute>
  <xsl:attribute name="space-after.optimum">6</xsl:attribute>
  <xsl:attribute name="space-after.maximum">10</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.properties">
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.number" use-attribute-sets="section.title.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
</xsl:attribute-set>

<!-- prefixed w/ "cnx." so we don't inherit the background color from formal.object.properties -->
<xsl:attribute-set name="cnx.figure.properties">
  <xsl:attribute name="keep-together">1</xsl:attribute>
  <xsl:attribute name="font-size">8</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.figure.content">
  <xsl:attribute name="text-align">center</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="formal.object.properties">
  <xsl:attribute name="keep-together">1</xsl:attribute>
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.silver"/></xsl:attribute>
  <!--inherited overrides-->
  <xsl:attribute name="space-before">0px</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0px</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0px</xsl:attribute>
  <xsl:attribute name="space-before.optimum">0px</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="xref.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.red"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="admonition.title.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$body.font.master"/></xsl:attribute>
  <xsl:attribute name="border-bottom-width">2px</xsl:attribute>
  <xsl:attribute name="border-bottom-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
  <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note">
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.silver"/></xsl:attribute>
  <xsl:attribute name="padding-bottom">1em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note.margin">
  <xsl:attribute name="padding-before">0.5em</xsl:attribute>
  <xsl:attribute name="border-top-width">2px</xsl:attribute>
  <xsl:attribute name="border-top-style">solid</xsl:attribute>
  <xsl:attribute name="border-top-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
  <xsl:attribute name="border-bottom-width">2px</xsl:attribute>
  <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
  <xsl:attribute name="border-bottom-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note.margin.title">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.chapter">
<!--
  <xsl:attribute name="border-width">2px</xsl:attribute>
  <xsl:attribute name="border-style">solid</xsl:attribute>
  <xsl:attribute name="border-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
-->
  <xsl:attribute name="text-align">left</xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.huge"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <!-- Magic to get the text to show up a little lower and to the left of the image -->
  <xsl:attribute name="padding-top">10px</xsl:attribute>
  <xsl:attribute name="margin-left">-0.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.chapter.number">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.chapter.title">
  <xsl:attribute name="color">white</xsl:attribute>
  <xsl:attribute name="font-style">italic</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.title">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.larger"/></xsl:attribute>
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="border-bottom-width">2px</xsl:attribute>
  <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
  <xsl:attribute name="border-bottom-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.header">
  <xsl:attribute name="text-align">center</xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.larger"/></xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.row">
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.number"
    use-attribute-sets="cnx.introduction.toc.title">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.title">
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="display-align">after</xsl:attribute>
  <xsl:attribute name="padding-before">7pt</xsl:attribute>
  <xsl:attribute name="padding-after">7pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.problems.title">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="padding-before">0.25em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.header.title">
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.header.subtitle">
  <xsl:attribute name="font-style">italic</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.header.separator">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
</xsl:attribute-set>


<!-- ============================================== -->
<!-- Custom page layouts for modern-textbook        -->
<!-- ============================================== -->

<!-- Generate custom page layouts for:
     - Chapter introduction
     - 2-column end-of-chapter problems
     - Custom body with marginalia
-->
<xsl:param name="cnx.pagemaster.body">cnx-body</xsl:param>
<xsl:param name="cnx.pagemaster.introduction">cnx-intro</xsl:param>
<xsl:param name="cnx.pagemaster.problems">cnx-problems-2column</xsl:param>
<xsl:template name="user.pagemasters">
    <!-- title pages -->
    <fo:simple-page-master master-name="{$cnx.pagemaster.introduction}"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$page.margin.inner"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.inner"/>
      </xsl:attribute>
      <fo:region-body margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"
                      column-gap="{$column.gap.titlepage}"
                      column-count="1">
      </fo:region-body>
      <fo:region-before region-name="xsl-region-before-first"
                        extent="{$region.before.extent}"
                        display-align="before"/>
      <fo:region-after region-name="xsl-region-after-first"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>


    <fo:simple-page-master master-name="{$cnx.pagemaster.problems}"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$page.margin.inner"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.inner"/>
      </xsl:attribute>
      <fo:region-body margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"
                      column-gap="{$column.gap.titlepage}"
                      column-count="2">
      </fo:region-body>
      <fo:region-before region-name="xsl-region-before-first"
                        extent="{$region.before.extent}"
                        display-align="before"/>
      <fo:region-after region-name="xsl-region-after-first"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>
    
    <!-- setup for body pages -->
    <fo:page-sequence-master master-name="{$cnx.pagemaster.body}">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference master-reference="blank"
                                              blank-or-not-blank="blank"/>
        <fo:conditional-page-master-reference master-reference="{$cnx.pagemaster.body}-odd"
                                              page-position="first"/>
        <fo:conditional-page-master-reference master-reference="{$cnx.pagemaster.body}-odd"
                                              odd-or-even="odd"/>
        <fo:conditional-page-master-reference 
                                              odd-or-even="even">
          <xsl:attribute name="master-reference">
            <xsl:choose>
              <xsl:when test="$double.sided != 0"><xsl:value-of select="$cnx.pagemaster.body"/>-even</xsl:when>
              <xsl:otherwise><xsl:value-of select="$cnx.pagemaster.body"/>-odd</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>


    <fo:simple-page-master master-name="{$cnx.pagemaster.body}-odd"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$page.margin.outer"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.inner"/>
      </xsl:attribute>
      <xsl:if test="$axf.extensions != 0">
        <xsl:call-template name="axf-page-master-properties">
          <xsl:with-param name="page.master">body-odd</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <fo:region-body margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"
                      column-gap="{$column.gap.body}"
                      column-count="{$column.count.body}">
      </fo:region-body>
      <fo:region-before region-name="xsl-region-before-odd"
                        extent="{$region.before.extent}"
                        display-align="before"/>
      <fo:region-after region-name="xsl-region-after-odd"
                       extent="{$region.after.extent}"
                       display-align="after"/>
    </fo:simple-page-master>

    <fo:simple-page-master master-name="{$cnx.pagemaster.body}-even"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$page.margin.outer"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.inner"/>
      </xsl:attribute>
      <xsl:if test="$axf.extensions != 0">
        <xsl:call-template name="axf-page-master-properties">
          <xsl:with-param name="page.master">body-even</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <fo:region-body margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"
                      column-gap="{$column.gap.body}"
                      column-count="{$column.count.body}">
      </fo:region-body>
      <fo:region-before region-name="xsl-region-before-even"
                        extent="{$region.before.extent}"
                        display-align="before"/>
      <fo:region-after region-name="xsl-region-after-even"
                       extent="{$region.after.extent}"
                       display-align="after"/>
    </fo:simple-page-master>

</xsl:template>

<!-- Override the default body pagemaster so the margin is always on the left -->
<xsl:template name="select.user.pagemaster">
  <xsl:param name="element"/>
  <xsl:param name="pageclass"/>
  <xsl:param name="default-pagemaster"/>
  <xsl:choose>
    <xsl:when test="$default-pagemaster = 'body'">
      <xsl:value-of select="$cnx.pagemaster.body"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$default-pagemaster"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ============================================== -->
<!-- New Feature: @class='end-of-chapter-problems'  -->
<!-- ============================================== -->

<!-- Render problem sections at the bottom of a chapter -->
<xsl:template match="db:chapter">
  <xsl:call-template name="page.sequence">
    <xsl:with-param name="master-reference">
      <xsl:value-of select="$cnx.pagemaster.introduction"/>
    </xsl:with-param>
    <xsl:with-param name="content">
      <!-- Taken from docbook-xsl/fo/component.xsl : match="d:chapter" -->
      <xsl:variable name="id">
        <xsl:call-template name="object.id"/>
      </xsl:variable>
      <fo:block id="{$id}"
                xsl:use-attribute-sets="component.titlepage.properties">
        <xsl:call-template name="chapter.titlepage"/>
      </fo:block>
    </xsl:with-param>
  </xsl:call-template>

    <xsl:variable name="master-reference">
      <xsl:call-template name="select.pagemaster"/>
    </xsl:variable>

  <xsl:call-template name="page.sequence">
    <xsl:with-param name="master-reference" select="$master-reference"/>
    <xsl:with-param name="initial-page-number">auto</xsl:with-param>
    <xsl:with-param name="content">

      <xsl:apply-templates/>

    </xsl:with-param>
  </xsl:call-template>
  
  <!-- Create a 2column page for problems. Insert the section number and title before each problem set -->
  <xsl:if test="count(.//*[@class='end-of-chapter-problems']) &gt; 0">
    <xsl:call-template name="page.sequence">
      <xsl:with-param name="master-reference">
        <xsl:value-of select="$cnx.pagemaster.problems"/>
      </xsl:with-param>
      <xsl:with-param name="initial-page-number">auto</xsl:with-param>
      <xsl:with-param name="content">

        <fo:marker marker-class-name="section.head.marker">
          <xsl:text>Problems</xsl:text>
        </fo:marker>
      
        <fo:block xsl:use-attribute-sets="cnx.formal.title">
          <fo:inline xsl:use-attribute-sets="example.title.properties">
            <xsl:text>Problems</xsl:text>
          </fo:inline>
        </fo:block>
        
        <xsl:for-each select="db:section[.//*[@class='end-of-chapter-problems']]">
          <xsl:variable name="sectionId">
            <xsl:call-template name="object.id"/>
          </xsl:variable>
          <!-- Print the section title and link back to it -->
          <fo:block xsl:use-attribute-sets="cnx.problems.title">
            <fo:basic-link internal-destination="{$sectionId}">
              <xsl:apply-templates select="." mode="object.title.markup">
                <xsl:with-param name="allow-anchors" select="0"/>
              </xsl:apply-templates>
            </fo:basic-link>
          </fo:block>
          <xsl:apply-templates select=".//*[@class='end-of-chapter-problems']">
            <xsl:with-param name="render" select="'true'"/>
          </xsl:apply-templates>
        </xsl:for-each>

      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="ext:exercise[ancestor-or-self::*[@class='end-of-chapter-problems']]">
<xsl:variable name="id">
  <xsl:call-template name="object.id"/>
</xsl:variable>
<fo:block id="{$id}" xsl:use-attribute-sets="informal.object.properties">
  <xsl:apply-templates select="." mode="number"/>
  <xsl:text> </xsl:text>
  <xsl:variable name="first">
    <xsl:apply-templates select="ext:problem/*[position() = 1]/node()"/>
  </xsl:variable>
  <xsl:copy-of select="$first"/>
  <xsl:apply-templates select="ext:problem/*[position() &gt; 1]"/>
</fo:block>
</xsl:template>


<!-- ============================================== -->
<!-- New Feature: @class='introduction'             -->
<!-- ============================================== -->

<xsl:template name="section.heading">
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="1"/>
  <xsl:param name="title"/>
  <xsl:param name="marker.title"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  
  <fo:block id="{$id}" xsl:use-attribute-sets="section.title.properties">
    <xsl:if test="$marker != 0">
      <fo:marker marker-class-name="section.head.marker">
        <xsl:copy-of select="$marker.title"/>
      </fo:marker>
    </xsl:if>

    <fo:inline xsl:use-attribute-sets="section.title.number">
      <xsl:value-of select="substring-before($title, $marker.title)"/>
    </fo:inline>

    <xsl:copy-of select="$marker.title"/>
  </fo:block>

</xsl:template>

<xsl:template name="chapter.titlepage">
  <!--
  <fo:marker marker-class-name="section.head.marker">
    <xsl:apply-templates mode="title.markup" select="."/>
  </fo:marker>
  -->
  <fo:block text-align="center" xsl:use-attribute-sets="cnx.tilepage.graphic">
    <xsl:choose>
      <xsl:when test="d:section[@class='introduction']/db:figure">

        <fo:block-container>
          <!-- Render the image with some text floating on top of it -->
          <!-- Hence the need for all the fo:block-container -->
          <xsl:apply-templates select="d:section[@class='introduction']/db:figure"/>
          <fo:block-container position="absolute">
            <fo:block xsl:use-attribute-sets="cnx.introduction.chapter">
              <fo:inline xsl:use-attribute-sets="cnx.introduction.chapter.number">
                <xsl:apply-templates select="." mode="label.markup"/>
              </fo:inline>
              <fo:inline xsl:use-attribute-sets="cnx.introduction.chapter.title">
                <xsl:apply-templates select="." mode="title.markup"/>
              </fo:inline>
            </fo:block>
          </fo:block-container>
        </fo:block-container>

      </xsl:when>
      <xsl:when test="d:chapterinfo/d:title">
        <xsl:apply-templates
               mode="book.titlepage.recto.auto.mode"
               select="d:chapterinfo/d:title"/>
      </xsl:when>
      <xsl:when test="d:title">
        <xsl:apply-templates 
               mode="book.titlepage.recto.auto.mode" 
               select="d:title"/>
      </xsl:when>
    </xsl:choose>
  </fo:block>
  <fo:block>
    <fo:table inline-progression-dimension="100%" table-layout="fixed">
      <fo:table-column column-width="66%"/>
      <fo:table-column column-width="33%"/>
      <fo:table-body>
        <fo:table-row>
          <fo:table-cell>
            <fo:block xsl:use-attribute-sets="cnx.introduction.title">
              <xsl:choose>
                <xsl:when test="d:section[@class='introduction']/db:title">
                  <xsl:apply-templates select="d:section[@class='introduction']/db:title/node()"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>Introduction</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </fo:block>
            <xsl:apply-templates select="d:section[@class='introduction']/*[not(self::db:figure)]"/>
          </fo:table-cell>
          <fo:table-cell display-align="after" padding-start="10px">
            <fo:block xsl:use-attribute-sets="cnx.introduction.toc" text-align="right">

              <xsl:call-template name="chapter.titlepage.toc"/>

            </fo:block>
          </fo:table-cell> 
        </fo:table-row >  
      </fo:table-body> 
    </fo:table>
  </fo:block>
</xsl:template>

<xsl:template name="chapter.titlepage.toc">
  <fo:table inline-progression-dimension="100%" table-layout="fixed">
    <fo:table-column column-width="25%"/>
    <fo:table-column column-width="75%"/>
    <fo:table-header>
      <fo:table-row>
        <fo:table-cell number-columns-spanned="2" xsl:use-attribute-sets="cnx.introduction.toc.header">
          <fo:block><xsl:text>Key Concepts</xsl:text></fo:block>
        </fo:table-cell>
      </fo:table-row>
    </fo:table-header>
    <fo:table-body>
      <xsl:apply-templates mode="introduction.toc" select="*"/>
    </fo:table-body>
  </fo:table>
  <xsl:call-template name="component.toc.separator"/>

</xsl:template>

<xsl:template mode="introduction.toc" match="db:chapter/db:section[not(@class='introduction')]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <fo:table-row xsl:use-attribute-sets="cnx.introduction.toc.row">
    <fo:table-cell>
      <fo:block xsl:use-attribute-sets="cnx.introduction.toc.number">
        <fo:basic-link internal-destination="{$id}">
          <xsl:apply-templates mode="label.markup" select="."/>
        </fo:basic-link>
      </fo:block>
    </fo:table-cell>
    <fo:table-cell>
      <fo:block xsl:use-attribute-sets="cnx.introduction.toc.title">
        <fo:basic-link internal-destination="{$id}">
          <xsl:apply-templates mode="title.markup" select="."/>
        </fo:basic-link>
      </fo:block>
    </fo:table-cell>
  </fo:table-row>
</xsl:template>

<!-- Since intro sections are rendered specifically only in the title page, ignore them for normal rendering -->
<xsl:template match="d:section[@class='introduction']"/>

<!-- HACK: Fix section numbering. Search for "CNX" below to find the change -->
<!-- From ../docbook-xsl/common/labels.xsl -->
<xsl:template match="d:section" mode="label.markup">
  <!-- if this is a nested section, label the parent -->
  <xsl:if test="local-name(..) = 'section'">
    <xsl:variable name="parent.section.label">
      <xsl:call-template name="label.this.section">
        <xsl:with-param name="section" select=".."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$parent.section.label != '0'">
      <xsl:apply-templates select=".." mode="label.markup"/>
      <xsl:apply-templates select=".." mode="intralabel.punctuation"/>
    </xsl:if>
  </xsl:if>

  <!-- if the parent is a component, maybe label that too -->
  <xsl:variable name="parent.is.component">
    <xsl:call-template name="is.component">
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:variable>

  <!-- does this section get labelled? -->
  <xsl:variable name="label">
    <xsl:call-template name="label.this.section">
      <xsl:with-param name="section" select="."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$section.label.includes.component.label != 0
                and $parent.is.component != 0">
    <xsl:variable name="parent.label">
      <xsl:apply-templates select=".." mode="label.markup"/>
    </xsl:variable>
    <xsl:if test="$parent.label != ''">
      <xsl:apply-templates select=".." mode="label.markup"/>
      <xsl:apply-templates select=".." mode="intralabel.punctuation"/>
    </xsl:if>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$label != 0">
      <xsl:variable name="format">
        <xsl:call-template name="autolabel.format">
          <xsl:with-param name="format" select="$section.autolabel"/>
        </xsl:call-template>
      </xsl:variable>
<!-- CNX: Don't include the introduction Section
      <xsl:number format="{$format}" count="d:section"/>
-->
      <xsl:number format="{$format}" count="d:section[not(@class='introduction')]"/>

    </xsl:when>
  </xsl:choose>
</xsl:template>


<!-- ============================================== -->
<!-- Customize block-text structure
     (notes, examples, exercises, nested elts)
  -->
<!-- ============================================== -->

<!-- Render equations with the number on the RHS -->
<xsl:template match="db:equation">
  <fo:block xsl:use-attribute-set="cnx.equation">
    <xsl:attribute name="id">
      <xsl:call-template name="object.id"/>
    </xsl:attribute>

    <fo:table inline-progression-dimension="100%" table-layout="fixed">
      <fo:table-column column-width="90%"/>
      <fo:table-column column-width="10%"/>
      <fo:table-body>
        <fo:table-row >
          <fo:table-cell>
            <fo:block text-align="center">
              <xsl:apply-templates/>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell>
            <fo:block text-align="end">
              <xsl:text>(</xsl:text>
              <xsl:apply-templates select="." mode="label.markup"/>
              <xsl:text>)</xsl:text>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </fo:block>
</xsl:template>


<!-- Handle figures (in-page and in margins) differently.
Combination of formal.object and formal.object.heading -->
<xsl:template match="d:figure">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="cnx.figure.properties">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>

    <fo:block xsl:use-attribute-sets="cnx.figure.content">
      <xsl:apply-templates select="*[not(self::d:caption)]"/>
    </fo:block>
    <fo:inline xsl:use-attribute-sets="figure.title.properties">
      <xsl:apply-templates select="." mode="object.title.markup">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>
    </fo:inline>
    <xsl:apply-templates select="d:caption"/>
  </fo:block>
</xsl:template>



<!-- A block-level element inside another block-level element should use the inner formatting -->
<xsl:template mode="formal.object.heading" match="db:example//*">
  <xsl:param name="object" select="."/>
  <xsl:param name="placement" select="'before'"/>

  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$placement = 'before'">
        <xsl:attribute
               name="keep-with-next.within-column">always</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute
               name="keep-with-previous.within-column">always</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:variable>

  <fo:block xsl:use-attribute-sets="cnx.formal.title.inner">
    <xsl:copy-of select="$content"/>
  </fo:block>
</xsl:template>

<xsl:template mode="formal.object.heading" match="*" name="formal.object.heading">
  <xsl:param name="object" select="."/>
  <xsl:param name="placement" select="'before'"/>

  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$placement = 'before'">
        <xsl:attribute
               name="keep-with-next.within-column">always</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute
               name="keep-with-previous.within-column">always</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:variable>

  <!-- CNX: added special case for examples and notes -->
  <fo:block xsl:use-attribute-sets="cnx.formal.title">
    <xsl:choose>
      <xsl:when test="self::db:example">
        <fo:inline xsl:use-attribute-sets="example.title.properties">
          <xsl:copy-of select="$content"/>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <fo:inline xsl:use-attribute-sets="cnx.formal.title.text">
          <xsl:copy-of select="$content"/>
        </fo:inline>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>

<xsl:template name="formal.object">
  <xsl:variable name="placement" select="'before'"/><!--hardcoded-->

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:apply-templates mode="formal.object.heading" select=".">
    <xsl:with-param name="placement" select="$placement"/>
  </xsl:apply-templates>

  <xsl:variable name="content">
    <xsl:apply-templates select="*[not(self::d:caption)]"/>
    <xsl:apply-templates select="d:caption"/>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <xsl:choose>
    <!-- tables have their own templates and
         are not handled by formal.object -->
    <xsl:when test="self::d:example">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="example.properties">
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column"><xsl:value-of
                          select="$keep.together"/></xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::d:equation">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="cnx.equation">
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column"><xsl:value-of
                          select="$keep.together"/></xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
    <xsl:when test="self::d:procedure">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="procedure.properties">
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column"><xsl:value-of
                          select="$keep.together"/></xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:when>
    <xsl:otherwise>
      <fo:block id="{$id}"
                xsl:use-attribute-sets="formal.object.properties">
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column"><xsl:value-of
                          select="$keep.together"/></xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </fo:block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:figure/d:caption">
  <fo:inline>
    <xsl:apply-templates/>
  </fo:inline>
</xsl:template>

<xsl:template match="db:note">
  <fo:block xsl:use-attribute-sets="cnx.note">
    <xsl:apply-imports/>
  </fo:block>
</xsl:template>

<!-- Concept Check, or default notes for the margin -->
<xsl:template match="db:note[@class='margin']">
  <fo:block xsl:use-attribute-sets="cnx.note.margin">
    <fo:block xsl:use-attribute-sets="cnx.note.margin.title">
      <xsl:apply-templates select="db:title/node()|db:label/node()"/>
    </fo:block>
    <xsl:apply-templates select="*[not(self::db:title or self::db:label)]"/>
  </fo:block>
</xsl:template>

<!-- ============================================== -->
<!-- Customize page headers                         -->
<!-- ============================================== -->

<!-- Custom page header -->
<xsl:template name="header.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <xsl:variable name="context" select="ancestor-or-self::*[self::db:preface | self::db:chapter | self::db:appendix]"/>

  <xsl:variable name="subtitle">
    <!-- Don't render the section name.
      <xsl:choose>
        <xsl:when test="ancestor::d:book and ($double.sided != 0)">
          <fo:retrieve-marker retrieve-class-name="section.head.marker"
                              retrieve-position="first-including-carryover"
                              retrieve-boundary="page-sequence"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="titleabbrev.markup"/>
        </xsl:otherwise>
      </xsl:choose>
    -->
    <xsl:apply-templates select="$context" mode="title.markup"/>
  </xsl:variable>
  
  <xsl:variable name="title">
    <fo:inline xsl:use-attribute-sets="cnx.header.title">
      <xsl:apply-templates select="$context" mode="object.xref.markup"/>
    </fo:inline>
    
    <xsl:if test="$subtitle != ''">
      <fo:inline xsl:use-attribute-sets="cnx.header.separator">
        <xsl:text>&#160;|&#160;</xsl:text>
      </fo:inline>
      <fo:inline xsl:use-attribute-sets="cnx.header.subtitle">
        <xsl:copy-of select="$subtitle"/>
      </fo:inline>
    </xsl:if>
  </xsl:variable>

  <fo:block>
    <!-- pageclass can be front, body, back -->
    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->
    <xsl:choose>
      <xsl:when test="$pageclass = 'titlepage'">
        <!-- nop; no footer on title pages -->
      </xsl:when>

      <xsl:when test="$double.sided != 0 and $sequence = 'even'
                      and $position='left'">
        <fo:page-number/>
        <xsl:text> &#160; &#160; </xsl:text>
        <xsl:copy-of select="$title"/>
      </xsl:when>

      <xsl:when test="$double.sided != 0 and ($sequence = 'odd' or $sequence = 'first')
                      and $position='right'">
        <xsl:copy-of select="$title"/>
        <xsl:text> &#160; &#160; </xsl:text>
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$double.sided = 0 and $position='center'">
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$sequence='blank'">
        <xsl:choose>
          <xsl:when test="$double.sided != 0 and $position = 'left'">
            <fo:page-number/>
          </xsl:when>
          <xsl:when test="$double.sided = 0 and $position = 'center'">
            <fo:page-number/>
          </xsl:when>
          <xsl:otherwise>
            <!-- nop -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!-- nop -->
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>

<xsl:template name="footer.content"/>

<!-- Give the left and right headers enough room for the text
      (ie make the center cell very small)
-->
<xsl:param name="header.column.widths">100 1 100</xsl:param>

</xsl:stylesheet>
