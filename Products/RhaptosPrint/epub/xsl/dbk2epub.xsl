<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
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

<!-- Add a template for newlines.
     The cnxml2docbook adds a processing instruction named <?cnx.newline?>
     and is matched here
     see http://www.sagehill.net/docbookxsl/LineBreaks.html
-->
<xsl:template match="processing-instruction('cnx.newline')">
	<xsl:comment>cnx.newline</xsl:comment>
	<br/>
</xsl:template>
<xsl:template match="processing-instruction('cnx.newline.underline')">
	<xsl:comment>cnx.newline.underline</xsl:comment>
	<hr/>
</xsl:template>

<!-- Fix up TOC-generation for the ncx file.
	Overrides code in docbook-xsl/docbook.xsl using code from docbook-xsl/xhtml-1_1/autotoc.xsl
 -->
  <xsl:template match="book|
                       article|
                       part|
                       reference|
                       preface|
                       chapter|
                       bibliography|
                       appendix|
                       glossary|
                       section|
                       sect1|
                       sect2|
                       sect3|
                       sect4|
                       sect5|
                       refentry|
                       colophon|
                       bibliodiv[title]|
                       setindex|
                       index"
                mode="ncx">
    <xsl:variable name="depth" select="count(ancestor::*)"/>
    <xsl:variable name="title">
      <xsl:if test="$epub.autolabel != 0">
        <xsl:variable name="label.markup">
          <xsl:apply-templates select="." mode="label.markup" />
        </xsl:variable>
        <xsl:if test="normalize-space($label.markup)">
          <xsl:value-of
            select="concat($label.markup,$autotoc.label.separator)" />
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="." mode="title.markup" />
    </xsl:variable>

    <xsl:variable name="href">
      <xsl:call-template name="href.target.with.base.dir">
        <xsl:with-param name="context" select="/" />
        <!-- Generate links relative to the location of root file/toc.xml file -->
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="id">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:variable>
    <xsl:variable name="order">
      <xsl:value-of select="$depth +
                                  count(preceding::part|
                                  preceding::reference|
                                  preceding::book[parent::set]|
                                  preceding::preface|
                                  preceding::chapter|
                                  preceding::bibliography|
                                  preceding::appendix|
                                  preceding::article|
                                  preceding::glossary|
                                  preceding::section[not(parent::partintro)]|
                                  preceding::sect1[not(parent::partintro)]|
                                  preceding::sect2|
                                  preceding::sect3|
                                  preceding::sect4|
                                  preceding::sect5|
                                  preceding::refentry|
                                  preceding::colophon|
                                  preceding::bibliodiv[title]|
                                  preceding::index)"/>
    </xsl:variable>


  <xsl:variable name="depth2">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'section'">
        <xsl:value-of select="count(ancestor::section) + 1"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'sect1'">1</xsl:when>
      <xsl:when test="local-name(.) = 'sect2'">2</xsl:when>
      <xsl:when test="local-name(.) = 'sect3'">3</xsl:when>
      <xsl:when test="local-name(.) = 'sect4'">4</xsl:when>
      <xsl:when test="local-name(.) = 'sect5'">5</xsl:when>
      <xsl:when test="local-name(.) = 'refsect1'">1</xsl:when>
      <xsl:when test="local-name(.) = 'refsect2'">2</xsl:when>
      <xsl:when test="local-name(.) = 'refsect3'">3</xsl:when>
      <xsl:when test="local-name(.) = 'simplesect'">
        <!-- sigh... -->
        <xsl:choose>
          <xsl:when test="local-name(..) = 'section'">
            <xsl:value-of select="count(ancestor::section)"/>
          </xsl:when>
          <xsl:when test="local-name(..) = 'sect1'">2</xsl:when>
          <xsl:when test="local-name(..) = 'sect2'">3</xsl:when>
          <xsl:when test="local-name(..) = 'sect3'">4</xsl:when>
          <xsl:when test="local-name(..) = 'sect4'">5</xsl:when>
          <xsl:when test="local-name(..) = 'sect5'">6</xsl:when>
          <xsl:when test="local-name(..) = 'refsect1'">2</xsl:when>
          <xsl:when test="local-name(..) = 'refsect2'">3</xsl:when>
          <xsl:when test="local-name(..) = 'refsect3'">4</xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

	<xsl:if test="not(local-name()='section' or local-name()='simplesect') or $toc.section.depth &gt; $depth2">

    <xsl:element name="ncx:navPoint">
      <xsl:attribute name="id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>

      <xsl:attribute name="playOrder">
        <xsl:choose>
          <xsl:when test="/*[self::set]">
            <xsl:value-of select="$order"/>
          </xsl:when>
          <xsl:when test="$root.is.a.chunk != '0'">
            <xsl:value-of select="$order + 1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$order - 0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:element name="ncx:navLabel">
        <xsl:element name="ncx:text"><xsl:value-of select="normalize-space($title)"/> </xsl:element>
      </xsl:element>
      <xsl:element name="ncx:content">
        <xsl:attribute name="src">
          <xsl:value-of select="$href"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="book[parent::set]|part|reference|preface|chapter|bibliography|appendix|article|glossary|section|sect1|sect2|sect3|sect4|sect5|refentry|colophon|bibliodiv[title]|setindex|index" mode="ncx"/>
    </xsl:element>

	</xsl:if>

  </xsl:template>


<!-- Customize the metadata generated for the epub.
	Originally from docbook-xsl/epub/docbook.xsl -->
<xsl:template mode="opf.metadata" match="authorgroup">
	<xsl:apply-templates mode="opf.metadata" select="node()"/>
</xsl:template>

<!-- Customize the title page
<xsl:template name="book.titlepage">
	<div>PHIL-TITLE</div>
</xsl:template>
-->
</xsl:stylesheet>