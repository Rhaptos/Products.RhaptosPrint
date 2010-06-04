<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  version="1.0">

<!-- This file chunks svg elements in a module into separate svg files and changes the file extension
	so that when "convert" runs through and converts SVG to PNG (or JPEG), the docbook points to
	the correct file.
 -->

<xsl:include href="debug.xsl"/>
<xsl:include href="../docbook-xsl/xhtml-1_1/chunker.xsl"/>
<xsl:include href="ident.xsl"/>

<!-- Possible options for this param:
	* "" to disable chunking
	* "svg" to chunk but not convert
	* "png" to chunk and (later) convert to PNG using the stderr from this xsl and imagemagick's convert
	* "jpg" to chunk and (later) convert to JPEG using the stderr from this xsl and imagemagick's convert
 -->
<xsl:param name="cnx.svg.extension"></xsl:param>
<xsl:param name="chunk.quietly">1</xsl:param>
<xsl:param name="svg.doctype-public">-//W3C//DTD SVG 1.1//EN</xsl:param>
<xsl:param name="svg.doctype-system">http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd</xsl:param>
<xsl:param name="svg.media-type">image/svg+xml</xsl:param>

<xsl:template match="db:imagedata[svg:svg]">
	<db:imagedata width="{svg:svg/@width}" depth="{svg:svg/@height}">
		<xsl:apply-templates select="@*"/>
		<xsl:if test="svg:svg/svg:metadata/pmml2svg:baseline-shift">
			<xsl:attribute name="pmml2svg:baseline-shift">
				<xsl:value-of select="svg:svg/svg:metadata/pmml2svg:baseline-shift"/>
			</xsl:attribute>
		</xsl:if>
		<!-- If we're chunking (and converting), then set the filename attrib and chunk it! -->
		<xsl:if test="$cnx.svg.extension!=''">
			<xsl:variable name="id" select="../@xml:id"/>
			<!-- Only convert if the output file type is not SVG -->
			<xsl:if test="$cnx.svg.extension!='svg'">
				<xsl:message>
					<xsl:value-of select="$id"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$cnx.svg.extension"/>
				</xsl:message>
			</xsl:if>
			<xsl:variable name="filename">
				<xsl:value-of select="$id"/>
				<xsl:text>.svg</xsl:text>
			</xsl:variable>
			<xsl:variable name="imageFile">
				<xsl:value-of select="$id"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="$cnx.svg.extension"/>
			</xsl:variable>
			<xsl:attribute name="fileref">
				<xsl:value-of select="$imageFile"/>
			</xsl:attribute>
		  <xsl:call-template name="write.chunk">
		    <xsl:with-param name="filename" select="$filename"/>
		    <xsl:with-param name="content" select="svg:svg"/>
		    <xsl:with-param name="doctype-public" select="$svg.doctype-public"/>
		    <xsl:with-param name="doctype-system" select="$svg.doctype-system"/>
		    <xsl:with-param name="media-type" select="$svg.media-type"/>
		    <xsl:with-param name="quiet" select="$chunk.quietly"/>
		  </xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="node()"/>
	</db:imagedata>

</xsl:template>

</xsl:stylesheet>