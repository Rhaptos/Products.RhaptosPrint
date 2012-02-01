<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg" xmlns:db="http://docbook.org/ns/docbook" xmlns:d="http://docbook.org/ns/docbook" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ext="http://cnx.org/ns/docbook+" version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/xhtml-1_1/docbook.xsl"/>
<xsl:import href="dbk2xhtml-core.xsl"/>
<xsl:import href="dbk2xhtml-overrides.xsl"/>

<xsl:output indent="no" method="xml"/>

<!-- ============================================== -->
<!-- Customize docbook params for this style        -->
<!-- ============================================== -->

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="toc.section.depth">1</xsl:param>

<xsl:param name="body.font.master">8.5</xsl:param>
<xsl:param name="body.start.indent">0px</xsl:param>

<xsl:param name="header.rule" select="0"/>

<xsl:param name="generate.toc">
appendix  toc,title
<!--chapter   toc,title-->
book      toc,title
</xsl:param>

<xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
</xsl:param>

<!-- ============================================== -->
<!-- New Feature: @class='problems-exercises'  -->
<!-- ============================================== -->

<!-- Render problem sections at the bottom of a chapter -->
<xsl:template match="db:chapter">

	<!-- Taken from docbook-xsl/fo/component.xsl : match="d:chapter" -->
	<xsl:variable name="id">
		<xsl:call-template name="object.id"/>
	</xsl:variable>

	<div id="{$id}" class="chapter">
		<xsl:call-template name="chapter.titlepage"/>
    <xsl:apply-templates mode="cnx.intro" select="d:section"/>
    <xsl:apply-templates select="node()[not(contains(@class,'introduction'))]"/>
		<xsl:call-template name="cnx.summarypage"/>
  	<xsl:call-template name="cnx.problemspage"/>
  </div>
</xsl:template>

<xsl:template name="cnx.summarypage">
	<!-- TODO: Create a 1-column Chapter Summary -->
	<xsl:if test="count(db:section/db:sectioninfo/db:abstract) &gt; 0">
		<div class="cnx-summarypage">
			<table>
			    <tr>
						<th>
							<div><xsl:text>Chapter Summary</xsl:text></div>
						</th>
					</tr>
					<xsl:apply-templates mode="cnx.chapter.summary" select="db:section"/>
			</table>
		</div>
	</xsl:if>

 	<!-- <?cnx.eoc class=review title=Review Notes?> -->
 	<xsl:variable name="context" select="."/>
	<xsl:for-each select=".//processing-instruction('cnx.eoc')[not(contains(.,'problems-exercises'))]">
		<xsl:variable name="val" select="concat(' ', .)"/>
		<xsl:variable name="class" select="substring-before(substring-after($val,' class=&quot;'), '&quot;')"/>
		<xsl:variable name="title" select="substring-before(substring-after(.,' title=&quot;'),'&quot;')"/>

			<xsl:message>LOG: INFO: Looking for some end-of-chapter matter: class=[<xsl:value-of select="$class"/>] title=[<xsl:value-of select="$title"/>] inside a [<xsl:value-of select="name()"/>]</xsl:message>
		
		<xsl:if test="$context//*[contains(@class,$class)]">
			<xsl:message>LOG: INFO: Found some end-of-chapter matter: class=[<xsl:value-of select="$class"/>] title=[<xsl:value-of select="$title"/>]</xsl:message>
			<xsl:call-template name="cnx.end-of-chapter-problems">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="title">
					<xsl:value-of select="$title"/>
				</xsl:with-param>
				<xsl:with-param name="attribute" select="$class"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

</xsl:template>

