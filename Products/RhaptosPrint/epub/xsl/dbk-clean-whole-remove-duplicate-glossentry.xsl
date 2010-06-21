<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file is run after the book-level glossary is created.
	It removes duplicate db:glossentry elements
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:output indent="yes" method="xml"/>

<!-- DEAD: Removed in favor of module-level glossaries
<xsl:template match="db:glossentry[normalize-space(db:glossterm/text())!='' and db:glossterm/text()=preceding-sibling::db:glossentry/db:glossterm/text()]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Removing duplicate glossentry for term "<xsl:value-of select="db:glossterm/text()"/>"</xsl:with-param></xsl:call-template>
</xsl:template>
-->

<!-- Since we decided to discard printing module metadata, this removes it (after we generate the book-level metadata).  -->
<xsl:template match="db:prefaceinfo/db:*[local-name()!='title']|db:chapterinfo/db:*[local-name()!='title']|db:sectioninfo/db:*[local-name()!='title']|db:appendixinfo/db:*[local-name()!='title']">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding module metadata: <xsl:value-of select="local-name()"/></xsl:with-param></xsl:call-template>
</xsl:template>

<!-- Discard the email address for epub generation -->
<xsl:template match="db:email">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding email address</xsl:with-param></xsl:call-template>
</xsl:template>


<xsl:template match="ext:exercise-number-stub"> 
	<xsl:variable name="chapter">
		<xsl:number count="db:chapter" from="db:book"/>
	</xsl:variable>
	<xsl:variable name="module">
		<xsl:number count="*[@ext:element='module']"/>
	</xsl:variable>

	<xsl:value-of select="$chapter"/>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="$module"/>
	<xsl:text>.</xsl:text>
</xsl:template>
</xsl:stylesheet>
