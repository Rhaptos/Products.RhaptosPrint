<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  version="1.0">

<xsl:import href="mdml2dbk.xsl"/>
<xsl:import href="cnxml2dbk-simple.xsl"/>
<xsl:output indent="yes" method="xml"/>

<!-- Used to update the ids so they are unique within a collection -->
<xsl:param name="cnx.module.id"/>

<!-- When generating id's we need to prefix them with a module id. 
	This is the text between the module, and the module-specific id. -->
<xsl:param name="cnx.module.separator">.</xsl:param>

<!-- HACK: FOP generation requires that db:imagedata be missing but epub/html needs it -->
<xsl:param name="cnx.output">fop</xsl:param>


<xsl:template mode="copy" match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates mode="copy" select="@*|node()"/>
    </xsl:copy>
</xsl:template>

<!-- Boilerplate -->
<xsl:template match="/">
	<xsl:apply-templates select="*"/>
</xsl:template>

<!-- Prefix all id's with the module id (for inclusion in collection) -->
<xsl:template match="@id">
	<xsl:attribute name="xml:id">
		<xsl:value-of select="$cnx.module.id"/>
		<xsl:value-of select="$cnx.module.separator"/>
		<xsl:value-of select="."/>
	</xsl:attribute>
</xsl:template>
<!-- Bug. can't replace @id with xsl:attribute if other attributes have already converted using xsl:copy -->
<xsl:template match="@*">
	<xsl:attribute name="{local-name(.)}"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@url|@type|@src|@format|@alt"/>

<!-- Match the roots and add boilerplate -->
<xsl:template match="c:document">
    <db:section>
    	<xsl:attribute name="xml:id"><xsl:value-of select="$cnx.module.id"/></xsl:attribute>
        <db:info>
        	<xsl:apply-templates select="c:title"/>
        	<xsl:apply-templates select="c:metadata"/>
        </db:info>
        
        <xsl:apply-templates select="c:content/*"/>
        <!--TODO: Figure out when to move the exercises
        <xsl:if test=".//c:section/c:exercise or c:exercise">
        	<db:qandaset>
        		<xsl:apply-templates mode="end-of-module" select=".//c:section/c:exercise | c:exercise"/>
        	</db:qandaset>
        </xsl:if>-->
        <xsl:apply-templates select="c:glossary"/>
    </db:section>
</xsl:template>


<xsl:template match="c:para[c:title]">
    <db:formalpara>
		<xsl:apply-templates select="@*|c:title"/>
		<db:para>
			<xsl:apply-templates select="*[local-name()!='title']|text()|processing-instruction()|comment()"/>
		</db:para>
	</db:formalpara>
</xsl:template>


<xsl:template match="c:list[@list-type='enumerated' or 	@number-style]">
	<xsl:variable name="numeration">
		<xsl:choose>
    		<xsl:when test="not(@number-style) or @number-style='arabic'">arabic</xsl:when>
			<xsl:when test="@number-style='upper-alpha'">upperalpha</xsl:when>
			<xsl:when test="@number-style='lower-alpha'">loweralpha</xsl:when>
			<xsl:when test="@number-style='upper-roman'">upperroman</xsl:when>
			<xsl:when test="@number-style='lower-roman'">lowerroman</xsl:when>
    		<xsl:otherwise>
    			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Unsupported @number-style</xsl:with-param></xsl:call-template>
    			<xsl:text>arabic</xsl:text>
    		</xsl:otherwise>
    	</xsl:choose>
	</xsl:variable>		
    <db:orderedlist numeration="{$numeration}"><xsl:apply-templates select="@*|node()"/></db:orderedlist>
</xsl:template>


<xsl:template match="c:list[@display='inline']">
	<xsl:for-each select="c:item">
		<xsl:if test="position()!=1">; </xsl:if>
    	<xsl:apply-templates select="*|text()|node()|comment()"/>
    </xsl:for-each>
</xsl:template>


