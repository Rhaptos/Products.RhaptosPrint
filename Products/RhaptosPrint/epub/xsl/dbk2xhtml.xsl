<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg" xmlns:db="http://docbook.org/ns/docbook" xmlns:d="http://docbook.org/ns/docbook" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ext="http://cnx.org/ns/docbook+" version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/xhtml-1_1/docbook.xsl"/>
<xsl:import href="dbk2xhtml-core.xsl"/>

<xsl:output indent="no" method="xml"/>

<!-- ============================================== -->
<!-- Customize docbook params for this style        -->
<!-- ============================================== -->

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="toc.section.depth">1</xsl:param>

<xsl:param name="body.font.master">8.5</xsl:param>
<xsl:param name="body.start.indent">0px</xsl:param>

<xsl:param name="header.rule" select="0"/>

<xsl:param name="generate.toc">
appendix  toc,title
chapter   toc,title
book      toc,title
</xsl:param>

<xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
</xsl:param>

<!-- simplified math generates a c:span[@class="simplemath"] or db:token[@class="simplemath"] with a mml:math in it. for epubs, discard the simplemath -->
<xsl:template match="db:token[@class='simplemath' and db:inlinemediaobject]">
  <xsl:message>INFO: Discarding simplemath in favor of MathML/SVG</xsl:message>
  <xsl:apply-templates select="db:inlinemediaobject"/>
</xsl:template>

</xsl:stylesheet>
