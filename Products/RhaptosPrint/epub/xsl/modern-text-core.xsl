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

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"></xsl:param>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="toc.section.depth">1</xsl:param>

<xsl:param name="body.font.family">sans-serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>

<xsl:param name="body.font.master">8.5</xsl:param>
<xsl:param name="body.start.indent">0px</xsl:param>

<xsl:param name="header.rule" select="0"/>

<xsl:param name="generate.toc">
appendix  toc,title
<!--chapter   toc,title-->
book      toc,title
</xsl:param>

<!-- To get page titles to match left/right alignment, we need to add blank pages between chapters (wi they all start on the same left/right side) -->
<xsl:param name="double.sided" select="1"/>

<xsl:param name="page.margin.top">0.25in</xsl:param>
<xsl:param name="page.margin.bottom">0.25in</xsl:param>
<xsl:param name="page.margin.inner">1.0in</xsl:param>
<xsl:param name="page.margin.outer">1.0in</xsl:param>
<xsl:param name="cnx.margin.problems">1in</xsl:param>

<xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
</xsl:param>

<!--<xsl:param name="xref.with.number.and.title" select="0"/>-->

<xsl:param name="cnx.pagewidth.pixels" select="396"/>
<xsl:param name="cnx.columnwidth.pixels" select="228"/>

<!-- ============================================== -->
<!-- Customize colors and formatting                -->
<!-- ============================================== -->

<xsl:param name="cnx.font.small" select="concat($body.font.master * 0.8, 'pt')"/>
<xsl:param name="cnx.font.large" select="concat($body.font.master * 1.2, 'pt')"/>
<xsl:param name="cnx.font.larger" select="concat($body.font.master * 1.6, 'pt')"/>
<xsl:param name="cnx.font.huge" select="concat($body.font.master * 4.0, 'pt')"/>
<xsl:param name="cnx.color.orange">#FAA61A</xsl:param>
<xsl:param name="cnx.color.blue">#0061AA</xsl:param>
<xsl:param name="cnx.color.red">#D89016</xsl:param>
<xsl:param name="cnx.color.green">#8FB733</xsl:param>
<xsl:param name="cnx.color.silver">#FBF2E2</xsl:param>
<xsl:param name="cnx.color.aqua">#EFF2F9</xsl:param>
<xsl:param name="cnx.color.light-green">#F1F6E6</xsl:param>

<xsl:attribute-set name="root.properties">
  <xsl:attribute name="font-stretch">semi-condensed</xsl:attribute><!--light-->
</xsl:attribute-set>

<xsl:attribute-set name="list.item.spacing">
  <xsl:attribute name="space-before.optimum">0.2em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.8em</xsl:attribute>
</xsl:attribute-set>

<!-- Don't indent all the time
<xsl:attribute-set name="normal.para.spacing">
  <xsl:attribute name="text-indent">2em</xsl:attribute>
</xsl:attribute-set>
-->

<xsl:attribute-set name="cnx.underscore">
  <xsl:attribute name="border-bottom-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
  <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
  <xsl:attribute name="border-bottom-width">1px</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.75em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">1.0em</xsl:attribute>
</xsl:attribute-set>

<!-- End-of-chapter questions and problem numbers -->
<xsl:attribute-set name="cnx.question"
		use-attribute-sets="informal.object.properties">
	<xsl:attribute name="space-before.minimum">0.25em</xsl:attribute>
	<xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
	<xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="cnx.question.number">
	<xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.equation">
  <xsl:attribute name="keep-together.within-column">2</xsl:attribute>
  <xsl:attribute name="keep-together.within-page">2</xsl:attribute>
  <!-- <xsl:attribute name="keep-together">always</xsl:attribute> -->
</xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title"
    use-attribute-sets="cnx.underscore">
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="space-before.minimum">16</xsl:attribute>
  <xsl:attribute name="space-before.optimum">18</xsl:attribute>
  <xsl:attribute name="space-before.maximum">20</xsl:attribute>
  <xsl:attribute name="padding-before">2px</xsl:attribute>
  <xsl:attribute name="padding-after">2px</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title.text">
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.green"/></xsl:attribute>
  <xsl:attribute name="padding-before">4px</xsl:attribute>
  <xsl:attribute name="padding-after">4px</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title.inner">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.vertical-spacing">
  <xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>

  <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="normal.para.spacing"
    use-attribute-sets="cnx.vertical-spacing">
  <!-- XSL seems to ignore the use-attribute-sets in some cases... -->
  <xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>

  <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="list.block.spacing"
    use-attribute-sets="cnx.vertical-spacing">
  <!-- XSL seems to ignore the use-attribute-sets in some cases... -->
  <xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>

  <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="list.item.spacing"
    use-attribute-sets="cnx.vertical-spacing">
  <!-- XSL seems to ignore the use-attribute-sets in some cases... -->
  <xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>

  <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="list.block.properties"
    use-attribute-sets="cnx.vertical-spacing">
  <!-- XSL seems to ignore the use-attribute-sets in some cases... -->
  <xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>

  <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="example.title.properties" use-attribute-sets="cnx.formal.title.text">
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="figure.title.properties"
                   use-attribute-sets="cnx.vertical-spacing">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.red"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.small"/></xsl:attribute>

  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="hyphenate">false</xsl:attribute>
  <xsl:attribute name="space-after.minimum">8</xsl:attribute>
  <xsl:attribute name="space-after.optimum">6</xsl:attribute>
  <xsl:attribute name="space-after.maximum">10</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties">
  <xsl:attribute name="padding-before">6pt</xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.larger"/></xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level2.properties">
  <xsl:attribute name="padding-before">6pt</xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.number" use-attribute-sets="section.title.level1.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
</xsl:attribute-set>

<!-- prefixed w/ "cnx." so we don't inherit the background color from formal.object.properties -->
<xsl:attribute-set name="cnx.figure.properties">
  <xsl:attribute name="keep-together.within-column">2</xsl:attribute>
  <xsl:attribute name="keep-together.within-page">2</xsl:attribute>
  <!-- <xsl:attribute name="keep-together">always</xsl:attribute> -->
  <xsl:attribute name="font-size">8pt</xsl:attribute>
  <xsl:attribute name="padding-after">0.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.figure.content">
  <xsl:attribute name="text-align">center</xsl:attribute>
