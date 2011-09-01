<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:ext="http://cnx.org/ns/docbook+"
  xmlns:c="http://cnx.rice.edu/cnxml"
  version="1.0">

<xsl:import href="debug.xsl"/>
<xsl:import href="../docbook-xsl/fo/docbook.xsl"/>
<xsl:import href="dbkplus.xsl"/>

<xsl:output indent="yes" method="xml" encoding="ASCII"/>

<!-- Remove reliance on external "draft" graphic -->
<xsl:param name="draft.mode">no</xsl:param>

<!-- Enable Apache FOP specific extensions (and disable things unsupported in FOP) -->
<xsl:param name="fop1.extensions" select="1"/>

<!-- Number the sections 1 level deep. See http://docbook.sourceforge.net/release/xsl/current/doc/html/ -->
<xsl:param name="section.autolabel" select="1"></xsl:param>
<xsl:param name="section.autolabel.max.depth">1</xsl:param>
<xsl:param name="chunk.section.depth" select="0"></xsl:param>
<xsl:param name="chunk.first.sections" select="0"></xsl:param>

<xsl:param name="section.label.includes.component.label">1</xsl:param>
<xsl:param name="toc.section.depth">0</xsl:param>

<!-- To support international characters, add some fonts -->
<xsl:param name="cnx.font.catchall">STIXGeneral,STIXSize,Code2000</xsl:param>
<xsl:param name="body.font.family">serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="dingbat.font.family">serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="monospace.font.family">monospace,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="sans.font.family">sans-serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="symbol.font.family">Symbol,ZapfDingbats,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>
<xsl:param name="title.font.family">sans-serif,<xsl:value-of select="$cnx.font.catchall"/></xsl:param>


<!-- Disable "Document Properties" in acrobat reader.
     Setting "fop1.extensions" causes this to be rendered which causes
     a stack underflow during the 2nd pass of rendering the PDF using
     the Development version of FOP -->
<!-- Metadata support ("Document Properties" in Adobe Reader) -->
<xsl:template name="fop1-document-information"/>


<!-- Add a template for newlines.
     The cnxml2docbook adds a processing instruction named <?cnx.newline?>
     and is matched here
     see http://www.sagehill.net/docbookxsl/LineBreaks.html
-->
<xsl:template match="processing-instruction('cnx.newline')">
	<fo:block>
		<xsl:comment>cnx.newline</xsl:comment>
	</fo:block>
</xsl:template>

<xsl:template match="c:media">
	<xsl:call-template name="log"><xsl:with-param name="str">INFO: Discarding media tag</xsl:with-param></xsl:call-template>
</xsl:template>

<!-- No longer used: Print the current module that is being worked on.
	Converting Docbook to XSL-FO may take hours so 
	it's useful to see that progress is being made
 -->

<!-- ORIGINAL: docbook-xsl/fo/lists.xsl
	Changes: In addition to outputting "???" if a link is broken, 
	  also generate debug message so the author can fix it
 -->


<xsl:template match="db:token[@class='simplemath']/text()">
    <xsl:choose>
        <xsl:when test="normalize-space(.) != '' and normalize-space(.) != ' '">
            <fo:inline font-family="STIXGeneral">
                <xsl:value-of select="."/>
            </fo:inline>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="."/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="inline.boldseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-weight="bold">
    <xsl:if test="ancestor::db:token[@class='simplemath']">
        <xsl:attribute name="font-family">
            <xsl:text>STIXGeneral</xsl:text>
        </xsl:attribute>
    </xsl:if>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.italicseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-style="italic">
    <xsl:if test="ancestor::db:token[@class='simplemath']">
        <xsl:attribute name="font-family">
            <xsl:text>STIXGeneral</xsl:text>
        </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<!-- Discard MathML -->
<xsl:template match="mml:*"/>

<xsl:template match="db:authorgroup[@role='all']|db:othercredit|db:editor"/>

