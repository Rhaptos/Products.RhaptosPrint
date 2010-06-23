<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:ext="http://cnx.org/ns/docbook+"
  version="1.0">

<!-- This file converts dbk files to chunked html which is used in EPUB generation.
	* Stores customizations and docbook settings specific to Connexions
	* Shifts images that were converted from MathML so they line up with text nicely
	* Puts equation numbers on the RHS of an equation
	* Disables equation and figure numbering inside things like examples and glossaries
	* Adds @class attributes to elements for custom styling (like c:rule, c:figure)
 -->

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/epub/docbook.xsl"/>
<xsl:import href="param.xsl"/>

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"></xsl:param>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>
<xsl:param name="chunk.section.depth" select="0"></xsl:param>
<xsl:param name="chunk.first.sections" select="0"></xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="xref.with.number.and.title">0</xsl:param>
<xsl:param name="toc.section.depth">0</xsl:param>

<xsl:output indent="yes" method="xml"/>

<!-- Output the PNG with the baseline info -->
<xsl:template match="@pmml2svg:baseline-shift">
	<xsl:attribute name="style">
	    <!-- Ignore width and height information for now
		<xsl:text>widt</xsl:text>
		<xsl:value-of select="@width"/>
		<xsl:text>; height:</xsl:text>
		<xsl:value-of select="@depth"/>
		<xsl:text>;</xsl:text>
		-->
	  	<xsl:text>vertical-align:-</xsl:text>
	  	<xsl:value-of select="." />
	  	<xsl:text>pt;</xsl:text>
  	</xsl:attribute>
</xsl:template>

<!-- Ignore the SVG element and use the @fileref (SVG-to-PNG conversion) -->
<xsl:template match="*['imagedata'=local-name() and @fileref]" xmlns:svg="http://www.w3.org/2000/svg">
	<img src="{@fileref}">
		<xsl:apply-templates select="@pmml2svg:baseline-shift"/>
		<!-- Ignore the SVG child -->
	</img>
<!--
  <object id="{$id}" type="image/svg+xml" data="{$chunkfn}" width="{@width}" height="{@height}">
 	<xsl:if test="svg:metadata/pmml2svg:baseline-shift">
  	  <xsl:attribute name="style">position:relative; top:<xsl:value-of
		select="svg:metadata/pmml2svg:baseline-shift" />px;</xsl:attribute>
  	</xsl:if>
	<img src="{@fileref}" width="{@width}" height="{@height}"/>
  </object>
--></xsl:template>


<!-- Put the equation number on the RHS -->
<xsl:template match="equation">
  <div class="equation">
    <xsl:attribute name="id">
      <xsl:call-template name="object.id"/>
    </xsl:attribute>
	<xsl:apply-templates/>
	<span class="label">
	  <xsl:text>(</xsl:text>
	  <xsl:apply-templates select="." mode="label.markup"/>
      <xsl:text>)</xsl:text>
    </span>
  </div>
</xsl:template>


<!-- Don't number examples inside exercises. Original code taken from docbook-xsl/common/labels.xsl -->
<xsl:template match="example[ancestor::glossentry
            or ancestor::*[@ext:element='rule']
            ]" mode="label.markup">
</xsl:template>
<xsl:template match="figure|table|example" mode="label.markup">
  <xsl:variable name="pchap"
                select="(ancestor::chapter
                        |ancestor::appendix
                        |ancestor::article[ancestor::book])[last()]"/>
  <xsl:variable name="name" select="name()"/>
  
  <xsl:variable name="prefix">
    <xsl:if test="count($pchap) &gt; 0">
      <xsl:apply-templates select="$pchap" mode="label.markup"/>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$prefix != ''">
            <xsl:apply-templates select="$pchap" mode="label.markup"/>
            <xsl:apply-templates select="$pchap" mode="intralabel.punctuation"/>
          <xsl:number format="1" from="chapter|appendix" count="*[$name=name() and not(
               ancestor::glossentry
               or ancestor::*[@ext:element='rule']
               
          )]" level="any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number format="1" from="book|article" level="any" count="*[$name=name() and not(
               ancestor::glossentry
               or ancestor::*[@ext:element='rule']
               
          )]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Override of docbook-xsl/xhtml-1_1/html.xsl -->