</xsl:attribute-set>

<!-- "Check for Understanding" is an exercise whose problem 
    is a list. These should be bold or larger
-->
<xsl:attribute-set name="cnx.exercise.listitem">
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="formal.object.properties" use-attribute-sets="cnx.vertical-spacing">
  <xsl:attribute name="margin-top">0em</xsl:attribute>
  <!-- <xsl:attribute name="keep-together">always</xsl:attribute> -->
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.light-green"/></xsl:attribute>
  <!--inherited overrides-->
</xsl:attribute-set>

<xsl:attribute-set name="informal.object.properties"
    use-attribute-sets="cnx.vertical-spacing">
  <!-- XSL seems to ignore the use-attribute-sets in some cases... -->
  <xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>

  <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>
  <xsl:attribute name="keep-together.within-column">9</xsl:attribute>
  <xsl:attribute name="keep-together.within-page">9</xsl:attribute>
</xsl:attribute-set>

<!-- In Docbook tables inherit formal.object.properties
    This causes the background (including the title) to have a background color.
    See "Customize Table Headings" below for more customizations
 -->
<xsl:attribute-set name="table.properties">
  <xsl:attribute name="background-color">transparent</xsl:attribute>
  <xsl:attribute name="margin-top">0em</xsl:attribute>
</xsl:attribute-set>

<!-- Used to get the indent working properly -->
<xsl:attribute-set name="cnx.formal.object.inner"
  use-attribute-sets="informal.object.properties"/>

<xsl:attribute-set name="informal.object.properties">
  <xsl:attribute name="start-indent">1em</xsl:attribute>
  <xsl:attribute name="end-indent">1em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="xref.properties">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.red"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="admonition.title.properties"
    use-attribute-sets="cnx.underscore">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="font-weight">normal</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="nongraphical.admonition.properties">
  <!-- Override Docbook Defaults -->
  <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">1.0em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">1.0em</xsl:attribute>
  <xsl:attribute name="margin-{$direction.align.start}">1em</xsl:attribute>
  <xsl:attribute name="margin-{$direction.align.end}">1em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note">
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.silver"/></xsl:attribute>
  <xsl:attribute name="padding-top">0.25em</xsl:attribute>
  <xsl:attribute name="padding-bottom">0.25em</xsl:attribute>
  <xsl:attribute name="space-before">1em</xsl:attribute>
  <xsl:attribute name="space-after">1em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note.concept" use-attribute-sets="cnx.note">
  <xsl:attribute name="space-before">1em</xsl:attribute>
  <xsl:attribute name="space-after">1em</xsl:attribute>
  <xsl:attribute name="padding-before">0.5em</xsl:attribute>
  <xsl:attribute name="padding-left">1em</xsl:attribute>
  <xsl:attribute name="border-top-width">1px</xsl:attribute>
  <xsl:attribute name="border-top-style">solid</xsl:attribute>
  <xsl:attribute name="border-top-color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="border-bottom-width">1px</xsl:attribute>
  <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
  <xsl:attribute name="border-bottom-color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="keep-together.within-column">2</xsl:attribute>
  <xsl:attribute name="keep-together.within-page">2</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note.concept.title">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note.tip" use-attribute-sets="cnx.vertical-spacing"/>

<xsl:attribute-set name="cnx.note.tip.body" use-attribute-sets="cnx.note cnx.underscore">
  <xsl:attribute name="border-top-width">1px</xsl:attribute>
  <xsl:attribute name="border-top-style">solid</xsl:attribute>
  <xsl:attribute name="border-top-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.aqua"/></xsl:attribute>
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="text-align">center</xsl:attribute>
  <xsl:attribute name="margin-top">1px<!--To match the orange line--></xsl:attribute>
  <xsl:attribute name="margin-bottom">0em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note.tip.title">
  <xsl:attribute name="text-align">center</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.note.tip.title.inline">
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="color">white</xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="padding-before">0.25em</xsl:attribute>
  <xsl:attribute name="padding-after">0.25em</xsl:attribute>
</xsl:attribute-set>


<xsl:attribute-set name="cnx.introduction.chapter">
<!--
  <xsl:attribute name="border-width">2px</xsl:attribute>
  <xsl:attribute name="border-style">solid</xsl:attribute>
  <xsl:attribute name="border-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
-->
  <xsl:attribute name="padding-left">0.1em</xsl:attribute>
  <xsl:attribute name="padding-before">0.05em</xsl:attribute>
  <xsl:attribute name="padding-after">0em</xsl:attribute>
  <xsl:attribute name="background-color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
  <xsl:attribute name="text-align">left</xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.huge"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.chapter.number">
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.chapter.title">
  <xsl:attribute name="color">white</xsl:attribute>
  <xsl:attribute name="font-variant">small-caps</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.title">
</xsl:attribute-set>
<xsl:attribute-set name="cnx.introduction.title.text"
    use-attribute-sets="cnx.underscore">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.larger"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.table">
  <xsl:attribute name="border-width">1px</xsl:attribute>
  <xsl:attribute name="border-style">solid</xsl:attribute>
  <xsl:attribute name="border-color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
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
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.number.inline"
    use-attribute-sets="cnx.underscore">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.title">
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="display-align">after</xsl:attribute>
  <xsl:attribute name="padding-before">0.25em</xsl:attribute>
  <xsl:attribute name="padding-after">0.25em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.problems.title"
    use-attribute-sets="cnx.problems.subtitle">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.large"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="padding-before">0.25em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.problems.subtitle">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.blue"/></xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="padding-before">0.25em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.header.title">
<!--  <xsl:attribute name="font-weight">bold</xsl:attribute> -->
</xsl:attribute-set>

<xsl:attribute-set name="cnx.header.subtitle">
<!--  <xsl:attribute name="font-style">italic</xsl:attribute> -->
</xsl:attribute-set>

