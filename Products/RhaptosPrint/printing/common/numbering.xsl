<?xml version= "1.0" standalone="no"?>
<!--
    Number most elements for print output.

    Author: Brent Hendricks, Chuck Bearden, Adan Galvan
    (C) 2006-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0" 
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:cnx="http://cnx.rice.edu/contexts#"
            xmlns:cnxml="http://cnx.rice.edu/cnxml"
            xmlns:qml="http://cnx.rice.edu/qml/1.0"
            xmlns:ind="index" 
            xmlns:glo="glossary"
            xmlns:exsl="http://exslt.org/common"
            xmlns:str="http://exslt.org/strings"
            extension-element-prefixes="exsl str"
>
  
  <xsl:variable name="lower-letters" select="'abcdefghijklmnopqrstuvwxyzäëïöüáéíóúàèìòùâêîôûåøãõæœçłñ'"/>
  <xsl:variable name="upper-letters" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÄËÏÖÜÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÅØÃÕÆŒÇŁÑ'"/>

  <!--A key that matches the type attribute of rule-->
  <xsl:key name="rule" match="cnxml:rule" use="translate(@type, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÄËÏÖÜÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÅØÃÕÆŒÇŁÑ', 'abcdefghijklmnopqrstuvwxyzäëïöüáéíóúàèìòùâêîôûåøãõæœçłñ')"/>

  <!-- output xml file's unicode characters are not encoded as '&#0032' but
  rather in binary.  that way #'s can be escaped as \# in the next step without
  messing up the unicode. -->
  <xsl:output encoding="UTF-8" />
  <xsl:variable name="mode">
    <xsl:choose>
      <xsl:when test="/course">collection</xsl:when>
      <xsl:when test="/module">module</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <!--Identity Transformation -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template> 

	
  <!-- -=-=-= ROOT =-=-=- -->
  <xsl:template match="/course|/module">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
      
      <ind:authorlist>
	<xsl:for-each select="//document/author">
	  <xsl:sort select="normalize-space(surname)"/>
	  <xsl:sort select="normalize-space(firstname)"/>
	  <xsl:variable name="author" select="@id"/>
	  <!-- Make sure we only get one copy of each author -->
	  <xsl:if test="not(preceding::author[@id=$author])">
	    <ind:item type="author">
	    <!-- normalize here?  or at a later time, ie. in tofo -->
	      <xsl:copy-of select="firstname"/> 
	      <xsl:copy-of select="surname"/>
	    </ind:item>
	  </xsl:if>
	</xsl:for-each>
      </ind:authorlist>
      <xsl:text>
      </xsl:text>
      <xsl:variable name="alldefs" 
          select="//cnxml:definition[not(ancestor::referenced-objects)] |
          //cnxml:glossary[not(ancestor::referenced-objects)]/cnxml:definition"/>
      <xsl:if test="$alldefs and /course">
      <glo:glossarylist>
	<xsl:for-each select="$alldefs">
	  <xsl:sort select="translate(normalize-space(.), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 
	    'abcdefghijklmnopqrstuvwxyz')" />
	  <glo:item id="{generate-id()}">
	    <glo:term>
	      <xsl:value-of select="cnxml:term"/>
	    </glo:term>
	      <xsl:for-each select="cnxml:meaning">
                <xsl:variable name="moduleid"
                     select="ancestor::*[local-name()='document'][1]/@id"/>
	      <glo:meaning moduleid="{$moduleid}">
		<glo:meaning-para>
		  <xsl:apply-templates />
		</glo:meaning-para>
		<xsl:call-template name="print-examples">
		  <xsl:with-param name="position"> 
		    <xsl:value-of select="1"/> 
		  </xsl:with-param>
		</xsl:call-template>
	      </glo:meaning>
	    </xsl:for-each>
	  </glo:item>
	</xsl:for-each>
      </glo:glossarylist>
      </xsl:if>
      <ind:indexlist>
        <xsl:for-each select="//keyword[not(ancestor::referenced-objects)] |
                              //cnxml:term[not(ancestor::referenced-objects)]">
          <!-- this will break if there is anything but text in a term -->
          <xsl:sort select="translate(normalize-space(.), 
              'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
          <!-- the 'translate' is to make capital letters and 
               lowercase letters equal so that they all alphabetize 
               together. -->
          <xsl:choose>
            <xsl:when test="self::keyword[string-length(normalize-space(.)) > 0]">
              <xsl:text>
              </xsl:text> 
              <ind:item type="keyword" id="{ancestor::document/@id}">
                <xsl:value-of select="."/>
              </ind:item>
            </xsl:when>
            <xsl:when test="not(ancestor::cnxml:glossary) and
                            string-length(normalize-space(.)) > 0">
              <xsl:text>
              </xsl:text>
              <ind:item type="term" id="{generate-id()}">
                <xsl:value-of select="normalize-space(.)"/>
              </ind:item>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </ind:indexlist>
    </xsl:copy>
  </xsl:template>

  <!-- Print Examples -->
  <xsl:template name="print-examples">
    <xsl:param name="position"/>
    <xsl:if test="local-name(following-sibling::*[position()=$position])='example'">
      <xsl:apply-templates select="following-sibling::*[position()=$position]"/>
      <xsl:call-template name="print-examples">
	<xsl:with-param name="position"> 
	  <xsl:value-of select="$position + 1"/> 
	</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Front matter doesn't get numbered; we test $mode because in CNXML 0.6, 
       authors will be able to add '@cnx:class="frontmatter"' to their elements, 
       and we want to ignore that until we can think through how to handle 
       classes we define for collections when they occur in modules. -->
  <xsl:template match="*[@cnx:class='frontmatter']">
    <xsl:if test="$mode = 'collection'">
      <xsl:copy>
  		  <xsl:copy-of select="@*"/>
  		  <xsl:apply-templates/>
			</xsl:copy>
    </xsl:if>
  </xsl:template>
  
  <!-- Chapters get numbered-->
  <xsl:template match="*[@cnx:class='chapter']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="$mode = 'collection'">
        <xsl:attribute name="number">
          <xsl:apply-templates select="." mode="numbering"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@cnx:class='chapter']" mode="numbering">
    <xsl:number level="single" format="1" count="*[@cnx:class='chapter']"/>
  </xsl:template>

  <!-- Sections get numbered-->
  <xsl:template match="cnxml:section|*[starts-with(@cnx:class, 'section')]">
    <xsl:choose>
      <xsl:when test="ancestor::*[@cnx:class='chapter'] or /module">
    	  <xsl:copy>
      	  <xsl:copy-of select="@*"/>
      	  <xsl:attribute name="number">
            <xsl:apply-templates select="." mode="numbering"/>
      	  </xsl:attribute>
      	  <xsl:apply-templates/>
    	  </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
    	  <xsl:copy>
  			  <xsl:copy-of select="@*"/>
  			  <xsl:apply-templates/>
			  </xsl:copy>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <xsl:template match="cnxml:section|*[starts-with(@cnx:class, 'section')]"
                mode="numbering">
    <xsl:choose>
      <xsl:when test="$mode = 'collection'">
        <xsl:number level="multiple" format="1.1"
                    count="cnxml:section|*[@cnx:class='chapter']|
                    *[starts-with(@cnx:class, 'section')]"/>
      </xsl:when>
      <xsl:when test="$mode = 'module' and self::cnxml:section">
        <xsl:number level="multiple" format="1.1"
                    count="cnxml:section"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <!-- EVERYTHING ELSE INSIDE OF A CHAPTER -->
  <xsl:template match="cnxml:figure|cnxml:definition|cnxml:equation">
    <xsl:variable name="local-name" select="local-name()"/>
    <xsl:variable name="type" select="translate(@type, $upper-letters, $lower-letters)"/>
    <xsl:call-template name="bi-level-numbering">
      <xsl:with-param name="second-level-number">
        <xsl:choose>
          <xsl:when test="$mode = 'collection'">
            <xsl:number level="any" count="cnxml:*[local-name()=$local-name][translate(@type, $upper-letters, $lower-letters)=$type]" from="*[@cnx:class='chapter']" />
          </xsl:when>
          <!-- We ignore @cnx:class='chapter' in module mode. -->
          <xsl:when test="$mode = 'module'">
            <xsl:number level="any" count="cnxml:*[local-name()=$local-name][translate(@type, $upper-letters, $lower-letters)=$type]"/>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="type" select="$type"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="cnxml:code[str:tokenize(@class)='listing']">
    <xsl:variable name="local-name" select="local-name()"/>
    <xsl:variable name="type" select="translate(@type, $upper-letters, $lower-letters)"/>
    <xsl:call-template name="bi-level-numbering">
      <xsl:with-param name="second-level-number">
        <xsl:choose>
          <xsl:when test="$mode = 'collection'">
            <xsl:number level="any" count="cnxml:code[str:tokenize(@class)='listing'][translate(@type, $upper-letters, $lower-letters)=$type]" from="*[@cnx:class='chapter']" />
          </xsl:when>
          <!-- We ignore @cnx:class='chapter' in module mode. -->
          <xsl:when test="$mode = 'module'">
            <xsl:number level="any" count="cnxml:code[str:tokenize(@class)='listing'][translate(@type, $upper-letters, $lower-letters)=$type]"/>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="type" select="$type"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="bi-level-numbering">
    <xsl:param name="second-level-number"/>
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="ancestor::*[@cnx:class='chapter'] or /module">
        <xsl:copy>
          <!--Add number attribute.-->
          <xsl:attribute name="number">
            <!-- We pay attention to @cnx:class='chapter' only in collection mode. -->
            <xsl:if test="$mode = 'collection' and ancestor::*[@cnx:class='chapter']">
              <xsl:number level="single" count="*[@cnx:class='chapter']"/>
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:value-of select="$second-level-number"/>
          </xsl:attribute>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:when test="ancestor::*[@cnx:class='frontmatter']">
        <xsl:copy>
          <xsl:attribute name="number">
            <xsl:number level="any" from="*[@cnx:class='frontmatter']" />
          </xsl:attribute>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnxml:table[not(ancestor::cnxml:figure)]">
    <xsl:choose>
      <xsl:when test="ancestor::*[@cnx:class='chapter'] or /module">
        <xsl:variable name="type" select="translate(@type, $upper-letters, $lower-letters)"/>
        <xsl:variable name="local-name" select="local-name()"/>
        <xsl:copy>
          <!--Add number attribute.-->
          <xsl:attribute name="number">
            <!-- We pay attention to @cnx:class='chapter' only in collection mode. -->
            <xsl:if test="$mode = 'collection' and ancestor::*[@cnx:class='chapter']">
              <xsl:number level="single" count="*[@cnx:class='chapter']"/>
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$mode = 'collection'">
                <xsl:number level="any" count="cnxml:table[not(ancestor::cnxml:figure)][translate(@type, $upper-letters, $lower-letters)=$type]" from="*[@cnx:class='chapter']" />
              </xsl:when>
              <!-- We ignore @cnx:class='chapter' in module mode. -->
              <xsl:when test="$mode = 'module'">
                <xsl:number level="any" count="cnxml:table[not(ancestor::cnxml:figure)][translate(@type, $upper-letters, $lower-letters)=$type]"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:when test="ancestor::*[@cnx:class='frontmatter']">
        <xsl:copy>
          <xsl:attribute name="number">
            <xsl:number level="any" from="*[@cnx:class='frontmatter']" />
          </xsl:attribute>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnxml:subfigure">
    <xsl:variable name="type" select="translate(@type, $upper-letters, $lower-letters)"/>
    <xsl:copy>
      <xsl:attribute name="number">
        <xsl:number level="single" count="cnxml:subfigure[translate(@type, $upper-letters, $lower-letters)=$type]" format="a" />
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cnxml:exercise[not(ancestor::cnxml:example)]">
    <xsl:choose>
      <xsl:when test="ancestor::*[@cnx:class='chapter']">
        <xsl:copy>
          <!--Add number attribute.-->
          <xsl:attribute name="number">
            <xsl:apply-templates select="ancestor::*[local-name()='document']"
                                 mode="numbering"/>
            <xsl:text>.</xsl:text>
            <xsl:number count="cnxml:exercise[not(ancestor::cnxml:example)]"
                        level="any" from="*[local-name()='document']"/>
          </xsl:attribute>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cnxml:example//cnxml:exercise">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="count(ancestor::cnxml:example[1]//cnxml:exercise) &gt; 1">
        <xsl:variable name="type" select="translate(@type, $upper-letters, $lower-letters)"/>
        <xsl:attribute name="number">
          <xsl:number level="any" count="cnxml:exercise[translate(@type, $upper-letters, $lower-letters)=$type]" from="cnxml:example"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="qml:problemset/qml:item">
    <xsl:choose>
      <xsl:when test="ancestor::*[@cnx:class='chapter'] or /module">
    	  <xsl:copy>
      	  <!--Add number attribute.-->
      	  <xsl:attribute name="number">
      	    <xsl:if test="ancestor::*[@cnx:class='chapter']">
		  <xsl:number level="single" count="*[@cnx:class='chapter']"/>
		  <xsl:text>.</xsl:text>
		        </xsl:if>
		  <xsl:number level="any" from="*[@cnx:class='chapter']" count="qml:item"/>
	  
      	  </xsl:attribute>
      
      	  <xsl:apply-templates select="@*|node()" />
      
    	  </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
    	  <xsl:copy>
  			  <xsl:copy-of select="@*"/>
  			  <xsl:apply-templates/>
			  </xsl:copy>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
  
  <!-- EXAMPLE: Same as previous template, but only count examples that are not in definitions.-->
  <xsl:template match="cnxml:example
                        [not(ancestor::cnxml:definition or ancestor::cnxml:rule or ancestor::cnxml:exercise or
                             ancestor::cnxml:text or ancestor::cnxml:longdesc or ancestor::cnxml:footnote or
                             ancestor::cnxml:entry or ancestor::cnxml:solution)]">
    <xsl:choose>
      <xsl:when test="ancestor::*[@cnx:class='chapter'] or /module">
        <xsl:variable name="type" select="translate(@type, $upper-letters, $lower-letters)"/>
        <xsl:copy>
          <!--Add number attribute.-->
          <xsl:attribute name="number">
            <xsl:if test="$mode = 'collection' and ancestor::*[@cnx:class='chapter']">
              <xsl:number level="single" count="*[@cnx:class='chapter']"/>
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$mode = 'collection'">
                <xsl:number level="any" from="*[@cnx:class='chapter']"
                            count="cnxml:example[not(ancestor::cnxml:definition|ancestor::cnxml:rule|ancestor::cnxml:exercise|
                                                     ancestor::cnxml:text|ancestor::cnxml:longdesc|ancestor::cnxml:footnote|
                                                     ancestor::cnxml:entry)][translate(@type, $upper-letters, $lower-letters)=$type]"/>
               </xsl:when>
              <xsl:when test="$mode = 'module'">
                <xsl:text></xsl:text>
                <xsl:number level="any" 
                            count="cnxml:example[not(ancestor::cnxml:definition|ancestor::cnxml:rule|ancestor::cnxml:exercise|
                                                     ancestor::cnxml:text|ancestor::cnxml:longdesc|ancestor::cnxml:footnote|
                                                     ancestor::cnxml:entry)][translate(@type, $upper-letters, $lower-letters)=$type]"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
  
  
  <!--RULE: Same as previous except only count RULEs of the same type.-->
  <xsl:template match="cnxml:rule">
    <xsl:choose>
      <xsl:when test="ancestor::*[@cnx:class='chapter'] or /module">
        <xsl:variable name="type" select="translate(@type, $upper-letters, $lower-letters)"/>
        <xsl:copy>
          <!--Add the number attribute.-->
          <xsl:attribute name="number">
            <xsl:if test="$mode = 'collection' and ancestor::*[@cnx:class='chapter']">
              <xsl:number level="single" count="*[@cnx:class='chapter']"/>
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$mode = 'collection'">
                <xsl:number level="any" from="*[@cnx:class='chapter']"
                            count="cnxml:rule[translate(@type, $upper-letters, $lower-letters)=$type]"/>
              </xsl:when>
              <xsl:when test="$mode = 'module'">
                <xsl:number level="any" count="cnxml:rule[translate(@type, $upper-letters, $lower-letters)=$type]"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--TERM: Add an autogenerated id to term.-->
  <xsl:template match="cnxml:term">
    <xsl:copy>
      <xsl:attribute name="id">
	<xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
