<xsl:template match="*[@ext:element|@class]" mode="class.value">
  <xsl:param name="class" select="local-name(.)"/>
  <xsl:variable name="cls">
  	<xsl:value-of select="$class"/>
  	<xsl:if test="@ext:element">
  		<xsl:text> </xsl:text>
  		<xsl:value-of select="@ext:element"/>
  	</xsl:if>
  	<xsl:if test="@class">
  		<xsl:text> </xsl:text>
  		<xsl:value-of select="@class"/>
  	</xsl:if>
  </xsl:variable>
  <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Adding to @class: "<xsl:value-of select="$cls"/>"</xsl:with-param></xsl:call-template>
  <!-- permit customization of class value only -->
  <!-- Use element name by default -->
  <xsl:value-of select="$cls"/>
</xsl:template>

<!-- Override of docbook-xsl/xhtml-1_1/xref.xsl -->
<xsl:template match="*[@XrefLabel]" mode="xref-to">
	<xsl:value-of select="@XrefLabel"/>
</xsl:template>

<xsl:template match="inlineequation" mode="xref-to">
	<xsl:text>Equation</xsl:text>
</xsl:template>

<xsl:template match="caption" mode="xref-to">
	<xsl:apply-templates select="."/>
</xsl:template>

<!-- Subfigures are converted to images inside a figure with an anchor.
	With this code, any xref to a subfigure contains the text of the figure.
	I just added "ancestor::figure" when searching for the context.
 -->
<xsl:template match="anchor" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="verbose" select="1"/>

  <xsl:variable name="context" select="(ancestor::figure| ancestor::simplesect                                        |ancestor::section                                        |ancestor::sect1                                        |ancestor::sect2                                        |ancestor::sect3                                        |ancestor::sect4                                        |ancestor::sect5                                        |ancestor::refsection                                        |ancestor::refsect1                                        |ancestor::refsect2                                        |ancestor::refsect3                                        |ancestor::chapter                                        |ancestor::appendix                                        |ancestor::preface                                        |ancestor::partintro                                        |ancestor::dedication                                        |ancestor::acknowledgements                                        |ancestor::colophon                                        |ancestor::bibliography                                        |ancestor::index                                        |ancestor::glossary                                        |ancestor::glossentry                                        |ancestor::listitem                                        |ancestor::varlistentry)[last()]"/>

  <xsl:choose>
    <xsl:when test="$xrefstyle != ''">
      <xsl:apply-templates select="." mode="object.xref.markup">
        <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
        <xsl:with-param name="referrer" select="$referrer"/>
        <xsl:with-param name="verbose" select="$verbose"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$context" mode="xref-to">
        <xsl:with-param name="purpose" select="'xref'"/>
        <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
        <xsl:with-param name="referrer" select="$referrer"/>
        <xsl:with-param name="verbose" select="$verbose"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Add a template for newlines.
     The cnxml2docbook adds a processing instruction named <?cnx.newline?>
     and is matched here
     see http://www.sagehill.net/docbookxsl/LineBreaks.html
-->
<xsl:template match="processing-instruction('cnx.newline')">
	<xsl:comment>cnx.newline</xsl:comment>
	<br/>
</xsl:template>
<xsl:template match="processing-instruction('cnx.newline.underline')">
	<xsl:comment>cnx.newline.underline</xsl:comment>
	<hr/>
</xsl:template>

