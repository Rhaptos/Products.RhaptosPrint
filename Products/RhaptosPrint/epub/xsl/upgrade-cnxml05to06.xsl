<xsl:stylesheet
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:md4="http://cnx.rice.edu/mdml/0.4"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="param.xsl"/>
<xsl:import href="ident.xsl"/>
<xsl:import href="cnxml-upgrade/cnxml05to06.xsl"/>

<xsl:template match="c:metadata[not(md4:*)]|md:*|md4:*">
	<xsl:call-template name="ident"/>
</xsl:template>

<!-- Grab the licensors from the website -->
<xsl:template match="c:metadata[md4:*]">
    <!-- Some modules have "**new**" as their version number. In this case, use "latest" -->
    <xsl:variable name="ver" select="/c:document/c:metadata/md4:version/text()"/>
    <xsl:variable name="version">
        <xsl:choose>
	        <xsl:when test="$ver and $ver != '**new**' and $ver != 'None'">
	            <xsl:value-of select="$ver"/>
	        </xsl:when>
	        <xsl:otherwise>
                <xsl:text>latest</xsl:text>
	        </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="url" select="concat($cnx.url, $cnx.module.id, '/', $version, '/module_export_template')"/>
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: NET: Getting licensor info from url '<xsl:value-of select="$url"/>'</xsl:with-param></xsl:call-template>
    <xsl:variable name="moduleExportTemplate" select="document($url)"/>
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
        <md4:licensorlist>
            <xsl:call-template name="cnx.copy.remote">
                <xsl:with-param name="nodes" select="$moduleExportTemplate/module/metadata/licensor"/>
            </xsl:call-template>
        </md4:licensorlist>
    </xsl:copy>
</xsl:template>

<!-- XSL doesn't allow xsl:apply-templates on remotely-retrieved nodes, so copy them manually -->
<xsl:template name="cnx.copy.remote">
    <xsl:param name="nodes"/>
    <xsl:param name="node.count" select="count($nodes)"/>
    <xsl:param name="count" select="1"/>
    <xsl:choose>
        <xsl:when test="$count &gt; $node.count"></xsl:when>
        <xsl:otherwise>
        
	        <!-- Determine the type of the node, and call the proper template -->
	        <xsl:variable name="node" select="$nodes[position()=$count]"/>
	        
	        <xsl:choose>
	            <xsl:when test="local-name($node) != ''">
			      <xsl:call-template name="cnx.copy.remote.element">
			        <xsl:with-param name="node" select="$node"/>
			      </xsl:call-template>
	            </xsl:when>
	            <xsl:otherwise>
	              <xsl:call-template name="cnx.copy.remote.node">
	                <xsl:with-param name="node" select="$node"/>
	              </xsl:call-template>
	            </xsl:otherwise>
	        </xsl:choose>

			<xsl:call-template name="cnx.copy.remote">
			  <xsl:with-param name="nodes" select="$nodes"/>
			  <xsl:with-param name="node.count" select="$node.count"/>
			  <xsl:with-param name="count" select="$count+1"/>
			</xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cnx.copy.remote.element">
    <xsl:param name="node"/>
    <xsl:element name="md4:{local-name($node)}">
        <xsl:apply-templates select="$node/@*"/>
        <xsl:call-template name="cnx.copy.remote">
            <xsl:with-param name="nodes" select="$node/node()"/>
        </xsl:call-template>
    </xsl:element>
</xsl:template>

<xsl:template name="cnx.copy.remote.node">
    <xsl:param name="node"/>
    <xsl:copy-of select="$node"/>
</xsl:template>

</xsl:stylesheet>