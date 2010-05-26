<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  version="1.0">

<!-- 
	Much of cnxml can be converted to docbook just by converting element names
	and attribute values. This file contains the straightforward conversions
 -->
<xsl:import href="debug.xsl"/>

<!-- Block elements in docbook cannot have free-floating text. they need to be wrapped in a db:para -->
<xsl:template name="block-id-and-children">
	<xsl:choose>
		<xsl:when test="normalize-space(text()) != ''">
			<db:para>
				<xsl:apply-templates select="@*|node()"/>
			</db:para>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="c:span">
	<db:token>
		<xsl:apply-templates select="@*|node()"/>
	</db:token>
</xsl:template>

<xsl:template match="c:note">
    <db:note><xsl:call-template name="block-id-and-children"/></db:note>
</xsl:template>
<xsl:template match="c:note[@type='warning']">
    <db:warning><xsl:call-template name="block-id-and-children"/></db:warning>
</xsl:template>
<xsl:template match="c:note[@type='footnote']">
    <db:footnote><xsl:call-template name="block-id-and-children"/></db:footnote>
</xsl:template>
<xsl:template match="c:section">
    <db:section><xsl:call-template name="block-id-and-children"/></db:section>
</xsl:template>
<xsl:template match="c:equation">
	<db:equation><xsl:call-template name="block-id-and-children"/></db:equation>
</xsl:template>
<xsl:template match="c:equation[not(c:title)]">
	<db:informalequation><xsl:call-template name="block-id-and-children"/></db:informalequation>
</xsl:template>
<xsl:template match="c:para//c:equation[not(c:title)]">
	<db:inlineequation><xsl:call-template name="block-id-and-children"/></db:inlineequation>
</xsl:template>
<xsl:template match="c:example">
	<db:example><xsl:call-template name="block-id-and-children"/></db:example>
</xsl:template>
<xsl:template match="c:example[not(c:title)]">
	<db:informalexample><xsl:call-template name="block-id-and-children"/></db:informalexample>
</xsl:template>

<!-- Support c:rule (with c:statement and c:proof) -->
<xsl:template match="c:rule">
    <db:section>
    	<xsl:apply-templates select="@*"/>
    	<db:title>
    	    <xsl:apply-templates select="c:title/@*"/>
    		<xsl:if test="not(@type)">
    			<xsl:text>Rule</xsl:text>
    		</xsl:if>
    		<xsl:value-of select="@type"/>
    		<xsl:if test="c:title">
    			<xsl:text>: </xsl:text>
    			<xsl:apply-templates select="c:title/node()"/>
    		</xsl:if>
    	</db:title>
    	<xsl:apply-templates select="*[local-name()!='title']"/>
    </db:section>
</xsl:template>

<xsl:template match="c:proof">
    <db:section>
    	<xsl:apply-templates select="@*"/>
    	<db:title>
    		<xsl:apply-templates select="c:title/@*"/>
    		<xsl:if test="not(@type)">
    			<xsl:text>Proof</xsl:text>
    		</xsl:if>
    		<xsl:value-of select="@type"/>
    		<xsl:if test="c:title">
    			<xsl:text>: </xsl:text>
    			<xsl:apply-templates select="c:title/node()"/>
    		</xsl:if>
    	</db:title>
    	<xsl:apply-templates select="*[local-name()!='title']"/>
    </db:section>
</xsl:template>

<xsl:template match="c:statement">
    <db:section>
    	<xsl:apply-templates select="@*|node()"/>
    </db:section>
</xsl:template>


<xsl:template match="c:para">
    <db:para><xsl:apply-templates select="@*|node()"/></db:para>
</xsl:template>

<xsl:template match="c:caption">
	<db:caption><xsl:apply-templates select="@*|node()"/></db:caption>
</xsl:template>
<xsl:template match="c:title">
	<db:title><xsl:apply-templates select="@*|node()"/></db:title>
</xsl:template>

<xsl:template match="c:sub">
    <db:subscript><xsl:apply-templates select="@*|node()"/></db:subscript>
</xsl:template>
<xsl:template match="c:sup">
    <db:superscript><xsl:apply-templates select="@*|node()"/></db:superscript>
</xsl:template>

<xsl:template match="c:list">
    <db:itemizedlist><xsl:apply-templates select="@*|node()"/></db:itemizedlist>
</xsl:template>
<xsl:template match="c:list[@list-type='labeled-item']">
    <db:orderedlist><xsl:apply-templates select="@*|node()"/></db:orderedlist>
</xsl:template>
<xsl:template match="c:list[@type='enumerated']">
    <db:orderedlist><xsl:apply-templates select="@*|node()"/></db:orderedlist>
</xsl:template>

<xsl:template match="c:emphasis[@effect='bold']">
    <db:emphasis role="bold"><xsl:apply-templates select="@*|node()"/></db:emphasis>
</xsl:template>
<xsl:template match="c:emphasis[not(@effect) or @effect='italics']">
    <db:emphasis><xsl:apply-templates select="@*|node()"/></db:emphasis>
</xsl:template>
<xsl:template match="c:emphasis[@effect and @effect!='italics' and @effect!='bold']">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Removing emphasis with @effect=<xsl:value-of select="@effect"/></xsl:with-param></xsl:call-template>
    <xsl:apply-templates select="@*|node()"/>