<!-- Fix up TOC-generation for the ncx file.
	Overrides code in docbook-xsl/docbook.xsl using code from docbook-xsl/xhtml-1_1/autotoc.xsl
 -->
  <xsl:template match="book|
                       article|
                       part|
                       reference|
                       preface|
                       chapter|
                       bibliography|
                       appendix|
                       glossary|
                       section|
                       sect1|
                       sect2|
                       sect3|
                       sect4|
                       sect5|
                       refentry|
                       colophon|
                       bibliodiv[title]|
                       setindex|
                       index"
                mode="ncx">
    <xsl:variable name="depth" select="count(ancestor::*)"/>
    <xsl:variable name="title">
      <xsl:if test="$epub.autolabel != 0">
        <xsl:variable name="label.markup">
          <xsl:apply-templates select="." mode="label.markup" />
        </xsl:variable>
        <xsl:if test="normalize-space($label.markup)">
          <xsl:value-of
            select="concat($label.markup,$autotoc.label.separator)" />
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="." mode="title.markup" />
    </xsl:variable>

    <xsl:variable name="href">
      <xsl:call-template name="href.target.with.base.dir">
        <xsl:with-param name="context" select="/" />
        <!-- Generate links relative to the location of root file/toc.xml file -->
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="id">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:variable>
    <xsl:variable name="order">
      <xsl:value-of select="$depth +
                                  count(preceding::part|
                                  preceding::reference|
                                  preceding::book[parent::set]|
                                  preceding::preface|
                                  preceding::chapter|
                                  preceding::bibliography|
                                  preceding::appendix|
                                  preceding::article|
                                  preceding::glossary|
                                  preceding::section[not(parent::partintro)]|
                                  preceding::sect1[not(parent::partintro)]|
                                  preceding::sect2|
                                  preceding::sect3|
                                  preceding::sect4|
                                  preceding::sect5|
                                  preceding::refentry|
                                  preceding::colophon|
                                  preceding::bibliodiv[title]|
                                  preceding::index)"/>
    </xsl:variable>


  <xsl:variable name="depth2">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'section'">
        <xsl:value-of select="count(ancestor::section) + 1"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'sect1'">1</xsl:when>
      <xsl:when test="local-name(.) = 'sect2'">2</xsl:when>
      <xsl:when test="local-name(.) = 'sect3'">3</xsl:when>
      <xsl:when test="local-name(.) = 'sect4'">4</xsl:when>
      <xsl:when test="local-name(.) = 'sect5'">5</xsl:when>
      <xsl:when test="local-name(.) = 'refsect1'">1</xsl:when>
      <xsl:when test="local-name(.) = 'refsect2'">2</xsl:when>
      <xsl:when test="local-name(.) = 'refsect3'">3</xsl:when>
      <xsl:when test="local-name(.) = 'simplesect'">
        <!-- sigh... -->
        <xsl:choose>
          <xsl:when test="local-name(..) = 'section'">
            <xsl:value-of select="count(ancestor::section)"/>
          </xsl:when>
          <xsl:when test="local-name(..) = 'sect1'">2</xsl:when>
          <xsl:when test="local-name(..) = 'sect2'">3</xsl:when>
          <xsl:when test="local-name(..) = 'sect3'">4</xsl:when>
          <xsl:when test="local-name(..) = 'sect4'">5</xsl:when>
          <xsl:when test="local-name(..) = 'sect5'">6</xsl:when>
          <xsl:when test="local-name(..) = 'refsect1'">2</xsl:when>
          <xsl:when test="local-name(..) = 'refsect2'">3</xsl:when>
          <xsl:when test="local-name(..) = 'refsect3'">4</xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

	<xsl:if test="not(local-name()='section' or local-name()='simplesect') or $toc.section.depth &gt; $depth2">

    <xsl:element name="ncx:navPoint">
      <xsl:attribute name="id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>

      <xsl:attribute name="playOrder">
        <xsl:choose>
          <xsl:when test="/*[self::set]">
            <xsl:value-of select="$order"/>
          </xsl:when>
          <xsl:when test="$root.is.a.chunk != '0'">
            <xsl:value-of select="$order + 1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$order - 0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:element name="ncx:navLabel">
        <xsl:element name="ncx:text"><xsl:value-of select="normalize-space($title)"/> </xsl:element>
      </xsl:element>
      <xsl:element name="ncx:content">
        <xsl:attribute name="src">
          <xsl:value-of select="$href"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:apply-templates select="book[parent::set]|part|reference|preface|chapter|bibliography|appendix|article|glossary|section|sect1|sect2|sect3|sect4|sect5|refentry|colophon|bibliodiv[title]|setindex|index" mode="ncx"/>
    </xsl:element>

	</xsl:if>

  </xsl:template>


