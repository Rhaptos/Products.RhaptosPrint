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

<xsl:import href="modern-textbook.xsl"/>

<!-- ============================================== -->
<!-- Customize docbook params for this style        -->
<!-- ============================================== -->

<xsl:param name="cnx.pagewidth.pixels" select="$cnx.columnwidth.pixels"/>

<xsl:param name="alignment">start</xsl:param>

<xsl:param name="column.count.titlepage" select="1"/>
<xsl:param name="column.count.lot" select="1"/>
<xsl:param name="column.count.front" select="2"/>
<xsl:param name="column.count.body" select="2"/>
<xsl:param name="column.count.back" select="2"/>
<xsl:param name="column.count.index" select="2"/>

<!-- Let @span='all' percolate through -->
<xsl:template match="@class[.='span-all']">
  <xsl:attribute name="span">all</xsl:attribute>
</xsl:template>


<!-- ============================================== -->
<!-- Custom page layouts for modern-textbook        -->
<!-- ============================================== -->

<xsl:param name="body.font.master">9</xsl:param>

<xsl:param name="cnx.color.black">#000000</xsl:param>

<xsl:param name="cnx.section.title.prefix"> | </xsl:param>

<xsl:attribute-set name="section.title.number">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.black"/></xsl:attribute>
	<!-- Overrides the border defined by section.title.level1.properties -->
  <xsl:attribute name="border-bottom-color">transparent</xsl:attribute>
  <xsl:attribute name="border-bottom-width">0px</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.green"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.larger"/></xsl:attribute>
  <xsl:attribute name="border-bottom-color"><xsl:value-of select="$cnx.color.green"/></xsl:attribute>
  <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
  <xsl:attribute name="border-bottom-width">1px</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level2.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level3.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.green"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="xref.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="cnx.note">
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.silver"/></xsl:attribute>
  <xsl:attribute name="padding-top">0.25em</xsl:attribute>
  <xsl:attribute name="padding-bottom">0.25em</xsl:attribute>
  <xsl:attribute name="space-before">1em</xsl:attribute>
  <xsl:attribute name="space-after">1em</xsl:attribute>
</xsl:attribute-set>


<!-- Generate custom page layouts for:
     - Chapter introduction
     - 2-column end-of-chapter problems
-->
<xsl:param name="cnx.pagemaster.intro">cnx-intro</xsl:param>
<xsl:template name="user.pagemasters">
    <fo:simple-page-master master-name="{$cnx.pagemaster.intro}"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$cnx.margin.problems"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$cnx.margin.problems"/>
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

    <!-- title pages -->
    <fo:simple-page-master master-name="{$cnx.pagemaster.problems}"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$cnx.margin.problems"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$cnx.margin.problems"/>
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
        <fo:conditional-page-master-reference 
                master-reference="{$cnx.pagemaster.body}-odd"/>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

    <fo:simple-page-master master-name="{$cnx.pagemaster.body}-odd"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$cnx.margin.problems"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$cnx.margin.problems"/>
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


    <fo:simple-page-master master-name="{$cnx.pagemaster.body}-first"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}">
      <xsl:attribute name="margin-{$direction.align.start}">
        <xsl:value-of select="$page.margin.outer"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.outer"/>
      </xsl:attribute>
      <xsl:if test="$axf.extensions != 0">
        <xsl:call-template name="axf-page-master-properties">
          <xsl:with-param name="page.master">body-odd</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <fo:region-body margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"
                      column-gap="{$column.gap.body}"
                      column-count="1">
      </fo:region-body>
      <fo:region-before region-name="xsl-region-before-odd"
                        extent="{$region.before.extent}"
                        display-align="before"/>
      <fo:region-after region-name="xsl-region-after-odd"
                       extent="{$region.after.extent}"
                       display-align="after"/>
    </fo:simple-page-master>

</xsl:template>

<!-- 1st-level section titles have black numbering and a pipe character before the text is rendered -->

