<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  version="1.0">

<!-- The h: prefix has been removed from HTML elements because kupu generates namespace-less elements -->
<!-- This xslt assumes preprocessing was done to conver h# elements into something that matches
     div[@cnx-extra='blockish']
 -->
<xsl:output omit-xml-declaration="yes" indent="yes" method="xml"/>

<!-- For debugging/development let everything that doesn't match bleed through
     so we can see what (either cnxml or html) was not matched.
     -->
<!--xsl:template match="*|c:*">
    <xsl:copy>
        <xsl:apply-templates select="node()"/>
    </xsl:copy>
</xsl:template-->
<xsl:template mode="copy" match="@*|node()|comment()">
    <xsl:copy>
        <xsl:apply-templates mode="copy" select="@*|node()|comment()"/>
    </xsl:copy>
</xsl:template>

<!-- Boilerplate -->
<xsl:template match="/">
    <xsl:apply-templates select="//c:document/c:content|/body"/>
</xsl:template>
<!-- Match the roots and add boilerplate -->
<xsl:template match="c:content">
    <body>
        <xsl:apply-templates select="*"/>
    </body>
</xsl:template>
<xsl:template match="body">
    <c:document>
    	<c:content>
        	<xsl:apply-templates />
    	</c:content>
    </c:document>
</xsl:template>

<!-- Convert mml:* to a kupu-friendly dfn/CDATA section and back -->
<xsl:template match="mml:*">
    <dfn>
            <xsl:text disable-output-escaping="yes">&lt;!--[CDATA[</xsl:text>
            <xsl:copy>
                <xsl:apply-templates mode="math" select="*|@*|node()|comment()"/>
            </xsl:copy>
            <xsl:text>]]--></xsl:text>
        [MathML]
        <!--xsl:comment>[CDATA[<xsl:apply-templates mode="math" select="."/>]]</xsl:comment-->
    </dfn>
</xsl:template>
<xsl:template mode="math" match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates mode="math" select="@*|node()|comment()"/>
    </xsl:copy>
