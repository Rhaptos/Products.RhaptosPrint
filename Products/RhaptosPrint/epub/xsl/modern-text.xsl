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

<!-- Sometimes we customize both how an exercise is rendered _and_ some wrapper stuff based on, say, its @class (like if it should be rendered).
  Instead of relying on xsl:apply-imports and potentially having another XSL, just put all the general templates in with mode="dbk"
  -->

<xsl:import href="modern-text-core.xsl"/>


<!-- ============================================== -->
<!-- New Feature: @class='margin'                   -->
<!-- ============================================== -->

<!-- These are magic settings to get a block to float left -->
<xsl:attribute-set name="cnx.margin">
  <xsl:attribute name="margin-left">-2.5in</xsl:attribute>
  <xsl:attribute name="padding-left">0.2in</xsl:attribute>
  <xsl:attribute name="padding-right">2in</xsl:attribute>
  <xsl:attribute name="margin-right">-1.7in</xsl:attribute>
  <xsl:attribute name="width">0in</xsl:attribute>
  <xsl:attribute name="position">absolute</xsl:attribute>
</xsl:attribute-set>

<!-- Marginalia support. Make position absolute so it doesn't take up space, then in another pass move it left/right -->
<xsl:template match="*[@class='margin']">
<!-- This outer, empty block container is necessary becuase FOP uses it to 
  know where to vertically position the figure/thing -->
<fo:block-container>
  <fo:block-container xsl:use-attribute-sets="cnx.margin">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-imports/>
  </fo:block-container>
</fo:block-container>
</xsl:template>


<!-- ============================================== -->
<!-- New Feature: @class='end-of-chapter-problems'  -->
<!-- (See included XSLT file for more) -->
<!-- ============================================== -->

<xsl:template match="*[@class='end-of-chapter-problems']">
  <xsl:param name="render" select="''"/>
  <xsl:choose>
    <xsl:when test="$render = 'true'">
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:comment>Moved <xsl:value-of select="local-name(.)"/>[id="<xsl:value-of select="@xml:id|@id"/>"] to bottom of chapter</xsl:comment>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
