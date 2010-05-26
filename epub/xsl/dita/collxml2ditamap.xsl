<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  exclude-result-prefixes="col md"
  >
  
<xsl:output indent="yes"/>

<!-- Boilerplate -->
<xsl:template match="/">
    <xsl:apply-templates select="col:collection"/>
</xsl:template>

<xsl:template match="col:collection">
	<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE map PUBLIC "-//OASIS//DTD DITA Map//EN" "../dtd/map.dtd"></xsl:text>
	<map title="{col:metadata/md:title/text()}">
    	<xsl:apply-templates select="col:content/col:subcollection"/>
    </map>
</xsl:template>

<xsl:template match="col:subcollection">
		<xsl:apply-templates select="col:content/col:subcollection|col:content/col:module"/>
</xsl:template>

<xsl:template match="col:module">
	<topicref href="{@document}.dita" type="topic">
	</topicref>
</xsl:template>

</xsl:stylesheet>
