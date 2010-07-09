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

<!-- This file converts dbk+ extension elements (like exercise problem and solution)
	 using the Docbook templates.
	* Customizes title generation
	* Numbers exercises
	* Labels exercises (and links to them)
 -->
<xsl:include href="param.xsl"/>

<xsl:template match="*" mode="xref-to">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Using element name for xref text: <xsl:value-of select="local-name()"/> id=<xsl:value-of select="(@id|@xml:id)[1]"/></xsl:with-param></xsl:call-template>
	<xsl:value-of select="local-name()"/>
</xsl:template>

<!-- EXERCISE templates -->

<!-- Generate custom HTML for an ext:problem and ext:solution.
	Taken from docbook-xsl/xhtml-1_1/formal.xsl: <xsl:template match="example">
 -->
<xsl:template match="ext:*">

  <xsl:variable name="param.placement" select="substring-after(normalize-space($formal.title.placement), concat(local-name(.), ' '))"/>

  <xsl:variable name="placement">
    <xsl:choose>
      <xsl:when test="contains($param.placement, ' ')">
        <xsl:value-of select="substring-before($param.placement, ' ')"/>
      </xsl:when>
      <xsl:when test="$param.placement = ''">before</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$param.placement"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="formal.object">
    <xsl:with-param name="placement" select="$placement"/>
  </xsl:call-template>

</xsl:template>

<!-- Can't use docbook-xsl/common/gentext.xsl because labels and titles can contain XML (makes things icky) -->
<xsl:template match="ext:*" mode="object.title.markup">
	<xsl:apply-templates select="." mode="cnx.template"/>
</xsl:template>

<!-- Link to the exercise and to the solution. HACK: We can do this because solutions are within a module (html file) -->
<xsl:template match="ext:exercise" mode="object.title.markup">
	<xsl:apply-templates select="." mode="cnx.template"/>
	<xsl:variable name="id" select="@xml:id"/>
        <xsl:for-each select="//db:section[@ext:element='solutions']/ext:solution[@exercise-id=$id]">
                <xsl:text> </xsl:text>
                <!-- TODO: gentext for "(" -->
                <xsl:text>(</xsl:text>
                <xsl:call-template name="simple.xlink">
                        <xsl:with-param name="linkend" select="@xml:id"/>
                        <xsl:with-param name="content">
                                <!-- TODO: gentext for "Go to" -->
                                <xsl:text>Go to</xsl:text>
                                <xsl:text> </xsl:text>
                                <xsl:choose>
                                        <xsl:when test="ext:label">
                                                <xsl:apply-templates select="ext:label" mode="cnx.label" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                                <!-- TODO: gentext for "Solution" -->
                                                <xsl:text>Solution</xsl:text>
                                        </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="count(//ext:solution[@exercise-id=$id]) > 1">
                                        <xsl:number count="ext:solution[@exercise-id=$id]" level="any" format=" A"/>
                                </xsl:if>
                        </xsl:with-param>
                </xsl:call-template>
                <!-- TODO: gentext for ")" -->
                <xsl:text>)</xsl:text>
        </xsl:for-each>
</xsl:template>

