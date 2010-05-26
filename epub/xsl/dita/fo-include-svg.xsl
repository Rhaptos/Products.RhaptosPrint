<?xml version='1.0'?>

<xsl:stylesheet version="1.0"
	xmlns:mml="http://www.w3.org/1998/Math/MathML"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="foreign[svg:svg]">
		<fo:instream-foreign-object>
			<xsl:apply-templates mode="reprefix-svg" select="svg"/>
		</fo:instream-foreign-object>
	</xsl:template>

	<!-- FOP causes non-prefixed elements to lose their namespace. So, we'll slap it back onto svg elements -->
	<xsl:template match="foreign[svg]">
		<xsl:variable name="adjust" select="svg/metadata/pmml2svg:baseline-shift/text()"/>
		<fo:instream-foreign-object alignment-adjust="-{$adjust}px">
			<xsl:apply-templates mode="reprefix-svg" select="svg"/>
		</fo:instream-foreign-object>
	</xsl:template>

	<xsl:template mode="reprefix-svg" match="*">
		<xsl:element name="svg:{local-name()}" namespace="http://www.w3.org/2000/svg">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="reprefix-svg"/>
		</xsl:element>
	</xsl:template>

	<xsl:template mode="reprefix-svg" match="*[contains(name(), ':')]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="reprefix-svg"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="foreign">
		<xsl:message>PHIL_ERROR: could not convert foreign/<xsl:value-of select="name(*[1])"/> to something FOP could understand</xsl:message>
		<fo:block>
			PHIL_ERROR: could not convert foreign/<xsl:value-of select="name(*[1])"/> to something FOP could understand
		</fo:block>
	</xsl:template>
</xsl:stylesheet>