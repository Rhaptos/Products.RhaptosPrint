<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file is run once all modules are converted and once all module dbk files are XIncluded.
	It:
	* unwraps a module (whose root is db:section) and puts it in a db:preface, db:chapter, db:section
	* puts in empty db:title elements for informal equations (TODO: Not sure why, maybe for labeling and linking)
	//* generates a book-wide glossary instead of a module-wide one (and marks each glossary section with a letter)
	* Converts links to content not included in the book to external links
 -->

<xsl:import href="param.xsl"/>
<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:output indent="yes" method="xml"/>

<!-- Collapse XIncluded modules -->
<xsl:template match="db:chapter[count(db:section)=1]|db:preface[count(db:section)=1]|db:appendix[count(db:section)=1]|db:section[@document and count(db:section)=1]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Converting module to <xsl:value-of select="local-name()"/></xsl:with-param></xsl:call-template>
	<xsl:copy>
		<xsl:apply-templates select="@*|db:section/@*"/>
		<xsl:element name="db:{local-name()}info">
			<xsl:apply-templates select="db:title"/>
			<xsl:apply-templates select="db:section/db:sectioninfo/node()"/>
		</xsl:element>
		<xsl:apply-templates select="db:section/node()[local-name()!='sectioninfo']"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="db:*[(local-name()='preface' or local-name()='chapter' or local-name()='appendix' or local-name()='section') and db:title and count(db:section)=1]/db:section/db:sectioninfo/db:title">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding original title</xsl:with-param></xsl:call-template>
</xsl:template>



<!-- Boilerplate -->
<xsl:template match="/">
	<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="db:informalequation">
	<db:equation>
		<xsl:apply-templates select="@*"/>
		<db:title/>
		<xsl:apply-templates select="node()"/>
	</db:equation>
</xsl:template>

<xsl:template match="db:informalexample">
	<db:example>
		<xsl:apply-templates select="@*"/>
		<db:title/>
		<xsl:apply-templates select="node()"/>
	</db:example>
</xsl:template>

<xsl:template match="db:informalfigure">
	<db:figure>
		<xsl:apply-templates select="@*"/>
		<db:title/>
		<xsl:apply-templates select="node()"/>
	</db:figure>
</xsl:template>



<!-- Combine all module glossaries into a single book glossary -->
<xsl:template match="db:book">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
<!-- DEAD: Removed in favor of module-level glossaries
		<xsl:if test="//db:glossentry">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: creating</xsl:with-param></xsl:call-template>
			<db:glossary>
				<xsl:variable name="letters">
					<xsl:apply-templates mode="glossaryletters" select="//db:glossentry/@ext:first-letter">
						<xsl:sort select="."/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: letters="<xsl:value-of select="$letters"/>"</xsl:with-param></xsl:call-template>
				<xsl:call-template name="cnx.glossary">
					<xsl:with-param name="letters" select="$letters"/>
				</xsl:call-template>
			</db:glossary>
		</xsl:if>
-->
	</xsl:copy>
</xsl:template>
<!-- DEAD: Removed in favor of module-level glossaries
<xsl:template mode="glossaryletters" match="@*">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template name="cnx.glossary">
	<xsl:param name="letters"/>
	<xsl:variable name="letter" select="substring($letters, 1, 1)"/>
	
	<!- - Skip all duplicates of letters until the last one, which we process - ->
	<xsl:if test="string-length($letters) = 1 or $letter != substring($letters,2,1)">
		<db:glossdiv>
			<db:title><xsl:value-of select="$letter"/></db:title>
			<xsl:apply-templates select="//db:glossentry[@ext:first-letter=$letter]">
				<xsl:sort select="concat(db:glossterm/text(), db:glossterm//text())"/>
			</xsl:apply-templates>
		</db:glossdiv>
	</xsl:if>

	<xsl:if test="string-length($letters) > 1">
		<xsl:call-template name="cnx.glossary">
			<xsl:with-param name="letters" select="substring($letters, 2)"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>
<!- - Discard the @ext:first-letter attribute since it's no longer needed - ->
<xsl:template match="@ext:first-letter">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: Writing out an entry whose first letter is "<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
</xsl:template>

<!- - Discard the module-level glossary - ->
<xsl:template match="db:glossary">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding module-level glossary and combining into book-level glossary</xsl:with-param></xsl:call-template>
</xsl:template>
-->

<!-- Make links to unmatched ids external -->
<xsl:template match="db:xref[@document]|db:link[@document]">
	<xsl:choose>
		<!-- if the target (or module) is in the document, then all is well -->
		<xsl:when test="id(@linkend) or id(@document)">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="url">
				<xsl:value-of select="$cnx.url"/>
				<xsl:value-of select="@document"/>
				<xsl:text>/</xsl:text>
				<xsl:choose>
					<xsl:when test="@version">
						<xsl:value-of select="@version"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>latest</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>/</xsl:text>
				<xsl:if test="@target-id">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="@target-id"/>
				</xsl:if>
			</xsl:variable>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Making external link to content</xsl:with-param></xsl:call-template>
			<db:link xlink:href="{$url}" type="external-content" class="external-content">
				<xsl:if test="not(text())">
					<xsl:value-of select="@document"/>
				</xsl:if>
				<xsl:apply-templates select="node()"/>
			</db:link>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- Creating an authors list for collections (STEP 2). Remove duplicates -->
<xsl:template match="db:authorgroup/db:*">
	<xsl:variable name="userId" select="@ext:user-id"/>
	<xsl:variable name="name" select="local-name()"/>
	<xsl:choose>
		<xsl:when test="not(preceding-sibling::db:*[local-name()=$name and @ext:user-id=$userId])">
			<xsl:call-template name="ident"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding duplicate author and editor</xsl:with-param></xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Convert db:anchor elements and links to them to point to the parent figure.
	They were added to preserve id's of subfigures (for linking)
 -->
<xsl:key name="id" match="*[@id or @xml:id]" use="@id|@xml:id"/>
<xsl:template match="@linkend">
	<xsl:variable name="target" select="key('id', .)"/>
	<xsl:attribute name="linkend">
		<xsl:choose>
			<xsl:when test="'anchor' = local-name($target)">
				<xsl:variable name="ancestor" select="ancestor::*[@xml:id][last()]"/>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Relinking db:anchor to <xsl:value-of select="local-name($ancestor)"/></xsl:with-param></xsl:call-template>
				<xsl:value-of select="$ancestor/@xml:id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template match="db:anchor">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Removing db:anchor and relinking db:anchor (probably created by converting c:subfigure)</xsl:with-param></xsl:call-template>
</xsl:template>

</xsl:stylesheet>
