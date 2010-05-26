<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
xmlns:qml="http://cnx.rice.edu/qml/1.0"
  exclude-result-prefixes="c"
  >
<xsl:param name="debugName" select="''"/>

<xsl:output indent="yes"/>

<!-- The h: prefix has been removed from HTML elements because kupu generates namespace-less elements -->


<xsl:include href="cnxml2xhtml.xsl"/>


<!-- h2d.xsl needs a parent html element -->
<xsl:template match="/">
	<html>
    	<xsl:apply-templates select="//c:document"/>
    </html>
</xsl:template>

<!-- Match the roots and add boilerplate -->
<xsl:template match="c:document">
    <body>
    	<h1><xsl:if test="$debugName!=''">[file:<xsl:value-of select="$debugName"/>] </xsl:if>
    	<xsl:if test="$debugName=''">[??? unknown source???] </xsl:if>
    	<xsl:apply-templates select="c:name/text()" /></h1>
        <xsl:apply-templates select="c:content/*"><xsl:with-param name="depth">1</xsl:with-param></xsl:apply-templates>
    </body>
</xsl:template>


<xsl:template match="mml:*">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates/>
	</xsl:copy>
</xsl:template>

<!-- ****************************************
       <c:term>name</c:term> = <a>[name]</a>
     **************************************** -->
<xsl:template match="c:term"><xsl:param name="depth">0</xsl:param>
    <a href="{@url}"><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></a>
</xsl:template>


<xsl:template match="c:link[@url|@document|@target-id|@target]"><xsl:param name="depth">0</xsl:param>
   	<xsl:variable name="href">
   		<xsl:value-of select="@url"/>
   		<xsl:if test="@document">
   			<xsl:value-of select="@document"/>
   			<xsl:text>.dita</xsl:text>
   		</xsl:if>
   		<xsl:if test="@target-id|@target">
   			<xsl:text>#</xsl:text>
   			<xsl:value-of select="@target-id"/>
   			<xsl:if test="@target-id != @target">
   				<xsl:value-of select="@target"/>
   			</xsl:if>
   		</xsl:if>
   	</xsl:variable>
    <a href="{$href}">
    	<xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates>
    </a>
</xsl:template>


<xsl:template match="c:media|c:foreign|qml:*" />

<xsl:template match="c:definition">
	<dl>
		<dt><xsl:apply-templates select="c:term/*"/></dt>
		<xsl:for-each select="c:meaning/*">
			<dd><xsl:apply-templates select="."/></dd>
		</xsl:for-each>
	</dl>
</xsl:template>


<xsl:template match="c:table[@id]">
	<table id="{@id}">
		<tr><td>Row1.1</td><td>Row1.2</td></tr>
		<tr><td>Row2.1</td><td>Row2.2</td></tr>
	</table>
</xsl:template>

<xsl:template match="c:rule[@id]">
	<strong id="{@id}"><xsl:value-of select="local-name(.)"/>:<xsl:value-of select="."/></strong>
</xsl:template>

<!-- Cheat with xhtml headings because I don't want to write a Java processor
for converting h# to nested sections.
Mostly taken from the original xslt
 -->
<!-- ****************************************
       The following are all blockish elements
       that are handled as h# tags with a prefix in the title
     **************************************** -->
<!-- 
<xsl:template match="c:note|c:equation|c:section|c:example|c:exercise|c:problem|c:solution">
    <xsl:param name="depth">0</xsl:param>
    <xsl:variable name="localname">
        <xsl:value-of select="local-name(.)"/>
    </xsl:variable>
    <xsl:variable name="prefix">
        <xsl:call-template name="choose-prefix"/>
    </xsl:variable>
    <xsl:variable name="prefixwithcolon">
        <xsl:value-of select="$prefix"/>
        <xsl:if test="$prefix != ''">: </xsl:if>
    </xsl:variable>
    <div cnx-extra="blockish">
    	<xsl:comment>  mostly pasted from "build-heading" </xsl:comment>
        <xsl:call-template name="copy-attributes-to-html"/>
        <xsl:comment> Create an anchor if it has an @id. This is a kupu thing </xsl:comment>
        <xsl:if test="@id">
        	<a name="{@id}"/>
        </xsl:if>
        <xsl:if test="$prefixwithcolon != '' or c:title or c:name">
        	<div cnx-extra="blockish-title">
		        <xsl:value-of select="$prefixwithcolon"/>
		        <xsl:for-each select="c:title|c:name">
        			<xsl:apply-templates/>
	        	</xsl:for-each>
        	</div>
        </xsl:if>
        
    <xsl:apply-templates select="*|text()|node()|comment()">
        <xsl:with-param name="depth" select="$depth+1"/>
    </xsl:apply-templates>
    </div>
</xsl:template>
-->

<xsl:template match="*">
  <xsl:message>
  	<xsl:if test="$debugName!=''">[file:<xsl:value-of select="$debugName"/>]</xsl:if>
  	<xsl:text>: match not supported for: </xsl:text>
  	<xsl:value-of select="namespace-uri(.)"/>
  	<xsl:text> </xsl:text>
  	<xsl:value-of select="local-name(.)"/>
  	<xsl:for-each select="@*">
	  	<xsl:text> @</xsl:text>
  		<xsl:value-of select="local-name(.)"/>
	  	<xsl:text>="</xsl:text>
  		<xsl:value-of select="."/>
	  	<xsl:text>"</xsl:text>
  	</xsl:for-each>
  </xsl:message>
</xsl:template>
</xsl:stylesheet>