</xsl:template>
<xsl:template match="c:emphasis[@effect='normal']">
    <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="c:link[@url]">
    <db:link xlink:href="{@url}"><xsl:apply-templates select="@*|node()"/></db:link>
</xsl:template>

<xsl:template match="c:para//c:code[not(@display='block')]">
    <db:code><xsl:apply-templates select="@*|node()"/></db:code>
</xsl:template>
<xsl:template match="c:preformat|c:code">
    <db:literallayout><xsl:apply-templates select="@*|node()"/></db:literallayout>
</xsl:template>

<xsl:template match="c:quote">
    <db:quote><xsl:apply-templates select="@*|node()"/></db:quote>
</xsl:template>
<xsl:template match="c:quote[@type='block']">
    <db:blockquote><xsl:apply-templates select="@*|node()"/></db:blockquote>
</xsl:template>

<xsl:template match="c:figure[not(c:title) and c:media/c:image]">
	<db:informalfigure><xsl:apply-templates select="@*|node()"/></db:informalfigure>
</xsl:template>
<xsl:template match="c:figure[c:title and c:media/c:image]">
	<db:figure><xsl:apply-templates select="@*|node()"/></db:figure>
</xsl:template>


<!-- Convert CALS Table -->
<xsl:template match="c:table">
	<db:table><xsl:apply-templates select="@*|node()"/></db:table>
</xsl:template>
<xsl:template match="c:tgroup">
	<db:tgroup><xsl:apply-templates select="@*|node()"/></db:tgroup>
</xsl:template>
<xsl:template match="c:thead">
	<db:thead><xsl:apply-templates select="@*|node()"/></db:thead>
</xsl:template>
<xsl:template match="c:tfoot">
	<db:tfoot><xsl:apply-templates select="@*|node()"/></db:tfoot>
</xsl:template>
<xsl:template match="c:tbody">
	<db:tbody><xsl:apply-templates select="@*|node()"/></db:tbody>
</xsl:template>
<xsl:template match="c:colspec">
	<db:colspec><xsl:apply-templates select="@*|node()"/></db:colspec>
</xsl:template>
<xsl:template match="c:row">
	<db:row><xsl:apply-templates select="@*|node()"/></db:row>
</xsl:template>
<xsl:template match="c:entry">
	<db:entry><xsl:apply-templates select="@*|node()"/></db:entry>
</xsl:template>
<xsl:template match="c:entrytbl">
	<db:entrytbl><xsl:apply-templates select="@*|node()"/></db:entrytbl>
</xsl:template>

<!-- Handle citations -->
<xsl:template match="c:cite">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Didn not fully convert c:cite yet</xsl:with-param></xsl:call-template>
	<db:citation>
		<!-- TODO: Treat it like a link....  -->
		<xsl:apply-templates select="@*|node()"/>
	</db:citation>
</xsl:template>
<xsl:template match="c:cite-title">
	<db:citetitle><xsl:apply-templates select="@*|node()"/></db:citetitle>
</xsl:template>
<!-- 
	c: @pub-type (optional): The type of publication cited. May be any of the following: "article", "book", "booklet", "conference",
	   "inbook", "incollection", "inproceedings", "mastersthesis", "manual", "misc", "phdthesis", "proceedings", "techreport", "unpublished".
	db: @pubwork (enumeration)

    * "article"
    * "bbs"
    * "book"
    * "cdrom"
    * "chapter"
    * "dvd"
    * "emailmessage"
    * "gopher"
    * "journal"
    * "manuscript"
    * "newsposting"
    * "part"
    * "refentry"
    * "section"
    * "series"
    * "set"
    * "webpage"
    * "wiki"
 --> 
<xsl:template match="c:cite-title/@pub-type">
	<xsl:variable name="pubwork">
		<xsl:choose>
			<xsl:when test="@pub-type = 'article'">article</xsl:when>
			<xsl:when test="@pub-type = 'book'">book</xsl:when>
			<xsl:when test="@pub-type = 'booklet'">journal</xsl:when>
			<xsl:when test="@pub-type = 'conference'">journal</xsl:when>
			<xsl:when test="@pub-type = 'inbook'">journal</xsl:when>
			<xsl:when test="@pub-type = 'incollection'">webpage</xsl:when>
			<xsl:when test="@pub-type = 'inproceedings'">journal</xsl:when>
			<xsl:when test="@pub-type = 'mastersthesis'">manuscript</xsl:when>
			<xsl:when test="@pub-type = 'phdthesis'">manuscript</xsl:when>
			<xsl:when test="@pub-type = 'proceedings'">journal</xsl:when>
			<xsl:when test="@pub-type = 'techreport'">journal</xsl:when>
			<!--
			<xsl:when test="@pub-type = 'manual'"></xsl:when>
			<xsl:when test="@pub-type = 'misc'"></xsl:when>
			<xsl:when test="@pub-type = 'unpublished'"></xsl:when>
			-->
			<xsl:when test="not(@pub-type)"></xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: Unmatched c:cite-title type</xsl:with-param></xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:if test="$pubwork != ''">
		<xsl:attribute name="pubwork"><xsl:value-of select="$pubwork"/></xsl:attribute>
	</xsl:if>
</xsl:template>


</xsl:stylesheet>