<!-- Make the title page show up first in readers.
	Originally in docbook-xsl/epub/docbook.xsl
 -->
  <xsl:template name="opf.spine">

    <xsl:element namespace="http://www.idpf.org/2007/opf" name="spine">
      <xsl:attribute name="toc">
        <xsl:value-of select="$epub.ncx.toc.id"/>
      </xsl:attribute>
      
	  <!-- Make sure the title page is the 1st item in the spine -->
	  <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
	  	<xsl:attribute name="idref">
	  		<xsl:value-of select="generate-id(book)"/>
	  	</xsl:attribute>
	  </xsl:element>

      <xsl:if test="/*/*[cover or contains(name(.), 'info')]//mediaobject[@role='cover' or ancestor::cover]"> 
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
          <xsl:attribute name="idref">
            <xsl:value-of select="$epub.cover.id"/>
          </xsl:attribute>
          <xsl:attribute name="linear">
          <xsl:choose>
            <xsl:when test="$epub.cover.linear">
              <xsl:text>yes</xsl:text>
            </xsl:when>
            <xsl:otherwise>no</xsl:otherwise>
          </xsl:choose>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>


      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:element namespace="http://www.idpf.org/2007/opf" name="itemref">
          <xsl:attribute name="idref"> <xsl:value-of select="$epub.html.toc.id"/> </xsl:attribute>
          <xsl:attribute name="linear">yes</xsl:attribute>
        </xsl:element>
      </xsl:if>  

      <!-- TODO: be nice to have a idref="titlepage" here -->
      <xsl:choose>
        <xsl:when test="$root.is.a.chunk != '0'">
          <xsl:apply-templates select="/*" mode="opf.spine"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="/*/*" mode="opf.spine"/>
        </xsl:otherwise>
      </xsl:choose>
                                   
    </xsl:element>
  </xsl:template>


<!-- Customize the metadata generated for the epub.
	Originally from docbook-xsl/epub/docbook.xsl -->
<xsl:template mode="opf.metadata" match="authorgroup">
	<xsl:apply-templates mode="opf.metadata" select="node()"/>
</xsl:template>

<!-- Customize the title page.
	TODO: All of these can be made nicer using gentext and the %t replacements
 -->