<xsl:template match="svg:*/@font-family">
    <xsl:attribute name="font-family">
        <xsl:value-of select="."/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$cnx.font.catchall"/>
    </xsl:attribute>
</xsl:template>

<xsl:template match="svg:*/@style">
    <xsl:variable name="containsFamily" select="contains(., 'font-family')"/>
    <xsl:attribute name="style">
	    <xsl:choose>
	        <xsl:when test="$containsFamily">
			    <xsl:variable name="before" select="substring-before(., 'font-family:')"/>
			    <xsl:variable name="family" select="substring-before(substring-after(., 'font-family:'), ';')"/>
			    <xsl:variable name="after" select="substring-after(substring-after(., 'font-family:'), ';')"/>
		        <xsl:value-of select="$before"/>
		        <xsl:value-of select="$family"/>
		        <xsl:if test="$family != ''">
		            <xsl:text>,</xsl:text>
		        </xsl:if>
		        <xsl:value-of select="$cnx.font.catchall"/>
		        <xsl:value-of select="$after"/>
	        </xsl:when>
	        <xsl:otherwise>
	            <xsl:value-of select="."/>
	            <xsl:text>;font-family:</xsl:text>
	            <xsl:value-of select="$cnx.font.catchall"/>
	            <xsl:text>;</xsl:text>
	        </xsl:otherwise>
	    </xsl:choose>
    </xsl:attribute>
</xsl:template>



