<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>


<!-- Boilerplate -->
<xsl:template match="/">
	<!-- 
	<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE topic PUBLIC "-//OASIS//DTD DITA Topic//EN" "../dtd/topic.dtd"></xsl:text>
	-->
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="*|comment()|text()">
	<xsl:copy>
	    <xsl:copy-of select="@*"/>
    	<xsl:apply-templates select="*|comment()|text()"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="topic">
	<topic xsi:noNamespaceSchemaLocation="urn:oasis:names:tc:dita:xsd:topic.xsd:1.1">
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates/>
	</topic>
</xsl:template>


<xsl:template match="p/section"><b><xsl:value-of select="title"/></b></xsl:template>


<xsl:template match="xref[not(@href) or @href='']
    | xref[not(contains(@href, '#')
      or contains(@href, 'http')
      or contains(@href, '.dita'))]">
	<xsl:apply-templates/>
</xsl:template>
<xsl:template match="xref[contains(@href, '.dita') and not(contains(@href, '#'))]">
	<xref href="{@href}#topic0">
		<xsl:apply-templates/>
	</xref>
</xsl:template>

<xsl:template match="body/image|body/xref"/>

<xsl:template match="required-cleanup|section/section|body/b|section[title/@outputclass='type_footnote']" />
<xsl:template match="section[title[contains(comment(), 'Removed')]]"/>


<!-- Now for some desperate slashing. Anything that causes problems is getting slashed -->


</xsl:stylesheet>
