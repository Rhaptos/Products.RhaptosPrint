<?xml version= "1.0" standalone="no"?>
<!--
    Author: Christine Donica, Brent Hendricks, Adan Galvan
    (C) 2002-2004 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cnx03="http://cnx.rice.edu/cnxml/0.3"
		xmlns:cnx035="http://cnx.rice.edu/cnxml/0.3.5"
		xmlns:cnx04="http://cnx.rice.edu/cnxml/0.4"
		xmlns:cnxml="http://cnx.rice.edu/cnxml"
                xmlns:mdml="http://cnx.rice.edu/mdml/0.4"
		exclude-result-prefixes="cnx035">
  <!-- NOTE, if you change the CNXML namespaces up here, you must also change
		them in the cnxml identity transform at the end of this
		file. -->  


  <!--identity transform-->
  <xsl:import href="ident.xsl"/>

  <!-- output xml file's unicode characters are not encoded as '&#0032' but
  rather in binary.  that way #'s can be escaped as \# in the next step without
  messing up the unicode. -->
  <xsl:output encoding="UTF-8" />

  <!-- Default copying rule for cnxml 0.3.5/0.4 attributes -->
  <xsl:template match="cnx03:*/@*|cnx035:*/@*|cnx04:*/@*">
    <xsl:attribute name="{local-name()}"><xsl:value-of select="." /></xsl:attribute>
  </xsl:template>

  <!-- identity transform for cnxml 0.3.5/0.4 tags -->
  <xsl:template match="cnx03:*|cnx035:*|cnx04:*">
    <!-- note on implamentation: tried to put an abbreviated namespace here (ie
    cnxml, not http....),  but it did not work.  would cause nonrecognition of
    tags.  alas. --> 
    <xsl:element name="{local-name()}" namespace="http://cnx.rice.edu/cnxml">
      <!-- Must copy the attributes first and separately, so that the
      templates for 'id' and 'target' are guaranteed to match *before*
      we've copied over any children (See XSLT spec 7.1.3 and and
      Michael Kay's XSLT ref. p 167 for rationale) -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>


  <!-- For CNXML 03, Change module tag into document, add Metadata tag, and add Content tag -->
  <xsl:template match="cnx03:module">
    <xsl:element name="cnxml:document">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="cnx03:name"/>

      <xsl:element name="cnxml:metadata" namespace="http://cnx.rice.edu/cnxml"> 
	<mdml:version><xsl:value-of select="/cnx03:module/@version" /></mdml:version>
	<mdml:created><xsl:value-of select="/cnx03:module/@created" /></mdml:created>
	<mdml:revised><xsl:value-of select="/cnx03:module/@revised" /></mdml:revised>
	<xsl:apply-templates select="cnx03:authorlist|cnx03:maintainerlist|cnx03:keywordlist|cnx03:abstract"/>
      </xsl:element>
      <xsl:element name="cnxml:content" namespace="http://cnx.rice.edu/cnxml">
	<xsl:apply-templates select="*[not(self::cnx03:authorlist or self::cnx03:maintainerlist or self::cnx03:keywordlist or self::cnx03:abstract or self::cnx03:name)]"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- Change module tags into document -->
  <xsl:template match="cnx035:module|cnx04:module">
    <xsl:element name="cnxml:document">     	
      <!-- Must copy the attributes first and separately, so that the
      templates for 'id' and 'target' are guaranteed to match *before*
      we've copied over any children (See XSLT spec 7.1.3 and and
      Michael Kay's XSLT ref. p 167 for rationale) -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <!-- Convert @module into @document on cnxn tags -->
  <xsl:template match="cnx03:cnxn/@module|cnx035:cnxn/@module|cnx04:cnxn/@module">
    <xsl:attribute name="document"><xsl:value-of select="." /></xsl:attribute>
  </xsl:template>

  <!-- Convert CNXML 0.3.5 metadata tags to MDML -->
  <xsl:template match="cnx035:metadata">
    <cnxml:metadata>
      <mdml:version><xsl:value-of select="/cnx035:module/@version" /></mdml:version>
      <mdml:created><xsl:value-of select="/cnx035:module/@created" /></mdml:created>
      <mdml:revised><xsl:value-of select="/cnx035:module/@revised" /></mdml:revised>
      <xsl:apply-templates />
    </cnxml:metadata>
  </xsl:template>
  
  <xsl:template match="cnx035:metadata//cnx035:*|cnx03:authorlist|cnx03:authorlist//cnx03:*|cnx03:maintainerlist|cnx03:maintainerlist//cnx03:*|cnx03:abstract|cnx03:abstract//cnx03:*|cnx03:keywordlist|cnx03:keywordlist//cnx03:*">
    <!-- note on implamentation: tried to put an abbreviated namespace here (ie
    cnxml, not http....),  but it did not work.  would cause nonrecognition of
    tags.  alas. --> 
    <xsl:element name="{local-name()}" 
		 namespace="http://cnx.rice.edu/mdml/0.4">
      <!-- Must copy the attributes first and separately, so that the
      templates for 'id' and 'target' are guaranteed to match *before*
      we've copied over any children (See XSLT spec 7.1.3 and and
      Michael Kay's XSLT ref. p 167 for rationale) -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>