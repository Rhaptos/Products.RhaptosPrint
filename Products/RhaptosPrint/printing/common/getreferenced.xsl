<?xml version="1.0"?>
<!--
    Retrieve content not included in the current object but referred 
    to by it, for the purpose of making more informational references 
    and footnotes to this content.

    Author: Chuck Bearden, Ross Reedstrom
    (C) 2008-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cnxml="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:cc="http://web.resource.org/cc/"
  xmlns:cnx="http://cnx.rice.edu/contexts#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
>

  <xsl:import href="getdoc.xsl"/>

  <xsl:output indent="yes" method="xml"/>
  <xsl:key name="doc-by-id" match="document" use="@id"/>
  <xsl:key name="cnxn-by-document" match="*[self::cnxml:cnxn or self::cnxml:link][@document]" use="@document"/>
  <xsl:key name="cite-by-document" match="cnxml:cite[@document]" use="@document"/>
  <xsl:variable name="repos-uri">
    <xsl:choose>
      <xsl:when test="/course">
        <xsl:value-of select="substring-before(/course/@uri, 
                      substring-after(/course/@uri, '/content'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(
                      /module/cnxml:document/module-export/portal/@href, 
                      '/content')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="//processing-instruction('abort-pdf')">
        <xsl:element name="abort-pdf">
          <xsl:value-of select="//processing-instruction('abort-pdf')"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="course|module">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <referenced-objects><xsl:comment>woof</xsl:comment>
        <xsl:call-template name="get-referenced">
          <xsl:with-param name="cnxn-elems" 
                          select="//*[self::cnxml:cnxn or self::cnxml:link]
                          [normalize-space(@document)]
                          [generate-id() = generate-id(key(
                             'cnxn-by-document', @document)[1])] | //cnxml:cite[normalize-space(@document)][generate-id() = generate-id(key(
                             'cite-by-document', @document)[1])]"/>
          <xsl:with-param name="position" select="1"/>
          <xsl:with-param name="objects-seen" select="''"/>
        </xsl:call-template>
      </referenced-objects>
    </xsl:copy>
  </xsl:template>

  <!-- Takes a cnxn, retrieves and writes the referenced doc if it's not in 
       the collection.  Recurs on the following cnxn in the document -->
  <xsl:template name="get-referenced">
    <xsl:param name="cnxn-elems"/>
    <xsl:param name="position"/>
    <xsl:param name="objects-seen"/>
    <xsl:variable name="cnxn-elem" select="$cnxn-elems[$position]"/>
    <xsl:variable name="document" select="normalize-space($cnxn-elem/@document)"/>
    <xsl:variable name="version">
      <xsl:choose>
        <xsl:when test="normalize-space($cnxn-elem/@version)">
          <xsl:value-of select="normalize-space($cnxn-elem/@version)"/>
        </xsl:when>
        <xsl:otherwise>latest</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$cnxn-elem and not(key('doc-by-id', $document)) and 
                  not(contains($objects-seen, concat($document, ',')))">
      <xsl:message>Getting <xsl:value-of select="$document"/> (referenced)</xsl:message>
      <xsl:choose>
        <xsl:when test="starts-with($document, 'm')">
          <!-- Get a module -->
          <xsl:variable name="module_export_rtf">
            <xsl:call-template name="get-doc">
              <xsl:with-param name="failonerror" select="0"/>
              <xsl:with-param name="docuri" select="concat($repos-uri, '/', $document, '/', 
                                            $version, '/module_export_template')"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="module-export" select="exsl:node-set($module_export_rtf)"/>
          <!-- We add a document to 'referenced-objects' only if we got a 
               real module_export_template back -->
          <xsl:if test="$module-export/module/cnxml:document">
            <document id="{$document}">
              <module-export>
                <xsl:copy-of select="$module-export/module/title"/>
                <xsl:for-each select="$module-export/module/metadata/author">
                  <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="$module-export/module/metadata/licensor">
                  <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:copy-of select="$module-export/module/metadata/parent"/>
                <xsl:copy-of select="$module-export/module/metadata/license"/>
                <xsl:copy-of select="$module-export/module/metadata/language"/>
                <xsl:copy-of select="$module-export/module/publishing/version"/>
                <xsl:copy-of select="$module-export/module/display/base"/>
              </module-export>
              <xsl:apply-templates select="$module-export/module/cnxml:document/*">
                <xsl:with-param name="DOC_ID" select="$document"/>
              </xsl:apply-templates>
            </document>
            <xsl:text>
</xsl:text>
          </xsl:if>
        </xsl:when>
        <!-- Get a collection -->
        <xsl:when test="starts-with($document, 'col')">
          <xsl:variable name="rdf_rtf">
            <xsl:call-template name="get-doc">
              <xsl:with-param name="failonerror" select="0"/>
              <xsl:with-param name="docuri" select="concat(
                          $repos-uri, '/', $document, '/', $version, 
                          '?format=rdf')"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="rdf" select="exsl:node-set($rdf_rtf)"/>
          <rdf:RDF id="{$document}">
            <xsl:copy-of select="$rdf/rdf:RDF/*"/>
          </rdf:RDF><xsl:text>
</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="count($cnxn-elems[$position+1])">
      <xsl:call-template name="get-referenced">
        <xsl:with-param name="cnxn-elems" select="$cnxn-elems"/>
        <xsl:with-param name="position" select="$position+1"/>
        <xsl:with-param name="objects-seen" 
                        select="concat($objects-seen, $document, ',')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="DOC_ID"/>
    <xsl:copy>
      <xsl:apply-templates select="@*">
        <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
      </xsl:apply-templates>
      <xsl:apply-templates>
        <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@id">
    <xsl:param name="DOC_ID"/>
    <xsl:attribute name="id">
      <xsl:if test="$DOC_ID and (ancestor::cnxml:content or ancestor::bib:file or ancestor-or-self::cnxml:glossary)">
        <xsl:value-of select="$DOC_ID"/>
        <xsl:text>*</xsl:text>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*|text()|comment()|processing-instruction()">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
