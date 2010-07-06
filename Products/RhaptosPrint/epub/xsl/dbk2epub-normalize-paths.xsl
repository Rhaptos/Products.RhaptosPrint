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

<!-- This file:
     * Ensures paths to images inside modules are correct (using @xml:base)
     //* Adds a @ext:first-letter attribute to glossary entries so they can be organized into a book-level glossary 
     * Adds an Attribution section at the end of the book
 -->

<xsl:import href="param.xsl"/>
<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:output indent="yes" method="xml"/>

<!-- Strip 'em for html generation -->
<xsl:template match="@xml:base"/>

<!-- Make image paths point into the module directory -->
<xsl:template match="@fileref">
	<xsl:attribute name="fileref">
		<xsl:value-of select="substring-before(ancestor::db:section[@xml:base]/@xml:base, '/')"/>
                <xsl:text>/</xsl:text>
		<xsl:value-of select="."/>
	</xsl:attribute>
</xsl:template>

<!-- Creating an authors list for collections (STEP 1). Just collect all the authors (with duplicates) -->
<xsl:template match="/db:book/db:info">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Collapsing authors of all modules into 1 book-level db:authorgroup</xsl:with-param></xsl:call-template>
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<db:authorgroup>
			<xsl:for-each select="//db:authorgroup/db:*">
				<xsl:call-template name="ident"/>
			</xsl:for-each>
		</db:authorgroup>
		<xsl:apply-templates select="node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="db:authorgroup">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding db:authorgroup whose grandparent is <xsl:value-of select="local-name(../..)"/></xsl:with-param></xsl:call-template>
</xsl:template>

<!-- DEAD: Removed in favor of module-level glossaries
<!- - Overloading the file to add glossary metadata - ->
<xsl:template match="db:glossentry">
	<!- - Find the 1st character. Used later in the transform to generate a glossary alphbetically - ->
	<xsl:variable name="letters">
		<xsl:apply-templates mode="glossaryletters" select="db:glossterm/node()"/>
	</xsl:variable>
	<xsl:variable name="firstLetter" select="translate(substring(normalize-space($letters),1,1),'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Glossary: firstLetter="<xsl:value-of select="$firstLetter"/>" of "<xsl:value-of select="normalize-space($letters)"/>"</xsl:with-param></xsl:call-template>
	<db:glossentry ext:first-letter="{$firstLetter}">
		<xsl:apply-templates select="@*|node()"/>
	</db:glossentry>
</xsl:template>
<!- - Helper template to recursively find the text in a glossary term - ->
<xsl:template mode="glossaryletters" select="*">
	<xsl:apply-templates mode="glossaryletters"/>
</xsl:template>
<xsl:template mode="glossaryletters" select="text()">
	<xsl:value-of select="."/>
</xsl:template>
-->


<!-- Add an attribution section with all the modules at the end of the book -->
<xsl:template match="db:book">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
		<db:appendix>
			<xsl:attribute name="xml:id">
				<xsl:value-of select="$attribution.section.id"/>
			</xsl:attribute>
			<db:title>Attributions</db:title>
			<xsl:for-each select=".//db:chapterinfo|.//db:sectioninfo">
				<xsl:variable name="id">
					<xsl:call-template name="cnx.id">
						<xsl:with-param name="object" select=".."/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="url">
					<xsl:value-of select="$cnx.url"/>
					<xsl:value-of select="$id"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="db:edition"/>
					<xsl:text>/</xsl:text>
				</xsl:variable>
				<xsl:variable name="attributionId">
					<xsl:text>book.attribution.</xsl:text>
					<xsl:value-of select="$id"/>
				</xsl:variable>
				<db:para>
				        <xsl:attribute name="xml:id">
					        <xsl:value-of select="$attributionId"/>
				        </xsl:attribute>
					<db:simplelist>
						<db:member>
							<xsl:apply-templates select="db:title/@*"/>
							<xsl:text>Module: </xsl:text>
							<db:link linkend="{$id}">
								<xsl:apply-templates select="db:title/node()"/>
							</db:link>
						</db:member>
						<db:member>
							<xsl:text>By: </xsl:text>
							<xsl:call-template name="cnx.personlist">
								<xsl:with-param name="nodes" select="db:authorgroup/db:author"/>
							</xsl:call-template>
						</db:member>
						<xsl:if test="db:authorgroup/db:editor">
							<db:member>
								<xsl:text>Edited by: </xsl:text>
								<xsl:call-template name="cnx.personlist">
									<xsl:with-param name="nodes" select="db:authorgroup/db:editor"/>
								</xsl:call-template>
							</db:member>
						</xsl:if>
						<xsl:if test="db:authorgroup/db:othercredit[@class='translator']">
							<db:member>
								<xsl:text>Translated by: </xsl:text>
								<xsl:call-template name="cnx.personlist">
									<xsl:with-param name="nodes" select="db:authorgroup/db:othercredit[@class='translator']"/>
								</xsl:call-template>
							</db:member>
						</xsl:if>
						<db:member>
							<xsl:text>URL: </xsl:text>
							<db:ulink url="{$url}"><xsl:value-of select="$url"/></db:ulink>
						</db:member>
						<xsl:if test="db:authorgroup/db:othercredit[@class='other' and db:contrib/text()='licensor' and *[name()!='db:contrib']]">
                                                        <!-- Max: The *[name()!='db:contrib'] is to make sure that the db:othercredit is actually populated with a user.  
                                                             Can somebody be removed once we populate this info for 0.5 modules -->
							<db:member>
								<xsl:text>Copyright: </xsl:text>
								<xsl:call-template name="cnx.personlist">
									<xsl:with-param name="nodes" select="db:authorgroup/db:othercredit[@class='other' and db:contrib/text()='licensor']"/>
								</xsl:call-template>
							</db:member>
						</xsl:if>
						<xsl:if test="db:legalnotice">
							<db:member>
								<xsl:text>License: </xsl:text>
								<xsl:apply-templates select="db:legalnotice/db:link"/>
							</db:member>
						</xsl:if>
						<xsl:if test="not(db:legalnotice)">
							<xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: Module contains no license info</xsl:with-param></xsl:call-template>
						</xsl:if>
					</db:simplelist>
				</db:para>
			</xsl:for-each>
		</db:appendix>
                <xsl:if test="$cnx.iscnx != 0">
                        <db:colophon>
                                <db:title>About Connexions</db:title>
                                <db:para>
                                        Since 1999, Connexions has been pioneering a global system where anyone can create course materials and make them fully accessible and easily reusable free of charge. We are a Web-based authoring, teaching and learning environment open to anyone interested in education, including students, teachers, professors and lifelong learners. We connect ideas and facilitate educational communities. Connexions's modular, interactive courses are in use worldwide by universities, community colleges, K-12 schools, distance learners, and lifelong learners. Connexions materials are in many languages, including English, Spanish, Chinese, Japanese, Italian, Vietnamese, French, Portuguese, and Thai. 
                                </db:para>
                        </db:colophon>
                </xsl:if>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