<xsl:template name="book.titlepage">
	<h2>
		<xsl:value-of select="bookinfo/title/text()"/>
	</h2>
	<xsl:variable name="authors">
		<xsl:call-template name="cnx.personlist">
			<xsl:with-param name="nodes" select="bookinfo/authorgroup/authors"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="editors">
		<xsl:call-template name="cnx.personlist">
			<xsl:with-param name="nodes" select="bookinfo/authorgroup/editor"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:if test="$authors!=$editors">
		<p>
			<strong><xsl:value-of select="@ext:type"/> <xsl:text> Edited By: </xsl:text></strong>
			<xsl:call-template name="cnx.personlist">
				<xsl:with-param name="nodes" select="bookinfo/authorgroup/editor"/>
			</xsl:call-template>
		</p>
	</xsl:if>
	<p>
		<strong><xsl:text>By: </xsl:text></strong>
		<xsl:call-template name="cnx.personlist">
			<xsl:with-param name="nodes" select="bookinfo/authorgroup/author"/>
		</xsl:call-template>
	</p>
	<xsl:if test="bookinfo/authorgroup/othercredit[@class='translator']">
		<p>
			<strong><xsl:text>Translated by: </xsl:text></strong>
			<xsl:call-template name="cnx.personlist">
				<xsl:with-param name="nodes" select="bookinfo/authorgroup/othercredit[@class='translator']"/>
			</xsl:call-template>
		</p>
	</xsl:if>
	<!-- TODO: If derived -->
	
	<p>
		<xsl:variable name="url">
			<xsl:value-of select="@ext:url"/>
		</xsl:variable>
		<strong><xsl:text>Online: </xsl:text></strong>
		<xsl:text>&lt;</xsl:text>
		<a href="{$url}"><xsl:value-of select="$url"/></a>
		<xsl:text>&gt;</xsl:text>
	</p>
	<xsl:if test="$cnx.iscnx != 0">
		<p><xsl:text>CONNEXIONS</xsl:text></p>
		<p>Rice University, Houston, Texas</p>
	</xsl:if>
	
	<xsl:if test="count(bookinfo/authorgroup/othercredit[@class='other' and contrib/text()='copyright'])>0">
		<p>
			<xsl:text>This selection and arrangement of content as a collection is copyrighted by </xsl:text>
			<xsl:call-template name="cnx.personlist">
				<xsl:with-param name="nodes" select="bookinfo/authorgroup/othercredit[@class='other' and contrib/text()='copyright']"/>
			</xsl:call-template>
			<xsl:text>.</xsl:text>
			<!-- TODO: use the XSL param "generate.legalnotice.link" to chunk the notice into a separate file -->
			<xsl:apply-templates mode="titlepage.mode" select="bookinfo/legalnotice"/>
		</p>
	</xsl:if>
	<xsl:if test="count(bookinfo/authorgroup/othercredit[@class='other' and contrib/text()='copyright'])=0">
		<xsl:text>LOG: WARNING: No copyright holders.... weird.</xsl:text>
	</xsl:if>
	<xsl:if test="@ext:derived-url">
		<p>
			<xsl:text>The collection was based on </xsl:text>
			<xsl:text> &lt;</xsl:text>
			<a href="{@ext:derived-url}">
				<xsl:value-of select="@ext:derived-url"/>
			</a>
			<xsl:text>&gt;.</xsl:text>
		</p>
	</xsl:if>
	<p>
		<xsl:text>Collection structure revised: </xsl:text>
	</p>
	<xsl:apply-templates mode="titlepage.mode" select="bookinfo/pubdate"/>
	<p>
		<xsl:text>For copyright and attribution information for the modules contained in this collection, see the "Attributions" section at the end of the collection.</xsl:text>
	</p>
</xsl:template>



<!-- Generate custom HTML for an ext:problem and ext:solution.
	Taken from docbook-xsl/xhtml-1_1/formal.xsl: <xsl:template match="example">
 -->
<xsl:template match="ext:exercise|ext:problem|ext:solution">
  <xsl:variable name="param.placement" select="substring-after(normalize-space($formal.title.placement),                      concat(local-name(.), ' '))"/>

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

<!-- Can't use docbook-xsl/common/gentext.xsl because labels and titles can contain XML (makes things icky) 
 -->
<xsl:template match="ext:*" mode="object.title.markup">
	<xsl:apply-templates select="." mode="cnx.template"/>