<xsl:template name="cnx.problemspage">
  <!-- Create a 2column page for problems. Insert the section number and title before each problem set -->
  <xsl:if test="count(.//*[contains(@class,'problems-exercises')]) &gt; 0">
    <xsl:call-template name="cnx.end-of-chapter-problems">
      <xsl:with-param name="title">
        <xsl:text>Problems</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="attribute" select="'problems-exercises'"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="cnx.end-of-chapter-problems">
	<xsl:param name="context" select="."/>
	<xsl:param name="title"/>
	<xsl:param name="attribute"/>

	<!-- Create a 1-column Listing of "Conceptual Questions" or "end-of-chapter Problems" -->
	<xsl:if test="count($context//*[contains(@class,$attribute)]) &gt; 0">
		<xsl:comment>CNX: Start Area: "<xsl:value-of select="$title"/>"</xsl:comment>
		
		<div class="cnx-eoc {$attribute}">
		<div class="title">
			<span>
				<xsl:copy-of select="$title"/>
			</span>
		</div>

		<!-- This for-each is the main section (1.4 Newton) to print section title -->
		<xsl:for-each select="$context/db:section[descendant::*[contains(@class,$attribute)]]">
			<xsl:variable name="sectionId">
				<xsl:call-template name="object.id"/>
			</xsl:variable>
			<div class="section">
        <!-- Print the section title and link back to it -->
        <div class="title">
          <a href="#{$sectionId}">
            <xsl:apply-templates select="." mode="object.title.markup">
              <xsl:with-param name="allow-anchors" select="0"/>
            </xsl:apply-templates>
          </a>
        </div>
        <!-- This for-each renders all the sections and exercises and numbers them -->
        <div class="body">
          <xsl:apply-templates select="descendant::*[contains(@class,$attribute)]/node()[not(self::db:title)]">
            <xsl:with-param name="render" select="true()"/>
          </xsl:apply-templates>
        </div>
      </div>
		</xsl:for-each>
    </div>
	</xsl:if>
</xsl:template>

<xsl:template mode="cnx.chapter.summary" match="db:section[not(contains(@class,'introduction')) and db:sectioninfo/db:abstract]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <tr>
    <td>
      <div class="cnx-introduction-toc-number cnx-introduction-toc-title">
        <a href="#{$id}">
          <xsl:apply-templates mode="label.markup" select="."/>
        </a>
      </div>
    </td>
    <td>
      <div class="cnx-introduction-toc-title">
        <xsl:apply-templates select="db:sectioninfo/db:abstract">
          <xsl:with-param name="render" select="true()"/>
        </xsl:apply-templates>
      </div>
    </td>
  </tr>
</xsl:template>

<!-- Renders an abstract onnly when "render" is set to true().
-->
<xsl:template match="d:abstract" mode="titlepage.mode">
  <xsl:param name="render" select="false()"/>
  <xsl:if test="$render">
    <xsl:apply-imports/>
  </xsl:if>
</xsl:template>

<!-- Renders an exercise only when "render" is set to true().
     This allows us to move certain problem-sets to the end of a chapter.
     Also, wither it renders the problem or the solution.
     This way we can render the solutions at the end of a book
-->
<xsl:template match="ext:exercise[ancestor-or-self::*[@class]]">
<xsl:param name="render" select="false()"/>
<xsl:param name="renderSolution" select="false()"/>
<xsl:variable name="class" select="ancestor-or-self::*[@class][1]/@class"/>
<xsl:if test="$render">
<xsl:choose>
	<xsl:when test="ancestor::db:chapter//processing-instruction('cnx.eoc')[contains(., $class)] or $class='problems-exercises'">
		<xsl:variable name="id">
			<xsl:call-template name="object.id"/>
		</xsl:variable>
		<xsl:if test="not(not($renderSolution) or ext:solution)">
			<xsl:call-template name="cnx.log"><xsl:with-param name="msg">Found a c:problem without a solution. skipping...</xsl:with-param></xsl:call-template>
		</xsl:if>
		<xsl:if test="not($renderSolution) or ext:solution">
			<div id="{$id}" class="exercise">
				<span class="cnx-gentext-exercise cnx-gentext-n">
					<xsl:apply-templates select="." mode="number"/>
				</span>
				<span class="cnx-gentext-exercise cnx-gentext-autogen">
  				<xsl:text> </xsl:text>
  		  </span>
				<xsl:choose>
					<xsl:when test="$renderSolution">
            <span class="solution">
						  <xsl:apply-templates select="ext:solution/*[position() = 1]/node()"/>
						</span>
						<div class="solution">
  						<xsl:apply-templates select="ext:solution/*[position() &gt; 1]"/>
  				  </div>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="ext:problem/*[position() = 1][self::db:para]">
							  <span class="problem">
  								<xsl:apply-templates select="ext:problem/*[position() = 1]/node()"/>
  						  </span>
							</xsl:when>
							<xsl:otherwise>
							  <div class="problem">
  								<xsl:apply-templates select="ext:problem/*[position() = 1]"/>
  						  </div>
							</xsl:otherwise>
						</xsl:choose>
						<div class="problem">
  						<xsl:apply-templates select="ext:problem/*[position() &gt; 1]"/>
  				  </div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-imports/>
	</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>

