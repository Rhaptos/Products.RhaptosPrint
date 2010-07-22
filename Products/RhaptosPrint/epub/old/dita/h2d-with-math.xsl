<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
   xmlns:mml="http://www.w3.org/1998/Math/MathML"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   exclude-result-prefixes="mml"
>

<xsl:import href="h2d.xsl"/>

<xsl:template match="mml:math">
	<foreign>
		<math xmlns="http://www.w3.org/1998/Math/MathML">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="math"/>
		</math>
	</foreign>
</xsl:template>

<xsl:template mode="math" match="*[not(starts-with(local-name(),'m'))]" priority="-100">
	<xsl:message>ERROR: a Content MathML element (<xsl:value-of select="local-name()"/>) slipped through</xsl:message>
	<mml:mrow>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates mode="math"/>
	</mml:mrow>
</xsl:template>

<xsl:template mode="math" match="mml:ci">
	<mml:mi>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates mode="math"/>
	</mml:mi>
</xsl:template>

<!-- The default c2p.xsl doesn't catch some applications, so here we do something "reasonable" -->
<xsl:template mode="math" match="mml:apply">
	<mml:mrow>
		<xsl:apply-templates mode="math" select="*[1]"/>
		<mml:mo>(</mml:mo>
		<xsl:for-each select="*[position()>1]">
			<xsl:apply-templates mode="math" select="."/>
			<xsl:if test="position()!=last()">
				<mml:mi>,</mml:mi>
			</xsl:if>
		</xsl:for-each>
		<mml:mo>)</mml:mo>
	</mml:mrow>
</xsl:template>

<!-- Drop invisible times ops -->
<xsl:template mode="math" match="mml:mo[count(*)=0 and normalize-space(text())='']">
	<xsl:variable name="name" select="normalize-space(text())"/>
	<xsl:choose>
		<xsl:when test="$name='' or $name='&#8290;' or $name='&#8289;' or $name='&#8291;' or $name='&#8203;'">
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template mode="math" match="*">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates mode="math"/>
	</xsl:copy>
</xsl:template>

<!-- Weird cruft from long ago... -->
<xsl:template match="mml:equation" />

</xsl:stylesheet>