</xsl:template>
<!-- Link to the exercise and to the solution. HACK: We can do this because solutions are within a module (html file) -->
<xsl:template match="ext:exercise" mode="object.title.markup">
	<xsl:apply-templates select="." mode="cnx.template"/>
	<xsl:variable name="id" select="@id"/>
	<xsl:variable name="solution" select="//ext:solution[@exercise-id=$id][1]"/>
	<xsl:variable name="solutionId" select="$solution/@id"/>
	<xsl:if test="$solution">
		<xsl:text> (</xsl:text>
		  <xsl:call-template name="simple.xlink">
		    <xsl:with-param name="linkend" select="$solutionId"/>
		    <xsl:with-param name="content">
		    	<xsl:text>Go to Solution</xsl:text>
		    </xsl:with-param>
		  </xsl:call-template>
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>
<xsl:template match="ext:solution" mode="object.title.markup">
	<xsl:apply-templates select="." mode="cnx.template"/>
	<xsl:variable name="exerciseId" select="@exercise-id"/>
	<xsl:if test="$exerciseId!=''">
		<xsl:text> (</xsl:text>
		  <xsl:call-template name="simple.xlink">
		    <xsl:with-param name="linkend" select="$exerciseId"/>
		    <xsl:with-param name="content">
		    	<xsl:text>Return to Exercise</xsl:text>
		    </xsl:with-param>
		  </xsl:call-template>
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="ext:exercise|ext:problem|ext:solution" mode="insert.label.markup">
	<xsl:param name="label" select="ext:label"/>

	<xsl:if test="$label!=''">
		<xsl:apply-templates select="$label" mode="cnx.label"/>
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:apply-templates select="." mode="number"/>
</xsl:template>

<xsl:template match="ext:*[not(title)]" mode="title.markup"/>
<xsl:template match="ext:*/title"/>

<xsl:template match="ext:exercise|ext:problem|ext:solution" mode="label.markup">
</xsl:template>

<!-- TODO: see if we can gentext these (maybe not, since we allow XML in labels and titles) -->
<xsl:template match="ext:exercise" mode="cnx.template">
	<xsl:choose>
		<xsl:when test="ext:label">
			<xsl:apply-templates select="ext:label" mode="cnx.label"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>Exercise</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="." mode="number"/>
	<xsl:if test="title">
		<xsl:text> : </xsl:text>
		<xsl:apply-templates select="." mode="title.markup"/>
	</xsl:if>
</xsl:template>
<xsl:template match="ext:problem[not(ext:label)]" mode="cnx.template"><xsl:apply-templates select="title"/></xsl:template>
<xsl:template match="ext:solution[not(ext:label)]" mode="cnx.template"><xsl:text>Solution to </xsl:text><xsl:apply-templates select="." mode="number"/></xsl:template>
<xsl:template match="ext:*[ext:label]" mode="cnx.template" priority="0">
	<xsl:apply-templates select="ext:label" mode="cnx.label"/>
	<xsl:if test="title">
		<xsl:text> : </xsl:text>
		<xsl:apply-templates select="." mode="title.markup"/>
	</xsl:if>
</xsl:template>

<xsl:template match="ext:label" mode="cnx.label">
	<xsl:apply-templates select="node()"/>
</xsl:template>
<xsl:template match="ext:label"/>

<!-- By default, nothing is numbered. -->
<xsl:template match="ext:*" mode="number"/>

<xsl:template match="ext:exercise" mode="number">
	<xsl:if test="ancestor::chapter|ancestor::appendix">
		<xsl:apply-templates select="ancestor::*[@ext:element='module']" mode="cnxnumber"/>
		<xsl:apply-templates select="." mode="intralabel.punctuation"/>
	</xsl:if>
	<xsl:number format="1" level="any" from="chapter" count="ext:exercise[not(ancestor::*[ext:element='example'])]"/>
</xsl:template>

<!-- Either a module is a chapter, or a section in a chapter -->
<xsl:template match="preface|chapter|appendix" mode="cnxnumber">
	<xsl:apply-templates select="." mode="label.markup"/>
</xsl:template>
<xsl:template match="*[@ext:element='module']" mode="cnxnumber">
	<xsl:if test="ancestor::chapter|ancestor::appendix">
		<xsl:apply-templates select="ancestor::preface|ancestor::chapter|ancestor::appendix" mode="cnxnumber"/>
		<xsl:apply-templates select="." mode="intralabel.punctuation"/>
	</xsl:if>
	<xsl:number from="preface|chapter|appendix" count="*[@ext:element='module']"/>
</xsl:template>
<xsl:template match="*" mode="cnxnumber">
	<xsl:call-template name="cnx.log"><xsl:with-param name="msg">BUG: tried to get a cnxnumber for something other than a preface|chapter|appendix|*[@ext:element='module']</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="ext:solution" mode="number">
	<xsl:variable name="exerciseId" select="@exercise-id"/>
	<xsl:apply-templates select="//*[@id=$exerciseId]" mode="number"/>
</xsl:template>

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

</xsl:stylesheet>