<xsl:template match="ext:exercise[not(ancestor::db:example)]" mode="number">
  <xsl:param name="type" select="@type"/>
  <xsl:choose>
    <xsl:when test="$type and $type != ''">
      <xsl:number format="1." level="any" from="db:chapter" count="ext:exercise[not(ancestor::db:example) and @type=$type]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:number format="1." level="any" from="db:chapter" count="ext:exercise[not(ancestor::db:example)]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================== -->
<!-- New Feature: Solutions at end of book          -->
<!-- ============================================== -->
<!-- TODO: end-of-book solutions code is bitrotting -->
<!-- when the placeholder element is encountered (since I didn't want to
      rewrite the match="d:book" template) run a nested for-loop on all
      chapters (and then sections) that contain a solution to be printed ( *[contains(@class,'problems-exercises') and .//ext:solution] ).
      Print the "exercise" solution with numbering.
-->
<xsl:template match="ext:cnx-solutions-placeholder[..//*[contains(@class,'problems-exercises') and .//ext:solution]]">
  <xsl:call-template name="cnx.log"><xsl:with-param name="msg">Injecting custom solution appendix</xsl:with-param></xsl:call-template>

  <div class="cnx-answers">
  <div class="title">
    <span>
      <xsl:text>Answers</xsl:text>
    </span>
  </div>
  
  <xsl:for-each select="../*[self::db:preface | self::db:chapter | self::db:appendix][.//*[contains(@class,'problems-exercises') and .//ext:solution]]">

    <xsl:variable name="chapterId">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <!-- Print the chapter number (not title) and link back to it -->
    <div class="problem">
      <a href="#{$chapterId}">
        <xsl:apply-templates select="." mode="object.xref.markup"/>
      </a>
    </div>

    <xsl:for-each select="db:section[.//*[contains(@class,'problems-exercises')]]">
      <xsl:variable name="sectionId">
        <xsl:call-template name="object.id"/>
      </xsl:variable>
      <!-- Print the section title and link back to it -->
      <div class="cnx-problems-subtitle">
        <a href="#{$sectionId}">
          <xsl:apply-templates select="." mode="object.title.markup">
            <xsl:with-param name="allow-anchors" select="0"/>
          </xsl:apply-templates>
        </a>
      </div>
      <xsl:apply-templates select=".//*[contains(@class,'problems-exercises')]">
        <xsl:with-param name="render" select="true()"/>
        <xsl:with-param name="renderSolution" select="true()"/>
      </xsl:apply-templates>
    </xsl:for-each>

  </xsl:for-each>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- New Feature: @class='introduction'             -->
<!-- ============================================== -->

<xsl:template name="section.heading">
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="1"/>
  <xsl:param name="title"/>
  <xsl:param name="marker.title"/>

  <xsl:variable name="cnx.title">
      <xsl:choose>
        <xsl:when test="$marker.title != ''">
          <span class="section-title-number">
            <xsl:value-of select="substring-before($title, $marker.title)"/>
          </span>
          <xsl:copy-of select="$marker.title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$title"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:variable>


  <xsl:variable name="head">
    <xsl:choose>
      <xsl:when test="number($level) &lt; 5">
        <xsl:value-of select="$level"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>5</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="h{$level + 1}">
    <xsl:if test="ancestor::db:section[1]/@xml:id">
      <xsl:attribute name="id">
        <xsl:value-of select="ancestor::db:section[1]/@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$cnx.title"/>
  </xsl:element>
</xsl:template>

<xsl:template mode="cnx.intro" match="node()"/>

<!-- Since intro sections are rendered specifically only in the title page, ignore them for normal rendering -->
<xsl:template mode="cnx.intro" match="d:section[contains(@class,'introduction')]">
  <xsl:variable name="title">
    <xsl:apply-templates select=".." mode="title.markup"/>
  </xsl:variable>

  <div class="introduction">

  <xsl:if test=".//db:figure[contains(@class,'splash')]">
    <xsl:apply-templates mode="cnx.splash" select=".//db:figure[contains(@class,'splash')]"/>
  </xsl:if>
  <xsl:call-template name="chapter.titlepage.toc"/>
  <div class="cnx-introduction-title">
    <span class="cnx-introduction-title-text">
      <xsl:choose>
        <xsl:when test="db:title">
          <xsl:apply-templates select="db:title/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Introduction</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#160; &#160; &#160;</xsl:text>
    </span>
  </div>
  <xsl:apply-templates select="node()"/>
  </div>

</xsl:template>



<xsl:template name="chapter.titlepage.toc">
      <table class="cnx-introduction-toc">
          <tr>
            <td colspan="2"><xsl:text>Key Concepts</xsl:text></td>
          </tr>
          <xsl:apply-templates mode="introduction.toc" select="../db:section[not(contains(@class,'introduction'))]"/>
        
      </table>
      <xsl:call-template name="component.toc.separator"/>
</xsl:template>


<xsl:template mode="introduction.toc" match="db:chapter/db:section[not(contains(@class,'introduction'))]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <tr>
    <td>
      <div class="cnx-introduction-toc-number cnx-introduction-toc-title">
        <a href="#{$id}">
          <xsl:apply-templates mode="label.markup" select="."/>
        </a>
      </div>
    </td>
    <td>
      <div class="cnx-introduction-toc-title">
        <a href="#{$id}">
          <xsl:apply-templates mode="title.markup" select="."/>
        </a>
      </div>
    </td>
  </tr>
</xsl:template>

<!-- HACK: Fix section numbering. Search for "CNX" below to find the change -->
<!-- From ../docbook-xsl/common/labels.xsl -->
<xsl:template match="d:section" mode="label.markup">
  <!-- if this is a nested section, label the parent -->
  <xsl:if test="local-name(..) = 'section'">
    <xsl:variable name="parent.section.label">
      <xsl:call-template name="label.this.section">
        <xsl:with-param name="section" select=".."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$parent.section.label != '0'">
      <xsl:apply-templates select=".." mode="label.markup"/>
      <xsl:apply-templates select=".." mode="intralabel.punctuation"/>
    </xsl:if>
  </xsl:if>

  <!-- if the parent is a component, maybe label that too -->
  <xsl:variable name="parent.is.component">
    <xsl:call-template name="is.component">
      <xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:variable>

  <!-- does this section get labelled? -->
  <xsl:variable name="label">
    <xsl:call-template name="label.this.section">
      <xsl:with-param name="section" select="."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$section.label.includes.component.label != 0                 and $parent.is.component != 0">
    <xsl:variable name="parent.label">
      <xsl:apply-templates select=".." mode="label.markup"/>
    </xsl:variable>
    <xsl:if test="$parent.label != ''">
      <xsl:apply-templates select=".." mode="label.markup"/>
      <xsl:apply-templates select=".." mode="intralabel.punctuation"/>
    </xsl:if>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$label != 0">
      <xsl:variable name="format">
        <xsl:call-template name="autolabel.format">
          <xsl:with-param name="format" select="$section.autolabel"/>
        </xsl:call-template>
      </xsl:variable>
<!-- CNX: Don't include the introduction Section
      <xsl:number format="{$format}" count="d:section"/>
-->
      <xsl:number format="{$format}" count="d:section[not(contains(@class,'introduction'))]"/>

    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- ============================================== -->
<!-- New Feature: Custom splash image
  -->
<!-- ============================================== -->

<!-- Splash figures are moved up so they need to be rendered in a separate mode -->
<xsl:template match="d:figure[contains(@class,'splash')]"/>
<xsl:template mode="cnx.splash" match="d:figure[contains(@class,'splash')]">
  <xsl:call-template name="cnx.figure"/>
</xsl:template>


<!-- ============================================== -->
<!-- Customize block-text structure
     (notes, examples, exercises, nested elts)
  -->
<!-- ============================================== -->

<!-- Handle figures differently.
Combination of formal.object and formal.object.heading -->
<xsl:template match="d:figure" name="cnx.figure">
	<xsl:param name="c" select="."/>
	<xsl:param name="renderCaption" select="true()"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
    	<xsl:with-param name="object" select="$c"/>
    </xsl:call-template>
  </xsl:variable>

  <div id="{$id}" class="figure">
    <xsl:choose>
      <xsl:when test="$c/@orient = 'vertical' or not($c/db:informalfigure)">
        <div class="cnx-figure-content">
          <xsl:apply-templates select="$c/*[not(self::d:caption)]"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <table class="cnx-figure-horizontal">
          <tr>
            <xsl:for-each select="$c/db:informalfigure">
              <td>
                <xsl:apply-templates select="."/>
              </td>
            </xsl:for-each>
          </tr>
        </table>
        <xsl:apply-templates select="$c/*[not(self::db:informalfigure or self::db:caption)]"/>
      </xsl:otherwise>
    </xsl:choose>
		<xsl:if test="$renderCaption">
			<span class="figure-title-properties">
				<xsl:apply-templates select="$c" mode="object.title.markup">
					<xsl:with-param name="allow-anchors" select="1"/>
				</xsl:apply-templates>
			</span>
			<xsl:apply-templates select="$c/d:caption"/>
		</xsl:if>
  </div>
</xsl:template>


<!-- A block-level element inside another block-level element should use the inner formatting -->
<xsl:template mode="formal.object.heading" match="*[         ancestor::ext:exercise or          ancestor::db:example or          ancestor::ext:rule or         ancestor::db:glosslist or         ancestor-or-self::db:list]">
  <xsl:param name="object" select="."/>

  <xsl:variable name="content">
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:variable>

  <div>
    <xsl:copy-of select="$content"/>
  </div>
</xsl:template>

<xsl:template mode="formal.object.heading" match="*" name="formal.object.heading">
  <xsl:param name="object" select="."/>

  <xsl:variable name="content">
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:variable>

  <!-- CNX: added special case for examples and notes -->
  <div class="title">
    <span>
      <xsl:copy-of select="$content"/>
    </span>
  </div>
</xsl:template>

<xsl:template name="formal.object">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

    <xsl:apply-templates mode="formal.object.heading" select=".">
    </xsl:apply-templates>
  
    <xsl:variable name="content">
      <div class="cnx-formal-object-inner">
        <xsl:apply-templates select="*[not(self::d:caption)]"/>
        <xsl:apply-templates select="d:caption"/>
      </div>
    </xsl:variable>
  
    <xsl:choose>
      <!-- tables have their own templates and
           are not handled by formal.object -->
      <xsl:when test="self::d:example">
        <div id="{$id}" class="cnx-example">
          <xsl:copy-of select="$content"/>
        </div>
      </xsl:when>
      <xsl:when test="self::d:equation">
        <div id="{$id}" class="cnx-equation">
          <xsl:copy-of select="$content"/>
        </div>
      </xsl:when>
      <xsl:when test="self::d:procedure">
        <div id="{$id}" class="cnx-procedure">
          <xsl:copy-of select="$content"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div id="{$id}" class="formal-object-properties">
          <xsl:copy-of select="$content"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="d:figure/d:caption">
  <div class="caption">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:note">
  <div class="cnx-note">
    <xsl:apply-templates select="@class"/>
    <xsl:apply-imports/>
  </div>
</xsl:template>

<!-- TODO: Possible bitrotted template -->
<xsl:template match="db:note[@type='tip']|db:tip">
  <div class="cnx-note-tip">
    <xsl:apply-templates select="@class"/>
    <div class="cnx-note-tip-title">
      <span class="cnx-note-tip-title-inline">
        <!-- FOP doesn't support @padding-end for fo:inline elements -->
        <xsl:text>&#160;</xsl:text>
        <xsl:apply-templates select="db:title/node()|db:label/node()"/>
        <!-- FOP doesn't support @padding-end for fo:inline elements -->
        <xsl:text>&#160;</xsl:text>
      </span>
    </div>
    <div class="cnx-note-tip-body cnx-note cnx-underscore">
      <xsl:apply-templates select="*[not(self::db:title or self::db:label)]"/>
    </div>
  </div>
</xsl:template>

<!-- Lists inside an exercise (that isn't at the bottom of the chapter)
     (ie "Check for Understanding")
     have a larger number. overriding docbook-xsl/fo/lists.xsl
     see <xsl:template match="d:orderedlist/d:listitem">
 -->
<xsl:template match="ext:exercise[not(ancestor-or-self::*[contains(@class,'problems-exercises')])]/ext:problem/d:orderedlist/d:listitem" mode="item-number">
  <div class="cnx-gentext-listitem cnx-gentext-n">
    <xsl:apply-imports/>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- Customize index page for modern-textbook       -->
<!-- ============================================== -->

<!-- If it's rendered in multiple columns the indexdiv gets a "h3" tag and, if the title div doesn't have one the title will show up alone in 1 column with the indexdivs in another -->
<xsl:template name="index.titlepage">
  <div class="title">
    <h2>
      <xsl:apply-templates select="." mode="title.markup"/>
    </h2>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- Customize Table of Contents                    -->
<!-- ============================================== -->

<!-- Don't include the introduction section in the TOC -->
<xsl:template match="db:section[contains(@class,'introduction')]" mode="toc"/>

<!-- Don't render sections that contain a class that is collated at the end of the chapter (problems + Exercises, Conceptual Questions, etc -->
<xsl:template match="db:section[@class]">
  <xsl:variable name="class" select="@class"/>
  <xsl:choose>
    <xsl:when test="not(ancestor::db:chapter[.//processing-instruction('cnx.eoc')[contains(., $class)]])">
      <xsl:message>LOG: DEBUG: Rendering a section with class=<xsl:value-of select="@class"/></xsl:message>
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>LOG: DEBUG: NOT Rendering a section with class=<xsl:value-of select="@class"/></xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="toc.line">
  <xsl:param name="toc-context" select="NOTANODE"/>  
  <xsl:variable name="id">  
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="label">  
    <xsl:apply-templates select="." mode="label.markup"/>  
  </xsl:variable>

  <div class="toc-line-properties">  
      <a href="#{$id}">  

<!-- CNX: Add the word "Chapter" or Appendix in front of the number -->
        <xsl:if test="self::db:appendix or self::db:chapter">
<span class="cnx-gentext-{local-name()} cnx-gentext-autogenerated">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="local-name()"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
</span>
        </xsl:if>

        <xsl:if test="$label != ''">
          <xsl:copy-of select="$label"/>
          <xsl:value-of select="$autotoc.label.separator"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="title.markup"/>  
      </a>
  </div>
</xsl:template>

</xsl:stylesheet>
