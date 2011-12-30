<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg" xmlns:db="http://docbook.org/ns/docbook" xmlns:d="http://docbook.org/ns/docbook" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ext="http://cnx.org/ns/docbook+" version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/xhtml-1_1/docbook.xsl"/>
<xsl:import href="dbk2xhtml-core.xsl"/>

<!-- Ignore Section title pages overridden in dbkplus.xsl -->
<xsl:import href="../docbook-xsl/xhtml-1_1/titlepage.templates.xsl"/>

<xsl:output indent="yes" method="xml"/>

<!-- ============================================== -->
<!-- Customize docbook params for this style        -->
<!-- ============================================== -->

<xsl:param name="cnx.font.catchall">sans-serif,STIXGeneral,STIXSize</xsl:param>

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="toc.section.depth">1</xsl:param>

<xsl:param name="body.font.family"><xsl:value-of select="$cnx.font.catchall"/></xsl:param>

<xsl:param name="body.font.master">8.5</xsl:param>
<xsl:param name="body.start.indent">0px</xsl:param>

<xsl:param name="header.rule" select="0"/>

<xsl:param name="generate.toc">
appendix  toc,title
<!--chapter   toc,title-->
book      toc,title
</xsl:param>

<!-- To get page titles to match left/right alignment, we need to add blank pages between chapters (wi they all start on the same left/right side) -->
<xsl:param name="double.sided" select="1"/>

<xsl:param name="page.margin.top">0.25in</xsl:param>
<xsl:param name="page.margin.bottom">0.25in</xsl:param>
<xsl:param name="page.margin.inner">1.0in</xsl:param>
<xsl:param name="page.margin.outer">1.0in</xsl:param>
<xsl:param name="cnx.margin.problems">1in</xsl:param>

<xsl:param name="formal.title.placement">
figure after
example before
equation before
table before
procedure before
</xsl:param>

<!--<xsl:param name="xref.with.number.and.title" select="0"/>-->

<xsl:param name="cnx.pagewidth.pixels" select="396"/>
<xsl:param name="cnx.columnwidth.pixels" select="210"/> <!-- 228 -->
<xsl:param name="cnx.image.scaling" select="0.5"/>

<!-- ============================================== -->
<!-- Customize colors and formatting                -->
<!-- ============================================== -->

<xsl:param name="cnx.font.small" select="concat($body.font.master * 0.8, 'pt')"/>
<xsl:param name="cnx.font.large" select="concat($body.font.master * 1.2, 'pt')"/>
<xsl:param name="cnx.font.larger" select="concat($body.font.master * 1.6, 'pt')"/>
<xsl:param name="cnx.font.huge" select="concat($body.font.master * 4.0, 'pt')"/>
<xsl:param name="cnx.color.orange">#FAA61A</xsl:param>
<xsl:param name="cnx.color.blue">#0061AA</xsl:param>
<xsl:param name="cnx.color.red">#D89016</xsl:param>
<xsl:param name="cnx.color.green">#8FB733</xsl:param>
<xsl:param name="cnx.color.silver">#FBF2E2</xsl:param>
<xsl:param name="cnx.color.aqua">#EFF2F9</xsl:param>
<xsl:param name="cnx.color.light-green">#F1F6E6</xsl:param>

<xsl:attribute-set name="root.properties"><xsl:attribute name="class">root-properties</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="list.item.spacing"><xsl:attribute name="class">list-item-spacing</xsl:attribute></xsl:attribute-set>

<!-- Don't indent all the time
<xsl:attribute-set name="normal.para.spacing">
  <xsl:attribute name="text-indent">2em</xsl:attribute>
</xsl:attribute-set>
-->

<xsl:attribute-set name="cnx.underscore"><xsl:attribute name="class">cnx-underscore</xsl:attribute></xsl:attribute-set>

<!-- End-of-chapter questions and problem numbers -->
<xsl:attribute-set name="cnx.question"><xsl:attribute name="class">cnx-question informal-object-properties</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="cnx.question.number"><xsl:attribute name="class">cnx-question-number</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.equation"><xsl:attribute name="class">cnx-equation</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title"><xsl:attribute name="class">cnx-formal-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title.text"><xsl:attribute name="class">cnx-formal-title-text</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.formal.title.inner"><xsl:attribute name="class">cnx-formal-title-inner</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.vertical-spacing"><xsl:attribute name="class">cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="normal.para.spacing"><xsl:attribute name="class">normal-para-spacing cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="list.block.spacing"><xsl:attribute name="class">list-block-spacing cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="list.item.spacing"><xsl:attribute name="class">list-item-spacing cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="list.block.properties"><xsl:attribute name="class">list-block-properties cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="example.title.properties"><xsl:attribute name="class">example-title-properties cnx-formal-title-text</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="figure.title.properties"><xsl:attribute name="class">figure-title-properties cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties"><xsl:attribute name="class">section-title-level1-properties</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="section.title.level2.properties"><xsl:attribute name="class">section-title-level2-properties</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="section.title.number"><xsl:attribute name="class">section-title-number section-title-level1-properties</xsl:attribute></xsl:attribute-set>