<xsl:attribute-set name="cnx.header.pagenumber">
  <xsl:attribute name="font-size"><xsl:value-of select="$cnx.font.small"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.header.separator">
  <xsl:attribute name="color"><xsl:value-of select="$cnx.color.orange"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.index.title.body"
    use-attribute-sets="cnx.problems.title">
</xsl:attribute-set>

<xsl:attribute-set name="cnx.titlepage.title">
  <xsl:attribute name="space-before">2in</xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <xsl:attribute name="font-size">24pt</xsl:attribute>
  <xsl:attribute name="text-align">center</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.titlepage.authors">
  <xsl:attribute name="space-before.optimum">1in</xsl:attribute>
  <xsl:attribute name="space-before.minimum">12pt</xsl:attribute>
  <xsl:attribute name="space-before.maximum">2in</xsl:attribute>
  <xsl:attribute name="font-size">12pt</xsl:attribute>
  <xsl:attribute name="text-align">center</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="cnx.titlepage.strong">
  <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>


<!-- Page Headers should be marked as all-uppercase.
     Since XSLT1.0 doesn't have fn:uppercase, we'll translate()
-->
<xsl:variable name="cnx.smallcase" select="'abcdefghijklmnopqrstuvwxyz&#228;&#235;&#239;&#246;&#252;&#225;&#233;&#237;&#243;&#250;&#224;&#232;&#236;&#242;&#249;&#226;&#234;&#238;&#244;&#251;&#229;&#248;&#227;&#245;&#230;&#339;&#231;&#322;&#241;'"/>
<xsl:variable name="cnx.uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ&#196;&#203;&#207;&#214;&#220;&#193;&#201;&#205;&#211;&#218;&#192;&#200;&#204;&#210;&#217;&#194;&#202;&#206;&#212;&#219;&#197;&#216;&#195;&#213;&#198;&#338;&#199;&#321;&#209;'"/>

<!-- ============================================== -->
<!-- Custom page layouts for modern-textbook        -->
<!-- ============================================== -->

<!-- Generate custom page layouts for:
     - Chapter introduction
     - 2-column end-of-chapter problems
-->
<xsl:param name="cnx.pagemaster.body">cnx-body</xsl:param>
<xsl:param name="cnx.pagemaster.problems">cnx-problems-2column</xsl:param>
<xsl:template name="user.pagemasters">
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
        <xsl:value-of select="$page.margin.inner"/>
      </xsl:attribute>
      <xsl:attribute name="margin-{$direction.align.end}">
        <xsl:value-of select="$page.margin.outer"/>
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

<!-- Override the default body pagemaster so we use a custom body -->
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
<!-- New Feature: @class='problems-exercises'  -->
<!-- ============================================== -->

<!-- Render problem sections at the bottom of a chapter -->
<xsl:template match="db:chapter">
  <xsl:variable name="master-reference">
    <xsl:call-template name="select.pagemaster"/>
  </xsl:variable>

  <xsl:call-template name="page.sequence">
    <xsl:with-param name="master-reference" select="$master-reference"/>
    <xsl:with-param name="initial-page-number">auto</xsl:with-param>
    <xsl:with-param name="content">
			<xsl:call-template name="chapter.titlepage"/>
      <xsl:apply-templates select="node()[not(@class='introduction')]"/>
			<xsl:call-template name="cnx.summarypage"/>
    </xsl:with-param>
  </xsl:call-template>
  
	<xsl:call-template name="cnx.problemspage"/>
</xsl:template>

<xsl:template name="cnx.summarypage">
	<!-- TODO: Create a 1-column Chapter Summary -->
	<xsl:if test="count(db:section/db:sectioninfo/db:abstract) &gt; 0">
		<fo:block space-before="2em" space-after="2em">
			<fo:table table-layout="fixed" width="100%" xsl:use-attribute-sets="cnx.introduction.toc.table">
				<fo:table-column column-width="0.5in"/>
				<fo:table-column column-width="5in"/>
				<fo:table-header>
					<fo:table-row>
						<fo:table-cell number-columns-spanned="2" xsl:use-attribute-sets="cnx.introduction.toc.header">
							<fo:block><xsl:text>Chapter Summary</xsl:text></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-header>
				<fo:table-body>
					<xsl:apply-templates mode="cnx.chapter.summary" select="db:section"/>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:if>

	<!-- Create a Review/Summary Section -->
	<xsl:if test=".//*[@class='review']">
		<xsl:call-template name="cnx.end-of-chapter-problems">
			<xsl:with-param name="title">
				<xsl:text>Chapter Review</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="attribute" select="'review'"/>
		</xsl:call-template>
	</xsl:if>
	
	<!-- Create a 1-column Listing of Conceptual Questions -->
	<xsl:call-template name="cnx.end-of-chapter-problems">
		<xsl:with-param name="title">
			<xsl:text>Conceptual Questions</xsl:text>
		</xsl:with-param>
		<xsl:with-param name="attribute" select="'conceptual-questions'"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="cnx.problemspage">
  <!-- Create a 2column page for problems. Insert the section number and title before each problem set -->
  <xsl:if test="count(.//*[@class='problems-exercises']) &gt; 0">
    <xsl:call-template name="page.sequence">
      <xsl:with-param name="master-reference">
        <xsl:value-of select="$cnx.pagemaster.problems"/>
      </xsl:with-param>
      <xsl:with-param name="initial-page-number">auto</xsl:with-param>
      <xsl:with-param name="content">

				<fo:marker marker-class-name="section.head.marker">
					<xsl:text>Problems</xsl:text>
				</fo:marker>

				<xsl:call-template name="cnx.end-of-chapter-problems">
					<xsl:with-param name="title">
						<xsl:text>Problems</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="attribute" select="'problems-exercises'"/>
				</xsl:call-template>

      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="cnx.end-of-chapter-problems">
	<xsl:param name="title"/>
	<xsl:param name="attribute"/>

	<!-- Create a 1-column Listing of "Conceptual Questions" or "end-of-chapter Problems" -->
	<xsl:if test="count(.//*[@class=$attribute]) &gt; 0">
		<xsl:comment>CNX: Start Area: "<xsl:value-of select="$title"/>"</xsl:comment>
		
		<fo:block xsl:use-attribute-sets="cnx.formal.title">
			<fo:inline xsl:use-attribute-sets="example.title.properties">
				<xsl:text>&#160; &#160; </xsl:text>
				<xsl:copy-of select="$title"/>
				<xsl:text> &#160; &#160;</xsl:text>
			</fo:inline>
		</fo:block>
		
		<!-- This for-each is the main section (1.4 Newton) to print section title -->
		<xsl:for-each select="db:section[descendant::*[@class=$attribute]]">
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
			<!-- This for-each renders all the sections and exercises and numbers them -->
			<xsl:apply-templates select="descendant::*[@class=$attribute]/node()">
				<xsl:with-param name="render" select="true()"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:if>