<xsl:template name="section.heading">
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="1"/>
  <xsl:param name="title"/>
  <xsl:param name="marker.title"/>

  <xsl:variable name="cnx.title">
    <fo:inline xsl:use-attribute-sets="section.title.number">
      <xsl:value-of select="substring-before($title, $marker.title)"/>
    </fo:inline>
    <xsl:if test="$level=1">
			<xsl:copy-of select="$cnx.section.title.prefix"/>
		</xsl:if>
    <xsl:copy-of select="$marker.title"/>
  </xsl:variable>

  <fo:block xsl:use-attribute-sets="section.title.properties">
    <xsl:if test="$marker != 0">
      <fo:marker marker-class-name="section.head.marker">
        <xsl:copy-of select="$marker.title"/>
      </fo:marker>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$level=1">
        <fo:block xsl:use-attribute-sets="section.title.level1.properties">
          <xsl:copy-of select="$cnx.title"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=2">
        <fo:block xsl:use-attribute-sets="section.title.level2.properties">
          <xsl:copy-of select="$cnx.title"/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="section.title.level3.properties">
          <xsl:copy-of select="$cnx.title"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>

<!-- Render problem sections at the bottom of a chapter -->
<xsl:template match="db:chapter">
  <xsl:variable name="master-reference">
    <xsl:call-template name="select.pagemaster"/>
  </xsl:variable>

  <!-- The introduction (if it exists) is a single-column page sequence -->
  <xsl:if test="node()[@class='introduction']">
    <xsl:call-template name="page.sequence">
      <xsl:with-param name="master-reference" select="$cnx.pagemaster.intro"/>
      <xsl:with-param name="initial-page-number">auto</xsl:with-param>
      <xsl:with-param name="content">
        <xsl:apply-templates select="node()[@class='introduction']"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>

  <xsl:call-template name="page.sequence">
    <xsl:with-param name="master-reference" select="$master-reference"/>
    <xsl:with-param name="initial-page-number">auto</xsl:with-param>
    <xsl:with-param name="content">
      <!-- Exclude the introduction (it's already been rendered) -->
      <xsl:apply-templates select="node()[not(@class='introduction')]"/>
			<xsl:call-template name="cnx.summarypage"/>
    </xsl:with-param>
  </xsl:call-template>
  
	<xsl:call-template name="cnx.problemspage"/>
</xsl:template>

<xsl:template match="d:section[@class='introduction']">
  <xsl:variable name="context" select="ancestor-or-self::*[self::db:preface | self::db:chapter | self::db:appendix | self::ext:cnx-solutions-placeholder]"/>
  
  <xsl:variable name="title">
    <fo:inline xsl:use-attribute-sets="cnx.header.title">
      <xsl:apply-templates select="$context" mode="title.markup"/>
    </fo:inline>
  </xsl:variable>
  <fo:block text-align="center" xsl:use-attribute-sets="cnx.tilepage.graphic">
    <fo:block xsl:use-attribute-sets="cnx.formal.title.text">
      <xsl:call-template name="cnx.figure">
        <xsl:with-param name="c" select=".//db:figure[@class='splash']"/>
        <xsl:with-param name="renderCaption" select="false()"/>
      </xsl:call-template>
    </fo:block>
  </fo:block>
  <fo:block xsl:use-attribute-sets="cnx.introduction.chapter">
    <fo:inline xsl:use-attribute-sets="cnx.introduction.chapter.number">
      <xsl:apply-templates select="." mode="label.markup"/>
    </fo:inline>
    <fo:inline>&#160;|&#160;</fo:inline><!--PHIL: style this-->
    <fo:inline xsl:use-attribute-sets="cnx.introduction.chapter.title">
      <xsl:copy-of select="$title"/>
    </fo:inline>
  </fo:block>
  <xsl:apply-templates select="node()"/>
</xsl:template>

</xsl:stylesheet>