<!-- prefixed w/ "cnx." so we don't inherit the background color from formal.object.properties -->
<xsl:attribute-set name="cnx.figure.properties"><xsl:attribute name="class">cnx-figure-properties</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.figure.content"><xsl:attribute name="class">cnx-figure-content</xsl:attribute></xsl:attribute-set>

<!-- "Check for Understanding" is an exercise whose problem 
    is a list. These should be bold or larger
-->
<xsl:attribute-set name="cnx.exercise.listitem"><xsl:attribute name="class">cnx-exercise-listitem</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="formal.object.properties"><xsl:attribute name="class">formal-object-properties cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="informal.object.properties"><xsl:attribute name="class">informal-object-properties cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>

<!-- In Docbook tables inherit formal.object.properties
    This causes the background (including the title) to have a background color.
    See "Customize Table Headings" below for more customizations
 -->
<xsl:attribute-set name="table.properties"><xsl:attribute name="class">table-properties</xsl:attribute></xsl:attribute-set>

<!-- Used to get the indent working properly -->
<xsl:attribute-set name="cnx.formal.object.inner"><xsl:attribute name="class">cnx-formal-object-inner informal-object-properties</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="informal.object.properties"><xsl:attribute name="class">informal-object-properties</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="xref.properties"><xsl:attribute name="class">xref-properties</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="admonition.title.properties"><xsl:attribute name="class">admonition-title-properties cnx-underscore</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="nongraphical.admonition.properties"><xsl:attribute name="class">nongraphical-admonition-properties</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.note"><xsl:attribute name="class">cnx-note</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.note.concept"><xsl:attribute name="class">cnx-note-concept cnx-note</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.note.concept.title"><xsl:attribute name="class">cnx-note-concept-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.note.tip"><xsl:attribute name="class">cnx-note-tip cnx-vertical-spacing</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.note.tip.body"><xsl:attribute name="class">cnx-note-tip-body cnx-note cnx-underscore</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.note.tip.title"><xsl:attribute name="class">cnx-note-tip-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.note.tip.title.inline"><xsl:attribute name="class">cnx-note-tip-title-inline</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.note.feature"><xsl:attribute name="class">cnx-note-feature</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="cnx.note.feature.title"><xsl:attribute name="class">cnx-note-feature-title</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="cnx.note.feature.title.inline"><xsl:attribute name="class">cnx-note-feature-title-inline</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="cnx.note.feature.body"><xsl:attribute name="class">cnx-note-feature-body</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="cnx.note.feature.body.inner"><xsl:attribute name="class">cnx-note-feature-body-inner</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.chapter"><xsl:attribute name="class">cnx-introduction-chapter</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.chapter.number"><xsl:attribute name="class">cnx-introduction-chapter-number</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.chapter.title"><xsl:attribute name="class">cnx-introduction-chapter-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.title"><xsl:attribute name="class">cnx-introduction-title</xsl:attribute></xsl:attribute-set>
<xsl:attribute-set name="cnx.introduction.title.text"><xsl:attribute name="class">cnx-introduction-title-text cnx-underscore</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.table"><xsl:attribute name="class">cnx-introduction-toc-table</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.header"><xsl:attribute name="class">cnx-introduction-toc-header</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.row"><xsl:attribute name="class">cnx-introduction-toc-row</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.number"><xsl:attribute name="class">cnx-introduction-toc-number cnx-introduction-toc-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.number.inline"><xsl:attribute name="class">cnx-introduction-toc-number-inline cnx-underscore</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.introduction.toc.title"><xsl:attribute name="class">cnx-introduction-toc-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.problems.title"><xsl:attribute name="class">cnx-problems-title cnx-problems-subtitle</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.problems.subtitle"><xsl:attribute name="class">cnx-problems-subtitle</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.header.title"><xsl:attribute name="class">cnx-header-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.header.subtitle"><xsl:attribute name="class">cnx-header-subtitle</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.header.pagenumber"><xsl:attribute name="class">cnx-header-pagenumber</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.header.separator"><xsl:attribute name="class">cnx-header-separator</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.index.title.body"><xsl:attribute name="class">cnx-index-title-body cnx-problems-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.titlepage.title"><xsl:attribute name="class">cnx-titlepage-title</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.titlepage.authors"><xsl:attribute name="class">cnx-titlepage-authors</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="cnx.titlepage.strong"><xsl:attribute name="class">cnx-titlepage-strong</xsl:attribute></xsl:attribute-set>


