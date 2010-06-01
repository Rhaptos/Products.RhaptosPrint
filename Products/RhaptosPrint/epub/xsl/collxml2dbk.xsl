<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xi='http://www.w3.org/2001/XInclude'
  exclude-result-prefixes="col md"
  >
<xsl:include href="cnxml2dbk.xsl"/>

<xsl:output indent="yes"/>

<xsl:template match="col:*/@*">
	<xsl:copy/>
</xsl:template>

<xsl:template match="col:collection">
	<db:book><xsl:apply-templates select="@*|node()"/></db:book>
</xsl:template>

<xsl:template match="col:metadata">
	<db:info><xsl:apply-templates select="@*|node()"/></db:info>
</xsl:template>

<!-- If there are no sub collections, treat each module as a db:chapter -->
<xsl:template match="col:collection/col:content[not(col:subcollection)]">
	<xsl:apply-templates select="node()"/>
</xsl:template>

<!-- If there are subcollections but no modules then treat each subcollection as a db:part -->
<xsl:template match="col:collection/col:content[col:subcollection and not(col:module)]">
	<xsl:apply-templates select="col:subcollection"/>
</xsl:template> 

<!-- If there are subcollections and modules then:
     treat each module before the 1st subcollection as a preface
     treat each module after the last subcollection as an appendix
     treat each subcollection as a chapter
     treat each module between subcollections as a chapter
 -->
<xsl:template match="col:collection/col:content[col:subcollection and col:module]">
	<!-- Preface -->
	<xsl:if test="col:module[not(preceding-sibling::col:subcollection)]">
		<db:preface>
			<db:title>Preface</db:title>
			<xsl:apply-templates select="col:module[not(preceding-sibling::col:subcollection)]"/>
		</db:preface>
	</xsl:if>
	<!-- Body -->
	<xsl:apply-templates select="col:subcollection|col:module[preceding-sibling::col:subcollection and following-sibling::col:subcollection]"/>
	<!-- Appendix -->
	<xsl:if test="col:module[not(following-sibling::col:subcollection)]">
		<db:appendix>
			<db:title>Errata</db:title>
			<xsl:apply-templates select="col:module[not(following-sibling::col:subcollection)]"/>
		</db:appendix>
	</xsl:if>
</xsl:template>


<!-- Free-floating Modules in a col:collection should be treated as Chapters -->
<xsl:template match="col:collection/col:content/col:module"> 
	<!-- TODO: Convert the db:section root of the module to a chapter. Can't now because we create xinclude refs to it -->
	<db:chapter>
		<xsl:apply-templates select="@*|node()"/>
		<xi:include href="{@document}/index.dbk"/>
	</db:chapter>
</xsl:template>

<xsl:template match="col:collection/col:content/col:subcollection">
	<db:chapter><xsl:apply-templates select="@*|node()"/></db:chapter>
</xsl:template>

<!-- Subcollections in a chapter should be treated as a section -->
<xsl:template match="col:subcollection/col:content/col:subcollection">
	<db:section><xsl:apply-templates select="@*|node()"/></db:section>
</xsl:template>

<xsl:template match="col:content">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="col:module">
	<xi:include href="{@document}/index.dbk"/>
</xsl:template>


<xsl:template match="md:title">
	<db:title><xsl:apply-templates/></db:title>
</xsl:template>



<xsl:template match="@id|@xml:id|comment()|processing-instruction()">
    <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
