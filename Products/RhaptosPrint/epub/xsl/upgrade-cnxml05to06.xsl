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

<!-- We need to grab the metadata from module_export_template since the md:metadata may be unusable -->
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
    <xsl:variable name="url">
        <xsl:call-template name="cnx.url"/>
        <xsl:value-of select="$cnx.module.id"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$version"/>
        <xsl:text>/index.cnxml/@@metadata</xsl:text>
    </xsl:variable>
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: NET: Getting md:metadata info from url '<xsl:value-of select="$url"/>'</xsl:with-param></xsl:call-template>
    <xsl:variable name="metadata" select="document($url)"/>
	    <xsl:choose>
	        <xsl:when test="count($metadata) != 0">
			    <xsl:copy>
			        <xsl:apply-templates select="@*"/>
			        <xsl:call-template name="cnx.copy.remote">
			            <xsl:with-param name="nodes" select="$metadata/metadata/*"/>
			        </xsl:call-template>
			    </xsl:copy>
	        </xsl:when>
	        <xsl:otherwise>
	            <xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: NET: Could not get md:metadata info from url '<xsl:value-of select="$url"/>'</xsl:with-param></xsl:call-template>
                <xsl:apply-imports/>
	        </xsl:otherwise>
	    </xsl:choose>
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
    <xsl:element name="md:{local-name($node)}">
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