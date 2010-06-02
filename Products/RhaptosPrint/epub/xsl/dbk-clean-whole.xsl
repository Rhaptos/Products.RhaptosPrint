<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:md="http://cnx.rice.edu/mdml/0.4" xmlns:bib="http://bibtexml.sf.net/"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:output indent="yes" method="xml"/>

<xsl:param name="cnx.url" select="'http://cnx.org'"/>

<!-- Collapse XIncluded modules -->
<xsl:template match="db:chapter[count(db:section)=1]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Converting module to chapter</xsl:with-param></xsl:call-template>
	<xsl:copy>
		<xsl:apply-templates select="@*|db:section/@*"/>
		<db:chapterinfo>
			<xsl:apply-templates select="db:title"/>
			<xsl:apply-templates select="db:section/db:sectioninfo/node()"/>
		</db:chapterinfo>
		<xsl:apply-templates select="db:section/node()[local-name()!='sectioninfo']"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="db:chapter[db:title]/db:section/db:sectioninfo/db:title">
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


<!-- If the Module title starts with the chapter title then discard it. -->
<xsl:template match="db:PHIL/db:chapter/db:section">
	<xsl:choose>
		<xsl:when test="starts-with(db:info/db:title/text(), ../db:info/db:title/text())">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Stripping chapter name from title</xsl:with-param></xsl:call-template>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<db:info>
					<xsl:apply-templates mode="strip-title" select="db:info/db:title"/>
					<xsl:apply-templates select="db:info/*[local-name()!='title']|db:info/processing-instruction()|db:info/comment()"/>
				</db:info>
				<xsl:apply-templates select="*[local-name()!='info']|processing-instruction()|comment()"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template mode="strip-title" match="db:title">
	<xsl:variable name="chapTitle">
		<xsl:value-of select="../../../db:info/db:title/text()"/>
		<xsl:text>: </xsl:text>
	</xsl:variable>
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:for-each select="node()">
			<xsl:choose>
				<xsl:when test="position()=1">
					<xsl:value-of select="substring-after(., $chapTitle)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<!-- Combine all module glossaries into a single book glossary -->
<xsl:template match="db:book">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<!-- Generate a list of authors from the modules -->
		<xsl:apply-templates/>
		<xsl:if test="//db:glossentry">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: creating</xsl:with-param></xsl:call-template>
			<db:glossary>
				<xsl:variable name="letters">
					<xsl:apply-templates mode="glossaryletters" select="//db:glossentry/@_first-letter">
						<xsl:sort select="."/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: letters="<xsl:value-of select="$letters"/>"</xsl:with-param></xsl:call-template>
				<xsl:call-template name="cnx.glossary">
					<xsl:with-param name="letters" select="$letters"/>
				</xsl:call-template>
			</db:glossary>
		</xsl:if>
	</xsl:copy>
</xsl:template>
<xsl:template mode="glossaryletters" match="@*">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template name="cnx.glossary">
	<xsl:param name="letters"/>
	<xsl:variable name="letter" select="substring($letters, 1, 1)"/>
	
	<!-- Skip all duplicates of letters until the last one, which we process -->
	<xsl:if test="string-length($letters) = 1 or $letter != substring($letters,2,1)">
		<db:glossdiv>
			<db:title><xsl:value-of select="$letter"/></db:title>
			<xsl:apply-templates select="//db:glossentry[@_first-letter=$letter]">
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
<!-- Discard the @_first-letter attribute since it's no longer needed -->
<xsl:template match="@_first-letter">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: Writing out an entry whose first letter is "<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
</xsl:template>

<!-- Discard the module-level glossary -->
<xsl:template match="db:glossary">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding module-level glossary and combining into book-level glossary</xsl:with-param></xsl:call-template>
</xsl:template>

<!-- Discard extra db:info in db:section (modules) except for db:title -->
<!-- This way we don't have attribution for every db:section (module) -->
<xsl:template match="db:section/db:info/db:*[not(self::db:title)]"/>

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
				<xsl:text>/content/</xsl:text>
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

<!-- Move the solutions to exercises (db:qandaset) to the end of the chapter. -->
<!-- 
<xsl:template match="db:question[../db:answer]">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
		<db:para><db:link xlink:href="{ancestor::db:section[@xml:id]/@xml:id}.solution">Solution</db:link></db:para>
	</xsl:copy>
</xsl:template>
<xsl:template match="db:answer"/>
<xsl:template match="db:chapter[.//db:qandaset]">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
		<db:section>
			<db:title>Solutions to Exercises</db:title>
			<xsl:apply-templates mode="cnx.solution" select=".//db:qandaset"/>
		</db:section>
	</xsl:copy>
</xsl:template>
<xsl:template mode="cnx.solution" match="db:qandaset">
	<db:formalpara>
		<db:title><xsl:apply-templates select="ancestor::db:*[db:title][2]/db:title/node()"/></db:title>
		<xsl:apply-templates mode="cnx.solution"/>
	</db:formalpara>
</xsl:template>
<xsl:template mode="cnx.solution" match="db:qandaentry">
	<xsl:value-of select="position()"/>
	<xsl:text>. </xsl:text>
	<xsl:apply-templates mode="cnx.solution"/>
	<xsl:text> </xsl:text>
</xsl:template>
<xsl:template mode="cnx.solution" match="db:answer">
	<xsl:apply-templates mode="cnx.solution"/>
</xsl:template>
<xsl:template mode="cnx.solution" match="db:para">
	<xsl:apply-templates mode="cnx.solution"/>
</xsl:template>
<xsl:template mode="cnx.solution" match="db:question"/>
<xsl:template mode="cnx.solution" match="*">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">ERROR: Skipped in creating a solution</xsl:with-param></xsl:call-template>
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>
 -->
</xsl:stylesheet>