<!-- Customize the title page -->
<xsl:template name="cnx.book.titlepage">
    <!-- To handle the case where we're generating a module epub -->
    <xsl:variable name="collectionAuthorgroup" select="db:bookinfo/db:authorgroup[@role='collection' or not(../db:authorgroup[@role='collection'])]"/>
    <xsl:variable name="collectionAuthors" select="$collectionAuthorgroup/db:author"/>
    <xsl:variable name="moduleAuthors" select="db:bookinfo/db:authorgroup[@role='module' or not(../db:authorgroup[@role='module'])]/db:author"/>
    <!-- Only modules have editors -->
    <xsl:variable name="editors" select="db:bookinfo/db:authorgroup[not(@role)]/db:editor"/>
    <xsl:variable name="translators" select="$collectionAuthorgroup/db:othercredit[@class='translator']"/>
    <xsl:variable name="licensors" select="$collectionAuthorgroup/db:othercredit[@class='other' and db:contrib/text()='licensor']"/>
    <xsl:variable name="authorsMismatch">
        <xsl:call-template name="cnx.authors.match">
            <xsl:with-param name="set1" select="$collectionAuthors"/>
            <xsl:with-param name="set2" select="$moduleAuthors"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="showCollectionAuthors" select="$authorsMismatch != ''"/>
    <xsl:call-template name="cnx.log"><xsl:with-param name="msg">INFO: Displaying separate collections authors on title page? <xsl:value-of select="$showCollectionAuthors"/></xsl:with-param></xsl:call-template>

    <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="d:bookinfo/d:title"/>

    <xsl:if test="$showCollectionAuthors">
        <xsl:call-template name="cnx.log"><xsl:with-param name="msg">DEBUG: Authors mismatch because of <xsl:value-of select="$authorsMismatch"/></xsl:with-param></xsl:call-template>
        <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="title_page_collection_editors">
            <fo:inline xsl:use-attribute-sets="cnx.titlepage.strong"><xsl:text>Collection edited by: </xsl:text></fo:inline>
            <fo:inline xsl:use-attribute-sets="cnx.titlepage.span">
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="$collectionAuthors"/>
                </xsl:call-template>
            </fo:inline>
        </fo:block>
    </xsl:if>
    <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="title_page_module_authors">
        <fo:inline xsl:use-attribute-sets="cnx.titlepage.strong">
            <xsl:choose>
                <xsl:when test="not($showCollectionAuthors)">
                    <xsl:text>By: </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Content authors: </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="cnx.titlepage.span">
            <xsl:call-template name="person.name.list">
                <xsl:with-param name="person.list" select="$moduleAuthors"/>
            </xsl:call-template>
        </fo:inline>
    </fo:block>
    <!-- Only for modules -->
    <xsl:if test="$editors">
        <fo:block xsl:use-attribute-sets="cnx.titlepage.authors">
            <fo:inline xsl:use-attribute-sets="cnx.titlepage.strong"><xsl:text>Edited by: </xsl:text></fo:inline>
            <fo:inline xsl:use-attribute-sets="cnx.titlepage.span">
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="$editors"/>
                </xsl:call-template>
            </fo:inline>
        </fo:block>
    </xsl:if>
    <xsl:if test="$translators">
        <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="title_page_translators">
            <fo:inline xsl:use-attribute-sets="cnx.titlepage.strong"><xsl:text>Translated by: </xsl:text></fo:inline>
            <fo:inline xsl:use-attribute-sets="cnx.titlepage.span">
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="$translators"/>
                </xsl:call-template>
            </fo:inline>
        </fo:block>
    </xsl:if>
    <xsl:for-each select="db:bookinfo/ext:derived-from">
        <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="title_page_derivation">
        <fo:inline xsl:use-attribute-sets="cnx.titlepage.strong"><xsl:text>Based on: </xsl:text></fo:inline>
        <fo:inline xsl:use-attribute-sets="cnx.titlepage.span">
            <xsl:apply-templates select="db:title/node()"/>
            <xsl:call-template name="cnx.cuteurl">
                <xsl:with-param name="url" select="@url"/>
            </xsl:call-template>
            <xsl:if test="ancestor::db:book[@ext:element='module']">
                <xsl:text> by </xsl:text>
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="db:authorgroup/db:author"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:text>.</xsl:text>
        </fo:inline>
        </fo:block>
    </xsl:for-each>
    <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="title_page_url">
        <fo:inline xsl:use-attribute-sets="cnx.titlepage.strong"><xsl:text>Online: </xsl:text></fo:inline>
        <fo:inline xsl:use-attribute-sets="cnx.titlepage.span">
            <xsl:call-template name="cnx.cuteurl">
                <xsl:with-param name="url" select="@ext:url"/>
            </xsl:call-template>
        </fo:inline>
    </fo:block>
    <xsl:if test="/db:book/@ext:site-type = 'cnx'">
        <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="portal_statement">
            <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="portal_title"><fo:inline xsl:use-attribute-sets="cnx.titlepage.span"><xsl:text>CONNEXIONS</xsl:text></fo:inline></fo:block>
            <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="portal_location"><fo:inline xsl:use-attribute-sets="cnx.titlepage.span"><xsl:text>Rice University, Houston, Texas</xsl:text></fo:inline></fo:block>
        </fo:block>
    </xsl:if>
    <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="copyright_page">
        <xsl:if test="$licensors">
            <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="copyright_statement">
                <xsl:choose>
                    <xsl:when test="@ext:element='module'">
                        <xsl:text>This module is copyrighted by </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>This selection and arrangement of content as a collection is copyrighted by </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:call-template name="person.name.list">
                    <xsl:with-param name="person.list" select="$licensors"/>
                </xsl:call-template>
                <xsl:text>.</xsl:text>
            </fo:block>
        </xsl:if>
        <xsl:if test="not($licensors)">
            <xsl:call-template name="cnx.log"><xsl:with-param name="msg">WARNING: No copyright holders getting output under bookinfo for collection level.... weird.</xsl:with-param></xsl:call-template>
        </xsl:if>
        <!-- TODO: use the XSL param "generate.legalnotice.link" to chunk the notice into a separate file -->
        <xsl:apply-templates mode="titlepage.mode" select="db:bookinfo/db:legalnotice"/>
        <xsl:if test="@ext:derived-url">
            <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="copyright_derivation">
                <xsl:text>The collection was based on </xsl:text>
                <xsl:call-template name="cnx.cuteurl">
                    <xsl:with-param name="url" select="@ext:derived-url"/>
                </xsl:call-template>
            </fo:block>
        </xsl:if>
        <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="copyright_revised">
            <xsl:choose>
                <xsl:when test="@ext:element='module'">
                    <xsl:text>Module revised: </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Collection structure revised: </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- FIXME: Should read "August 10, 2009".  But for now, leaving as "2009/08/10" and chopping off the rest of the time/timezone stuff. -->
            <xsl:value-of select="substring-before(normalize-space(db:bookinfo/db:pubdate/text()),' ')"/>
        </fo:block>
        <xsl:if test="not(@ext:element='module')">
	        <fo:block xsl:use-attribute-sets="cnx.titlepage.authors" id="copyright_attribution">
	            <xsl:text>For copyright and attribution information for the modules contained in this collection, see the "</xsl:text>
	            <xsl:call-template name="simple.xlink">
	                <xsl:with-param name="linkend" select="$attribution.section.id"/>
	                <xsl:with-param name="content">
	                    <xsl:text>Attributions</xsl:text>
	                </xsl:with-param>
	            </xsl:call-template>
	            <xsl:text>" section at the end of the collection.</xsl:text>
	        </fo:block>
	    </xsl:if>
    </fo:block>
