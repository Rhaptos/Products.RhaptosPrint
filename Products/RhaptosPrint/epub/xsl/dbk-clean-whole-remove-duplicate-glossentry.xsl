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
  xmlns:cnxorg="http://cnx.rice.edu/system-info"
  version="1.0">

<!-- This file is run after the book-level glossary is created.
	It removes duplicate db:glossentry elements
	It also adds in an attribution section at the end of the book.
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="ident.xsl"/>

<xsl:output indent="yes" method="xml"/>

<!-- DEAD: Removed in favor of module-level glossaries
<xsl:template match="db:glossentry[normalize-space(db:glossterm/text())!='' and db:glossterm/text()=preceding-sibling::db:glossentry/db:glossterm/text()]">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Removing duplicate glossentry for term "<xsl:value-of select="db:glossterm/text()"/>"</xsl:with-param></xsl:call-template>
</xsl:template>
-->

<!-- Since we decided to discard printing module metadata, this removes it (after we generate the book-level metadata).  -->
<xsl:template match="db:prefaceinfo/db:*[local-name()!='title']|db:chapterinfo/db:*[local-name()!='title']|db:sectioninfo/db:*[local-name()!='title']|db:appendixinfo/db:*[local-name()!='title']">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding module metadata: <xsl:value-of select="local-name()"/></xsl:with-param></xsl:call-template>
</xsl:template>

<!-- Discard the email address for epub generation -->
<xsl:template match="db:email">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding email address</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="db:authorgroup[not(parent::db:biblioentry or parent::db:bookinfo)]">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Discarding db:authorgroup whose grandparent is <xsl:value-of select="local-name(../..)"/></xsl:with-param></xsl:call-template>
</xsl:template>


<!-- Add an attribution section with all the modules at the end of the book -->
<xsl:template match="db:book[not(@ext:element='module')]">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
        <db:appendix>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$attribution.section.id"/>
            </xsl:attribute>
            <db:title>Attributions</db:title>
            <xsl:for-each select=".//db:prefaceinfo|.//db:chapterinfo|.//db:sectioninfo|.//db:appendixinfo">
                <xsl:variable name="id">
                    <xsl:call-template name="cnx.id">
                        <xsl:with-param name="object" select=".."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="url">
                    <xsl:value-of select="$cnx.url"/>
                    <xsl:value-of select="$id"/>
                    <xsl:text>/</xsl:text>
                    <!-- Some modules don't have md:version set (db:edition), so pull it from the collection -->
                    <xsl:choose>
                       <xsl:when test="../@cnxorg:version-at-this-collection-version">
                           <xsl:value-of select="../@cnxorg:version-at-this-collection-version"/>
                       </xsl:when>
                       <!-- Could have been xincluded in a db:preface -->
                       <xsl:when test="../../@cnxorg:version-at-this-collection-version">
                           <xsl:value-of select="../../@cnxorg:version-at-this-collection-version"/>
                       </xsl:when>
                       <xsl:when test="db:edition/text()">
                           <xsl:value-of select="db:edition/text()"/>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:text>latest</xsl:text>
                       </xsl:otherwise>
                    </xsl:choose>
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
                        <xsl:variable name="originalTitle">
                            <xsl:choose>
                                <xsl:when test="ext:original-title">
                                    <xsl:apply-templates select="ext:original-title/node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="db:title/node()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <db:member>
                            <xsl:apply-templates select="db:title/@*"/>
                            <xsl:text>Module: </xsl:text>
                            <db:link linkend="{$id}">
                                <xsl:copy-of select="$originalTitle"/>
                            </db:link>
                        </db:member>
                        <xsl:if test="ext:original-title">
                            <db:member>
                                <xsl:text>Used here as: </xsl:text>
                                <xsl:apply-templates select="db:title/node()"/>
                            </db:member>
                        </xsl:if>
                        <db:member>
                            <xsl:text>By: </xsl:text>
                            <ext:persons>
                                <xsl:apply-templates select="db:authorgroup/db:author"/>
                            </ext:persons>
                        </db:member>
                        <xsl:if test="db:authorgroup/db:editor">
                            <db:member>
                                <xsl:text>Edited by: </xsl:text>
                                <ext:persons>
                                    <xsl:apply-templates select="db:authorgroup/db:editor"/>
                                </ext:persons>
                            </db:member>
                        </xsl:if>
                        <xsl:if test="db:authorgroup/db:othercredit[@class='translator']">
                            <db:member>
                                <xsl:text>Translated by: </xsl:text>
                                <ext:persons>
                                    <xsl:apply-templates select="db:authorgroup/db:othercredit[@class='translator']"/>
                                </ext:persons>
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
                                <ext:persons>
                                    <xsl:apply-templates select="db:authorgroup/db:othercredit[@class='other' and db:contrib/text()='licensor']"/>
                                </ext:persons>
                            </db:member>
                        </xsl:if>
                        <xsl:if test="db:legalnotice">
                            <db:member>
                                <xsl:text>License: </xsl:text>
                                <xsl:apply-templates select="db:legalnotice/db:ulink"/>
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