<xsl:template match="c:item">
    <db:listitem>
    	<xsl:choose>
    		<xsl:when test="c:title">
    			<db:formalpara>
    				<xsl:apply-templates select="@*|*[local-name(.)!='para']|text()|node()|comment()"/>
    			</db:formalpara>
    			<xsl:apply-templates select="c:para"/>
    		</xsl:when>
    		<xsl:when test="c:para">
				<xsl:apply-templates select="@*|node()"/>
    		</xsl:when>
    		<xsl:otherwise>
		    	<db:para>
					<xsl:apply-templates select="@*|node()"/>
				</db:para>
			</xsl:otherwise>
		</xsl:choose>
    </db:listitem>
</xsl:template>


<xsl:template match="c:link[@document|@target-id and normalize-space(text())='']">
	<xsl:variable name="linkend">
		<xsl:if test="not(@document)"><xsl:value-of select="$cnx.module.id"/></xsl:if>
		<xsl:value-of select="@document"/>
		<xsl:if test="@target-id"><xsl:value-of select="$cnx.module.separator"/></xsl:if>
		<xsl:value-of select="@target-id"/>
	</xsl:variable>
    <db:xref linkend="{$linkend}"><xsl:apply-templates select="@*|node()"/></db:xref>
</xsl:template>
<xsl:template match="c:link[@document|@target-id and normalize-space(text())!='']">
	<xsl:variable name="linkend">
		<xsl:if test="not(@document)"><xsl:value-of select="$cnx.module.id"/></xsl:if>
		<xsl:value-of select="@document"/>
		<xsl:if test="@target-id"><xsl:value-of select="$cnx.module.separator"/></xsl:if>
		<xsl:value-of select="@target-id"/>
	</xsl:variable>
    <db:link linkend="{$linkend}"><xsl:apply-templates select="@*|node()"/></db:link>
</xsl:template>


<!-- ****************************************
        A simple c:figure = img
        By simple, I mean:
        * only a c:media (no c:subfigure, c:table, c:code)
        * only a c:image in the c:media (no c:audio, c:flash, c:video, c:text, c:java-applet, c:labview, c:download)
        * no c:caption
        * c:title cannot have xml elements in it, just text
     **************************************** -->
<xsl:template match="c:media[c:image]">
	<db:mediaobject><xsl:call-template name="media.image"/></db:mediaobject>
</xsl:template>
<!-- See m21854 //c:equation/@id="eip-id14423064" -->
<xsl:template match="c:para//c:media[c:image]">
	<db:inlinemediaobject><xsl:call-template name="media.image"/></db:inlinemediaobject>
</xsl:template>
<!-- see m0003 -->
<xsl:template name="media.image">
	<xsl:apply-templates select="@*"/>
	<!-- Pick the correct image. To get Music Theory to use the included SVG file, 
	     we try to xinclude it here and then remove the xinclude in the cleanup phase.
	 -->
	<xsl:apply-templates select="c:image[contains(@src, '.eps')]"/>
	<xsl:choose>
	 	<xsl:when test="c:image[@mime-type != 'application/postscript' and not(contains(@src, '.eps')) and @for = 'pdf']">
	 		<xsl:apply-templates select="c:image[@mime-type != 'application/postscript' and not(contains(@src, '.eps')) and @for = 'pdf']"/>
	 	</xsl:when>
	 	<xsl:when test="c:image[@mime-type != 'application/postscript' and not(contains(@src, '.eps'))]">
	 		<xsl:apply-templates select="c:image[@mime-type != 'application/postscript' and not(contains(@src, '.eps'))]"/>
	 	</xsl:when>
		<xsl:when test="c:image[contains(@src, '.eps')]">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: No suitable image found. Hoping that a SVG file with the same name as the EPS file exists</xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: No suitable image found.</xsl:with-param></xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="c:image[@src]">
	<xsl:variable name="ext" select="substring-after(substring(@src, string-length(@src) - 5), '.')"/>
	<xsl:variable name="format">
		<xsl:choose>
			<xsl:when test="$ext='jpg' or $ext='jpeg' or @mime-type = 'image/jpeg'">JPEG</xsl:when>
			<xsl:when test="$ext='gif' or @mime-type = 'image/gif'">GIF</xsl:when>
			<xsl:when test="$ext='png' or @mime-type = 'image/png'">PNG</xsl:when>
			<xsl:when test="$ext='svg' or @mime-type = 'image/svg+xml'">SVG</xsl:when>
			<!-- Hack for Music Theory. Kitty stores the .epc and .svg files -->
			<xsl:when test="@mime-type = 'application/postscript'">SVG</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: Could not match mime-type. Assuming JPEG.</xsl:with-param></xsl:call-template>
				<xsl:text>JPEG</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<db:imageobject format="{$format}">
		<!-- Make sure imageobject has an id. Used when converting svg to png -->
		<xsl:attribute name="xml:id">
			<xsl:value-of select="$cnx.module.id"/>
			<xsl:value-of select="$cnx.module.separator"/>
			<xsl:value-of select="generate-id(.)"/>
		</xsl:attribute>
		
		<db:imagedata fileref="{@src}">
			<xsl:choose>
				<xsl:when test="@print-width">
					<xsl:attribute name="width"><xsl:value-of select="@print-width"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="@width">
					<xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="@height">
				<xsl:attribute name="depth"><xsl:value-of select="@height"/></xsl:attribute>
			</xsl:if>
		</db:imagedata>
	</db:imageobject>
