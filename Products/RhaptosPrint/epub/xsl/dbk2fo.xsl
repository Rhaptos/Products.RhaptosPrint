<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/fo/docbook.xsl"/>
<xsl:import href="dbkplus.xsl"/>

<xsl:output indent="yes" method="xml" encoding="ASCII"/>

<!-- Remove reliance on external "draft" graphic -->
<xsl:param name="draft.mode">no</xsl:param>

<!-- Enable Apache FOP specific extensions (and disable things unsupported in FOP) -->
<xsl:param name="fop1.extensions" select="1"/>

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"></xsl:param>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>
<xsl:param name="chunk.section.depth" select="0"></xsl:param>
<xsl:param name="chunk.first.sections" select="0"></xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="toc.section.depth">0</xsl:param>

<!-- To support international characters, add some fonts -->
<xsl:param name="cnx.font.catchall">STIXGeneral,STIXSize,Code2000</xsl:param>
<xsl:param name="body.font.family">serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="dingbat.font.family">serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="monospace.font.family">monospace,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="sans.font.family">sans-serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="symbol.font.family">Symbol,ZapfDingbats,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="title.font.family">sans-serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>


<!-- Disable "Document Properties" in acrobat reader.
     Setting "fop1.extensions" causes this to be rendered which causes
     a stack underflow during the 2nd pass of rendering the PDF using
     the Development version of FOP -->
<!-- Metadata support ("Document Properties" in Adobe Reader) -->
<xsl:template name="fop1-document-information"/>


<!-- Add a template for newlines.
     The cnxml2docbook adds a processing instruction named <?cnx.newline?>
     and is matched here
     see http://www.sagehill.net/docbookxsl/LineBreaks.html
-->
<xsl:template match="processing-instruction('cnx.newline')">
	<fo:block>
		<xsl:comment>cnx.newline</xsl:comment>
	</fo:block>
</xsl:template>


<!-- No longer used: Print the current module that is being worked on.
	Converting Docbook to XSL-FO may take hours so 
	it's useful to see that progress is being made
 -->

<!-- ORIGINAL: docbook-xsl/fo/lists.xsl
	Changes: In addition to outputting "???" if a link is broken, 
	  also generate debug message so the author can fix it
 -->


<xsl:template match="db:token[@class='simplemath']/text()">
    <xsl:choose>
        <xsl:when test="normalize-space(.) != '' and normalize-space(.) != ' '">
            <fo:inline font-family="STIXGeneral">
                <xsl:value-of select="."/>
            </fo:inline>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="."/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="inline.boldseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-weight="bold">
    <xsl:if test="ancestor::db:token[@class='simplemath']">
        <xsl:attribute name="font-family">
            <xsl:text>STIXGeneral</xsl:text>
        </xsl:attribute>
    </xsl:if>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.italicseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-style="italic">
    <xsl:if test="ancestor::db:token[@class='simplemath']">
        <xsl:attribute name="font-family">
            <xsl:text>STIXGeneral</xsl:text>
        </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<!-- Discard MathML -->
<xsl:template match="mml:*"/>

<xsl:template match="db:authorgroup[@role='all']|db:othercredit|db:editor"/>

<xsl:template match="svg:*/@font-family">
    <xsl:attribute name="font-family">
        <xsl:value-of select="."/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$cnx.font.catchall"/>
    </xsl:attribute>
</xsl:template>

<xsl:template match="svg:*/@style">
    <xsl:variable name="containsFamily" select="contains(., 'font-family')"/>
    <xsl:attribute name="style">
	    <xsl:choose>
	        <xsl:when test="$containsFamily">
			    <xsl:variable name="before" select="substring-before(., 'font-family:')"/>
			    <xsl:variable name="family" select="substring-before(substring-after(., 'font-family:'), ';')"/>
			    <xsl:variable name="after" select="substring-after(substring-after(., 'font-family:'), ';')"/>
		        <xsl:value-of select="$before"/>
		        <xsl:value-of select="$family"/>
		        <xsl:if test="$family != ''">
		            <xsl:text>,</xsl:text>
		        </xsl:if>
		        <xsl:value-of select="$cnx.font.catchall"/>
		        <xsl:value-of select="$after"/>
	        </xsl:when>
	        <xsl:otherwise>
	            <xsl:value-of select="."/>
	            <xsl:text>;font-family:</xsl:text>
	            <xsl:value-of select="$cnx.font.catchall"/>
	            <xsl:text>;</xsl:text>
	        </xsl:otherwise>
	    </xsl:choose>
    </xsl:attribute>
</xsl:template>

</xsl:stylesheet>