<!-- Page Headers should be marked as all-uppercase.
     Since XSLT1.0 doesn't have fn:uppercase, we'll translate()
-->
<xsl:variable name="cnx.smallcase" select="'abcdefghijklmnopqrstuvwxyz&#xE4;&#xEB;&#xEF;&#xF6;&#xFC;&#xE1;&#xE9;&#xED;&#xF3;&#xFA;&#xE0;&#xE8;&#xEC;&#xF2;&#xF9;&#xE2;&#xEA;&#xEE;&#xF4;&#xFB;&#xE5;&#xF8;&#xE3;&#xF5;&#xE6;&#x153;&#xE7;&#x142;&#xF1;'"/>
<xsl:variable name="cnx.uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ&#xC4;&#xCB;&#xCF;&#xD6;&#xDC;&#xC1;&#xC9;&#xCD;&#xD3;&#xDA;&#xC0;&#xC8;&#xCC;&#xD2;&#xD9;&#xC2;&#xCA;&#xCE;&#xD4;&#xDB;&#xC5;&#xD8;&#xC3;&#xD5;&#xC6;&#x152;&#xC7;&#x141;&#xD1;'"/>

<!-- ============================================== -->
<!-- Custom page layouts for modern-textbook        -->
<!-- ============================================== -->

<!-- Generate custom page layouts for:
     - Chapter introduction
     - 2-column end-of-chapter problems
-->
<xsl:param name="cnx.pagemaster.body">cnx-body</xsl:param>
<xsl:param name="cnx.pagemaster.problems">cnx-problems-2column</xsl:param>
<xsl:template name="user.pagemasters">
    <!-- title pages -->
    
    
    <!-- setup for body pages -->
    


    

    
</xsl:template>

<!-- Override the default body pagemaster so we use a custom body -->
<xsl:template name="select.user.pagemaster">
  <xsl:param name="element"/>
  <xsl:param name="pageclass"/>
  <xsl:param name="default-pagemaster"/>
  <xsl:choose>
    <xsl:when test="$default-pagemaster = 'body'">
      <xsl:value-of select="$cnx.pagemaster.body"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$default-pagemaster"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ============================================== -->
<!-- New Feature: @class='problems-exercises'  -->
<!-- ============================================== -->

<!-- Render problem sections at the bottom of a chapter -->
<xsl:template match="db:chapter">
  <xsl:variable name="master-reference">
    <xsl:call-template name="select.pagemaster"/>
  </xsl:variable>

  <xsl:call-template name="page.sequence">
    <xsl:with-param name="master-reference" select="$master-reference"/>
    <xsl:with-param name="initial-page-number">auto</xsl:with-param>
    <xsl:with-param name="content">
			<xsl:call-template name="chapter.titlepage"/>
      <xsl:apply-templates select="node()[not(contains(@class,'introduction'))]"/>
			<xsl:call-template name="cnx.summarypage"/>
    </xsl:with-param>
  </xsl:call-template>
  
	<xsl:call-template name="cnx.problemspage"/>
</xsl:template>

