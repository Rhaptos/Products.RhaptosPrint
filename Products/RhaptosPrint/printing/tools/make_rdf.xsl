<?xml version="1.0"?>

<!--  This stylesheet takes a XML file listing wanted module IDs as 
      input, and outputs a workable collection RDF file.  It's a bit 
      hacky in that many of the collection parameters are hard-coded 
      in variables in the stylesheet.  They should probably be moved 
      into the input file, so that a simple XML input file defines 
      the desired collection in full.  For now, the input file contains 
      one 'modules' root element with 'module' child elements, each of 
      which has a required 'moduleid' attribute and an optional 
      'version' attribute, e.g.:

        <?xml version="1.0"?>
        <modules>
          <module moduleid="m10221" version=""></module>
        </modules>

      To override the module title within the collection, make the override 
      title the content of the 'module' element.

      New style of collection description also available:

      <?xml version="1.0"?>
      <collection collectionid="">
        <metadata>
          <title></title>
          <version></version>
          <editors>
            <name></name>
            ...
          </editors>
          <hostname></hostname>
          <port></port>
        </metadata>
        <modules>
          <module moduleid="m10221" version=""></module>
        </modules>
      </collection>

    Author: Chuck Bearden
    (C) 2008 Rice University

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

  <xsl:output indent="yes" method="xml"/>
  <xsl:variable name="modules-rtf">
    <!-- descendant-or-self axis is used so that we can handle both old- 
         (no 'collection' wrapper or metadata) and new style ad hoc 
         collection descriptions. -->
    <xsl:apply-templates select="//modules" mode="add-ids"/>
  </xsl:variable>
  <xsl:variable name="modules" select="exsl:node-set($modules-rtf)"/>
  <xsl:variable name="hostname">
    <xsl:choose>
      <xsl:when test="/collection/metadata/hostname">
        <xsl:value-of select="/collection/metadata/hostname"/>
      </xsl:when>
      <xsl:otherwise>localhost:8080</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="collection-title">
    <xsl:choose>
      <xsl:when test="/collection/metadata/title">
        <xsl:value-of select="/collection/metadata/title"/>
      </xsl:when>
      <xsl:otherwise>Your title here</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="collection-version">
    <xsl:choose>
      <xsl:when test="/collection/metadata/version">
        <xsl:value-of select="/collection/metadata/version"/>
      </xsl:when>
      <xsl:otherwise>1.1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="collection-id">
    <xsl:choose>
      <xsl:when test="/collection/@collectionid">
        <xsl:value-of select="/collection/@collectionid"/>
      </xsl:when>
      <xsl:otherwise>randomcoll</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="content-uri" select="concat('http://', $hostname, '/content')"/>
  <xsl:variable name="collection-uri" select="concat($content-uri, '/', $collection-id, '/', $collection-version)"/>

  <xsl:template match="/">
    <rdf:RDF xmlns:cc="http://web.resource.org/cc/"
             xmlns:cnx="http://cnx.rice.edu/contexts#"
             xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

      <xsl:comment> Context object </xsl:comment>
      <xsl:call-template name="course-object"/>
      <xsl:comment> Our licenses </xsl:comment>
      <xsl:call-template name="license-block"/>
      <xsl:comment> Module descriptions </xsl:comment>
      <xsl:for-each select="$modules/module">
        <xsl:call-template name="make-module-description"/>
      </xsl:for-each>
    </rdf:RDF>
  </xsl:template>

  <xsl:template name="course-object">
    <!-- Course Object -->
    <rdf:Description about="urn:context:root">
      <cc:license rdf:resource="http://creativecommons.org/licenses/by/2.0/"/>
      <cnx:class>context</cnx:class>
      <cnx:type>Course</cnx:type>
      <cnx:name><xsl:value-of select="$collection-title"/></cnx:name>
      <cnx:uri><xsl:value-of select="$collection-uri"/></cnx:uri>
      <cnx:homepage></cnx:homepage>
      <cnx:annotations><xsl:value-of select="$collection-uri"/>/annotations</cnx:annotations>

      <cnx:author>
        <rdf:Bag>
    <xsl:choose>
      <xsl:when test="count(/collection/metadata/editors/name)">
        <xsl:for-each select="/collection/metadata/editors/name">
          <rdf:li>
            <xsl:value-of select="."/>
          </rdf:li>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <rdf:li>
          Milford Pugwash
        </rdf:li>
      </xsl:otherwise>
    </xsl:choose>
        </rdf:Bag>
      </cnx:author>

      <cnx:children>
         <rdf:Seq>
      <xsl:for-each select="$modules/module">
           <rdf:li resource="{@id}"/>
      </xsl:for-each>
         </rdf:Seq>
      </cnx:children>
    </rdf:Description>
  </xsl:template>

  <xsl:template name="license-block">
    <cc:License rdf:about="http://creativecommons.org/licenses/by/2.0/">
      <cc:requires rdf:resource="http://web.resource.org/cc/Attribution"/>
      <cc:permits rdf:resource="http://web.resource.org/cc/Reproduction"/>
      <cc:permits rdf:resource="http://web.resource.org/cc/Distribution"/>
      <cc:permits rdf:resource="http://web.resource.org/cc/DerivativeWorks"/>
      <cc:requires rdf:resource="http://web.resource.org/cc/Notice"/>
    </cc:License>
  </xsl:template>

  <xsl:template name="make-module-description">
    <xsl:variable name="module-id" select="@moduleid"/>
    <xsl:variable name="module-version">
      <xsl:choose>
        <xsl:when test="normalize-space(@version)">
          <xsl:value-of select="normalize-space(@version)"/>
        </xsl:when>
        <xsl:otherwise>latest</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="module-uri" select="concat($content-uri, '/', 
                  $module-id, '/', $module-version, '/')"/>
    <xsl:variable name="doc" select="document(concat($module-uri, 'index.cnxml'))"/>
    <xsl:variable name="module-name">
      <xsl:choose>
        <xsl:when test="normalize-space(.)">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$doc/cnxml:document/cnxml:name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <rdf:Description about="{@id}">
      <cnx:class>module</cnx:class>
      <cnx:id><xsl:value-of select="$module-id"/></cnx:id>
      <cnx:name><xsl:value-of select="$module-name"/></cnx:name>
      <cnx:uri><xsl:value-of select="$module-uri"/></cnx:uri>
      <cnx:author>
        <rdf:Bag>
        <xsl:for-each select="$doc/cnxml:document/cnxml:metadata/md:authorlist/md:author">
          <xsl:variable name="author-name">
            <xsl:value-of select="md:firstname"/>
            <xsl:value-of select="concat(' ', md:othername, ' ')"/>
            <xsl:value-of select="md:surname"/>
          </xsl:variable>
          <rdf:li>
            <xsl:value-of select="normalize-space($author-name)"/>
          </rdf:li>
        </xsl:for-each>
        </rdf:Bag>
      </cnx:author>
      <cnx:links>
      </cnx:links>
    </rdf:Description>
  </xsl:template>

  <xsl:template match="modules" mode="add-ids">
    <xsl:apply-templates mode="add-ids"/>
  </xsl:template>

  <xsl:template match="module" mode="add-ids">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="@*|text()|comment()|processing-instruction()">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