</xsl:template>

<xsl:template match="c:image[contains(@src, '.eps')]">
	<db:imageobject format="SVG">
		<!-- Make sure imageobject has an id. Used when converting svg to png -->
		<xsl:attribute name="xml:id">
			<xsl:value-of select="$cnx.module.id"/>
			<xsl:value-of select="$cnx.module.separator"/>
			<xsl:value-of select="generate-id(.)"/>
		</xsl:attribute>
		<db:imagedata>
			<xsl:choose>
				<xsl:when test="@print-width">
					<xsl:attribute name="width"><xsl:value-of select="@print-width"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="@width">
					<xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="@height">
				<xsl:attribute name="depth"><xsl:value-of select="@height"/></xsl:attribute>
			</xsl:if>
			
			<xsl:variable name="href">
				<xsl:value-of select="substring-before(@src, '.eps')"/>
				<xsl:text>.svg</xsl:text>
			</xsl:variable>
			<xi:include href="{$href}" xmlns:xi="http://www.w3.org/2001/XInclude"/>
		</db:imagedata>
	</db:imageobject>
</xsl:template>


<xsl:template match="c:exercise">
	<db:qandaset role="none">
	<db:qandaentry>
		<xsl:apply-templates select="@*|node()"/>
	</db:qandaentry>
	</db:qandaset>
</xsl:template>
<xsl:template match="c:problem">
	<db:question><xsl:apply-templates select="@*|node()"/></db:question>
</xsl:template>
<xsl:template match="c:solution">
	<db:answer><xsl:apply-templates select="@*|node()"/></db:answer>
</xsl:template>

<xsl:template match="c:foreign">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Ignoring c:foreign element for conversion</xsl:with-param></xsl:call-template>
	<xsl:apply-templates/>
</xsl:template>

<!-- MathML -->
<xsl:template match="c:equation/mml:math">
	<db:mediaobject><xsl:call-template name="insert-mathml"/></db:mediaobject>
</xsl:template>
<xsl:template match="mml:math">
	<db:inlinemediaobject><xsl:call-template name="insert-mathml"/></db:inlinemediaobject>
</xsl:template>

<xsl:template name="insert-mathml">
	<db:imageobject>
		<!-- Make sure imageobject has an id. Used when converting svg to png -->
		<xsl:attribute name="xml:id">
			<xsl:value-of select="$cnx.module.id"/>
			<xsl:value-of select="$cnx.module.separator"/>
			<xsl:value-of select="generate-id(.)"/>
		</xsl:attribute>
		<!-- HACK: FOP generation requires that db:imagedata be missing -->
		<xsl:choose>
			<xsl:when test="$cnx.output = 'fop'">
				<xsl:apply-templates mode="copy" select="."/>
			</xsl:when>
			<xsl:otherwise>
				<db:imagedata format="svg"> 
					<xsl:apply-templates mode="copy" select="."/>
				</db:imagedata>
			</xsl:otherwise>
		</xsl:choose>
	</db:imageobject>