</xsl:template>

<xsl:template mode="cnx.chapter.summary" match="db:section[not(@class='introduction') and db:sectioninfo/db:abstract]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <fo:table-row xsl:use-attribute-sets="cnx.introduction.toc.row">
    <fo:table-cell padding-left="1em">
      <fo:block xsl:use-attribute-sets="cnx.introduction.toc.number">
        <fo:basic-link internal-destination="{$id}" xsl:use-attribute-sets="cnx.introduction.toc.number.inline">
          <xsl:apply-templates mode="label.markup" select="."/>
        </fo:basic-link>
      </fo:block>
    </fo:table-cell>
    <fo:table-cell>
      <fo:block xsl:use-attribute-sets="cnx.introduction.toc.title">
        <xsl:apply-templates select="db:sectioninfo/db:abstract">
          <xsl:with-param name="render" select="true()"/>
        </xsl:apply-templates>
      </fo:block>
    </fo:table-cell>
  </fo:table-row>
</xsl:template>

<!-- Renders an abstract onnly when "render" is set to true().
-->
<xsl:template match="d:abstract" mode="titlepage.mode">
  <xsl:param name="render" select="false()"/>
  <xsl:if test="$render">
    <xsl:apply-imports/>
  </xsl:if>
</xsl:template>

<!-- Renders an exercise only when "render" is set to true().
     This allows us to move certain problem-sets to the end of a chapter.
     Also, wither it renders the problem or the solution.
     This way we can render the solutions at the end of a book
-->
<xsl:template match="ext:exercise[ancestor-or-self::*[@class='problems-exercises' or @class='conceptual-questions']]">
<xsl:param name="render" select="false()"/>
<xsl:param name="renderSolution" select="false()"/>
<xsl:if test="$render">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:if test="not(not($renderSolution) or ext:solution)">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">Found a c:problem without a solution. skipping...</xsl:with-param></xsl:call-template>
  </xsl:if>
  <xsl:if test="not($renderSolution) or ext:solution">
    <fo:block id="{$id}" xsl:use-attribute-sets="cnx.question">
      <fo:inline xsl:use-attribute-sets="cnx.question.number">
	      <xsl:apply-templates select="." mode="number"/>
	    </fo:inline>
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="$renderSolution">
          <xsl:variable name="first">
            <xsl:apply-templates select="ext:solution/*[position() = 1]/node()"/>
          </xsl:variable>
          <xsl:copy-of select="$first"/>
          <xsl:apply-templates select="ext:solution/*[position() &gt; 1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="first">
            <xsl:apply-templates select="ext:problem/*[position() = 1]/node()"/>
          </xsl:variable>
          <xsl:copy-of select="$first"/>
          <xsl:apply-templates select="ext:problem/*[position() &gt; 1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
  </xsl:if>
</xsl:if>
</xsl:template>

<xsl:template match="ext:exercise[not(ancestor::db:example)]" mode="number">
  <xsl:param name="type" select="@type"/>
  <xsl:choose>
    <xsl:when test="$type and $type != ''">
      <xsl:number format="1." level="any" from="db:chapter" count="ext:exercise[not(ancestor::db:example) and @type=$type]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:number format="1." level="any" from="db:chapter" count="ext:exercise[not(ancestor::db:example)]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================== -->
<!-- New Feature: Solutions at end of book          -->
<!-- ============================================== -->

