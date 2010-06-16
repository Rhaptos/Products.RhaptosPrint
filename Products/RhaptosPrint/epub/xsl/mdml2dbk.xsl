<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:md4="http://cnx.rice.edu/mdml/0.4"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns="http://cnx.rice.edu/mdml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:ext="http://cnx.org/ns/docbook+"
  exclude-result-prefixes="c xlink db md4 md exsl"
  version="1.0">

<!-- This file converts module and collection mdml to elements Docbook understands. -->

<xsl:param name="cnx.license">This selection and arrangement of content is licensed under the Creative Commons Attribution License: </xsl:param>

<!-- There are 2 namespaces for mdml, so we convert the old one to the new one, and process it -->
<xsl:param name="exsl.node.set.available"> 
  <xsl:choose>
    <xsl:when xmlns:exsl="http://exslt.org/common" exsl:foo="" test="function-available('exsl:node-set') or contains(system-property('xsl:vendor'),                          'Apache Software Foundation')">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:template match="md4:*">
	<xsl:choose>
	    <xsl:when test="$exsl.node.set.available != 0">
			<xsl:variable name="upgraded">
				<xsl:apply-templates select="." mode="upgrade.mdml"/>
			</xsl:variable>
			<xsl:apply-templates select="exsl:node-set($upgraded)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: Could not upconvert MDML namespaced element</xsl:with-param></xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="*" mode="upgrade.mdml">
  <xsl:choose>
    <xsl:when test="self::md4:*">
      <xsl:element name="{local-name(.)}" namespace="http://cnx.rice.edu/mdml">
        <xsl:apply-templates select="@*[not(name(.) = 'xml:id')]"/>
        <xsl:if test="@xml:id">
          <xsl:attribute name="id">
            <xsl:value-of select="@xml:id"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="upgrade.mdml"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:apply-templates select="@*[not(name(.) = 'xml:id')]"/>
        <xsl:if test="@xml:id">
          <xsl:attribute name="id">
            <xsl:value-of select="@xml:id"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="upgrade.mdml"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
<xsl:template match="comment()|processing-instruction()|text()" mode="upgrade.mdml">
  <xsl:copy/>
</xsl:template>

  
 <!-- Either the authors/editors/maintainers/licensors are in lists, or in md:roles -->
<!-- new-style roles -->
<xsl:template match="md:roles">
	<db:authorgroup>
		<xsl:apply-templates select="@*|node()"/>
	</db:authorgroup>
</xsl:template>
<xsl:template match="md:role">
	<xsl:call-template name="people-lookup">
		<xsl:with-param name="ids"><xsl:apply-templates select="text()"/><xsl:text> </xsl:text></xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template name="people-lookup">
	<xsl:param name="ids"/>
	<xsl:variable name="first" select="substring-before($ids,' ')"/>
	<xsl:variable name="rest" select="substring-after($ids,' ')"/>
	<xsl:choose>
		<xsl:when test="@type = 'author'">
			<db:author ext:userid="{$first}">
				<xsl:apply-templates select="@*|../../md:actors/md:*[@userid=$first]"/>
			</db:author>
		</xsl:when>
		<xsl:when test="@type = 'editor'">
			<db:editor ext:userid="{$first}">
				<xsl:apply-templates select="@*|../../md:actors/md:*[@userid=$first]"/>
			</db:editor>
		</xsl:when>
		<xsl:when test="@type = 'translator'">
			<db:othercredit class="translator" ext:userid="{$first}">
				<xsl:apply-templates select="@*|../../md:actors/md:*[@userid=$first]"/>
			</db:othercredit>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: Unknown role <xsl:value-of select="@type"/></xsl:with-param></xsl:call-template>
			<db:othercredit class="other" ext:userid="{$first}">
				<xsl:apply-templates select="@*|../../md:actors/md:*[@userid=$first]"/>
				<db:contrib><xsl:value-of select="@type"/></db:contrib>
			</db:othercredit>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$rest != ''">
		<xsl:call-template name="people-lookup">
			<xsl:with-param name="ids" select="$rest"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>


<!--  old-style lists -->
<xsl:template match="md:authorlist|md:maintainerlist|md:licensorlist">
	<db:authorgroup>
		<xsl:comment>
			<xsl:value-of select="substring-before(local-name(.), 'list')"/>
			<xsl:text>s</xsl:text>
		</xsl:comment>
		<xsl:apply-templates/>
	</db:authorgroup>
</xsl:template>

<xsl:template match="md:author">
	<db:author><xsl:call-template name="author-maintainer"/></db:author>
</xsl:template>
<xsl:template match="md:maintainer">
	<db:editor><xsl:call-template name="author-maintainer"/></db:editor>
</xsl:template>
<xsl:template match="md:licensor">
	<db:othercredit class="other"><xsl:call-template name="author-maintainer"/></db:othercredit>
</xsl:template>

<xsl:template name="author-maintainer">
	<xsl:choose>
		<xsl:when test="md:firstname/text() = md:surname/text()">
			<db:orgname><xsl:apply-templates select="md:firstname/node()"/></db:orgname>
		</xsl:when>
		<xsl:otherwise>
			<db:personname>
				<xsl:apply-templates select="md:firstname|md:surname"/>
			</db:personname>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates select="md:email"/>
</xsl:template>

<xsl:template match="md:license">
	<db:legalnotice>
		<db:para>
			<xsl:value-of select="$cnx.license"/>
			<?cnx.newline?>
			<!-- old-style mdml uses @href -->
			<db:link xlink:href="{@url}{@href}"><xsl:value-of select="@url"/><xsl:value-of select="@href"/></db:link>
			<xsl:apply-templates/>
		</db:para>
	</db:legalnotice>
</xsl:template>


<!-- Simple transforms: -->
<xsl:template match="md:roles|md:person"><xsl:apply-templates/></xsl:template>
<xsl:template match="md:firstname">
	<db:firstname><xsl:apply-templates/></db:firstname>
</xsl:template>
<xsl:template match="md:surname">
	<db:surname><xsl:apply-templates/></db:surname>
</xsl:template>
<xsl:template match="md:email">
	<db:email><xsl:apply-templates/></db:email>
</xsl:template>
<xsl:template match="md:revised">
	<db:pubdate><xsl:apply-templates/></db:pubdate>
</xsl:template>
<xsl:template match="md:version">
	<db:edition><xsl:apply-templates/></db:edition>
</xsl:template>
<xsl:template match="md:keywordlist">
	<db:keywordset><xsl:apply-templates/></db:keywordset>
</xsl:template>
<xsl:template match="md:keyword">
	<db:keyword><xsl:apply-templates/></db:keyword>
</xsl:template>
<xsl:template match="md:subjectlist">
	<db:subjectset><xsl:apply-templates/></db:subjectset>
</xsl:template>
<xsl:template match="md:subject">
	<db:subject><xsl:apply-templates/></db:subject>
</xsl:template>
<xsl:template match="md:abstract">
	<db:abstract><db:para><xsl:apply-templates/></db:para></db:abstract>
</xsl:template>


<!-- Ignore the following metadata elements -->
<!-- Ignore actors. they're only used by md:roles -->
<xsl:template match="md:title|md:content-id|md:version|md:created|md:language|md:fullname|md:actors|md:repository|md:content-url"/>

 
</xsl:stylesheet>