<xsl:template name="cnx.summarypage">
	<!-- TODO: Create a 1-column Chapter Summary -->
	<xsl:if test="count(db:section/db:sectioninfo/db:abstract) &gt; 0">
		<div space-before="2em" space-after="2em">
			<table>
				
				
				
					<tr>
						<td>
							<div><xsl:text>Chapter Summary</xsl:text></div>
						</td>
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
    <xsl:call-template name="page.sequence">
      <xsl:with-param name="master-reference">
        <xsl:value-of select="$cnx.pagemaster.problems"/>
      </xsl:with-param>
      <xsl:with-param name="initial-page-number">auto</xsl:with-param>
      <xsl:with-param name="content">

				<xsl:call-template name="cnx.end-of-chapter-problems">
					<xsl:with-param name="title">
						<xsl:text>Problems</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="attribute" select="'problems-exercises'"/>
				</xsl:call-template>

      </xsl:with-param>
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
		
		<div class="{$attribute}">
		<div xsl:use-attribute-sets="cnx.formal.title">
			<span xsl:use-attribute-sets="example.title.properties">
				<xsl:copy-of select="$title"/>
			</span>
		</div>

		<!-- This for-each is the main section (1.4 Newton) to print section title -->
		<xsl:for-each select="$context/db:section[descendant::*[contains(@class,$attribute)]]">
			<xsl:variable name="sectionId">
				<xsl:call-template name="object.id"/>
			</xsl:variable>
			<!-- Print the section title and link back to it -->
			<div xsl:use-attribute-sets="cnx.problems.title">
				<a href="#{$sectionId}">
					<xsl:apply-templates select="." mode="object.title.markup">
						<xsl:with-param name="allow-anchors" select="0"/>
					</xsl:apply-templates>
				</a>
			</div>
			<!-- This for-each renders all the sections and exercises and numbers them -->
			<xsl:apply-templates select="descendant::*[contains(@class,$attribute)]/node()[not(self::db:title)]">
				<xsl:with-param name="render" select="true()"/>
			</xsl:apply-templates>
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
      <div xsl:use-attribute-sets="cnx.introduction.toc.number">
        <a href="#{$id}">
          <xsl:apply-templates mode="label.markup" select="."/>
        </a>
      </div>
    </td>
    <td>
      <div xsl:use-attribute-sets="cnx.introduction.toc.title">
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
			<div id="{$id}" xsl:use-attribute-sets="cnx.question">
				<span xsl:use-attribute-sets="cnx.question.number">
					<xsl:apply-templates select="." mode="number"/>
				</span>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="$renderSolution">
						<xsl:variable name="first">
							<xsl:apply-templates select="ext:solution/*[position() = 1]/node()"/>
						</xsl:variable>
						<xsl:copy-of select="$first"/>
						<xsl:apply-templates select="ext:solution/*[position() &gt; 1]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="ext:problem/*[position() = 1][self::db:para]">
								<xsl:apply-templates select="ext:problem/*[position() = 1]/node()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="ext:problem/*[position() = 1]"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="ext:problem/*[position() &gt; 1]"/>
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

<!-- when the placeholder element is encountered (since I didn't want to
      rewrite the match="d:book" template) run a nested for-loop on all
      chapters (and then sections) that contain a solution to be printed ( *[contains(@class,'problems-exercises') and .//ext:solution] ).
      Print the "exercise" solution with numbering.
-->
<xsl:template match="ext:cnx-solutions-placeholder[..//*[contains(@class,'problems-exercises') and .//ext:solution]]">
  <xsl:call-template name="cnx.log"><xsl:with-param name="msg">Injecting custom solution appendix</xsl:with-param></xsl:call-template>

  <xsl:call-template name="page.sequence">
    <xsl:with-param name="master-reference">
      <xsl:value-of select="$cnx.pagemaster.problems"/>
    </xsl:with-param>
    <xsl:with-param name="initial-page-number">auto</xsl:with-param>
    <xsl:with-param name="content">
  
      <a name=""/>
    
      <div xsl:use-attribute-sets="cnx.formal.title">
        <span xsl:use-attribute-sets="example.title.properties">
          <xsl:text>    Answers    </xsl:text>
        </span>
      </div>
      
      <xsl:for-each select="../*[self::db:preface | self::db:chapter | self::db:appendix][.//*[contains(@class,'problems-exercises') and .//ext:solution]]">
  
        <xsl:variable name="chapterId">
          <xsl:call-template name="object.id"/>
        </xsl:variable>
        <!-- Print the chapter number (not title) and link back to it -->
        <div xsl:use-attribute-sets="cnx.problems.title">
          <a href="#{$chapterId}">
            <xsl:apply-templates select="." mode="object.xref.markup"/>
          </a>
        </div>

        <xsl:for-each select="db:section[.//*[contains(@class,'problems-exercises')]]">
          <xsl:variable name="sectionId">
            <xsl:call-template name="object.id"/>
          </xsl:variable>
          <!-- Print the section title and link back to it -->
          <div xsl:use-attribute-sets="cnx.problems.subtitle">
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
  
    </xsl:with-param>
  </xsl:call-template>
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
          <span xsl:use-attribute-sets="section.title.number">
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
      <xsl:when test="number($level) &lt; 6">
        <xsl:value-of select="$level"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>6</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="h{$level}">
    <xsl:if test="ancestor::db:section[1]/@xml:id">
      <xsl:attribute name="id">
        <xsl:value-of select="ancestor::db:section[1]/@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$cnx.title"/>
  </xsl:element>
</xsl:template>


<xsl:template name="chapter.titlepage">
  <!--
  <fo:marker marker-class-name="section.head.marker">
    <xsl:apply-templates mode="title.markup" select="."/>
  </fo:marker>
  -->
	<!-- Taken from docbook-xsl/fo/component.xsl : match="d:chapter" -->
	<xsl:variable name="id">
		<xsl:call-template name="object.id"/>
	</xsl:variable>

	<div id="{$id}" xsl:use-attribute-sets="component.titlepage.properties">
    <xsl:apply-templates mode="cnx.intro" select="d:section"/>
	</div>
</xsl:template>

<xsl:template mode="cnx.intro" match="node()"/>

<!-- Since intro sections are rendered specifically only in the title page, ignore them for normal rendering -->
<xsl:template mode="cnx.intro" match="d:section[contains(@class,'introduction')]">
  <xsl:variable name="title">
    <xsl:apply-templates select=".." mode="title.markup"/>
  </xsl:variable>

  <div class="introduction" xsl:use-attribute-sets="cnx.tilepage.graphic">
    <div xsl:use-attribute-sets="cnx.introduction.chapter">
      <span xsl:use-attribute-sets="cnx.introduction.chapter.number">
        <xsl:apply-templates select=".." mode="label.markup"/>
      </span>
      <span xsl:use-attribute-sets="cnx.introduction.chapter.title">
        <xsl:copy-of select="translate($title, $cnx.smallcase, $cnx.uppercase)"/>
      </span>
    </div>

  <xsl:if test=".//db:figure[contains(@class,'splash')]">
    <xsl:apply-templates mode="cnx.splash" select=".//db:figure[contains(@class,'splash')]"/>
  </xsl:if>
  <xsl:call-template name="chapter.titlepage.toc"/>
  <div xsl:use-attribute-sets="cnx.introduction.title">
    <span xsl:use-attribute-sets="cnx.introduction.title.text">
      <xsl:choose>
        <xsl:when test="db:title">
          <xsl:apply-templates select="db:title/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Introduction</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>     </xsl:text>
    </span>
  </div>
  <xsl:apply-templates select="node()"/>
  </div>

</xsl:template>



<xsl:template name="chapter.titlepage.toc">
<div space-before="2em" space-after="2em">
  <!-- Tables in FOP can't be centered, so we nest them -->
  <xsl:call-template name="table.layout.center">
    <xsl:with-param name="content">
      <table>
        
        
        
          <tr>
            <td>
              <div><xsl:text>Key Concepts</xsl:text></div>
            </td>
          </tr>
        
        
          <xsl:apply-templates mode="introduction.toc" select="../db:section[not(contains(@class,'introduction'))]"/>
        
      </table>
      <xsl:call-template name="component.toc.separator"/>
    </xsl:with-param>
  </xsl:call-template>
</div>
</xsl:template>

<!-- Tables in FOP can't be centered, so we nest them -->
<xsl:template name="table.layout.center">
  <xsl:param name="content"/>

  <table>
    
    
    
    
      <tr>
        <td/>
        <td>

          <table>
            
              <tr><td>
                <xsl:copy-of select="$content"/>
              </td></tr>
            
          </table>

        </td>
        <td/>
      </tr>
    
  </table>
</xsl:template>

<xsl:template mode="introduction.toc" match="db:chapter/db:section[not(contains(@class,'introduction'))]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <tr>
    <td>
      <div xsl:use-attribute-sets="cnx.introduction.toc.number">
        <a href="#{$id}">
          <xsl:apply-templates mode="label.markup" select="."/>
        </a>
      </div>
    </td>
    <td>
      <div xsl:use-attribute-sets="cnx.introduction.toc.title">
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

<!-- Render equations with the number on the RHS -->
<xsl:template match="db:equation">
  <div xsl:use-attribute-set="cnx.equation">
    <xsl:attribute name="id">
      <xsl:call-template name="object.id"/>
    </xsl:attribute>

    <table>
      
      
      
        <tr>
          <td>
            <div text-align="center">
              <xsl:apply-templates/>
            </div>
          </td>
          <td>
            <div text-align="end">
              <xsl:text>(</xsl:text>
              <xsl:apply-templates select="." mode="label.markup"/>
              <xsl:text>)</xsl:text>
            </div>
          </td>
        </tr>
      
    </table>
  </div>
</xsl:template>


<xsl:template name="pi.dbfo_keep-together">
  <xsl:text>always</xsl:text>
</xsl:template>

<!-- The @class may have style attributes encoded in it.
     examples include "color='#ffffcc' background-color='#808080'"
-->
<xsl:template match="@class|processing-instruction('cnx.style')" name="cnx.style.rec">
  <xsl:param name="value" select="concat(normalize-space(.), ' ')"/>
  <xsl:variable name="pair" select="substring-before($value,' ')"/>
  <xsl:variable name="tail" select="substring-after($value,' ')"/>
  <xsl:message>LOG: INFO: Found custom cnx.style PI </xsl:message>
  <xsl:if test="contains($pair,'=')">
  	<xsl:variable name="quot">
  		<xsl:choose>
				<xsl:when test="contains($pair,'&quot;')">"</xsl:when>
				<xsl:otherwise>'</xsl:otherwise>
			</xsl:choose>
  	</xsl:variable>
    <xsl:call-template name="cnx.style.pair">
      <xsl:with-param name="name" select="substring-before($pair,'=')"/>
      <xsl:with-param name="value" select="substring-before(substring-after($pair,$quot), $quot)"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:if test="$tail != ''">
    <xsl:call-template name="cnx.style.rec">
      <xsl:with-param name="value" select="$tail"/>
    </xsl:call-template>
  </xsl:if>    
</xsl:template>

<xsl:template name="cnx.style.pair">
  <xsl:param name="name"/>
  <xsl:param name="value"/>
	<!-- TODO: Customize attribute names that are different between HTML and XSL-FO -->
  <xsl:variable name="attrName" select="$name"/>
  <xsl:message>LOG: INFO: Setting cnx.class.style <xsl:value-of select="$attrName"/> = <xsl:value-of select="$value"/> on <xsl:value-of select="name(..)"/></xsl:message>
  <xsl:attribute name="{$attrName}">
    <xsl:value-of select="$value"/>
  </xsl:attribute>
</xsl:template>

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

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <div id="{$id}" xsl:use-attribute-sets="cnx.figure.properties">
    <xsl:apply-templates select="$c/@class"/>
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of select="$keep.together"/></xsl:attribute>
      <xsl:attribute name="keep-together.within-page"><xsl:value-of select="$keep.together"/></xsl:attribute>
<!--
      <xsl:attribute name="keep-together"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
-->
    </xsl:if>

    <div xsl:use-attribute-sets="cnx.figure.content">
      <xsl:apply-templates select="$c/*[not(self::d:caption)]"/>
    </div>
		<xsl:if test="$renderCaption">
			<span xsl:use-attribute-sets="figure.title.properties">
				<xsl:apply-templates select="$c" mode="object.title.markup">
					<xsl:with-param name="allow-anchors" select="1"/>
				</xsl:apply-templates>
			</span>
			<xsl:apply-templates select="$c/d:caption"/>
		</xsl:if>
  </div>
</xsl:template>

<!-- "Customize Table Headings"
    Taken from docbook-xsl/fo/tables.xsl with modifications marked with "CNX"
 -->
<xsl:template name="table.block">
  <xsl:param name="table.layout" select="NOTANODE"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="param.placement" select="substring-after(normalize-space(                    $formal.title.placement), concat(local-name(.), ' '))"/>

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

  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="self::d:table">
      <div id="{$id}" xsl:use-attribute-sets="table.properties">
        <xsl:if test="$keep.together != ''">
          <xsl:attribute name="keep-together.within-column">
            <xsl:value-of select="$keep.together"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="$placement = 'before'">
          <xsl:call-template name="formal.object.heading">
            <xsl:with-param name="placement" select="$placement"/>
          </xsl:call-template>
        </xsl:if>
<!-- CNX Hack -->
<div xsl:use-attribute-sets="formal.object.properties">
        <xsl:copy-of select="$table.layout"/>
        <xsl:call-template name="table.footnote.block"/>
</div>
        <xsl:if test="$placement != 'before'">
          <xsl:call-template name="formal.object.heading">
            <xsl:with-param name="placement" select="$placement"/>
          </xsl:call-template>
        </xsl:if>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <div id="{$id}" xsl:use-attribute-sets="informaltable.properties">
        <xsl:copy-of select="$table.layout"/>
        <xsl:call-template name="table.footnote.block"/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<!-- A block-level element inside another block-level element should use the inner formatting -->
<xsl:template mode="formal.object.heading" match="*[         ancestor::ext:exercise or          ancestor::db:example or          ancestor::ext:rule or         ancestor::db:glosslist or         ancestor-or-self::db:list]">
  <xsl:param name="object" select="."/>
  <xsl:param name="placement" select="'before'"/>

  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$placement = 'before'">
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:variable>

  <div xsl:use-attribute-sets="cnx.formal.title.inner">
    <xsl:copy-of select="$content"/>
  </div>
</xsl:template>

<xsl:template mode="formal.object.heading" match="*" name="formal.object.heading">
  <xsl:param name="object" select="."/>
  <xsl:param name="placement" select="'before'"/>

  <xsl:variable name="content">
    <xsl:apply-templates select="$object" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </xsl:variable>

  <!-- CNX: added special case for examples and notes -->
  <div xsl:use-attribute-sets="cnx.formal.title">
    <xsl:choose>
      <xsl:when test="self::db:example">
        <span xsl:use-attribute-sets="example.title.properties">
          <xsl:copy-of select="$content"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span xsl:use-attribute-sets="cnx.formal.title.text">
          <xsl:copy-of select="$content"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template name="formal.object">
  <xsl:variable name="placement" select="'before'"/><!--hardcoded-->

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="keep.together">
    <xsl:choose>
      <xsl:when test="self::ext:exercise">
        <xsl:text>3</xsl:text>
      </xsl:when>
      <xsl:when test="self::ext:problem | self::ext:solution">
        <xsl:text>4</xsl:text>
      </xsl:when>
      <xsl:when test="self::ext:*">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <div class="cnx-formal-object">

    <xsl:apply-templates mode="formal.object.heading" select=".">
      <xsl:with-param name="placement" select="$placement"/>
    </xsl:apply-templates>
  
    <xsl:variable name="content">
      <div xsl:use-attribute-sets="cnx.formal.object.inner">
        <xsl:apply-templates select="*[not(self::d:caption)]"/>
        <xsl:apply-templates select="d:caption"/>
      </div>
    </xsl:variable>
  
    <xsl:choose>
      <!-- tables have their own templates and
           are not handled by formal.object -->
      <xsl:when test="self::d:example">
        <div id="{$id}" xsl:use-attribute-sets="example.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of select="$keep.together"/></xsl:attribute>
            <xsl:attribute name="keep-together.within-page"><xsl:value-of select="$keep.together"/></xsl:attribute>
<!--
            <xsl:attribute name="keep-together"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
-->
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </div>
      </xsl:when>
      <xsl:when test="self::d:equation">
        <div id="{$id}" xsl:use-attribute-sets="cnx.equation">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of select="$keep.together"/></xsl:attribute>
            <xsl:attribute name="keep-together.within-page"><xsl:value-of select="$keep.together"/></xsl:attribute>
<!--
            <xsl:attribute name="keep-together"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
-->
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </div>
      </xsl:when>
      <xsl:when test="self::d:procedure">
        <div id="{$id}" xsl:use-attribute-sets="procedure.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of select="$keep.together"/></xsl:attribute>
            <xsl:attribute name="keep-together.within-page"><xsl:value-of select="$keep.together"/></xsl:attribute>
<!--
            <xsl:attribute name="keep-together"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
-->
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div id="{$id}" xsl:use-attribute-sets="formal.object.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of select="$keep.together"/></xsl:attribute>
            <xsl:attribute name="keep-together.within-page"><xsl:value-of select="$keep.together"/></xsl:attribute>
<!--
            <xsl:attribute name="keep-together"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
-->
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </div>

</xsl:template>

<xsl:template match="d:figure/d:caption">
  <div xsl:use-attribute-sets="cnx.figure.caption">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:note">
  <div xsl:use-attribute-sets="cnx.note">
    <xsl:apply-templates select="@class"/>
    <xsl:apply-imports/>
  </div>
</xsl:template>

<xsl:template match="db:note[@type='tip']|db:tip">
  <div xsl:use-attribute-sets="cnx.note.tip">
    <xsl:apply-templates select="@class"/>
    <div xsl:use-attribute-sets="cnx.note.tip.title">
      <span xsl:use-attribute-sets="cnx.note.tip.title.inline">
        <!-- FOP doesn't support @padding-end for fo:inline elements -->
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="db:title/node()|db:label/node()"/>
        <!-- FOP doesn't support @padding-end for fo:inline elements -->
        <xsl:text> </xsl:text>
      </span>
    </div>
    <div xsl:use-attribute-sets="cnx.note.tip.body">
      <xsl:apply-templates select="*[not(self::db:title or self::db:label)]"/>
    </div>
  </div>
</xsl:template>

<!-- "feature" notes contain an image in the title. Handle them specially -->
<xsl:template match="db:note[db:title/db:mediaobject]">
  <div xsl:use-attribute-sets="cnx.note.feature">
    <xsl:apply-templates select="@class"/>
    <xsl:apply-templates select="db:title/node()|db:label/node()"/>
    <div xsl:use-attribute-sets="cnx.note.feature.body">
    	<xsl:apply-templates select="processing-instruction('cnx.style')"/>
			<div xsl:use-attribute-sets="cnx.note.feature.body.inner">
				<xsl:apply-templates select="node()[not(self::db:title or self::db:label or processing-instruction('cnx.style'))]"/>
			</div>
    </div>
  </div>
</xsl:template>

<!-- Lists inside an exercise (that isn't at the bottom of the chapter)
     (ie "Check for Understanding")
     have a larger number. overriding docbook-xsl/fo/lists.xsl
     see <xsl:template match="d:orderedlist/d:listitem">
 -->
<xsl:template match="ext:exercise[not(ancestor-or-self::*[contains(@class,'problems-exercises')])]/ext:problem/d:orderedlist/d:listitem" mode="item-number">
  <div xsl:use-attribute-sets="cnx.exercise.listitem">
    <xsl:apply-imports/>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- Customize index page for modern-textbook       -->
<!-- ============================================== -->

<xsl:template name="index.titlepage">
  <div xsl:use-attribute-sets="cnx.formal.title">
        <span xsl:use-attribute-sets="example.title.properties">
          <xsl:apply-templates select="." mode="title.markup"/>
        </span>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- Customize Table of Contents                    -->
<!-- ============================================== -->

<xsl:attribute-set name="toc.line.properties"><xsl:attribute name="class">toc-line-properties</xsl:attribute></xsl:attribute-set>

<xsl:attribute-set name="table.of.contents.titlepage.recto.style"><xsl:attribute name="class">table-of-contents-titlepage-recto-style, cnx-underscore</xsl:attribute></xsl:attribute-set>

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

  <div xsl:use-attribute-sets="toc.line.properties">  
    <span keep-with-next.within-line="always">
      
      <a href="#{$id}">  

<!-- CNX: Add the word "Chapter" or Appendix in front of the number -->
        <xsl:if test="self::db:appendix or self::db:chapter">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="local-name()"/>
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="$label != ''">
          <xsl:copy-of select="$label"/>
          <xsl:value-of select="$autotoc.label.separator"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="title.markup"/>  
      </a>
    </span>
    <span keep-together.within-line="always"> 
      <a href="#{$id}">
      </a>
    </span>
  </div>
</xsl:template>

<!-- ============================================== -->
<!-- Customize page headers                         -->
<!-- ============================================== -->

<!-- Custom page header -->
<xsl:template name="header.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

  <xsl:variable name="context" select="ancestor-or-self::*[self::db:preface | self::db:chapter | self::db:appendix | self::ext:cnx-solutions-placeholder]"/>

  <xsl:variable name="subtitle">
    <!-- Don't render the section name.
      <xsl:choose>
        <xsl:when test="ancestor::d:book and ($double.sided != 0)">
          <fo:retrieve-marker retrieve-class-name="section.head.marker"
                              retrieve-position="first-including-carryover"
                              retrieve-boundary="page-sequence"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="titleabbrev.markup"/>
        </xsl:otherwise>
      </xsl:choose>
    -->
    <xsl:apply-templates select="$context" mode="title.markup"/>
  </xsl:variable>
  
  <xsl:variable name="title">
    <!-- Convert titles to uppercase -->
    <xsl:variable name="title">
      <xsl:apply-templates select="$context" mode="object.xref.markup"/>
    </xsl:variable>
    <span xsl:use-attribute-sets="cnx.header.title">
      <xsl:value-of select="translate($title, $cnx.smallcase, $cnx.uppercase)"/>
    </span>
    
    <!-- Add a separator and convert subtitle to uppercase -->
    <xsl:if test="$subtitle != '' and $subtitle != $title">
      <span xsl:use-attribute-sets="cnx.header.separator">
        <xsl:text> | </xsl:text>
      </span>
      <span xsl:use-attribute-sets="cnx.header.subtitle">
        <xsl:value-of select="translate($subtitle, $cnx.smallcase, $cnx.uppercase)"/>
      </span>
    </xsl:if>
  </xsl:variable>

  <div>
    <!-- pageclass can be front, body, back -->
    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->
    <xsl:choose>
      <xsl:when test="$pageclass = 'titlepage'">
        <!-- nop; no footer on title pages -->
      </xsl:when>

      <xsl:when test="$double.sided != 0 and $sequence = 'even'                       and $position='left'">
        <span xsl:use-attribute-sets="cnx.header.pagenumber">
          PGNUM
        </span>
        <xsl:text>     </xsl:text>
        <xsl:copy-of select="$title"/>
      </xsl:when>

      <xsl:when test="$double.sided != 0 and ($sequence = 'odd' or $sequence = 'first')                       and $position='right'">
        <xsl:copy-of select="$title"/>
        <xsl:text>     </xsl:text>
        <span xsl:use-attribute-sets="cnx.header.pagenumber">
          PGNUM
        </span>
      </xsl:when>

      <xsl:when test="$double.sided = 0 and $position='center'">
        PGNUM
      </xsl:when>

      <xsl:when test="$sequence='blank'">
        <xsl:choose>
          <xsl:when test="$double.sided != 0 and $position = 'left'">
            <span xsl:use-attribute-sets="cnx.header.pagenumber">
              PGNUM
            </span>
          </xsl:when>
          <xsl:when test="$double.sided = 0 and $position = 'center'">
            <span xsl:use-attribute-sets="cnx.header.pagenumber">
              PGNUM
            </span>
          </xsl:when>
          <xsl:otherwise>
            <!-- nop -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!-- nop -->
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>



<xsl:template name="select.pagemaster">
  <xsl:text>body</xsl:text>
</xsl:template>
<xsl:template name="page.sequence">
  <xsl:param name="content"/>
  <xsl:copy-of select="$content"/>
</xsl:template>


</xsl:stylesheet>
