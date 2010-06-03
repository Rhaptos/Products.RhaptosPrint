<xsl:stylesheet version="1.0"
	xmlns:c="http://cnx.rice.edu/cnxml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    >
<!-- This file:
	* Does all the logging
	* Optionally provides an XPath to the current context (where the error occurred)
	* Logs any unmatched elements
-->


<!-- Used for logging to know what the current module is -->
<xsl:param name="cnx.module.id" select="/c:document/@id"/>
<!-- The following parameters are used for batch processing and gathering statistics -->
<xsl:param name="cnx.log.onlybugs">no</xsl:param> 
<xsl:param name="cnx.log.onlyaggregate">yes</xsl:param>
<xsl:param name="cnx.log.nowarn">no</xsl:param> 

<!-- Catch-all -->
<xsl:template match="*">
	<xsl:call-template name="cnx.log">
		<xsl:with-param name="isBug">yes</xsl:with-param>
		<xsl:with-param name="msg">
			<xsl:text>BUG: Could not match Element </xsl:text>
	  		<xsl:value-of select="local-name(..)"/>
			<xsl:text>/</xsl:text>
	  		<xsl:value-of select="local-name(.)"/>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="debugPathPrinter">
	<xsl:if test="../.."><!-- Root is a node, and confuses the printing -->
		<xsl:for-each select="..">
			<xsl:call-template name="debugPathPrinter"/>
		</xsl:for-each>
	</xsl:if>
	<xsl:text>/</xsl:text>
	<xsl:value-of select="local-name(.)"/>
	<xsl:text>[</xsl:text>
	<xsl:choose>
		<xsl:when test="@xml:id">
			<xsl:text>@xml:id='</xsl:text>
			<xsl:value-of select="@xml:id"/>
			<xsl:text>'</xsl:text>
		</xsl:when>
		<xsl:when test="@id">
			<xsl:text>@id='</xsl:text>
			<xsl:value-of select="@id"/>
			<xsl:text>'</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="position()"/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>]</xsl:text>
</xsl:template>

<xsl:template name="cnx.log">
	<xsl:param name="msg" />
	<xsl:param name="isBug">no</xsl:param>
	<xsl:param name="node" select="."/>
	<xsl:if test="($cnx.log.onlybugs != 'no' and $isBug != 'no') or $cnx.log.onlybugs = 'no'">
	<xsl:if test="not(starts-with($msg, 'WARNING: ')) or $cnx.log.nowarn='no'"> 
		<xsl:choose>
			<xsl:when test="$cnx.log.onlyaggregate != 'no'">
				<xsl:message>
					<xsl:text>LOG: </xsl:text>
				  	<xsl:value-of select="$msg"/>
				</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>LOG: </xsl:text>
					<xsl:text>{ module: "</xsl:text>
				  	<xsl:value-of select="$cnx.module.id"/>
					<xsl:text>", message: "</xsl:text>
				  	<xsl:value-of select="$msg"/>
				  	<xsl:text>", xpath: "</xsl:text>
				  	<xsl:call-template name="debugPathPrinter"/>
				  	<xsl:text>"}</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose> 
	</xsl:if>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>