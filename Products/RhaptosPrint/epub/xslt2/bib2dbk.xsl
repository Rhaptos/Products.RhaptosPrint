<xsl:stylesheet version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:bib="http://bibtexml.sf.net/"
        xmlns="http://docbook.org/ns/docbook"
        >

  <!-- Piggyback the BibTeXML conversion -->
  <xsl:import href="bibtexconverter-customized/bibxml2docbook5.xsl"/>
  <!-- Used by BibTeXML converter -->
  <xsl:param name="title" select="'Bibliography'" as="xs:string" />

  <!-- Stupid BibTeXML stylesheets.... -->
  <xsl:template match="text()">
      <xsl:copy/>
  </xsl:template>

  <!-- BibTeXML to Docbook conversion leaves cruft sitting around (bib:*).
      Apply imports and anything that isn't matched is discarded.
   -->
  <xsl:template match="bib:*">
      <xsl:apply-imports/>
  </xsl:template>
  <xsl:template match="bib:*/text()"/>


  <!-- Make sure the label does not contain the module id (we prefix all ids with the module so they are unique) -->
  <xsl:template match="bib:entry">
    <biblioentry>
      <xsl:variable name="xid" select="translate(@id,'/:','')"/>
      <xsl:attribute name="xreflabel" select="substring-after($xid, '.')"/>
      <xsl:attribute name="xml:id" select="$xid"/>
      <xsl:call-template name="authors"/>
      <xsl:call-template name="date"/>
      <xsl:apply-templates select="*" />
      <xsl:apply-templates select="*/*"/>
    </biblioentry>
  </xsl:template>

</xsl:stylesheet>