</xsl:template>
<xsl:template match="dfn">
    <!-- kupu converts the CDATA section to a comment starting with [CDATA[
        but it appears that the builtin python SAX parser does not 
        support comments. -->
    <xsl:variable name="comment"><xsl:value-of select="string(comment())" /></xsl:variable>
    <debug><xsl:copy-of select="."/></debug>
    <!-- If it's a kupu-contrived comment, strip the "[CDATA[" and "]]" (that's what the 8 and 9 are for in the value-of -->
    <xsl:if test="starts-with($comment, '[CDATA[') and substring($comment, string-length($comment)-1) = ']]'">
        <xsl:value-of select="substring($comment, 8, string-length($comment)-9)" disable-output-escaping="yes"/>
    </xsl:if>
    <!--xsl:value-of select="string(text())" disable-output-escaping="yes"/-->
    <!--xsl:apply-templates mode="math" select="mml:*"/-->
</xsl:template>


<xsl:template name="copy-attributes-to-html">
    <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@type">
        <xsl:attribute name="class">type_<xsl:value-of select="@type"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@start-value">
        <xsl:attribute name="class">start-value_<xsl:value-of select="@start-value"/></xsl:attribute>
    </xsl:if>
</xsl:template>
<xsl:template name="copy-attributes-to-cnxml">
    <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="contains(@class,'type_')">
        <xsl:variable name="type1"><xsl:value-of select="substring-after(@class, 'type_')"/></xsl:variable>
        <xsl:variable name="type2"><xsl:choose>
                <xsl:when test="contains($type1, ' ')"><xsl:value-of select="substring-before($type1, ' ')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$type1"/></xsl:otherwise>
            </xsl:choose></xsl:variable>
        <xsl:attribute name="type"><xsl:value-of select="$type2"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="contains(@class,'start-value_')">
        <xsl:variable name="type1"><xsl:value-of select="substring-after(@class, 'start-value_')"/></xsl:variable>
        <xsl:variable name="type2"><xsl:choose>
                <xsl:when test="contains($type1, ' ')"><xsl:value-of select="substring-before($type1, ' ')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$type1"/></xsl:otherwise>
            </xsl:choose></xsl:variable>
        <xsl:attribute name="start-value"><xsl:value-of select="$type2"/></xsl:attribute>
    </xsl:if>
    <!-- c:note has subtypes (like Warning). In those cases, set the attr -->
    <xsl:variable name="start" select="substring-before(text()[1], ':')"/>
    <xsl:if test="'Warning'=substring-before($start,':')">
        <xsl:attribute name="type">warning</xsl:attribute>
    </xsl:if>
</xsl:template>

<xsl:template name="build-heading"><xsl:param name="depth"/><xsl:param name="prefix"/>
    <xsl:element name="h{$depth}">
        <xsl:call-template name="copy-attributes-to-html"/>
        <!-- Create an anchor if it has an @id -->
        <xsl:if test="@id">
        	<a name="{@id}"/>
        </xsl:if>
        <xsl:value-of select="$prefix"/>
        <xsl:apply-templates select="c:title|c:name" mode="title-mode"/>
    </xsl:element></xsl:template>

<!-- c:name is cnxml 0.5 -->
<xsl:template mode="title-mode" match="c:title|c:name">
    <xsl:apply-templates select="node()|comment()"/>
</xsl:template>
<xsl:template match="c:title|c:name" />


<!-- Convert c:para to p or, if it contains blockish elements, a div -->
<xsl:template match="c:para"><xsl:param name="depth">0</xsl:param>
    <xsl:variable name="elementname"><xsl:choose>
        <xsl:when test="c:figure[not(c:subfigure or c:table or c:code) and c:media/c:image and (not(c:title) or not(c:title/*))]">p</xsl:when>
        <xsl:when test="c:section|c:para|c:example|c:exercise|c:rule|c:definition|c:quote|c:note|c:figure">div</xsl:when>
        <xsl:otherwise>p</xsl:otherwise>
    </xsl:choose></xsl:variable>
    <xsl:element name="{$elementname}"><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></xsl:element>
</xsl:template>
<xsl:template match="p"><xsl:param name="depth">0</xsl:param>
    <c:para><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:para>
</xsl:template>
<xsl:template match="div[not(@cnx-extra)]"><xsl:param name="depth">0</xsl:param>
    <c:para><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:para>
</xsl:template>


<xsl:template match="c:sub"><xsl:param name="depth">0</xsl:param>
    <sub><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></sub>
</xsl:template>
<xsl:template match="sub"><xsl:param name="depth">0</xsl:param>
    <c:sub><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:sub>
</xsl:template>

<xsl:template match="c:sup"><xsl:param name="depth">0</xsl:param>
    <sup><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></sup>
</xsl:template>
<xsl:template match="sup"><xsl:param name="depth">0</xsl:param>
    <c:sup><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:sup>
</xsl:template>


<xsl:template match="c:list"><xsl:param name="depth">0</xsl:param>
    <ul><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></ul>
</xsl:template>
<xsl:template match="ul"><xsl:param name="depth">0</xsl:param>
    <c:list><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:list>
</xsl:template>


<xsl:template match="c:list[@list-type='enumerated']"><xsl:param name="depth">0</xsl:param>
    <ol><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></ol>
</xsl:template>
<xsl:template match="ol"><xsl:param name="depth">0</xsl:param>
    <c:list list-type="enumerated"><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:list>
</xsl:template>


<xsl:template match="c:item"><xsl:param name="depth">0</xsl:param>
    <li><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></li>
</xsl:template>
<xsl:template match="li"><xsl:param name="depth">0</xsl:param>
    <c:item><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:item>
</xsl:template>


<!-- ****************************************
       <c:emphasis effect="">text</c:emphasis> = <strong/><em/><u/><strike/>
     **************************************** -->

<xsl:template match="c:emphasis[not(@effect) or @effect='bold']"><xsl:param name="depth">0</xsl:param>
    <strong><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></strong>
</xsl:template>
<!-- kupu for some reason uses <span style='font-weight: bold;'/> instead of strong when the bold button is pressed. -->
<xsl:template match="strong|span[@style='font-weight: bold;']"><xsl:param name="depth">0</xsl:param>
    <c:emphasis><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:emphasis>
</xsl:template>

<xsl:template match="c:emphasis[@effect='italics']"><xsl:param name="depth">0</xsl:param>
    <em><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></em>
</xsl:template>
<xsl:template match="em"><xsl:param name="depth">0</xsl:param>
    <c:emphasis effect="italics"><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:emphasis>
</xsl:template>

<xsl:template match="c:emphasis[@effect='underline']"><xsl:param name="depth">0</xsl:param>
    <u><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></u>
</xsl:template>
<xsl:template match="u"><xsl:param name="depth">0</xsl:param>
    <c:emphasis effect="underline"><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:emphasis>
</xsl:template>

<xsl:template match="c:emphasis[@effect='smallcaps']"><xsl:param name="depth">0</xsl:param>
    <strike><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></strike>
</xsl:template>
<xsl:template match="strike"><xsl:param name="depth">0</xsl:param>
    <c:emphasis effect="smallcaps"><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:emphasis>
</xsl:template>


<!-- ****************************************
       <c:definition><c:term/><c:meaning /></c:definition> = <dl><dt/><dd/></dl>
     **************************************** -->

<xsl:template match="c:definition[not(c:example)]"><xsl:param name="depth">0</xsl:param>
    <dl><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></dl>
</xsl:template>
<xsl:template match="dl"><xsl:param name="depth">0</xsl:param>
    <c:definition><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:definition>
</xsl:template>

<xsl:template match="c:definition/c:term"><xsl:param name="depth">0</xsl:param>
    <dt><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></dt>
</xsl:template>
<xsl:template match="dt"><xsl:param name="depth">0</xsl:param>
    <c:term><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:term>
</xsl:template>

<xsl:template match="c:definition/c:meaning"><xsl:param name="depth">0</xsl:param>
    <dd><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></dd>
</xsl:template>
<xsl:template match="dd"><xsl:param name="depth">0</xsl:param>
    <c:meaning><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:meaning>
</xsl:template>



<!-- ****************************************
       <c:link>name</c:link> = <a>name</a>
     **************************************** -->
<xsl:template match="c:link[@url]"><xsl:param name="depth">0</xsl:param>
    <a href="{@url}"><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></a>
</xsl:template>
<xsl:template match="a[@href and not(starts-with(text(),'[') and substring(text(),string-length(text())) = ']')]"><xsl:param name="depth">0</xsl:param>
    <c:link url="{@href}"><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:link>
</xsl:template>


<!-- ****************************************
       <c:term>name</c:term> = <a>[name]</a>
     **************************************** -->
<xsl:template match="c:term"><xsl:param name="depth">0</xsl:param>
    <a href="{@url}"><xsl:call-template name="copy-attributes-to-html"/>[<xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates>]</a>
</xsl:template>
<xsl:template match="a[starts-with(text(),'[') and substring(text(),string-length(text())) = ']']"><xsl:param name="depth">0</xsl:param>
    <c:term><xsl:if test="@href"><xsl:attribute name="url"><xsl:value-of select="@href"/></xsl:attribute></xsl:if><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:value-of select="substring(text(),2,string-length(text())-2)"/><!-- xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates --></c:term>
</xsl:template>


<!-- ****************************************
       <c:code>text</c:code> = <code>text</code>
     **************************************** -->
<xsl:template match="c:code"><xsl:param name="depth">0</xsl:param>
    <code><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></code>
</xsl:template>
<xsl:template match="code"><xsl:param name="depth">0</xsl:param>
    <c:code><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:code>
</xsl:template>


<!-- ****************************************
       <c:quote>text</c:quote> = <blockquote>text</blockquote>
     **************************************** -->
<xsl:template match="c:quote"><xsl:param name="depth">0</xsl:param>
    <blockquote><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></blockquote>
</xsl:template>
<xsl:template match="blockquote"><xsl:param name="depth">0</xsl:param>
    <c:quote><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:quote>
</xsl:template>


<!-- ****************************************
       <c:cite>text</c:cite> = <cite>text</cite>
       Note: I haven't found any modules that use c:cite-title yet
     **************************************** -->
<xsl:template match="c:cite"><xsl:param name="depth">0</xsl:param>
    <cite><xsl:call-template name="copy-attributes-to-html"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></cite>
</xsl:template>
<xsl:template match="cite"><xsl:param name="depth">0</xsl:param>
    <c:cite><xsl:call-template name="copy-attributes-to-cnxml"/><xsl:apply-templates select="*|text()|node()|comment()"><xsl:with-param name="depth" select="$depth"/></xsl:apply-templates></c:cite>
</xsl:template>


<!-- ****************************************
        A simple c:figure = img
        By simple, I mean:
        * only a c:media (no c:subfigure, c:table, c:code)
        * only a c:image in the c:media (no c:audio, c:flash, c:video, c:text, c:java-applet, c:labview, c:download)
        * no c:caption
        * c:title cannot have xml elements in it, just text
     **************************************** -->
<xsl:template match="c:figure[not(c:subfigure or c:table or c:code) and c:media/c:image and (not(c:title) or not(c:title/*))]"><xsl:param name="depth">0</xsl:param>
    <img title="{c:caption/text()}" 
        alt="{c:media/@alt}" 
        src="{c:media/c:image/@src}" 
        height="{c:media/c:image/@height}" 
        width="{c:media/c:image/@width}"><xsl:call-template name="copy-attributes-to-html"/>
     </img>
</xsl:template>
<xsl:template match="img"><xsl:param name="depth">0</xsl:param>
    <c:figure><xsl:call-template name="copy-attributes-to-cnxml"/>
        <xsl:if test="@title">
            <c:caption><xsl:value-of select="@title"/></c:caption>
        </xsl:if>
        <c:media alt="{@alt}">
            <c:image src="{@src}" height="{@height}" width="{@width}"/>
        </c:media>
    </c:figure>
</xsl:template>



<!-- ****************************************
       The following are all blockish elements
       that are handled as h# tags with a prefix in the title
     **************************************** -->
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
    <xsl:call-template name="build-heading">
        <xsl:with-param name="depth" select="$depth+1"/>
        <xsl:with-param name="prefix" select="$prefixwithcolon"/>
    </xsl:call-template>
    <xsl:apply-templates select="*|text()|node()|comment()">
        <xsl:with-param name="depth" select="$depth+1"/>
    </xsl:apply-templates>
</xsl:template>




<!-- ***************************************************************
        Templates that convert between prefixed titles of headings to
        c:notes, c:examples, etc.
     *************************************************************** -->
<xsl:template name="choose-prefix">
    <xsl:param name="name">
        <xsl:value-of select="local-name(.)"/>
    </xsl:param>
    <xsl:choose>
        <xsl:when test="$name='equation'">Equation</xsl:when>
        <xsl:when test="$name='example'">Example</xsl:when>
        <xsl:when test="$name='exercise'">Exercise</xsl:when>
        <xsl:when test="$name='problem'">Problem</xsl:when>
        <xsl:when test="$name='proof'">Proof</xsl:when>
        <xsl:when test="$name='solution'">Solution</xsl:when>
        <!-- There are many subtypes for c:note -->
        <xsl:when test="$name='note' and @type='warning'">Warning</xsl:when>
        <xsl:when test="$name='note'">Note</xsl:when>
        <xsl:otherwise><!-- Section --></xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template name="choose-element-name"><xsl:param name="title"/>
    <xsl:variable name="start" select="normalize-space(substring-before($title, ':'))"/>
    <xsl:choose>
        <xsl:when test="$start='Equation'">equation</xsl:when>
        <xsl:when test="$start='Example'">example</xsl:when>
        <xsl:when test="$start='Exercise'">exercise</xsl:when>
        <xsl:when test="$start='Problem'">problem</xsl:when>
        <xsl:when test="$start='Proof'">proof</xsl:when>
        <xsl:when test="$start='Solution'">solution</xsl:when>
        <xsl:when test="$start='Warning'">note</xsl:when>
        <xsl:when test="$start='Note'">note</xsl:when>
        <xsl:otherwise>section</xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="div[@cnx-extra='blockish']">
    <xsl:variable name="heading"><xsl:value-of select="div[@cnx-extra='blockish-title']/text()"/></xsl:variable>
    <xsl:variable name="elname"><xsl:call-template name="choose-element-name"><xsl:with-param name="title" select="$heading"/></xsl:call-template></xsl:variable>
    <xsl:element name="c:{$elname}">
        <xsl:call-template name="copy-attributes-to-cnxml"/>
        <!-- Handle anchors (a/@name becomes the @id) -->
        <xsl:if test="a[@name]">
        	<xsl:attribute name="id"><xsl:value-of select="a/@name"/></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="*[not(@name)]|text()"/><!-- Skip anchors -->
    </xsl:element>
</xsl:template>
<xsl:template match="div[@cnx-extra='blockish-title']">
    <xsl:variable name="titletext">
        <xsl:choose>
            <xsl:when test="contains(text()[1],':')">
                <xsl:value-of select="substring-after(text()[1],':')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text()[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="normalize-space($titletext) != '' or count(*)!=0">
    <c:title>
        <xsl:call-template name="copy-attributes-to-cnxml"/>
        <!-- For this, we need to translate ALL the nodes, and just strip the Prefix from the 1st node -->
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="position()=1 and contains(., ': ')">
                    <xsl:value-of select="substring-after(., ': ')"/>
                </xsl:when>
                <xsl:when test="position()=1 and contains(., ':')">
                    <xsl:value-of select="substring-after(., ':')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </c:title>
    </xsl:if>
</xsl:template>


<xsl:template match="comment()">
    <xsl:copy-of select="."/>comment
</xsl:template>


</xsl:stylesheet>
