<?xml version="1.0" encoding="utf-8"?>
<!--
    Assemble modules comprised by collections when generating 
    collection PDFs.

    Author: Brent Hendricks and Chuck Bearden
    (C) 2005-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.  -->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:cnx="http://cnx.rice.edu/contexts#"
        xmlns:cc="http://web.resource.org/cc/"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:exsl="http://exslt.org/common"
        extension-element-prefixes="exsl"
		exclude-result-prefixes="cnx rdf">

  <!-- Import transformation rules for modules -->
  <xsl:import href="modimport-old.xsl"/>
  <xsl:import href="modimport.xsl"/>
  <xsl:import href="getdoc.xsl"/>
  
  <!-- output xml file's unicode characters are not encoded as '&#0032' but
  rather in binary.  that way #'s can be escaped as \# in the next step without
  messing up the unicode. -->
  <xsl:output encoding="UTF-8" />


  <!-- Default rule for cnx nodes is to squash them -->
  <xsl:template match="cnx:*" />
    
  <!-- Keys for matching an element by eithr 'ID' or 'about' -->
  <xsl:key name="ID" match="*[@ID]" use="@ID"/>
  <xsl:key name="about" match="*[@about]" use="@about"/>
  
  <!--The ROOT node-->
  <xsl:template match="/">
    <!-- We only want the top level description.  The others will get -->
    <!-- pulled in as linked -->
    <xsl:apply-templates select="rdf:RDF/rdf:Description[cnx:class='context']"/>
  </xsl:template>	
  
  <!-- Top-level context object -->
  <xsl:template match="rdf:Description[cnx:class='context']">
    <course uri="{cnx:uri}">
      <xsl:apply-templates>
        <xsl:with-param name="parentlevel" select="'context'"/>
      </xsl:apply-templates>
    </course>
  </xsl:template>
  
  <!-- Copy license -->
  <xsl:template match="cc:license">
    <license uri="{@rdf:resource}"/>
  </xsl:template>

  <!-- Copy creation and revision date for collection structure. -->
  <xsl:template match="cnx:created|cnx:revised">
    <xsl:element name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <!-- Copy description -->
  <xsl:template match="cnx:description">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!-- Copy language -->
  <xsl:template match="cnx:language">
    <xsl:copy-of select="."/>
  </xsl:template>
    
  <!-- Copy names -->
  <xsl:template match="cnx:name">
    <name><xsl:value-of select="."/></name>
  </xsl:template>
  
  <!-- Split out author list -->
  <xsl:template match="rdf:Description[cnx:class='context']/cnx:author">
    <xsl:for-each select="rdf:Bag/rdf:li">
      <author><xsl:value-of select="."/></author>
    </xsl:for-each>
  </xsl:template>

  <!-- Split out author list -->
  <xsl:template match="rdf:Description[cnx:class='context']/cnx:licensor">
    <xsl:for-each select="rdf:Bag/rdf:li">
      <licensor><xsl:value-of select="."/></licensor>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Copy display parameters over. -->
  <xsl:template match="rdf:Description[cnx:class='context']/cnx:parameters">
    <parameters>
      <xsl:for-each select="rdf:Bag/rdf:li/cnx:parameter">
        <parameter name="{@name}" value="{@value}"/>
      </xsl:for-each>
    </parameters>
  </xsl:template>

  <!-- Handle children of containers -->
  <xsl:template match="cnx:children">
    <xsl:param name="parentlevel"/>
    <xsl:apply-templates>
      <xsl:with-param name="parentlevel" select="$parentlevel"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Match chapters -->
  <xsl:template match="rdf:Description[cnx:class='group']">
    <xsl:param name="mylevel"/>
    <group id="{@ID}" label="{./cnx:type}">
      <xsl:attribute name="cnx:class" namespace="http://cnx.rice.edu/contexts#">
        <xsl:value-of select="$mylevel"/>
      </xsl:attribute>
      <xsl:apply-templates>
        <xsl:with-param name="parentlevel" select="$mylevel"/>
      </xsl:apply-templates>
    </group>
  </xsl:template>

  <!-- Match modules -->
  <xsl:template match="rdf:Description[cnx:class='module']">
    <xsl:param name="mylevel"/>
    <xsl:variable name="DOC_ID" select="cnx:id"/>
    <!-- We need info from module_export_template for proper attribution. -->
    <xsl:message>Getting <xsl:value-of select="$DOC_ID"/></xsl:message>
    <xsl:variable name="module_export_rtf">
      <xsl:call-template name="get-doc">
        <xsl:with-param name="docuri" select="concat(normalize-space(cnx:uri),'module_export_template')"/>
        <xsl:with-param name="failonerror" select="1"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="module_export" select="exsl:node-set($module_export_rtf)"/>
    <xsl:variable name="document" select="$module_export/module/*[local-name()='document'][namespace-uri()='http://cnx.rice.edu/cnxml']"/>
    <document id="{$DOC_ID}">
      <xsl:attribute name="cnx:class" namespace="http://cnx.rice.edu/contexts#">
        <xsl:value-of select="$mylevel"/>
      </xsl:attribute>
      <xsl:copy-of select="$document/@*[name()!='id']"/>
      <xsl:copy-of select="$module_export//processing-instruction('abort-pdf')"/>
      <xsl:apply-templates/>
      <module-export>
        <xsl:copy-of select="$module_export/module/title"/>
        <xsl:for-each select="$module_export/module/metadata/author">
          <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="$module_export/module/metadata/licensor">
          <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:for-each select="$module_export/module/metadata/optionalrole[@name='Translator']">
          <xsl:copy-of select="."/>
        </xsl:for-each>
        <xsl:copy-of select="$module_export/module/metadata/parent"/>
        <xsl:copy-of select="$module_export/module/metadata/license"/>
        <xsl:copy-of select="$module_export/module/metadata/language"/>
        <xsl:copy-of select="$module_export/module/publishing/version"/>
        <xsl:copy-of select="$module_export/module/publishing/portal"/>
        <xsl:copy-of select="$module_export/module/display/base"/>
      </module-export>
      <xsl:apply-templates select="$document">
        <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
      </xsl:apply-templates>
      
    </document>
  </xsl:template>

  <!-- Match preface modules -->
  <xsl:template match="rdf:Description[cnx:class='preface']">
    <preface id="{cnx:id}">
      <xsl:apply-templates/>
      <xsl:apply-templates select="document(concat(normalize-space(cnx:uri),'index.cnxml'))/*"/>
      
    </preface>
  </xsl:template>


  
  <!-- Match list items that refer to an another Description object -->
  <!-- and copy the contents of the module or the group that the -->
  <!-- rdf:li describes -->
  <!-- Either the child is a subcollection or a module.
       Subcollection has an actual #id, and since module is external, has an 'about'
   -->
  <xsl:template match="rdf:li[@resource]">
    <xsl:param name="parentlevel"/>
    <!-- FIXME: our case detection is a little, umm, hacky -->
    <xsl:choose>
      <!-- Case 1: reference starts with a # which means that it
      links by ID -->
      <xsl:when test="starts-with(@resource,'#')">
	<xsl:apply-templates select="key('ID', substring-after(@resource,'#'))">
          <xsl:with-param name="mylevel">
            <xsl:choose>
              <xsl:when test="$parentlevel='context'">
                <xsl:value-of select="'chapter'"/>
              </xsl:when>
              <xsl:when test="$parentlevel='chapter'">
                <xsl:value-of select="'section1'"/>
              </xsl:when>
              <xsl:when test="starts-with($parentlevel, 'section')">
                <xsl:value-of select="concat('section', string(number(substring-after($parentlevel, 'section'))+1))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message>Bad code</xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
	</xsl:apply-templates>
      </xsl:when>
      <!--Case 2: reference does not start with a #, which means
      that it links by 'about' -->
      <xsl:otherwise>
	<xsl:apply-templates select="key('about',@resource)">
          <xsl:with-param name="mylevel">
            <xsl:choose>
              <xsl:when test="$parentlevel='context'">
                <xsl:choose>
                  <xsl:when test="count(preceding-sibling::rdf:li[starts-with(@resource, '#')]) = 0 and count(following-sibling::rdf:li[starts-with(@resource, '#')]) > 0">
                    <xsl:value-of select="'frontmatter'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'chapter'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$parentlevel='chapter'">
                <xsl:value-of select="'section1'"/>
              </xsl:when>
              <xsl:when test="starts-with($parentlevel, 'section')">
                <xsl:value-of select="concat('section', string(number(substring-after($parentlevel, 'section'))+1))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'unknown'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Default template for rdf tags-->
  <xsl:template match="rdf:*">
    <xsl:param name="parentlevel"/>
    <xsl:apply-templates>
      <xsl:with-param name="parentlevel" select="$parentlevel"/>
    </xsl:apply-templates>
  </xsl:template>
  
</xsl:stylesheet>






