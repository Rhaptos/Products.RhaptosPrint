<?xml version="1.0"?>
<!--
    Generate bibtex file from BibTeXML in modules.

    Author: Adan Galvan and Chuck Bearden
    (C) 2003-2009 Rice University

    This software is subject to the provisions of the GNU Lesser General
    Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:bibtex="http://bibtexml.sf.net/">
  <xsl:output method="text" media-type="application/x-bibtex"
	      encoding="iso-8859-1"/>

  <xsl:template match="bibtex:bibliography">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="bibtex:entry">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="bibtex:entry/bibtex:*">
    <xsl:text>@</xsl:text>
    <xsl:value-of select='substring-after(name(),"bib:")'/>
    <xsl:text>{</xsl:text>
    <xsl:value-of select="../@id"/>
    <xsl:text>,</xsl:text>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="bibtex:entry/*/bibtex:*">
    <xsl:text>   </xsl:text>
    <xsl:value-of select='substring-after(name(),"bib:")'/>
    <xsl:text> = {</xsl:text>
    <xsl:call-template name="escape-latexchars">
      <xsl:with-param name="data">
        <xsl:value-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>},</xsl:text>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="text()"/>

  <!-- == Escape LaTeX special characters that may occur in bib entries. == -->
  <!-- Note: if we reuse this approach elsewhere, we should factor these 
       templates out into their own stylesheet and include or import. -->
  <xsl:template name="generic-escaping">
    <xsl:param name="data"/>
    <xsl:param name="escapee"/>
    <xsl:param name="escape-char"/>
    <xsl:choose>
      <xsl:when test="contains($data, $escapee)">
        <xsl:value-of select="substring-before($data, $escapee)"/>
        <xsl:value-of select="$escape-char"/>
        <xsl:value-of select="$escapee"/>
        <xsl:call-template name="generic-escaping">
          <xsl:with-param name="data"
                          select="substring-after($data, $escapee)"/>
          <xsl:with-param name="escapee" select="$escapee"/>
          <xsl:with-param name="escape-char" select="$escape-char"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$data"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="backslash-escape">
    <xsl:param name="data"/>
    <xsl:param name="escapee"/>
    <xsl:call-template name="generic-escaping">
      <xsl:with-param name="data" select="$data"/>
      <xsl:with-param name="escapee" select="$escapee"/>
      <xsl:with-param name="escape-char" select="'\'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="escape-octothorpe">
    <xsl:param name="data"/>
    <xsl:call-template name="backslash-escape">
      <xsl:with-param name="data" select="$data"/>
      <xsl:with-param name="escapee" select="'#'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="escape-dollar">
    <xsl:param name="data"/>
    <xsl:call-template name="backslash-escape">
      <xsl:with-param name="data" select="$data"/>
      <xsl:with-param name="escapee" select="'$'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="escape-percent">
    <xsl:param name="data"/>
    <xsl:call-template name="backslash-escape">
      <xsl:with-param name="data" select="$data"/>
      <xsl:with-param name="escapee" select="'%'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="escape-ampersand">
    <xsl:param name="data"/>
    <xsl:call-template name="backslash-escape">
      <xsl:with-param name="data" select="$data"/>
      <xsl:with-param name="escapee" select="'&amp;'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Tilde and caret must be escaped specially, else they become diacritics 
       over the following character. -->
  <xsl:template name="escape-tilde">
    <xsl:param name="data"/>
    <xsl:choose>
      <xsl:when test="contains($data, '~')">
        <xsl:value-of select="substring-before($data, '~')"/>
        <xsl:text>\verb'~'</xsl:text>
        <xsl:call-template name="escape-tilde">
          <xsl:with-param name="data"
                          select="substring-after($data, '~')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$data"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="escape-underscore">
    <xsl:param name="data"/>
    <xsl:call-template name="backslash-escape">
      <xsl:with-param name="data" select="$data"/>
      <xsl:with-param name="escapee" select="'_'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- '\\' imposes a linebreak in LaTeX, so we escape backslashes with \verb -->
  <xsl:template name="escape-backslash">
    <xsl:param name="data"/>
    <xsl:choose>
      <xsl:when test="contains($data, '\')">
        <xsl:value-of select="substring-before($data, '\')"/>
        <xsl:text>\verb'\'</xsl:text>
        <xsl:call-template name="escape-backslash">
          <xsl:with-param name="data" select="substring-after($data, '\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$data"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Tilde and caret must be escaped specially, else they become diacritics 
       over the following character. -->
  <xsl:template name="escape-caret">
    <xsl:param name="data"/>
    <xsl:choose>
      <xsl:when test="contains($data, '^')">
        <xsl:value-of select="substring-before($data, '^')"/>
        <xsl:text>\verb'^'</xsl:text>
        <xsl:call-template name="escape-caret">
          <xsl:with-param name="data" select="substring-after($data, '^')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$data"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Work around the circular escaping problem by converting curly braces 
       to this strange intermediate form.  Note that I may now have done away 
       with the need for this by escaping backslash without curly braces. -->
  <xsl:template name="escape-curly">
    <xsl:param name="data"/>
    <xsl:choose>
      <xsl:when test="contains($data, '{') or contains($data, '}')">
        <xsl:variable name="leftcurly-idx">
          <xsl:choose>
            <xsl:when test="contains($data, '{')">
              <xsl:value-of select="string-length(substring-before($data, '{'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="string-length($data)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="rightcurly-idx">
          <xsl:choose>
            <xsl:when test="contains($data, '}')">
              <xsl:value-of select="string-length(substring-before($data, '}'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="string-length($data)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$leftcurly-idx &lt; $rightcurly-idx">
            <xsl:value-of select="substring-before($data, '{')"/>
            <xsl:text>!!**1**!!</xsl:text>
            <xsl:call-template name="escape-curly">
              <xsl:with-param name="data" 
                              select="substring-after($data, '{')"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-before($data, '}')"/>
            <xsl:text>!!**2**!!</xsl:text>
            <xsl:call-template name="escape-curly">
              <xsl:with-param name="data" 
                              select="substring-after($data, '}')"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$data"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Fix the weird escaping of curly braces. -->
  <xsl:template name="fix-curly">
    <xsl:param name="data"/>
    <xsl:choose>
      <xsl:when test="contains($data, '!!**1**!!') or 
                      contains($data, '!!**2**!!')">
        <xsl:variable name="leftcurly-idx">
          <xsl:choose>
            <xsl:when test="contains($data, '!!**1**!!')">
              <xsl:value-of select="string-length(substring-before($data, '!!**1**!!'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="string-length($data)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="rightcurly-idx">
          <xsl:choose>
            <xsl:when test="contains($data, '!!**2**!!')">
              <xsl:value-of select="string-length(substring-before($data, '!!**2**!!'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="string-length($data)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$leftcurly-idx &lt; $rightcurly-idx">
            <xsl:value-of select="substring-before($data, '!!**1**!!')"/>
            <xsl:text>\{</xsl:text>
            <xsl:call-template name="fix-curly">
              <xsl:with-param name="data" 
                              select="substring-after($data, '!!**1**!!')"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-before($data, '!!**2**!!')"/>
            <xsl:text>\}</xsl:text>
            <xsl:call-template name="fix-curly">
              <xsl:with-param name="data" 
                              select="substring-after($data, '!!**2**!!')"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$data"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- The Great Escape -->
  <xsl:template name="escape-latexchars">
    <xsl:param name="data"/>
    <xsl:call-template name="fix-curly">
      <xsl:with-param name="data">
        <xsl:call-template name="escape-caret">
          <xsl:with-param name="data">
            <xsl:call-template name="escape-curly">
              <xsl:with-param name="data">
                <xsl:call-template name="escape-underscore">
                  <xsl:with-param name="data">
                    <xsl:call-template name="escape-tilde">
                      <xsl:with-param name="data">
                        <xsl:call-template name="escape-ampersand">
                          <xsl:with-param name="data">
                            <xsl:call-template name="escape-percent">
                              <xsl:with-param name="data">
                                <xsl:call-template name="escape-dollar">
                                  <xsl:with-param name="data">
                                    <xsl:call-template name="escape-octothorpe">
                                      <xsl:with-param name="data">
                                        <xsl:call-template name="escape-backslash">
                                          <xsl:with-param name="data" select="$data"/>
                                        </xsl:call-template>
                                      </xsl:with-param>
                                    </xsl:call-template>
                                  </xsl:with-param>
                                </xsl:call-template>
                              </xsl:with-param>
                            </xsl:call-template>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