<xsl:template match="ext:solution" mode="object.title.markup">
	<xsl:apply-templates select="." mode="cnx.template"/>
	<xsl:variable name="exerciseId" select="@exercise-id"/>
	<xsl:if test="$exerciseId!='' and parent::db:section[@ext:element='solutions']">
		<xsl:text> </xsl:text>
                <!-- TODO: gentext for "(" -->
		<xsl:text>(</xsl:text>
		  <xsl:call-template name="simple.xlink">
		    <xsl:with-param name="linkend" select="$exerciseId"/>
		    <xsl:with-param name="content">
                        <!-- TODO: gentext for "Return to" -->
		    	<xsl:text>Return to</xsl:text>
                        <xsl:text> </xsl:text>
                        <xsl:choose>
                            <xsl:when test="//ext:exercise[@xml:id=$exerciseId]/ext:label">
                                <xsl:apply-templates select="//ext:exercise[@xml:id=$exerciseId]/ext:label" mode="cnx.label" />
                            </xsl:when>
                            <xsl:when test="//ext:exercise[@xml:id=$exerciseId][ancestor::db:example]">
                                <!-- TODO: gentext for "Problem" -->
                                <xsl:text>Problem</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- TODO: gentext for "Exercise" -->
                                <xsl:text>Exercise</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
		    </xsl:with-param>
		  </xsl:call-template>
                <!-- TODO: gentext for ")" -->
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="ext:*" mode="insert.label.markup">
	<xsl:param name="label" select="ext:label"/>
	<xsl:if test="$label!=''">
		<xsl:apply-templates select="$label" mode="cnx.label"/>
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:apply-templates select="." mode="number"/>
</xsl:template>

<xsl:template match="ext:*[not(db:title)]" mode="title.markup"/>
<xsl:template match="ext:*/db:title"/>
<xsl:template match="ext:exercise|ext:problem|ext:solution" mode="label.markup"/>

<xsl:template match="ext:exercise" mode="cnx.template">
	<xsl:call-template name="cnx.label">
		<xsl:with-param name="default">
                        <xsl:choose>
                                <xsl:when test="ancestor::db:example">
                                        <!-- TODO: gentext for "Problem" -->
                                	<xsl:text>Problem</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                        <!-- TODO: gentext for "Exercise" -->
                                	<xsl:text>Exercise</xsl:text>
                                </xsl:otherwise>
                        </xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="ext:rule" mode="cnx.template">
        <xsl:variable name="type">
                <xsl:choose>
                        <xsl:when test="@type">
                                <xsl:value-of select="translate(@type,$cnx.upper,$cnx.lower)"/>
                        </xsl:when>
                        <xsl:otherwise>rule</xsl:otherwise>
                </xsl:choose>
        </xsl:variable>
	<xsl:variable name="defaultLabel">
		<xsl:choose>
			<!-- TODO: gentext for "Rule" and custom rules -->
			<xsl:when test="$type='theorem'"><xsl:text>Theorem</xsl:text></xsl:when>
			<xsl:when test="$type='lemma'"><xsl:text>Lemma</xsl:text></xsl:when>
			<xsl:when test="$type='corollary'"><xsl:text>Corollary</xsl:text></xsl:when>
			<xsl:when test="$type='law'"><xsl:text>Law</xsl:text></xsl:when>
			<xsl:when test="$type='proposition'"><xsl:text>Proposition</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Rule</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name="cnx.label">
		<xsl:with-param name="default" select="$defaultLabel"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="cnx.label" match="ext:*[ext:label]" mode="cnx.template" priority="0">
	<xsl:param name="c" select="."/>
	<xsl:param name="default"></xsl:param>
	<xsl:choose>
		<xsl:when test="$c/ext:label">
			<xsl:apply-templates select="$c/ext:label" mode="cnx.label"/>
		</xsl:when>
		<xsl:when test="$default=''">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: No default set when calling template cnx.label</xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$default"/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="$c/." mode="number"/>
	<xsl:if test="$c/db:title">
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="$c/." mode="title.markup"/>
	</xsl:if>
</xsl:template>

<xsl:template match="ext:problem" mode="cnx.template">
	<xsl:apply-templates select="ext:label" mode="cnx.label"/>
	<xsl:if test="ext:label and db:title">
		<xsl:text>: </xsl:text>
	</xsl:if>
        <xsl:apply-templates select="db:title" mode="title.markup"/>
</xsl:template>

<xsl:template match="ext:solution" mode="cnx.template">
        <xsl:variable name="exerciseId" select="@exercise-id"/>
        <xsl:choose>
                <xsl:when test="ext:label">
                	<xsl:apply-templates select="ext:label" mode="cnx.label"/>
                </xsl:when>
                <xsl:otherwise>
                        <!-- TODO: gentext for "Solution" -->
                        <xsl:text>Solution</xsl:text>
                </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="count(//ext:solution[@exercise-id=$exerciseId]) > 1">
                <xsl:number count="ext:solution[@exercise-id=$exerciseId]" level="any" format=" A"/>
        </xsl:if>
        <xsl:if test="parent::db:section[@ext:element='solutions']">
                <xsl:text> </xsl:text>
                <!-- TODO: gentext for "to" -->
                <xsl:text>to</xsl:text>
                <xsl:text> </xsl:text>
                <xsl:choose>
                        <xsl:when test="//ext:exercise[@xml:id=$exerciseId]/ext:label">
                                <xsl:apply-templates select="//ext:exercise[@xml:id=$exerciseId]/ext:label" mode="cnx.label" />
                        </xsl:when>
                        <xsl:otherwise>
                                <!-- TODO: gentext for "Exercise" -->
                                <xsl:text>Exercise</xsl:text>
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="." mode="number"/>
        </xsl:if>
</xsl:template>

<xsl:template match="ext:label" mode="cnx.label">
	<xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="ext:label"/>



<!-- NUMBERING templates -->

<!-- By default, nothing is numbered. -->
<xsl:template match="ext:*" mode="number"/>

<xsl:template name="cnx.chapter.number">
	<xsl:for-each select="ancestor::db:chapter">
                <xsl:apply-templates select="." mode="label.markup"/>
		<xsl:apply-templates select="." mode="intralabel.punctuation"/>
        </xsl:for-each>
</xsl:template>

<xsl:template match="ext:exercise" mode="number">
	<xsl:call-template name="cnx.chapter.number"/>
        <xsl:if test="ancestor::db:section[@ext:element='module']">
                <xsl:number format="1" level="any" from="db:chapter" count="*[@ext:element='module']"/>
		<xsl:apply-templates select="." mode="intralabel.punctuation"/>
	</xsl:if>
	<xsl:number format="1." level="any" from="*[@ext:element='module']" count="ext:exercise[not(ancestor::db:example)]"/>
</xsl:template>

<xsl:template match="ext:exercise[ancestor::db:example]" mode="number">
        <xsl:if test="count(ancestor::db:example[1]//ext:exercise) > 1">
        	<xsl:number format="1." level="any" from="db:example" count="ext:exercise"/>
        </xsl:if>
</xsl:template>

<xsl:template match="ext:rule" mode="number">
	<xsl:variable name="type" select="translate(@type,$cnx.upper,$cnx.lower)"/>
	<xsl:call-template name="cnx.chapter.number"/>
        <xsl:choose>
                <xsl:when test="$type='rule' or not(@type)">
                        <xsl:number format="1." level="any" from="db:preface|db:chapter" count="ext:rule[translate(@type,$cnx.upper,$cnx.lower)='rule' or not(@type)]"/>
                </xsl:when>
                <xsl:otherwise>
                        <xsl:number format="1." level="any" from="db:preface|db:chapter" count="ext:rule[translate(@type,$cnx.upper,$cnx.lower)=$type]"/>
                </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template match="ext:solution" mode="number">
	<xsl:variable name="exerciseId" select="@exercise-id"/>
	<xsl:apply-templates select="//*[@xml:id=$exerciseId]" mode="number"/>
</xsl:template>



<!-- XREF templates -->

<xsl:template match="ext:*" mode="xref-to">
	<xsl:apply-templates select="." mode="object.xref.markup"/>
</xsl:template>

<xsl:template match="ext:*" mode="object.xref.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="referrer"/>
  <xsl:param name="verbose" select="1"/>
	<!-- TODO: Reimplement using gentext defaults -->
	<xsl:apply-templates select="." mode="cnx.template"/>
</xsl:template>



    <!-- Add an asterisk linking to a module's attribution. The XPath ugliness below is like preface/prefaceinfo/title/text(), but also for chapter and section -->
    <!-- FIXME: not working for some reason in modules that front matter (i.e. in db:preface).   Haven't tested module EPUBs or EPUBs of collections with no subcollections. -->
    <xsl:template match="*[@ext:element='module']/db:*[contains(local-name(),'info')]/db:title/text()">
    	<xsl:variable name="moduleId">
    		<xsl:call-template name="cnx.id">
    			<xsl:with-param name="object" select="../../.."/>
    		</xsl:call-template>
    	</xsl:variable>
    	<xsl:variable name="id">
    		<xsl:value-of select="$attribution.section.id"/>
    		<xsl:value-of select="$cnx.module.separator"/>
    		<xsl:value-of select="$moduleId"/>
    	</xsl:variable>
        <xsl:value-of select="."/>
        <!-- FIXME: Remove the reference to the <sup/> element by using docbook templates and move this into dbkplus.xsl -->
        <xsl:call-template name="inline.superscriptseq">
        	<xsl:with-param name="content">
                <xsl:call-template name="simple.xlink">
                        <xsl:with-param name="linkend" select="$id"/>
                        <xsl:with-param name="content">
							<xsl:text>*</xsl:text>
                        </xsl:with-param>
                </xsl:call-template>
        	</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
<!-- Otherwise the call to "simple.xlink" above would fail. -->
<xsl:template match="db:title/text()" mode="common.html.attributes"/>
<xsl:template match="db:title/text()" mode="html.title.attribute"/>

<xsl:template match="ext:persons">
	<xsl:call-template name="person.name.list">
		<xsl:with-param name="person.list" select="db:*"/>
	</xsl:call-template>
</xsl:template>

</xsl:stylesheet>
