<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  version="1.0">

<!-- This file converts dbk files to chunked html which is used in EPUB generation.
	* Stores customizations and docbook settings specific to Connexions
	* Shifts images that were converted from MathML so they line up with text nicely
	* Puts equation numbers on the RHS of an equation
	* Disables equation and figure numbering inside things like examples and glossaries
	* Adds @class attributes to elements for custom styling (like c:rule, c:figure)
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/epub/docbook.xsl"/>

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"></xsl:param>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>
<xsl:param name="chunk.section.depth" select="0"></xsl:param>
<xsl:param name="chunk.first.sections" select="0"></xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="xref.with.number.and.title">0</xsl:param>
<xsl:param name="toc.section.depth">0</xsl:param>


<!-- Use .xhtml so browsers are in XML-mode (and render inline SVG) -->
<xsl:param name="html.ext">.xhtml</xsl:param>
<!-- <xsl:param name="chunk.quietly">0</xsl:param>  -->
<xsl:param name="svg.doctype-public">-//W3C//DTD SVG 1.1//EN</xsl:param>
<xsl:param name="svg.doctype-system">http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd</xsl:param>
<xsl:param name="svg.media-type">image/svg+xml</xsl:param>

<xsl:output indent="yes" method="xml"/>

<!-- Output the PNG with the baseline info -->
<xsl:template match="@pmml2svg:baseline-shift">
	<xsl:attribute name="style">
	    <!-- Ignore width and height information for now
		<xsl:text>width:</xsl:text>
		<xsl:value-of select="@width"/>
		<xsl:text>; height:</xsl:text>
		<xsl:value-of select="@depth"/>
		<xsl:text>;</xsl:text>
		-->
	  	<xsl:text>vertical-align:-</xsl:text>
	  	<xsl:value-of select="." />
	  	<xsl:text>pt;</xsl:text>
  	</xsl:attribute>
</xsl:template>

<!-- Ignore the SVG element and use the @fileref (SVG-to-PNG conversion) -->
<xsl:template match="*['imagedata'=local-name() and @fileref]" xmlns:svg="http://www.w3.org/2000/svg">
	<img src="{@fileref}">
		<xsl:apply-templates select="@pmml2svg:baseline-shift"/>
		<!-- Ignore the SVG child -->
	</img>
<!--
  <object id="{$id}" type="image/svg+xml" data="{$chunkfn}" width="{@width}" height="{@height}">
 	<xsl:if test="svg:metadata/pmml2svg:baseline-shift">
  	  <xsl:attribute name="style">position:relative; top:<xsl:value-of
		select="svg:metadata/pmml2svg:baseline-shift" />px;</xsl:attribute>
  	</xsl:if>
	<img src="{@fileref}" width="{@width}" height="{@height}"/>
  </object>
--></xsl:template>


<!-- Put the equation number on the RHS -->
<xsl:template match="equation">
  <div class="equation">
    <xsl:attribute name="id">
      <xsl:call-template name="object.id"/>
    </xsl:attribute>
	<xsl:apply-templates/>
	<span class="label">
	  <xsl:text>(</xsl:text>
	  <xsl:apply-templates select="." mode="label.markup"/>
      <xsl:text>)</xsl:text>
    </span>
  </div>
</xsl:template>


<!-- Don't number examples inside exercises. Original code taken from docbook-xsl/common/labels.xsl -->
<xsl:template match="example[ancestor::glossentry
            or ancestor::*[@c:element='rule']
            ]" mode="label.markup">
</xsl:template>
<xsl:template match="figure|table|example" mode="label.markup">
  <xsl:variable name="pchap"
                select="(ancestor::chapter
                        |ancestor::appendix
                        |ancestor::article[ancestor::book])[last()]"/>
  <xsl:variable name="name" select="name()"/>
  
  <xsl:variable name="prefix">
    <xsl:if test="count($pchap) &gt; 0">
      <xsl:apply-templates select="$pchap" mode="label.markup"/>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$prefix != ''">
            <xsl:apply-templates select="$pchap" mode="label.markup"/>
            <xsl:apply-templates select="$pchap" mode="intralabel.punctuation"/>
          <xsl:number format="1" from="chapter|appendix" count="*[$name=name() and not(
               ancestor::glossentry
               or ancestor::*[@c:element='rule']
               
          )]" level="any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number format="1" from="book|article" level="any" count="*[$name=name() and not(
               ancestor::glossentry
               or ancestor::*[@c:element='rule']
               
          )]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Override of docbook-xsl/xhtml-1_1/html.xsl -->
<xsl:template match="*[@c:element|@class]" mode="class.value">
  <xsl:param name="class" select="local-name(.)"/>
  <xsl:variable name="cls">
  	<xsl:value-of select="$class"/>
  	<xsl:if test="@c:element">
  		<xsl:text> </xsl:text>
  		<xsl:value-of select="@c:element"/>
  	</xsl:if>
  	<xsl:if test="@class">
  		<xsl:text> </xsl:text>
  		<xsl:value-of select="@class"/>
  	</xsl:if>
  </xsl:variable>
  <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Adding to @class: "<xsl:value-of select="$cls"/>"</xsl:with-param></xsl:call-template>
  <!-- permit customization of class value only -->
  <!-- Use element name by default -->
  <xsl:value-of select="$cls"/>
</xsl:template>

<!-- Override of docbook-xsl/xhtml-1_1/xref.xsl -->
<xsl:template match="*[@XrefLabel]" mode="xref-to">
	<xsl:value-of select="@XrefLabel"/>
</xsl:template>

<xsl:template match="inlineequation" mode="xref-to">
	<xsl:text>Equation</xsl:text>
</xsl:template>

<xsl:template match="caption" mode="xref-to">
	<xsl:apply-templates select="."/>
</xsl:template>

</xsl:stylesheet>