</xsl:template>



<!-- Partially supported -->
<xsl:template match="c:figure[c:subfigure]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Splitting subfigures into multiple figures</xsl:with-param></xsl:call-template>
	<db:section>
		<xsl:apply-templates select="@*|node()"/>
	</db:section>
</xsl:template>

<xsl:template match="c:figure|c:subfigure">
	<db:figure>
		<xsl:apply-templates select="@*|node()"/>
	</db:figure>
</xsl:template>




<xsl:template match="c:document/c:title">
	<db:title>
		<xsl:apply-templates select="@*|node()"/>
		<!-- TODO: Remove debugging line. -->
		<xsl:text> [</xsl:text>
		<xsl:value-of select="$cnx.module.id"/>
		<xsl:text>]</xsl:text>
	</db:title>
</xsl:template>


<!-- Match glossary stuff. TODO: A free-standing definition (not in a glossary)
     should continue to appear in-line but should be numbered.
     TODO: A glossary definition should be in a top-level glossary and then later
     turned into a single db:glossary at the end of a book.
 -->
<xsl:template match="c:glossary">
	<db:glossary>
		<xsl:apply-templates select="@*|node()"/>
	</db:glossary>
</xsl:template>
<xsl:template match="c:glossary/c:definition">
	<db:glossentry>
		<xsl:apply-templates select="@*"/>
		<xsl:if test="c:title">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Dropping c:title in c:definition</xsl:with-param></xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="c:term"/>
		<db:glossdef>
			<xsl:apply-templates select="*[preceding-sibling::c:term]"/>
		</db:glossdef>
	</db:glossentry>
</xsl:template>

<!-- According to eip-help/definition. Can be inline, and not in a c:glossary -->
<xsl:template match="c:definition">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: Inline defined terms and term definitions are not yet numbered.</xsl:with-param></xsl:call-template>
	<db:glosslist>
		<xsl:if test="c:title">
			<xsl:apply-templates select="c:title"/>
		</xsl:if>
		<db:glossentry>
			<xsl:apply-templates select="@*|c:term"/>
			<db:glossdef>
				<xsl:apply-templates select="*[preceding-sibling::c:term]"/>
			</db:glossdef>
		</db:glossentry>
	</db:glosslist>
</xsl:template>
<xsl:template match="c:definition/c:meaning">
	<db:para><xsl:apply-templates select="@*|node()"/></db:para>
</xsl:template>

<xsl:template match="c:term[not(@url)]">
	<db:glossterm><xsl:apply-templates select="@*|node()"/></db:glossterm>
</xsl:template>

<xsl:template match="c:term[@document|@target-id]">
	<xsl:variable name="linkend">
		<xsl:if test="not(@document)"><xsl:value-of select="$cnx.module.id"/></xsl:if>
		<xsl:value-of select="@document"/>
		<xsl:if test="@target-id"><xsl:value-of select="$cnx.module.separator"/></xsl:if>
		<xsl:value-of select="@target-id"/>
	</xsl:variable>
    <db:glossterm linkend="{$linkend}"><xsl:apply-templates select="@*|node()"/></db:glossterm>
</xsl:template>


<!-- Add a processing instruction that will be matched in the custom docbook2fo.xsl -->
<xsl:template match="c:newline">
	<xsl:processing-instruction name="cnx.newline"/>
</xsl:template>

<xsl:template match="c:space[@effect='underline']">
	<xsl:call-template name="cnx.space.loop">
		<xsl:with-param name="char">_</xsl:with-param>
		<xsl:with-param name="count" select="@count"/>
	</xsl:call-template>
</xsl:template>
<xsl:template name="cnx.space.loop">
	<xsl:param name="char"/>
	<xsl:param name="count">0</xsl:param>
	<xsl:if test="$count != 0">
		<xsl:value-of select="$char"/>
		<xsl:call-template name="cnx.space.loop">
			<xsl:with-param name="char" select="$char"/>
			<xsl:with-param name="count" select="$count - 1"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Add metadata like authors, an abstract, etc -->
<xsl:template match="c:metadata">
	<xsl:apply-templates/>
</xsl:template>


</xsl:stylesheet>
