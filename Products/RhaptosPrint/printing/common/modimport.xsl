<?xml version= "1.0"?>
<!--
    Format CNXML >= 0.5 when generating collection or module PDFs.

    Author: Brent Hendricks, Chuck Bearden, and Adan Galvan
    (C) 2005-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cnxml="http://cnx.rice.edu/cnxml"
                xmlns:qml="http://cnx.rice.edu/qml/1.0"
                xmlns:mdml4="http://cnx.rice.edu/mdml/0.4"
                xmlns:mdml="http://cnx.rice.edu/mdml"
                xmlns:md="http://cnx.rice.edu/mdml"
                xmlns:m="http://www.w3.org/1998/Math/MathML"
                xmlns:bib="http://bibtexml.sf.net/"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="str"
>

  <xsl:import href="default-type.xsl"/>

  <!-- For module, we copy authors, keywords, and content.  That's it -->
  <xsl:template match="cnxml:document">
    <xsl:param name="DOC_ID"/>
    <xsl:call-template name="copy-metadata"/>
    <xsl:apply-templates select="cnxml:content">
      <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="cnxml:glossary"/>
    <xsl:apply-templates select="bib:file">
      <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="copy-metadata">
    <xsl:variable name="metadata" select="cnxml:metadata"/>
    <!-- Convert MDML 0.5 authors to faux 0.4 structures since we know how to 
         grab that downstream, using named template below. -->
    <xsl:choose>
      <xsl:when test="string($metadata/@mdml-version) = '0.5'">
        <xsl:call-template name="mdml05-authors">
          <xsl:with-param name="userids" select="str:tokenize($metadata/mdml:roles/mdml:role[@type='author'])"/>
          <xsl:with-param name="userid-idx" select="1"/>
          <xsl:with-param name="metadata" select="$metadata"/>
        </xsl:call-template>
        <xsl:apply-templates select="$metadata/mdml:keywordlist/mdml:keyword" mode="strip-namespace"/>
      </xsl:when>
      <!-- Do what we used to do, only with more precise (and performant?) XPath. -->
      <xsl:otherwise>
        <xsl:apply-templates select="$metadata/mdml4:authorlist/mdml4:author"/>
        <xsl:apply-templates select="$metadata/mdml4:keywordlist/mdml4:keyword"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Convert MDML 0.5 authors to faux 0.4 structures since we know how to grab that downstream. -->
  <xsl:template name="mdml05-authors">
    <xsl:param name="userids"/>
    <xsl:param name="userid-idx"/>
    <xsl:param name="metadata"/>
    <xsl:element name="author">
      <xsl:attribute name="id"><xsl:value-of select="$userids[$userid-idx]"/></xsl:attribute>
      <xsl:apply-templates select="$metadata/mdml:actors/*[@userid=$userids[$userid-idx]]/*" mode="strip-namespace"/>
    </xsl:element>
    <xsl:if test="$userid-idx &lt; count($userids)">
      <xsl:call-template name="mdml05-authors">
        <xsl:with-param name="userids" select="$userids"/>
        <xsl:with-param name="userid-idx" select="$userid-idx + 1"/>
        <xsl:with-param name="metadata" select="$metadata"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mdml:*" mode="strip-namespace">
    <xsl:element name="{local-name(.)}">
      <xsl:apply-templates select="node()|@*" mode="strip-namespace"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="node()|@*" mode="strip-namespace">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="strip-namespace"/>
    </xsl:copy>
  </xsl:template>

  <!-- Concatenate the IDs: -->
  <!-- The id of each elements is concatenated with the module id to -->
  <!-- make it unique within the course. The two ids are separated by an *.-->
  <xsl:template match="cnxml:*/@id|qml:*/@id|m:math/@id|bib:*/@id">
    <xsl:param name="DOC_ID"/>
    <xsl:attribute name="id">
      <xsl:value-of select="$DOC_ID"/>*<xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- And since the ids are concatenated, the 'target' attribute must -->
  <!-- be modified to refect this -->
  <xsl:template match="cnxml:cnxn/@target">
    <xsl:param name="DOC_ID"/>
    <xsl:attribute name="target">
      <xsl:choose>
	<!--Case 1: If cnxn has a document attribute, concatenate that
	value with the target attribute.-->
	<xsl:when test="normalize-space(../@document)">
          <xsl:value-of select="normalize-space(../@document)"/>*<xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<!--Case 2: If cnxn does not have a document attribute,
	concatenate the id of the current document with the target
	attribute.-->
	<xsl:otherwise>
          <xsl:value-of select="$DOC_ID"/>*<xsl:value-of select="normalize-space(.)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="cnxml:cite/@target-id | cnxml:cite/@resource | cnxml:link/@target-id">
    <xsl:param name="DOC_ID"/>
    <xsl:choose>
      <xsl:when test="../@resource">
        <xsl:attribute name="resource">
          <xsl:choose>
            <!-- Case 1: If element has a document attribute, concatenate that value 
                 with the target-id attribute. -->
            <xsl:when test="normalize-space(../@document)">
              <xsl:value-of select="normalize-space(../@document)"/>
              <xsl:text>*</xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <!-- Case 2: If element does not have a document attribute, concatenate 
                 the id of the current document with the target-id attribute. -->
            <xsl:otherwise>
              <xsl:value-of select="$DOC_ID"/>
              <xsl:text>*</xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="target-id">
          <xsl:choose>
            <!-- Case 1: If element has a document attribute, concatenate that value 
                 with the target-id attribute. -->
            <xsl:when test="normalize-space(../@document)">
              <xsl:value-of select="normalize-space(../@document)"/>
              <xsl:text>*</xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <!-- Case 2: If element does not have a document attribute, concatenate 
                 the id of the current document with the target-id attribute. -->
            <xsl:otherwise>
              <xsl:value-of select="$DOC_ID"/>
              <xsl:text>*</xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Normalize values of cnxn attributes, since we count on them 
       for making cross-references and footnotes. -->
  <xsl:template match="cnxml:cnxn/@document">
    <xsl:attribute name="document">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="cnxml:cnxn/@strength">
    <xsl:attribute name="strength">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="cnxml:cnxn/@version">
    <xsl:attribute name="version">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>

  <!-- Transform to common author format -->
  <xsl:template match="mdml4:author">
    <author id="{@id}">
      <xsl:if test="mdml4:honorific">
        <honorific><xsl:value-of select="mdml4:honorific"/></honorific>
      </xsl:if>
      <firstname><xsl:value-of select="mdml4:firstname"/></firstname>
      <xsl:if test="mdml4:othername">
        <othername><xsl:value-of select="mdml4:othername"/></othername>
      </xsl:if>
      <xsl:if test="mdml4:othername">
        <othername><xsl:value-of select="mdml4:othername"/></othername>
      </xsl:if>
      <surname><xsl:value-of select="mdml4:surname"/></surname>
      <xsl:if test="mdml4:lineage">
        <lineage><xsl:value-of select="mdml4:lineage"/></lineage>
      </xsl:if>
      <xsl:if test="mdml4:fullname">
        <fullname><xsl:value-of select="mdml4:fullname"/></fullname>
      </xsl:if>
    </author>
  </xsl:template>

  <!-- Transform to common keyword format -->
  <xsl:template match="mdml4:keyword">
    <keyword><xsl:value-of select="."/></keyword>
  </xsl:template>

  <!-- Grab the content -->
  <xsl:template match="cnxml:content">
    <xsl:param name="DOC_ID"/>
    <cnxml:content>
      <xsl:apply-templates>
        <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
      </xsl:apply-templates>
    </cnxml:content>
  </xsl:template>

  <!-- Grab the glossary -->
  <xsl:template match="cnxml:glossary">
    <cnxml:glossary>
      <xsl:apply-templates />
    </cnxml:glossary>
  </xsl:template>

  <!--Grab the bib file -->
  <xsl:template match="bib:file">
    <xsl:param name="DOC_ID"/>
    <bib:file>
      <xsl:apply-templates>
        <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
      </xsl:apply-templates>
    </bib:file>
  </xsl:template>

  <!-- Default copying rule for cnxml tags -->
  <xsl:template match="cnxml:content//*|cnxml:glossary//*|cnxml:*/@*">
    <xsl:param name="DOC_ID"/>
    <xsl:copy>
      <!-- Must copy the attributes first and separately, so that the
      templates for 'id' and 'target' are guaranteed to match *before*
      we've copied over any children (See XSLT spec 7.1.3 and and
      Michael Kay's XSLT ref. p 167 for rationale) -->
      <xsl:apply-templates select="@*">
        <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
      </xsl:apply-templates>
      <xsl:call-template name="generate-default-type-if-needed"/>
      <xsl:apply-templates select="node()">
        <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
<!-- xsltproc seems to ignore 'nodtdattr' when assembling our 
  collection XML (perhaps the command-line param to xsltproc is not 
  inherited by document()?), so all m:cn elements get the default 
  @base="10" attribute.  So we have to fix that here.
  -->
  <xsl:template match="m:cn/@base">
    <xsl:choose>
      <xsl:when test=".='10'">
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- identity transform for other tags -->
  <xsl:template match="*/@*|*">
    <xsl:param name="DOC_ID"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()">
        <xsl:with-param name="DOC_ID" select="$DOC_ID"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="processing-instruction()">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
