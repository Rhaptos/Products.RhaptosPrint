<?xml version= "1.0"?>

<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:bib="http://bibtexml.sf.net/">

  <xsl:template match="bib:entry">
    <xsl:if test="@id">
       \nocite{<xsl:value-of select="@id"/>}
    </xsl:if>
   </xsl:template>

</xsl:stylesheet>