<!-- when the placeholder element is encountered (since I didn't want to
      rewrite the match="d:book" template) run a nested for-loop on all
      chapters (and then sections) that contain a solution to be printed ( *[@class='problems-exercises' and .//ext:solution] ).
      Print the "exercise" solution with numbering.
-->
<xsl:template match="ext:cnx-solutions-placeholder[..//*[@class='problems-exercises' and .//ext:solution]]">
  <xsl:call-template name="cnx.log"><xsl:with-param name="msg">Injecting custom solution appendix</xsl:with-param></xsl:call-template>

  <xsl:call-template name="page.sequence">
    <xsl:with-param name="master-reference">
      <xsl:value-of select="$cnx.pagemaster.problems"/>
    </xsl:with-param>
    <xsl:with-param name="initial-page-number">auto</xsl:with-param>
    <xsl:with-param name="content">
  
      <fo:marker marker-class-name="section.head.marker">
        <xsl:text>Answers</xsl:text>
      </fo:marker>
    
      <fo:block xsl:use-attribute-sets="cnx.formal.title">
        <fo:inline xsl:use-attribute-sets="example.title.properties">
          <xsl:text>&#160; &#160; Answers &#160; &#160;</xsl:text>
        </fo:inline>
      </fo:block>
      
      <xsl:for-each select="../*[self::db:preface | self::db:chapter | self::db:appendix][.//*[@class='problems-exercises' and .//ext:solution]]">
  
        <xsl:variable name="chapterId">
          <xsl:call-template name="object.id"/>
        </xsl:variable>
        <!-- Print the chapter number (not title) and link back to it -->
        <fo:block xsl:use-attribute-sets="cnx.problems.title">
          <fo:basic-link internal-destination="{$chapterId}">
            <xsl:apply-templates select="." mode="object.xref.markup"/>
          </fo:basic-link>
        </fo:block>

        <xsl:for-each select="db:section[.//*[@class='problems-exercises']]">
          <xsl:variable name="sectionId">
            <xsl:call-template name="object.id"/>
          </xsl:variable>
          <!-- Print the section title and link back to it -->
          <fo:block xsl:use-attribute-sets="cnx.problems.subtitle">
            <fo:basic-link internal-destination="{$sectionId}">
              <xsl:apply-templates select="." mode="object.title.markup">
                <xsl:with-param name="allow-anchors" select="0"/>
              </xsl:apply-templates>
            </fo:basic-link>
          </fo:block>
          <xsl:apply-templates select=".//*[@class='problems-exercises']">
            <xsl:with-param name="render" select="true()"/>
            <xsl:with-param name="renderSolution" select="true()"/>
          </xsl:apply-templates>
        </xsl:for-each>

      </xsl:for-each>
  
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- ============================================== -->
<!-- New Feature: @class='introduction'             -->
<!-- ============================================== -->

<xsl:template name="section.heading">
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="1"/>
  <xsl:param name="title"/>
  <xsl:param name="marker.title"/>

  <xsl:variable name="cnx.title">
    <fo:inline xsl:use-attribute-sets="section.title.number">
      <xsl:value-of select="substring-before($title, $marker.title)"/>
    </fo:inline>
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
      <xsl:when test="$level=3">
        <fo:block xsl:use-attribute-sets="section.title.level3.properties">
          <xsl:copy-of select="$cnx.title"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=4">
        <fo:block xsl:use-attribute-sets="section.title.level4.properties">
          <xsl:copy-of select="$cnx.title"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=5">
        <fo:block xsl:use-attribute-sets="section.title.level5.properties">
          <xsl:copy-of select="$cnx.title"/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="section.title.level6.properties">
          <xsl:copy-of select="$cnx.title"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>


<xsl:template name="chapter.titlepage">
  <!--
  <fo:marker marker-class-name="section.head.marker">
    <xsl:apply-templates mode="title.markup" select="."/>
  </fo:marker>
  -->
	<!-- Taken from docbook-xsl/fo/component.xsl : match="d:chapter" -->
	<xsl:variable name="id">
		<xsl:call-template name="object.id"/>
	</xsl:variable>
	<fo:block id="{$id}"
						xsl:use-attribute-sets="component.titlepage.properties">
    <xsl:apply-templates select="db:section[@class='introduction']"/>
	</fo:block>
</xsl:template>

<!-- Since intro sections are rendered specifically only in the title page, ignore them for normal rendering -->
<xsl:template match="d:section[@class='introduction']">
  <xsl:variable name="title">
    <xsl:apply-templates select=".." mode="title.markup"/>
  </xsl:variable>
  <fo:block text-align="center" xsl:use-attribute-sets="cnx.tilepage.graphic">
    <fo:block xsl:use-attribute-sets="cnx.introduction.chapter">
      <fo:inline xsl:use-attribute-sets="cnx.introduction.chapter.number">
        <xsl:apply-templates select=".." mode="label.markup"/>
      </fo:inline>
      <fo:inline xsl:use-attribute-sets="cnx.introduction.chapter.title">
        <xsl:copy-of select="translate($title, $cnx.smallcase, $cnx.uppercase)"/>
      </fo:inline>
    </fo:block>
  </fo:block>
  <xsl:if test=".//db:figure[@class='splash']">
    <xsl:apply-templates mode="cnx.splash" select=".//db:figure[@class='splash']"/>
  </xsl:if>
  <xsl:call-template name="chapter.titlepage.toc"/>
  <fo:block xsl:use-attribute-sets="cnx.introduction.title">
    <fo:inline xsl:use-attribute-sets="cnx.introduction.title.text">
      <xsl:choose>
        <xsl:when test="db:title">
          <xsl:apply-templates select="db:title/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Introduction</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#160; &#160; &#160;</xsl:text>
    </fo:inline>
  </fo:block>
  <xsl:apply-templates select="node()"/>
</xsl:template>



<xsl:template name="chapter.titlepage.toc">
<fo:block space-before="2em" space-after="2em">
  <!-- Tables in FOP can't be centered, so we nest them -->
  <xsl:call-template name="table.layout.center">
    <xsl:with-param name="content">
      <fo:table table-layout="fixed" width="100%" xsl:use-attribute-sets="cnx.introduction.toc.table">
        <fo:table-column column-width="0.5in"/>
        <fo:table-column column-width="3in"/>
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
    </xsl:with-param>
  </xsl:call-template>
</fo:block>
</xsl:template>

<!-- Tables in FOP can't be centered, so we nest them -->
<xsl:template name="table.layout.center">
  <xsl:param name="content"/>

  <fo:table width="100%" table-layout="fixed">
    <fo:table-column column-width="1in"/>
    <fo:table-column/>
    <fo:table-column column-width="1in"/>
    <fo:table-body start-indent="0pt">
      <fo:table-row>
        <fo:table-cell/>
        <fo:table-cell>

          <fo:table>
            <fo:table-body start-indent="0pt">
              <fo:table-row><fo:table-cell><fo:block>
                <xsl:copy-of select="$content"/>
               </fo:block></fo:table-cell></fo:table-row>
            </fo:table-body>
          </fo:table>

        </fo:table-cell>
        <fo:table-cell/>
      </fo:table-row>
    </fo:table-body>
  </fo:table>
</xsl:template>

<xsl:template mode="introduction.toc" match="db:chapter/db:section[not(@class='introduction')]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <fo:table-row xsl:use-attribute-sets="cnx.introduction.toc.row">
    <fo:table-cell padding-left="1em">
      <fo:block xsl:use-attribute-sets="cnx.introduction.toc.number">
        <fo:basic-link internal-destination="{$id}" xsl:use-attribute-sets="cnx.introduction.toc.number.inline">
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
<!-- New Feature: Custom splash image
  -->
<!-- ============================================== -->

<!-- Splash figures are moved up so they need to be rendered in a separate mode -->
<xsl:template match="d:figure[@class='splash']"/>
<xsl:template mode="cnx.splash" match="d:figure[@class='splash']">
  <xsl:call-template name="cnx.figure"/>
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


<xsl:template name="pi.dbfo_keep-together">
  <xsl:text>always</xsl:text>
</xsl:template>

<xsl:template match="@class"/>

<!-- Handle figures differently.
Combination of formal.object and formal.object.heading -->
<xsl:template match="d:figure" name="cnx.figure">
	<xsl:param name="c" select="."/>
	<xsl:param name="renderCaption" select="true()"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
    	<xsl:with-param name="object" select="$c"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="cnx.figure.properties">
    <xsl:apply-templates select="$c/@class"/>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
      <xsl:attribute name="keep-together.within-page"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
<!--
      <xsl:attribute name="keep-together"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
-->
    </xsl:if>

    <fo:block xsl:use-attribute-sets="cnx.figure.content">
      <xsl:apply-templates select="$c/*[not(self::d:caption)]"/>
    </fo:block>
		<xsl:if test="$renderCaption">
			<fo:inline xsl:use-attribute-sets="figure.title.properties">
				<xsl:apply-templates select="$c" mode="object.title.markup">
					<xsl:with-param name="allow-anchors" select="1"/>
				</xsl:apply-templates>
			</fo:inline>
			<xsl:apply-templates select="$c/d:caption"/>
		</xsl:if>
  </fo:block>
</xsl:template>

<!-- "Customize Table Headings"
    Taken from docbook-xsl/fo/tables.xsl with modifications marked with "CNX"
 -->
<xsl:template name="table.block">
  <xsl:param name="table.layout" select="NOTANODE"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="param.placement"
                select="substring-after(normalize-space(
                   $formal.title.placement), concat(local-name(.), ' '))"/>

  <xsl:variable name="placement">
    <xsl:choose>
      <xsl:when test="contains($param.placement, ' ')">
        <xsl:value-of select="substring-before($param.placement, ' ')"/>
      </xsl:when>
      <xsl:when test="$param.placement = ''">before</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$param.placement"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="self::d:table">
      <fo:block id="{$id}"
                xsl:use-attribute-sets="table.properties">
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column">
            <xsl:value-of select="$keep.together"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="$placement = 'before'">
          <xsl:call-template name="formal.object.heading">
            <xsl:with-param name="placement" select="$placement"/>
          </xsl:call-template>
        </xsl:if>
