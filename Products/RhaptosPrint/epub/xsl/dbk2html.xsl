<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file converts dbk files to chunked html which is used in the offline HTML zip file.
    * Modifies links to be localized for offline zip file
 -->
<xsl:import href="dbk2epub.xsl"/>
<xsl:import href="dbk2html-media.xsl"/>

<xsl:param name="cnx.epub.start.filename" select="concat('start', $html.ext)"/>

<!-- Discard the "unsupported media link" and convert the inner c:media element -->
<xsl:template match="db:link[c:media]">
    <xsl:apply-templates select="c:media"/>
</xsl:template>


<!-- Chunk out a separate "start.html" file just above the OEBPS dir that has a link to the TOC -->
<xsl:template match="/">
    <xsl:variable name="titleFilename">
         <xsl:call-template name="make-relative-filename">
             <xsl:with-param name="base.dir" select="$base.dir"/>
             <xsl:with-param name="base.name">
                 <xsl:value-of select="$root.filename"/>
                 <xsl:value-of select="$html.ext"/>
             </xsl:with-param>
         </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="content">
        <xsl:choose>
            <xsl:when test="db:book/@ext:element='module'">
               <xsl:variable name="filename">
                    <xsl:call-template name="make-relative-filename">
                        <xsl:with-param name="base.dir" select="$base.dir"/>
                        <xsl:with-param name="base.name">
                            <xsl:apply-templates select=".//db:preface" mode="recursive-chunk-filename"/>
                        </xsl:with-param>
                    </xsl:call-template>
               </xsl:variable>
               <html>
                   <head>
                       <script type="text/javascript">
                           window.location.href="<xsl:value-of select="$filename"/>";
                       </script>
                   </head>
                   <body>
                       <a href="{$titleFilename}">Open the title page</a>
                       <a href="{$filename}">Open the module</a>
                   </body>
               </html>
            </xsl:when>
            <xsl:otherwise>
                <!-- It's a collection and has a TOC so make a frame -->
                <xsl:variable name="tocFilename">
                    <!-- The following is taken from Docbook. Apparently this is sprinkled (~ 6 times) in the Docbook Source -->
                    <xsl:call-template name="make-relative-filename">
                        <xsl:with-param name="base.dir" select="$base.dir"/>
                        <xsl:with-param name="base.name">
                            <xsl:call-template name="toc-href"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
            
                <html>
                    <frameset cols="20%,80%">
                        <frame src="{$tocFilename}" />
                        <frame src="{$titleFilename}" name="main" />
                    </frameset>
                </html>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:call-template name="write.chunk"> 
        <xsl:with-param name="filename"> 
            <xsl:value-of select="$cnx.epub.start.filename" /> 
        </xsl:with-param> 
        <xsl:with-param name="method" select="'xml'" /> 
        <xsl:with-param name="encoding" select="'utf-8'" /> 
        <xsl:with-param name="indent" select="'yes'" /> 
        <xsl:with-param name="quiet" select="$chunk.quietly" /> 
        <xsl:with-param name="doctype-public" select="''"/> <!-- intentionally blank --> 
        <xsl:with-param name="doctype-system" select="''"/> <!-- intentionally blank --> 
        <xsl:with-param name="content" select="$content"/> 
    </xsl:call-template>

    <xsl:apply-imports/>
</xsl:template>

<!-- In order to get the TOC frame to open links in the main window, we add a target to the <a> tag -->
<!-- TAKEN FROM: docbook-xsl/xhtml-1_1/autotoc.xsl -->
<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="depth" select="1"/>
  <xsl:param name="depth.from.context" select="8"/>

 <span>
  <xsl:attribute name="class"><xsl:value-of select="local-name(.)"/></xsl:attribute>

  <!-- * if $autotoc.label.in.hyperlink is zero, then output the label -->
  <!-- * before the hyperlinked title (as the DSSSL stylesheet does) -->
  <xsl:if test="$autotoc.label.in.hyperlink = 0">
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:copy-of select="$label"/>
    <xsl:if test="$label != ''">
      <xsl:value-of select="$autotoc.label.separator"/>
    </xsl:if>
  </xsl:if>

  <!-- START: edit -->
  <a target="main">
  <!-- END: edit -->
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
        <xsl:with-param name="context" select="$toc-context"/>
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:attribute>
    
  <!-- * if $autotoc.label.in.hyperlink is non-zero, then output the label -->
  <!-- * as part of the hyperlinked title -->
  <xsl:if test="not($autotoc.label.in.hyperlink = 0)">
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="label.markup"/>
    </xsl:variable>
    <xsl:copy-of select="$label"/>
    <xsl:if test="$label != ''">
      <xsl:value-of select="$autotoc.label.separator"/>
    </xsl:if>
  </xsl:if>

    <xsl:apply-templates select="." mode="titleabbrev.markup"/>
  </a>
  </span>
</xsl:template>


<xsl:template match="db:link[@ext:resource!='']">
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Generating local link to resource</xsl:with-param></xsl:call-template>
    <xsl:variable name="linkend">
        <xsl:if test="$cnx.module.id != ''">
            <!-- If we're generating a collection, include the module dir. -->
            <xsl:value-of select="@ext:document"/>
            <xsl:text>/</xsl:text>
        </xsl:if>
        <xsl:value-of select="@ext:resource"/>
    </xsl:variable>
    <xsl:variable name="content">
        <xsl:value-of select="@ext:resource"/>
    </xsl:variable>

    <xsl:message>linkend=<xsl:value-of select="$linkend"/> content="<xsl:value-of select="$content"/></xsl:message>
    
    <xsl:call-template name="simple.xlink">
	    <xsl:with-param name="node" select="."/>
	    <xsl:with-param name="linkend" select="$linkend"/>
	    <xsl:with-param name="content" select="$content"/>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>