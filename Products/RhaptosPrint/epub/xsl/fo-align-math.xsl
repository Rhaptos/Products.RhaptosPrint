<?xml version="1.0" ?>
<!-- 
	pmml2svg provides a baseline-shift element so we can position the graphic correctly
	(Sometimes the math extends below the baseline of text, if the math is inline)
	At this point we correct for it.
 -->
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  >

<xsl:output indent="yes" method="xml"/>
<xsl:include href="debug.xsl"/>
<xsl:include href="ident.xsl"/>

<!--
<xsl:template match="fo:block[not(@font-family)]">
  <xsl:copy>
    <xsl:apply-templates select="@*|ancestor::*[@font-family]/@font-family|node()"/>
  </xsl:copy>
</xsl:template>
-->

<!-- The span-all hack below sometimes loses the xmlns:svg="..." declaration so this attribute adds it onto the root -->
<xsl:template match="/*">
  <xsl:copy>
    <xsl:attribute name="svg:PHIL">this-attribute-is-to-ensure-the-svg-prefix-is-everywhere</xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- HACK: With the multi-column PDF layout spanning a note or image
     across both columns is possible only when it is the child of
     fo:flow. To accomplish this, we manually close all the
     ancestor tags and then reopen them with the same attributes.
-->
<xsl:template match="fo:*[@span='all']" name="cnx.span-all">
<xsl:message>LOG: INFO: Moving @span-all out because FOP requires it to be a child of fo:flow</xsl:message>
  <!-- close the tags.
       They must be done in reverse order so
       xsl:for-each/xsl:sort isn't good enough here -->
  <xsl:comment>auto-gen close tags:start</xsl:comment>
  <xsl:call-template name="cnx.reverse-close">
    <xsl:with-param name="c" select=".."/>
  </xsl:call-template>
  <xsl:text>
</xsl:text>
  <xsl:comment>auto-gen close tags:done</xsl:comment>

  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
  
  <!-- re-open the tags -->
  <xsl:comment>auto-gen re-open tags:start</xsl:comment>
  <xsl:for-each select="ancestor::*[ancestor::fo:flow]">

    <!-- generate open tag -->
    <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
    <xsl:value-of select="name()"/>

    <!-- generate attributes (except for id's) -->
    <xsl:for-each select="@*[not(name() = 'id' or name() = 'xml:id')]">
      <xsl:text> </xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>="</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>"</xsl:text>
    </xsl:for-each>
    <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
  </xsl:for-each>

  <xsl:text>
</xsl:text>
  <xsl:comment>auto-gen reopen tags:done</xsl:comment>
</xsl:template>

<!-- Used to close all the open fo:block/fo:wrap tags -->
<xsl:template name="cnx.reverse-close">
  <xsl:param name="c"/>
  <xsl:if test="$c[ancestor::fo:flow]">
    <!-- generate close tag -->
    <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="name($c)"/>
    <xsl:text disable-output-escaping="yes">&gt;</xsl:text>

    <!-- Generate the other close tags 1st -->
    <xsl:call-template name="cnx.reverse-close">
      <xsl:with-param name="c" select="$c/parent::*[1]"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- Move the image up or down according to its baseline -->
<xsl:template match="fo:instream-foreign-object[svg:svg/svg:metadata/pmml2svg:baseline-shift]">
	<xsl:copy>
		<xsl:attribute name="alignment-adjust">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="svg:svg/svg:metadata/pmml2svg:baseline-shift/text()"/>
			<xsl:text>px</xsl:text>
		</xsl:attribute>
		<xsl:apply-templates select="@*|svg:svg"/>
	</xsl:copy>
</xsl:template>

<!-- Hack to dump negative-width SVG elements -->
<xsl:template match="fo:instream-foreign-object[svg:svg[starts-with(@width, '-')]]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Negative width SVG element. Stripping for now</xsl:with-param></xsl:call-template>
</xsl:template>

</xsl:stylesheet>