<!-- CNX Hack -->
<fo:block xsl:use-attribute-sets="formal.object.properties">
        <xsl:copy-of select="$table.layout"/>
        <xsl:call-template name="table.footnote.block"/>
</fo:block>
        <xsl:if test="$placement != 'before'">
          <xsl:call-template name="formal.object.heading">
            <xsl:with-param name="placement" select="$placement"/>
          </xsl:call-template>
        </xsl:if>
      </fo:block>
    </xsl:when>
    <xsl:otherwise>
      <fo:block id="{$id}"
                xsl:use-attribute-sets="informaltable.properties">
        <xsl:copy-of select="$table.layout"/>
        <xsl:call-template name="table.footnote.block"/>
      </fo:block>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<!-- A block-level element inside another block-level element should use the inner formatting -->
<xsl:template mode="formal.object.heading" match="*[
        ancestor::ext:exercise or 
        ancestor::db:example or 
        ancestor::ext:rule or
        ancestor::db:glosslist or
        ancestor-or-self::db:list]">
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
    <!-- FOP doesn't support @padding-end for fo:inline elements -->
    <xsl:text>&#160; &#160; &#160;</xsl:text>
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
    <!-- FOP doesn't support @padding-end for fo:inline elements -->
    <xsl:text>&#160; &#160; &#160;</xsl:text>
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

  <xsl:variable name="keep.together">
    <xsl:choose>
      <xsl:when test="self::ext:exercise">
        <xsl:text>3</xsl:text>
      </xsl:when>
      <xsl:when test="self::ext:problem | self::ext:solution">
        <xsl:text>4</xsl:text>
      </xsl:when>
      <xsl:when test="self::ext:*">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:wrapper>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
      <xsl:attribute name="keep-together.within-page"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
<!--
      <xsl:attribute name="keep-together"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
-->
    </xsl:if>

    <xsl:apply-templates mode="formal.object.heading" select=".">
      <xsl:with-param name="placement" select="$placement"/>
    </xsl:apply-templates>
  
    <xsl:variable name="content">
      <fo:block xsl:use-attribute-sets="cnx.formal.object.inner">
        <xsl:apply-templates select="*[not(self::d:caption)]"/>
        <xsl:apply-templates select="d:caption"/>
      </fo:block>
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
            <xsl:attribute name="keep-together.within-page"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
<!--
            <xsl:attribute name="keep-together"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
-->
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
            <xsl:attribute name="keep-together.within-page"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
<!--
            <xsl:attribute name="keep-together"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
-->
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
            <xsl:attribute name="keep-together.within-page"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
<!--
            <xsl:attribute name="keep-together"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
-->
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
            <xsl:attribute name="keep-together.within-page"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
<!--
            <xsl:attribute name="keep-together"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
-->
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </fo:wrapper>

</xsl:template>

<xsl:template match="d:figure/d:caption">
  <fo:block xsl:use-attribute-sets="cnx.figure.caption">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template match="db:note">
  <fo:block xsl:use-attribute-sets="cnx.note">
    <xsl:apply-templates select="@class"/>
    <xsl:apply-imports/>
  </fo:block>
</xsl:template>

<xsl:template match="db:note[@type='tip']">
  <fo:block xsl:use-attribute-sets="cnx.note.tip">
    <xsl:apply-templates select="@class"/>
    <fo:block xsl:use-attribute-sets="cnx.note.tip.title">
      <fo:inline xsl:use-attribute-sets="cnx.note.tip.title.inline">
        <!-- FOP doesn't support @padding-end for fo:inline elements -->
        <xsl:text>&#160;</xsl:text>
        <xsl:apply-templates select="db:title/node()|db:label/node()"/>
        <!-- FOP doesn't support @padding-end for fo:inline elements -->
        <xsl:text>&#160;</xsl:text>
      </fo:inline>
    </fo:block>
    <fo:block xsl:use-attribute-sets="cnx.note.tip.body">
      <xsl:apply-templates select="*[not(self::db:title or self::db:label)]"/>
    </fo:block>
  </fo:block>
</xsl:template>

