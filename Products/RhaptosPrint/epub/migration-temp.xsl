<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg" xmlns:db="http://docbook.org/ns/docbook" xmlns:d="http://docbook.org/ns/docbook" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ext="http://cnx.org/ns/docbook+" version="1.0">

<xsl:output indent="yes" method="xml"/>

<xsl:template match="@*|node()">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<!-- Convert Dx to delta x (4) -->
<xsl:template match="mml:*[substring(text(), 1, 1) = 'D' and string-length(text()) >= 2]">
  <xsl:message><xsl:value-of select="local-name()"/> "<xsl:value-of select="text()"/>"</xsl:message>
</xsl:template>

<!-- Add a space to alpha-numeric text following math and preceding math (1140) -->
<xsl:template match="text()[preceding-sibling::node()[self::mml:math or self::db:token] and string-length(normalize-space(.)) > 0
 and substring(normalize-space(.),1,1) != ' '
 and substring(normalize-space(.),1,1) != ':'
 and substring(normalize-space(.),1,1) != ';'
 and substring(normalize-space(.),1,1) != '.'
 and substring(normalize-space(.),1,1) != '?'
 and substring(normalize-space(.),1,1) != '!'
 and substring(normalize-space(.),1,1) != ','
 and substring(normalize-space(.),1,1) != '='
 and substring(normalize-space(.),1,1) != ')'
 and substring(normalize-space(.),1,1) != '('
 and substring(normalize-space(.),1,1) != '/'
 and substring(normalize-space(.),1,1) != '-'
]">
  <!-- <xsl:message>text before: "<xsl:value-of select="normalize-space(.)"/>"</xsl:message> -->
  <xsl:variable name="fix">
    <xsl:text> </xsl:text>
    <xsl:copy/>
  </xsl:variable>
</xsl:template>

<xsl:template match="text()[following-sibling::node()[self::mml:math or self::db:token] and string-length(normalize-space(.)) > 0
 and substring(normalize-space(.),string-length(normalize-space(.)),1) != ' '
 and substring(normalize-space(.),string-length(normalize-space(.)),1) != '('
]">
    <!-- <xsl:message>text after: "<xsl:value-of select="substring(normalize-space(.),string-length(normalize-space(.)),1)"/>" "<xsl:value-of select="normalize-space(.)"/>"</xsl:message> -->
  <xsl:variable name="fix">
    <xsl:copy/>
    <xsl:text> </xsl:text>
  </xsl:variable>
</xsl:template>

<!-- Convert overbars so they are stretchy (90) -->
<xsl:template match="mml:mo[@stretchy='false' and text() = '&#713;']">
  <!-- <xsl:message>Found an overbar. Should convert to stretchy=true and just a "-"</xsl:message> -->
  <xsl:variable name="fix">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'stretchy')]"/>
      <xsl:attribute name="stretchy">
        <xsl:text>true</xsl:text>
      </xsl:attribute>
      <xsl:text>-</xsl:text>
    </xsl:copy>
  </xsl:variable>
</xsl:template>


<!-- For tables without a header, use the 1st row as a header (13) -->
<!-- TODO: rewrite using cnxml instead of dbk -->
<xsl:template match="db:table/db:tgroup[not(db:thead)]/db:tbody">
  <!-- <xsl:message>Found a table with no header. Using the 1st row as header</xsl:message> -->
  <xsl:variable name="fix">
    <db:thead>
      <xsl:apply-templates select="db:trow[1]"/>
    </db:thead>
    <xsl:copy>
      <xsl:apply-templates select="db:trow[position() != 1]"/>
    </xsl:copy>
  </xsl:variable>
</xsl:template>


<!-- There are links (and textual references, but I can't find those) that are mislabeled (should be xrefs) -->
<!-- TODO: rewrite using cnxml instead of dbk -->
<!-- TODO: add an XML document-id-mapping lookup to rewrite the @document value -->
<xsl:template match="db:link[@document]">
  <!-- <xsl:message>Found a link to <xsl:value-of select="@document"/> with text: "<xsl:value-of select="text()"/>"</xsl:message> -->
</xsl:template>

<!-- Find things like "Exercise 1.3" in regular body text -->
<!--
<xsl:template match="text()[contains(.,'Example ') and string(number(substring(substring-after(.,'Example '),1,1))) != 'NaN']">
  <xsl:message><xsl:value-of select="ancestor::db:section[@document]/@document"/>: Found a reference to 'Example #' in regular text; this should be a c:link. Text: "Example <xsl:value-of select="substring(substring-after(.,'Example '),1,10)"/>"</xsl:message>
</xsl:template>

<xsl:template match="text()[contains(.,'Table ') and string(number(substring(substring-after(.,'Table '),1,1))) != 'NaN']">
  <xsl:message><xsl:value-of select="ancestor::db:section[@document]/@document"/>: Found a reference to 'Table #' in regular text; this should be a c:link. Text: "Table <xsl:value-of select="substring(substring-after(.,'Table '),1,10)"/>"...</xsl:message>
</xsl:template>

<xsl:template match="text()[contains(.,'Figure ') and string(number(substring(substring-after(.,'Figure '),1,1))) != 'NaN']">
  <xsl:message><xsl:value-of select="ancestor::db:section[@document]/@document"/>: Found a reference to 'Figure #' in regular text; this should be a c:link. Text: "Figure <xsl:value-of select="substring(substring-after(.,'Figure '),1,10)"/>"...</xsl:message>
</xsl:template>
-->

</xsl:stylesheet>