</xsl:template>

<!-- Copied line-for-line from docbook-xsl/fo/division.xsl
    because there's a weird issue with overloading the "book.titlepage" template.
-->
<xsl:template match="d:book">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:variable name="preamble"
                select="d:title|d:subtitle|d:titleabbrev|d:bookinfo|d:info"/>
  <xsl:variable name="content"
                select="node()[not(self::d:title or self::d:subtitle
                            or self::d:titleabbrev
                            or self::d:info
                            or self::d:bookinfo)]"/>
  <xsl:variable name="titlepage-master-reference">
    <xsl:call-template name="select.pagemaster">
      <xsl:with-param name="pageclass" select="'titlepage'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:call-template name="front.cover"/>
  <xsl:if test="$preamble">
    <xsl:call-template name="page.sequence">
      <xsl:with-param name="master-reference"
                      select="$titlepage-master-reference"/>
      <xsl:with-param name="content">
        <fo:block id="{$id}">
          <xsl:call-template name="cnx.book.titlepage"/>
        </fo:block>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  <xsl:apply-templates select="d:dedication" mode="dedication"/>
  <xsl:apply-templates select="d:acknowledgements" mode="acknowledgements"/>
  <xsl:call-template name="make.book.tocs"/>
  <xsl:apply-templates select="$content"/>
  <xsl:call-template name="back.cover"/>
</xsl:template>

<xsl:template name="cnx.cuteurl">
    <xsl:param name="url"/>
    <xsl:param name="text">
        <xsl:value-of select="$url"/>
    </xsl:param>
    <xsl:text> &lt;</xsl:text>
    <fo:basic-link external-destination="url({$url})">
      <xsl:copy-of select="$text"/>
    </fo:basic-link>
    <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template name="cnx.authors.match">
    <xsl:param name="set1"/>
    <xsl:param name="set2"/>
    <xsl:param name="count" select="1"/>
    <xsl:choose>
        <!-- Base case (end of list) -->
        <xsl:when test="$count > count($set1)"/>
        <!-- Mismatch because set sizes don't match -->
        <xsl:when test="count($set1) != count($set2)">
            <xsl:text>set-size-diff=</xsl:text>
            <xsl:value-of select="count($set2) - count($set1)"/>
        </xsl:when>
        <!-- Check and recurse -->
        <xsl:otherwise>
	        <xsl:variable name="id" select="$set1[$count]/@ext:user-id"/>
	        <xsl:if test="not($set2[@ext:user-id=$id])">
	            <xsl:value-of select="$id"/>
	            <xsl:text>|</xsl:text>
	        </xsl:if>
	        <xsl:call-template name="cnx.authors.match">
	            <xsl:with-param name="set1" select="$set1"/>
	            <xsl:with-param name="set2" select="$set2"/>
	            <xsl:with-param name="count" select="$count+1"/>
	        </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


</xsl:stylesheet>