<!-- Lists inside an exercise (that isn't at the bottom of the chapter)
     (ie "Check for Understanding")
     have a larger number. overriding docbook-xsl/fo/lists.xsl
     see <xsl:template match="d:orderedlist/d:listitem">
 -->
<xsl:template match="ext:exercise[not(ancestor-or-self::*[@class='problems-exercises'])]/ext:problem/d:orderedlist/d:listitem" mode="item-number">
  <fo:wrapper xsl:use-attribute-sets="cnx.exercise.listitem">
    <xsl:apply-imports/>
  </fo:wrapper>
</xsl:template>

<!-- ============================================== -->
<!-- Customize index page for modern-textbook       -->
<!-- ============================================== -->

<xsl:template name="index.titlepage">
  <fo:block xsl:use-attribute-sets="cnx.formal.title">
        <fo:inline xsl:use-attribute-sets="example.title.properties">
          <xsl:text>&#160; &#160; </xsl:text>
          <xsl:apply-templates select="." mode="title.markup"/>
          <xsl:text> &#160; &#160;</xsl:text>
        </fo:inline>
  </fo:block>
</xsl:template>

<!-- ============================================== -->
<!-- Customize Table of Contents                    -->
<!-- ============================================== -->

<xsl:attribute-set name="toc.line.properties">
  <xsl:attribute name="font-size">
    <xsl:choose>
      <xsl:when test="self::d:chapter or self::d:appendix"><xsl:value-of select="$cnx.font.larger"/></xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$body.font.master"/>
        <xsl:text>pt</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>

  <xsl:attribute name="color">
    <xsl:choose>
      <xsl:when test="self::d:chapter"><xsl:value-of select="$cnx.color.blue"/></xsl:when>
      <xsl:otherwise>black</xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.of.contents.titlepage.recto.style"
    use-attribute-sets="cnx.underscore">
</xsl:attribute-set>

<!-- Don't include the introduction section in the TOC -->
<xsl:template match="db:section[@class='introduction']" mode="toc"/>

<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="NOTANODE"/>  
  <xsl:variable name="id">  
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">  
    <xsl:apply-templates select="." mode="label.markup"/>  
  </xsl:variable>

  <fo:block xsl:use-attribute-sets="toc.line.properties">  
    <fo:inline keep-with-next.within-line="always">
      
      <fo:basic-link internal-destination="{$id}">  

<!-- CNX: Add the word "Chapter" or Appendix in front of the number -->
        <xsl:if test="self::db:appendix or self::db:chapter">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="local-name()"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
        </xsl:if>

        <xsl:if test="$label != ''">
          <xsl:copy-of select="$label"/>
          <xsl:value-of select="$autotoc.label.separator"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="title.markup"/>  
      </fo:basic-link>
    </fo:inline>
    <fo:inline keep-together.within-line="always"> 
      <xsl:text> </xsl:text>
      <fo:leader leader-pattern="dots"
                 leader-pattern-width="3pt"
                 leader-alignment="reference-area"
                 keep-with-next.within-line="always"/>
      <xsl:text> </xsl:text>
      <fo:basic-link internal-destination="{$id}">
        <fo:page-number-citation ref-id="{$id}"/>
      </fo:basic-link>
    </fo:inline>
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

  <xsl:variable name="context" select="ancestor-or-self::*[self::db:preface | self::db:chapter | self::db:appendix | self::ext:cnx-solutions-placeholder]"/>

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
    <!-- Convert titles to uppercase -->
    <xsl:variable name="title">
      <xsl:apply-templates select="$context" mode="object.xref.markup"/>
    </xsl:variable>
    <fo:inline xsl:use-attribute-sets="cnx.header.title">
      <xsl:value-of select="translate($title, $cnx.smallcase, $cnx.uppercase)"/>
    </fo:inline>
    
    <!-- Add a separator and convert subtitle to uppercase -->
    <xsl:if test="$subtitle != '' and $subtitle != $title">
      <fo:inline xsl:use-attribute-sets="cnx.header.separator">
        <xsl:text>&#160;|&#160;</xsl:text>
      </fo:inline>
      <fo:inline xsl:use-attribute-sets="cnx.header.subtitle">
        <xsl:value-of select="translate($subtitle, $cnx.smallcase, $cnx.uppercase)"/>
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
        <fo:inline xsl:use-attribute-sets="cnx.header.pagenumber">
          <fo:page-number/>
        </fo:inline>
        <xsl:text> &#160; &#160; </xsl:text>
        <xsl:copy-of select="$title"/>
      </xsl:when>

      <xsl:when test="$double.sided != 0 and ($sequence = 'odd' or $sequence = 'first')
                      and $position='right'">
        <xsl:copy-of select="$title"/>
        <xsl:text> &#160; &#160; </xsl:text>
        <fo:inline xsl:use-attribute-sets="cnx.header.pagenumber">
          <fo:page-number/>
        </fo:inline>
      </xsl:when>

      <xsl:when test="$double.sided = 0 and $position='center'">
        <fo:page-number/>
      </xsl:when>

      <xsl:when test="$sequence='blank'">
        <xsl:choose>
          <xsl:when test="$double.sided != 0 and $position = 'left'">
            <fo:inline xsl:use-attribute-sets="cnx.header.pagenumber">
              <fo:page-number/>
            </fo:inline>
          </xsl:when>
          <xsl:when test="$double.sided = 0 and $position = 'center'">
            <fo:inline xsl:use-attribute-sets="cnx.header.pagenumber">
              <fo:page-number/>
            </fo:inline>
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



<xsl:template name="process.image">
  <!-- When this template is called, the current node should be  -->
  <!-- a graphic, inlinegraphic, imagedata, or videodata. All    -->
  <!-- those elements have the same set of attributes, so we can -->
  <!-- handle them all in one place.                             -->

  <xsl:variable name="scalefit">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0">0</xsl:when>
      <xsl:when test="@contentwidth">0</xsl:when>
      <xsl:when test="@contentdepth and 
                      @contentdepth != '100%'">0</xsl:when>
      <xsl:when test="@scale">0</xsl:when>
      <xsl:when test="@scalefit"><xsl:value-of select="@scalefit"/></xsl:when>
      <xsl:when test="@width or @depth">1</xsl:when>
      <xsl:when test="$default.image.width != ''">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="scale">
    <xsl:choose>
      <xsl:when test="$ignore.image.scaling != 0">0</xsl:when>
      <xsl:when test="@contentwidth or @contentdepth">1.0</xsl:when>
      <xsl:when test="@scale">
        <xsl:value-of select="@scale div 100.0"/>
      </xsl:when>
      <xsl:otherwise>1.0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'graphic'
                      or local-name(.) = 'inlinegraphic'">
        <!-- handle legacy graphic and inlinegraphic by new template --> 
        <xsl:call-template name="mediaobject.filename">
          <xsl:with-param name="object" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- imagedata, videodata, audiodata -->
        <xsl:call-template name="mediaobject.filename">
          <xsl:with-param name="object" select=".."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="content-type">
    <xsl:if test="@format">
      <xsl:call-template name="graphic.format.content-type">
        <xsl:with-param name="format" select="@format"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="bgcolor">
    <xsl:call-template name="pi.dbfo_background-color">
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="imageWidth">
    <xsl:choose>
      <xsl:when test="@width">
        <xsl:value-of select="@width"/>
      </xsl:when>
      <xsl:when test="@depth">
      	<xsl:value-of select="@depth * @_actual-width div @_actual-height"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@_actual-width"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="maxWidth">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*[@class='problems-exercises']">
        <xsl:value-of select="$cnx.columnwidth.pixels"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$cnx.pagewidth.pixels"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:external-graphic>
    <xsl:attribute name="src">
      <xsl:call-template name="fo-external-image">
        <xsl:with-param name="filename">
          <xsl:if test="$img.src.path != '' and
                        not(starts-with($filename, '/')) and
                        not(contains($filename, '://'))">
            <xsl:value-of select="$img.src.path"/>
          </xsl:if>
          <xsl:value-of select="$filename"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:attribute>

<!-- CNX HACK: Don't set the height/width if the width is being forced -->
    <xsl:if test="$imageWidth &lt;= $maxWidth">
      <xsl:attribute name="width">
        <xsl:choose>
          <xsl:when test="$ignore.image.scaling != 0">auto</xsl:when>
          <xsl:when test="contains(@width,'%')">
            <xsl:value-of select="@width"/>
          </xsl:when>
          <xsl:when test="@width and not(@width = '')">
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@width"/>
              <xsl:with-param name="default.units" select="'px'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="not(@depth) and $default.image.width != ''">
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="$default.image.width"/>
              <xsl:with-param name="default.units" select="'px'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>auto</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <xsl:attribute name="height">
        <xsl:choose>
          <xsl:when test="$ignore.image.scaling != 0">auto</xsl:when>
          <xsl:when test="contains(@depth,'%')">
            <xsl:value-of select="@depth"/>
          </xsl:when>
          <xsl:when test="@depth">
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@depth"/>
              <xsl:with-param name="default.units" select="'px'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>auto</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>

    <xsl:attribute name="content-width">
      <xsl:choose>
<!-- CNX HACK -->
        <xsl:when test="$imageWidth > $maxWidth">
          <xsl:message>LOG: WARNING: image width is too wide. Forcing width and ignoring height. Max of <xsl:value-of select="$maxWidth"/> is less than imageWidth:<xsl:value-of select="$imageWidth"/> actual: <xsl:value-of select="@_actual-width"/></xsl:message>
          <xsl:value-of select="$maxWidth"/>
          <xsl:text>px</xsl:text>
        </xsl:when>
        <xsl:when test="$ignore.image.scaling != 0">auto</xsl:when>
        <xsl:when test="contains(@contentwidth,'%')">
          <xsl:value-of select="@contentwidth"/>
        </xsl:when>
        <xsl:when test="@contentwidth">
          <xsl:call-template name="length-spec">
            <xsl:with-param name="length" select="@contentwidth"/>
            <xsl:with-param name="default.units" select="'px'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="number($scale) != 1.0">
          <xsl:value-of select="$scale * 100"/>
          <xsl:text>%</xsl:text>
        </xsl:when>
        <xsl:when test="$scalefit = 1">scale-to-fit</xsl:when>
<!-- CNX HACK -->
        <xsl:when test="@width">
          <xsl:value-of select="@width"/>
        </xsl:when>
        <xsl:when test="@_actual-width">
          <xsl:value-of select="@_actual-width"/>
        </xsl:when>
        <xsl:otherwise>auto</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

<!-- CNX HACK: Don't set the height if the width is being forced -->
    <xsl:if test="not(@_actual-width) or $imageWidth &lt;= $maxWidth">
      <xsl:attribute name="content-height">
        <xsl:choose>
          <xsl:when test="$ignore.image.scaling != 0">auto</xsl:when>
          <xsl:when test="contains(@contentdepth,'%')">
            <xsl:value-of select="@contentdepth"/>
          </xsl:when>
          <xsl:when test="@contentdepth">
            <xsl:call-template name="length-spec">
              <xsl:with-param name="length" select="@contentdepth"/>
              <xsl:with-param name="default.units" select="'px'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="number($scale) != 1.0">
            <xsl:value-of select="$scale * 100"/>
            <xsl:text>%</xsl:text>
          </xsl:when>
          <xsl:when test="$scalefit = 1">scale-to-fit</xsl:when>
          <xsl:otherwise>auto</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="$content-type != ''">
      <xsl:attribute name="content-type">
        <xsl:value-of select="concat('content-type:',$content-type)"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="$bgcolor != ''">
      <xsl:attribute name="background-color">
        <xsl:value-of select="$bgcolor"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="@align">
      <xsl:attribute name="text-align">
        <xsl:value-of select="@align"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="@valign">
      <xsl:attribute name="display-align">
        <xsl:choose>
          <xsl:when test="@valign = 'top'">before</xsl:when>
          <xsl:when test="@valign = 'middle'">center</xsl:when>
          <xsl:when test="@valign = 'bottom'">after</xsl:when>
          <xsl:otherwise>auto</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </fo:external-graphic>
</xsl:template>


</xsl:stylesheet>
